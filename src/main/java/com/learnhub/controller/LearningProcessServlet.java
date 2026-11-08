package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.User;
import com.learnhub.service.LearningProcessService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.UUID;

@WebServlet(
        name = "LearningProcessServlet",
        urlPatterns = {"/learn/lesson", "/learn/complete"}
)
public class LearningProcessServlet extends HttpServlet {
    private final LearningProcessService learningService =
            new LearningProcessService();

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

        LearningProcessService.LessonViewerData data;
        try {
            data = learningService.getLessonViewer(user.getId(), courseId, lessonId);
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
            return;
        }
        LessonDTO lesson = data.lesson();

        if ("quiz".equals(lesson.getType())) {
            if (!learningService.isQuizLessonAvailable(lesson)) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Quiz is not available.");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/quiz?quizId=" + lesson.getQuizId()
                    + "&courseId=" + courseId);
            return;
        }
        if ("video".equals(lesson.getType())) {
            req.setAttribute("videoEmbedUrl", com.learnhub.util.YouTubeVideo.embedUrl(lesson.getVideoUrl()));
        }

        req.setAttribute("lesson", lesson);
        req.setAttribute("course", data.course());
        req.setAttribute("registration", data.registration());
        req.setAttribute("lessonStatuses", data.statuses());
        req.setAttribute("prevLesson", data.previous());
        req.setAttribute("nextLesson", data.next());
        req.setAttribute("completedLessons", data.completedCount());
        req.setAttribute("totalLessons", data.totalCount());
        req.setAttribute("progressPercent", data.progressPercent());
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

        try {
            learningService.completeLessonForStudent(user.getId(), courseId, registrationId, lessonId);
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
            return;
        }

        resp.sendRedirect(
                req.getContextPath()
                        + "/learn/lesson?courseId=" + courseId
                        + "&lessonId=" + lessonId
                        + "&completed=true"
        );
    }
}
