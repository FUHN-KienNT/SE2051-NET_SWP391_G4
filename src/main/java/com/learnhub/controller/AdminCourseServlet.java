package com.learnhub.controller;

import com.learnhub.entity.Course;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.DashboardService;
import com.learnhub.util.CloudinaryClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet handling Course Management & Course Detail for Managers and Experts.
 * Implements methods specified in SDS Course Management (2.4, 2.4.1):
 * - View Course List & Course Detail
 * - Update Course Info (Title, Category, Price, Status, Cloudinary Thumbnail, Description)
 * - Inspect Curriculum (Sections, Lessons, Quizzes)
 * - Save Changes to PostgreSQL
 * - Publish / Unpublish Course
 * - Back to List navigation
 */
@WebServlet(name = "AdminCourseServlet", urlPatterns = {"/manager/courses", "/manager/course-status", "/manager/course-detail"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 20,      // 20MB
        maxRequestSize = 1024 * 1024 * 30    // 30MB
)
public class AdminCourseServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminCourseServlet.class.getName());
    private final CourseService courseService = new CourseService();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), null);
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!isAuthorizedRole(currentUser, role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager or Expert privileges required.");
            return;
        }

        String path = req.getServletPath();
        String action = req.getParameter("action");

        if ("/manager/course-detail".equals(path)) {
            handleCourseDetail(req, resp);
            return;
        }

        if ("get-json".equalsIgnoreCase(action)) {
            handleGetCourseJson(req, resp);
            return;
        }

        // View Course List with filters, search, sort, pagination
        String search = req.getParameter("search");
        String categoryIdStr = req.getParameter("categoryId");
        if (categoryIdStr == null || categoryIdStr.isBlank()) {
            categoryIdStr = req.getParameter("category");
        }
        String status = req.getParameter("status");
        String priceType = req.getParameter("priceType");
        String sortBy = req.getParameter("sortBy");
        String sortOrder = req.getParameter("sortOrder");

        UUID categoryId = ControllerSupport.optionalUuid(categoryIdStr);

        if (sortBy == null || sortBy.isBlank()) {
            sortBy = "created_at";
        }
        if (sortOrder == null || sortOrder.isBlank()) {
            sortOrder = "desc";
        }

        int page = ControllerSupport.pageNumber(req.getParameter("page"));
        int pageSize = 10;

        List<Course> courses = courseService.getCoursesForManagement(
                search, categoryId, status, priceType, sortBy, sortOrder, page, pageSize
        );
        int totalCourses = courseService.countCoursesForManagement(search, categoryId, status, priceType);
        int totalPages = (int) Math.ceil((double) totalCourses / pageSize);

        List<Setting> categories = courseService.getActiveCategories();
        List<User> instructors = courseService.getAllInstructors();

        req.setAttribute("courses", courses);
        req.setAttribute("categories", categories);
        req.setAttribute("instructors", instructors);
        req.setAttribute("search", search);
        req.setAttribute("selectedCategory", categoryIdStr);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("selectedPriceType", priceType);
        req.setAttribute("sortBy", sortBy);
        req.setAttribute("sortOrder", sortOrder);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalCourses", totalCourses);
        req.setAttribute("pageTitle", "Course management – LearnHub");

        // Flash parameters
        if ("true".equals(req.getParameter("status_success"))) {
            req.setAttribute("successMessage", "Trạng thái khóa học đã được cập nhật thành công!");
        } else if ("true".equals(req.getParameter("save_success"))) {
            req.setAttribute("successMessage", "Thông tin khóa học đã được lưu thành công!");
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/course-list.jsp").forward(req, resp);
    }

    private void handleCourseDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        Course course = null;
        if (idStr != null && !idStr.isBlank()) {
            try {
                UUID courseId = UUID.fromString(idStr.trim());
                course = courseService.getCourseDetailWithCurriculum(courseId);
            } catch (Exception ignored) {
            }
        }

        if (course == null) {
            if ("new".equalsIgnoreCase(req.getParameter("action")) || idStr == null || idStr.isBlank()) {
                course = new Course();
                course.setStatus("draft");
            } else {
                resp.sendRedirect(req.getContextPath() + "/manager/courses?error=course_not_found");
                return;
            }
        }

        List<Setting> categories = courseService.getActiveCategories();
        List<User> instructors = courseService.getAllInstructors();

        req.setAttribute("course", course);
        req.setAttribute("categories", categories);
        req.setAttribute("instructors", instructors);
        req.setAttribute("pageTitle", "Course Detail - " + (course.getId() != null ? course.getCourseCode() : "New Course"));

        if ("true".equals(req.getParameter("save_success"))) {
            req.setAttribute("successMessage", "Thông tin khóa học đã được cập nhật thành công!");
        } else if ("true".equals(req.getParameter("status_success"))) {
            req.setAttribute("successMessage", "Trạng thái công khai khóa học đã được cập nhật!");
        } else if ("missing_title".equals(req.getParameter("error"))) {
            req.setAttribute("errorMessage", "Tên khóa học (Course Title) không được để trống.");
        } else if ("save_failed".equals(req.getParameter("error"))) {
            req.setAttribute("errorMessage", "Không thể lưu khóa học. Vui lòng kiểm tra lại thông tin.");
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/course-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!isAuthorizedRole(currentUser, role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = req.getServletPath();
        String action = req.getParameter("action");

        if ("publish".equalsIgnoreCase(action) || "unpublish".equalsIgnoreCase(action)) {
            handlePublishToggle(req, resp, currentUser, "publish".equalsIgnoreCase(action));
        } else if ("/manager/course-status".equals(path) || "status".equalsIgnoreCase(action)) {
            handleChangeStatus(req, resp, currentUser);
        } else if ("save".equalsIgnoreCase(action) || "/manager/course-detail".equals(path)) {
            handleSaveCourse(req, resp, currentUser);
        } else {
            resp.sendRedirect(req.getContextPath() + "/manager/courses");
        }
    }

    private void handlePublishToggle(HttpServletRequest req, HttpServletResponse resp, User actor, boolean publish) throws IOException {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isBlank()) {
            try {
                UUID courseId = UUID.fromString(idStr.trim());
                Course course = courseService.getCourseById(courseId);
                if (course != null) {
                    String newStatus = publish ? "published" : "draft";
                    boolean success = courseService.updateCourseStatus(courseId, newStatus);
                    if (success) {
                        dashboardService.logEvent(
                                actor.getEmail(),
                                "COURSE_STATUS_CHANGE",
                                (publish ? "Published" : "Unpublished") + " course: " + course.getTitle(),
                                "SUCCESS"
                        );
                        resp.sendRedirect(req.getContextPath() + "/manager/course-detail?id=" + courseId + "&status_success=true");
                        return;
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error toggling course publication status: " + e.getMessage(), e);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/manager/courses?error=status_failed");
    }

    private void handleChangeStatus(HttpServletRequest req, HttpServletResponse resp, User actor) throws IOException {
        String idStr = req.getParameter("courseId");
        if (idStr == null || idStr.isBlank()) {
            idStr = req.getParameter("id");
        }
        String status = req.getParameter("status");

        if (idStr != null && status != null) {
            try {
                UUID courseId = UUID.fromString(idStr.trim());
                Course course = courseService.getCourseById(courseId);
                if (course != null) {
                    boolean success = courseService.updateCourseStatus(courseId, status);
                    if (success) {
                        dashboardService.logEvent(
                                actor.getEmail(),
                                "COURSE_STATUS_CHANGE",
                                "Đổi trạng thái khóa học '" + course.getTitle() + "' sang: " + status,
                                "SUCCESS"
                        );
                        resp.sendRedirect(req.getContextPath() + "/manager/courses?status_success=true");
                        return;
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error updating course status: " + e.getMessage(), e);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/manager/courses?error=status_failed");
    }

    private void handleSaveCourse(HttpServletRequest req, HttpServletResponse resp, User actor) throws IOException {
        String idStr = req.getParameter("id");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String priceStr = req.getParameter("price");
        String thumbnailUrl = req.getParameter("thumbnailUrl");
        String categoryIdStr = req.getParameter("categoryId");
        String expertIdStr = req.getParameter("expertId");
        String status = req.getParameter("status");

        boolean isDetailRequest = "/manager/course-detail".equals(req.getServletPath()) || "detail".equalsIgnoreCase(req.getParameter("source"));

        if (title == null || title.trim().isEmpty()) {
            if (isDetailRequest && idStr != null && !idStr.isBlank()) {
                resp.sendRedirect(req.getContextPath() + "/manager/course-detail?id=" + idStr + "&error=missing_title");
            } else {
                resp.sendRedirect(req.getContextPath() + "/manager/courses?error=missing_title");
            }
            return;
        }

        // Handle Cloudinary file upload if present
        try {
            Part filePart = req.getPart("thumbnailFile");
            if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isBlank()) {
                String filename = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                try (InputStream is = filePart.getInputStream()) {
                    String uploadedUrl = CloudinaryClient.uploadFile(is, filename);
                    if (uploadedUrl != null && !uploadedUrl.isBlank()) {
                        thumbnailUrl = uploadedUrl;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Thumbnail upload issue: " + e.getMessage());
        }

        BigDecimal price = BigDecimal.ZERO;
        if (priceStr != null && !priceStr.trim().isEmpty()) {
            try {
                price = new BigDecimal(priceStr.trim());
                if (price.compareTo(BigDecimal.ZERO) < 0) {
                    price = BigDecimal.ZERO;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        UUID categoryId = ControllerSupport.optionalUuid(categoryIdStr);

        UUID expertId = ControllerSupport.optionalUuid(expertIdStr);

        if (status == null || status.isBlank()) {
            status = "draft";
        }

        boolean isUpdate = idStr != null && !idStr.trim().isEmpty();

        // Preserve previous thumbnail if not updated
        if (isUpdate && (thumbnailUrl == null || thumbnailUrl.isBlank())) {
            try {
                Course existing = courseService.getCourseById(UUID.fromString(idStr.trim()));
                if (existing != null) {
                    thumbnailUrl = existing.getThumbnailUrl();
                }
            } catch (Exception ignored) {}
        }

        Course course = new Course();
        course.setTitle(title.trim());
        course.setDescription(description != null ? description.trim() : "");
        course.setPrice(price);
        course.setThumbnailUrl(thumbnailUrl != null ? thumbnailUrl.trim() : "");
        course.setCategoryId(categoryId);
        course.setExpertId(expertId);
        course.setStatus(status.trim().toLowerCase());

        boolean result;
        UUID savedId = null;

        if (isUpdate) {
            try {
                UUID courseId = UUID.fromString(idStr.trim());
                course.setId(courseId);
                savedId = courseId;
                result = courseService.updateCourse(course);
                if (result) {
                    dashboardService.logEvent(
                            actor.getEmail(),
                            "COURSE_UPDATE",
                            "Cập nhật khóa học: " + course.getTitle(),
                            "SUCCESS"
                    );
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error updating course: " + e.getMessage(), e);
                result = false;
            }
        } else {
            savedId = UUID.randomUUID();
            course.setId(savedId);
            course.setCreatedBy(actor.getId());
            result = courseService.createCourse(course);
            if (result) {
                dashboardService.logEvent(
                        actor.getEmail(),
                        "COURSE_CREATE",
                        "Tạo khóa học mới: " + course.getTitle(),
                        "SUCCESS"
                );
            }
        }

        if (result) {
            if (isDetailRequest && savedId != null) {
                resp.sendRedirect(req.getContextPath() + "/manager/course-detail?id=" + savedId + "&save_success=true");
            } else {
                resp.sendRedirect(req.getContextPath() + "/manager/courses?save_success=true");
            }
        } else {
            if (isDetailRequest && idStr != null && !idStr.isBlank()) {
                resp.sendRedirect(req.getContextPath() + "/manager/course-detail?id=" + idStr + "&error=save_failed");
            } else {
                resp.sendRedirect(req.getContextPath() + "/manager/courses?error=save_failed");
            }
        }
    }

    private void handleGetCourseJson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        resp.setContentType("application/json;charset=UTF-8");
        if (idStr != null && !idStr.isBlank()) {
            try {
                UUID courseId = UUID.fromString(idStr.trim());
                Course course = courseService.getCourseById(courseId);
                if (course != null) {
                    String json = String.format(
                            "{\"id\":\"%s\",\"title\":\"%s\",\"description\":\"%s\",\"price\":%s,\"thumbnailUrl\":\"%s\",\"categoryId\":\"%s\",\"expertId\":\"%s\",\"status\":\"%s\"}",
                            course.getId(),
                            escapeJson(course.getTitle()),
                            escapeJson(course.getDescription() != null ? course.getDescription() : ""),
                            course.getPrice() != null ? course.getPrice().toPlainString() : "0",
                            escapeJson(course.getThumbnailUrl() != null ? course.getThumbnailUrl() : ""),
                            course.getCategoryId() != null ? course.getCategoryId() : "",
                            course.getExpertId() != null ? course.getExpertId() : "",
                            course.getStatus()
                    );
                    resp.getWriter().write(json);
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.getWriter().write("{\"error\":\"not_found\"}");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private boolean isAuthorizedRole(User user, String role) {
        if (user == null) return false;
        String rCode = user.getRoleCode() != null ? user.getRoleCode() : "";
        String rName = user.getRoleName() != null ? user.getRoleName() : "";
        String sRole = role != null ? role : "";

        return "ROLE_MANAGER".equalsIgnoreCase(rCode)
                || "ROLE_EXPERT".equalsIgnoreCase(rCode)
                || "manager".equalsIgnoreCase(sRole)
                || "expert".equalsIgnoreCase(sRole)
                || "Manager".equalsIgnoreCase(rName);
    }
}
