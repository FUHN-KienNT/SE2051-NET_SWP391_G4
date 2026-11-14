package com.learnhub.service;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.learnhub.dao.NotificationDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.entity.Notification;
import com.learnhub.entity.Registration;
import com.learnhub.util.VNPayUtil;

import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service managing payment operations, VietQR/SePay webhook processing,
 * and VNPay return/IPN validation.
 * Enforces Controller -> Service -> DAO clean architecture.
 */
public class PaymentService {
    private static final Logger LOGGER = Logger.getLogger(PaymentService.class.getName());
    private static final UUID PAYMENT_NOTIF_TYPE_ID = UUID.fromString("b0000000-0000-0000-0000-000000000023");
    private static final UUID DEFAULT_ADMIN_ID = UUID.fromString("c0000000-0000-0000-0000-000000000001");

    private final RegistrationDAO registrationDAO;
    private final NotificationDAO notificationDAO;

    public PaymentService() {
        this.registrationDAO = new RegistrationDAO();
        this.notificationDAO = new NotificationDAO();
    }

    public PaymentService(RegistrationDAO registrationDAO, NotificationDAO notificationDAO) {
        this.registrationDAO = registrationDAO;
        this.notificationDAO = notificationDAO;
    }

    public Registration getRegistrationById(UUID id) {
        if (id == null) return null;
        return registrationDAO.findById(id);
    }

    public List<Registration> getPaymentHistory(UUID userId) {
        if (userId == null) return List.of();
        return registrationDAO.findByUserId(userId);
    }

    public boolean updateRegistrationStatus(UUID id, String status, String paymentStatus) {
        if (id == null) return false;
        return registrationDAO.updateRegistrationStatus(id, status, paymentStatus);
    }

    public boolean mockPayment(UUID regId) {
        if (regId == null) return false;
        Registration reg = registrationDAO.findById(regId);
        if (reg != null) {
            reg.setTransactionId("SP" + System.currentTimeMillis());
            return registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");
        }
        return false;
    }

    // ==========================================
    // SePay Webhook Handling
    // ==========================================

    public record SePayResult(boolean success, int httpStatusCode, String message) {}

