package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dto.ManagerDashboardDTO;
import com.learnhub.entity.User;
import com.learnhub.service.DashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller dedicated exclusively to the Manager Dashboard (/manager/dashboard).
 * Provides overall course monitoring, curriculum review queues, expert allocation,
 * publishing controls, and real-time student registration logs.
 */
@WebServlet(name = "ManagerDashboardServlet", urlPatterns = {"/manager/dashboard"})
public class ManagerDashboardServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ManagerDashboardServlet.class.getName());
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER) : null;
        if (currentUser == null) {
            String redirectUri = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }
            resp.sendRedirect(req.getContextPath() + "/auth/login?redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8));
            return;
        }

        if (!isAuthorizedManager(req, currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager privileges required.");
            return;
        }

        // Filters: Period (Date Range), Search, Category
        String period = req.getParameter("period");
        if (period == null || period.isBlank()) {
            period = req.getParameter("dateRange");
        }
        if (period == null || period.isBlank()) {
            period = "month";
        }

        String search = req.getParameter("search");
        String categoryId = req.getParameter("categoryId");

        // Build data
        ManagerDashboardDTO dashboard = dashboardService.buildManagerDashboard(period, search, categoryId);

        req.setAttribute("dashboard", dashboard);
        req.setAttribute("pageTitle", "Manager Dashboard – LearnHub");

        // Flash feedback parameters
        if ("true".equals(req.getParameter("assign_success"))) {
            req.setAttribute("successMessage", "Domain expert has been assigned successfully!");
        } else if ("true".equals(req.getParameter("status_success"))) {
            req.setAttribute("successMessage", "Course publication status updated successfully!");
        } else if ("assign_failed".equals(req.getParameter("error"))) {
            req.setAttribute("errorMessage", "Failed to assign domain expert. Please verify the selected course.");
        } else if ("status_failed".equals(req.getParameter("error"))) {
            req.setAttribute("errorMessage", "Failed to update course status. Please try again.");
        }

        req.getRequestDispatcher("/WEB-INF/views/manager/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER) : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        if (!isAuthorizedManager(req, currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        String period = req.getParameter("period");
        String periodParam = (period != null && !period.isBlank()) ? "&period=" + period : "";

        if ("assign-expert".equalsIgnoreCase(action)) {
            handleAssignExpert(req, resp, currentUser, periodParam);
        } else if ("toggle-status".equalsIgnoreCase(action)) {
            handleToggleStatus(req, resp, currentUser, periodParam);
        } else {
            resp.sendRedirect(req.getContextPath() + "/manager/dashboard");
        }
    }

    private void handleAssignExpert(HttpServletRequest req, HttpServletResponse resp, User actor, String periodParam) throws IOException {
        String courseIdStr = req.getParameter("courseId");
        String expertIdStr = req.getParameter("expertId");

        if (courseIdStr != null && !courseIdStr.isBlank()) {
            try {
                UUID courseId = UUID.fromString(courseIdStr.trim());
                UUID expertId = (expertIdStr != null && !expertIdStr.isBlank()) ? UUID.fromString(expertIdStr.trim()) : null;

                boolean success = dashboardService.assignExpertToCourse(courseId, expertId, actor.getEmail());
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/manager/dashboard?assign_success=true" + periodParam);
                    return;
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error assigning expert: " + e.getMessage(), e);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/manager/dashboard?error=assign_failed" + periodParam);
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, User actor, String periodParam) throws IOException {
        String courseIdStr = req.getParameter("courseId");
        String status = req.getParameter("status");

        if (courseIdStr != null && !courseIdStr.isBlank() && status != null && !status.isBlank()) {
            try {
                UUID courseId = UUID.fromString(courseIdStr.trim());
                boolean success = dashboardService.toggleCourseStatus(courseId, status.trim().toLowerCase(), actor.getEmail());
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/manager/dashboard?status_success=true" + periodParam);
                    return;
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error toggling course status: " + e.getMessage(), e);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/manager/dashboard?error=status_failed" + periodParam);
    }

    private boolean isAuthorizedManager(HttpServletRequest req, User user) {
        if (user == null) return false;
        String role = (String) req.getSession().getAttribute("userRole");
        String rCode = user.getRoleCode() != null ? user.getRoleCode() : "";
        String rName = user.getRoleName() != null ? user.getRoleName() : "";

        return AppConstants.Role.MANAGER.equalsIgnoreCase(rCode)
                || "ROLE_MANAGER".equalsIgnoreCase(rCode)
                || "manager".equalsIgnoreCase(role)
                || "Manager".equalsIgnoreCase(rName);
    }
}
