package com.learnhub.controller;

import com.learnhub.entity.User;
import com.learnhub.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth/login", "/auth/register", "/auth/logout"})
public class AuthServlet extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession authSession = req.getSession(false);
        if (authSession != null) {
            Object oauthError = authSession.getAttribute("oauth.error");
            if (oauthError != null) {
                req.setAttribute("errorMessage", oauthError);
                authSession.removeAttribute("oauth.error");
            }
        }
        if ("/auth/logout".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/home?logout=success");
            return;
        }

        if ("/auth/register".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // default: login
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/auth/login".equals(path)) {
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            User user = userService.login(email, password);

            if (user != null) {
                HttpSession session = req.getSession(true);
                session.setAttribute("currentUser", user);
                session.setAttribute("userName", user.getUsername());
                session.setAttribute("userRole", user.getRoleCode());

                String redirectUri = req.getParameter("redirect_uri");
                if (redirectUri != null && !redirectUri.trim().isEmpty()) {
                    resp.sendRedirect(redirectUri);
                } else if ("ROLE_ADMIN".equalsIgnoreCase(user.getRoleCode())) {
                    resp.sendRedirect(req.getContextPath() + "/admin/users");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/home");
                }
            } else {
                req.setAttribute("email", email);
                req.setAttribute("errorMessage", "Email hoặc mật khẩu không chính xác, hoặc tài khoản đã bị khóa.");
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            }
        } else if ("/auth/register".equals(path)) {
            String username = req.getParameter("username");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String confirmPassword = req.getParameter("confirmPassword");

            req.setAttribute("username", username);
            req.setAttribute("email", email);

            if (password == null || !password.equals(confirmPassword)) {
                req.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
                req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
                return;
            }

            User registered = userService.register(username, email, password);
            if (registered != null) {
                resp.sendRedirect(req.getContextPath() + "/auth/login?registered=success");
            } else {
                req.setAttribute("errorMessage", "Email này đã được sử dụng hoặc có lỗi xảy ra.");
                req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            }
        }
    }
}
