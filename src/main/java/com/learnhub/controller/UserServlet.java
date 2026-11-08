package com.learnhub.controller;

import com.learnhub.dto.UserDTO;
import com.learnhub.entity.Setting;
import com.learnhub.service.UserService;
import com.learnhub.util.PaginationHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * User Management Servlet for Administrators.
 * Implements methods specified in SDS User Management Diagram (6.1, 6.2, 6.3):
 * - viewUserList()
 * - filterUsers()
 * - viewUserDetail()
 * - updateUserProfile()
 * - changeUserStatus()
 * - resetPassword()
 * - createUser()
 */
@WebServlet(name = "UserServlet", urlPatterns = {"/admin/users", "/admin/user-detail", "/admin/user-status", "/admin/reset-password"})
public class UserServlet extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/users".equals(path) && "new".equalsIgnoreCase(req.getParameter("action"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/user-detail?action=new");
            return;
        }

        if ("/admin/user-detail".equals(path)) {
            String action = req.getParameter("action");
            if ("new".equalsIgnoreCase(action)) {
                List<Setting> roles = userService.getAllRoles();
                req.setAttribute("isNew", true);
                req.setAttribute("roles", roles);
                req.getRequestDispatcher("/WEB-INF/views/admin/user-detail.jsp").forward(req, resp);
                return;
            }

            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    UUID userId = UUID.fromString(idStr.trim());
                    UserDTO user = userService.getUserById(userId);
                    if (user != null) {
                        List<Setting> roles = userService.getAllRoles();
                        String userCode = "USR-" + user.getId().toString().substring(0, 8).toUpperCase();
                        String initials = computeInitials(user.getFullName() != null && !user.getFullName().isBlank()
                                ? user.getFullName() : user.getUsername());

                        req.setAttribute("user", user);
                        req.setAttribute("roles", roles);
                        req.setAttribute("userCode", userCode);
                        req.setAttribute("initials", initials);
                        req.getRequestDispatcher("/WEB-INF/views/admin/user-detail.jsp").forward(req, resp);
                        return;
                    }
                } catch (Exception ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        // Default: /admin/users
        String search = req.getParameter("search");
        String roleIdStr = req.getParameter("roleId");
        String status = req.getParameter("status");

        List<Setting> roles = userService.getAllRoles();
        UUID roleId = null;
        if (roleIdStr != null && !roleIdStr.trim().isEmpty()) {
            try {
                roleId = UUID.fromString(roleIdStr.trim());
            } catch (IllegalArgumentException e) {
                // If roleIdStr is code or name (e.g. ROLE_ADMIN, admin)
                for (Setting r : roles) {
                    if (r.getCode().equalsIgnoreCase(roleIdStr.trim()) || r.getName().equalsIgnoreCase(roleIdStr.trim())) {
                        roleId = r.getId();
                        break;
                    }
                }
            }
        }

        if (roleId != null) {
            roleIdStr = roleId.toString();
        } else {
            roleIdStr = "";
        }

        if (status != null && (status.trim().isEmpty() || status.equalsIgnoreCase("all"))) {
            status = null;
        }

        int page = ControllerSupport.pageNumber(req.getParameter("page"));
        int pageSize = 10;
        String pageSizeParam = req.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                int parsed = Integer.parseInt(pageSizeParam.trim());
                if (parsed == 10 || parsed == 20 || parsed == 50) {
                    pageSize = parsed;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        int totalUsers = userService.countUsers(search, roleId, status);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalUsers / pageSize));
        if (page > totalPages) {
            page = totalPages;
        }

        List<UserDTO> users = userService.getUserList(search, roleId, status, page, pageSize);
        List<String> pageNumbers = PaginationHelper.getPageNumbers(page, totalPages);

        req.setAttribute("users", users);
        req.setAttribute("roles", roles);
        req.setAttribute("search", search != null ? search.trim() : "");
        req.setAttribute("roleId", roleIdStr);
        req.setAttribute("selectedRole", roleIdStr);
        req.setAttribute("selectedStatus", status != null ? status.trim() : "");
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageNumbers", pageNumbers);

        req.getRequestDispatcher("/WEB-INF/views/admin/user-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/user-status".equals(path)) {
            String idStr = req.getParameter("userId");
            String status = req.getParameter("status");
            String statusNote = req.getParameter("statusNote");
            if (idStr != null && status != null) {
                try {
                    UUID userId = UUID.fromString(idStr);
                    if ("inactive".equalsIgnoreCase(status) && (statusNote == null || statusNote.trim().isEmpty())) {
                        req.getSession().setAttribute("flashError", "Vui lòng nhập lý do tạm ngưng tài khoản để người dùng nắm được thông tin.");
                        resp.sendRedirect(req.getContextPath() + "/admin/users");
                        return;
                    }
                    UserDTO user = userService.getUserById(userId);
                    if (user != null) {
                        user.setStatus(status.trim().toLowerCase());
                        com.learnhub.entity.User currentAdmin = ControllerSupport.currentUser(req);
                        String adminEmail = currentAdmin != null ? currentAdmin.getEmail() : "admin";
                        userService.updateUserProfile(user, adminEmail, statusNote);
                    }
                } catch (Exception ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users?updated=status");
            return;
        }

        if ("/admin/user-detail".equals(path)) {
            String action = req.getParameter("action");
            if ("create".equalsIgnoreCase(action) || "new".equalsIgnoreCase(action)) {
                String username = req.getParameter("username");
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String roleIdStr = req.getParameter("roleId");
                String status = req.getParameter("status");

                UUID roleId = null;
                if (roleIdStr != null && !roleIdStr.trim().isEmpty()) {
                    try {
                        roleId = UUID.fromString(roleIdStr.trim());
                    } catch (IllegalArgumentException ignored) {
                    }
                }

                com.learnhub.entity.User currentAdmin = ControllerSupport.currentUser(req);
                String adminEmail = currentAdmin != null ? currentAdmin.getEmail() : "admin";

                UserService.AdminCreateUserResult result = userService.createUserByAdmin(
                        username, fullName, email, phone, roleId, status, adminEmail);

                if (result.isSuccess()) {
                    String msg = "Tạo người dùng thành công!";
                    if (result.isEmailSent()) {
                        msg += " Đã gửi thông tin đăng nhập đến " + (email != null ? email.trim() : "") + ".";
                    } else {
                        msg += " (Lưu ý: Không gửi được email thông báo).";
                    }
                    msg += " Mật khẩu tạm thời: " + result.getTemporaryPassword();
                    req.getSession().setAttribute("flashMessage", msg);
                    resp.sendRedirect(req.getContextPath() + "/admin/users");
                    return;
                } else {
                    req.setAttribute("errorMessage", result.getErrorMessage());
                    req.setAttribute("isNew", true);
                    req.setAttribute("roles", userService.getAllRoles());
                    req.setAttribute("enteredUsername", username);
                    req.setAttribute("enteredFullName", fullName);
                    req.setAttribute("enteredEmail", email);
                    req.setAttribute("enteredPhone", phone);
                    req.setAttribute("enteredRoleId", roleIdStr);
                    req.setAttribute("enteredStatus", status);
                    req.getRequestDispatcher("/WEB-INF/views/admin/user-detail.jsp").forward(req, resp);
                    return;
                }
            }

            String idStr = req.getParameter("userId");
            if (idStr == null || idStr.trim().isEmpty()) {
                idStr = req.getParameter("id");
            }

            if ("reset-password".equalsIgnoreCase(action)) {
                if (idStr != null) {
                    try {
                        UUID userId = UUID.fromString(idStr.trim());
                        com.learnhub.entity.User currentAdmin = ControllerSupport.currentUser(req);
                        String adminEmail = currentAdmin != null ? currentAdmin.getEmail() : "admin";
                        String tempPass = userService.issueTemporaryPassword(userId, adminEmail);
                        if (tempPass != null) {
                            UserDTO targetUser = userService.getUserById(userId);
                            String emailNotice = targetUser != null ? targetUser.getEmail() : "người dùng";
                            req.getSession().setAttribute("flashMessage",
                                    "Đã cấp mật khẩu tạm thời thành công và gửi email đến " + emailNotice + "! Mật khẩu tạm: " + tempPass);
                        } else {
                            req.getSession().setAttribute("flashError", "Không thể tạo mật khẩu tạm thời. Vui lòng kiểm tra lại.");
                        }
                        resp.sendRedirect(req.getContextPath() + "/admin/user-detail?id=" + userId);
                        return;
                    } catch (Exception e) {
                        req.getSession().setAttribute("flashError", "Lỗi khi đặt lại mật khẩu: " + e.getMessage());
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/users");
                return;
            }

            // Default: update user profile
            if (idStr != null) {
                try {
                    UUID userId = UUID.fromString(idStr.trim());
                    String fullName = req.getParameter("fullName");
                    String phone = req.getParameter("phone");
                    String roleIdStr = req.getParameter("roleId");
                    String status = req.getParameter("status");
                    String statusNote = req.getParameter("statusNote");

                    if ("inactive".equalsIgnoreCase(status) && (statusNote == null || statusNote.trim().isEmpty())) {
                        req.getSession().setAttribute("flashError", "Vui lòng nhập lý do tạm ngưng tài khoản để người dùng nắm được thông tin.");
                        resp.sendRedirect(req.getContextPath() + "/admin/user-detail?id=" + userId);
                        return;
                    }

                    if (fullName == null || fullName.trim().isEmpty()) {
                        req.getSession().setAttribute("flashError", "Họ và tên (Full Name) không được để trống.");
                        resp.sendRedirect(req.getContextPath() + "/admin/user-detail?id=" + userId);
                        return;
                    }

                    if (phone != null && !phone.trim().isEmpty()) {
                        String p = phone.trim();
                        if (!p.matches("^0[0-9]{9}$")) {
                            req.getSession().setAttribute("flashError",
                                    "Số điện thoại không hợp lệ (yêu cầu 10 chữ số bắt đầu bằng 0, ví dụ: 0987654321).");
                            resp.sendRedirect(req.getContextPath() + "/admin/user-detail?id=" + userId);
                            return;
                        }
                    }

                    UUID roleId = roleIdStr != null && !roleIdStr.trim().isEmpty() ? UUID.fromString(roleIdStr.trim()) : null;
                    UserDTO dto = new UserDTO();
                    dto.setId(userId);
                    dto.setFullName(fullName.trim());
                    dto.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);
                    dto.setRoleId(roleId);
                    dto.setStatus(status != null ? status.trim() : null);

                    com.learnhub.entity.User currentAdmin = ControllerSupport.currentUser(req);
                    String adminEmail = currentAdmin != null ? currentAdmin.getEmail() : "admin";

                    boolean success = userService.updateUserProfile(dto, adminEmail, statusNote);
                    if (success) {
                        req.getSession().setAttribute("flashMessage", "Cập nhật hồ sơ người dùng thành công.");
                    } else {
                        req.getSession().setAttribute("flashError", "Không thể cập nhật hồ sơ người dùng.");
                    }
                    resp.sendRedirect(req.getContextPath() + "/admin/user-detail?id=" + userId);
                    return;
                } catch (Exception e) {
                    req.getSession().setAttribute("flashError", "Đã xảy ra lỗi khi cập nhật: " + e.getMessage());
                    resp.sendRedirect(req.getContextPath() + "/admin/user-detail?id=" + idStr);
                    return;
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if ("/admin/reset-password".equals(path)) {
            String idStr = req.getParameter("userId");
            String newPass = req.getParameter("newPassword");
            if (idStr != null && newPass != null) {
                try {
                    UUID userId = UUID.fromString(idStr);
                    userService.resetPassword(userId, newPass);
                } catch (Exception ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users?updated=password");
        }
    }

    private String computeInitials(String name) {
        if (name == null || name.isBlank()) return "U";
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        }
        String first = parts[0].substring(0, 1).toUpperCase();
        String last = parts[parts.length - 1].substring(0, 1).toUpperCase();
        return first + last;
    }
}
