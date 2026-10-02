package com.learnhub.dao;

import com.learnhub.entity.AuditLog;
import com.learnhub.util.DbConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Admin Dashboard aggregation queries.
 * Implements methods specified in SDS Admin Dashboard (2.3):
 * - countTotalUsers()
 * - countActiveUsers()
 * - countActiveCourses()
 * - countEnrollments(from, to)
 * - getRevenue(from, to)
 * - countPendingRegistrations()
 * - getRecentAuditLogs(limit)
 * - insertAuditLog()
 */
public class DashboardDAO {

    private static final Logger LOGGER = Logger.getLogger(DashboardDAO.class.getName());

    // ── User Metrics ──────────────────────────────────────────────────────────────

    /**
     * Count total registered users (all statuses).
     */
    public int countTotalUsers() {
        String sql = "SELECT COUNT(*) FROM \"user\"";
        return querySingleInt(sql);
    }

    /**
     * Count users with status = 'active'.
     */
    public int countActiveUsers() {
        String sql = "SELECT COUNT(*) FROM \"user\" WHERE status = 'active'";
        return querySingleInt(sql);
    }

    /**
     * Count users created within a date range (for growth calculation).
     */
    public int countUsersCreatedBetween(Timestamp from, Timestamp to) {
        String sql = "SELECT COUNT(*) FROM \"user\" WHERE created_at >= ? AND created_at < ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countUsersCreatedBetween: " + e.getMessage(), e);
        }
        return 0;
    }

    // ── Course Metrics ───────────────────────────────────────────────────────────

    /**
     * Count published courses.
     */
    public int countActiveCourses() {
        String sql = "SELECT COUNT(*) FROM course WHERE status = 'published'";
        return querySingleInt(sql);
    }

    // ── Enrollment Metrics ───────────────────────────────────────────────────────

    /**
     * Count enrollments (registrations) within a date range.
     *
     * @param from inclusive start timestamp
     * @param to   exclusive end timestamp
     */
    public long countEnrollments(Timestamp from, Timestamp to) {
        String sql = "SELECT COUNT(*) FROM registration WHERE enrolled_at >= ? AND enrolled_at < ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countEnrollments: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Count all time total enrollments.
     */
    public long countTotalEnrollments() {
        String sql = "SELECT COUNT(*) FROM registration";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countTotalEnrollments: " + e.getMessage(), e);
        }
        return 0;
    }

    // ── Revenue Metrics ──────────────────────────────────────────────────────────

    /**
     * Sum of paid registration amounts within a date range.
     *
     * @param from inclusive start timestamp
     * @param to   exclusive end timestamp
     */
    public BigDecimal getRevenue(Timestamp from, Timestamp to) {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM registration " +
                     "WHERE payment_status = 'paid' AND paid_at >= ? AND paid_at < ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getRevenue: " + e.getMessage(), e);
        }
        return BigDecimal.ZERO;
    }

    // ── Pending Registrations ─────────────────────────────────────────────────────

    /**
     * Count registrations with payment_status = 'pending'.
     */
    public int countPendingRegistrations() {
        String sql = "SELECT COUNT(*) FROM registration WHERE payment_status = 'pending'";
        return querySingleInt(sql);
    }

    // ── Audit Logs ────────────────────────────────────────────────────────────────

    /**
     * Retrieve the most recent audit log entries.
     *
     * @param limit maximum number of rows to return
     */
    public List<AuditLog> getRecentAuditLogs(int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT id, actor, action_type, description, status, created_at " +
                     "FROM audit_log ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAuditLog(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getRecentAuditLogs: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Insert a new audit log entry (called by application code on significant events).
     */
    public boolean insertAuditLog(String actor, String actionType, String description, String status) {
        String sql = "INSERT INTO audit_log (id, actor, action_type, description, status, created_at) " +
                     "VALUES (gen_random_uuid(), ?, ?, ?, ?, NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, actor);
            ps.setString(2, actionType);
            ps.setString(3, description);
            ps.setString(4, status != null ? status : "SUCCESS");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in insertAuditLog: " + e.getMessage(), e);
            return false;
        }
    }

    // ── Private Helpers ──────────────────────────────────────────────────────────

    private int querySingleInt(String sql) {
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in querySingleInt [" + sql + "]: " + e.getMessage(), e);
        }
        return 0;
    }

    private AuditLog mapAuditLog(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setId((UUID) rs.getObject("id"));
        log.setActor(rs.getString("actor"));
        log.setActionType(rs.getString("action_type"));
        log.setDescription(rs.getString("description"));
        log.setStatus(rs.getString("status"));
        log.setCreatedAt(rs.getTimestamp("created_at"));
        return log;
    }
}
