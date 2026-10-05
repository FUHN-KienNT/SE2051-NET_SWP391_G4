package com.learnhub.service;

import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.User;
import com.learnhub.util.PasswordHashUtil;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserServiceAccountTest {
    private static class AccountDao extends UserDAO {
        final User user = new User();
        boolean taken;
        String savedUsername;
        String savedHash;

        AccountDao() {
            user.setId(UUID.randomUUID());
            user.setUsername("Alex");
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
        public boolean updatePasswordIfCurrentHash(UUID userId, String currentHash, String newHash) {
            if (!currentHash.equals(user.getPassword())) return false;
            savedHash = newHash;
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
}