    public SePayResult processSePayWebhook(String requestBody) {
        if (requestBody == null || requestBody.isBlank()) {
            return new SePayResult(false, 400, "Empty body");
        }

        try {
            JsonObject json = JsonParser.parseString(requestBody).getAsJsonObject();

            String content = json.has("content") ? json.get("content").getAsString() : "";
            long transferAmount = json.has("transferAmount") ? json.get("transferAmount").getAsLong() : 0;
            String transactionId = json.has("id") ? json.get("id").getAsString() : ("SP" + System.currentTimeMillis());

            // Tìm mã đơn dạng: LH<8_CHAR_HEX>
            String matchedRegPrefix = null;
            if (content != null && content.toUpperCase().contains("LH")) {
                int idx = content.toUpperCase().indexOf("LH");
                String sub = content.substring(idx);
                String[] parts = sub.split("[^a-zA-Z0-9]");
                if (parts.length > 0) {
                    matchedRegPrefix = parts[0].toUpperCase();
                }
            }

            LOGGER.info("SePay Webhook Extracted Code: " + matchedRegPrefix + ", Amount: " + transferAmount);

            if (matchedRegPrefix != null && matchedRegPrefix.length() >= 4) {
                String hexPart = matchedRegPrefix.substring(2); // Cắt bỏ "LH"
                List<Registration> pendingList = registrationDAO.findRegistrations("", null, "pending", 0, 100);

                for (Registration reg : pendingList) {
                    String regHex = reg.getId().toString().replace("-", "").substring(0, 8).toUpperCase();
                    if (regHex.startsWith(hexPart)) {
                        long expectedAmount = reg.getAmount() != null ? reg.getAmount().longValue() : 0;
                        String courseTitle = reg.getCourseTitle() != null ? reg.getCourseTitle() : "Khóa học";

                        // Trường hợp 1: Chuyển THIẾU tiền -> Giữ pending, cảnh báo học viên & Admin
                        if (transferAmount < expectedAmount) {
                            long shortfall = expectedAmount - transferAmount;
                            LOGGER.warning(String.format(
                                    "SePay Webhook Underpayment: Reg=%s, Expected=%d, Received=%d, Shortfall=%d",
                                    reg.getId(), expectedAmount, transferAmount, shortfall));

                            sendPaymentNotification(reg.getUserId(), String.format(
                                    "Thanh toán chưa hoàn tất cho khóa học \"%s\": Hệ thống nhận được %s đ nhưng học phí là %s đ (còn thiếu %s đ). Vui lòng liên hệ hỗ trợ để chuyển bổ sung hoặc nhận hoàn tiền.",
                                    courseTitle, formatVnd(transferAmount), formatVnd(expectedAmount), formatVnd(shortfall)));

                            sendPaymentNotification(DEFAULT_ADMIN_ID, String.format(
                                    "[Cảnh báo chuyển thiếu] Đơn %s (%s): Học viên chuyển %s đ / %s đ (thiếu %s đ, Mã GD SePay: %s). Đơn vẫn giữ trạng thái pending.",
                                    matchedRegPrefix, courseTitle, formatVnd(transferAmount), formatVnd(expectedAmount), formatVnd(shortfall), transactionId));

                            return new SePayResult(true, 200, "Underpayment detected: order remains pending");
                        }

                        // Trường hợp 2: Chuyển ĐỦ hoặc THỪA tiền -> Kích hoạt khóa học ngay
                        reg.setTransactionId(transactionId);
                        registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");

                        if (transferAmount > expectedAmount) {
                            long excessAmount = transferAmount - expectedAmount;
                            LOGGER.info(String.format(
                                    "SePay Webhook Overpayment: Activated Reg=%s, Expected=%d, Received=%d, Excess=%d",
                                    reg.getId(), expectedAmount, transferAmount, excessAmount));

                            sendPaymentNotification(reg.getUserId(), String.format(
                                    "Khóa học \"%s\" đã được kích hoạt! Hệ thống ghi nhận bạn chuyển dư %s đ (Đã nhận: %s đ / Học phí: %s đ). Bộ phận kế toán sẽ liên hệ hoàn trả số tiền dư cho bạn.",
                                    courseTitle, formatVnd(excessAmount), formatVnd(transferAmount), formatVnd(expectedAmount)));

                            sendPaymentNotification(DEFAULT_ADMIN_ID, String.format(
                                    "[Cần hoàn tiền thừa] Đơn %s (%s): Học viên chuyển dư %s đ (Đã nhận: %s đ / Học phí: %s đ, Mã GD SePay: %s). Vui lòng kiểm tra và hoàn trả tiền dư.",
                                    matchedRegPrefix, courseTitle, formatVnd(excessAmount), formatVnd(transferAmount), formatVnd(expectedAmount), transactionId));

                            return new SePayResult(true, 200, "Payment processed with overpayment notice");
                        } else {
                            LOGGER.info("SePay Webhook Success: Activated registration " + reg.getId());
                            sendPaymentNotification(reg.getUserId(), String.format(
                                    "Chúc mừng! Bạn đã thanh toán thành công %s đ và kích hoạt khóa học \"%s\".",
                                    formatVnd(transferAmount), courseTitle));
                            return new SePayResult(true, 200, "Payment processed successfully");
                        }
                    }
                }
            }

            LOGGER.warning("SePay Webhook: No matching pending registration found for content: " + content);
            return new SePayResult(false, 200, "Order not found or already paid");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing SePay Webhook JSON", e);
            return new SePayResult(false, 500, "Internal error: " + e.getMessage());
        }
    }

    // ==========================================
    // VNPay Handling (Return & IPN)
    // ==========================================

    public record VNPayReturnResult(
            boolean isValid,
            boolean isSuccess,
            Registration registration,
            String message,
            String txnRef,
            String transactionNo,
            String amount,
            String orderInfo
    ) {}

