package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import com.learnhub.service.LessonService;
import com.learnhub.util.YouTubeVideo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.UUID;

@WebServlet(name = "LessonPreviewServlet", urlPatterns = "/lessons/preview")
public class LessonPreviewServlet extends HttpServlet {
    private final LessonService lessonService = new LessonService();

    private User requirePreviewUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Object account = req.getSession(false) == null ? null
                : req.getSession(false).getAttribute(AppConstants.SessionKey.CURRENT_USER);
        if (!(account instanceof User user)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }
        if (!AppConstants.Role.EXPERT.equalsIgnoreCase(user.getRoleCode())
                && !AppConstants.Role.MANAGER.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requirePreviewUser(req, resp);
        if (user == null) return;
        UUID lessonId;
        try {
            lessonId = UUID.fromString(req.getParameter("id"));
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid lesson.");
            return;
        }
        try {
            var data = lessonService.getLessonPreview(user, lessonId);
            boolean manager = AppConstants.Role.MANAGER.equalsIgnoreCase(user.getRoleCode());
            req.setAttribute("lesson", data.lesson());
            req.setAttribute("quiz", data.quiz());
            req.setAttribute("questions", data.questions());
            req.setAttribute("isManagerPreview", manager);
            req.setAttribute("videoEmbedUrl", YouTubeVideo.embedUrl(data.lesson().getVideoUrl()));
            req.setAttribute("pageTitle", "Lesson Preview - LearnHub");
            req.setAttribute("backPath", manager ? "/manager/lessons" : "/expert/lessons");
            req.setAttribute("reviewAction", "/lessons/preview");
            if (manager && req.getSession().getAttribute("lessonReviewToken") == null) {
                req.getSession().setAttribute("lessonReviewToken", UUID.randomUUID().toString());
            }
            req.getRequestDispatcher("/WEB-INF/views/learn/lesson-preview.jsp").forward(req, resp);
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Lesson not found.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requirePreviewUser(req, resp);
        if (user == null) return;
        if (!AppConstants.Role.MANAGER.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Object token = req.getSession(false).getAttribute("lessonReviewToken");
        if (!(token instanceof String expected) || !expected.equals(req.getParameter("csrfToken"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        UUID lessonId;
        Timestamp updatedAt;
        try {
            lessonId = UUID.fromString(req.getParameter("id"));
            updatedAt = Timestamp.valueOf(req.getParameter("updatedAt"));
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid lesson review.");
            return;
        }
        try {
            var lesson = lessonService.getLessonForManager(user, lessonId);
            boolean saved = lessonService.reviewLesson(user, lesson.getCourseId(), lessonId,
                    updatedAt, req.getParameter("decision"), req.getParameter("declineReason"));
            if (!saved) {
                resp.setStatus(HttpServletResponse.SC_CONFLICT);
                req.setAttribute("reviewError", "The lesson has changed or has already been reviewed. Review the current content before trying again.");
                doGet(req, resp);
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/manager/lessons?reviewed=true&courseId="
                    + lesson.getCourseId());
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (IllegalArgumentException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            req.setAttribute("reviewError", e.getMessage());
            doGet(req, resp);
        } catch (IllegalStateException e) {
            throw new ServletException("Cannot save lesson review.", e);
        }
    }
}