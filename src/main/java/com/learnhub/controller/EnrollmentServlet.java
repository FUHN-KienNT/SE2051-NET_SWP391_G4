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
            req.setAttribute("roleError", "Your current account (" + (roleName != null ? roleName : roleCode) + 
                    ") is not a Student. Please log in with a Student account to enroll in a course.");
            req.setAttribute("pageTitle", "Thông báo đăng ký - " + course.getTitle());
            req.getRequestDispatcher("/WEB-INF/views/courses/enrollment.jsp").forward(req, resp);
            return;
        }

        // BƯỚC 3: Kiểm tra xem học viên này đã thanh toán khóa học này trước đó chưa
        List<Registration> myEnrollments = courseService.getMyEnrollments(currentUser.getId());
        boolean isAlreadyEnrolled = myEnrollments != null && myEnrollments.stream()
                .anyMatch(r -> courseId.equals(r.getCourseId())
                        && ("paid".equalsIgnoreCase(r.getPaymentStatus())
                            || (course.getPrice() != null && course.getPrice().compareTo(java.math.BigDecimal.ZERO) <= 0)));
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

        String phone = req.getParameter("phone");
        String paymentMethodIdStr = req.getParameter("paymentMethodId");

        UUID courseId = null;
        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                courseId = UUID.fromString(courseIdStr.trim());
            } catch (IllegalArgumentException ignored) {
            }
        }

        if (courseId == null) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        Course course = courseService.getCourseDetailWithCurriculum(courseId);
        if (course == null) {
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        // VALIDATION SỐ ĐIỆN THOẠI (Bắt buộc & 10 số, đầu số hợp lệ của các nhà mạng Việt Nam)
        String phoneRegex = "^(0[35789])[0-9]{8}$";
        if (phone == null || phone.trim().isEmpty() || !phone.trim().matches(phoneRegex)) {
            String phoneErrorMsg;
            if (phone == null || phone.trim().isEmpty()) {
                phoneErrorMsg = "Vui lòng nhập số điện thoại liên hệ.";
            } else {
                phoneErrorMsg = "Số điện thoại không hợp lệ (phải gồm 10 chữ số, bắt đầu bằng 03, 05, 07, 08, 09).";
            }

            currentUser.setPhone(phone != null ? phone.trim() : "");
            req.setAttribute("course", course);
            req.setAttribute("student", currentUser);
            req.setAttribute("paymentMethods", courseService.getPaymentMethods());
            req.setAttribute("phoneError", phoneErrorMsg);
            req.setAttribute("pageTitle", "Thông tin thanh toán - " + course.getTitle());
            req.getRequestDispatcher("/WEB-INF/views/courses/enrollment.jsp").forward(req, resp);
            return;
        }

        // Cập nhật số điện thoại tạm thời vào session user
        currentUser.setPhone(phone.trim());

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
            // Sau này sẽ tích hợp điều hướng sang cổng thanh toán tương ứng (VNPay / SePay / ...)
            resp.sendRedirect(req.getContextPath() + "/my-enrollments?registered=success");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
