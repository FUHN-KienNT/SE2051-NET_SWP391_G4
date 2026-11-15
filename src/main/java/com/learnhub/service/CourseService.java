package com.learnhub.service;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.QuizDAO;
import com.learnhub.dto.CourseStatusCounts;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.dto.CourseDTO;
import com.learnhub.dto.RegistrationDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Module;
import com.learnhub.entity.Quiz;
import com.learnhub.entity.Registration;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.UUID;

/**
 * Service handling Course browsing, registration, curriculum logic,
 * and Course Management for Administrators & Instructors.
 */
public class CourseService {

    private final CourseDAO courseDAO;
    private final RegistrationDAO registrationDAO;
    private final SettingDAO settingDAO;
    private final UserDAO userDAO;

    /**
     * Creates an instance with the supplied values.
     */
    public CourseService() {
        this.courseDAO = new CourseDAO();
        this.registrationDAO = new RegistrationDAO();
        this.settingDAO = new SettingDAO();
        this.userDAO = new UserDAO();
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param courseDAO the course dao
     * @param registrationDAO the registration dao
     * @param settingDAO the setting dao
     * @param userDAO the user dao
     */
    public CourseService(CourseDAO courseDAO, RegistrationDAO registrationDAO, SettingDAO settingDAO, UserDAO userDAO) {
        this.courseDAO = courseDAO;
        this.registrationDAO = registrationDAO;
        this.settingDAO = settingDAO;
        this.userDAO = userDAO;
    }

    /**
     * Searches for public courses.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @param page the requested page number
     * @param pageSize the maximum number of items per page
     * @return the result of search public courses
     */
    public List<CourseDTO> searchPublicCourses(String search, UUID categoryId, int page, int pageSize) {
        if (page < 1) {
            page = 1;
        }
        if (pageSize < 1) {
            pageSize = 9;
        }
        int offset = (page - 1) * pageSize;

        List<Course> courses = courseDAO.findPublishedCourses(search, categoryId, offset, pageSize);

        List<CourseDTO> dtos = new ArrayList<>();
        for (Course c : courses) {
            dtos.add(toCourseDTO(c));
        }
        return dtos;
    }

    /**
     * Returns popular public courses.
     *
     * @param excludedCourseId the excluded course id identifier
     * @param limit the limit
     * @return the popular public courses
     */
    public List<CourseDTO> getPopularPublicCourses(UUID excludedCourseId, int limit) {
        List<CourseDTO> dtos = new ArrayList<>();
        for (Course course : courseDAO.findPopularPublishedCourses(excludedCourseId, limit)) {
            dtos.add(toCourseDTO(course));
        }
        return dtos;
    }

    /**
     * To course dto.
     *
     * @param course the course
     * @return the result of to course dto
     */
    private CourseDTO toCourseDTO(Course course) {
        CourseDTO dto = new CourseDTO(
                course.getId(), course.getTitle(), course.getDescription(), course.getPrice(),
                course.getThumbnailUrl(), course.getStatus(), course.getCategoryId(),
                course.getCategoryName(), course.getExpertName()
        );
        dto.setModuleCount(course.getModuleCount());
        dto.setLessonCount(course.getLessonCount());
        dto.setCategoryStatus(course.getCategoryStatus());
        return dto;
    }

    /**
     * Counts public courses.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @return the number of public courses
     */
    public int countPublicCourses(String search, UUID categoryId) {
        return courseDAO.countPublishedCourses(search, categoryId);
    }

    /**
     * Returns course detail with curriculum.
     *
     * @param courseId the course id identifier
     * @return the course detail with curriculum
     */
    public Course getCourseDetailWithCurriculum(UUID courseId) {
        Course course = courseDAO.findCourseWithModulesAndLessons(courseId);
        if (course == null || course.getModules() == null) return course;

        Map<UUID, Module> modules = new HashMap<>();
        for (Module module : course.getModules()) {
            module.setQuizzes(new ArrayList<>());
            modules.put(module.getId(), module);
        }
        for (Quiz quiz : new QuizDAO().findByCourseId(courseId)) {
            Module module = modules.get(quiz.getModuleId());
            if (module != null) module.getQuizzes().add(quiz);
        }
        return course;
    }

    /**
     * Returns published course curriculum.
     *
     * @param courseId the course id identifier
     * @return the published course curriculum
     */
    public Course getPublishedCourseCurriculum(UUID courseId) {
        Course course = getCourseDetailWithCurriculum(courseId);
        if (course != null && course.getModules() != null) {
            course.setModules(course.getModules().stream().filter(module -> !module.isHidden()).toList());
            course.setModuleCount(course.getModules().size());
            int lessonCount = 0;
            for (Module module : course.getModules()) {
                module.setLessons(module.getLessons().stream()
                        .filter(lesson -> AppConstants.LessonStatus.PUBLISHED.equals(lesson.getPublicationStatus()))
                        .toList());
                lessonCount += module.getLessons().size();
            }
            course.setLessonCount(lessonCount);
        }
        return course;
    }

    /**
     * Process course registration.
     *
     * @param userId the user id identifier
     * @param courseId the course id identifier
     * @param paymentMethodId the payment method id identifier
     * @return the result of process course registration
     */
    public Registration processCourseRegistration(UUID userId, UUID courseId, UUID paymentMethodId) {
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            return null;
        }

        Registration existing = registrationDAO.findByUserAndCourse(userId, courseId);
        if (existing != null) {
            if ("pending".equalsIgnoreCase(existing.getPaymentStatus())) {
                existing.setPaymentMethodId(paymentMethodId);
                // Keep same registration, allow proceed to checkout
                return existing;
            }
            return existing;
        }

        Registration reg = new Registration();
        reg.setId(UUID.randomUUID());
        reg.setUserId(userId);
        reg.setCourseId(courseId);
        reg.setAmount(course.getPrice());
        reg.setPaymentMethodId(paymentMethodId);
        reg.setStatus("enrolled");
        reg.setPaymentStatus("pending");
        reg.setProgressPercent((short) 0);

        if (registrationDAO.insertRegistration(reg)) {
            return reg;
        }
        return null;
    }

