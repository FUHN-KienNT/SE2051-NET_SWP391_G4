package com.learnhub.controller;

import com.learnhub.entity.Registration;
import com.learnhub.entity.User;
import com.learnhub.service.PaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Payment pages: VietQR / SePay checkout, status polling, and student history.
 * URL: /payment/checkout
 * Action:
 * - GET /payment/checkout?regId=... -> Renders checkout.jsp (VietQR code)
 * - GET /payment/checkout?action=check-status&regId=... -> Returns JSON { "status": "paid"|"pending" }
 * - POST /payment/checkout?action=mock-pay&regId=... -> Demo trigger to simulate successful transfer
 */
@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment/checkout", "/my-payments", "/payment/history"})
public class PaymentServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(PaymentServlet.class.getName());
    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/payment/checkout".equals(req.getServletPath())) {
            showHistory(req, resp);
            return;
        }
        String action = req.getParameter("action");
        String regIdStr = req.getParameter("regId");

        if (regIdStr == null || regIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        UUID regId;
        try {
            regId = UUID.fromString(regIdStr.trim());
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        Registration reg = paymentService.getRegistrationById(regId);
        if (reg == null) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        // Chống lỗ hổng IDOR: Kiểm tra người dùng hiện tại có phải chính chủ đơn hàng này không
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser != null && !currentUser.getId().equals(reg.getUserId())) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        // 1. AJAX Check Status Polling
        if ("check-status".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            boolean isPaid = "paid".equalsIgnoreCase(reg.getPaymentStatus());
            out.write(String.format("{\"paid\": %b, \"paymentStatus\": \"%s\", \"courseId\": \"%s\"}",
                    isPaid, reg.getPaymentStatus(), reg.getCourseId()));
            return;
        }

        // 2. Render VietQR Checkout Page
        // Quy ước mã chuyển khoản: LH + 8 ký tự đầu của Registration ID (không dấu gạch nối)
        String transferCode = "LH" + reg.getId().toString().replace("-", "").substring(0, 8).toUpperCase();
        
        String bankCode = "MB"; // MBBank
        String bankAccount = "0964902684"; 
        String accountName = "LE DOAN ANH HUY";
        long amountVnd = reg.getAmount() != null ? reg.getAmount().longValue() : 0;

        String qrImageUrl = String.format("https://qr.sepay.vn/img?acc=%s&bank=%s&amount=%d&des=%s",
                bankAccount, bankCode, amountVnd, transferCode);

        req.setAttribute("registration", reg);
        req.setAttribute("transferCode", transferCode);
        req.setAttribute("bankCode", bankCode);
        req.setAttribute("bankName", "Ngân hàng Quân Đội (MB Bank)");
        req.setAttribute("bankAccount", bankAccount);
        req.setAttribute("accountName", accountName);
        req.setAttribute("amountVnd", amountVnd);
        req.setAttribute("qrImageUrl", qrImageUrl);
        req.setAttribute("pageTitle", "Thanh toán VietQR - " + reg.getCourseTitle());

        req.getRequestDispatcher("/WEB-INF/views/courses/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/payment/checkout".equals(req.getServletPath())) {
            super.doPost(req, resp);
            return;
        }
        String action = req.getParameter("action");
        String regIdStr = req.getParameter("regId");

        // Mock payment trigger for review & demo
        if ("mock-pay".equalsIgnoreCase(action) && regIdStr != null) {
            try {
                UUID regId = UUID.fromString(regIdStr.trim());
                paymentService.mockPayment(regId);
                LOGGER.info("Mock Pay Triggered for registration: " + regId);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error triggering mock payment", e);
            }
            resp.sendRedirect(req.getContextPath() + "/payment/checkout?regId=" + regIdStr);
            return;
        }

        doGet(req, resp);
    }

    private void showHistory(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User currentUser = ControllerSupport.currentUser(req);

        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, req.getContextPath() + "/my-payments", "must_login");
            return;
        }

        // Lấy toàn bộ danh sách đăng ký & thanh toán của học viên này qua PaymentService
        List<Registration> payments = paymentService.getPaymentHistory(currentUser.getId());

        req.setAttribute("payments", payments);
        req.setAttribute("pageTitle", "Lịch sử thanh toán - LearnHub");
        req.getRequestDispatcher("/WEB-INF/views/courses/payment-history.jsp").forward(req, resp);
    }
}