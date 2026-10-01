package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
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
 * Servlet handling Course Enrollments and Payment Information.
 */
@WebServlet(name = "EnrollmentServlet", urlPatterns = {"/enroll", "/enrollment", "/my-enrollments"})
public class EnrollmentServlet extends HttpServlet {
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String action = req.getParameter("action");

        // 1. Nếu truy cập /my-enrollments hoặc có action=my-courses -> Dashboard khóa học đã tham gia
        if ("/my-enrollments".equals(path) || "my-courses".equals(action)) {
            handleMyEnrollments(req, resp);
            return;
        }

        // 2. Mặc định là trang hiển thị thông tin thanh toán / đăng ký khóa học (/enroll hoặc /enrollment)
        handleEnrollmentPage(req, resp);
    }

    private void handleEnrollmentPage(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        UUID courseId;
        try {
            courseId = UUID.fromString(courseIdStr.trim());
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        Course course = courseService.getCourseDetailWithCurriculum(courseId);
        if (course == null) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        // BƯỚC 1: Kiểm tra xem người dùng đã đăng nhập chưa
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER) : null;
        if (currentUser == null) {
            String redirectUri = req.getContextPath() + "/enrollment?courseId=" + courseId;
            String encodedUri = java.net.URLEncoder.encode(redirectUri, "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
            return;
        }

        // BƯỚC 2: Kiểm tra vai trò người dùng (chỉ Student mới được mua / đăng ký)
        String roleCode = currentUser.getRoleCode();
        String roleName = currentUser.getRoleName();
        boolean isStudent = (roleCode == null || roleCode.trim().isEmpty())
                || AppConstants.Role.STUDENT.equalsIgnoreCase(roleCode)
                || "Student".equalsIgnoreCase(roleName)
                || "Học viên".equalsIgnoreCase(roleName);

        if (!isStudent) {
            req.setAttribute("course", course);
            req.setAttribute("student", currentUser);
            req.setAttribute("roleError", "Tài khoản hiện tại của bạn (" + (roleName != null ? roleName : roleCode) + 
                    ") không phải là Học viên. Vui lòng đăng nhập tài khoản Student để đăng ký khóa học.");
            req.setAttribute("pageTitle", "Thông báo đăng ký - " + course.getTitle());
            req.getRequestDispatcher("/WEB-INF/views/courses/enrollment.jsp").forward(req, resp);
            return;
        }

        // BƯỚC 3: Kiểm tra xem học viên này đã đăng ký khóa học này trước đó chưa
        List<Registration> myEnrollments = courseService.getMyEnrollments(currentUser.getId());
        boolean isAlreadyEnrolled = myEnrollments != null && myEnrollments.stream()
                .anyMatch(r -> courseId.equals(r.getCourseId()));
        if (isAlreadyEnrolled) {
            resp.sendRedirect(req.getContextPath() + "/learning-process?courseId=" + courseId);
            return;
        }

        // BƯỚC 4: Lấy danh sách các phương thức thanh toán khả dụng từ DB
        List<Setting> paymentMethods = courseService.getPaymentMethods();

        req.setAttribute("course", course);
        req.setAttribute("student", currentUser);
        req.setAttribute("paymentMethods", paymentMethods);
        req.setAttribute("pageTitle", "Thông tin thanh toán - " + course.getTitle());
        req.getRequestDispatcher("/WEB-INF/views/courses/enrollment.jsp").forward(req, resp);
    }

    private void handleMyEnrollments(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER) : null;

        if (user == null) {
            String redirectUri = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }
            String encodedUri = java.net.URLEncoder.encode(redirectUri, "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
            return;
        }

        List<Registration> myEnrollments = courseService.getMyEnrollments(user.getId());
        req.setAttribute("enrollments", myEnrollments);
        req.getRequestDispatcher("/WEB-INF/views/learn/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER) : null;

        String courseIdStr = req.getParameter("courseId");
        if (currentUser == null) {
            String redirectUri = req.getContextPath() + "/enrollment?courseId=" + (courseIdStr != null ? courseIdStr : "");
            String encodedUri = java.net.URLEncoder.encode(redirectUri, "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
            return;
        }

        String paymentMethodIdStr = req.getParameter("paymentMethodId");

        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                UUID courseId = UUID.fromString(courseIdStr.trim());
                UUID paymentMethodId = null;
                if (paymentMethodIdStr != null && !paymentMethodIdStr.trim().isEmpty()) {
                    try {
                        paymentMethodId = UUID.fromString(paymentMethodIdStr.trim());
                    } catch (IllegalArgumentException ignored) {
                    }
                }

                // Xử lý tạo bản ghi đăng ký khóa học
                Registration reg = courseService.processCourseRegistration(currentUser.getId(), courseId, paymentMethodId);
                if (reg != null) {
                    // Sau này sẽ tích hợp điều hướng sang cổng thanh toán tương ứng (VNPay / MoMo / ...)
                    resp.sendRedirect(req.getContextPath() + "/my-enrollments?registered=success");
                    return;
                }
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
