package com.learnhub.controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.learnhub.dao.NotificationDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.entity.Notification;
import com.learnhub.entity.Registration;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SePay Webhook Endpoint.
 * Receives JSON webhook notification whenever money transfer arrives in bank account.
 * URL: /api/payment/sepay-webhook
 * Method: POST
 */
@WebServlet(name = "SePayWebhookServlet", urlPatterns = {"/api/payment/sepay-webhook"})
public class SePayWebhookServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SePayWebhookServlet.class.getName());
    private static final UUID PAYMENT_NOTIF_TYPE_ID = UUID.fromString("b0000000-0000-0000-0000-000000000023");
    private static final UUID DEFAULT_ADMIN_ID = UUID.fromString("c0000000-0000-0000-0000-000000000001");

    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String requestBody = sb.toString();
        LOGGER.info("SePay Webhook Received Body: " + requestBody);

        if (requestBody.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"success\": false, \"message\": \"Empty body\"}");
            return;
        }

        try {
            JsonObject json = JsonParser.parseString(requestBody).getAsJsonObject();

            // SePay fields: content (nội dung chuyển khoản), transferAmount, id, referenceCode...
            String content = json.has("content") ? json.get("content").getAsString() : "";
            long transferAmount = json.has("transferAmount") ? json.get("transferAmount").getAsLong() : 0;
            String transactionId = json.has("id") ? json.get("id").getAsString() : ("SP" + System.currentTimeMillis());

            // Tìm mã đơn dạng: LH<8_CHAR_HEX>
            String matchedRegPrefix = null;
            if (content != null && content.toUpperCase().contains("LH")) {
                int idx = content.toUpperCase().indexOf("LH");
                String sub = content.substring(idx);
                // Lấy chuỗi sau LH gồm 8 ký tự alphanumeric
                String[] parts = sub.split("[^a-zA-Z0-9]");
                if (parts.length > 0) {
                    matchedRegPrefix = parts[0].toUpperCase(); // Ví dụ LH4A8B9C12
                }
            }

            LOGGER.info("SePay Webhook Extracted Code: " + matchedRegPrefix + ", Amount: " + transferAmount);

            boolean matched = false;
            String responseMessage = "Order not found or already paid";

            if (matchedRegPrefix != null && matchedRegPrefix.length() >= 4) {
                String hexPart = matchedRegPrefix.substring(2); // Cắt bỏ "LH"
                // Quét các đơn đang pending để tìm đơn có ID bắt đầu bằng chuỗi hex này
                List<Registration> pendingList = registrationDAO.findRegistrations("", null, "pending", 0, 100);
                for (Registration reg : pendingList) {
                    String regHex = reg.getId().toString().replace("-", "").substring(0, 8).toUpperCase();
                    if (regHex.startsWith(hexPart)) {
                        matched = true;
                        long expectedAmount = reg.getAmount() != null ? reg.getAmount().longValue() : 0;
                        String courseTitle = reg.getCourseTitle() != null ? reg.getCourseTitle() : "Khóa học";

                        // Trường hợp 1: Chuyển THIẾU tiền -> KHÔNG kích hoạt khóa học, gửi thông báo cho học viên & Admin
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

                            responseMessage = "Underpayment detected: order remains pending";
                            break;
                        }

                        // Trường hợp 2: Chuyển ĐỦ hoặc THỪA tiền -> Kích hoạt khóa học ngay
                        reg.setTransactionId(transactionId);
                        registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");

                        if (transferAmount > expectedAmount) {
                            // Chuyển THỪA tiền -> Kích hoạt khóa học + thông báo hoàn trả tiền thừa
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

                            responseMessage = "Payment processed with overpayment notice";
                        } else {
                            // Chuyển ĐÚNG số tiền
                            LOGGER.info("SePay Webhook Success: Activated registration " + reg.getId());
                            sendPaymentNotification(reg.getUserId(), String.format(
                                    "Chúc mừng! Bạn đã thanh toán thành công %s đ và kích hoạt khóa học \"%s\".",
                                    formatVnd(transferAmount), courseTitle));
                            responseMessage = "Payment processed successfully";
                        }
                        break;
                    }
                }
            }

            if (matched) {
                out.write("{\"success\": true, \"message\": \"" + responseMessage + "\"}");
            } else {
                LOGGER.warning("SePay Webhook: No matching pending registration found for content: " + content);
                out.write("{\"success\": false, \"message\": \"" + responseMessage + "\"}");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing SePay Webhook JSON", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"success\": false, \"message\": \"Internal error: " + e.getMessage() + "\"}");
        }
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

    private static String formatVnd(long amount) {
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(amount);
    }
}
