package com.learnhub.controller;

import com.learnhub.entity.Registration;
import com.learnhub.service.CourseService;
import com.learnhub.service.PaymentService;
import com.learnhub.util.VNPayGateway;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;
import java.util.UUID;

/**
 * Servlet handling Payment flows and Webhook.
 * Implements methods specified in SDS Enrollment & Payment Class Diagram (1.1, 1.2, 1.3):
 * - checkout()
 * - handleWebhook()
 * - paymentResult()
 */
@WebServlet(name = "PaymentServlet", urlPatterns = {"/checkout", "/payment/webhook", "/payment/result"})
public class PaymentServlet extends HttpServlet {
    private final PaymentService paymentService = new PaymentService();
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/checkout".equals(path)) {
            String regIdStr = req.getParameter("registrationId");
            if (regIdStr != null) {
                try {
                    UUID regId = UUID.fromString(regIdStr);
                    Registration reg = courseService.getRegistrationDetailById(regId);
                    req.setAttribute("registration", reg);
                    req.getRequestDispatcher("/WEB-INF/views/payment/checkout.jsp").forward(req, resp);
                    return;
                } catch (Exception ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        if ("/payment/result".equals(path) || "/payment/webhook".equals(path)) {
            Map<String, String> params = VNPayGateway.parseCallback(req.getParameterMap());
            boolean validSignature = paymentService.verifySignature(params);
            boolean success = false;

            if (validSignature) {
                String responseCode = params.get("vnp_ResponseCode");
                String txnRef = params.get("vnp_TxnRef");
                success = paymentService.updatePaymentStatus(txnRef, "00".equals(responseCode) ? "success" : "failed", params);
            }

            req.setAttribute("paymentSuccess", success);
            req.setAttribute("params", params);
            req.getRequestDispatcher("/WEB-INF/views/payment/result.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/checkout".equals(path)) {
            String regIdStr = req.getParameter("registrationId");
            if (regIdStr != null) {
                try {
                    UUID regId = UUID.fromString(regIdStr);
                    String clientIp = req.getRemoteAddr();
                    String payUrl = paymentService.createPaymentRequest(regId, clientIp);
                    if (payUrl != null) {
                        resp.sendRedirect(payUrl);
                        return;
                    }
                } catch (Exception ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        if ("/payment/webhook".equals(path)) {
            Map<String, String> params = VNPayGateway.parseCallback(req.getParameterMap());
            paymentService.updatePaymentStatus(params.get("vnp_TxnRef"), "pending", params);
            resp.getWriter().write("{\"RspCode\":\"00\",\"Message\":\"Confirm Success\"}");
        }
    }
}
