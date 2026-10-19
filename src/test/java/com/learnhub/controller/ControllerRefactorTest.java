package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Proxy;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class ControllerRefactorTest {
    @Test
    void sessionLookupDoesNotCreateAnonymousSessions() {
        Exchange exchange = new Exchange("/courses");
        assertNull(ControllerSupport.currentUser(exchange.request));
        assertFalse(exchange.sessionCreated);
        exchange.hasSession = true;
        exchange.sessionValues.put("currentUser", "invalid session value");
        assertNull(ControllerSupport.currentUser(exchange.request));
        User user = new User();
        exchange.sessionValues.put("currentUser", user);
        assertSame(user, ControllerSupport.currentUser(exchange.request));
    }

    @Test
    void optionalFiltersKeepTheirFallbacks() {
        for (String value : new String[]{null, "", " ", "invalid", "2147483648", "0", "-3"}) {
            assertEquals(1, ControllerSupport.pageNumber(value));
        }
        assertEquals(4, ControllerSupport.pageNumber(" 4 "));
        assertNull(ControllerSupport.optionalUuid(null));
        assertNull(ControllerSupport.optionalUuid("bad-id"));
        UUID id = UUID.randomUUID();
        assertEquals(id, ControllerSupport.optionalUuid(" " + id + " "));
    }

    @Test
    void loginRedirectPreservesQueryAndContextPath() throws Exception {
        Exchange exchange = new Exchange("/courses");
        exchange.query = "search=Java & JSP";
        String target = "/learnhub/courses?search=Java & JSP";
        assertEquals(target, ControllerSupport.requestUri(exchange.request));
        ControllerSupport.redirectToLogin(exchange.request, exchange.response, target, "must_login");
        assertEquals("/learnhub/auth/login?error=must_login&redirect_uri="
                + URLEncoder.encode(target, StandardCharsets.UTF_8), exchange.redirect);
    }

    @Test
    void signInRotatesSessionAndPreservesRequiredPasswordChange() throws Exception {
        Exchange exchange = new Exchange("/auth/login");
        User user = new User();
        user.setUsername("student");
        user.setRoleCode(AppConstants.Role.STUDENT);
        user.setRequiresPasswordChange(true);
        ControllerSupport.signIn(exchange.request, exchange.response, user, "/learnhub/my-enrollments");
        assertTrue(exchange.sessionRotated);
        assertSame(user, exchange.sessionValues.get("currentUser"));
        assertEquals("student", exchange.sessionValues.get("userName"));
        assertEquals(AppConstants.Role.STUDENT, exchange.sessionValues.get("userRole"));
        assertEquals("/learnhub/my-enrollments", exchange.sessionValues.get("account.afterPasswordRedirect"));
        assertEquals("/learnhub/account/set-password", exchange.redirect);
    }

    @Test
    void signInRejectsExternalRedirect() throws Exception {
        Exchange exchange = new Exchange("/auth/login");
        User user = new User();
        user.setRoleCode(AppConstants.Role.STUDENT);
        ControllerSupport.signIn(exchange.request, exchange.response, user, "https://example.com");
        assertTrue(exchange.sessionRotated);
        assertTrue(exchange.redirect.startsWith("/learnhub/"));
    }

    @Test
    void bothHistoryAliasesStillRequireLoginAndRejectPost() throws Exception {
        for (String path : new String[]{"/my-payments", "/payment/history"}) {
            Exchange exchange = new Exchange(path);
            new PaymentServlet().doGet(exchange.request, exchange.response);
            assertEquals("/learnhub/auth/login?error=must_login&redirect_uri=%2Flearnhub%2Fmy-payments",
                    exchange.redirect);
            Exchange post = new Exchange(path);
            post.parameters.put("action", "mock-pay");
            new PaymentServlet().doPost(post.request, post.response);
            assertEquals(405, post.error);
            assertNull(post.redirect);
        }
    }

    @Test
    void checkoutMissingOrInvalidRegistrationStillRedirectsToCourses() throws Exception {
        for (String value : new String[]{null, "", "invalid"}) {
            Exchange exchange = new Exchange("/payment/checkout");
            if (value != null) exchange.parameters.put("regId", value);
            new PaymentServlet().doGet(exchange.request, exchange.response);
            assertEquals("/learnhub/courses", exchange.redirect);
        }
    }

    @Test
    void vnpayIpnStillRejectsMissingChecksumBeforeDatabaseAccess() throws Exception {
        Exchange exchange = new Exchange("/api/payment/vnpay-ipn");
        new VNPayServlet().doGet(exchange.request, exchange.response);
        assertEquals("{\"RspCode\":\"97\",\"Message\":\"Invalid Checksum\"}", exchange.body.toString());
        assertNull(exchange.redirect);
    }

    private static final class Exchange {
        final Map<String, Object> sessionValues = new HashMap<>();
        final Map<String, String> parameters = new HashMap<>();
        final StringWriter body = new StringWriter();
        final HttpServletRequest request;
        final HttpServletResponse response;
        boolean hasSession;
        boolean sessionCreated;
        boolean sessionRotated;
        String query;
        String redirect;
        int error;

        Exchange(String path) {
            HttpSession session = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class}, (proxy, method, args) -> {
                        switch (method.getName()) {
                            case "getAttribute": return sessionValues.get(args[0]);
                            case "setAttribute": sessionValues.put((String) args[0], args[1]); break;
                            case "removeAttribute": sessionValues.remove(args[0]); break;
                        }
                        return null;
                    });
            request = (HttpServletRequest) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletRequest.class}, (proxy, method, args) -> {
                        switch (method.getName()) {
                            case "getSession":
                                if (args == null || Boolean.TRUE.equals(args[0])) {
                                    sessionCreated = !hasSession;
                                    hasSession = true;
                                }
                                return hasSession ? session : null;
                            case "changeSessionId": sessionRotated = true; return "rotated";
                            case "getServletPath": return path;
                            case "getRequestURI": return "/learnhub" + path;
                            case "getContextPath": return "/learnhub";
                            case "getQueryString": return query;
                            case "getProtocol": return "HTTP/1.1";
                            case "getParameter": return parameters.get(args[0]);
                            case "getParameterMap": return Map.of();
                            default: return null;
                        }
                    });
            response = (HttpServletResponse) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletResponse.class}, (proxy, method, args) -> {
                        switch (method.getName()) {
                            case "sendRedirect": redirect = (String) args[0]; break;
                            case "sendError": error = (Integer) args[0]; break;
                            case "getWriter": return new PrintWriter(body);
                        }
                        return null;
                    });
        }
    }
}
