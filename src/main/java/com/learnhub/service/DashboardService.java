package com.learnhub.service;

import com.learnhub.dao.DashboardDAO;
import com.learnhub.dto.DashboardDTO;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.User;
import com.google.gson.Gson;

import com.learnhub.entity.AuditLog;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.logging.Logger;

/**
 * Service layer for the Admin Dashboard (SDS 2.3).
 * Orchestrates DAO calls, applies date-range filtering,
 * and computes period-over-period growth percentages.
 *
 * Supported dateRange values: "today" | "week" | "month"
 */
public class DashboardService {

    private static final Logger LOGGER = Logger.getLogger(DashboardService.class.getName());

    private final DashboardDAO dashboardDAO;
    private final UserDAO userDAO;

    public DashboardService() {
        this.dashboardDAO = new DashboardDAO();
        this.userDAO = new UserDAO();
    }

    public DashboardService(DashboardDAO dashboardDAO, UserDAO userDAO) {
        this.dashboardDAO = dashboardDAO;
        this.userDAO = userDAO;
    }


    /**
     * Build a fully-populated DashboardDTO for the given date range.
     *
     * @param dateRange "today" | "week" | "month" (defaults to "month" if null/unknown)
     */
    public DashboardDTO buildDashboard(String dateRange) {
        if (dateRange == null || dateRange.isBlank()) dateRange = "month";

        DashboardDTO dto = new DashboardDTO();
        dto.setDateRange(dateRange);

        // ── Compute current and previous time window ──────────────────────────────

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

    // ── Private Helpers ──────────────────────────────────────────────────────────

    /**
     * Compute percentage growth from previous to current value.
     * Returns null if there is no baseline (previous == 0).
     */
    private Double growthPct(long current, long previous) {
        if (previous == 0) return null;
        double pct = ((double)(current - previous) / previous) * 100.0;
        return BigDecimal.valueOf(pct).setScale(1, RoundingMode.HALF_UP).doubleValue();
    }
}
