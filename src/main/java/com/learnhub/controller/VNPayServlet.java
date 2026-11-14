package com.learnhub.controller;

import com.learnhub.service.PaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * VNPay browser return and server IPN, with separate response contracts.
 * URLs: /payment/vnpay-return and /api/payment/vnpay-ipn.
 */
@WebServlet(name = "VNPayServlet", urlPatterns = {"/payment/vnpay-return", "/api/payment/vnpay-ipn"})
public class VNPayServlet extends HttpServlet {
    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("/api/payment/vnpay-ipn".equals(req.getServletPath())) {
            handleIpn(req, resp);
        } else {
            handleReturn(req, resp);
        }
    }

    private void handleReturn(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        PaymentService.VNPayReturnResult result = paymentService.processVNPayReturn(req.getParameterMap());

        // Chống lỗ hổng IDOR: Kiểm tra chính chủ người thanh toán nếu có phiên đăng nhập
        com.learnhub.entity.User currentUser = ControllerSupport.currentUser(req);
        if (currentUser != null && result.registration() != null && !currentUser.getId().equals(result.registration().getUserId())) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        req.setAttribute("paymentSuccess", result.isSuccess());
        req.setAttribute("message", result.message());
        req.setAttribute("registration", result.registration());
        req.setAttribute("vnp_TxnRef", result.txnRef());
        req.setAttribute("vnp_TransactionNo", result.transactionNo());
        req.setAttribute("vnp_Amount", result.amount());
        req.setAttribute("vnp_OrderInfo", result.orderInfo());
        req.setAttribute("pageTitle", "Kết quả thanh toán - LearnHub");

        req.getRequestDispatcher("/WEB-INF/views/courses/payment-result.jsp").forward(req, resp);
    }

    private void handleIpn(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PaymentService.VNPayIpnResponse ipnResponse = paymentService.processVNPayIpn(req.getParameterMap());
        resp.getWriter().write(String.format("{\"RspCode\":\"%s\",\"Message\":\"%s\"}",
                ipnResponse.rspCode(), ipnResponse.message()));
    }
}