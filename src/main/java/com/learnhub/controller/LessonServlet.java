package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.LessonService;
import com.learnhub.service.ModuleService;
import com.learnhub.service.QuizManagementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Timestamp;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@WebServlet(name = "LessonServlet", urlPatterns = {
        "/expert/lessons", "/expert/lessons/create", "/expert/lessons/edit", "/expert/lessons/upload"
})
@MultipartConfig(maxFileSize = 50 * 1024 * 1024)
public class LessonServlet extends HttpServlet {
    private final LessonService lessonService = new LessonService();
    private final ModuleService moduleService = new ModuleService();
    private final CourseService courseService = new CourseService();
    private final QuizManagementService quizService = new QuizManagementService();

    private User requireExpert(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = ControllerSupport.currentUser(req);
        if (user == null || !AppConstants.Role.EXPERT.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = requireExpert(req, resp);
        if (user == null) return;
        if (req.getSession(false).getAttribute("lessonActionToken") == null) {
            req.getSession(false).setAttribute("lessonActionToken", UUID.randomUUID().toString());
        }
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            resp.sendError(HttpServletResponse.SC_GONE, "Permanent lesson deletion is no longer supported.");
            return;
        }
        if ("activate".equalsIgnoreCase(action) || "deactivate".equalsIgnoreCase(action)) {
            resp.setHeader("Allow", "POST");
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        try {
            String value = req.getParameter("courseId");
            UUID courseId = value == null || value.isBlank() ? null : UUID.fromString(value.strip());
            switch (req.getServletPath()) {
                case "/expert/lessons/create" -> {
                    if (courseId == null) {
                        var assignedCourses = courseService.getAssignedCourseOptions(user.getId());
                        if (!assignedCourses.isEmpty()) {
                            resp.sendRedirect(req.getContextPath() + "/expert/lessons/create?courseId=" + assignedCourses.get(0).getId());
                            return;
                        }
                    }
                    showForm(req, resp, user.getId(), courseId, null);
                }
                case "/expert/lessons/edit" -> {
                    String idParam = req.getParameter("id");
                    if (idParam == null || idParam.isBlank()) {
                        resp.sendRedirect(req.getContextPath() + "/expert/lessons" + (courseId == null ? "" : "?courseId=" + courseId));
                        return;
                    }
                    UUID lessonId = UUID.fromString(idParam.strip());
                    LessonDTO lesson = lessonService.getLesson(user.getId(), lessonId);
                    showForm(req, resp, user.getId(), courseId, lesson);
                }
                default -> showList(req, resp, user.getId(), courseId);
            }
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid course, lesson or filter.");
        } catch (IllegalStateException e) {
            throw new ServletException("Cannot load lessons.", e);
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp, UUID expertId, UUID courseId)
            throws ServletException, IOException {
        var assignedCourses = courseService.getAssignedCourseOptions(expertId);
        if (courseId == null && !assignedCourses.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + assignedCourses.get(0).getId());
            return;
        }
        Course course = courseId == null ? null : lessonService.getCourseForExpert(expertId, courseId);
        var filter = lessonService.lessonListFilter(req.getParameter("sort"), req.getParameter("direction"),
                req.getParameter("durationSort"), req.getParameter("lessonStatus"),
                req.getParameter("lessonModuleId"), req.getParameter("lessonSearch"));
        var data = lessonService.buildLessonList(course == null ? List.of() : course.getModules(), filter);
        req.setAttribute("course", course);
        req.setAttribute("modules", course == null ? List.of() : course.getModules());
        req.setAttribute("canCreateModule", course != null);
        req.setAttribute("assignedCourses", assignedCourses);
        ControllerSupport.lessonListAttributes(req, data, filter.search());
        req.getRequestDispatcher("/WEB-INF/views/common/lesson-list.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, UUID expertId,
                          UUID courseId, LessonDTO lesson) throws ServletException, IOException {
        Course course = courseId == null ? null : lessonService.getCourseForExpert(expertId, courseId);
        if (lesson != null && req.getAttribute("fieldErrors") == null && (course == null || course.getModules().stream()
                .noneMatch(module -> module.getId().equals(lesson.getModuleId())))) {
            throw new SecurityException("Lesson does not belong to this course.");
        }
        req.setAttribute("course", course);
        req.setAttribute("modules", course == null ? List.of() : course.getModules());
        req.setAttribute("lesson", lesson);
        req.setAttribute("defaultOrderIndex", 1);
        req.setAttribute("nextLessonOrders", lessonService.getNextLessonOrders(course, lesson == null ? null : lesson.getId()));
        req.setAttribute("lessonQuizzes", courseId == null ? List.of()
                : quizService.findByExpert(expertId, null, null, courseId, "published"));
        req.getRequestDispatcher("/WEB-INF/views/expert/lesson-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = requireExpert(req, resp);
        if (user == null) return;
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            resp.sendError(HttpServletResponse.SC_GONE, "Permanent lesson deletion is no longer supported.");
            return;
        }
        Object token = req.getSession(false).getAttribute("lessonActionToken");
        if (!(token instanceof String expected) || !expected.equals(req.getParameter("csrfToken"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        action = action == null || action.isBlank() ? "save" : action;
        if ("activate".equalsIgnoreCase(action) || "deactivate".equalsIgnoreCase(action)
                || "upload".equalsIgnoreCase(action)) action = action.toLowerCase(Locale.ROOT);
        try {
            switch (action) {
                case "activate", "deactivate" -> handleAvailability(req, resp, user.getId(), action);
                case "createModule", "renameModule", "hideModule", "showModule" ->
                        handleModuleAction(req, resp, user.getId(), action);
                case "upload" -> handleUpload(req, resp, user.getId());
                case "save" -> handleSave(req, resp, user.getId());
                default -> resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid lesson action.");
            }
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (IllegalArgumentException | NullPointerException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid course, lesson or input.");
        } catch (IllegalStateException e) {
            throw new ServletException("Lesson operation failed.", e);
        }
    }

    private void handleAvailability(HttpServletRequest req, HttpServletResponse resp, UUID expertId, String action)
            throws IOException {
        UUID lessonId = UUID.fromString(req.getParameter("id"));
        UUID courseId = UUID.fromString(req.getParameter("courseId"));
        Timestamp version = Timestamp.valueOf(req.getParameter("updatedAt"));
        boolean activate = "activate".equals(action);
        if (!lessonService.changeLessonAvailability(expertId, courseId, lessonId, version, activate)) {
            resp.sendError(HttpServletResponse.SC_CONFLICT, "Lesson status has changed. Reload and try again.");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseId
                + "&availability=" + (activate ? "active" : "inactive"));
    }

    private void handleModuleAction(HttpServletRequest req, HttpServletResponse resp, UUID expertId, String action)
            throws IOException {
        UUID courseId = UUID.fromString(req.getParameter("courseId"));
        switch (action) {
            case "createModule" -> moduleService.createForExpert(courseId, expertId, req.getParameter("moduleTitle"));
            case "renameModule" -> moduleService.renameForExpert(courseId,
                    UUID.fromString(req.getParameter("moduleId")), expertId, req.getParameter("moduleTitle"));
            case "hideModule", "showModule" -> moduleService.setHiddenForExpert(courseId,
                    UUID.fromString(req.getParameter("moduleId")), expertId, "hideModule".equals(action));
            default -> throw new IllegalArgumentException("Invalid module action.");
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?courseId=" + courseId + "&moduleAction=" + action);
    }

    private void handleUpload(HttpServletRequest req, HttpServletResponse resp, UUID expertId)
            throws ServletException, IOException {
        UUID lessonId = UUID.fromString(req.getParameter("lessonId"));
        Part file = req.getPart("file");
        if (file == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing file.");
            return;
        }
        try (InputStream input = file.getInputStream()) {
            lessonService.attachMaterial(expertId, lessonId, input, file.getSubmittedFileName());
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?id=" + lessonId + "&uploaded=true");
    }

    private Integer readInteger(String value) {
        try {
            return value == null ? null : Integer.valueOf(value.strip());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void handleSave(HttpServletRequest req, HttpServletResponse resp, UUID expertId)
            throws ServletException, IOException {
        UUID courseId = UUID.fromString(req.getParameter("courseId"));
        UUID id = ControllerSupport.optionalUuid(req.getParameter("id"));
        if (id == null) {
            String submittedId = req.getParameter("id");
            if (submittedId != null && !submittedId.isBlank()) throw new IllegalArgumentException("Invalid lesson.");
            id = UUID.randomUUID();
        }
        Integer order = readInteger(req.getParameter("orderIndex"));
        LessonDTO dto = new LessonDTO(id, ControllerSupport.optionalUuid(req.getParameter("moduleId")),
                req.getParameter("title"), req.getParameter("content"), order == null ? 0 : order);
        dto.setDurationMinutes(readInteger(req.getParameter("durationMinutes")));
        dto.setType(req.getParameter("type"));
        dto.setVideoUrl(req.getParameter("videoUrl"));
        dto.setQuizId(ControllerSupport.optionalUuid(req.getParameter("quizId")));
        var result = lessonService.saveLesson(expertId, courseId, dto);
        if (!result.saved()) {
            req.setAttribute("fieldErrors", result.errors());
            if (result.errors().isEmpty()) req.setAttribute("saveError", "Can not save lesson.");
            resp.setStatus(result.errors().isEmpty()
                    ? HttpServletResponse.SC_INTERNAL_SERVER_ERROR : HttpServletResponse.SC_BAD_REQUEST);
            showForm(req, resp, expertId, courseId, dto);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/expert/lessons?submitted=true&courseId=" + courseId);
    }
}
