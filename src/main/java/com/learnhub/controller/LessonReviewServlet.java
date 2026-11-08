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

@WebServlet(name = "LessonReviewServlet", urlPatterns = {"/manager/lesson-review", "/manager/lessons"})
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
            String courseIdParam = req.getParameter("courseId");
            if (courseIdParam == null || courseIdParam.isBlank()) {
                req.setAttribute("pendingCourses", lessonService.getCoursesAwaitingReview(manager));
                req.setAttribute("pageTitle", "Lesson Review - LearnHub");
                req.getRequestDispatcher("/WEB-INF/views/manager/lesson-review-list.jsp").forward(req, resp);
                return;
            }
            UUID courseId = UUID.fromString(courseIdParam);
            var course = lessonService.getCourseForLessonReview(manager, courseId);
            var filter = lessonService.lessonListFilter(req.getParameter("sort"), req.getParameter("direction"),
                    req.getParameter("durationSort"), req.getParameter("lessonStatus"),
                    req.getParameter("lessonModuleId"), req.getParameter("lessonSearch"));
            var lessonList = lessonService.buildLessonList(course.getModules(), filter);
            req.setAttribute("course", course);
            req.setAttribute("modules", course.getModules());
            req.setAttribute("managerReview", true);
            req.setAttribute("canCreateModule", false);
            ControllerSupport.lessonListAttributes(req, lessonList, filter.search());
            req.setAttribute("pageTitle", "Lesson Review - LearnHub");
            req.getRequestDispatcher("/WEB-INF/views/common/lesson-list.jsp").forward(req, resp);
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
                    updatedAt, req.getParameter("decision"), req.getParameter("declineReason"));
            if (!reviewed) {
                resp.sendError(HttpServletResponse.SC_CONFLICT,
                        "The lesson has changed or has already been reviewed. Reload before reviewing again.");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/manager/lessons?reviewed=true&courseId=" + courseId);
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid lesson review.");
        } catch (IllegalStateException e) {
            throw new ServletException("Cannot save lesson review.", e);
        }
    }
}
