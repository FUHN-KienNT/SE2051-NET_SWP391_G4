package com.learnhub.dao;

import com.learnhub.entity.AuditLog;
import com.learnhub.util.DbConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Admin Dashboard aggregation queries and system audit logging.
 * Implements specifications in SDS Admin Dashboard (2.3).
 *
 * <p>Provides database operations for user metrics, course counts, enrollment statistics,
 * revenue calculations, chart datasets, and audit trails.</p>
 *
 * @author NguyenLD - System Administration Module
 */
public class DashboardDAO {

    private static final Logger LOGGER = Logger.getLogger(DashboardDAO.class.getName());

    // -------------------------------------------------------------------------
    // User Metrics
    // -------------------------------------------------------------------------

    /**
     * Counts the total number of registered users across all statuses.
     *
     * @return Total user count in database
     */
    public int countTotalUsers() {
        String sql = "SELECT COUNT(*) FROM \"user\"";
        return querySingleInt(sql);
    }

    /**
     * Counts the total number of users with 'active' status.
     *
     * @return Active user count
     */
    public int countActiveUsers() {
        String sql = "SELECT COUNT(*) FROM \"user\" WHERE status = 'active'";
        return querySingleInt(sql);
    }

    /**
     * Counts users created within a specific timestamp range (used for growth percentage).
     *
     * @param from Inclusive start timestamp
     * @param to   Exclusive end timestamp
     * @return Number of users created in this interval
     */
    public int countUsersCreatedBetween(Timestamp from, Timestamp to) {
        String sql = "SELECT COUNT(*) FROM \"user\" WHERE created_at >= ? AND created_at < ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countUsersCreatedBetween: " + e.getMessage(), e);
        }
        return 0;
    }

    // -------------------------------------------------------------------------
    // Course Metrics
    // -------------------------------------------------------------------------

    /**
     * Counts the total number of published courses available for enrollment.
     *
     * @return Count of published courses
     */
    public int countActiveCourses() {
        String sql = "SELECT COUNT(*) FROM course WHERE status = 'published'";
        return querySingleInt(sql);
    }

    // -------------------------------------------------------------------------
    // Enrollment Metrics
    // -------------------------------------------------------------------------

    /**
     * Counts enrollments (registrations) created within a specific timestamp range.
     *
     * @param from Inclusive start timestamp
     * @param to   Exclusive end timestamp
     * @return Count of enrollments in the interval
     */
    public long countEnrollments(Timestamp from, Timestamp to) {
        String sql = "SELECT COUNT(*) FROM registration WHERE enrolled_at >= ? AND enrolled_at < ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countEnrollments: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Counts all-time total course enrollments.
     *
     * @return Total count of all registrations
     */
    public long countTotalEnrollments() {
        String sql = "SELECT COUNT(*) FROM registration";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countTotalEnrollments: " + e.getMessage(), e);
        }
        return 0;
    }

    // -------------------------------------------------------------------------
    // Revenue Metrics
    // -------------------------------------------------------------------------

    /**
     * Computes total revenue from paid registrations within a given timestamp range.
     *
     * @param from Inclusive start timestamp
     * @param to   Exclusive end timestamp
     * @return Sum of paid amounts (VND)
     */
    public BigDecimal getRevenue(Timestamp from, Timestamp to) {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM registration "
                + "WHERE payment_status = 'paid' AND paid_at >= ? AND paid_at < ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getRevenue: " + e.getMessage(), e);
        }
        return BigDecimal.ZERO;
    }

    /**
     * Counts registrations awaiting payment confirmation.
     *
     * @return Count of pending registrations
     */
    public int countPendingRegistrations() {
        String sql = "SELECT COUNT(*) FROM registration WHERE payment_status = 'pending'";
        return querySingleInt(sql);
    }

    // -------------------------------------------------------------------------
    // Chart Analytics Datasets
    // -------------------------------------------------------------------------

    /**
     * Retrieves aggregated monthly revenue for the last 6 calendar months.
     *
     * @return Object array where [0] is List&lt;String&gt; (month labels) and [1] is List&lt;BigDecimal&gt; (revenue values)
     */
    public Object[] getRevenueLast6Months() {
        List<String> labels = new ArrayList<>();
        List<BigDecimal> data = new ArrayList<>();
        String sql = "SELECT TO_CHAR(COALESCE(paid_at, enrolled_at), 'Mon') AS month_label, SUM(amount) AS revenue "
                + "FROM registration "
                + "WHERE payment_status = 'paid' "
                + "  AND COALESCE(paid_at, enrolled_at) >= date_trunc('month', CURRENT_DATE - INTERVAL '5 months') "
                + "GROUP BY TO_CHAR(COALESCE(paid_at, enrolled_at), 'Mon'), date_trunc('month', COALESCE(paid_at, enrolled_at)) "
                + "ORDER BY date_trunc('month', COALESCE(paid_at, enrolled_at))";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                labels.add(rs.getString("month_label"));
                BigDecimal rev = rs.getBigDecimal("revenue");
                data.add(rev != null ? rev : BigDecimal.ZERO);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching revenue chart data: " + e.getMessage(), e);
        }
        return new Object[]{labels, data};
    }

    /**
     * Retrieves top 5 course categories by total student enrollments.
     *
     * @return Object array where [0] is List&lt;String&gt; (category names) and [1] is List&lt;Long&gt; (enrollment counts)
     */
    public Object[] getEnrollmentsByCategory() {
        List<String> labels = new ArrayList<>();
        List<Long> data = new ArrayList<>();
        String sql = "SELECT s.name AS category_name, COUNT(r.id) AS enrollments "
                + "FROM registration r "
                + "JOIN course c ON r.course_id = c.id "
                + "JOIN setting s ON c.category_id = s.id "
                + "GROUP BY s.name "
                + "ORDER BY enrollments DESC "
                + "LIMIT 5";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                labels.add(rs.getString("category_name"));
                data.add(rs.getLong("enrollments"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching enrollment chart data: " + e.getMessage(), e);
        }
        return new Object[]{labels, data};
    }

    // -------------------------------------------------------------------------
    // Audit Logging
    // -------------------------------------------------------------------------

    /**
     * Retrieves the most recent system audit log records ordered by timestamp descending.
     *
     * @param limit Maximum number of audit records to return
     * @return List of AuditLog entities
     */
    public List<AuditLog> getRecentAuditLogs(int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT id, actor, action_type, description, status, created_at "
                + "FROM audit_log ORDER BY created_at DESC LIMIT ?";

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
     * Inserts a new audit log record into the database for administrative actions and security events.
     *
     * @param actor       User email or system service that initiated the event
     * @param actionType  Action code (e.g. USER_CREATE, SETTING_UPDATE, COURSE_PUBLISH)
     * @param description Narrative description of the event
     * @param status      Execution outcome (SUCCESS, FAILED, WARNING)
     * @return true if successfully inserted, false otherwise
     */
    public boolean insertAuditLog(String actor, String actionType, String description, String status) {
        String sql = "INSERT INTO audit_log (id, actor, action_type, description, status, created_at) "
                + "VALUES (gen_random_uuid(), ?, ?, ?, ?, NOW())";

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

    // -------------------------------------------------------------------------
    // Private Helpers
    // -------------------------------------------------------------------------

    private int querySingleInt(String sql) {
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
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
