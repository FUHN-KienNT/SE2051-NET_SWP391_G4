package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.entity.Registration;
import com.learnhub.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Handles Student Registration History / Payment History screen.
 * URL: /my-payments
 */
@WebServlet(name = "PaymentHistoryServlet", urlPatterns = {"/my-payments", "/payment/history"})
public class PaymentHistoryServlet extends HttpServlet {
    private final RegistrationDAO registrationDAO = new RegistrationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER) : null;

        if (currentUser == null) {
            String redirectUri = req.getContextPath() + "/my-payments";
            String encodedUri = URLEncoder.encode(redirectUri, StandardCharsets.UTF_8);
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
            return;
        }

        // Lấy toàn bộ danh sách đăng ký & thanh toán của học viên này
        List<Registration> payments = registrationDAO.findByUserId(currentUser.getId());

        req.setAttribute("payments", payments);
        req.setAttribute("pageTitle", "Lịch sử thanh toán - LearnHub");
        req.getRequestDispatcher("/WEB-INF/views/courses/payment-history.jsp").forward(req, resp);
    }
}