    public VNPayReturnResult processVNPayReturn(Map<String, String[]> parameterMap) {
        String vnp_ResponseCode = getParam(parameterMap, "vnp_ResponseCode");
        String vnp_TxnRef = getParam(parameterMap, "vnp_TxnRef");
        String vnp_TransactionNo = getParam(parameterMap, "vnp_TransactionNo");
        String vnp_Amount = getParam(parameterMap, "vnp_Amount");
        String vnp_OrderInfo = getParam(parameterMap, "vnp_OrderInfo");

        LOGGER.info("VNPay Return: TxnRef=" + vnp_TxnRef + ", ResponseCode=" + vnp_ResponseCode + ", TranNo=" + vnp_TransactionNo);

        boolean isChecksumValid = VNPayUtil.verifyIpnChecksum(parameterMap);
        boolean isSuccess = isChecksumValid && "00".equals(vnp_ResponseCode);

        UUID regId = null;
        Registration reg = null;
        if (vnp_TxnRef != null) {
            try {
                regId = UUID.fromString(vnp_TxnRef.trim());
                reg = registrationDAO.findById(regId);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Invalid vnp_TxnRef UUID: " + vnp_TxnRef, e);
            }
        }

        String message;
        if (!isChecksumValid) {
            message = "Chữ ký bảo mật không hợp lệ (Checksum verification failed).";
        } else if (reg != null) {
            if (isSuccess) {
                reg.setTransactionId(vnp_TransactionNo != null ? vnp_TransactionNo : "VNP" + System.currentTimeMillis());
                registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");
                message = "Thanh toán qua VNPAY thành công! Bạn đã được kích hoạt khóa học.";
            } else {
                message = "Giao dịch không thành công hoặc đã bị hủy (Mã lỗi VNPAY: " + vnp_ResponseCode + ").";
            }
        } else {
            message = "Không tìm thấy thông tin đơn hàng tương ứng trong hệ thống.";
        }

        return new VNPayReturnResult(isChecksumValid, isSuccess, reg, message,
                vnp_TxnRef, vnp_TransactionNo, vnp_Amount, vnp_OrderInfo);
    }

    public record VNPayIpnResponse(String rspCode, String message) {}

    public VNPayIpnResponse processVNPayIpn(Map<String, String[]> parameterMap) {
        String vnp_ResponseCode = getParam(parameterMap, "vnp_ResponseCode");
        String vnp_TxnRef = getParam(parameterMap, "vnp_TxnRef");
        String vnp_TransactionNo = getParam(parameterMap, "vnp_TransactionNo");

        LOGGER.info("VNPay IPN Received: TxnRef=" + vnp_TxnRef + ", ResponseCode=" + vnp_ResponseCode);

        boolean isChecksumValid = VNPayUtil.verifyIpnChecksum(parameterMap);
        if (!isChecksumValid) {
            LOGGER.warning("VNPay IPN Invalid Checksum for TxnRef=" + vnp_TxnRef);
            return new VNPayIpnResponse("97", "Invalid Checksum");
        }

        UUID regId = null;
        Registration reg = null;
        try {
            if (vnp_TxnRef != null) {
                regId = UUID.fromString(vnp_TxnRef.trim());
                reg = registrationDAO.findById(regId);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error parsing TxnRef", e);
        }

        if (reg == null) {
            return new VNPayIpnResponse("01", "Order not found");
        }

        if ("paid".equalsIgnoreCase(reg.getPaymentStatus())) {
            return new VNPayIpnResponse("02", "Order already confirmed");
        }

        if ("00".equals(vnp_ResponseCode)) {
            reg.setTransactionId(vnp_TransactionNo != null ? vnp_TransactionNo : "VNP" + System.currentTimeMillis());
            registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");
            LOGGER.info("VNPay IPN Success: Activated registration " + reg.getId());
        } else {
            LOGGER.info("VNPay IPN Failed with code " + vnp_ResponseCode + " for registration " + reg.getId());
        }

        return new VNPayIpnResponse("00", "Confirm Success");
    }

    private void sendPaymentNotification(UUID userId, String message) {
        if (userId == null) return;
        try {
            Notification n = new Notification();
            n.setId(UUID.randomUUID());
            n.setUserId(userId);
            n.setTypeId(PAYMENT_NOTIF_TYPE_ID);
            n.setContent(message);
            n.setStatus("unread");
            notificationDAO.insert(n);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Could not insert payment notification for user " + userId, e);
        }
    }

    private String getParam(Map<String, String[]> paramMap, String key) {
        String[] values = paramMap.get(key);
        return (values != null && values.length > 0) ? values[0] : null;
    }

    private static String formatVnd(long amount) {
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(amount);
    }
}