package com.learnhub.util;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class PostLoginNavigationTest {
    private static final String CONTEXT = "/learnhub";

    @Test
    void genericEntryGoesToEachRolesOwnDashboard() {
        assertEquals("/learnhub/admin/dashboard", destination(AppConstants.Role.ADMIN, "/learnhub/home"));
        assertEquals("/learnhub/manager/dashboard", destination(AppConstants.Role.MANAGER, "/home"));
        assertEquals("/learnhub/expert/dashboard", destination(AppConstants.Role.EXPERT, null));
        assertEquals("/learnhub/my-enrollments", destination(AppConstants.Role.STUDENT, "/"));
    }

    @Test
    void preservesAllowedDeepLinksAndQueryStrings() {
        assertEquals("/learnhub/admin/users?page=2", destination(AppConstants.Role.ADMIN, "/admin/users?page=2"));
        assertEquals("/learnhub/admin/courses?status=draft", destination(AppConstants.Role.MANAGER,
                "/learnhub/admin/courses?status=draft"));
        assertEquals("/learnhub/expert/dashboard", destination(AppConstants.Role.EXPERT, "/expert/dashboard"));
        assertEquals("/learnhub/my-enrollments?registered=success", destination(AppConstants.Role.STUDENT,
                "/my-enrollments?registered=success"));
    }

    @Test
    void forbiddenRoleLinksFallBackToTheUsersDashboard() {
        assertEquals("/learnhub/manager/dashboard", destination(AppConstants.Role.MANAGER, "/learnhub/admin/dashboard"));
        assertEquals("/learnhub/manager/dashboard", destination(AppConstants.Role.MANAGER, "/admin/users"));
        assertEquals("/learnhub/admin/dashboard", destination(AppConstants.Role.ADMIN, "/manager/dashboard"));
        assertEquals("/learnhub/expert/dashboard", destination(AppConstants.Role.EXPERT, "/admin/dashboard"));
        assertEquals("/learnhub/my-enrollments", destination(AppConstants.Role.STUDENT, "/expert/dashboard"));
    }

    @Test
    void rejectsExternalAndMalformedRedirects() {
        assertNull(PostLoginNavigation.safeLocalPath("https://example.com/", CONTEXT));
        assertNull(PostLoginNavigation.safeLocalPath("//example.com/", CONTEXT));
        assertNull(PostLoginNavigation.safeLocalPath("/admin/%2e%2e/users", CONTEXT));
        assertNull(PostLoginNavigation.safeLocalPath("/admin/../users", CONTEXT));
        assertNull(PostLoginNavigation.safeLocalPath("/admin%2fusers", CONTEXT));
        assertNull(PostLoginNavigation.safeLocalPath("/home\r\nLocation: https://example.com", CONTEXT));
        assertEquals("/learnhub/my-enrollments", destination(AppConstants.Role.STUDENT, "//example.com/"));
    }

    private static String destination(String role, String requested) {
        User user = new User();
        user.setRoleCode(role);
        return PostLoginNavigation.destination(user, requested, CONTEXT);
    }
}
