package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.Arrays;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AdminDashboardServletTest {
    @Test
    void managerHasDedicatedServletUrl() {
        WebServlet mapping = AdminDashboardServlet.class.getAnnotation(WebServlet.class);
        assertTrue(Arrays.asList(mapping.urlPatterns()).contains("/manager/dashboard"));
    }

    @Test
    void oldAdminDashboardLinkRedirectsManagerToManagerDashboard() throws Exception {
        Exchange exchange = new Exchange(AppConstants.Role.MANAGER, "/admin/dashboard");
        new AdminDashboardServlet().doGet(exchange.request, exchange.response);
        assertEquals("/learnhub/manager/dashboard", exchange.redirect.get());
    }

    @Test
    void adminCannotOpenManagerDashboard() throws Exception {
        Exchange exchange = new Exchange(AppConstants.Role.ADMIN, "/manager/dashboard");
        new AdminDashboardServlet().doGet(exchange.request, exchange.response);
        assertEquals(HttpServletResponse.SC_FORBIDDEN, exchange.errorCode.get());
    }

    private static final class Exchange {
        final AtomicReference<String> redirect = new AtomicReference<>();
        final AtomicInteger errorCode = new AtomicInteger();
        final HttpServletRequest request;
        final HttpServletResponse response;

        Exchange(String role, String path) {
            User user = new User();
            user.setRoleCode(role);
            HttpSession session = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class}, (proxy, method, args) -> {
                        if ("getAttribute".equals(method.getName()) && "currentUser".equals(args[0])) return user;
                        return null;
                    });
            request = (HttpServletRequest) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletRequest.class}, (proxy, method, args) -> switch (method.getName()) {
                        case "getSession" -> session;
                        case "getServletPath" -> path;
                        case "getContextPath" -> "/learnhub";
                        default -> null;
                    });
            response = (HttpServletResponse) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletResponse.class}, (proxy, method, args) -> {
                        if ("sendRedirect".equals(method.getName())) redirect.set((String) args[0]);
                        if ("sendError".equals(method.getName())) errorCode.set((Integer) args[0]);
                        return null;
                    });
        }
    }
}
