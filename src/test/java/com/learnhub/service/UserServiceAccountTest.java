package com.learnhub.service;

import com.learnhub.dao.DashboardDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.dto.UserDTO;
import com.learnhub.entity.User;
import com.learnhub.util.PasswordHashUtil;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserServiceAccountTest {
    private static class AccountDao extends UserDAO {
        final User user = new User();
        boolean taken;
        String savedUsername;
        String savedFullName;
        String savedHash;
        User insertedUser;
        boolean insertCalled;
        boolean updateCalled;
        boolean updatePasswordWithMustChangeCalled;

        AccountDao() {
            user.setId(UUID.randomUUID());
            user.setUsername("Alex");
            user.setFullName("Alex Nguyen");
            user.setStatus("active");
            user.setPassword(PasswordHashUtil.hashPassword("current-password"));
        }

        @Override
        public User findById(UUID id) {
            return user.getId().equals(id) ? user : null;
        }

        @Override
        public boolean isIdentityTakenByOther(UUID userId, String username) {
            return taken;
        }

        @Override
        public boolean updateOwnUsername(UUID userId, String username) {
            savedUsername = username;
            return true;
        }

        @Override
        public boolean updateOwnProfile(UUID userId, String username, String fullName) {
            savedUsername = username;
            savedFullName = fullName;
            return true;
        }

        @Override
        public boolean updatePasswordIfCurrentHash(UUID userId, String currentHash, String newHash) {
            if (!currentHash.equals(user.getPassword())) return false;
            savedHash = newHash;
            return true;
        }

        @Override
        public boolean setInitialPassword(UUID userId, String currentHash, String newHash) {
            if (!user.isRequiresPasswordChange() || !currentHash.equals(user.getPassword())) return false;
            savedHash = newHash;
            user.setPassword(newHash);
            user.setRequiresPasswordChange(false);
            return true;
        }

        @Override
        public boolean update(User u) {
            updateCalled = true;
            return true;
        }

        @Override
        public boolean updatePasswordWithMustChange(UUID userId, String newHashedPassword) {
            updatePasswordWithMustChangeCalled = true;
            savedHash = newHashedPassword;
            return true;
        }

        @Override
        public boolean insert(User u) {
            this.insertedUser = u;
            this.insertCalled = true;
            return true;
        }

        @Override
        public User findByEmail(String email) {
            if (taken) {
                User u = new User();
                u.setEmail(email);
                return u;
            }
            return null;
        }
    }

    private static class MockDashboardDao extends DashboardDAO {
        String loggedAction;
        String loggedDesc;

        @Override
        public boolean insertAuditLog(String actor, String actionType, String description, String status) {
            this.loggedAction = actionType;
            this.loggedDesc = description;
            return true;
        }
    }

    @Test
    void ownUsernameIsValidatedAndCannotReuseAnotherIdentity() {
        AccountDao dao = new AccountDao();
        UserService service = new UserService(dao, new SettingDAO());
        assertEquals(UserService.UsernameUpdateResult.INVALID,
                service.updateOwnUsername(dao.user.getId(), " x "));
        assertEquals(UserService.UsernameUpdateResult.INVALID,
                service.updateOwnUsername(dao.user.getId(), "New Name"));
        dao.taken = true;
        assertEquals(UserService.UsernameUpdateResult.TAKEN,
                service.updateOwnUsername(dao.user.getId(), "Other"));
        dao.taken = false;
        assertEquals(UserService.UsernameUpdateResult.SUCCESS,
                service.updateOwnUsername(dao.user.getId(), "  New_Name  "));
        assertEquals("New_Name", dao.savedUsername);
    }

    @Test
    void passwordChangeRequiresCurrentPasswordAndHashesTheReplacement() {
        AccountDao dao = new AccountDao();
        UserService service = new UserService(dao, new SettingDAO());
        UUID userId = dao.user.getId();
        assertEquals(UserService.PasswordChangeResult.INVALID_CURRENT,
                service.changeOwnPassword(userId, "wrong-password", "new-password"));
        assertEquals(UserService.PasswordChangeResult.SAME_PASSWORD,
                service.changeOwnPassword(userId, "current-password", "current-password"));
        assertEquals(UserService.PasswordChangeResult.INVALID_NEW,
                service.changeOwnPassword(userId, "current-password", "short"));
        assertEquals(UserService.PasswordChangeResult.SUCCESS,
                service.changeOwnPassword(userId, "current-password", "new-password"));
        assertTrue(PasswordHashUtil.checkPassword("new-password", dao.savedHash));
    }

    @Test
    void ownProfileRequiresFullNameAndKeepsItSeparateFromUsername() {
        AccountDao dao = new AccountDao();
        UserService service = new UserService(dao, new SettingDAO());
        UUID userId = dao.user.getId();
        assertEquals(UserService.ProfileUpdateResult.INVALID_FULL_NAME,
                service.updateOwnProfile(userId, "Alex", "  \t  "));
        assertEquals(UserService.ProfileUpdateResult.INVALID_FULL_NAME,
                service.updateOwnProfile(userId, "Alex", "a".repeat(256)));
        assertEquals(UserService.ProfileUpdateResult.INVALID_FULL_NAME,
                service.updateOwnProfile(userId, "Alex", "Nguyễn abc@123"));
        dao.taken = true;
        assertEquals(UserService.ProfileUpdateResult.TAKEN,
                service.updateOwnProfile(userId, "Other", "Nguyễn Văn A"));
        dao.taken = false;
        assertEquals(UserService.ProfileUpdateResult.SUCCESS,
                service.updateOwnProfile(userId, "  Alex_2  ", "  Nguyễn Văn A  "));
        assertEquals("Alex_2", dao.savedUsername);
        assertEquals("Nguyễn Văn A", dao.savedFullName);
    }

    @Test
    void newGoogleAccountCanSetPasswordOnlyWhileSetupIsRequired() {
        AccountDao dao = new AccountDao();
        UserService service = new UserService(dao, new SettingDAO());
        UUID userId = dao.user.getId();

        assertEquals(UserService.PasswordChangeResult.FAILED,
                service.setInitialPassword(userId, "new-password"));
        dao.user.setRequiresPasswordChange(true);
        assertEquals(UserService.PasswordChangeResult.INVALID_NEW,
                service.setInitialPassword(userId, "short"));
        assertEquals(UserService.PasswordChangeResult.SAME_PASSWORD,
                service.setInitialPassword(userId, "current-password"));
        assertEquals(UserService.PasswordChangeResult.SUCCESS,
                service.setInitialPassword(userId, "new-password"));
        assertTrue(PasswordHashUtil.checkPassword("new-password", dao.savedHash));
        assertEquals(UserService.PasswordChangeResult.FAILED,
                service.setInitialPassword(userId, "another-password"));
    }

    @Test
    void updateUserProfileUpdatesPhoneAndStatusWithAuditLog() {
        AccountDao dao = new AccountDao();
        MockDashboardDao dashboardDao = new MockDashboardDao();
        UserService service = new UserService(dao, new SettingDAO(), dashboardDao);
        UUID userId = dao.user.getId();

        UserDTO dto = new UserDTO();
        dto.setId(userId);
        dto.setFullName("Lê Đình Nguyên");
        dto.setPhone("0987654321");
        dto.setStatus("banned");

        boolean success = service.updateUserProfile(dto, "admin@learnhub.com", "Vi phạm điều khoản dịch vụ");
        assertTrue(success);
        assertTrue(dao.updateCalled);
        assertEquals("Lê Đình Nguyên", dao.user.getFullName());
        assertEquals("0987654321", dao.user.getPhone());
        assertEquals("banned", dao.user.getStatus());
        assertEquals("ACCOUNT_STATUS_CHANGE", dashboardDao.loggedAction);
        assertTrue(dashboardDao.loggedDesc.contains("Vi phạm điều khoản dịch vụ"));
    }

    @Test
    void issueTemporaryPasswordGeneratesPasswordAndSetsFlag() {
        AccountDao dao = new AccountDao();
        MockDashboardDao dashboardDao = new MockDashboardDao();
        UserService service = new UserService(dao, new SettingDAO(), dashboardDao);
        UUID userId = dao.user.getId();

        String tempPass = service.issueTemporaryPassword(userId, "admin@learnhub.com");
        assertNotNull(tempPass);
        assertEquals(8, tempPass.length());
        assertTrue(dao.updatePasswordWithMustChangeCalled);
        assertTrue(PasswordHashUtil.checkPassword(tempPass, dao.savedHash));
        assertEquals("PASSWORD_RESET_ADMIN", dashboardDao.loggedAction);
    }

    @Test
    void createUserByAdminSuccessfullyCreatesUserWithTempPasswordAndRequiresPasswordChange() {
        AccountDao dao = new AccountDao();
        MockDashboardDao dashboardDao = new MockDashboardDao();
        UserService service = new UserService(dao, new SettingDAO(), dashboardDao);

        UUID roleId = UUID.randomUUID();
        UserService.AdminCreateUserResult result = service.createUserByAdmin(
                "hoangnam2026",
                "Nguyễn Hoàng Nam",
                "namnh@learnhub.edu.vn",
                "0987654321",
                roleId,
                "active",
                "admin@learnhub.com"
        );

        assertTrue(result.isSuccess());
        assertNotNull(result.getTemporaryPassword());
        assertEquals(8, result.getTemporaryPassword().length());
        assertTrue(dao.insertCalled);
        assertNotNull(dao.insertedUser);
        assertEquals("hoangnam2026", dao.insertedUser.getUsername());
        assertEquals("Nguyễn Hoàng Nam", dao.insertedUser.getFullName());
        assertEquals("namnh@learnhub.edu.vn", dao.insertedUser.getEmail());
        assertEquals("0987654321", dao.insertedUser.getPhone());
        assertEquals(roleId, dao.insertedUser.getRoleId());
        assertEquals("active", dao.insertedUser.getStatus());
        assertTrue(dao.insertedUser.isRequiresPasswordChange());
        assertTrue(PasswordHashUtil.checkPassword(result.getTemporaryPassword(), dao.insertedUser.getPassword()));
        assertEquals("USER_CREATE", dashboardDao.loggedAction);
    }

    @Test
    void createUserByAdminValidatesInputsAndRejectsDuplicates() {
        AccountDao dao = new AccountDao();
        MockDashboardDao dashboardDao = new MockDashboardDao();
        UserService service = new UserService(dao, new SettingDAO(), dashboardDao);
        UUID roleId = UUID.randomUUID();

        // 1. Empty username
        UserService.AdminCreateUserResult r1 = service.createUserByAdmin("", "Nguyễn Văn A", "a@test.com", null, roleId, "active", "admin");
        assertEquals(false, r1.isSuccess());
        assertTrue(r1.getErrorMessage().contains("Tên đăng nhập không được để trống"));

        // 2. Invalid username format
        UserService.AdminCreateUserResult r2 = service.createUserByAdmin("a b", "Nguyễn Văn A", "a@test.com", null, roleId, "active", "admin");
        assertEquals(false, r2.isSuccess());
        assertTrue(r2.getErrorMessage().contains("Tên đăng nhập từ 3 đến 255 ký tự"));

        // 3. Invalid email format
        UserService.AdminCreateUserResult r3 = service.createUserByAdmin("validuser", "Nguyễn Văn A", "invalid-email", null, roleId, "active", "admin");
        assertEquals(false, r3.isSuccess());
        assertTrue(r3.getErrorMessage().contains("email không đúng định dạng"));

        // 4. Invalid full name
        UserService.AdminCreateUserResult r4 = service.createUserByAdmin("validuser", "   ", "a@test.com", null, roleId, "active", "admin");
        assertEquals(false, r4.isSuccess());
        assertTrue(r4.getErrorMessage().contains("Họ và tên không hợp lệ"));

        // 5. Invalid phone number
        UserService.AdminCreateUserResult r5 = service.createUserByAdmin("validuser", "Nguyễn Văn A", "a@test.com", "12345", roleId, "active", "admin");
        assertEquals(false, r5.isSuccess());
        assertTrue(r5.getErrorMessage().contains("Số điện thoại không hợp lệ"));

        // 6. Null role
        UserService.AdminCreateUserResult r6 = service.createUserByAdmin("validuser", "Nguyễn Văn A", "a@test.com", null, null, "active", "admin");
        assertEquals(false, r6.isSuccess());
        assertTrue(r6.getErrorMessage().contains("Vui lòng chọn vai trò"));

        // 7. Identity taken
        dao.taken = true;
        UserService.AdminCreateUserResult r7 = service.createUserByAdmin("validuser", "Nguyễn Văn A", "a@test.com", null, roleId, "active", "admin");
        assertEquals(false, r7.isSuccess());
        assertTrue(r7.getErrorMessage().contains("đã được sử dụng"));
    }
}
