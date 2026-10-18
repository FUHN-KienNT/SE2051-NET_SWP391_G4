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
 * URLs: /admin/dashboard (Admin), /manager/dashboard (Manager)
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard", "/manager/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Role guard ─────────────────────────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?redirect_uri=" + req.getContextPath() + req.getServletPath());
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String roleCode = currentUser.getRoleCode();
        boolean manager = "ROLE_MANAGER".equalsIgnoreCase(roleCode);
        boolean managerPage = "/manager/dashboard".equals(req.getServletPath());
        if (!managerPage && manager) {
            resp.sendRedirect(req.getContextPath() + "/manager/dashboard");
            return;
        }
        if (managerPage ? !manager : !"ROLE_ADMIN".equalsIgnoreCase(roleCode)) {
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
        req.setAttribute("pageTitle", managerPage
                ? "Manager dashboard – LearnHub" : "Admin dashboard – LearnHub");
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