    /**
     * Searches for registrations.
     *
     * @param search the search
     * @param status the status
     * @param page the requested page number
     * @param pageSize the maximum number of items per page
     * @return the result of search registrations
     */
    public List<RegistrationDTO> searchRegistrations(String search, String status, int page, int pageSize) {
        if (page < 1) {
            page = 1;
        }
        if (pageSize < 1) {
            pageSize = 10;
        }
        int offset = (page - 1) * pageSize;

        List<Registration> list = registrationDAO.findRegistrations(search, status, offset, pageSize);

        List<RegistrationDTO> dtos = new ArrayList<>();
        for (Registration r : list) {
            RegistrationDTO dto = new RegistrationDTO();
            dto.setId(r.getId());
            dto.setUserId(r.getUserId());
            dto.setUserName(r.getUserName());
            dto.setUserEmail(r.getUserEmail());
            dto.setCourseId(r.getCourseId());
            dto.setCourseTitle(r.getCourseTitle());
            dto.setAmount(r.getAmount());
            dto.setPaymentStatus(r.getPaymentStatus());
            dto.setStatus(r.getStatus());
            dto.setProgressPercent(r.getProgressPercent());
            dto.setEnrolledAt(r.getEnrolledAt());
            dto.setPaymentMethod(r.getPaymentMethodName());
            dto.setTransactionId(r.getTransactionId());
            dtos.add(dto);
        }
        return dtos;
    }

    /**
     * Returns registration detail by id.
     *
     * @param id the id identifier
     * @return the registration detail by id
     */
    public Registration getRegistrationDetailById(UUID id) {
        return registrationDAO.findById(id);
    }

    /**
     * Update registration status.
     *
     * @param id the id identifier
     * @param status the status
     * @param paymentStatus the payment status
     * @return true when the condition holds; false otherwise
     */
    public boolean updateRegistrationStatus(UUID id, String status, String paymentStatus) {
        return registrationDAO.updateRegistrationStatus(id, status, paymentStatus);
    }

    /**
     * Returns active categories.
     *
     * @return the active categories
     */
    public List<Setting> getActiveCategories() {
        return settingDAO.findActiveCategories();
    }

    public record AssignedCourseNavigation(List<Course> courses, String search,
                                           int page, int totalPages, int totalCourses) {}

