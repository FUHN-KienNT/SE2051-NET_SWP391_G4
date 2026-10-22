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
        assertEquals("/learnhub/expert/dashboard", destination(AppConstants.Role.EXPERT, "/expert/dashboard"));
        assertEquals("/learnhub/expert/lessons/edit?id=lesson&courseId=course",
                destination(AppConstants.Role.EXPERT, "/expert/lessons/edit?id=lesson&courseId=course"));
        assertEquals("/learnhub/expert/questions/detail?id=question",
                destination(AppConstants.Role.EXPERT, "/expert/questions/detail?id=question"));
        assertEquals("/learnhub/expert/quizzes/detail?id=quiz",
                destination(AppConstants.Role.EXPERT, "/expert/quizzes/detail?id=quiz"));
        assertEquals("/learnhub/my-enrollments?registered=success", destination(AppConstants.Role.STUDENT,
                "/my-enrollments?registered=success"));
    }

    @Test
    void managerAlwaysStartsAtDashboardAfterLogin() {
        assertEquals("/learnhub/manager/dashboard", destination(AppConstants.Role.MANAGER,
                "/learnhub/manager/courses?status=draft"));
        assertEquals("/learnhub/manager/dashboard", destination(AppConstants.Role.MANAGER,
                "/manager/dashboard?period=quarter"));
    }

    @Test
    void forbiddenRoleLinksFallBackToTheUsersDashboard() {
        assertEquals("/learnhub/manager/dashboard", destination(AppConstants.Role.MANAGER, "/learnhub/admin/dashboard"));
        assertEquals("/learnhub/manager/dashboard", destination(AppConstants.Role.MANAGER, "/admin/users"));
        assertEquals("/learnhub/admin/dashboard", destination(AppConstants.Role.ADMIN, "/manager/dashboard"));
        assertEquals("/learnhub/expert/dashboard", destination(AppConstants.Role.EXPERT, "/admin/dashboard"));
        assertEquals("/learnhub/my-enrollments", destination(AppConstants.Role.STUDENT, "/expert/dashboard"));
        assertEquals("/learnhub/my-enrollments", destination(AppConstants.Role.STUDENT, "/expert/lessons"));
    }

    @Test
    void courseDeepLinksAllowExpertButRejectAdmin() {
        for (String path : new String[]{"/manager/courses", "/manager/course-detail", "/manager/course-status"}) {
            assertEquals(CONTEXT + path + "?id=123", destination(AppConstants.Role.EXPERT, path + "?id=123"));
            assertEquals(CONTEXT + "/admin/dashboard", destination(AppConstants.Role.ADMIN, path));
        }
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
