package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.EnrollmentDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * Service handling student course enrollment lifecycle.
 * Implements methods specified in Enrollment & Payment Class Diagram (SDS 1.1):
 * - createEnrollment()
 * - activateEnrollment()
 * - cancelUnpaidEnrollment()
 */
public class EnrollmentService {
    private final EnrollmentDAO enrollmentDAO;
    private final RegistrationDAO registrationDAO;
    private final CourseDAO courseDAO;

    public EnrollmentService() {
        this.enrollmentDAO = new EnrollmentDAO();
        this.registrationDAO = new RegistrationDAO();
        this.courseDAO = new CourseDAO();
    }

    public EnrollmentService(EnrollmentDAO enrollmentDAO, RegistrationDAO registrationDAO, CourseDAO courseDAO) {
        this.enrollmentDAO = enrollmentDAO;
        this.registrationDAO = registrationDAO;
        this.courseDAO = courseDAO;
    }

    public Registration createEnrollment(UUID userId, UUID courseId) {
        Course course = courseDAO.findById(courseId);
        if (course == null) return null;

        Registration existing = registrationDAO.findByUserAndCourse(userId, courseId);
        if (existing != null) return existing;

        Registration reg = new Registration();
        reg.setId(UUID.randomUUID());
        reg.setUserId(userId);
        reg.setCourseId(courseId);
        reg.setAmount(course.getPrice());
        reg.setStatus("enrolled");
        reg.setPaymentStatus("pending");
        reg.setProgressPercent((short) 0);

        if (enrollmentDAO.insert(reg)) {
            return reg;
        }
        return null;
    }

    public boolean activateEnrollment(UUID registrationId) {
        return registrationDAO.updateRegistrationStatus(registrationId, "enrolled", "paid");
    }

    public boolean cancelUnpaidEnrollment(UUID registrationId) {
        return registrationDAO.updateRegistrationStatus(registrationId, "cancelled", "failed");
    }

    public List<Registration> getMyEnrollments(UUID userId) {
        return registrationDAO.findByUserId(userId);
    }
}
