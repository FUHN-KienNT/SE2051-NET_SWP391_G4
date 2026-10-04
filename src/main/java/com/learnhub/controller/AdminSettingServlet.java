package com.learnhub.controller;

import com.learnhub.dao.SettingDAO;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.service.DashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * System Settings Management Servlet for Administrators (SRS 2.2 / 2.2.1).
 *
 * Implements:
 * - View Setting List: paginated list of system master data / configurations.
 * - Filter Setting List: filter by type and status.
 * - Search Settings: search by name, code, description.
 * - Sort Setting List: sort by name, type, order, status.
 * - Activate/Deactivate Setting: change status of master data.
 * - Create/Update Setting: modal form for adding/editing master data.
 *
 * URLs: /admin/settings, /admin/setting-status
 */
@WebServlet(name = "AdminSettingServlet", urlPatterns = {"/admin/settings", "/admin/setting-status"})
public class AdminSettingServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminSettingServlet.class.getName());
    private final SettingDAO settingDAO = new SettingDAO();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            String redirectUri = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }
            resp.sendRedirect(req.getContextPath() + "/auth/login?redirect_uri=" + java.net.URLEncoder.encode(redirectUri, "UTF-8"));
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!isAuthorizedAdmin(currentUser, role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Administrator privileges required.");
            return;
        }

        String action = req.getParameter("action");
        if ("get-json".equalsIgnoreCase(action)) {
            handleGetJson(req, resp);
            return;
        }

        // Query params
        String search = req.getParameter("search");
        String type = req.getParameter("type");
        String status = req.getParameter("status");
        String sortBy = req.getParameter("sortBy");
        String sortOrder = req.getParameter("sortOrder");
        String pageStr = req.getParameter("page");

        if (sortBy == null || sortBy.isBlank()) {
            sortBy = "order";
        }
        if (sortOrder == null || sortOrder.isBlank()) {
            sortOrder = "asc";
        }

        int page = 1;
        int pageSize = 10;
        if (pageStr != null && !pageStr.isBlank()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr.trim()));
            } catch (NumberFormatException ignored) {
            }
        }

        int offset = (page - 1) * pageSize;
        List<Setting> settings = settingDAO.findSettings(search, type, status, sortBy, sortOrder, offset, pageSize);
        int totalSettings = settingDAO.countSettings(search, type, status);
        int totalPages = (int) Math.ceil((double) totalSettings / pageSize);

        List<String> types = settingDAO.findAllTypes();

        req.setAttribute("settings", settings);
        req.setAttribute("types", types);
        req.setAttribute("search", search);
        req.setAttribute("selectedType", type);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("sortBy", sortBy);
        req.setAttribute("sortOrder", sortOrder);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalSettings", totalSettings);
        req.setAttribute("pageTitle", "System Settings – LearnHub Admin");

        if ("true".equals(req.getParameter("status_success"))) {
            req.setAttribute("successMessage", "Trạng thái cấu hình đã được cập nhật thành công!");
        } else if ("true".equals(req.getParameter("save_success"))) {
            req.setAttribute("successMessage", "Thông tin cấu hình đã được lưu thành công!");
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/setting-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!isAuthorizedAdmin(currentUser, role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = req.getServletPath();
        String action = req.getParameter("action");

        if ("/admin/setting-status".equals(path) || "status".equalsIgnoreCase(action)) {
            handleChangeStatus(req, resp, currentUser);
        } else if ("save".equalsIgnoreCase(action)) {
            handleSaveSetting(req, resp, currentUser);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/settings");
        }
    }

    private void handleChangeStatus(HttpServletRequest req, HttpServletResponse resp, User actor) throws IOException {
        String idStr = req.getParameter("id");
        String statusStr = req.getParameter("status");

        if (idStr != null && statusStr != null) {
            try {
                UUID id = UUID.fromString(idStr.trim());
                boolean newStatus = Boolean.parseBoolean(statusStr.trim());
                Setting setting = settingDAO.findById(id);
                if (setting != null) {
                    boolean success = settingDAO.updateStatus(id, newStatus);
                    if (success) {
                        dashboardService.logEvent(
                                actor.getEmail(),
                                "SETTING_STATUS_CHANGE",
                                "Đổi trạng thái cấu hình '" + setting.getName() + "' sang: " + (newStatus ? "Active" : "Inactive"),
                                "SUCCESS"
                        );
                        resp.sendRedirect(req.getContextPath() + "/admin/settings?status_success=true");
                        return;
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error updating setting status: " + e.getMessage(), e);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/settings?error=status_failed");
    }

    private void handleSaveSetting(HttpServletRequest req, HttpServletResponse resp, User actor) throws IOException {
        String idStr = req.getParameter("id");
        String type = req.getParameter("type");
        String code = req.getParameter("code");
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String statusStr = req.getParameter("status");
        String sortOrderStr = req.getParameter("sortOrder");

        if (name == null || name.trim().isEmpty() || type == null || type.trim().isEmpty() || code == null || code.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/settings?error=missing_fields");
            return;
        }

        int sortOrder = 1;
        if (sortOrderStr != null && !sortOrderStr.trim().isEmpty()) {
            try {
                sortOrder = Integer.parseInt(sortOrderStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        boolean status = "true".equalsIgnoreCase(statusStr) || "active".equalsIgnoreCase(statusStr);

        Setting s = new Setting();
        s.setType(type.trim());
        s.setCode(code.trim());
        s.setName(name.trim());
        s.setDescription(description != null ? description.trim() : "");
        s.setStatus(status);
        s.setSortOrder(sortOrder);

        boolean isUpdate = idStr != null && !idStr.trim().isEmpty();
        boolean result;

        if (isUpdate) {
            try {
                UUID id = UUID.fromString(idStr.trim());
                s.setId(id);
                result = settingDAO.update(s);
                if (result) {
                    dashboardService.logEvent(actor.getEmail(), "SETTING_UPDATE", "Cập nhật cấu hình: " + s.getName(), "SUCCESS");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error updating setting: " + e.getMessage(), e);
                result = false;
            }
        } else {
            s.setId(UUID.randomUUID());
            result = settingDAO.insert(s);
            if (result) {
                dashboardService.logEvent(actor.getEmail(), "SETTING_CREATE", "Thêm cấu hình mới: " + s.getName(), "SUCCESS");
            }
        }

        if (result) {
            resp.sendRedirect(req.getContextPath() + "/admin/settings?save_success=true");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/settings?error=save_failed");
        }
    }

    private void handleGetJson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        resp.setContentType("application/json;charset=UTF-8");
        if (idStr != null && !idStr.isBlank()) {
            try {
                UUID id = UUID.fromString(idStr.trim());
                Setting s = settingDAO.findById(id);
                if (s != null) {
                    String json = String.format(
                            "{\"id\":\"%s\",\"type\":\"%s\",\"code\":\"%s\",\"name\":\"%s\",\"description\":\"%s\",\"status\":%b,\"sortOrder\":%d}",
                            s.getId(),
                            escapeJson(s.getType()),
                            escapeJson(s.getCode()),
                            escapeJson(s.getName()),
                            escapeJson(s.getDescription() != null ? s.getDescription() : ""),
                            s.isStatus(),
                            s.getSortOrder()
                    );
                    resp.getWriter().write(json);
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.getWriter().write("{\"error\":\"not_found\"}");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private boolean isAuthorizedAdmin(User user, String role) {
        if (user == null) return false;
        String rCode = user.getRoleCode() != null ? user.getRoleCode() : "";
        String rName = user.getRoleName() != null ? user.getRoleName() : "";
        String sRole = role != null ? role : "";

        return "ROLE_ADMIN".equalsIgnoreCase(rCode)
                || "ROLE_MANAGER".equalsIgnoreCase(rCode)
                || "admin".equalsIgnoreCase(sRole)
                || "manager".equalsIgnoreCase(sRole)
                || "ROLE_ADMIN".equalsIgnoreCase(sRole)
                || "ROLE_MANAGER".equalsIgnoreCase(sRole)
                || "Administrator".equalsIgnoreCase(rName)
                || "Manager".equalsIgnoreCase(rName)
                || "Admin".equalsIgnoreCase(rName);
    }
}
