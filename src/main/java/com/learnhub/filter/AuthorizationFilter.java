package com.learnhub.filter;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.UserDAO;
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
 * - Mid-session status check for account suspension
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {
        "/admin/*", "/manager/*", "/expert/*",
        "/learn/*", "/quiz/*", "/learning-process/*",
        "/profile", "/account", "/account/*"
})
public class AuthorizationFilter implements Filter {

    private final UserDAO userDAO;

    /**
     * Creates an authorization filter with the default user DAO.
     */
    public AuthorizationFilter() {
        this(new UserDAO());
    }

    /**
     * Creates an authorization filter with the default user DAO.
     * @param userDAO the data access object used to refresh user status
     */
    public AuthorizationFilter(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Checks session authentication and role access before passing a request along.
     * @param request the HTTP request
     * @param response the HTTP response
     * @param chain the remaining filter chain
     * @throws IOException if sending or reading data fails
     * @throws ServletException if forwarding the request fails
     */
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

        // Rule 5: Mid-session suspension check. Invalidate session if user becomes non-active.
        User currentUser = getCurrentUser(req);
        if (currentUser != null && currentUser.getId() != null) {
            User freshUser = userDAO.findById(currentUser.getId());
            if (freshUser == null || !"active".equalsIgnoreCase(freshUser.getStatus())) {
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                String reason = (freshUser != null && freshUser.getStatusNote() != null && !freshUser.getStatusNote().isBlank())
                        ? freshUser.getStatusNote().trim() : "";
                String encodedReason = URLEncoder.encode(reason, StandardCharsets.UTF_8);
                resp.sendRedirect(req.getContextPath() + "/auth/login?suspended=1"
                        + (!encodedReason.isEmpty() ? "&reason=" + encodedReason : ""));
                return;
            }
        }

        // Retired registration URL must stay inaccessible even when an old link is used.
        if (isUnder(path, "/admin/registrations")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Registration management requires Manager privileges.");
            return;
        }

        boolean isCourseManagement = isUnder(path, "/manager/courses")
                || isUnder(path, "/manager/course-status")
                || isUnder(path, "/manager/course-detail");
        if (isCourseManagement && !hasManagerRole(req) && !hasExpertRole(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: Manager or Expert privileges required for course management.");
            return;
        }

        if (isUnder(path, "/manager") && !isCourseManagement && !hasManagerRole(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager privileges required.");
            return;
        }

        // Administration URLs
        if (isUnder(path, "/admin")) {
            boolean isUserManagement = isUnder(path, "/admin/users")
                    || isUnder(path, "/admin/user-list");
            boolean isSettingsManagement = isUnder(path, "/admin/settings")
                    || isUnder(path, "/admin/setting-detail")
                    || isUnder(path, "/admin/setting-status")
                    || isUnder(path, "/admin/setting-reorder");
                    
            if (isUserManagement || isSettingsManagement) {
                // User and system settings management: Allowed ONLY for Admin
                if (!hasOnlyAdminRole(req)) {
                    resp.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Access denied: Administrator privileges required."
                    );
                    return;
                }
            } else {
                // Other admin routes: Admin or Manager
                if (!hasAdminRole(req)) {
                    resp.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Access denied: Administrator or Manager privileges required."
                    );
                    return;
                }
            }
        }

        // Only Expert can manage lessons, questions and quizzes.
        boolean expertOnly = isUnder(path, "/expert");

        if (expertOnly && !hasExpertRole(req)) {
            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: Subject Expert privileges required."
                    );
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * Checks whether a request path is inside a protected prefix.
     * @param path the request path
     * @param prefix the path prefix
     * @return true when the path is within the prefix
     */
    private boolean isUnder(String path, String prefix) {
        return path.equals(prefix) || path.startsWith(prefix + "/");
    }

    /**
     * Checks whether the request has an authenticated user.
     * @param req the HTTP request
     * @return true when the request has a signed in user
     */
    public boolean isLoggedIn(HttpServletRequest req) {
        return getCurrentUser(req) != null;
    }

    /**
     * Checks whether the current user has the administrator role.
     * @param req the HTTP request
     * @return true when the user has the administrator role
     */
    public boolean hasAdminRole(HttpServletRequest req) {
        return hasOnlyAdminRole(req) || hasManagerRole(req);
    }

    /**
     * Checks whether the current user has only the administrator role.
     * @param req the HTTP request
     * @return true when the user has only the administrator role
     */
    public boolean hasOnlyAdminRole(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String role = (String) session.getAttribute("userRole");
            if (role != null && ("ROLE_ADMIN".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(role))) {
                return true;
            }
        }
        User user = getCurrentUser(req);
        if (user == null) return false;
        String code = user.getRoleCode();
        String name = user.getRoleName();
        return AppConstants.Role.ADMIN.equalsIgnoreCase(code)
                || "admin".equalsIgnoreCase(code)
                || "Administrator".equalsIgnoreCase(name)
                || "Admin".equalsIgnoreCase(name);
    }

    /**
     * Checks whether the current user has the manager role.
     * @param req the HTTP request
     * @return true when the user has the manager role
     */
    public boolean hasManagerRole(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String role = (String) session.getAttribute("userRole");
            if (role != null && ("ROLE_MANAGER".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role))) {
                return true;
            }
        }
        User user = getCurrentUser(req);
        if (user == null) return false;
        String code = user.getRoleCode();
        String name = user.getRoleName();
        return AppConstants.Role.MANAGER.equalsIgnoreCase(code)
                || "manager".equalsIgnoreCase(code)
                || "Manager".equalsIgnoreCase(name);
    }

    /**
     * Checks whether the current user has the expert role.
     * @param req the HTTP request
     * @return true when the user has the expert role
     */
    public boolean hasExpertRole(HttpServletRequest req) {
        User user = getCurrentUser(req);

        return user != null
                && AppConstants.Role.EXPERT.equalsIgnoreCase(
                user.getRoleCode()
        );
    }

    /**
     * Checks whether the current user has the student role.
     * @param req the HTTP request
     * @return true when the user has the student role
     */
    public boolean hasStudentRole(HttpServletRequest req) {
        User user = getCurrentUser(req);

        return user != null
                && AppConstants.Role.STUDENT.equalsIgnoreCase(
                user.getRoleCode()
        );
    }

    /**
     * Returns the authenticated user from the session.
     * @param req the HTTP request
     * @return the signed in user, or null
     */
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
