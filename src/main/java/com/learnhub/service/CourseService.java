package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.dto.CourseDTO;
import com.learnhub.dto.PageResult;
import com.learnhub.dto.RegistrationDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.Setting;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Service handling Course browsing, registration, and curriculum logic.
 * Implements methods specified in SDS Course Browsing Diagram (5.1, 5.2, 5.3):
 * - searchPublicCourses()
 * - getCourseDetailWithCurriculum()
 * - processCourseRegistration()
 * - searchRegistrations()
 * - getRegistrationDetailById()
 * - updateRegistrationStatus()
 */
public class CourseService {
    private final CourseDAO courseDAO;
    private final RegistrationDAO registrationDAO;
    private final SettingDAO settingDAO;

    public CourseService() {
        this.courseDAO = new CourseDAO();
        this.registrationDAO = new RegistrationDAO();
        this.settingDAO = new SettingDAO();
    }

    public CourseService(CourseDAO courseDAO, RegistrationDAO registrationDAO, SettingDAO settingDAO) {
        this.courseDAO = courseDAO;
        this.registrationDAO = registrationDAO;
        this.settingDAO = settingDAO;
    }

    public PageResult<CourseDTO> searchPublicCourses(String search, UUID categoryId, int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 9;
        int offset = (page - 1) * pageSize;

        List<Course> courses = courseDAO.findPublishedCourses(search, categoryId, offset, pageSize);
        int total = courseDAO.countPublishedCourses(search, categoryId);

        List<CourseDTO> dtos = new ArrayList<>();
        for (Course c : courses) {
            CourseDTO dto = new CourseDTO(
                c.getId(), c.getTitle(), c.getDescription(), c.getPrice(),
                c.getThumbnailUrl(), c.getStatus(), c.getCategoryId(),
                c.getCategoryName(), c.getExpertName()
            );
            dto.setModuleCount(c.getModuleCount());
            dto.setLessonCount(c.getLessonCount());
            dtos.add(dto);
        }
        return new PageResult<>(dtos, page, pageSize, total);
    }

    public Course getCourseDetailWithCurriculum(UUID courseId) {
        return courseDAO.findCourseWithModulesAndLessons(courseId);
    }

    public Registration processCourseRegistration(UUID userId, UUID courseId, UUID paymentMethodId) {
        Course course = courseDAO.findById(courseId);
        if (course == null) return null;

        Registration existing = registrationDAO.findByUserAndCourse(userId, courseId);
        if (existing != null) {
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

    public PageResult<RegistrationDTO> searchRegistrations(String search, String status, int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        List<Registration> list = registrationDAO.findRegistrations(search, status, offset, pageSize);
        int total = registrationDAO.countRegistrations(search, status);

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
        return new PageResult<>(dtos, page, pageSize, total);
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
}
