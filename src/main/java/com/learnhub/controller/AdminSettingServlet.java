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
 * URLs: /admin/settings, /admin/setting-detail, /admin/setting-status
 */
@WebServlet(name = "AdminSettingServlet", urlPatterns = {"/admin/settings", "/admin/setting-detail", "/admin/setting-status"})
public class AdminSettingServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminSettingServlet.class.getName());
    private final SettingDAO settingDAO = new SettingDAO();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), null);
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!isAuthorizedAdmin(currentUser, role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Administrator privileges required.");
            return;
        }

        String path = req.getServletPath();
        if ("/admin/setting-detail".equals(path)) {
            handleShowDetail(req, resp);
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

        if (sortBy == null || sortBy.isBlank()) {
            sortBy = "order";
        }
        if (sortOrder == null || sortOrder.isBlank()) {
            sortOrder = "asc";
        }

        int page = ControllerSupport.pageNumber(req.getParameter("page"));
        int pageSize = 10;

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
        } else if ("core_role_protected".equals(req.getParameter("error")) || "role_deactivate_blocked".equals(req.getParameter("error"))) {
            req.setAttribute("errorMessage", "Không thể vô hiệu hóa vai trò (Role luôn ở trạng thái Active)!");
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/setting-list.jsp").forward(req, resp);
    }

    private boolean isRoleSetting(Setting setting) {
        if (setting == null) return false;
        return "role".equalsIgnoreCase(setting.getType());
    }

    private void handleShowDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        Setting setting = null;
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                UUID id = UUID.fromString(idStr.trim());
                setting = settingDAO.findById(id);
            } catch (IllegalArgumentException ignored) {
            }
            if (setting == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/settings");
                return;
            }
        }

        req.setAttribute("setting", setting);
        req.setAttribute("types", getSettingTypes(setting));
        req.setAttribute("isProtected", isRoleSetting(setting));
        req.setAttribute("pageTitle", setting != null
                ? "Setting Detail - " + setting.getCode() + " – LearnHub Admin"
                : "Add New Setting – LearnHub Admin");
        req.getRequestDispatcher("/WEB-INF/views/admin/setting-detail.jsp").forward(req, resp);
    }

    private List<String> getSettingTypes(Setting setting) {
        List<String> types = new java.util.ArrayList<>(settingDAO.findAllTypes());
        if (setting != null && setting.getType() != null && !setting.getType().trim().isEmpty()) {
            String currentType = setting.getType().trim();
            boolean exists = false;
            for (String t : types) {
                if (t != null && t.equalsIgnoreCase(currentType)) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                types.add(currentType);
            }
        }
        return types;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = ControllerSupport.currentUser(req);
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
        } else if ("/admin/setting-detail".equals(path) || "save".equalsIgnoreCase(action)) {
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
                    if (isRoleSetting(setting) && !newStatus) {
                        resp.sendRedirect(req.getContextPath() + "/admin/settings?error=core_role_protected");
                        return;
                    }
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

    private void handleSaveSetting(HttpServletRequest req, HttpServletResponse resp, User actor) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        String type = req.getParameter("type");
        String code = req.getParameter("code");
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String statusStr = req.getParameter("status");
        String sortOrderStr = req.getParameter("sortOrder");

        int sortOrder = 1;
        if (sortOrderStr != null && !sortOrderStr.trim().isEmpty()) {
            try {
                sortOrder = Integer.parseInt(sortOrderStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        boolean status = statusStr == null || "true".equalsIgnoreCase(statusStr) || "active".equalsIgnoreCase(statusStr);
        boolean isUpdate = idStr != null && !idStr.trim().isEmpty();
        UUID currentId = null;
        Setting existing = null;

        if (isUpdate) {
            try {
                currentId = UUID.fromString(idStr.trim());
                existing = settingDAO.findById(currentId);
            } catch (IllegalArgumentException ignored) {
            }
        }

        boolean isRole = "role".equalsIgnoreCase(type) || (existing != null && isRoleSetting(existing));
        if (isRole) {
            status = true; // Roles are strictly active
        }

        boolean protectedSetting = isRole;

        String resolvedCode = (code != null && !code.trim().isEmpty())
                ? code.trim()
                : (existing != null ? existing.getCode() : generateSettingCode(name));

        Setting s = new Setting();
        s.setId(currentId);
        s.setType(type != null ? type.trim() : "");
        s.setCode(resolvedCode);
        s.setName(name != null ? name.trim() : "");
        s.setDescription(description != null ? description.trim() : "");
        s.setStatus(status);
        s.setSortOrder(sortOrder);

        if (s.getName().isEmpty() || s.getType().isEmpty()) {
            req.setAttribute("errorMessage", "Setting Name and Setting Type are required and cannot be empty.");
            req.setAttribute("setting", s);
            req.setAttribute("types", getSettingTypes(s));
            req.setAttribute("isProtected", protectedSetting);
            req.getRequestDispatcher("/WEB-INF/views/admin/setting-detail.jsp").forward(req, resp);
            return;
        }

        if (settingDAO.existsByName(s.getName(), currentId)) {
            req.setAttribute("errorMessage", "Setting Name '" + s.getName() + "' already exists. Setting Name must be unique.");
            req.setAttribute("setting", s);
            req.setAttribute("types", getSettingTypes(s));
            req.setAttribute("isProtected", protectedSetting);
            req.getRequestDispatcher("/WEB-INF/views/admin/setting-detail.jsp").forward(req, resp);
            return;
        }

        boolean result;
        if (isUpdate && currentId != null) {
            try {
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
            req.setAttribute("errorMessage", "Could not save setting into the database. Please try again.");
            req.setAttribute("setting", s);
            req.setAttribute("types", getSettingTypes(s));
            req.setAttribute("isProtected", protectedSetting);
            req.getRequestDispatcher("/WEB-INF/views/admin/setting-detail.jsp").forward(req, resp);
        }
    }

    private String generateSettingCode(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "STG_" + System.currentTimeMillis() % 10000;
        }
        String normalized = java.text.Normalizer.normalize(name.trim(), java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .replaceAll("[đĐ]", "d")
                .toUpperCase()
                .replaceAll("[^A-Z0-9]+", "_")
                .replaceAll("^_+|_+$", "");
        if (normalized.isEmpty()) {
            normalized = "STG";
        }
        if (normalized.length() > 40) {
            normalized = normalized.substring(0, 40);
        }
        if (settingDAO.findByCode(normalized) != null) {
            normalized = normalized + "_" + (System.currentTimeMillis() % 1000);
        }
        return normalized;
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
                || "admin".equalsIgnoreCase(sRole)
                || "ROLE_ADMIN".equalsIgnoreCase(sRole)
                || "Administrator".equalsIgnoreCase(rName)
                || "Admin".equalsIgnoreCase(rName);
    }
}
