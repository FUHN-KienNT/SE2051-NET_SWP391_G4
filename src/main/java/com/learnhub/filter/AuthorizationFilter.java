package com.learnhub.filter;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {
        "/admin/*", "/expert/*", "/lessons/*", "/questions/*",
        "/learn/*", "/quiz/*"
})
public class AuthorizationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String path = req.getServletPath();

        // All URLs mapped to this filter require login.
        if (!isLoggedIn(req)) {
            String redirectUri = req.getRequestURI();

            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }

            String encodedUri = URLEncoder.encode(
                    redirectUri, StandardCharsets.UTF_8
            );

            resp.sendRedirect(req.getContextPath()
                    + "/auth/login?error=unauthorized&redirect_uri="
                    + encodedUri);
            return;
        }

        // Only Admin can access administration URLs.
        if (isUnder(path, "/admin") && !hasAdminRole(req)) {
            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: Administrator privileges required."
            );
            return;
        }

        // Only Expert can manage lessons, questions and quizzes.
        boolean expertOnly = isUnder(path, "/expert")
                || isUnder(path, "/lessons")
                || isUnder(path, "/questions")
                || isUnder(path, "/quiz/manage")
                || isUnder(path, "/quiz/detail");

        if (expertOnly && !hasExpertRole(req)) {
            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: Subject Expert privileges required."
            );
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isUnder(String path, String prefix) {
        return path.equals(prefix) || path.startsWith(prefix + "/");
    }

    public boolean isLoggedIn(HttpServletRequest req) {
        return getCurrentUser(req) != null;
    }

    public boolean hasAdminRole(HttpServletRequest req) {
        User user = getCurrentUser(req);

        return user != null
                && AppConstants.Role.ADMIN.equalsIgnoreCase(
                user.getRoleCode()
        );
    }

    public boolean hasExpertRole(HttpServletRequest req) {
        User user = getCurrentUser(req);

        return user != null
                && AppConstants.Role.EXPERT.equalsIgnoreCase(
                user.getRoleCode()
        );
    }

    public boolean hasStudentRole(HttpServletRequest req) {
        User user = getCurrentUser(req);

        return user != null
                && AppConstants.Role.STUDENT.equalsIgnoreCase(
                user.getRoleCode()
        );
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);

        if (session == null) {
            return null;
        }

        Object currentUser = session.getAttribute(
                AppConstants.SessionKey.CURRENT_USER
        );

        return currentUser instanceof User ? (User) currentUser : null;
    }
}