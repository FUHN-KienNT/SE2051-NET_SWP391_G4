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
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "CourseServlet", urlPatterns = {
    "/courses",
    "/course-detail",
    "/courses/register",
    "/expert/dashboard",
        "/learn/course"
})
public class CourseServlet extends HttpServlet {

    private final CourseService courseService = new CourseService();
    private final LearningProcessService learningService = new LearningProcessService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/course-detail":
                handleCourseDetail(req, resp);
                break;
            case "/expert/dashboard":
                handleExpertDashboard(req, resp);
                break;
            case "/learn/course":
                handleMyCourseDetail(req, resp);
                break;
            case "/courses":
            default:
                handleCourseList(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/courses/register".equals(path)) {
            handleCourseRegister(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/courses");
        }
    }

    private void handleExpertDashboard(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), "must_login");
            return;
        }
        UUID expertId = currentUser.getId();
        int page = 1;
        int pageSize = 8;
        String pageStr = req.getParameter("page");
        if (pageStr != null) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {
            }
        }
        String search = req.getParameter("search");
        search = search == null ? "" : search.strip();
        int totalCourses = courseService.countAssignedCourses(expertId, null, search);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalCourses / pageSize));
        page = Math.min(page, totalPages);
        List<Course> courses = courseService.getAssignedCourses(expertId, page, pageSize, search);
        int publishedCourses = courseService.countAssignedCourses(expertId, "published", search);
        int draftCourses = courseService.countAssignedCourses(expertId, "draft", search);
        int archivedCourse = courseService.countAssignedCourses(expertId, "archived", search);
        req.setAttribute("search", search);
        req.setAttribute("courses", courses);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalCourses", totalCourses);
        req.setAttribute("publishedCourses", publishedCourses);
        req.setAttribute("draftCourses", draftCourses);
        req.setAttribute("archivedCourses", archivedCourse);
        req.getRequestDispatcher("/WEB-INF/views/expert/dashboard.jsp").forward(req, resp);
    }

    private void handleCourseList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("detail".equals(action)) {
            handleCourseDetail(req, resp);
            return;
        }

        String search = req.getParameter("search");
        // Hỗ trợ cả 2 tên param categoryId và category
        String categoryIdStr = req.getParameter("categoryId");
        if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            categoryIdStr = req.getParameter("category");
        }

        String pageStr = req.getParameter("page");
        UUID categoryId = ControllerSupport.optionalUuid(categoryIdStr);
        int page = 1;
        int pageSize = 9;
        if (pageStr != null) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr.trim()));
            } catch (Exception ignored) {
            }
        }

        List<CourseDTO> courses = courseService.searchPublicCourses(search, categoryId, page, pageSize);
        int totalCourses = courseService.countPublicCourses(search, categoryId);
        int totalPages = (int) Math.ceil((double) totalCourses / pageSize);

        List<Setting> categories = courseService.getActiveCategories();
        req.setAttribute("courses", courses);
        req.setAttribute("categories", categories);
        req.setAttribute("search", search);
        req.setAttribute("categoryId", categoryIdStr);
        req.setAttribute("selectedCategory", categoryIdStr);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalCourses", totalCourses);

        req.getRequestDispatcher("/WEB-INF/views/courses/list.jsp").forward(req, resp);
    }

    private void handleCourseDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr != null) {
            try {
                UUID courseId = UUID.fromString(idStr);
                Course course = courseService.getPublishedCourseCurriculum(courseId);
                if (course != null) {
                    req.setAttribute("course", course);

                    // Kiểm tra user đã đăng ký khóa học chưa
                    User user = ControllerSupport.currentUser(req);
                    if (user != null && AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode())
                            && learningService.findEnrolledCourse(user.getId(), courseId) != null) {
                        resp.sendRedirect(req.getContextPath() + "/learn/course?id=" + courseId);
                        return;
                    }

                    req.setAttribute("pageTitle", course.getTitle() + " - LearnHub");
                    req.getRequestDispatcher("/WEB-INF/views/courses/detail.jsp").forward(req, resp);
                    return;
                } else {
                    resp.setContentType("text/plain;charset=UTF-8");
                    resp.getWriter().write("DEBUG: course is null for courseId=" + courseId);
                    return;
                }
            } catch (Exception e) {
                throw new ServletException("Error loading course details", e);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }

    private void handleCourseRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), "must_login");
            return;
        }
        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr != null) {
            try {
                UUID courseId = UUID.fromString(courseIdStr);
                Registration reg = courseService.processCourseRegistration(currentUser.getId(), courseId, null);
                if (reg != null) {
                    boolean canLearn = learningService.findEnrolledCourse(
                            currentUser.getId(), courseId) != null;
                    resp.sendRedirect(req.getContextPath() + (canLearn
                            ? "/learn/course?id=" + courseId
                            : "/my-enrollments"));
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }
    private void handleMyCourseDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = ControllerSupport.currentUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth/login"); return; }
        if (!AppConstants.Role.STUDENT.equalsIgnoreCase(user.getRoleCode())) {
            resp.sendError(403); return;
        }
        UUID courseId;
        try { courseId = UUID.fromString(req.getParameter("id")); }
        catch (IllegalArgumentException | NullPointerException e) { resp.sendError(400); return; }
        ContinueLearningDTO progress = learningService.findEnrolledCourse(user.getId(), courseId);
        if (progress == null) { resp.sendError(403); return; }
        Course course = courseService.getPublishedCourseCurriculum(courseId);
        if (course == null) { resp.sendError(404); return; }
        req.setAttribute("course", course);
        req.setAttribute("progress", progress);
        req.setAttribute("myCourseDetail", true);
        req.getRequestDispatcher("/WEB-INF/views/courses/my-detail.jsp").forward(req, resp);
    }
}
