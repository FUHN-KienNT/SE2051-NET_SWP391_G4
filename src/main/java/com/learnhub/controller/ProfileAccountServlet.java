package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.User;
import com.learnhub.service.ProfileService;
import com.learnhub.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;

@WebServlet(name = "ProfileAccountServlet", urlPatterns = {
        "/profile", "/account", "/account/profile", "/account/password"
})
public class ProfileAccountServlet extends HttpServlet {
    private static final String CSRF_TOKEN = "account.csrfToken";
    private final UserDAO userDAO = new UserDAO();
    private final UserService userService = new UserService();
    private final ProfileService profileService = new ProfileService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = loadCurrentUser(req, resp);
        if (user == null) return;
        resp.setHeader("Cache-Control", "no-store");
        switch (req.getServletPath()) {
            case "/profile" -> {
                req.setAttribute("profileUser", user);
                if (AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode())) {
                    req.setAttribute("overview", profileService.getOverview(user.getId()));
                }
                req.getRequestDispatcher("/WEB-INF/views/profile/index.jsp").forward(req, resp);
            }
            case "/account" -> showAccount(req, resp, user);
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = loadCurrentUser(req, resp);
        if (user == null) return;
        resp.setHeader("Cache-Control", "no-store");
        if (!hasValidCsrfToken(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        switch (req.getServletPath()) {
            case "/account/profile" -> updateProfile(req, resp, user);
            case "/account/password" -> changePassword(req, resp, user);
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    private User loadCurrentUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Object account = session == null ? null : session.getAttribute(AppConstants.SessionKey.CURRENT_USER);
        if (!(account instanceof User sessionUser)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }
        User fresh = userDAO.findById(sessionUser.getId());
        if (fresh == null || !AppConstants.UserStatus.ACTIVE.equalsIgnoreCase(fresh.getStatus())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return fresh;
    }

    private void showAccount(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session.getAttribute(CSRF_TOKEN) == null) {
            session.setAttribute(CSRF_TOKEN, UUID.randomUUID().toString());
        }
        req.setAttribute("csrfToken", session.getAttribute(CSRF_TOKEN));
        req.setAttribute("profileUser", user);
        req.getRequestDispatcher("/WEB-INF/views/profile/account.jsp").forward(req, resp);
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String requested = req.getParameter("username");
        UserService.UsernameUpdateResult result = userService.updateOwnUsername(user.getId(), requested);
        if (result == UserService.UsernameUpdateResult.SUCCESS) {
            refreshSessionUser(req, user.getId());
            resp.sendRedirect(req.getContextPath() + "/account?updated=profile");
            return;
        }
        req.setAttribute("enteredUsername", requested);
        req.setAttribute("profileError", switch (result) {
            case INVALID -> "Use 3–255 letters, numbers, dots, underscores, or hyphens.";
            case TAKEN -> "This username is already in use.";
            default -> "Could not save your username. Please try again.";
        });
        showAccount(req, resp, user);
    }

    private void changePassword(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");
        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            req.setAttribute("passwordError", "New passwords do not match.");
            showAccount(req, resp, user);
            return;
        }
        UserService.PasswordChangeResult result = userService.changeOwnPassword(
                user.getId(), req.getParameter("currentPassword"), newPassword);
        if (result == UserService.PasswordChangeResult.SUCCESS) {
            req.changeSessionId();
            refreshSessionUser(req, user.getId());
            resp.sendRedirect(req.getContextPath() + "/account?updated=password");
            return;
        }
        req.setAttribute("passwordError", switch (result) {
            case INVALID_CURRENT -> "Current password is incorrect.";
            case INVALID_NEW -> "Use at least 8 characters and no more than 72 bytes.";
            case SAME_PASSWORD -> "Choose a password different from your current one.";
            default -> "Could not change your password. Please try again.";
        });
        showAccount(req, resp, user);
    }

    private void refreshSessionUser(HttpServletRequest req, UUID userId) {
        User refreshed = userDAO.findById(userId);
        if (refreshed != null) {
            HttpSession session = req.getSession(false);
            session.setAttribute(AppConstants.SessionKey.CURRENT_USER, refreshed);
            session.setAttribute("userName", refreshed.getUsername());
            session.setAttribute("userRole", refreshed.getRoleCode());
        }
    }

    private boolean hasValidCsrfToken(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        Object expected = session == null ? null : session.getAttribute(CSRF_TOKEN);
        String supplied = req.getParameter("csrfToken");
        return expected instanceof String token && supplied != null
                && MessageDigest.isEqual(token.getBytes(StandardCharsets.UTF_8),
                supplied.getBytes(StandardCharsets.UTF_8));
    }
}
