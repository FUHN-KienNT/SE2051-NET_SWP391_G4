package com.learnhub.controller;

import com.learnhub.dto.DashboardDTO;
import com.learnhub.entity.User;
import com.learnhub.service.DashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet for the Admin Dashboard screen (SDS 2.3).
 *
 * Implements:
 * - viewKeyMetricsSummary()     — loads aggregated system statistics
 * - filterMetricsByDateRange()  — accepts ?dateRange=today|week|month
 * - viewRecentSystemLogs()      — passes recent audit_log entries to view
 *
 * URL: /admin/dashboard
 * Roles allowed: admin, manager
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Role guard ─────────────────────────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?redirect_uri=/admin/dashboard");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String userRole = (String) session.getAttribute("userRole");
        String roleCode = currentUser != null ? currentUser.getRoleCode() : userRole;
        String roleName = currentUser != null ? currentUser.getRoleName() : "";

        boolean isAuthorized = "ROLE_ADMIN".equalsIgnoreCase(userRole)
                || "ROLE_MANAGER".equalsIgnoreCase(userRole)
                || "admin".equalsIgnoreCase(userRole)
                || "manager".equalsIgnoreCase(userRole)
                || "ROLE_ADMIN".equalsIgnoreCase(roleCode)
                || "ROLE_MANAGER".equalsIgnoreCase(roleCode)
                || "admin".equalsIgnoreCase(roleCode)
                || "manager".equalsIgnoreCase(roleCode)
                || "Administrator".equalsIgnoreCase(roleName)
                || "Manager".equalsIgnoreCase(roleName)
                || "Admin".equalsIgnoreCase(roleName);

        if (!isAuthorized) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // ── Date range filter ─────────────────────────────────────────────────
        String dateRange = req.getParameter("dateRange");
        if (dateRange == null || dateRange.isBlank()) {
            dateRange = "month";
        }

        // ── Build dashboard data ──────────────────────────────────────────────
        DashboardDTO dashboard = dashboardService.buildDashboard(dateRange);

        // ── Forward to JSP ────────────────────────────────────────────────────
        req.setAttribute("dashboard", dashboard);
        req.setAttribute("pageTitle", "Admin Dashboard – LearnHub");
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
