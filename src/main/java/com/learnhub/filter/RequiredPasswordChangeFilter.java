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

/** Keeps new Google accounts on password setup until the database flag is cleared. */
@WebFilter(filterName = "RequiredPasswordChangeFilter", urlPatterns = "/*")
public class RequiredPasswordChangeFilter implements Filter {
    private final UserDAO userDAO;

    public RequiredPasswordChangeFilter() {
        this(new UserDAO());
    }

    RequiredPasswordChangeFilter(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        Object current = session == null ? null : session.getAttribute(AppConstants.SessionKey.CURRENT_USER);
        if (!(current instanceof User user) || !user.isRequiresPasswordChange()) {
            chain.doFilter(request, response);
            return;
        }

        String path = req.getServletPath();
        if ("/account/set-password".equals(path) || "/auth/logout".equals(path)
                || path.startsWith("/assets/") || "/favicon.ico".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        User fresh = userDAO.findById(user.getId());
        if (fresh == null || !AppConstants.UserStatus.ACTIVE.equalsIgnoreCase(fresh.getStatus())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!fresh.isRequiresPasswordChange()) {
            session.setAttribute(AppConstants.SessionKey.CURRENT_USER, fresh);
            chain.doFilter(request, response);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/account/set-password");
    }
}
