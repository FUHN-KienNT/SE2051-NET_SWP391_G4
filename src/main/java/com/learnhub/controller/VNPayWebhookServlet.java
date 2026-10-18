package com.learnhub.controller;

import com.learnhub.dao.RegistrationDAO;
import com.learnhub.entity.Registration;
import com.learnhub.util.VNPayUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * VNPay IPN (Instant Payment Notification) Webhook API.
 * Called automatically by VNPay Server to confirm transaction status.
 * URL: /api/payment/vnpay-ipn
 */
@WebServlet(name = "VNPayWebhookServlet", urlPatterns = {"/api/payment/vnpay-ipn"})
public class VNPayWebhookServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(VNPayWebhookServlet.class.getName());
    private final RegistrationDAO registrationDAO = new RegistrationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String vnp_ResponseCode = req.getParameter("vnp_ResponseCode");
        String vnp_TxnRef = req.getParameter("vnp_TxnRef");
        String vnp_TransactionNo = req.getParameter("vnp_TransactionNo");

        LOGGER.info("VNPay IPN Received: TxnRef=" + vnp_TxnRef + ", ResponseCode=" + vnp_ResponseCode);

        boolean isChecksumValid = VNPayUtil.verifyIpnChecksum(req.getParameterMap());
        if (!isChecksumValid) {
            LOGGER.warning("VNPay IPN Invalid Checksum for TxnRef=" + vnp_TxnRef);
            resp.getWriter().write("{\"RspCode\":\"97\",\"Message\":\"Invalid Checksum\"}");
            return;
        }

        UUID regId = null;
        Registration reg = null;
        try {
            regId = UUID.fromString(vnp_TxnRef.trim());
            reg = registrationDAO.findById(regId);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error parsing TxnRef", e);
        }

        if (reg == null) {
            resp.getWriter().write("{\"RspCode\":\"01\",\"Message\":\"Order not found\"}");
            return;
        }

        if ("paid".equalsIgnoreCase(reg.getPaymentStatus())) {
            resp.getWriter().write("{\"RspCode\":\"02\",\"Message\":\"Order already confirmed\"}");
            return;
        }

        if ("00".equals(vnp_ResponseCode)) {
            reg.setTransactionId(vnp_TransactionNo != null ? vnp_TransactionNo : "VNP" + System.currentTimeMillis());
            registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");
            LOGGER.info("VNPay IPN Success: Activated registration " + reg.getId());
            resp.getWriter().write("{\"RspCode\":\"00\",\"Message\":\"Confirm Success\"}");
        } else {
            LOGGER.info("VNPay IPN Failed with code " + vnp_ResponseCode + " for registration " + reg.getId());
            resp.getWriter().write("{\"RspCode\":\"00\",\"Message\":\"Confirm Success\"}");
        }
    }
}
