package com.learnhub.controller;

import com.learnhub.service.OAuthService;
import com.learnhub.service.OAuthService.Provider;
import com.learnhub.service.OAuthService.Profile;
import com.learnhub.entity.User;
import com.learnhub.util.FullNameUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.Serializable;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.time.Duration;
import java.time.Instant;

@WebServlet(urlPatterns = {"/auth/oauth/google", "/auth/oauth/google/callback", "/auth/oauth/github", "/auth/oauth/github/callback", "/auth/oauth/complete-profile"})
public class OAuthServlet extends HttpServlet {
    private static final String PENDING_PROFILE = "oauth.pendingProfile";
    private static final Duration PENDING_LIFETIME = Duration.ofMinutes(10);
    private final OAuthService oauth = new OAuthService();

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/auth/oauth/complete-profile".equals(path)) { showCompletion(req, resp); return; }
        Provider provider = path.contains("google") ? Provider.GOOGLE : Provider.GITHUB;
        if (path.endsWith("/callback")) { callback(req, resp, provider); return; }
        start(req, resp, provider);
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/auth/oauth/complete-profile".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        completeProfile(req, resp);
    }

    private void start(HttpServletRequest req, HttpServletResponse resp, Provider provider) throws IOException {
        String redirect = safeRedirect(req.getParameter("redirect_uri"), req.getContextPath());
        if (redirect == null) redirect = "";
        String state = OAuthService.newState();
        HttpSession session = req.getSession(true);
        session.removeAttribute(PENDING_PROFILE);
        session.setAttribute("oauth.state." + provider.name(), state);
        session.setAttribute("oauth.redirect." + provider.name(), redirect);
        String url = oauth.authorizationUrl(provider, state);
        if (url == null) { fail(req, resp, "Login with this provider is not configured."); return; }
        resp.sendRedirect(url);
    }

    private void callback(HttpServletRequest req, HttpServletResponse resp, Provider provider) throws IOException {
        HttpSession session = req.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute("oauth.state." + provider.name());
        String actual = req.getParameter("state");
        String redirect = session == null ? "" : (String) session.getAttribute("oauth.redirect." + provider.name());
        if (session != null) {
            session.removeAttribute("oauth.state." + provider.name());
            session.removeAttribute("oauth.redirect." + provider.name());
        }
        if (expected == null || actual == null || !MessageDigest.isEqual(expected.getBytes(StandardCharsets.UTF_8), actual.getBytes(StandardCharsets.UTF_8))) {
            fail(req, resp, "Login session is invalid or expired. Please try again."); return;
        }
        if (req.getParameter("error") != null) { fail(req, resp, "You cancelled or did not complete the login."); return; }
        String code = req.getParameter("code");
        if (code == null || code.isBlank()) { fail(req, resp, "Provider did not return a valid authentication code."); return; }
        Profile profile = null;
        try {
            profile = oauth.fetchProfile(provider, code);
            User user = oauth.resolveAccount(provider, profile);
            signIn(req, resp, user, redirect);
        } catch (OAuthService.FullNameRequiredException e) {
            if (profile == null) { fail(req, resp, "Could not verify account with provider."); return; }
            HttpSession waiting = req.getSession(true);
            waiting.setAttribute(PENDING_PROFILE, new PendingOAuthProfile(
                    provider, profile.id(), profile.email(), redirect, Instant.now(), OAuthService.newState()));
            resp.sendRedirect(req.getContextPath() + "/auth/oauth/complete-profile");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); fail(req, resp, "Login was interrupted. Please try again.");
        } catch (IOException e) {
            fail(req, resp, "Could not verify account with provider. Please try again with a verified email.");
        } catch (SQLException e) {
            if ("Account inactive".equals(e.getMessage())) fail(req, resp, "Your account has been locked or disabled.");
            else { getServletContext().log("OAuth account resolution failed", e); fail(req, resp, "Could not complete login. Please try again."); }
        }
    }

    private void showCompletion(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        PendingOAuthProfile pending = pendingProfile(req);
        if (pending == null) { fail(req, resp, "Login session is invalid or expired. Please try again."); return; }
        forwardCompletion(req, resp, pending);
    }

    private void completeProfile(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        PendingOAuthProfile pending = pendingProfile(req);
        if (pending == null) { fail(req, resp, "Login session is invalid or expired. Please try again."); return; }
        String supplied = req.getParameter("csrfToken");
        if (supplied == null || !MessageDigest.isEqual(
                pending.csrfToken().getBytes(StandardCharsets.UTF_8), supplied.getBytes(StandardCharsets.UTF_8))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String enteredFullName = req.getParameter("fullName");
        String fullName = FullNameUtil.normalizeOrNull(enteredFullName);
        if (fullName == null) {
            req.setAttribute("enteredFullName", enteredFullName);
            req.setAttribute("errorMessage", "Enter a full name using letters, spaces, apostrophes, hyphens, or periods (up to 255 characters).");
            forwardCompletion(req, resp, pending);
            return;
        }
        try {
            User user = oauth.resolveAccount(pending.provider(), new Profile(pending.id(), pending.email(), fullName));
            signIn(req, resp, user, pending.redirect());
        } catch (SQLException e) {
            if ("Account inactive".equals(e.getMessage())) {
                fail(req, resp, "Your account has been locked or disabled.");
            } else {
                getServletContext().log("OAuth profile completion failed", e);
                req.setAttribute("enteredFullName", enteredFullName);
                req.setAttribute("errorMessage", "Could not complete sign-up. Please try again.");
                forwardCompletion(req, resp, pending);
            }
        }
    }

    private PendingOAuthProfile pendingProfile(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        Object value = session == null ? null : session.getAttribute(PENDING_PROFILE);
        if (!(value instanceof PendingOAuthProfile pending)) return null;
        if (!Instant.now().isBefore(pending.createdAt().plus(PENDING_LIFETIME))) {
            session.removeAttribute(PENDING_PROFILE);
            return null;
        }
        return pending;
    }

    private void forwardCompletion(HttpServletRequest req, HttpServletResponse resp, PendingOAuthProfile pending)
            throws ServletException, IOException {
        resp.setHeader("Cache-Control", "no-store");
        req.setAttribute("csrfToken", pending.csrfToken());
        req.setAttribute("providerName", pending.provider() == Provider.GOOGLE ? "Google" : "GitHub");
        req.getRequestDispatcher("/WEB-INF/views/auth/complete-profile.jsp").forward(req, resp);
    }

    private void signIn(HttpServletRequest req, HttpServletResponse resp, User user, String redirect) throws IOException {
        HttpSession authenticated = req.getSession(true);
        authenticated.removeAttribute(PENDING_PROFILE);
        req.changeSessionId();
        authenticated.setAttribute("currentUser", user);
        authenticated.setAttribute("userName", user.getUsername());
        authenticated.setAttribute("userRole", user.getRoleCode());
        if (safeRedirect(redirect, req.getContextPath()) != null) resp.sendRedirect(redirect);
        else if ("ROLE_ADMIN".equalsIgnoreCase(user.getRoleCode())) resp.sendRedirect(req.getContextPath() + "/admin/users");
        else resp.sendRedirect(req.getContextPath() + "/home");
    }

    private void fail(HttpServletRequest req, HttpServletResponse resp, String message) throws IOException {
        HttpSession session = req.getSession(true);
        session.removeAttribute(PENDING_PROFILE);
        session.setAttribute("oauth.error", message);
        resp.sendRedirect(req.getContextPath() + "/auth/login");
    }

    private record PendingOAuthProfile(Provider provider, String id, String email, String redirect,
                                       Instant createdAt, String csrfToken) implements Serializable {
        private static final long serialVersionUID = 1L;
    }

    private static String safeRedirect(String value, String contextPath) {
        if (value == null || value.isBlank() || value.indexOf('\\') >= 0 || value.indexOf('\r') >= 0 || value.indexOf('\n') >= 0) return null;
        try {
            URI uri = URI.create(value);
            if (uri.isAbsolute() || uri.getRawAuthority() != null || uri.getRawPath() == null || !uri.getRawPath().startsWith("/") || uri.getRawPath().startsWith("//")) return null;
            if (!contextPath.isEmpty() && !uri.getRawPath().equals(contextPath) && !uri.getRawPath().startsWith(contextPath + "/")) return null;
            return value;
        } catch (IllegalArgumentException e) { return null; }
    }
}
