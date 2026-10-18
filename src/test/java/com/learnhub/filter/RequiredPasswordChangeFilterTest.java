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
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RequiredPasswordChangeFilterTest {
    @Test
    void blocksOtherPagesButAllowsPasswordSetupAndSignOut() throws Exception {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setStatus("active");
        user.setRequiresPasswordChange(true);
        UserDAO dao = new UserDAO() {
            @Override public User findById(UUID id) { return user; }
        };
        RequiredPasswordChangeFilter filter = new RequiredPasswordChangeFilter(dao);

        Exchange blocked = new Exchange(user, "/home");
        filter.doFilter(blocked.request, blocked.response, blocked.chain);
        assertFalse(blocked.chainCalled.get());
        assertEquals("/learnhub/account/set-password", blocked.redirect.get());

        Exchange form = new Exchange(user, "/account/set-password");
        filter.doFilter(form.request, form.response, form.chain);
        assertTrue(form.chainCalled.get());

        Exchange logout = new Exchange(user, "/auth/logout");
        filter.doFilter(logout.request, logout.response, logout.chain);
        assertTrue(logout.chainCalled.get());
    }

    @Test
    void resumedSessionCanContinueAfterPasswordWasChangedElsewhere() throws Exception {
        User sessionUser = new User();
        sessionUser.setId(UUID.randomUUID());
        sessionUser.setRequiresPasswordChange(true);
        User fresh = new User();
        fresh.setId(sessionUser.getId());
        fresh.setStatus("active");
        UserDAO dao = new UserDAO() {
            @Override public User findById(UUID id) { return fresh; }
        };
        Exchange exchange = new Exchange(sessionUser, "/home");
        new RequiredPasswordChangeFilter(dao).doFilter(exchange.request, exchange.response, exchange.chain);
        assertTrue(exchange.chainCalled.get());
        assertEquals(fresh, exchange.attributes.get(AppConstants.SessionKey.CURRENT_USER));
    }

    private static final class Exchange {
        final Map<String, Object> attributes = new HashMap<>();
        final AtomicReference<String> redirect = new AtomicReference<>();
        final AtomicBoolean chainCalled = new AtomicBoolean();
        final HttpServletRequest request;
        final HttpServletResponse response;
        final FilterChain chain = (req, resp) -> chainCalled.set(true);

        Exchange(User user, String path) {
            attributes.put(AppConstants.SessionKey.CURRENT_USER, user);
            HttpSession session = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class}, (proxy, method, args) -> switch (method.getName()) {
                        case "getAttribute" -> attributes.get(args[0]);
                        case "setAttribute" -> { attributes.put((String) args[0], args[1]); yield null; }
                        default -> null;
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
                        return null;
                    });
        }
    }
}
