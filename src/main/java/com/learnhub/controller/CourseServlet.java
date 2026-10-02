package com.learnhub.controller;

import com.learnhub.dto.CourseDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "CourseServlet", urlPatterns = {
    "/courses",
    "/course-detail",
    "/courses/register",
    "/expert/dashboard"
})
public class CourseServlet extends HttpServlet {

    private final CourseService courseService = new CourseService();

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
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            String redirectUri = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }
            String encodedUri = java.net.URLEncoder.encode(redirectUri, "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
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
        List<Course> courses;
        int totalCourses;
        courses = courseService.getAssignedCourses(expertId, page, pageSize);
        totalCourses = courseService.countAssignedCourses(expertId);
        int totalPages = (int) Math.ceil((double) totalCourses / pageSize);
        req.setAttribute("courses", courses);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalCourses", totalCourses);
        req.getRequestDispatcher("/WEB-INF/views/expert/dashboard.jsp").forward(req, resp);
    }

    private void handleCourseList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Nếu có action=detail thì chuyển sang trang chi tiết
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
        UUID categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = UUID.fromString(categoryIdStr.trim());
            } catch (Exception ignored) {
            }
        }
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
                Course course = courseService.getCourseDetailWithCurriculum(courseId);
                if (course != null) {
                    req.setAttribute("course", course);

                    // Kiểm tra user đã đăng ký khóa học chưa
                    HttpSession session = req.getSession(false);
                    User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
                    boolean isEnrolled = false;
                    if (currentUser != null) {
                        isEnrolled = courseService.getMyEnrollments(currentUser.getId())
                                .stream()
                                .anyMatch(r -> courseId.equals(r.getCourseId()) 
                                        && ("paid".equalsIgnoreCase(r.getPaymentStatus()) 
                                            || (course.getPrice() != null && course.getPrice().compareTo(java.math.BigDecimal.ZERO) <= 0)));
                    }
                    req.setAttribute("isEnrolled", isEnrolled);

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
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            String redirectUri = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }
            String encodedUri = java.net.URLEncoder.encode(redirectUri, "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
            return;
        }
        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr != null) {
            try {
                UUID courseId = UUID.fromString(courseIdStr);
                Registration reg = courseService.processCourseRegistration(currentUser.getId(), courseId, null);
                if (reg != null) {
                    resp.sendRedirect(req.getContextPath() + "/my-enrollments");
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
