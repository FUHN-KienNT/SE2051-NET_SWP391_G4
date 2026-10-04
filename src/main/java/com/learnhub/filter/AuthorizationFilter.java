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

/**
 * Filter handling authentication and RBAC authorization according to SDS 4.1 & Permission Matrix:
 * - isLoggedIn(req)
 * - hasExpertRole(req)
 * - hasStudentRole(req)
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {
        "/admin/*", "/expert/*", "/lessons/*", "/questions/*",
        "/learn/*", "/quiz/*", "/learning-process/*"
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

        // Administration URLs
        if (isUnder(path, "/admin")) {
            boolean isCourseManagement = isUnder(path, "/admin/courses")
                    || isUnder(path, "/admin/course-status")
                    || isUnder(path, "/admin/course-detail");
            if (isCourseManagement) {
                if (!hasAdminRole(req) && !hasExpertRole(req)) {
                    resp.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Access denied: Administrator or Expert privileges required."
                    );
                    return;
                }
            } else if (!hasAdminRole(req)) {
                resp.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Access denied: Administrator privileges required."
                );
                return;
            }
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
        HttpSession session = req.getSession(false);
        if (session != null) {
            String role = (String) session.getAttribute("userRole");
            if (role != null && ("ROLE_ADMIN".equalsIgnoreCase(role) || "ROLE_MANAGER".equalsIgnoreCase(role)
                    || "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role))) {
                return true;
            }
        }
        User user = getCurrentUser(req);
        if (user == null) return false;
        String code = user.getRoleCode();
        String name = user.getRoleName();
        return AppConstants.Role.ADMIN.equalsIgnoreCase(code)
                || AppConstants.Role.MANAGER.equalsIgnoreCase(code)
                || "admin".equalsIgnoreCase(code)
                || "manager".equalsIgnoreCase(code)
                || "Administrator".equalsIgnoreCase(name)
                || "Manager".equalsIgnoreCase(name)
                || "Admin".equalsIgnoreCase(name);
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