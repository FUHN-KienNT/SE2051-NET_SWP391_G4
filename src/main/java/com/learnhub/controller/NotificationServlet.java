package com.learnhub.controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.learnhub.constant.AppConstants;
import com.learnhub.entity.Notification;
import com.learnhub.entity.User;
import com.learnhub.service.NotificationService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "NotificationServlet", urlPatterns = {
        "/notifications", "/notifications/read", "/notifications/read-all"
})
public class NotificationServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(NotificationServlet.class.getName());
    private static final int POPUP_LIMIT = 20;
    private static final String CSRF_SESSION_KEY = "notificationCsrfToken";

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        prepareResponse(resp);
        User user = currentUser(req);
        if (user == null) {
            error(resp, HttpServletResponse.SC_UNAUTHORIZED, "Phiên đăng nhập đã hết hạn.");
            return;
        }
        if (!"/notifications".equals(req.getServletPath())) {
            error(resp, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Phương thức không được hỗ trợ.");
            return;
        }

        try {
            List<Notification> notifications = notificationService.getRecentNotifications(user.getId(), POPUP_LIMIT);
            int unreadCount = notificationService.countUnreadNotifications(user.getId());
            JsonArray items = new JsonArray();
            for (Notification notification : notifications) {
                JsonObject item = new JsonObject();
                item.addProperty("id", notification.getId().toString());
                item.addProperty("content", notification.getContent());
                item.addProperty("typeName", notification.getTypeName() == null
                        || notification.getTypeName().isBlank() ? "Hệ thống" : notification.getTypeName());
                item.addProperty("status", notification.getStatus());
                Timestamp time = notification.getSentAt() != null
                        ? notification.getSentAt() : notification.getCreatedAt();
                if (time != null) {
                    item.addProperty("sentAt", time.toInstant().toString());
                }
                items.add(item);
            }

            JsonObject body = new JsonObject();
            body.add("notifications", items);
            body.addProperty("unreadCount", unreadCount);
            body.addProperty("csrfToken", csrfToken(req.getSession(false)));
            write(resp, body);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Could not load notifications", e);
            error(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tải thông báo.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        prepareResponse(resp);
        User user = currentUser(req);
        if (user == null) {
            error(resp, HttpServletResponse.SC_UNAUTHORIZED, "Phiên đăng nhập đã hết hạn.");
            return;
        }
        String path = req.getServletPath();
        if (!"/notifications/read".equals(path) && !"/notifications/read-all".equals(path)) {
            error(resp, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Phương thức không được hỗ trợ.");
            return;
        }
        HttpSession session = req.getSession(false);
        Object token = session.getAttribute(CSRF_SESSION_KEY);
        if (!(token instanceof String)
                || !token.equals(req.getHeader("X-CSRF-Token"))) {
            error(resp, HttpServletResponse.SC_FORBIDDEN, "Yêu cầu không hợp lệ. Hãy tải lại thông báo.");
            return;
        }

        try {
            if ("/notifications/read-all".equals(path)) {
                int updated = notificationService.markAllAsRead(user.getId());
                JsonObject body = new JsonObject();
                body.addProperty("updated", updated);
                write(resp, body);
                return;
            }

            UUID id;
            try {
                id = UUID.fromString(req.getParameter("id"));
            } catch (IllegalArgumentException | NullPointerException e) {
                error(resp, HttpServletResponse.SC_BAD_REQUEST, "ID thông báo không hợp lệ.");
                return;
            }
            if (!notificationService.markAsRead(user.getId(), id)) {
                error(resp, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy thông báo.");
                return;
            }
            JsonObject body = new JsonObject();
            body.addProperty("updated", 1);
            write(resp, body);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Could not update notifications", e);
            error(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể cập nhật thông báo.");
        }
    }

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        Object account = session == null ? null : session.getAttribute(AppConstants.SessionKey.CURRENT_USER);
        return account instanceof User ? (User) account : null;
    }

    private String csrfToken(HttpSession session) {
        synchronized (session) {
            Object existing = session.getAttribute(CSRF_SESSION_KEY);
            if (existing instanceof String) {
                return (String) existing;
            }
            String token = UUID.randomUUID().toString();
            session.setAttribute(CSRF_SESSION_KEY, token);
            return token;
        }
    }

    private void prepareResponse(HttpServletResponse resp) {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
    }

    private void error(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        JsonObject body = new JsonObject();
        body.addProperty("error", message);
        write(resp, body);
    }

    private void write(HttpServletResponse resp, JsonObject body) throws IOException {
        resp.getWriter().write(body.toString());
    }
}
