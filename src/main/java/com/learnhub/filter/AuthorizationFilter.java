package com.learnhub.filter;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filter handling authentication and RBAC authorization according to SDS 4.1 & Permission Matrix:
 * - isLoggedIn(req)
 * - hasExpertRole(req)
 * - hasStudentRole(req)
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/admin/*", "/expert/*", "/learn/*", "/quiz/*"})
public class AuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String uri = req.getRequestURI();

        if (!isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login?error=unauthorized");
            return;
        }

        if (uri.contains("/admin/") && !hasAdminRole(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Administrator privileges required.");
            return;
        }

        if (uri.contains("/expert/") && !hasExpertRole(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Subject Expert privileges required.");
            return;
        }

        chain.doFilter(request, response);
    }

    public boolean isLoggedIn(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute(AppConstants.SessionKey.CURRENT_USER) != null;
    }

    public boolean hasAdminRole(HttpServletRequest req) {
        User user = getCurrentUser(req);
        return user != null && (AppConstants.Role.ADMIN.equalsIgnoreCase(user.getRoleCode()) || "Administrator".equalsIgnoreCase(user.getRoleName()));
    }

    public boolean hasExpertRole(HttpServletRequest req) {
        User user = getCurrentUser(req);
        return user != null && (AppConstants.Role.EXPERT.equalsIgnoreCase(user.getRoleCode()) || hasAdminRole(req));
    }

    public boolean hasStudentRole(HttpServletRequest req) {
        User user = getCurrentUser(req);
        return user != null && AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode());
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER);
        }
        return null;
    }

    @Override
    public void destroy() {
    }
}
