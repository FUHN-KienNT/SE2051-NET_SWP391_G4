package com.learnhub.constant;

/**
 * System-wide constants for LearnHub.
 * Standardizes statuses, roles, session keys, and pagination defaults.
 */
public final class AppConstants {

    private AppConstants() {
        // Prevent instantiation
    }

    // =========================================================================
    // 1. User & Account Statuses (matches schema user_status ENUM)
    // =========================================================================
    public static final class UserStatus {
        private UserStatus() {}
        public static final String ACTIVE = "active";
        public static final String INACTIVE = "inactive";
        public static final String BANNED = "banned";
    }

    // =========================================================================
    // 2. Course Statuses (matches schema course_status ENUM)
    // =========================================================================
    public static final class CourseStatus {
        private CourseStatus() {}
        public static final String DRAFT = "draft";
        public static final String PUBLISHED = "published";
        public static final String ARCHIVED = "archived";
    }

    // =========================================================================
    // 3. Lesson Statuses (matches schema lesson_status ENUM)
    // =========================================================================
    public static final class LessonStatus {
        private LessonStatus() {}
        public static final String DRAFT = "draft";
        public static final String PUBLISHED = "published";
        public static final String ARCHIVED = "archived";
        public static final String DECLINE = "decline";
    }

    // =========================================================================
    // 4. Quiz Statuses (matches schema quiz_status ENUM)
    // =========================================================================
    public static final class QuizStatus {
        private QuizStatus() {}
        public static final String PUBLISHED = "published";
        public static final String DRAFT = "draft";
        public static final String HIDDEN = "hidden";
    }

    // =========================================================================
    // 5. Course Registration Statuses (matches schema registration_status ENUM)
    // =========================================================================
    public static final class RegistrationStatus {
        private RegistrationStatus() {}
        public static final String ENROLLED = "enrolled";
        public static final String COMPLETED = "completed";
        public static final String CANCELLED = "cancelled";
    }

    // =========================================================================
    // 6. Payment Statuses (matches schema payment_status ENUM)
    // =========================================================================
    public static final class PaymentStatus {
        private PaymentStatus() {}
        public static final String PENDING = "pending";
        public static final String PAID = "paid";
        public static final String FAILED = "failed";
        public static final String REFUNDED = "refunded";
    }

    // =========================================================================
    // 7. Learning Progress Statuses (matches schema learning_status ENUM)
    // =========================================================================
    public static final class LearningStatus {
        private LearningStatus() {}
        public static final String NOT_STARTED = "not_started";
        public static final String IN_PROGRESS = "in_progress";
        public static final String COMPLETED = "completed";
    }

    // =========================================================================
    // 8. Notification Statuses (matches schema notification_status ENUM)
    // =========================================================================
    public static final class NotificationStatus {
        private NotificationStatus() {}
        public static final String UNREAD = "unread";
        public static final String READ = "read";
        public static final String SENT = "sent";
        public static final String FAILED = "failed";
    }

    // =========================================================================
    // 9. Security Roles (matches RBAC settings & AuthorizationFilter)
    // =========================================================================
    public static final class Role {
        private Role() {}
        public static final String ADMIN = "ROLE_ADMIN";
        public static final String MANAGER = "ROLE_MANAGER";
        public static final String EXPERT = "ROLE_EXPERT";
        public static final String STUDENT = "ROLE_STUDENT";
    }

    // =========================================================================
    // 8. Session & Request Attributes
    // =========================================================================
    public static final class SessionKey {
        private SessionKey() {}
        public static final String CURRENT_USER = "currentUser";
        public static final String FLASH_MESSAGE = "flashMessage";
        public static final String FLASH_ERROR = "flashError";
    }

    // =========================================================================
    // 9. Pagination Defaults
    // =========================================================================
    public static final class Pagination {
        private Pagination() {}
        public static final int DEFAULT_PAGE = 1;
        public static final int DEFAULT_PAGE_SIZE = 10;
        public static final int COURSE_PAGE_SIZE = 9;
        public static final int EXPERT_COURSE_PAGE_SIZE = 8;
    }
}
