package com.learnhub.controller;

import com.learnhub.dao.QuizAttemptDAO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Module;
import com.learnhub.entity.Registration;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.LearningProcessService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * LearningProcessServlet for student study progress and student learning dashboard.
 * Implements methods specified in SDS Lesson Learning Diagram (4.1, 4.2, 4.3):
 * - showLessonContent()
 * - markAsComplete()
 * - handleDashboard()
 */
@WebServlet(name = "LearningProcessServlet", urlPatterns = {"/learn/lesson", "/learn/complete", "/learning-process"})
public class LearningProcessServlet extends HttpServlet {
    private final LearningProcessService learningService = new LearningProcessService();
    private final CourseService courseService = new CourseService();
    private final QuizAttemptDAO quizAttemptDAO = new QuizAttemptDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            String redirectUri = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }
            String encodedUri = java.net.URLEncoder.encode(redirectUri, "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
            return;
        }

        String path = req.getServletPath();
        String action = req.getParameter("action");
        String lessonIdStr = req.getParameter("lessonId");
        String courseIdStr = req.getParameter("courseId");

        // 1. Dashboard request (/learning-process?action=dashboard or /learning-process without course/lesson)
        if ("dashboard".equals(action) || ("/learning-process".equals(path) && courseIdStr == null && lessonIdStr == null)) {
            handleDashboard(req, resp, user);
            return;
        }

        // 2. Direct course navigation: resolve first lesson and redirect to /learn/lesson
        if (courseIdStr != null && (lessonIdStr == null || lessonIdStr.trim().isEmpty())) {
            try {
                UUID courseId = UUID.fromString(courseIdStr.trim());
                Course course = courseService.getCourseDetailWithCurriculum(courseId);
                if (course != null && course.getModules() != null) {
                    for (Module m : course.getModules()) {
                        if (m.getLessons() != null && !m.getLessons().isEmpty()) {
                            resp.sendRedirect(req.getContextPath() + "/learn/lesson?courseId=" + courseId + "&lessonId=" + m.getLessons().get(0).getId());
                            return;
                        }
                    }
                }
            } catch (Exception ignored) {
            }
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        // 3. Lesson viewer
        if (lessonIdStr != null && courseIdStr != null) {
            try {
                UUID lessonId = UUID.fromString(lessonIdStr.trim());
                UUID courseId = UUID.fromString(courseIdStr.trim());

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

    private void handleDashboard(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        List<Registration> myEnrollments = courseService.getMyEnrollments(user.getId());
        ContinueLearningDTO continueLearning = learningService.getContinueLearning(user.getId());
        int totalCourses = myEnrollments != null ? myEnrollments.size() : 0;
        int completedLessons = learningService.countCompletedLessonsByUser(user.getId());
        Double avgScore = quizAttemptDAO.getAverageScoreByUser(user.getId());

        Map<String, Object> progressSummary = new HashMap<>();
        progressSummary.put("totalCourses", totalCourses);
        progressSummary.put("completedLessons", completedLessons);
        progressSummary.put("averageScore", avgScore != null ? String.format("%.1f", avgScore) : "N/A");

        req.setAttribute("progressSummary", progressSummary);
        req.setAttribute("continueLearning", continueLearning);
        req.setAttribute("registrations", myEnrollments);
        req.getRequestDispatcher("/WEB-INF/views/learn/dashboard.jsp").forward(req, resp);
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
