package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.User;
import com.learnhub.service.AvatarService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

@WebServlet("/account/avatar")
@MultipartConfig(maxFileSize = AvatarService.MAX_BYTES, maxRequestSize = AvatarService.MAX_BYTES + 65536)
public class AvatarServlet extends HttpServlet {
    private final UserDAO users = new UserDAO();
    private final AvatarService avatars = new AvatarService();
    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        resp.setHeader("Cache-Control", "no-store");
        HttpSession session = req.getSession(false);
        Object current = session == null ? null : session.getAttribute(AppConstants.SessionKey.CURRENT_USER);
        if (!(current instanceof User sessionUser)) { resp.sendRedirect(req.getContextPath() + "/auth/login"); return; }
        User user = users.findById(sessionUser.getId());
        if (user == null || !AppConstants.UserStatus.ACTIVE.equalsIgnoreCase(user.getStatus())) { resp.sendError(403); return; }
        try {
            Object expected = session.getAttribute("account.csrfToken");
            String supplied = req.getParameter("csrfToken");
            if (!(expected instanceof String token) || supplied == null || !MessageDigest.isEqual(token.getBytes(StandardCharsets.UTF_8), supplied.getBytes(StandardCharsets.UTF_8))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }
            Part part = req.getPart("avatar");
            byte[] bytes = null;
            if (part != null) {
                try (InputStream input = part.getInputStream()) { bytes = input.readNBytes(AvatarService.MAX_BYTES + 1); }
            }
            AvatarService.Result result = avatars.update(user.getId(), bytes);
            if (result == AvatarService.Result.SUCCESS) {
                User refreshed = users.findById(user.getId());
                if (refreshed != null) session.setAttribute(AppConstants.SessionKey.CURRENT_USER, refreshed);
                resp.sendRedirect(req.getContextPath() + "/account?updated=avatar"); return;
            }
            showError(req, resp, user, result == AvatarService.Result.INVALID_IMAGE
                    ? "Choose a valid JPEG or PNG image no larger than 5 MB." : "Could not update your photo. Please try again.");
        } catch (IllegalStateException e) {
            showError(req, resp, user, "Choose a valid JPEG or PNG image no larger than 5 MB.");
        }
    }
    private void showError(HttpServletRequest req, HttpServletResponse resp, User user, String error) throws ServletException, IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        req.setAttribute("avatarError", error);
        req.setAttribute("profileUser", user);
        req.setAttribute("csrfToken", req.getSession(false).getAttribute("account.csrfToken"));
        req.getRequestDispatcher("/WEB-INF/views/profile/account.jsp").forward(req, resp);
    }
}
