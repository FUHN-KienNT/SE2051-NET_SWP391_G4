package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import com.learnhub.util.PostLoginNavigation;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

/** Shared HTTP mechanics; authorization and endpoint-specific errors stay in each servlet. */
final class ControllerSupport {
    private ControllerSupport() {}

    static User currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute(AppConstants.SessionKey.CURRENT_USER);
        return value instanceof User user ? user : null;
    }

    /** For optional filters only. Required identifiers must still report invalid input. */
    static UUID optionalUuid(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return UUID.fromString(value.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    static int pageNumber(String value) {
        try {
            return Math.max(1, Integer.parseInt(value == null ? "" : value.trim()));
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    static void redirectToLogin(HttpServletRequest request, HttpServletResponse response,
                                String target, String error) throws IOException {
        String query = error == null ? "" : "error=" + URLEncoder.encode(error, StandardCharsets.UTF_8) + "&";
        response.sendRedirect(request.getContextPath() + "/auth/login?" + query
                + "redirect_uri=" + URLEncoder.encode(target, StandardCharsets.UTF_8));
    }

    static String requestUri(HttpServletRequest request) {
        String query = request.getQueryString();
        return request.getRequestURI() + (query == null ? "" : "?" + query);
    }

    static void signIn(HttpServletRequest request, HttpServletResponse response,
                       User user, String redirect) throws IOException {
        HttpSession session = request.getSession(true);
        request.changeSessionId();
        session.setAttribute(AppConstants.SessionKey.CURRENT_USER, user);
        session.setAttribute("userName", user.getUsername());
        session.setAttribute("userRole", user.getRoleCode());
        String destination = PostLoginNavigation.destination(user, redirect, request.getContextPath());
        if (user.isRequiresPasswordChange()) {
            session.setAttribute("account.afterPasswordRedirect", destination);
            response.sendRedirect(request.getContextPath() + "/account/set-password");
        } else {
            response.sendRedirect(destination);
        }
    }
}
