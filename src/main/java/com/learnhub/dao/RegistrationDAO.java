package com.learnhub.dao;

import com.learnhub.entity.Registration;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Registration entity.
 * Implements methods specified in SDS Course Browsing & Enrollment Diagrams:
 * - insertRegistration()
 * - findRegistrations()
 * - countRegistrations()
 * - findRegistrationById()
 * - updateRegistrationStatus()
 * - findByUserAndCourse()
 * - updateProgressPercent()
 */
public class RegistrationDAO {
    private static final Logger LOGGER = Logger.getLogger(RegistrationDAO.class.getName());

    public boolean insertRegistration(Registration reg) {
        String sql = "INSERT INTO registration (id, user_id, course_id, enrolled_at, status, progress_percent, " +
                     "amount, payment_method_id, transaction_id, payment_status, paid_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, reg.getId());
            ps.setObject(2, reg.getUserId());
            ps.setObject(3, reg.getCourseId());
            ps.setString(4, reg.getStatus() != null ? reg.getStatus() : "enrolled");
            ps.setShort(5, reg.getProgressPercent());
            ps.setBigDecimal(6, reg.getAmount());
            ps.setObject(7, reg.getPaymentMethodId());
            ps.setString(8, reg.getTransactionId());
            ps.setString(9, reg.getPaymentStatus() != null ? reg.getPaymentStatus() : "pending");
            ps.setTimestamp(10, reg.getPaidAt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in insertRegistration: " + e.getMessage(), e);
            return false;
        }
    }

    public List<Registration> findRegistrations(String search, String status, int offset, int limit) {
        List<Registration> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT r.id, r.user_id, r.course_id, r.enrolled_at, r.status, r.progress_percent, " +
                "r.amount, r.payment_method_id, r.transaction_id, r.payment_status, r.paid_at, " +
                "u.username as user_name, u.email as user_email, c.title as course_title, s.name as payment_method_name " +
                "FROM registration r " +
                "JOIN \"user\" u ON r.user_id = u.id " +
                "JOIN course c ON r.course_id = c.id " +
                "LEFT JOIN setting s ON r.payment_method_id = s.id " +
                "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.username) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(c.title) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append("AND (r.status = ? OR r.payment_status = ?) ");
            params.add(status.trim());
            params.add(status.trim());
        }

        sql.append("ORDER BY r.enrolled_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRegistration(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findRegistrations: " + e.getMessage(), e);
        }
        return list;
    }

    public int countRegistrations(String search, String status) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM registration r " +
                "JOIN \"user\" u ON r.user_id = u.id " +
                "JOIN course c ON r.course_id = c.id " +
                "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.username) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(c.title) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append("AND (r.status = ? OR r.payment_status = ?) ");
            params.add(status.trim());
            params.add(status.trim());
        }

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countRegistrations: " + e.getMessage(), e);
        }
        return 0;
    }

    public Registration findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT r.id, r.user_id, r.course_id, r.enrolled_at, r.status, r.progress_percent, " +
                     "r.amount, r.payment_method_id, r.transaction_id, r.payment_status, r.paid_at, " +
                     "u.username as user_name, u.email as user_email, c.title as course_title, s.name as payment_method_name " +
                     "FROM registration r " +
                     "JOIN \"user\" u ON r.user_id = u.id " +
                     "JOIN course c ON r.course_id = c.id " +
                     "LEFT JOIN setting s ON r.payment_method_id = s.id " +
                     "WHERE r.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRegistration(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in RegistrationDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }

    public Registration findRegistrationById(UUID id) {
        return findById(id);
    }

    public Registration findByUserAndCourse(UUID userId, UUID courseId) {
        if (userId == null || courseId == null) return null;
        String sql = "SELECT r.id, r.user_id, r.course_id, r.enrolled_at, r.status, r.progress_percent, " +
                     "r.amount, r.payment_method_id, r.transaction_id, r.payment_status, r.paid_at, " +
                     "u.username as user_name, u.email as user_email, c.title as course_title, s.name as payment_method_name " +
                     "FROM registration r " +
                     "JOIN \"user\" u ON r.user_id = u.id " +
                     "JOIN course c ON r.course_id = c.id " +
                     "LEFT JOIN setting s ON r.payment_method_id = s.id " +
                     "WHERE r.user_id = ? AND r.course_id = ? " +
                     "ORDER BY r.enrolled_at DESC LIMIT 1";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            ps.setObject(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRegistration(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByUserAndCourse: " + e.getMessage(), e);
        }
        return null;
    }

    public List<Registration> findByUserId(UUID userId) {
        List<Registration> list = new ArrayList<>();
        String sql = "SELECT r.id, r.user_id, r.course_id, r.enrolled_at, r.status, r.progress_percent, " +
                     "r.amount, r.payment_method_id, r.transaction_id, r.payment_status, r.paid_at, " +
                     "u.username as user_name, u.email as user_email, c.title as course_title, s.name as payment_method_name " +
                     "FROM registration r " +
                     "JOIN \"user\" u ON r.user_id = u.id " +
                     "JOIN course c ON r.course_id = c.id " +
                     "LEFT JOIN setting s ON r.payment_method_id = s.id " +
                     "WHERE r.user_id = ? ORDER BY r.enrolled_at DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRegistration(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByUserId: " + e.getMessage(), e);
        }
        return list;
    }

    public boolean updateRegistrationStatus(UUID id, String status, String paymentStatus) {
        String sql = "UPDATE registration SET status = ?, payment_status = ?, paid_at = CASE WHEN ? = 'paid' THEN NOW() ELSE paid_at END WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, paymentStatus);
            ps.setString(3, paymentStatus);
            ps.setObject(4, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in updateRegistrationStatus: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean updateProgressPercent(UUID registrationId, int percent) {
        String sql = "UPDATE registration SET progress_percent = ? WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.min(100, Math.max(0, percent)));
            ps.setObject(2, registrationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in updateProgressPercent: " + e.getMessage(), e);
            return false;
        }
    }

    private Registration mapResultSetToRegistration(ResultSet rs) throws SQLException {
        Registration r = new Registration();
        r.setId((UUID) rs.getObject("id"));
        r.setUserId((UUID) rs.getObject("user_id"));
        r.setCourseId((UUID) rs.getObject("course_id"));
        r.setEnrolledAt(rs.getTimestamp("enrolled_at"));
        r.setStatus(rs.getString("status"));
        r.setProgressPercent(rs.getShort("progress_percent"));
        r.setAmount(rs.getBigDecimal("amount"));
        r.setPaymentMethodId((UUID) rs.getObject("payment_method_id"));
        r.setTransactionId(rs.getString("transaction_id"));
        r.setPaymentStatus(rs.getString("payment_status"));
        r.setPaidAt(rs.getTimestamp("paid_at"));

        try {
            r.setUserName(rs.getString("user_name"));
            r.setUserEmail(rs.getString("user_email"));
            r.setCourseTitle(rs.getString("course_title"));
            r.setPaymentMethodName(rs.getString("payment_method_name"));
        } catch (SQLException ignored) {
        }
        return r;
    }
}
