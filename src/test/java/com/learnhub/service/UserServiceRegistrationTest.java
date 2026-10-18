package com.learnhub.service;

import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.util.PasswordHashUtil;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserServiceRegistrationTest {
    private static class RegistrationDao extends UserDAO {
        User inserted;
        String takenIdentity;

        @Override public User findByEmail(String email) {
            return takenIdentity != null && takenIdentity.equalsIgnoreCase(email) ? new User() : null;
        }
        @Override public boolean insert(User user) { inserted = user; return true; }
    }

    @Test
    void registrationRechecksIdentityAfterVerification() {
        RegistrationDao dao = new RegistrationDao();
        UserService service = new UserService(dao, new RolesDao());
        String hash = PasswordHashUtil.hashPassword("password123");

        assertFalse(service.isRegistrationIdentityTaken("alex", "alex@example.com"));
        dao.takenIdentity = "alex";
        assertTrue(service.isRegistrationIdentityTaken("alex", "alex@example.com"));
        assertNull(service.registerVerified("alex", "Nguyễn Văn A", "alex@example.com", hash));
        assertNull(dao.inserted);

        dao.takenIdentity = "alex@example.com";
        assertTrue(service.isRegistrationIdentityTaken("alex", "alex@example.com"));
        assertNull(service.registerVerified("alex", "Nguyễn Văn A", "alex@example.com", hash));
        assertNull(dao.inserted);
    }

    private static class RolesDao extends SettingDAO {
        @Override public List<Setting> findAllRoles() {
            return List.of(new Setting(UUID.randomUUID(), "role", "ROLE_STUDENT", "Student", null, true, 1));
        }
    }

    @Test
    void verifiedRegistrationRequiresAndPersistsIndependentFullName() {
        RegistrationDao dao = new RegistrationDao();
        UserService service = new UserService(dao, new RolesDao());
        String hash = PasswordHashUtil.hashPassword("password123");

        assertNull(service.registerVerified("alex", " \t ", "alex@example.com", hash));
        assertNull(service.registerVerified("alex", "a".repeat(256), "alex@example.com", hash));
        assertNull(service.registerVerified("alex", "Nguyễn abc@123", "alex@example.com", hash));
        assertNull(dao.inserted);

        User created = service.registerVerified("alex", "  Nguyễn Văn A  ", "ALEX@example.com", hash);
        assertNotNull(created);
        assertEquals("alex", created.getUsername());
        assertEquals("Nguyễn Văn A", created.getFullName());
        assertEquals("alex@example.com", created.getEmail());
        assertEquals(created, dao.inserted);
    }
}
