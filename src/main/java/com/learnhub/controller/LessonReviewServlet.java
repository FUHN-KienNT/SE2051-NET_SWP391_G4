package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import com.learnhub.service.LessonService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.UUID;

@WebServlet(name = "LessonReviewServlet", urlPatterns = "/admin/lesson-review")
public class LessonReviewServlet extends HttpServlet {
    private final LessonService lessonService = new LessonService();

    private User requireManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Object account = req.getSession(false) == null ? null
                : req.getSession(false).getAttribute(AppConstants.SessionKey.CURRENT_USER);
        if (!(account instanceof User user)
                || !AppConstants.Role.MANAGER.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User manager = requireManager(req, resp);
        if (manager == null) return;
        try {
            UUID courseId = UUID.fromString(req.getParameter("courseId"));
            var data = lessonService.getLessonsForReview(manager, courseId);
            if (req.getSession().getAttribute("lessonReviewToken") == null) {
                req.getSession().setAttribute("lessonReviewToken", UUID.randomUUID().toString());
            }
            req.setAttribute("course", data.course());
            req.setAttribute("lessons", data.lessons());
            req.setAttribute("pageTitle", "Lesson Review - LearnHub");
            req.getRequestDispatcher("/WEB-INF/views/admin/lesson-review.jsp").forward(req, resp);
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid course.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User manager = requireManager(req, resp);
        if (manager == null) return;
        Object token = req.getSession(false).getAttribute("lessonReviewToken");
        if (!(token instanceof String expected) || !expected.equals(req.getParameter("csrfToken"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            UUID courseId = UUID.fromString(req.getParameter("courseId"));
            UUID lessonId = UUID.fromString(req.getParameter("lessonId"));
            Timestamp updatedAt = Timestamp.valueOf(req.getParameter("updatedAt"));
            boolean reviewed = lessonService.reviewLesson(manager, courseId, lessonId,
                    updatedAt, req.getParameter("decision"));
            if (!reviewed) {
                resp.sendError(HttpServletResponse.SC_CONFLICT,
                        "The lesson has changed or has already been reviewed. Reload before reviewing again.");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/admin/lesson-review?reviewed=true&courseId=" + courseId);
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid lesson review.");
        } catch (IllegalStateException e) {
            throw new ServletException("Cannot save lesson review.", e);
        }
    }
}
