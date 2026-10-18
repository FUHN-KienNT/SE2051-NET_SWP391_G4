package com.learnhub.filter;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AuthorizationFilterManagerTest {
    @Test
    void managerCanOpenManagerDashboard() throws Exception {
        Exchange exchange = new Exchange(AppConstants.Role.MANAGER);
        new AuthorizationFilter().doFilter(exchange.request, exchange.response, exchange.chain);
        assertTrue(exchange.chainCalled.get());
        assertEquals(0, exchange.errorCode.get());
    }

    @Test
    void otherRolesCannotOpenManagerDashboard() throws Exception {
        for (String role : new String[]{AppConstants.Role.ADMIN, AppConstants.Role.EXPERT,
                AppConstants.Role.STUDENT}) {
            Exchange exchange = new Exchange(role);
            new AuthorizationFilter().doFilter(exchange.request, exchange.response, exchange.chain);
            assertFalse(exchange.chainCalled.get());
            assertEquals(HttpServletResponse.SC_FORBIDDEN, exchange.errorCode.get());
        }
    }

    private static final class Exchange {
        final AtomicBoolean chainCalled = new AtomicBoolean();
        final AtomicInteger errorCode = new AtomicInteger();
        final FilterChain chain = (request, response) -> chainCalled.set(true);
        final HttpServletRequest request;
        final HttpServletResponse response;

        Exchange(String role) {
            User user = new User();
            user.setRoleCode(role);
            HttpSession session = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class}, (proxy, method, args) -> {
                        if ("getAttribute".equals(method.getName())) {
                            if (AppConstants.SessionKey.CURRENT_USER.equals(args[0])) return user;
                            if ("userRole".equals(args[0])) return role;
                        }
                        return null;
                    });
            request = (HttpServletRequest) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletRequest.class}, (proxy, method, args) -> switch (method.getName()) {
                        case "getSession" -> session;
                        case "getServletPath" -> "/manager/dashboard";
                        default -> null;
                    });
            response = (HttpServletResponse) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletResponse.class}, (proxy, method, args) -> {
                        if ("sendError".equals(method.getName())) errorCode.set((Integer) args[0]);
                        return null;
                    });
        }
    }
}
