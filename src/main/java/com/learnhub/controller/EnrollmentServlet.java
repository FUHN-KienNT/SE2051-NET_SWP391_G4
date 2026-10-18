package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.CourseDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.LearningProcessService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet(
        name = "EnrollmentServlet",
        urlPatterns = {"/enroll", "/enrollment", "/my-enrollments"}
)
public class EnrollmentServlet extends HttpServlet {

    private final CourseService courseService = new CourseService();

    private final LearningProcessService learningService =
            new LearningProcessService();

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp
    ) throws ServletException, IOException {

        String path = req.getServletPath();
        String action = req.getParameter("action");

        if ("/my-enrollments".equals(path)) {
            handleMyEnrollments(req, resp);
            return;
        }

        if ("my-courses".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/my-enrollments");
            return;
        }

        handleEnrollmentPage(req, resp);
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);

        Object account = session == null
                ? null
                : session.getAttribute(AppConstants.SessionKey.CURRENT_USER);

        return account instanceof User ? (User) account : null;
    }

    private void redirectToLogin(
            HttpServletRequest req,
            HttpServletResponse resp,
            String target
    ) throws IOException {

        String encoded = URLEncoder.encode(
                target, StandardCharsets.UTF_8
        );

        resp.sendRedirect(
                req.getContextPath()
                        + "/auth/login?error=must_login&redirect_uri="
                        + encoded
        );
    }

    private void handleEnrollmentPage(
            HttpServletRequest req,
            HttpServletResponse resp
    ) throws ServletException, IOException {

        String courseIdValue = req.getParameter("courseId");

        if (courseIdValue == null || courseIdValue.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        UUID courseId;

        try {
            courseId = UUID.fromString(courseIdValue.trim());
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        Course course =
                courseService.getPublishedCourseCurriculum(courseId);

        if (course == null) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        User user = getCurrentUser(req);

        if (user == null) {
            redirectToLogin(
                    req,
                    resp,
                    req.getContextPath()
                            + "/enrollment?courseId=" + courseId
            );
            return;
        }

        if (!AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode())) {
            req.setAttribute("course", course);
            req.setAttribute("student", user);
            req.setAttribute(
                    "roleError",
                    "Vui lòng đăng nhập tài khoản Student để đăng ký khóa học."
            );
            req.setAttribute("pageTitle", "Thông báo đăng ký");

            req.getRequestDispatcher(
                    "/WEB-INF/views/courses/enrollment.jsp"
            ).forward(req, resp);
            return;
        }

        List<Registration> registrations =
                courseService.getMyEnrollments(user.getId());

        boolean alreadyEnrolled = registrations != null
                && registrations.stream().anyMatch(registration ->
                courseId.equals(registration.getCourseId())
                        && learningService.isAccessibleRegistration(registration, course)
        );

        if (alreadyEnrolled) {
            resp.sendRedirect(
                    req.getContextPath()
                            + "/learn/course?id="
                            + courseId
            );
            return;
        }

        List<Setting> paymentMethods =
                courseService.getPaymentMethods();

        req.setAttribute("course", course);
        req.setAttribute("student", user);
        req.setAttribute("paymentMethods", paymentMethods);
        req.setAttribute(
                "pageTitle",
                "Thông tin thanh toán - " + course.getTitle()
        );

        req.getRequestDispatcher(
                "/WEB-INF/views/courses/enrollment.jsp"
        ).forward(req, resp);
    }

    private void handleMyEnrollments(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getCurrentUser(req);
        if (user == null) {
            redirectToLogin(req, resp, req.getContextPath() + "/my-enrollments");
            return;
        }
        if (!AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Student access required.");
            return;
        }
        List<ContinueLearningDTO> enrolled = learningService.getStudentCourses(user.getId());
        if ("continue".equals(req.getParameter("action"))) {
            handleContinue(req, resp, enrolled);
            return;
        }
        String search = req.getParameter("search");
        search = search == null ? "" : search.trim();
        String categoryValue = req.getParameter("categoryId");
        UUID categoryId = null;
        if (categoryValue != null && !categoryValue.isBlank()) {
            try {
                categoryId = UUID.fromString(categoryValue);
            } catch (IllegalArgumentException e) {
                resp.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid category."
                );
                return;
            }
        }

        String sort = req.getParameter("sort");
        var data = learningService.buildStudentDashboard(
                enrolled, search, categoryId, sort);
        req.setAttribute("myCourses", data.myCourses());
        req.setAttribute("availableCourses", data.availableCourses());
        req.setAttribute("categories", courseService.getActiveCategories());
        req.setAttribute("search", search);
        req.setAttribute(
                "selectedCategory",
                categoryId == null ? "" : categoryId.toString()
        );
        req.setAttribute("sort", data.sort());
        req.setAttribute("pageTitle", "My Courses - LearnHub");

        req.getRequestDispatcher(
                "/WEB-INF/views/learn/dashboard.jsp"
        ).forward(req, resp);
    }

    private void handleContinue(
            HttpServletRequest req,
            HttpServletResponse resp,
            List<ContinueLearningDTO> enrolled
    ) throws IOException {

        ContinueLearningDTO selected;
        try {
            selected = learningService.resolveContinueLesson(
                    enrolled, req.getParameter("courseId"), req.getParameter("lessonId"));
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (selected.getLessonId() == null) {
            resp.sendRedirect(req.getContextPath()
                    + "/my-enrollments?notice=no-lessons");
            return;
        }
        resp.sendRedirect(req.getContextPath()
                + "/learn/lesson?courseId=" + selected.getCourseId()
                + "&lessonId=" + selected.getLessonId());
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp
    ) throws ServletException, IOException {

        User user = getCurrentUser(req);
        String courseIdValue = req.getParameter("courseId");

        if (user == null) {
            redirectToLogin(
                    req,
                    resp,
                    req.getContextPath()
                            + "/enrollment?courseId="
                            + (courseIdValue == null ? "" : courseIdValue)
            );
            return;
        }

        if (!AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Student access required."
            );
            return;
        }

        String paymentMethodValue = req.getParameter("paymentMethodId");

        if (courseIdValue != null && !courseIdValue.isBlank()) {
            try {
                UUID courseId = UUID.fromString(courseIdValue.trim());
                UUID paymentMethodId = null;

                if (paymentMethodValue != null
                        && !paymentMethodValue.isBlank()) {
                    try {
                        paymentMethodId =
                                UUID.fromString(paymentMethodValue.trim());
                    } catch (IllegalArgumentException ignored) {
                    }
                }

                Registration registration =
                        courseService.processCourseRegistration(
                                user.getId(),
                                courseId,
                                paymentMethodId
                        );

                if (registration != null) {
                    boolean canLearn =
                            learningService.findEnrolledCourse(user.getId(), courseId) != null;
                    resp.sendRedirect(req.getContextPath() + (canLearn
                            ? "/learn/course?id=" + courseId
                            : "/my-enrollments?registered=success"));
                    return;
                }
            } catch (IllegalArgumentException ignored) {
            }
        }

        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
