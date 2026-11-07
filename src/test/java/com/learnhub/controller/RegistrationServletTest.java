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
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RegistrationServletTest {

    @Test
    void servletHasDedicatedUrlMappings() {
        WebServlet mapping = RegistrationServlet.class.getAnnotation(WebServlet.class);
        List<String> routes = Arrays.asList(mapping.urlPatterns());
        assertTrue(routes.contains("/manager/registrations"));
        assertTrue(routes.contains("/admin/registrations"));
    }

    @Test
    void studentCannotAccessRegistrationManagement() throws Exception {
        Exchange exchange = new Exchange(AppConstants.Role.STUDENT, "/manager/registrations");
        new RegistrationServlet().doGet(exchange.request, exchange.response);
        assertEquals(HttpServletResponse.SC_FORBIDDEN, exchange.errorCode.get());
    }

    @Test
    void unauthenticatedUserRedirectsToLogin() throws Exception {
        Exchange exchange = new Exchange(null, "/manager/registrations");
        new RegistrationServlet().doGet(exchange.request, exchange.response);
        assertTrue(exchange.redirect.get() != null && exchange.redirect.get().contains("/auth/login"));
    }

    private static final class Exchange {
        final AtomicReference<String> redirect = new AtomicReference<>();
        final AtomicInteger errorCode = new AtomicInteger();
        final HttpServletRequest request;
        final HttpServletResponse response;

        Exchange(String role, String path) {
            User user = null;
            if (role != null) {
                user = new User();
                user.setRoleCode(role);
            }
            final User finalUser = user;

            HttpSession session = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class}, (proxy, method, args) -> {
                        if ("getAttribute".equals(method.getName())) {
                            if ("currentUser".equals(args[0])) return finalUser;
                            if ("userRole".equals(args[0])) return role;
                        }
                        return null;
                    });

            request = (HttpServletRequest) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletRequest.class}, (proxy, method, args) -> switch (method.getName()) {
                        case "getSession" -> session;
                        case "getServletPath" -> path;
                        case "getContextPath" -> "/learnhub";
                        case "getRequestURI" -> "/learnhub" + path;
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
