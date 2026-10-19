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
 * VNPay browser return and server IPN, with separate response contracts.
 * URLs: /payment/vnpay-return and /api/payment/vnpay-ipn.
 */
@WebServlet(name = "VNPayServlet", urlPatterns = {"/payment/vnpay-return", "/api/payment/vnpay-ipn"})
public class VNPayServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(VNPayServlet.class.getName());
    private final RegistrationDAO registrationDAO = new RegistrationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("/api/payment/vnpay-ipn".equals(req.getServletPath())) {
            handleIpn(req, resp);
        } else {
            handleReturn(req, resp);
        }
    }

    private void handleReturn(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String vnp_ResponseCode = req.getParameter("vnp_ResponseCode");
        String vnp_TxnRef = req.getParameter("vnp_TxnRef"); // registration.id
        String vnp_TransactionNo = req.getParameter("vnp_TransactionNo");
        String vnp_Amount = req.getParameter("vnp_Amount");
        String vnp_OrderInfo = req.getParameter("vnp_OrderInfo");

        LOGGER.info("VNPay Return: TxnRef=" + vnp_TxnRef + ", ResponseCode=" + vnp_ResponseCode + ", TranNo=" + vnp_TransactionNo);

        boolean isChecksumValid = VNPayUtil.verifyIpnChecksum(req.getParameterMap());
        boolean isSuccess = "00".equals(vnp_ResponseCode);

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

        if (reg != null) {
            if (isSuccess) {
                // Cập nhật trạng thái thành 'paid' và lưu transaction_id
                reg.setTransactionId(vnp_TransactionNo != null ? vnp_TransactionNo : "VNP" + System.currentTimeMillis());
                registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");
                req.setAttribute("paymentSuccess", true);
                req.setAttribute("message", "Thanh toán qua VNPAY thành công! Bạn đã được kích hoạt khóa học.");
            } else {
                req.setAttribute("paymentSuccess", false);
                req.setAttribute("message", "Giao dịch không thành công hoặc đã bị hủy (Mã lỗi VNPAY: " + vnp_ResponseCode + ").");
            }
            req.setAttribute("registration", reg);
        } else {
            req.setAttribute("paymentSuccess", false);
            req.setAttribute("message", "Không tìm thấy thông tin đơn hàng tương ứng trong hệ thống.");
        }

        req.setAttribute("vnp_TxnRef", vnp_TxnRef);
        req.setAttribute("vnp_TransactionNo", vnp_TransactionNo);
        req.setAttribute("vnp_Amount", vnp_Amount);
        req.setAttribute("vnp_OrderInfo", vnp_OrderInfo);
        req.setAttribute("pageTitle", "Kết quả thanh toán - LearnHub");

        req.getRequestDispatcher("/WEB-INF/views/courses/payment-result.jsp").forward(req, resp);
    }

    private void handleIpn(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
