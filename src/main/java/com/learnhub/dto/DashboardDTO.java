package com.learnhub.dto;

import com.learnhub.entity.AuditLog;

import java.math.BigDecimal;
import java.util.List;

/**
 * Data Transfer Object for the Admin Dashboard screen.
 * Carries aggregated system statistics and recent audit log entries.
 */
public class DashboardDTO {

    // ── Metric Cards ────────────────────────────────────────────────────────────

    /** Total count of all user accounts (active + inactive). */
    private int totalUsers;

    /** Total count of active (status = 'active') user accounts. */
    private int activeUsers;

    /** Growth % of total users compared to previous period (null if no baseline). */
    private Double userGrowthPct;

    /** Count of published courses on the platform. */
    private int activeCourses;

    /** Total enrollments within the selected date range. */
    private long totalEnrollments;

    /** Growth % of enrollments compared to previous period. */
    private Double enrollmentGrowthPct;

    /** Sum of paid revenue (registration.amount where payment_status = 'paid') in the selected range. */
    private BigDecimal monthlyRevenue;

    /** Count of registrations with payment_status = 'pending'. */
    private int pendingRegistrations;

    // ── Audit Log ───────────────────────────────────────────────────────────────

    /** Last 10 audit log entries ordered by created_at DESC. */
    private List<AuditLog> recentLogs;

    // ── Filter ──────────────────────────────────────────────────────────────────

    /** Active date range filter: "today" | "week" | "month" (default: "month"). */
    private String dateRange;

    // ── Constructors ─────────────────────────────────────────────────────────────

    public DashboardDTO() {
        this.monthlyRevenue = BigDecimal.ZERO;
        this.dateRange = "month";
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────────

    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }

    public int getActiveUsers() { return activeUsers; }
    public void setActiveUsers(int activeUsers) { this.activeUsers = activeUsers; }

    public Double getUserGrowthPct() { return userGrowthPct; }
    public void setUserGrowthPct(Double userGrowthPct) { this.userGrowthPct = userGrowthPct; }

    public int getActiveCourses() { return activeCourses; }
    public void setActiveCourses(int activeCourses) { this.activeCourses = activeCourses; }

    public long getTotalEnrollments() { return totalEnrollments; }
    public void setTotalEnrollments(long totalEnrollments) { this.totalEnrollments = totalEnrollments; }

    public Double getEnrollmentGrowthPct() { return enrollmentGrowthPct; }
    public void setEnrollmentGrowthPct(Double enrollmentGrowthPct) { this.enrollmentGrowthPct = enrollmentGrowthPct; }

    public BigDecimal getMonthlyRevenue() { return monthlyRevenue; }
    public void setMonthlyRevenue(BigDecimal monthlyRevenue) {
        this.monthlyRevenue = (monthlyRevenue != null) ? monthlyRevenue : BigDecimal.ZERO;
    }

    public int getPendingRegistrations() { return pendingRegistrations; }
    public void setPendingRegistrations(int pendingRegistrations) { this.pendingRegistrations = pendingRegistrations; }

    public List<AuditLog> getRecentLogs() { return recentLogs; }
    public void setRecentLogs(List<AuditLog> recentLogs) { this.recentLogs = recentLogs; }

    public String getDateRange() { return dateRange; }
    public void setDateRange(String dateRange) { this.dateRange = dateRange; }
}
