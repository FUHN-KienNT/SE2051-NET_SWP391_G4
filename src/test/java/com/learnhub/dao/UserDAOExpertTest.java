package com.learnhub.dao;

import com.learnhub.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserDAOExpertTest {
    @Test
    void testFindInstructorsReturnsOnlyActiveExperts() {
        UserDAO dao = new UserDAO();
        List<User> list = dao.findInstructors();
        assertNotNull(list);
        assertFalse(list.isEmpty(), "Should return at least one active expert from database");
        for (User u : list) {
            String roleCode = u.getRoleCode() != null ? u.getRoleCode().trim().toUpperCase() : "";
            String roleName = u.getRoleName() != null ? u.getRoleName().trim().toLowerCase() : "";
            boolean isExpert = "ROLE_EXPERT".equals(roleCode) || "EXPERT".equals(roleCode)
                    || "expert".equals(roleName) || roleName.startsWith("expert");
            assertTrue(isExpert, "User " + u.getUsername() + " must have expert role");

            boolean isOtherRole = "ROLE_ADMIN".equals(roleCode) || "ROLE_MANAGER".equals(roleCode) || "ROLE_STUDENT".equals(roleCode);
            assertFalse(isOtherRole, "User " + u.getUsername() + " must not have another role");

            assertTrue("active".equalsIgnoreCase(u.getStatus()), "User " + u.getUsername() + " must be active");
            assertTrue(dao.isExpert(u.getId()), "isExpert check must return true for " + u.getUsername());
        }
    }
}
