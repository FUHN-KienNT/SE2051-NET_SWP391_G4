package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
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
 * Controller for the Admin Dashboard screen (SDS 2.3).
 *
 * <p>Implements:
 * <ul>
 *   <li>viewKeyMetricsSummary() — loads aggregated system statistics</li>
 *   <li>filterMetricsByDateRange() — accepts ?dateRange=today|week|month</li>
 *   <li>viewRecentSystemLogs() — passes recent audit_log entries to view</li>
 * </ul>
 * </p>
 *
 * <p>Endpoint: /admin/dashboard</p>
 *
 * @author NguyenLD - System Administration Module
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Bước 1: Kiểm tra phiên đăng nhập và phân quyền truy cập (Role Guard)
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            String targetUri = req.getContextPath() + req.getServletPath();
            resp.sendRedirect(req.getContextPath() + "/auth/login?redirect_uri=" + targetUri);
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String roleCode = currentUser != null ? currentUser.getRoleCode() : null;
        String userRole = (String) session.getAttribute("userRole");
        String roleName = currentUser != null ? currentUser.getRoleName() : "";

        // Nếu là Manager thì tự động điều hướng sang Manager Dashboard
        boolean isManager = AppConstants.Role.MANAGER.equalsIgnoreCase(roleCode)
                || "ROLE_MANAGER".equalsIgnoreCase(userRole)
                || "manager".equalsIgnoreCase(userRole)
                || "manager".equalsIgnoreCase(roleCode)
                || "Manager".equalsIgnoreCase(roleName);

        if (isManager) {
            resp.sendRedirect(req.getContextPath() + "/manager/dashboard");
            return;
        }

        // Kiểm tra quyền Administrator
        boolean isAuthorized = AppConstants.Role.ADMIN.equalsIgnoreCase(roleCode)
                || "ROLE_ADMIN".equalsIgnoreCase(userRole)
                || "admin".equalsIgnoreCase(userRole)
                || "admin".equalsIgnoreCase(roleCode)
                || "Administrator".equalsIgnoreCase(roleName)
                || "Admin".equalsIgnoreCase(roleName);

        if (!isAuthorized) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Bước 2: Đọc tham số lọc thời gian (mặc định là 'month')
        String dateRange = req.getParameter("dateRange");
        if (dateRange == null || dateRange.isBlank()) {
            dateRange = "month";
        }

        // Bước 3: Tổng hợp các chỉ số KPI và biểu đồ từ DashboardService
        DashboardDTO dashboard = dashboardService.buildDashboard(dateRange);

        // Bước 4: Chuyển tiếp dữ liệu sang giao diện admin/dashboard.jsp
        req.setAttribute("dashboard", dashboard);
        req.setAttribute("pageTitle", "Admin dashboard – LearnHub");
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
