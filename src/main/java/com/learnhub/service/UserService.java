package com.learnhub.service;

import com.learnhub.dao.DashboardDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.util.EmailUtil;
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
import java.util.logging.Level;
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

    public static class AdminCreateUserResult {
        private final boolean success;
        private final String temporaryPassword;
        private final boolean emailSent;
        private final String errorMessage;
        private final User user;

        public AdminCreateUserResult(boolean success, String temporaryPassword, boolean emailSent, String errorMessage, User user) {
            this.success = success;
            this.temporaryPassword = temporaryPassword;
            this.emailSent = emailSent;
            this.errorMessage = errorMessage;
            this.user = user;
        }

        public static AdminCreateUserResult success(String temporaryPassword, boolean emailSent, User user) {
            return new AdminCreateUserResult(true, temporaryPassword, emailSent, null, user);
        }

        public static AdminCreateUserResult failure(String errorMessage) {
            return new AdminCreateUserResult(false, null, false, errorMessage, null);
        }

        public boolean isSuccess() { return success; }
        public String getTemporaryPassword() { return temporaryPassword; }
        public boolean isEmailSent() { return emailSent; }
        public String getErrorMessage() { return errorMessage; }
        public User getUser() { return user; }
    }
    private static final Logger LOGGER = Logger.getLogger(UserService.class.getName());

    private final UserDAO userDAO;
    private final SettingDAO settingDAO;
    private final DashboardDAO dashboardDAO;

    public UserService() {
        this.userDAO = new UserDAO();
        this.settingDAO = new SettingDAO();
        this.dashboardDAO = new DashboardDAO();
    }

    public UserService(UserDAO userDAO, SettingDAO settingDAO) {
        this(userDAO, settingDAO, new DashboardDAO());
    }

    public UserService(UserDAO userDAO, SettingDAO settingDAO, DashboardDAO dashboardDAO) {
        this.userDAO = userDAO;
        this.settingDAO = settingDAO;
        this.dashboardDAO = dashboardDAO;
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
        return updateUserProfile(dto, null, null);
    }

    public boolean updateUserProfile(UserDTO dto, String adminEmail, String statusNote) {
        if (dto == null || dto.getId() == null) return false;
        User user = userDAO.findById(dto.getId());
        if (user == null) return false;

        String oldStatus = user.getStatus();
        if (dto.getUsername() != null && !dto.getUsername().isBlank()) {
            user.setUsername(dto.getUsername().trim());
        }
        if (dto.getFullName() != null) {
            String norm = FullNameUtil.normalizeOrNull(dto.getFullName());
            user.setFullName(norm != null ? norm : dto.getFullName().trim());
        }
        if (dto.getEmail() != null && !dto.getEmail().isBlank()) {
            user.setEmail(dto.getEmail().trim());
        }
        if (dto.getRoleId() != null) {
            user.setRoleId(dto.getRoleId());
        }
        user.setPhone(dto.getPhone() != null && !dto.getPhone().isBlank() ? dto.getPhone().trim() : null);

        boolean statusChanged = false;
        if (dto.getStatus() != null && !dto.getStatus().isBlank()) {
            if (!dto.getStatus().equalsIgnoreCase(oldStatus)) {
                statusChanged = true;
                user.setStatus(dto.getStatus().trim().toLowerCase());
            }
        }

        boolean updated = userDAO.update(user);
        if (updated && (statusChanged || (statusNote != null && !statusNote.isBlank()))) {
            try {
                String actor = (adminEmail != null && !adminEmail.isBlank()) ? adminEmail : "admin";
                String actionType = "ACCOUNT_STATUS_CHANGE";
                StringBuilder desc = new StringBuilder();
                desc.append("User [").append(user.getEmail()).append("] status: ");
                if (statusChanged) {
                    desc.append(oldStatus).append(" -> ").append(user.getStatus());
                } else {
                    desc.append(user.getStatus());
                }
                if (statusNote != null && !statusNote.isBlank()) {
                    desc.append(". Note: ").append(statusNote.trim());
                }
                dashboardDAO.insertAuditLog(actor, actionType, desc.toString(), "SUCCESS");
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to log status change audit: " + e.getMessage());
            }
        }
        return updated;
    }

    public String issueTemporaryPassword(UUID userId, String adminEmail) {
        if (userId == null) return null;
        User user = userDAO.findById(userId);
        if (user == null) return null;

        String tempPassword = generateTemporaryPassword();
        String hashed = PasswordHashUtil.hashPassword(tempPassword);
        boolean ok = userDAO.updatePasswordWithMustChange(userId, hashed);
        if (!ok) return null;

        // Send email to user
        try {
            String subject = "LearnHub - Mật khẩu tạm thời cho tài khoản của bạn";
            String body = "Xin chào " + (user.getFullName() != null ? user.getFullName() : user.getUsername()) + ",\n\n"
                    + "Quản trị viên hệ thống đã cấp lại mật khẩu tạm thời cho tài khoản của bạn trên LearnHub.\n\n"
                    + "Mật khẩu tạm thời: " + tempPassword + "\n\n"
                    + "Vì lý do an toàn bảo mật, hệ thống sẽ yêu cầu bạn đổi mật khẩu mới ngay trong lần đăng nhập đầu tiên.\n\n"
                    + "Trân trọng,\nĐội ngũ Quản trị LearnHub";
            EmailUtil.sendEmail(user.getEmail(), subject, body);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to send temp password email to " + user.getEmail() + ": " + e.getMessage());
        }

        // Audit log
        try {
            String actor = (adminEmail != null && !adminEmail.isBlank()) ? adminEmail : "admin";
            dashboardDAO.insertAuditLog(actor, "PASSWORD_RESET_ADMIN",
                    "Issued temporary password for user: " + user.getEmail(), "SUCCESS");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to log password reset audit: " + e.getMessage());
        }

        return tempPassword;
    }

    private String generateTemporaryPassword() {
        String upper = "ABCDEFGHJKLMNPQRSTUVWXYZ";
        String lower = "abcdefghijkmnopqrstuvwxyz";
        String digits = "23456789";
        String special = "@#$%&*";
        java.security.SecureRandom random = new java.security.SecureRandom();
        StringBuilder sb = new StringBuilder();
        sb.append(upper.charAt(random.nextInt(upper.length())));
        sb.append(lower.charAt(random.nextInt(lower.length())));
        sb.append(digits.charAt(random.nextInt(digits.length())));
        sb.append(special.charAt(random.nextInt(special.length())));
        String all = upper + lower + digits + special;
        for (int i = 0; i < 4; i++) {
            sb.append(all.charAt(random.nextInt(all.length())));
        }
        char[] chars = sb.toString().toCharArray();
        for (int i = chars.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char tmp = chars[i];
            chars[i] = chars[j];
            chars[j] = tmp;
        }
        return new String(chars);
    }

    public AdminCreateUserResult createUserByAdmin(String username, String fullName, String email, String phone,
                                                  UUID roleId, String status, String adminEmail) {
        if (username == null || username.isBlank()) {
            return AdminCreateUserResult.failure("Tên đăng nhập không được để trống.");
        }
        String normalizedUsername = username.trim();
        if (!normalizedUsername.matches("^[\\p{L}\\p{N}._-]{3,255}$")) {
            return AdminCreateUserResult.failure("Tên đăng nhập từ 3 đến 255 ký tự, chỉ chứa chữ cái, số, dấu chấm, gạch dưới hoặc gạch ngang.");
        }

        if (email == null || email.isBlank()) {
            return AdminCreateUserResult.failure("Email không được để trống.");
        }
        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);
        if (normalizedEmail.length() > 255 || !normalizedEmail.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            return AdminCreateUserResult.failure("Địa chỉ email không đúng định dạng.");
        }

        String normalizedFullName = FullNameUtil.normalizeOrNull(fullName);
        if (normalizedFullName == null) {
            return AdminCreateUserResult.failure("Họ và tên không hợp lệ.");
        }

        String normalizedPhone = null;
        if (phone != null && !phone.isBlank()) {
            normalizedPhone = phone.trim();
            if (!normalizedPhone.matches("^0[0-9]{9}$")) {
                return AdminCreateUserResult.failure("Số điện thoại không hợp lệ (yêu cầu 10 chữ số bắt đầu bằng 0, ví dụ: 0987654321).");
            }
        }

        if (roleId == null) {
            return AdminCreateUserResult.failure("Vui lòng chọn vai trò cho người dùng.");
        }

        if (isRegistrationIdentityTaken(normalizedUsername, normalizedEmail)) {
            return AdminCreateUserResult.failure("Tên đăng nhập hoặc địa chỉ email này đã được sử dụng.");
        }

        String tempPassword = generateTemporaryPassword();
        String hashedPassword = PasswordHashUtil.hashPassword(tempPassword);

        User newUser = new User();
        newUser.setId(UUID.randomUUID());
        newUser.setUsername(normalizedUsername);
        newUser.setFullName(normalizedFullName);
        newUser.setEmail(normalizedEmail);
        newUser.setPassword(hashedPassword);
        newUser.setRoleId(roleId);
        newUser.setStatus(status != null && !status.isBlank() ? status.trim().toLowerCase(Locale.ROOT) : "active");
        newUser.setPhone(normalizedPhone);
        newUser.setRequiresPasswordChange(true);

        boolean inserted = userDAO.insert(newUser);
        if (!inserted) {
            return AdminCreateUserResult.failure("Không thể lưu người dùng vào cơ sở dữ liệu. Vui lòng thử lại.");
        }

        try {
            String actor = (adminEmail != null && !adminEmail.isBlank()) ? adminEmail : "admin";
            dashboardDAO.insertAuditLog(actor, "USER_CREATE",
                    "Admin created user [" + newUser.getUsername() + " / " + newUser.getEmail() + "] with role ID: " + newUser.getRoleId(), "SUCCESS");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to log user creation audit: " + e.getMessage());
        }

        boolean emailSent = false;
        try {
            String subject = "LearnHub - Thông tin tài khoản người dùng mới";
            String body = "Xin chào " + newUser.getFullName() + ",\n\n"
                    + "Quản trị viên hệ thống đã tạo tài khoản cho bạn trên nền tảng LearnHub.\n\n"
                    + "Thông tin đăng nhập:\n"
                    + "- Tên đăng nhập: " + newUser.getUsername() + "\n"
                    + "- Email: " + newUser.getEmail() + "\n"
                    + "- Mật khẩu tạm thời: " + tempPassword + "\n\n"
                    + "Vì lý do an toàn bảo mật, hệ thống sẽ yêu cầu bạn đổi mật khẩu mới ngay trong lần đăng nhập đầu tiên.\n\n"
                    + "Trân trọng,\nĐội ngũ Quản trị LearnHub";
            EmailUtil.sendEmail(newUser.getEmail(), subject, body);
            emailSent = true;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to send welcome email with temp password to " + newUser.getEmail() + ": " + e.getMessage());
        }

        return AdminCreateUserResult.success(tempPassword, emailSent, newUser);
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
