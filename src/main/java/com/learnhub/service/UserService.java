package com.learnhub.service;

import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.dto.UserDTO;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.util.FullNameUtil;
import com.learnhub.util.PasswordHashUtil;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
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
    public enum UsernameUpdateResult { SUCCESS, INVALID, TAKEN, FAILED }
    public enum ProfileUpdateResult { SUCCESS, INVALID_USERNAME, INVALID_FULL_NAME, TAKEN, FAILED }
    public enum PasswordChangeResult { SUCCESS, INVALID_CURRENT, INVALID_NEW, SAME_PASSWORD, FAILED }
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

    public int countUsers(String search, UUID roleId, String status) {
        return userDAO.countUsers(search, roleId, status);
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

    public UsernameUpdateResult updateOwnUsername(UUID userId, String requestedUsername) {
        if (userId == null || requestedUsername == null) return UsernameUpdateResult.INVALID;
        String username = requestedUsername.trim();
        if (!username.matches("^[\\p{L}\\p{N}._-]{3,255}$")) return UsernameUpdateResult.INVALID;
        User user = userDAO.findById(userId);
        if (user == null || !"active".equalsIgnoreCase(user.getStatus())) return UsernameUpdateResult.FAILED;
        if (userDAO.isIdentityTakenByOther(userId, username)) return UsernameUpdateResult.TAKEN;
        return userDAO.updateOwnUsername(userId, username)
                ? UsernameUpdateResult.SUCCESS : UsernameUpdateResult.FAILED;
    }

    public ProfileUpdateResult updateOwnProfile(UUID userId, String requestedUsername, String requestedFullName) {
        if (userId == null || requestedUsername == null) return ProfileUpdateResult.INVALID_USERNAME;
        String username = requestedUsername.trim();
        if (!username.matches("^[\\p{L}\\p{N}._-]{3,255}$")) return ProfileUpdateResult.INVALID_USERNAME;
        String fullName = FullNameUtil.normalizeOrNull(requestedFullName);
        if (fullName == null) return ProfileUpdateResult.INVALID_FULL_NAME;
        User user = userDAO.findById(userId);
        if (user == null || !"active".equalsIgnoreCase(user.getStatus())) return ProfileUpdateResult.FAILED;
        if (userDAO.isIdentityTakenByOther(userId, username)) return ProfileUpdateResult.TAKEN;
        return userDAO.updateOwnProfile(userId, username, fullName)
                ? ProfileUpdateResult.SUCCESS : ProfileUpdateResult.FAILED;
    }

    public PasswordChangeResult changeOwnPassword(UUID userId, String currentPassword,
                                                   String newPassword) {
        if (userId == null || currentPassword == null || newPassword == null) {
            return PasswordChangeResult.INVALID_NEW;
        }
        User user = userDAO.findById(userId);
        if (user == null || !"active".equalsIgnoreCase(user.getStatus())) {
            return PasswordChangeResult.FAILED;
        }
        if (!PasswordHashUtil.checkPassword(currentPassword, user.getPassword())) {
            return PasswordChangeResult.INVALID_CURRENT;
        }
        if (newPassword.length() < 8 || newPassword.getBytes(StandardCharsets.UTF_8).length > 72) {
            return PasswordChangeResult.INVALID_NEW;
        }
        if (PasswordHashUtil.checkPassword(newPassword, user.getPassword())) {
            return PasswordChangeResult.SAME_PASSWORD;
        }
        String newHash = PasswordHashUtil.hashPassword(newPassword);
        return userDAO.updatePasswordIfCurrentHash(userId, user.getPassword(), newHash)
                ? PasswordChangeResult.SUCCESS : PasswordChangeResult.FAILED;
    }

    public PasswordChangeResult setInitialPassword(UUID userId, String newPassword) {
        if (userId == null || newPassword == null || newPassword.length() < 8
                || newPassword.getBytes(StandardCharsets.UTF_8).length > 72) {
            return PasswordChangeResult.INVALID_NEW;
        }
        User user = userDAO.findById(userId);
        if (user == null || !"active".equalsIgnoreCase(user.getStatus())
                || !user.isRequiresPasswordChange()) {
            return PasswordChangeResult.FAILED;
        }
        if (PasswordHashUtil.checkPassword(newPassword, user.getPassword())) {
            return PasswordChangeResult.SAME_PASSWORD;
        }
        String newHash = PasswordHashUtil.hashPassword(newPassword);
        return userDAO.setInitialPassword(userId, user.getPassword(), newHash)
                ? PasswordChangeResult.SUCCESS : PasswordChangeResult.FAILED;
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

    /** Called only after the email verification code has been accepted. */
    public User registerVerified(String username, String fullName, String email, String passwordHash) {
        if (email == null || passwordHash == null || username == null || !passwordHash.startsWith("$2")) return null;
        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);
        String normalizedName = username.trim();
        String normalizedFullName = FullNameUtil.normalizeOrNull(fullName);
        if (normalizedEmail.isEmpty() || normalizedName.isEmpty() || normalizedFullName == null) return null;
        // Availability was checked before sending the code; check again after verification.
        if (isRegistrationIdentityTaken(normalizedName, normalizedEmail)) return null;

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
        newUser.setUsername(normalizedName);
        newUser.setFullName(normalizedFullName);
        newUser.setEmail(normalizedEmail);
        newUser.setPassword(passwordHash);
        newUser.setRoleId(roleId);
        newUser.setStatus("active");

        if (userDAO.insert(newUser)) {
            return newUser;
        }
        return null;
    }

    /** Checks whether either registration identifier is already in use. */
    public boolean isRegistrationIdentityTaken(String name, String email) {
        return userDAO.findByEmail(email) != null || userDAO.findByEmail(name) != null;
    }

    public List<Setting> getAllRoles() {
        return settingDAO.findAllRoles();
    }

    public UserDTO getUserByEmail(String email) {
        if (email == null) return null;
        User u = userDAO.findByEmail(email.trim());
        return u != null ? toDTO(u) : null;
    }

    private UserDTO toDTO(User u) {
        UserDTO dto = new UserDTO();
        dto.setId(u.getId());
        dto.setUsername(u.getUsername());
        dto.setFullName(u.getFullName());
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
