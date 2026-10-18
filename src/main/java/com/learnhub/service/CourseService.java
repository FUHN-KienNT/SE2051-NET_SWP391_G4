package com.learnhub.service;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.dto.CourseDTO;
import com.learnhub.dto.RegistrationDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;

import java.util.ArrayList;
import java.util.List;
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

    public CourseService() {
        this.courseDAO = new CourseDAO();
        this.registrationDAO = new RegistrationDAO();
        this.settingDAO = new SettingDAO();
        this.userDAO = new UserDAO();
    }

    public CourseService(CourseDAO courseDAO, RegistrationDAO registrationDAO, SettingDAO settingDAO, UserDAO userDAO) {
        this.courseDAO = courseDAO;
        this.registrationDAO = registrationDAO;
        this.settingDAO = settingDAO;
        this.userDAO = userDAO;
    }

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

    public List<CourseDTO> getPopularPublicCourses(UUID excludedCourseId, int limit) {
        List<CourseDTO> dtos = new ArrayList<>();
        for (Course course : courseDAO.findPopularPublishedCourses(excludedCourseId, limit)) {
            dtos.add(toCourseDTO(course));
        }
        return dtos;
    }

    private CourseDTO toCourseDTO(Course course) {
        CourseDTO dto = new CourseDTO(
                course.getId(), course.getTitle(), course.getDescription(), course.getPrice(),
                course.getThumbnailUrl(), course.getStatus(), course.getCategoryId(),
                course.getCategoryName(), course.getExpertName()
        );
        dto.setModuleCount(course.getModuleCount());
        dto.setLessonCount(course.getLessonCount());
        return dto;
    }

    public int countPublicCourses(String search, UUID categoryId) {
        return courseDAO.countPublishedCourses(search, categoryId);
    }

    public Course getCourseDetailWithCurriculum(UUID courseId) {
        Course c = courseDAO.findCourseWithModulesAndLessons(courseId);
        if (c != null && c.getModules() != null) {
            com.learnhub.dao.QuizDAO quizDAO = new com.learnhub.dao.QuizDAO();
            for (com.learnhub.entity.Module m : c.getModules()) {
                m.setQuizzes(quizDAO.findByModuleId(m.getId()));
            }
        }
        return c;
    }

    public Course getPublishedCourseCurriculum(UUID courseId) {
        Course course = getCourseDetailWithCurriculum(courseId);
        if (course != null && course.getModules() != null) {
            int lessonCount = 0;
            for (com.learnhub.entity.Module module : course.getModules()) {
                module.setLessons(module.getLessons().stream()
                        .filter(lesson -> AppConstants.LessonStatus.PUBLISHED.equals(lesson.getPublicationStatus()))
                        .toList());
                lessonCount += module.getLessons().size();
            }
            course.setLessonCount(lessonCount);
        }
        return course;
    }

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

    public Registration getRegistrationDetailById(UUID id) {
        return registrationDAO.findById(id);
    }

    public boolean updateRegistrationStatus(UUID id, String status, String paymentStatus) {
        return registrationDAO.updateRegistrationStatus(id, status, paymentStatus);
    }

    public List<Setting> getActiveCategories() {
        return settingDAO.findActiveCategories();
    }

    public record AssignedCourseNavigation(List<Course> courses, String search,
                                           int page, int totalPages, int totalCourses) {}

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

    public List<Course> getAssignedCourses(UUID expertId, int page, int pageSize) {
        return getAssignedCourses(expertId, page, pageSize, "");
    }

    public List<Course> getAssignedCourses(UUID expertId, int page, int pageSize, String search) {
        page = Math.max(1, page);
        pageSize = pageSize < 1 ? 10 : pageSize;
        String keyword = search == null ? "" : search.strip();
        return courseDAO.findByExpertId(expertId, (page - 1) * pageSize, pageSize, keyword);
    }
    public int countAssignedCourses(UUID expertId, String status, String search) {
        String keyword = search == null ? "" : search.strip();
        return courseDAO.countByExpertId(expertId, status, keyword);
    }

    public int countAssignedCourses(UUID expertId) {
        return courseDAO.countByExpertId(expertId);
    }

    public int countAssignedCourses(UUID expertId, String status) {
        return courseDAO.countByExpertId(expertId, status);
    }

    public List<Registration> getMyEnrollments(UUID userId) {
        return registrationDAO.findByUserId(userId);
    }

    public List<Setting> getPaymentMethods() {
        List<Setting> all = settingDAO.findByType("payment_method");
        List<Setting> result = new ArrayList<>();
        Setting vnpay = null;
        Setting sepay = null;

        for (Setting s : all) {
            if ("vnpay".equalsIgnoreCase(s.getCode())) {
                vnpay = s;
            } else if ("sepay".equalsIgnoreCase(s.getCode()) || "banking".equalsIgnoreCase(s.getCode())) {
                sepay = s;
            }
        }

        if (vnpay != null) {
            result.add(vnpay);
        } else {
            result.add(new Setting(
                    UUID.fromString("b0000000-0000-0000-0000-000000000011"),
                    "payment_method", "vnpay", "Cổng thanh toán VNPAY",
                    "Thanh toán qua quét mã VNPAY-QR, Thẻ ATM nội địa hoặc Internet Banking",
                    true, 1
            ));
        }

        if (sepay != null) {
            if ("banking".equalsIgnoreCase(sepay.getCode())) {
                sepay.setCode("sepay");
                sepay.setName("Cổng thanh toán SePay (VietQR)");
                sepay.setDescription("Chuyển khoản ngân hàng tự động 24/7 qua mã VietQR SePay");
            }
            result.add(sepay);
        } else {
            result.add(new Setting(
                    UUID.fromString("b0000000-0000-0000-0000-000000000013"),
                    "payment_method", "sepay", "Cổng thanh toán SePay (VietQR)",
                    "Chuyển khoản ngân hàng tự động 24/7 qua mã VietQR SePay",
                    true, 2
            ));
        }

        return result;
    }

    public List<Course> getCoursesForManagement(String search, UUID categoryId, String status, String priceType, String sortBy, String sortOrder, int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;
        return courseDAO.findAllCoursesForManagement(search, categoryId, status, priceType, sortBy, sortOrder, offset, pageSize);
    }

    public int countCoursesForManagement(String search, UUID categoryId, String status, String priceType) {
        return courseDAO.countAllCoursesForManagement(search, categoryId, status, priceType);
    }

    public boolean updateCourseStatus(UUID courseId, String status) {
        if (courseId == null || status == null) return false;
        return courseDAO.updateStatus(courseId, status);
    }

    public boolean createCourse(Course course) {
        if (course == null || course.getTitle() == null || course.getTitle().trim().isEmpty()) {
            return false;
        }
        if (course.getId() == null) {
            course.setId(UUID.randomUUID());
        }
        return courseDAO.insert(course);
    }

    public boolean updateCourse(Course course) {
        if (course == null || course.getId() == null) return false;
        return courseDAO.update(course);
    }

    public Course getCourseById(UUID courseId) {
        if (courseId == null) return null;
        return courseDAO.findById(courseId);
    }

    public List<User> getAllInstructors() {
        return userDAO.findInstructors();
    }
}
