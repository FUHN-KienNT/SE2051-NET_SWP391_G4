package com.fpt.lms.controller;

import com.fpt.lms.dto.LessonDTO;
import com.fpt.lms.entity.Course;
import com.fpt.lms.entity.Registration;
import com.fpt.lms.entity.User;
import com.fpt.lms.service.CourseService;
import com.fpt.lms.service.LearningProcessService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.UUID;

/**
 * LearningProcessServlet for student study progress.
 * Implements methods specified in SDS Lesson Learning Diagram (4.1, 4.2, 4.3):
 * - showLessonContent()
 * - markAsComplete()
 */
@WebServlet(name = "LearningProcessServlet", urlPatterns = {"/learn/lesson", "/learn/complete"})
public class LearningProcessServlet extends HttpServlet {
    private final LearningProcessService learningService = new LearningProcessService();
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=must_login");
            return;
        }

        String lessonIdStr = req.getParameter("lessonId");
        String courseIdStr = req.getParameter("courseId");

        if (lessonIdStr != null && courseIdStr != null) {
            try {
                UUID lessonId = UUID.fromString(lessonIdStr);
                UUID courseId = UUID.fromString(courseIdStr);

                Registration reg = courseService.getCourseDetailWithCurriculum(courseId) != null ?
                        courseService.processCourseRegistration(user.getId(), courseId, null) : null;

                if (reg != null) {
                    LessonDTO lesson = learningService.getLessonForStudent(lessonId, reg.getId());
                    Course course = courseService.getCourseDetailWithCurriculum(courseId);
                    int progress = learningService.getProgressPercent(reg.getId());

                    req.setAttribute("lesson", lesson);
                    req.setAttribute("course", course);
                    req.setAttribute("registration", reg);
                    req.setAttribute("progressPercent", progress);

                    req.getRequestDispatcher("/WEB-INF/views/learn/viewer.jsp").forward(req, resp);
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String lessonIdStr = req.getParameter("lessonId");
        String registrationIdStr = req.getParameter("registrationId");
        String courseIdStr = req.getParameter("courseId");

        if (lessonIdStr != null && registrationIdStr != null) {
            try {
                UUID lessonId = UUID.fromString(lessonIdStr);
                UUID registrationId = UUID.fromString(registrationIdStr);
                learningService.markLessonComplete(registrationId, lessonId);
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/learn/lesson?courseId=" + courseIdStr + "&lessonId=" + lessonIdStr + "&completed=true");
    }
}
