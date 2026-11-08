package com.learnhub.filter;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AuthorizationFilterAccountStatusTest {

    private static class StubUserDao extends UserDAO {
        final User dbUser = new User();

        StubUserDao(UUID id, String status, String statusNote) {
            dbUser.setId(id);
            dbUser.setStatus(status);
            dbUser.setStatusNote(statusNote);
        }

        @Override
        public User findById(UUID id) {
            return dbUser.getId().equals(id) ? dbUser : null;
        }
    }

    private static class TestExchange {
        final AtomicBoolean chainCalled = new AtomicBoolean(false);
        final AtomicBoolean sessionInvalidated = new AtomicBoolean(false);
        final AtomicReference<String> redirectedUrl = new AtomicReference<>(null);
        final FilterChain chain = (req, resp) -> chainCalled.set(true);

        final HttpServletRequest request;
        final HttpServletResponse response;

        TestExchange(User sessionUser) {
            HttpSession session = (HttpSession) Proxy.newProxyInstance(
                    getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class},
                    (proxy, method, args) -> {
                        if ("getAttribute".equals(method.getName())) {
                            if (AppConstants.SessionKey.CURRENT_USER.equals(args[0])) {
                                return sessionUser;
                            }
                            if ("userRole".equals(args[0])) {
                                return sessionUser != null ? sessionUser.getRoleCode() : null;
                            }
                        }
                        if ("invalidate".equals(method.getName())) {
                            sessionInvalidated.set(true);
                            return null;
                        }
                        return null;
                    }
            );

            request = (HttpServletRequest) Proxy.newProxyInstance(
                    getClass().getClassLoader(),
                    new Class<?>[]{HttpServletRequest.class},
                    (proxy, method, args) -> switch (method.getName()) {
                        case "getSession" -> session;
                        case "getServletPath" -> "/account/profile";
                        case "getRequestURI" -> "/account/profile";
                        case "getContextPath" -> "";
                        case "getMethod" -> "GET";
                        default -> null;
                    }
            );

            response = (HttpServletResponse) Proxy.newProxyInstance(
                    getClass().getClassLoader(),
                    new Class<?>[]{HttpServletResponse.class},
                    (proxy, method, args) -> {
                        if ("sendRedirect".equals(method.getName())) {
                            redirectedUrl.set((String) args[0]);
                            return null;
                        }
                        return null;
                    }
            );
        }
    }

    @Test
    void activeUserInSessionPassesFilter() throws Exception {
        UUID userId = UUID.randomUUID();
        User sessionUser = new User();
        sessionUser.setId(userId);
        sessionUser.setStatus("active");
        sessionUser.setRoleCode(AppConstants.Role.STUDENT);

        StubUserDao stubDao = new StubUserDao(userId, "active", null);
        AuthorizationFilter filter = new AuthorizationFilter(stubDao);

        TestExchange exchange = new TestExchange(sessionUser);
        filter.doFilter(exchange.request, exchange.response, exchange.chain);

        assertTrue(exchange.chainCalled.get(), "Active user should proceed through filter chain");
        assertFalse(exchange.sessionInvalidated.get(), "Session should not be invalidated for active user");
        assertEquals(null, exchange.redirectedUrl.get(), "No redirection should occur for active user");
    }

    @Test
    void inactiveUserInSessionIsTerminatedAndRedirectedWithReason() throws Exception {
        UUID userId = UUID.randomUUID();
        User sessionUser = new User();
        sessionUser.setId(userId);
        sessionUser.setStatus("active"); // Was active when logged in
        sessionUser.setRoleCode(AppConstants.Role.STUDENT);

        // But in DB, status was changed by admin to inactive with a note
        StubUserDao stubDao = new StubUserDao(userId, "inactive", "Chưa hoàn tất học phí Fall 2026");
        AuthorizationFilter filter = new AuthorizationFilter(stubDao);

        TestExchange exchange = new TestExchange(sessionUser);
        filter.doFilter(exchange.request, exchange.response, exchange.chain);

        assertFalse(exchange.chainCalled.get(), "Suspended user should NOT proceed through filter chain");
        assertTrue(exchange.sessionInvalidated.get(), "Session must be invalidated on mid-session suspension");
        assertNotNull(exchange.redirectedUrl.get());
        assertTrue(exchange.redirectedUrl.get().contains("/auth/login?suspended=1"),
                "Must redirect to login with suspended flag");
        assertTrue(exchange.redirectedUrl.get().contains("reason="),
                "Must include encoded reason in query string");
    }

    private static void assertNotNull(Object obj) {
        org.junit.jupiter.api.Assertions.assertNotNull(obj);
    }
}
