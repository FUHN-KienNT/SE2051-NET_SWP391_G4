package com.learnhub.controller;

import com.learnhub.entity.Registration;
import com.learnhub.entity.User;
import com.learnhub.service.EnrollmentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * Servlet handling Course Enrollments.
 * Implements methods specified in SDS Enrollment Diagram (1.1, 1.2):
 * - enroll()
 * - viewMyEnrollments()
 */
@WebServlet(name = "EnrollmentServlet", urlPatterns = {"/enroll", "/my-enrollments"})
public class EnrollmentServlet extends HttpServlet {
    private final EnrollmentService enrollmentService = new EnrollmentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=must_login");
            return;
        }

        List<Registration> myEnrollments = enrollmentService.getMyEnrollments(user.getId());
        req.setAttribute("enrollments", myEnrollments);
        req.getRequestDispatcher("/WEB-INF/views/learn/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=must_login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr != null) {
            try {
                UUID courseId = UUID.fromString(courseIdStr);
                Registration reg = enrollmentService.createEnrollment(user.getId(), courseId);
                if (reg != null) {
                    resp.sendRedirect(req.getContextPath() + "/checkout?registrationId=" + reg.getId());
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