    public record ExpertDashboardData(List<Course> courses, int page, int totalPages,
                                     CourseStatusCounts counts, String search) {}

    /**
     * Returns expert dashboard.
     *
     * @param expertId the expert id identifier
     * @param page the requested page number
     * @param pageSize the maximum number of items per page
     * @param search the search
     * @return the expert dashboard
     */
    public ExpertDashboardData getExpertDashboard(UUID expertId, int page, int pageSize, String search) {
        String keyword = search == null ? "" : search.strip();
        pageSize = pageSize < 1 ? 8 : pageSize;
        var counts = courseDAO.countAssignedByStatus(expertId, keyword);
        int totalPages = Math.max(1, (int) Math.ceil(counts.total() / (double) pageSize));
        page = Math.max(1, Math.min(page, totalPages));
        return new ExpertDashboardData(getAssignedCourses(expertId, page, pageSize, keyword),
                page, totalPages, counts, keyword);
    }

    /**
     * Returns assigned course options.
     *
     * @param expertId the expert id identifier
     * @return the assigned course options
     */
    public List<Course> getAssignedCourseOptions(UUID expertId) {
        return courseDAO.findAssignedCourseOptions(expertId);
    }

    /**
     * Returns assigned course navigation.
     *
     * @param expertId the expert id identifier
     * @param search the search
     * @param page the requested page number
     * @return the assigned course navigation
     */
    public AssignedCourseNavigation getAssignedCourseNavigation(UUID expertId, String search, int page) {
        String keyword = search == null ? "" : search.strip();
        if (expertId == null) return new AssignedCourseNavigation(List.of(), keyword, 1, 1, 0);
        int pageSize = 8;
        int total = countAssignedCourses(expertId, null, keyword);
        int totalPages = Math.max(1, (int) Math.ceil(total / (double) pageSize));
        page = Math.max(1, Math.min(page, totalPages));
        List<Course> courses = getAssignedCourses(expertId, page, pageSize, keyword);
        return new AssignedCourseNavigation(courses, keyword, page, totalPages, total);
    }

    /**
     * Returns assigned courses.
     *
     * @param expertId the expert id identifier
     * @param page the requested page number
     * @param pageSize the maximum number of items per page
     * @return the assigned courses
     */
    public List<Course> getAssignedCourses(UUID expertId, int page, int pageSize) {
        return getAssignedCourses(expertId, page, pageSize, "");
    }

    /**
     * Returns assigned courses.
     *
     * @param expertId the expert id identifier
     * @param page the requested page number
     * @param pageSize the maximum number of items per page
     * @param search the search
     * @return the assigned courses
     */
    public List<Course> getAssignedCourses(UUID expertId, int page, int pageSize, String search) {
        page = Math.max(1, page);
        pageSize = pageSize < 1 ? 10 : pageSize;
        String keyword = search == null ? "" : search.strip();
        return courseDAO.findByExpertId(expertId, (page - 1) * pageSize, pageSize, keyword);
    }
    /**
     * Counts assigned courses.
     *
     * @param expertId the expert id identifier
     * @param status the status
     * @param search the search
     * @return the number of assigned courses
     */
    public int countAssignedCourses(UUID expertId, String status, String search) {
        String keyword = search == null ? "" : search.strip();
        return courseDAO.countByExpertId(expertId, status, keyword);
    }

    /**
     * Counts assigned courses.
     *
     * @param expertId the expert id identifier
     * @return the number of assigned courses
     */
    public int countAssignedCourses(UUID expertId) {
        return courseDAO.countByExpertId(expertId);
    }

    /**
     * Counts assigned courses.
     *
     * @param expertId the expert id identifier
     * @param status the status
     * @return the number of assigned courses
     */
    public int countAssignedCourses(UUID expertId, String status) {
        return courseDAO.countByExpertId(expertId, status);
    }

    /**
     * Returns my enrollments.
     *
     * @param userId the user id identifier
     * @return the my enrollments
     */
    public List<Registration> getMyEnrollments(UUID userId) {
        return registrationDAO.findByUserId(userId);
    }

