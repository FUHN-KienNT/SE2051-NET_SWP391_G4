package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Lesson;
import com.learnhub.entity.Registration;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.LearningProcessService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.Map;

@WebServlet(
        name = "LearningProcessServlet",
        urlPatterns = {"/learn/lesson", "/learn/complete"}
)
public class LearningProcessServlet extends HttpServlet {
    private final LearningProcessService learningService =
            new LearningProcessService();

    private final CourseService courseService = new CourseService();

    private User requireStudent(
            HttpServletRequest req,
            HttpServletResponse resp
    ) throws IOException {

        HttpSession session = req.getSession(false);

        Object account = session == null
                ? null
                : session.getAttribute(AppConstants.SessionKey.CURRENT_USER);

        User user = account instanceof User ? (User) account : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }

        if (!AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Student access required."
            );
            return null;
        }

        return user;
    }

    private boolean canStudy(
            Registration registration,
            Course course,
            UUID lessonId
    ) {
        if (registration == null || course == null) return false;

        boolean active =
                "enrolled".equalsIgnoreCase(registration.getStatus())
                        || "completed".equalsIgnoreCase(registration.getStatus());

        if (!active) return false;

        boolean paidCourse = course.getPrice() != null
                && course.getPrice().compareTo(BigDecimal.ZERO) > 0;

        if (paidCourse
                && !"paid".equalsIgnoreCase(registration.getPaymentStatus())) {
            return false;
        }

        return course.getModules().stream()
                .flatMap(module -> module.getLessons().stream())
                .anyMatch(lesson -> lesson.getId().equals(lessonId));
    }

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp
    ) throws ServletException, IOException {

        User user = requireStudent(req, resp);
        if (user == null) return;

        if (!"/learn/lesson".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }

        UUID courseId;
        UUID lessonId;

        try {
            courseId = UUID.fromString(req.getParameter("courseId"));
            lessonId = UUID.fromString(req.getParameter("lessonId"));
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Registration registration =
                learningService.findRegistration(user.getId(), courseId);

        Course course =
                courseService.getCourseDetailWithCurriculum(courseId);

        if (!canStudy(registration, course, lessonId)) {
            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Course access denied."
            );
            return;
        }

        LessonDTO lesson = learningService.getLessonForStudent(
                lessonId,
                registration.getId()
        );

        if (lesson == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }


        List<Lesson> orderedLessons = course.getModules().stream()
                .flatMap(module -> module.getLessons().stream())
                .toList();

        // Resolve previous and next lessons.
        for (int index = 0; index < orderedLessons.size(); index++) {
            if (orderedLessons.get(index).getId().equals(lessonId)) {
                if (index > 0) {
                    req.setAttribute(
                            "prevLesson",
                            orderedLessons.get(index - 1)
                    );
                }

                if (index + 1 < orderedLessons.size()) {
                    req.setAttribute(
                            "nextLesson",
                            orderedLessons.get(index + 1)
                    );
                }

                break;
            }
        }

        Map<String, String> statuses =
                learningService.getLessonStatuses(registration.getId());
        int completedCount = learningService.getCompletedCount(
                registration.getId(), orderedLessons);
        int totalCount = orderedLessons.size();
        int progressPercent = learningService.getProgressPercent(
                registration.getId());
        req.setAttribute("lesson", lesson);
        req.setAttribute("course", course);
        req.setAttribute("registration", registration);
        req.setAttribute("lessonStatuses", statuses);
        req.setAttribute("completedLessons", completedCount);
        req.setAttribute("totalLessons", totalCount);
        req.setAttribute("progressPercent", progressPercent);
        req.setAttribute("pageTitle", lesson.getTitle() + " - LearnHub");

        req.getRequestDispatcher(
                "/WEB-INF/views/learn/viewer.jsp"
        ).forward(req, resp);
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp
    ) throws ServletException, IOException {

        User user = requireStudent(req, resp);
        if (user == null) return;

        if (!"/learn/complete".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }

        UUID courseId;
        UUID lessonId;
        UUID registrationId;

        try {
            courseId = UUID.fromString(req.getParameter("courseId"));
            lessonId = UUID.fromString(req.getParameter("lessonId"));
            registrationId = UUID.fromString(
                    req.getParameter("registrationId")
            );
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Registration registration =
                learningService.findRegistration(user.getId(), courseId);

        Course course =
                courseService.getCourseDetailWithCurriculum(courseId);

        if (!canStudy(registration, course, lessonId)
                || !registration.getId().equals(registrationId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        learningService.markLessonComplete(registrationId, lessonId);

        resp.sendRedirect(
                req.getContextPath()
                        + "/learn/lesson?courseId=" + courseId
                        + "&lessonId=" + lessonId
                        + "&completed=true"
        );
    }
}