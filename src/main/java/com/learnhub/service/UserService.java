package com.learnhub.service;

import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.dto.UserDTO;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.util.PasswordHashUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;

/**
 * Service handling User management and security logic.
 * Implements methods specified in SDS User Management Class Diagram & Sequence Diagrams (6.1, 6.2, 6.3):
 * - getUserList()
 * - getUserById()
 * - updateUser()
 * - updateUserProfile()
 * - toggleStatus()
 * - resetPassword()
 */
public class UserService {
    private static final Logger LOGGER = Logger.getLogger(UserService.class.getName());

    private final UserDAO userDAO;
    private final SettingDAO settingDAO;

    public UserService() {
        this.userDAO = new UserDAO();
        this.settingDAO = new SettingDAO();
    }

    public UserService(UserDAO userDAO, SettingDAO settingDAO) {
        this.userDAO = userDAO;
        this.settingDAO = settingDAO;
    }

    public List<UserDTO> getUserList(String search, UUID roleId, String status, int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        List<User> users = userDAO.findUsers(search, roleId, status, offset, pageSize);

        List<UserDTO> dtos = new ArrayList<>();
        for (User u : users) {
            dtos.add(toDTO(u));
        }
        return dtos;
    }

    public UserDTO getUserById(UUID id) {
        User u = userDAO.findById(id);
        return u != null ? toDTO(u) : null;
    }

    public boolean updateUser(UserDTO dto) {
        return updateUserProfile(dto);
    }

    public boolean updateUserProfile(UserDTO dto) {
        if (dto == null || dto.getId() == null) return false;
        User user = userDAO.findById(dto.getId());
        if (user == null) return false;

        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        if (dto.getRoleId() != null) {
            user.setRoleId(dto.getRoleId());
        }
        if (dto.getStatus() != null) {
            user.setStatus(dto.getStatus());
        }
        return userDAO.update(user);
    }

    public boolean toggleStatus(UUID userId, String status) {
        if (userId == null) return false;
        return userDAO.updateStatus(userId, status);
    }

    public boolean resetPassword(UUID userId, String newPlainPassword) {
        if (userId == null || newPlainPassword == null || newPlainPassword.isEmpty()) {
            return false;
        }
        String hashed = PasswordHashUtil.hashPassword(newPlainPassword);
        return userDAO.updatePassword(userId, hashed);
    }

    public User login(String email, String plainPassword) {
        if (email == null || plainPassword == null) return null;
        User user = userDAO.findByEmail(email.trim());
        if (user == null) return null;

        if (PasswordHashUtil.checkPassword(plainPassword, user.getPassword())) {
            if ("active".equalsIgnoreCase(user.getStatus())) {
                return user;
            } else {
                LOGGER.warning("User " + email + " is " + user.getStatus());
                return null;
            }
        }
        return null;
    }

    public User register(String name, String email, String password) {
        if (email == null || password == null || name == null) return null;
        if (userDAO.findByEmail(email.trim()) != null) {
            return null;
        }
        if (userDAO.findByEmail(name.trim()) != null) {
            return null;
        }

        Setting studentRole = null;
        List<Setting> roles = settingDAO.findAllRoles();
        for (Setting r : roles) {
            if ("ROLE_STUDENT".equalsIgnoreCase(r.getCode())) {
                studentRole = r;
                break;
            }
        }
        UUID roleId = studentRole != null ? studentRole.getId() : UUID.fromString("a0000000-0000-0000-0000-000000000004");

        User newUser = new User();
        newUser.setId(UUID.randomUUID());
        newUser.setUsername(name);
        newUser.setEmail(email.trim());
        newUser.setPassword(PasswordHashUtil.hashPassword(password));
        newUser.setRoleId(roleId);
        newUser.setStatus("active");

        if (userDAO.insert(newUser)) {
            return newUser;
        }
        return null;
    }

    public List<Setting> getAllRoles() {
        return settingDAO.findAllRoles();
    }

    private UserDTO toDTO(User u) {
        UserDTO dto = new UserDTO();
        dto.setId(u.getId());
        dto.setUsername(u.getUsername());
        dto.setFullName(u.getUsername());
        dto.setEmail(u.getEmail());
        dto.setRoleId(u.getRoleId());
        dto.setRoleName(u.getRoleName());
        dto.setRoleCode(u.getRoleCode());
        dto.setStatus(u.getStatus());
        dto.setPhone(u.getPhone());
        dto.setAvatarUrl(u.getAvatarUrl());
        return dto;
    }
}
