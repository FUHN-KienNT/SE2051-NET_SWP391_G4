package com.learnhub.controller;

import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.User;
import com.learnhub.constant.AppConstants;
import com.learnhub.service.CourseService;
import com.learnhub.service.LessonService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;
import java.util.Map;
import java.util.List;
import java.sql.Timestamp;

/**
 * Servlet handling Lesson administration & material uploads.
 * Implements methods specified in SDS Lesson Learning Class Diagram (4.1):
 * - showLessonList()
 * - showLessonDetail()
 * - saveAndRedirect()
 */
@WebServlet(name = "LessonServlet", urlPatterns = {"/lessons/manage", "/lessons/upload"})
@MultipartConfig(maxFileSize = 50 * 1024 * 1024)
public class LessonServlet extends HttpServlet {
    private final LessonService lessonService = new LessonService();
    private final CourseService courseService = new CourseService();

     @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
         Object account = req.getSession(false) == null ? null
                 : req.getSession(false).getAttribute(AppConstants.SessionKey.CURRENT_USER);
         if (!(account instanceof User user)
                 || !AppConstants.Role.EXPERT.equalsIgnoreCase(user.getRoleCode())) {
             resp.sendError(HttpServletResponse.SC_FORBIDDEN);
             return;
         }
         UUID expertId = user.getId();
         if (req.getSession(false).getAttribute("lessonActionToken") == null) {
             req.getSession(false).setAttribute(
                     "lessonActionToken", UUID.randomUUID().toString());
         }
        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                UUID courseId = UUID.fromString(courseIdStr);
                lessonService.requireCourseAccess(expertId, courseId);
                Course course = courseService.getCourseDetailWithCurriculum(courseId);
                if (course != null) {
                    req.setAttribute("course", course);
                    req.setAttribute("modules", course.getModules());
                }
            } catch (SecurityException e) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            } catch (Exception e) {
                throw new ServletException("Lesson operation failed.", e);
            }
        }
        String action = req.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            req.setAttribute("defaultOrderIndex", 1);
            req.getRequestDispatcher("/WEB-INF/views/expert/lesson-detail.jsp").forward(req, resp);
            return;
        }
         if ("delete".equalsIgnoreCase(action)) {
             resp.sendError(HttpServletResponse.SC_GONE, "Permanent lesson deletion is no longer available.");
             return;
         }
         if ("activate".equalsIgnoreCase(action) || "deactivate".equalsIgnoreCase(action)) {
             resp.setHeader("Allow", "POST");
             resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
             return;
         }
        if ("edit".equalsIgnoreCase(action)) {
            String lessonIdStr = req.getParameter("id");
            if (lessonIdStr != null && !lessonIdStr.trim().isEmpty()) {
                try {
                    UUID lessonId = UUID.fromString(lessonIdStr.trim());
                    LessonDTO lesson = lessonService.getLesson(expertId, lessonId);
                    req.setAttribute("lesson", lesson);
                } catch (SecurityException e) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                } catch (Exception e) {
                    throw new ServletException("Lesson operation failed.", e);
                }
            }
            req.getRequestDispatcher("/WEB-INF/views/expert/lesson-detail.jsp").forward(req, resp);
            return;
        }
        Course selectedCourse = (Course) req.getAttribute("course");
        var lessonList = lessonService.buildLessonList(
                selectedCourse == null ? List.of() : selectedCourse.getModules(),
                req.getParameter("sort"), req.getParameter("direction"), req.getParameter("lessonStatus"));
        req.setAttribute("lessonRows", lessonList.rows());
        req.setAttribute("lessonSort", lessonList.sort());
        req.setAttribute("lessonDirection", lessonList.direction());
        req.setAttribute("lessonStatus", lessonList.status());
        int coursePage = 1;
        try {
            coursePage = Integer.parseInt(req.getParameter("coursePage"));
        } catch (NumberFormatException ignored) {
        }
        var navigation = courseService.getAssignedCourseNavigation(
                expertId, req.getParameter("courseSearch"), coursePage);
        req.setAttribute("assignedCourses", navigation.courses());
        req.setAttribute("courseSearch", navigation.search());
        req.setAttribute("coursePage", navigation.page());
        req.setAttribute("courseTotalPages", navigation.totalPages());
        req.setAttribute("courseTotal", navigation.totalCourses());
        req.getRequestDispatcher("/WEB-INF/views/expert/lesson-manage.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Object account = req.getSession(false) == null ? null
                : req.getSession(false).getAttribute(AppConstants.SessionKey.CURRENT_USER);
        if (!(account instanceof User user)
                || !AppConstants.Role.EXPERT.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        UUID expertId = user.getId();
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            resp.sendError(HttpServletResponse.SC_GONE, "Permanent lesson deletion is no longer available.");
            return;
        }
        if ("activate".equalsIgnoreCase(action) || "deactivate".equalsIgnoreCase(action)) {
            Object token = req.getSession(false).getAttribute("lessonActionToken");
            if (!(token instanceof String expected)
                    || !expected.equals(req.getParameter("csrfToken"))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            UUID lessonId;
            UUID courseId;
            Timestamp updatedAt;
            try {
                lessonId = UUID.fromString(req.getParameter("id"));
                courseId = UUID.fromString(req.getParameter("courseId"));
                updatedAt = Timestamp.valueOf(req.getParameter("updatedAt"));
            } catch (IllegalArgumentException | NullPointerException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            try {
                boolean changed = lessonService.changeLessonAvailability(expertId, courseId, lessonId,
                        updatedAt, "activate".equalsIgnoreCase(action));
                if (!changed) {
                    resp.sendError(HttpServletResponse.SC_CONFLICT, "Lesson status has changed. Reload and try again.");
                    return;
                }
            } catch (SecurityException e) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            } catch (IllegalStateException e) {
                throw new ServletException("Cannot change lesson availability.", e);
            }
            resp.sendRedirect(req.getContextPath() + "/lessons/manage?courseId=" + courseId
                    + "&availability=" + ("activate".equalsIgnoreCase(action) ? "active" : "inactive"));
            return;
        }
        if ("upload".equalsIgnoreCase(action)) {
            String lessonIdStr = req.getParameter("lessonId");
            Part filePart = req.getPart("file");
            if (lessonIdStr != null && filePart != null) {
                try {
                    UUID lessonId = UUID.fromString(lessonIdStr);
                    InputStream inputStream = filePart.getInputStream();
                    String filename = filePart.getSubmittedFileName();
                    lessonService.attachMaterial(expertId, lessonId, inputStream, filename);
                } catch (SecurityException e) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                } catch (Exception e) {
                    throw new ServletException("Lesson operation failed.", e);
                }
            }
            resp.sendRedirect(req.getContextPath() + "/lessons/manage?id=" + req.getParameter("lessonId") + "&uploaded=true");
            return;
        }

        Object saveToken = req.getSession(false).getAttribute("lessonActionToken");
        if (!(saveToken instanceof String expected)
                || !expected.equals(req.getParameter("csrfToken"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String idStr = req.getParameter("id");
        String courseIdStr = req.getParameter("courseId");
        String moduleIdStr = req.getParameter("moduleId");
        String title = req.getParameter("title");
        String content = req.getParameter("content");
        String orderIndexStr = req.getParameter("orderIndex");
        String durationValue = req.getParameter("durationMinutes");
        Integer durationMinutes = null;
        try {
            durationMinutes = Integer.valueOf(durationValue == null ? "" : durationValue.strip());
        } catch (NumberFormatException ignored) {
        }
        int orderIndex = 0;
        try {
            orderIndex = Integer.parseInt(orderIndexStr == null ? "" : orderIndexStr.trim());
        } catch (NumberFormatException ignored) {
        }
        try {
            UUID id = (idStr != null && !idStr.trim().isEmpty()) ? UUID.fromString(idStr) : UUID.randomUUID();
            UUID moduleId = null;
            try {
                moduleId = UUID.fromString(moduleIdStr == null ? "" : moduleIdStr.trim());
            } catch (IllegalArgumentException ignored) {
            }
            LessonDTO dto = new LessonDTO(id, moduleId, title, content, orderIndex);
            dto.setDurationMinutes(durationMinutes);
            dto.setPublicationStatus(AppConstants.LessonStatus.DRAFT);
            Map<String, String> errors = lessonService.validateLesson(expertId, dto);
            boolean saved = errors.isEmpty() && lessonService.saveLesson(expertId, dto);
            if (!saved) {
                Course course = courseService.getCourseDetailWithCurriculum(
                        UUID.fromString(courseIdStr));
                req.setAttribute("course", course);
                req.setAttribute("modules", course == null ? List.of() : course.getModules());
                req.setAttribute("lesson", dto);
                req.setAttribute("fieldErrors", errors);
                if (errors.isEmpty()) {
                    req.setAttribute("saveError", "Can not save lesson.");
                    resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                } else {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                }
                req.getRequestDispatcher("/WEB-INF/views/expert/lesson-detail.jsp")
                        .forward(req, resp);
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/lessons/manage?submitted=true&courseId=" + (courseIdStr != null ? courseIdStr : ""));
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        } catch (Exception e) {
            throw new ServletException("Cannot save lesson.", e);
        }
    }
}
