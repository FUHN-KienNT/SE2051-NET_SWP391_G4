package com.learnhub.controller;

import com.learnhub.dto.CourseDTO;
import com.learnhub.dto.PageResult;
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

/**
 * Course Servlet handling public courses list and detail.
 * Matches CourseController in SDS Course Browsing Class Diagram:
 * - getPublicCourses()
 * - getPublicCourseDetail()
 * - registerCourse()
 */
@WebServlet(name = "CourseServlet", urlPatterns = {"/courses", "/course-detail", "/courses/register"})
public class CourseServlet extends HttpServlet {
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/course-detail".equals(path)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    UUID courseId = UUID.fromString(idStr);
                    Course course = courseService.getCourseDetailWithCurriculum(courseId);
                    req.setAttribute("course", course);
                    req.getRequestDispatcher("/WEB-INF/views/courses/detail.jsp").forward(req, resp);
                    return;
                } catch (IllegalArgumentException ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        // Default: /courses
        String search = req.getParameter("search");
        String categoryIdStr = req.getParameter("category");
        String pageStr = req.getParameter("page");

        UUID categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = UUID.fromString(categoryIdStr);
            } catch (Exception ignored) {
            }
        }

        int page = 1;
        if (pageStr != null) {
            try { page = Integer.parseInt(pageStr); } catch (Exception ignored) {}
        }

        PageResult<CourseDTO> pageResult = courseService.searchPublicCourses(search, categoryId, page, 9);
        List<Setting> categories = courseService.getActiveCategories();

        req.setAttribute("pageResult", pageResult);
        req.setAttribute("categories", categories);
        req.setAttribute("search", search);
        req.setAttribute("selectedCategory", categoryIdStr);

        req.getRequestDispatcher("/WEB-INF/views/courses/list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=must_login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr != null) {
            try {
                UUID courseId = UUID.fromString(courseIdStr);
                Registration reg = courseService.processCourseRegistration(currentUser.getId(), courseId, null);
                if (reg != null) {
                    resp.sendRedirect(req.getContextPath() + "/checkout?registrationId=" + reg.getId());
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
