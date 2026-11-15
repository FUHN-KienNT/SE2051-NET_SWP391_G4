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

import java.io.IOException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller dedicated exclusively to the Manager Dashboard (/manager/dashboard).
 * Provides overall course monitoring, curriculum review queues, expert allocation,
 * publishing controls, and real-time student registration logs.
 *
 * @author NguyenLD - System Administration Module
 */
@WebServlet(name = "ManagerDashboardServlet", urlPatterns = {"/manager/dashboard"})
public class ManagerDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = Logger.getLogger(ManagerDashboardServlet.class.getName());
    private final DashboardService dashboardService = new DashboardService();

    /**
     * Handles an HTTP GET request.
     *
     * @param req the incoming request
     * @param resp the outgoing response
     * @throws ServletException if the operation cannot complete
     * @throws IOException if the operation cannot complete
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Bước 1: Kiểm tra phiên đăng nhập người dùng
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), null);
            return;
        }

        // Bước 2: Kiểm tra quyền Manager
        if (!isAuthorizedManager(req, currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager privileges required.");
            return;
        }

        // Bước 3: Đọc các tham số bộ lọc (Khoảng thời gian, Từ khóa, Danh mục)
        String period = req.getParameter("period");
        if (period == null || period.isBlank()) {
            period = req.getParameter("dateRange");
        }
        if (period == null || period.isBlank()) {
            period = "month";
        }

        String search = req.getParameter("search");
        String categoryId = req.getParameter("categoryId");

        // Bước 4: Xây dựng dữ liệu thống kê cho Quản lý từ Service
        ManagerDashboardDTO dashboard = dashboardService.buildManagerDashboard(period, search, categoryId);

        req.setAttribute("dashboard", dashboard);
        req.setAttribute("pageTitle", "Manager Dashboard – LearnHub");

        // Bước 5: Đọc các thông báo Flash Message phản hồi thao tác
        if ("true".equals(req.getParameter("assign_success"))) {
            req.setAttribute("successMessage", "Domain expert has been assigned successfully!");
        } else if ("true".equals(req.getParameter("status_success"))) {
            req.setAttribute("successMessage", "Course publication status updated successfully!");
        } else if ("assign_failed".equals(req.getParameter("error"))) {
            req.setAttribute("errorMessage", "Failed to assign domain expert. Please verify the selected course.");
        } else if ("status_failed".equals(req.getParameter("error"))) {
            req.setAttribute("errorMessage", "Failed to update course status. Please try again.");
        }

        // Bước 6: Chuyển tiếp sang giao diện manager/dashboard.jsp
        req.getRequestDispatcher("/WEB-INF/views/manager/dashboard.jsp").forward(req, resp);
    }

    /**
     * Handles an HTTP POST request.
     *
     * @param req the incoming request
     * @param resp the outgoing response
     * @throws ServletException if the operation cannot complete
     * @throws IOException if the operation cannot complete
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Bước 1: Kiểm tra phiên đăng nhập và quyền Manager
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        if (!isAuthorizedManager(req, currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Bước 2: Phân luồng xử lý theo hành động (Action Dispatching)
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

    private void handleAssignExpert(HttpServletRequest req, HttpServletResponse resp,
                                    User actor, String periodParam) throws IOException {
        String courseIdStr = req.getParameter("courseId");
        String expertIdStr = req.getParameter("expertId");

        if (courseIdStr != null && !courseIdStr.isBlank()) {
            try {
                UUID courseId = UUID.fromString(courseIdStr.trim());
                UUID expertId = (expertIdStr != null && !expertIdStr.isBlank())
                        ? UUID.fromString(expertIdStr.trim()) : null;

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

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp,
                                    User actor, String periodParam) throws IOException {
        String courseIdStr = req.getParameter("courseId");
        String status = req.getParameter("status");

        if (courseIdStr != null && !courseIdStr.isBlank() && status != null && !status.isBlank()) {
            try {
                UUID courseId = UUID.fromString(courseIdStr.trim());
                boolean success = dashboardService.toggleCourseStatus(
                        courseId, status.trim().toLowerCase(), actor.getEmail());
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

    /**
     * Checks whether authorized manager.
     *
     * @param req the incoming request
     * @param user the user
     * @return true when the condition holds; false otherwise
     */
    private boolean isAuthorizedManager(HttpServletRequest req, User user) {
        if (user == null) {
            return false;
        }
        String role = (String) req.getSession().getAttribute("userRole");
        String rCode = user.getRoleCode() != null ? user.getRoleCode() : "";
        String rName = user.getRoleName() != null ? user.getRoleName() : "";

        return AppConstants.Role.MANAGER.equalsIgnoreCase(rCode)
                || "ROLE_MANAGER".equalsIgnoreCase(rCode)
                || "manager".equalsIgnoreCase(role)
                || "Manager".equalsIgnoreCase(rName);
    }
}
