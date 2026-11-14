package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.User;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service managing Course Registrations for Managers and Admins.
 * Enforces Controller -> Service -> DAO clean architecture.
 */
public class RegistrationService {
    private static final Logger LOGGER = Logger.getLogger(RegistrationService.class.getName());

    private final RegistrationDAO registrationDAO;
    private final UserDAO userDAO;
    private final CourseDAO courseDAO;

    public RegistrationService() {
        this.registrationDAO = new RegistrationDAO();
        this.userDAO = new UserDAO();
        this.courseDAO = new CourseDAO();
    }

    public RegistrationService(RegistrationDAO registrationDAO, UserDAO userDAO, CourseDAO courseDAO) {
        this.registrationDAO = registrationDAO;
        this.userDAO = userDAO;
        this.courseDAO = courseDAO;
    }

    public record RegistrationPageData(
            List<Registration> list,
            int totalCount,
            int totalPages,
            int currentPage,
            int pageSize,
            Map<String, Object> stats
    ) {}

    public RegistrationPageData getRegistrations(String search, String status, String paymentStatus, int page, int pageSize) {
        int currentPage = Math.max(1, page);
        int validPageSize = Math.max(1, Math.min(100, pageSize));
        int offset = (currentPage - 1) * validPageSize;

        List<Registration> list = registrationDAO.findRegistrations(search, status, paymentStatus, offset, validPageSize);
        int totalCount = registrationDAO.countRegistrations(search, status, paymentStatus);
        int totalPages = totalCount > 0 ? (int) Math.ceil((double) totalCount / validPageSize) : 1;
        Map<String, Object> stats = registrationDAO.getRegistrationStats(search, status, paymentStatus);

        return new RegistrationPageData(list, totalCount, totalPages, currentPage, validPageSize, stats);
    }

    public record RegistrationDetailData(
            Registration registration,
            User student,
            Course course
    ) {}

    public RegistrationDetailData getRegistrationDetail(UUID id) {
        if (id == null) return null;
        Registration reg = registrationDAO.findById(id);
        if (reg == null) return null;

        User student = userDAO.findById(reg.getUserId());
        Course course = courseDAO.findById(reg.getCourseId());

        return new RegistrationDetailData(reg, student, course);
    }

    public boolean updateRegistrationStatus(UUID id, String newStatus, String newPaymentStatus) {
        if (id == null) return false;
        try {
            if (newStatus == null || newStatus.trim().isEmpty()) {
                Registration existing = registrationDAO.findById(id);
                if ("failed".equalsIgnoreCase(newPaymentStatus)) {
                    newStatus = "cancelled";
                } else if (existing != null && "completed".equalsIgnoreCase(existing.getStatus())) {
                    newStatus = "completed";
                } else {
                    newStatus = "enrolled";
                }
            }
            return registrationDAO.updateRegistrationStatus(id, newStatus, newPaymentStatus);
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Error updating registration status: " + ex.getMessage(), ex);
            return false;
        }
    }
}