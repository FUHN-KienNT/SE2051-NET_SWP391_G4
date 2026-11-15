package com.learnhub.dto;

import com.learnhub.entity.AuditLog;

import java.math.BigDecimal;
import java.util.List;
import com.learnhub.entity.User;

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

    private String revenueLabelsJson = "[]";
    private String revenueDataJson = "[]";
    private String enrollmentLabelsJson = "[]";
    private String enrollmentDataJson = "[]";
    private List<User> recentUsers;


    // ── Constructors ─────────────────────────────────────────────────────────────

    /**
     * Creates an instance with the supplied values.
     */
    public DashboardDTO() {
        this.monthlyRevenue = BigDecimal.ZERO;
        this.dateRange = "month";
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────────

    /**
     * Returns total users.
     *
     * @return the total users
     */
    public int getTotalUsers() { return totalUsers; }
    /**
     * Sets total users.
     *
     * @param totalUsers the total users
     */
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }

    /**
     * Returns active users.
     *
     * @return the active users
     */
    public int getActiveUsers() { return activeUsers; }
    /**
     * Sets active users.
     *
     * @param activeUsers the active users
     */
    public void setActiveUsers(int activeUsers) { this.activeUsers = activeUsers; }

    /**
     * Returns user growth pct.
     *
     * @return the user growth pct
     */
    public Double getUserGrowthPct() { return userGrowthPct; }
    /**
     * Sets user growth pct.
     *
     * @param userGrowthPct the user growth pct
     */
    public void setUserGrowthPct(Double userGrowthPct) { this.userGrowthPct = userGrowthPct; }

    /**
     * Returns active courses.
     *
     * @return the active courses
     */
    public int getActiveCourses() { return activeCourses; }
    /**
     * Sets active courses.
     *
     * @param activeCourses the active courses
     */
    public void setActiveCourses(int activeCourses) { this.activeCourses = activeCourses; }

    /**
     * Returns total enrollments.
     *
     * @return the total enrollments
     */
    public long getTotalEnrollments() { return totalEnrollments; }
    /**
     * Sets total enrollments.
     *
     * @param totalEnrollments the total enrollments
     */
    public void setTotalEnrollments(long totalEnrollments) { this.totalEnrollments = totalEnrollments; }

    /**
     * Returns enrollment growth pct.
     *
     * @return the enrollment growth pct
     */
    public Double getEnrollmentGrowthPct() { return enrollmentGrowthPct; }
    /**
     * Sets enrollment growth pct.
     *
     * @param enrollmentGrowthPct the enrollment growth pct
     */
    public void setEnrollmentGrowthPct(Double enrollmentGrowthPct) { this.enrollmentGrowthPct = enrollmentGrowthPct; }

    /**
     * Returns monthly revenue.
     *
     * @return the monthly revenue
     */
    public BigDecimal getMonthlyRevenue() { return monthlyRevenue; }
    /**
     * Sets monthly revenue.
     *
     * @param monthlyRevenue the monthly revenue
     */
    public void setMonthlyRevenue(BigDecimal monthlyRevenue) {
        this.monthlyRevenue = (monthlyRevenue != null) ? monthlyRevenue : BigDecimal.ZERO;
    }

    /**
     * Returns pending registrations.
     *
     * @return the pending registrations
     */
    public int getPendingRegistrations() { return pendingRegistrations; }
    /**
     * Sets pending registrations.
     *
     * @param pendingRegistrations the pending registrations
     */
    public void setPendingRegistrations(int pendingRegistrations) { this.pendingRegistrations = pendingRegistrations; }

    /**
     * Returns recent logs.
     *
     * @return the recent logs
     */
    public List<AuditLog> getRecentLogs() { return recentLogs; }
    /**
     * Sets recent logs.
     *
     * @param recentLogs the recent logs
     */
    public void setRecentLogs(List<AuditLog> recentLogs) { this.recentLogs = recentLogs; }

    /**
     * Returns date range.
     *
     * @return the date range
     */
    public String getDateRange() { return dateRange; }
    /**
     * Sets date range.
     *
     * @param dateRange the date range
     */
    public void setDateRange(String dateRange) { this.dateRange = dateRange; }

    /**
     * Returns revenue labels json.
     *
     * @return the revenue labels json
     */
    public String getRevenueLabelsJson() { return revenueLabelsJson; }
    /**
     * Sets revenue labels json.
     *
     * @param s the s
     */
    public void setRevenueLabelsJson(String s) { this.revenueLabelsJson = s; }

    /**
     * Returns revenue data json.
     *
     * @return the revenue data json
     */
    public String getRevenueDataJson() { return revenueDataJson; }
    /**
     * Sets revenue data json.
     *
     * @param s the s
     */
    public void setRevenueDataJson(String s) { this.revenueDataJson = s; }

    /**
     * Returns enrollment labels json.
     *
     * @return the enrollment labels json
     */
    public String getEnrollmentLabelsJson() { return enrollmentLabelsJson; }
    /**
     * Sets enrollment labels json.
     *
     * @param s the s
     */
    public void setEnrollmentLabelsJson(String s) { this.enrollmentLabelsJson = s; }

    /**
     * Returns enrollment data json.
     *
     * @return the enrollment data json
     */
    public String getEnrollmentDataJson() { return enrollmentDataJson; }
    /**
     * Sets enrollment data json.
     *
     * @param s the s
     */
    public void setEnrollmentDataJson(String s) { this.enrollmentDataJson = s; }

    /**
     * Returns recent users.
     *
     * @return the recent users
     */
    public List<User> getRecentUsers() { return recentUsers; }
    /**
     * Sets recent users.
     *
     * @param list the list
     */
    public void setRecentUsers(List<User> list) { this.recentUsers = list; }

}
