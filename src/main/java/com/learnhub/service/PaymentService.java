package com.learnhub.service;

import com.learnhub.dao.PaymentDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.entity.Payment;
import com.learnhub.entity.Registration;
import com.learnhub.util.VNPayGateway;

import java.util.Map;
import java.util.UUID;
import java.util.logging.Logger;

/**
 * Service managing payment processing and VNPay webhooks.
 * Implements methods specified in Enrollment & Payment Class Diagram (SDS 1.1):
 * - createPaymentRequest()
 * - verifySignature()
 * - updatePaymentStatus()
 */
public class PaymentService {
    private static final Logger LOGGER = Logger.getLogger(PaymentService.class.getName());

    private final PaymentDAO paymentDAO;
    private final RegistrationDAO registrationDAO;
    private final EnrollmentService enrollmentService;
    private final NotificationService notificationService;

    public PaymentService() {
        this.paymentDAO = new PaymentDAO();
        this.registrationDAO = new RegistrationDAO();
        this.enrollmentService = new EnrollmentService();
        this.notificationService = new NotificationService();
    }

    public String createPaymentRequest(UUID registrationId, String clientIp) {
        Registration reg = registrationDAO.findById(registrationId);
        if (reg == null) return null;

        Payment p = new Payment();
        p.setId(UUID.randomUUID());
        p.setRegistrationId(registrationId);
        p.setAmount(reg.getAmount());
        p.setPaymentMethod("vnpay");
        p.setStatus("pending");
        paymentDAO.insert(p);

        return VNPayGateway.buildPaymentUrl(
            registrationId,
            reg.getAmount(),
            "Thanh toan khoa hoc LearnHub - " + reg.getCourseTitle(),
            clientIp
        );
    }

    public boolean verifySignature(Map<String, String> params) {
        return VNPayGateway.verifySignature(params);
    }

    public boolean updatePaymentStatus(String transactionId, String status, Map<String, String> callbackData) {
        boolean success = "00".equals(callbackData.get("vnp_ResponseCode")) || "success".equalsIgnoreCase(status);
        String vnpTxnRef = callbackData.get("vnp_TxnRef");

        LOGGER.info("Processing payment update for TxnRef: " + vnpTxnRef + " Status: " + (success ? "PAID" : "FAILED"));

        if (vnpTxnRef != null && vnpTxnRef.contains("_")) {
            String regPrefix = vnpTxnRef.substring(0, vnpTxnRef.indexOf('_'));
            // Find registration and update
            Payment payment = paymentDAO.findByTransactionId(vnpTxnRef);
            if (payment != null) {
                paymentDAO.updateStatus(payment.getId(), success ? "success" : "failed");
                if (success) {
                    enrollmentService.activateEnrollment(payment.getRegistrationId());
                    Registration reg = registrationDAO.findById(payment.getRegistrationId());
                    if (reg != null) {
                        notificationService.notifyEnrollmentSuccess(reg.getUserId(), reg.getCourseTitle());
                    }
                }
            }
        }
        return success;
    }
}
