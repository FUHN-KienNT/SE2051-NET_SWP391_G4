package com.learnhub.util;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;

import java.net.URI;
import java.util.Locale;

/** Chooses an in-app destination after authentication. */
public final class PostLoginNavigation {
    private PostLoginNavigation() {}

    public static String dashboardPath(User user) {
        String role = user == null ? null : user.getRoleCode();
        if (AppConstants.Role.ADMIN.equalsIgnoreCase(role)) return "/admin/dashboard";
        if (AppConstants.Role.MANAGER.equalsIgnoreCase(role)) return "/manager/dashboard";
        if (AppConstants.Role.EXPERT.equalsIgnoreCase(role)) return "/expert/dashboard";
        if (AppConstants.Role.STUDENT.equalsIgnoreCase(role)) return "/my-enrollments";
        return "/home";
    }

    public static String destination(User user, String requested, String contextPath) {
        String fallback = contextPath + dashboardPath(user);
        if (user != null && AppConstants.Role.MANAGER.equalsIgnoreCase(user.getRoleCode())) return fallback;
        String safe = safeLocalPath(requested, contextPath);
        if (safe == null) return fallback;

        String path = URI.create(safe).getPath().substring(contextPath.length());
        if (path.isEmpty() || path.equals("/") || path.equals("/home") || path.equals("/index")
                || isUnder(path, "/auth") || !canVisit(user, path)) return fallback;
        return safe;
    }

    public static String safeLocalPath(String requested, String contextPath) {
        if (requested == null || requested.isBlank() || requested.indexOf('\\') >= 0
                || requested.chars().anyMatch(Character::isISOControl)) return null;
        try {
            URI uri = URI.create(requested);
            String path = uri.getRawPath();
            if (uri.isAbsolute() || uri.getRawAuthority() != null || uri.getRawFragment() != null
                    || path == null || !path.startsWith("/") || path.startsWith("//")
                    || path.toLowerCase(Locale.ROOT).matches(".*%(?:2f|5c).*")) return null;
            for (String segment : path.split("/")) {
                if (segment.equals(".") || segment.equals("..") || segment.toLowerCase(Locale.ROOT).matches("%2e.*")) return null;
            }
            if (contextPath.isEmpty() || path.equals(contextPath) || path.startsWith(contextPath + "/")) return requested;
            return contextPath + requested;
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private static boolean canVisit(User user, String path) {
        String role = user == null ? null : user.getRoleCode();
        boolean admin = AppConstants.Role.ADMIN.equalsIgnoreCase(role);
        boolean manager = AppConstants.Role.MANAGER.equalsIgnoreCase(role);
        boolean expert = AppConstants.Role.EXPERT.equalsIgnoreCase(role);
        boolean student = AppConstants.Role.STUDENT.equalsIgnoreCase(role);

        if (isUnder(path, "/manager/courses") || isUnder(path, "/manager/course-status")
                || isUnder(path, "/manager/course-detail")) return manager || expert;
        if (isUnder(path, "/manager")) return manager;
        if (isUnder(path, "/admin/dashboard") || isUnder(path, "/admin/users")
                || isUnder(path, "/admin/user-detail") || isUnder(path, "/admin/user-status")
                || isUnder(path, "/admin/reset-password") || isUnder(path, "/admin/settings")
                || isUnder(path, "/admin/setting-detail") || isUnder(path, "/admin/setting-status")) return admin;
        if (isUnder(path, "/admin/lesson-review")) return manager;
        if (isUnder(path, "/admin")) return admin || manager;
        if (isUnder(path, "/expert") || isUnder(path, "/lessons")
                || isUnder(path, "/questions") || isUnder(path, "/quiz/manage")
                || isUnder(path, "/quiz/detail")) return expert;
        if (isUnder(path, "/my-enrollments") || isUnder(path, "/learn")
                || isUnder(path, "/learning-process") || isUnder(path, "/enroll")
                || isUnder(path, "/enrollment")) return student;
        return true;
    }

    private static boolean isUnder(String path, String prefix) {
        return path.equals(prefix) || path.startsWith(prefix + "/");
    }
}
