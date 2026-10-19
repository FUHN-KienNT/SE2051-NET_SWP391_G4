package com.learnhub.controller;

import jakarta.servlet.annotation.WebServlet;
import org.junit.jupiter.api.Test;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;
import static org.junit.jupiter.api.Assertions.*;

class ControllerRoutesTest {
    @Test
    void preservesExistingUrlsWithoutDuplicateMappings() throws Exception {
        Set<String> expected = Set.of(
                "",
                "/account",
                "/account/password",
                "/account/profile",
                "/account/set-password",
                "/manager/course-detail",
                "/manager/course-status",
                "/admin/dashboard",
                "/admin/lesson-review",
                "/admin/reset-password",
                "/admin/setting-detail",
                "/admin/setting-status",
                "/admin/settings",
                "/admin/user-detail",
                "/admin/user-status",
                "/admin/users",
                "/api/payment/sepay-webhook",
                "/api/payment/vnpay-ipn",
                "/auth/forgot-password",
                "/auth/forgot-password/verify",
                "/auth/login",
                "/auth/logout",
                "/auth/oauth/complete-profile",
                "/auth/oauth/github",
                "/auth/oauth/github/callback",
                "/auth/oauth/google",
                "/auth/oauth/google/callback",
                "/auth/register",
                "/auth/resend-code",
                "/auth/reset-password",
                "/auth/verify-email",
                "/course-detail",
                "/courses",
                "/courses/register",
                "/enroll",
                "/enrollment",
                "/error",
                "/expert/dashboard",
                "/home",
                "/index",
                "/learn/complete",
                "/learn/course",
                "/learn/lesson",
                "/lessons/manage",
                "/lessons/upload",
                "/manager/courses",
                "/manager/dashboard",
                "/my-enrollments",
                "/my-payments",
                "/notifications",
                "/notifications/read",
                "/notifications/read-all",
                "/payment/checkout",
                "/payment/history",
                "/payment/vnpay-return",
                "/profile",
                "/questions/detail",
                "/questions/manage",
                "/quiz",
                "/quiz/detail",
                "/quiz/history",
                "/quiz/info",
                "/quiz/manage",
                "/quiz/submit",
                "/quiz/take",
                "/quiz/view"
        );
        Set<String> actual = new HashSet<>();
        try (var files = Files.list(Path.of("src/main/java/com/learnhub/controller"))) {
            for (Path file : files.filter(p -> p.toString().endsWith("Servlet.java")).toList()) {
                String className = file.getFileName().toString().replace(".java", "");
                WebServlet mapping = Class.forName("com.learnhub.controller." + className).getAnnotation(WebServlet.class);
                assertNotNull(mapping, className);
                for (String route : mapping.urlPatterns()) {
                    assertTrue(actual.add(route), "Duplicate URL mapping: " + route);
                }
            }
        }
        assertEquals(expected, actual);
    }
}