    /**
     * Returns payment methods.
     *
     * @return the payment methods
     */
    public List<Setting> getPaymentMethods() {
        List<Setting> activeList = settingDAO.findByType("payment_method");
        int totalConfigured = settingDAO.countSettings(null, "payment_method", null);

        // If payment methods are configured in the database, strictly respect their active/inactive status
        if (totalConfigured > 0) {
            List<Setting> result = new ArrayList<>();
            for (Setting s : activeList) {
                if ("banking".equalsIgnoreCase(s.getCode())) {
                    s.setCode("sepay");
                    if (s.getName() == null || s.getName().isBlank()) {
                        s.setName("Cổng thanh toán SePay (VietQR)");
                    }
                    if (s.getDescription() == null || s.getDescription().isBlank()) {
                        s.setDescription("Chuyển khoản ngân hàng tự động 24/7 qua mã VietQR SePay");
                    }
                }
                result.add(s);
            }
            return result;
        }

        // Fallback default methods only when the database has zero configured payment methods (unseeded DB)
        List<Setting> fallbackResult = new ArrayList<>();
        fallbackResult.add(new Setting(
                UUID.fromString("b0000000-0000-0000-0000-000000000011"),
                "payment_method", "vnpay", "Cổng thanh toán VNPAY",
                "Thanh toán qua quét mã VNPAY-QR, Thẻ ATM nội địa hoặc Internet Banking",
                true, 1
        ));
        fallbackResult.add(new Setting(
                UUID.fromString("b0000000-0000-0000-0000-000000000013"),
                "payment_method", "sepay", "Cổng thanh toán SePay (VietQR)",
                "Chuyển khoản ngân hàng tự động 24/7 qua mã VietQR SePay",
                true, 2
        ));
        return fallbackResult;
    }

    /**
     * Finds an active payment method by its UUID identifier.
     *
     * @param paymentMethodId UUID of the payment method
     * @return Setting entity if active and available, or null if inactive or not found
     */
    public Setting getActivePaymentMethodById(UUID paymentMethodId) {
        if (paymentMethodId == null) {
            return null;
        }
        for (Setting method : getPaymentMethods()) {
            if (paymentMethodId.equals(method.getId())) {
                return method;
            }
        }
        return null;
    }

    /**
     * Returns courses for management.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @param status the status
     * @param priceType the price type
     * @param sortBy the sort by
     * @param sortOrder the sort order
     * @param page the requested page number
     * @param pageSize the maximum number of items per page
     * @return the courses for management
     */
    public List<Course> getCoursesForManagement(String search, UUID categoryId, String status, String priceType, String sortBy, String sortOrder, int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;
        return courseDAO.findAllCoursesForManagement(search, categoryId, status, priceType, sortBy, sortOrder, offset, pageSize);
    }

    /**
     * Counts courses for management.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @param status the status
     * @param priceType the price type
     * @return the number of courses for management
     */
    public int countCoursesForManagement(String search, UUID categoryId, String status, String priceType) {
        return courseDAO.countAllCoursesForManagement(search, categoryId, status, priceType);
    }

    /**
     * Update course status.
     *
     * @param courseId the course id identifier
     * @param status the status
     * @return true when the condition holds; false otherwise
     */
    public boolean updateCourseStatus(UUID courseId, String status) {
        if (courseId == null || status == null) return false;
        return courseDAO.updateStatus(courseId, status);
    }

    /**
     * Create course.
     *
     * @param course the course
     * @return true when the condition holds; false otherwise
     */
    public boolean createCourse(Course course) {
        if (course == null || course.getTitle() == null || course.getTitle().trim().isEmpty()) {
            return false;
        }
        if (course.getId() == null) {
            course.setId(UUID.randomUUID());
        }
        return courseDAO.insert(course);
    }

    /**
     * Update course.
     *
     * @param course the course
     * @return true when the condition holds; false otherwise
     */
    public boolean updateCourse(Course course) {
        if (course == null || course.getId() == null) return false;
        return courseDAO.update(course);
    }

    /**
     * Returns course by id.
     *
     * @param courseId the course id identifier
     * @return the course by id
     */
    public Course getCourseById(UUID courseId) {
        if (courseId == null) return null;
        return courseDAO.findById(courseId);
    }

    /**
     * Returns all instructors.
     *
     * @return the all instructors
     */
    public List<User> getAllInstructors() {
        return userDAO.findInstructors();
    }
}
