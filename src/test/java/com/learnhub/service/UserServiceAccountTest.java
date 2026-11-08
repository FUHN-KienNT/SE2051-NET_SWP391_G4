package com.learnhub.service;

import com.learnhub.dao.DashboardDAO;
import com.learnhub.dao.NotificationDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.dto.UserDTO;
import com.learnhub.entity.Notification;
import com.learnhub.entity.User;
import com.learnhub.util.PasswordHashUtil;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserServiceAccountTest {
    private static class AccountDao extends UserDAO {
        final User user = new User();
        boolean taken;
        boolean phoneTaken;
        String savedUsername;
        String savedFullName;
        String savedPhone;
        String savedHash;
        User insertedUser;
        boolean insertCalled;
        boolean updateCalled;
        boolean updatePasswordWithMustChangeCalled;

        AccountDao() {
            user.setId(UUID.randomUUID());
            user.setUsername("Alex");
            user.setFullName("Alex Nguyen");
            user.setEmail("alex@learnhub.com");
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
        public boolean isPhoneTakenByOther(UUID userId, String phone) { return phoneTaken; }

        @Override
        public boolean updateOwnUsername(UUID userId, String username) {
            savedUsername = username;
            return true;
        }

        @Override
        public boolean updateOwnProfile(UUID userId, String username, String fullName, String phone) {
            savedUsername = username;
            savedFullName = fullName;
            savedPhone = phone;
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
            if (!user.isRequiresPasswordChange() || !java.util.Objects.equals(currentHash, user.getPassword())) return false;
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
            if (user != null && email != null &&
                    (email.trim().equalsIgnoreCase(user.getEmail()) || email.trim().equalsIgnoreCase(user.getUsername()))) {
                return user;
            }
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

    private static class MockNotificationDao extends NotificationDAO {
        Notification insertedNotification;
        final List<Notification> returnedList = new ArrayList<>();

        @Override
        public boolean insert(Notification notification) {
            this.insertedNotification = notification;
            return true;
        }

        @Override
        public List<Notification> findByUserId(UUID userId) {
            return returnedList;
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
                service.updateOwnProfile(userId, "Alex", "  \t  ", null));
        assertEquals(UserService.ProfileUpdateResult.INVALID_FULL_NAME,
                service.updateOwnProfile(userId, "Alex", "a".repeat(256), null));
        assertEquals(UserService.ProfileUpdateResult.INVALID_FULL_NAME,
                service.updateOwnProfile(userId, "Alex", "Nguyễn abc@123", null));
        assertEquals(UserService.ProfileUpdateResult.INVALID_PHONE,
                service.updateOwnProfile(userId, "Alex", "Nguyễn Văn A", "12345"));
        dao.taken = true;
        assertEquals(UserService.ProfileUpdateResult.TAKEN,
                service.updateOwnProfile(userId, "Other", "Nguyễn Văn A", null));
        dao.taken = false;
        dao.phoneTaken = true;
        assertEquals(UserService.ProfileUpdateResult.PHONE_TAKEN,
                service.updateOwnProfile(userId, "Alex_2", "Nguyễn Văn A", "0987654321"));
        dao.phoneTaken = false;
        assertEquals(UserService.ProfileUpdateResult.SUCCESS,
                service.updateOwnProfile(userId, "  Alex_2  ", "  Nguyễn Văn A  ", " 0987654321 "));
        assertEquals("Alex_2", dao.savedUsername);
        assertEquals("Nguyễn Văn A", dao.savedFullName);
        assertEquals("0987654321", dao.savedPhone);
        assertEquals(UserService.ProfileUpdateResult.INVALID_PHONE,
                service.updateOwnProfile(userId, "Alex_2", "Nguyễn Văn A", "+84 912 345 678"));
        assertEquals(UserService.ProfileUpdateResult.INVALID_PHONE,
                service.updateOwnProfile(userId, "Alex_2", "Nguyễn Văn A", "1987654321"));
        assertEquals(UserService.ProfileUpdateResult.SUCCESS,
                service.updateOwnProfile(userId, "Alex_2", "Nguyễn Văn A", ""));
        assertNull(dao.savedPhone);
    }

    @Test
    void googleAccountWithNullPasswordMustCompleteSetupBeforePasswordLogin() {
        AccountDao dao = new AccountDao();
        UserService service = new UserService(dao, new SettingDAO());
        dao.user.setPassword(null);
        dao.user.setRequiresPasswordChange(true);

        assertEquals(UserService.LoginStatus.INVALID_CREDENTIALS,
                service.authenticate(dao.user.getEmail(), "new-password").getStatus());
        assertEquals(UserService.LoginStatus.INVALID_CREDENTIALS,
                service.authenticate(dao.user.getEmail(), "").getStatus());
        assertEquals(UserService.PasswordChangeResult.INVALID_NEW,
                service.setInitialPassword(dao.user.getId(), "short"));
        assertNull(dao.user.getPassword());
        assertTrue(dao.user.isRequiresPasswordChange());

        assertEquals(UserService.PasswordChangeResult.SUCCESS,
                service.setInitialPassword(dao.user.getId(), "new-password"));
        assertTrue(PasswordHashUtil.checkPassword("new-password", dao.savedHash));
        assertFalse(dao.user.isRequiresPasswordChange());
        assertEquals(UserService.LoginStatus.SUCCESS,
                service.authenticate(dao.user.getEmail(), "new-password").getStatus());
        assertEquals(UserService.PasswordChangeResult.FAILED,
                service.setInitialPassword(dao.user.getId(), "another-password"));
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
    void updateUserProfileUpdatesPhoneAndStatusWithAuditLogAndNotification() {
        AccountDao dao = new AccountDao();
        MockDashboardDao dashboardDao = new MockDashboardDao();
        MockNotificationDao notificationDao = new MockNotificationDao();
        UserService service = new UserService(dao, new SettingDAO(), dashboardDao, notificationDao);
        UUID userId = dao.user.getId();

        UserDTO dto = new UserDTO();
        dto.setId(userId);
        dto.setFullName("Lê Đình Nguyên");
        dto.setPhone("0987654321");
        dto.setStatus("inactive");

        boolean success = service.updateUserProfile(dto, "admin@learnhub.com", "Vi phạm điều khoản dịch vụ");
        assertTrue(success);
        assertTrue(dao.updateCalled);
        assertEquals("Lê Đình Nguyên", dao.user.getFullName());
        assertEquals("0987654321", dao.user.getPhone());
        assertEquals("inactive", dao.user.getStatus());
        assertEquals("Vi phạm điều khoản dịch vụ", dao.user.getStatusNote());
        assertEquals("ACCOUNT_STATUS_CHANGE", dashboardDao.loggedAction);
        assertTrue(dashboardDao.loggedDesc.contains("Vi phạm điều khoản dịch vụ"));
        assertNotNull(notificationDao.insertedNotification);
        assertEquals(userId, notificationDao.insertedNotification.getUserId());
        assertTrue(notificationDao.insertedNotification.getContent().contains("Vi phạm điều khoản dịch vụ"));
    }

    @Test
    void updateUserProfileRequiresReasonWhenSettingInactive() {
        AccountDao dao = new AccountDao();
        MockDashboardDao dashboardDao = new MockDashboardDao();
        MockNotificationDao notificationDao = new MockNotificationDao();
        UserService service = new UserService(dao, new SettingDAO(), dashboardDao, notificationDao);
        UUID userId = dao.user.getId();

        UserDTO dto = new UserDTO();
        dto.setId(userId);
        dto.setStatus("inactive");

        // Null reason should fail
        boolean successNull = service.updateUserProfile(dto, "admin@learnhub.com", null);
        assertFalse(successNull);

        // Empty reason should fail
        boolean successEmpty = service.updateUserProfile(dto, "admin@learnhub.com", "   ");
        assertFalse(successEmpty);
    }

    @Test
    void authenticateActiveUserSuccess() {
        AccountDao dao = new AccountDao();
        UserService service = new UserService(dao, new SettingDAO());

        UserService.LoginResult result = service.authenticate("alex@learnhub.com", "current-password");
        assertEquals(UserService.LoginStatus.SUCCESS, result.getStatus());
        assertNotNull(result.getUser());
        assertEquals("Alex", result.getUser().getUsername());
    }

    @Test
    void authenticateInvalidPasswordDoesNotRevealInactiveStatus() {
        AccountDao dao = new AccountDao();
        dao.user.setStatus("inactive");
        dao.user.setStatusNote("Chưa hoàn tất học phí");
        UserService service = new UserService(dao, new SettingDAO());

        // Wrong password on inactive account must return INVALID_CREDENTIALS without revealing inactive state
        UserService.LoginResult result = service.authenticate("alex@learnhub.com", "wrong-password");
        assertEquals(UserService.LoginStatus.INVALID_CREDENTIALS, result.getStatus());
        assertNull(result.getUser());
        assertNull(result.getStatusNote());
    }

    @Test
    void authenticateInactiveAccountReturnsReasonWhenPasswordIsCorrect() {
        AccountDao dao = new AccountDao();
        dao.user.setStatus("inactive");
        dao.user.setStatusNote("Chưa đóng học phí Fall 2026");
        UserService service = new UserService(dao, new SettingDAO());

        UserService.LoginResult result = service.authenticate("alex@learnhub.com", "current-password");
        assertEquals(UserService.LoginStatus.ACCOUNT_INACTIVE, result.getStatus());
        assertNotNull(result.getUser());
        assertEquals("Chưa đóng học phí Fall 2026", result.getStatusNote());
    }

    @Test
    void authenticateInactiveAccountWithoutNoteFallsBackToNotification() {
        AccountDao dao = new AccountDao();
        dao.user.setStatus("inactive");
        dao.user.setStatusNote(null); // No note in user table

        MockNotificationDao notificationDao = new MockNotificationDao();
        Notification notif = new Notification();
        notif.setUserId(dao.user.getId());
        notif.setContent("Tài khoản của bạn đã được chuyển sang trạng thái tạm ngưng. Lý do: Bảo trì tài khoản định kỳ");
        notificationDao.returnedList.add(notif);

        UserService service = new UserService(dao, new SettingDAO(), new DashboardDAO(), notificationDao);

        UserService.LoginResult result = service.authenticate("alex@learnhub.com", "current-password");
        assertEquals(UserService.LoginStatus.ACCOUNT_INACTIVE, result.getStatus());
        assertNotNull(result.getStatusNote());
        assertTrue(result.getStatusNote().contains("Bảo trì tài khoản định kỳ"));
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
