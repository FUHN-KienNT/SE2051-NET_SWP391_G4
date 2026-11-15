package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.DashboardDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.dto.DashboardDTO;
import com.learnhub.dto.ManagerDashboardDTO;
import com.learnhub.entity.AuditLog;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.User;
import com.google.gson.Gson;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;

/**
 * Service layer for Admin and Manager Dashboards.
 * Orchestrates DAO calls, applies date-range filtering,
 * and computes period-over-period growth percentages.
 *
 * Supported dateRange values: "today" | "week" | "month" | "quarter" | "all"
 */
public class DashboardService {

    private static final Logger LOGGER = Logger.getLogger(DashboardService.class.getName());

    private final DashboardDAO dashboardDAO;
    private final UserDAO userDAO;
    private final CourseDAO courseDAO;
    private final LessonDAO lessonDAO;
    private final RegistrationDAO registrationDAO;
    private final SettingDAO settingDAO;

    public DashboardService() {
        this.dashboardDAO = new DashboardDAO();
        this.userDAO = new UserDAO();
        this.courseDAO = new CourseDAO();
        this.lessonDAO = new LessonDAO();
        this.registrationDAO = new RegistrationDAO();
        this.settingDAO = new SettingDAO();
    }

    public DashboardService(DashboardDAO dashboardDAO, UserDAO userDAO) {
        this.dashboardDAO = dashboardDAO;
        this.userDAO = userDAO;
        this.courseDAO = new CourseDAO();
        this.lessonDAO = new LessonDAO();
        this.registrationDAO = new RegistrationDAO();
        this.settingDAO = new SettingDAO();
    }


    /**
     * Build a fully-populated DashboardDTO for the given date range.
     *
     * @param dateRange "today" | "week" | "month" (defaults to "month" if null/unknown)
     */
    public DashboardDTO buildDashboard(String dateRange) {
        // Bước 1: Chuẩn hóa tham số khoảng thời gian lọc (mặc định là 'month')
        if (dateRange == null || dateRange.isBlank()) {
            dateRange = "month";
        }

        DashboardDTO dto = new DashboardDTO();
        dto.setDateRange(dateRange);

        // Bước 2: Xác định các mốc thời gian hiện tại và kỳ trước để tính tăng trưởng
        LocalDate today = LocalDate.now();
        Timestamp currentFrom;
        Timestamp currentTo;
        Timestamp previousFrom;
        Timestamp previousTo;

        switch (dateRange) {
            case "today":
                currentFrom  = Timestamp.valueOf(today.atStartOfDay());
                currentTo    = Timestamp.valueOf(today.atTime(LocalTime.MAX));
                previousFrom = Timestamp.valueOf(today.minusDays(1).atStartOfDay());
                previousTo   = Timestamp.valueOf(today.minusDays(1).atTime(LocalTime.MAX));
                break;
            case "week":
                currentFrom  = Timestamp.valueOf(today.minusDays(6).atStartOfDay());
                currentTo    = Timestamp.valueOf(LocalDateTime.now());
                previousFrom = Timestamp.valueOf(today.minusDays(13).atStartOfDay());
                previousTo   = Timestamp.valueOf(today.minusDays(7).atStartOfDay());
                break;
            default: // "month"
                dateRange = "month";
                dto.setDateRange("month");
                currentFrom  = Timestamp.valueOf(today.withDayOfMonth(1).atStartOfDay());
                currentTo    = Timestamp.valueOf(LocalDateTime.now());
                previousFrom = Timestamp.valueOf(today.minusMonths(1).withDayOfMonth(1).atStartOfDay());
                previousTo   = Timestamp.valueOf(today.withDayOfMonth(1).atStartOfDay());
                break;
        }

        // ── User metrics ──────────────────────────────────────────────────────────

        int totalUsers  = dashboardDAO.countTotalUsers();
        int activeUsers = dashboardDAO.countActiveUsers();
        dto.setTotalUsers(totalUsers);
        dto.setActiveUsers(activeUsers);

        int currentNewUsers  = dashboardDAO.countUsersCreatedBetween(currentFrom, currentTo);
        int previousNewUsers = dashboardDAO.countUsersCreatedBetween(previousFrom, previousTo);
        dto.setUserGrowthPct(growthPct(currentNewUsers, previousNewUsers));

        // ── Course metrics ────────────────────────────────────────────────────────

        dto.setActiveCourses(dashboardDAO.countActiveCourses());

        // ── Enrollment metrics ────────────────────────────────────────────────────

        long currentEnrollments  = dashboardDAO.countEnrollments(currentFrom, currentTo);
        long previousEnrollments = dashboardDAO.countEnrollments(previousFrom, previousTo);
        dto.setTotalEnrollments(dashboardDAO.countTotalEnrollments());
        dto.setEnrollmentGrowthPct(growthPct(currentEnrollments, previousEnrollments));

        // ── Revenue metrics ───────────────────────────────────────────────────────

        BigDecimal revenue = dashboardDAO.getRevenue(currentFrom, currentTo);
        dto.setMonthlyRevenue(revenue);

        // ── Pending registrations ─────────────────────────────────────────────────

        dto.setPendingRegistrations(dashboardDAO.countPendingRegistrations());

        // ── Recent audit logs ─────────────────────────────────────────────────────

        List<AuditLog> logs = dashboardDAO.getRecentAuditLogs(10);
        dto.setRecentLogs(logs);

        
        // Charts Data
        Object[] revData = dashboardDAO.getRevenueLast6Months();
        List<String> revLabels = (List<String>) revData[0];
        List<BigDecimal> revValues = (List<BigDecimal>) revData[1];
        
        Object[] enrData = dashboardDAO.getEnrollmentsByCategory();
        List<String> enrLabels = (List<String>) enrData[0];
        List<Long> enrValues = (List<Long>) enrData[1];
        
        Gson gson = new Gson();
        dto.setRevenueLabelsJson(gson.toJson(revLabels));
        dto.setRevenueDataJson(gson.toJson(revValues));
        dto.setEnrollmentLabelsJson(gson.toJson(enrLabels));
        dto.setEnrollmentDataJson(gson.toJson(enrValues));

        // Quick Access Users (Top 5 most recent)
        List<User> recentUsers = userDAO.findUsers("", null, "", 0, 5);
        dto.setRecentUsers(recentUsers);

        return dto;
    }

