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
        if (url == null) { fail(req, resp, "Đăng nhập bằng nhà cung cấp này chưa được cấu hình."); return; }
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
            fail(req, resp, "Phiên đăng nhập không hợp lệ hoặc đã hết hạn. Vui lòng thử lại."); return;
        }
        if (req.getParameter("error") != null) { fail(req, resp, "Bạn đã hủy hoặc không hoàn tất đăng nhập."); return; }
        String code = req.getParameter("code");
        if (code == null || code.isBlank()) { fail(req, resp, "Nhà cung cấp không trả về mã xác thực hợp lệ."); return; }
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
            Thread.currentThread().interrupt(); fail(req, resp, "Đăng nhập bị gián đoạn. Vui lòng thử lại.");
        } catch (IOException e) {
            fail(req, resp, "Không thể xác minh tài khoản với nhà cung cấp. Hãy dùng email đã xác minh rồi thử lại.");
        } catch (SQLException e) {
            if ("Account inactive".equals(e.getMessage())) fail(req, resp, "Tài khoản đã bị khóa hoặc vô hiệu hóa.");
            else { getServletContext().log("OAuth account resolution failed", e); fail(req, resp, "Không thể hoàn tất đăng nhập. Vui lòng thử lại."); }
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
