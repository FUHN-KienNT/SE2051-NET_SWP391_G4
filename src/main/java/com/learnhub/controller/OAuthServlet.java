package com.learnhub.controller;

import com.learnhub.service.OAuthService;
import com.learnhub.service.OAuthService.Provider;
import com.learnhub.service.OAuthService.Profile;
import com.learnhub.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URI;
import java.sql.SQLException;
import java.security.MessageDigest;

@WebServlet(urlPatterns = {"/auth/oauth/google", "/auth/oauth/google/callback", "/auth/oauth/github", "/auth/oauth/github/callback"})
public class OAuthServlet extends HttpServlet {
    private final OAuthService oauth = new OAuthService();

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        Provider provider = path.contains("google") ? Provider.GOOGLE : Provider.GITHUB;
        if (path.endsWith("/callback")) { callback(req, resp, provider); return; }
        start(req, resp, provider);
    }

    private void start(HttpServletRequest req, HttpServletResponse resp, Provider provider) throws IOException {
        String redirect = safeRedirect(req.getParameter("redirect_uri"), req.getContextPath());
        if (redirect == null) redirect = "";
        String state = OAuthService.newState();
        HttpSession session = req.getSession(true);
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
        if (expected == null || actual == null || !MessageDigest.isEqual(expected.getBytes(java.nio.charset.StandardCharsets.UTF_8), actual.getBytes(java.nio.charset.StandardCharsets.UTF_8))) {
            fail(req, resp, "Login session is invalid or expired. Please try again."); return;
        }
        if (req.getParameter("error") != null) { fail(req, resp, "You cancelled or did not complete the login."); return; }
        String code = req.getParameter("code");
        if (code == null || code.isBlank()) { fail(req, resp, "Provider did not return a valid authentication code."); return; }
        try {
            Profile profile = oauth.fetchProfile(provider, code);
            User user = oauth.resolveAccount(provider, profile);
            HttpSession authenticated = req.getSession(true);
            req.changeSessionId();
            authenticated.setAttribute("currentUser", user);
            authenticated.setAttribute("userName", user.getUsername());
            authenticated.setAttribute("userRole", user.getRoleCode());
            if (safeRedirect(redirect, req.getContextPath()) != null) resp.sendRedirect(redirect);
            else if ("ROLE_ADMIN".equalsIgnoreCase(user.getRoleCode())) resp.sendRedirect(req.getContextPath() + "/admin/users");
            else resp.sendRedirect(req.getContextPath() + "/home");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); fail(req, resp, "Login was interrupted. Please try again.");
        } catch (IOException e) {
            fail(req, resp, "Could not verify account with provider. Please try again with a verified email.");
        } catch (SQLException e) {
            if ("Account inactive".equals(e.getMessage())) fail(req, resp, "Your account has been locked or disabled.");
            else { getServletContext().log("OAuth account resolution failed", e); fail(req, resp, "Could not complete login. Please try again."); }
        }
    }

    private void fail(HttpServletRequest req, HttpServletResponse resp, String message) throws IOException {
        req.getSession(true).setAttribute("oauth.error", message);
        resp.sendRedirect(req.getContextPath() + "/auth/login");
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