    /**
     * Write a system event to the audit_log table.
     */
    public void logEvent(String actor, String actionType, String description, String status) {
        try {
            dashboardDAO.insertAuditLog(actor, actionType, description, status);
        } catch (Exception e) {
            LOGGER.warning("Failed to write audit log: " + e.getMessage());
        }
    }

    /**
     * Build a fully-populated ManagerDashboardDTO for the Manager Dashboard.
     *
     * @param period "month" | "quarter" | "all"
     * @param search course title or code search keyword
     * @param categoryIdStr category UUID string filter
     */
    public ManagerDashboardDTO buildManagerDashboard(String period, String search, String categoryIdStr) {
        // Bước 1: Chuẩn hóa bộ lọc thời gian và từ khóa tìm kiếm
        if (period == null || period.isBlank()) {
            period = "month";
        }

        ManagerDashboardDTO dto = new ManagerDashboardDTO();
        dto.setDateRange(period);
        dto.setSearch(search != null ? search.trim() : "");
        dto.setSelectedCategory(categoryIdStr != null ? categoryIdStr.trim() : "");

        // Bước 2: Xác định khoảng thời gian cho kỳ hiện tại và kỳ đối chiếu
        LocalDate today = LocalDate.now();
        Timestamp currentFrom;
        Timestamp currentTo;
        Timestamp previousFrom;
        Timestamp previousTo;

        if ("quarter".equalsIgnoreCase(period)) {
            currentFrom  = Timestamp.valueOf(today.minusMonths(3).atStartOfDay());
            currentTo    = Timestamp.valueOf(LocalDateTime.now());
            previousFrom = Timestamp.valueOf(today.minusMonths(6).atStartOfDay());
            previousTo   = Timestamp.valueOf(today.minusMonths(3).atStartOfDay());
        } else if ("all".equalsIgnoreCase(period)) {
            currentFrom  = Timestamp.valueOf(LocalDate.of(2000, 1, 1).atStartOfDay());
            currentTo    = Timestamp.valueOf(LocalDateTime.now());
            previousFrom = currentFrom;
            previousTo   = currentTo;
        } else { // "month"
            period = "month";
            dto.setDateRange("month");
            currentFrom  = Timestamp.valueOf(today.withDayOfMonth(1).atStartOfDay());
            currentTo    = Timestamp.valueOf(LocalDateTime.now());
            previousFrom = Timestamp.valueOf(today.minusMonths(1).withDayOfMonth(1).atStartOfDay());
            previousTo   = Timestamp.valueOf(today.withDayOfMonth(1).atStartOfDay());
        }

        // 1. Metric Cards
        int totalCourses = courseDAO.countTotalCourses();
        int publishedCourses = courseDAO.countPublishedCourses();
        int unpublishedCourses = courseDAO.countUnpublishedCourses();
        int pendingReviewsCount = lessonDAO.countCoursesAwaitingReview();
        int unassignedCoursesCount = courseDAO.countUnassignedCourses();
        long totalEnrollments = dashboardDAO.countTotalEnrollments();

        long currentEnrollments = dashboardDAO.countEnrollments(currentFrom, currentTo);
        long previousEnrollments = dashboardDAO.countEnrollments(previousFrom, previousTo);
        Double growth = growthPct(currentEnrollments, previousEnrollments);

        dto.setTotalCourses(totalCourses);
        dto.setPublishedCourses(publishedCourses);
        dto.setUnpublishedCourses(unpublishedCourses);
        dto.setPendingReviewsCount(pendingReviewsCount);
        dto.setUnassignedCoursesCount(unassignedCoursesCount);
        dto.setTotalEnrollments(totalEnrollments);
        dto.setEnrollmentGrowthPct(growth != null ? growth : 0.0);

        // 2. Action Queues
        dto.setPendingReviews(lessonDAO.findCoursesAwaitingReview(5));
        dto.setUnassignedCourses(courseDAO.findUnassignedCourses(5));

        // 3. Course Catalog Table
        UUID catId = null;
        if (categoryIdStr != null && !categoryIdStr.isBlank()) {
            try {
                catId = UUID.fromString(categoryIdStr.trim());
            } catch (Exception ignored) {}
        }
        List<Course> catalog = courseDAO.findAllCoursesForManagement(search, catId, null, null, "created_at", "desc", 0, 10);
        int totalCatalog = courseDAO.countAllCoursesForManagement(search, catId, null, null);
        dto.setCourses(catalog);
        dto.setTotalCatalogCourses(totalCatalog);

        // 4. Student Registrations Feed (All records, displayed with scrollable viewport)
        List<Registration> recent = registrationDAO.findRegistrations("", "all", 0, 0);
        dto.setRecentEnrollments(recent);

        // 5. Lookups
        dto.setInstructors(userDAO.findInstructors());
        dto.setCategories(settingDAO.findActiveCategories());

        return dto;
    }

