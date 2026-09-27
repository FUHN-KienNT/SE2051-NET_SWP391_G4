package com.learnhub.controller;

import com.learnhub.dto.UserDTO;
import com.learnhub.entity.Setting;
import com.learnhub.service.UserService;
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
 */
@WebServlet(name = "UserServlet", urlPatterns = {"/admin/users", "/admin/user-detail", "/admin/user-status", "/admin/reset-password"})
public class UserServlet extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/user-detail".equals(path)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    UUID userId = UUID.fromString(idStr);
                    UserDTO user = userService.getUserById(userId);
                    List<Setting> roles = userService.getAllRoles();
                    req.setAttribute("user", user);
                    req.setAttribute("roles", roles);
                    req.getRequestDispatcher("/WEB-INF/views/admin/user-detail.jsp").forward(req, resp);
                    return;
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
        String pageStr = req.getParameter("page");

        UUID roleId = null;
        if (roleIdStr != null && !roleIdStr.trim().isEmpty()) {
            try { roleId = UUID.fromString(roleIdStr); } catch (Exception ignored) {}
        }

        int page = 1;
        if (pageStr != null) {
            try { page = Integer.parseInt(pageStr); } catch (Exception ignored) {}
        }

        List<UserDTO> users = userService.getUserList(search, roleId, status, page, 10);
        List<Setting> roles = userService.getAllRoles();

        req.setAttribute("users", users);
        req.setAttribute("roles", roles);
        req.setAttribute("search", search);
        req.setAttribute("selectedRole", roleIdStr);
        req.setAttribute("selectedStatus", status);

        req.getRequestDispatcher("/WEB-INF/views/admin/user-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/user-status".equals(path)) {
            String idStr = req.getParameter("userId");
            String status = req.getParameter("status");
            if (idStr != null && status != null) {
                try {
                    UUID userId = UUID.fromString(idStr);
                    userService.toggleStatus(userId, status);
                } catch (Exception ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users?updated=status");
            return;
        }

        if ("/admin/user-detail".equals(path)) {
            String idStr = req.getParameter("userId");
            String username = req.getParameter("username");
            String email = req.getParameter("email");
            String roleIdStr = req.getParameter("roleId");
            String status = req.getParameter("status");

            if (idStr != null) {
                try {
                    UUID userId = UUID.fromString(idStr);
                    UUID roleId = roleIdStr != null ? UUID.fromString(roleIdStr) : null;
                    UserDTO dto = new UserDTO(userId, username, email, roleId, null, status);
                    userService.updateUserProfile(dto);
                    resp.sendRedirect(req.getContextPath() + "/admin/user-detail?id=" + userId + "&success=true");
                    return;
                } catch (Exception ignored) {
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
}