    /**
     * Gán giảng viên chuyên gia (Expert) phụ trách nội dung khóa học.
     *
     * @param courseId     ID khóa học cần phân công
     * @param expertId     ID tài khoản chuyên gia (hoặc null nếu hủy phân công)
     * @param managerEmail Email của quản lý thực hiện thao tác
     * @return true nếu phân công thành công, false nếu thất bại
     */
    public boolean assignExpertToCourse(UUID courseId, UUID expertId, String managerEmail) {
        // Bước 1: Kiểm tra tham số đầu vào
        if (courseId == null) {
            return false;
        }

        // Bước 2: Kiểm tra tính hợp lệ của Expert
        if (expertId != null && !userDAO.isExpert(expertId)) {
            LOGGER.warning("Cannot assign expert: user " + expertId + " is not an active expert");
            return false;
        }

        // Bước 3: Cập nhật cơ sở dữ liệu và ghi nhật ký kiểm toán
        boolean ok = courseDAO.assignExpert(courseId, expertId);
        if (ok) {
            Course c = courseDAO.findById(courseId);
            String title = c != null ? c.getTitle() : courseId.toString();
            logEvent(managerEmail, "ASSIGN_EXPERT", "Assigned expert to course: " + title, "SUCCESS");
        }
        return ok;
    }

    /**
     * Đổi trạng thái phát hành của khóa học (published, draft, archived).
     *
     * @param courseId     ID khóa học
     * @param newStatus    Trạng thái mới
     * @param managerEmail Email của quản lý thực hiện
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean toggleCourseStatus(UUID courseId, String newStatus, String managerEmail) {
        // Bước 1: Kiểm tra tham số đầu vào
        if (courseId == null || newStatus == null) {
            return false;
        }

        // Bước 2: Cập nhật trạng thái và ghi audit log
        boolean ok = courseDAO.updateStatus(courseId, newStatus);
        if (ok) {
            Course c = courseDAO.findById(courseId);
            String title = c != null ? c.getTitle() : courseId.toString();
            logEvent(managerEmail, "COURSE_STATUS_CHANGE", "Changed status of course '" + title + "' to " + newStatus, "SUCCESS");
        }
        return ok;
    }

    // -------------------------------------------------------------------------
    // Private Helpers
    // -------------------------------------------------------------------------

    /**
     * Tính toán phần trăm tăng trưởng từ giá trị kỳ trước sang kỳ hiện tại.
     * Trả về null nếu không có mốc so sánh (previous == 0).
     *
     * @param current  Số liệu kỳ hiện tại
     * @param previous Số liệu kỳ trước
     * @return Tỷ lệ phần trăm tăng/giảm (+/- %)
     */
    private Double growthPct(long current, long previous) {
        if (previous == 0) {
            return null;
        }
        double pct = ((double) (current - previous) / previous) * 100.0;
        return BigDecimal.valueOf(pct).setScale(1, RoundingMode.HALF_UP).doubleValue();
    }
}
