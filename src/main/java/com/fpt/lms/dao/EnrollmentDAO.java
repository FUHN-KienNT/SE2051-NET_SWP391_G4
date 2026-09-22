package com.fpt.lms.dao;

import com.fpt.lms.entity.Registration;
import com.fpt.lms.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Enrollment.
 * Implements methods specified in Enrollment & Payment Class Diagram (SDS 1.1):
 * - insert()
 * - updateStatus()
 * - findExpiredPending()
 */
public class EnrollmentDAO {
    private static final Logger LOGGER = Logger.getLogger(EnrollmentDAO.class.getName());
    private final RegistrationDAO registrationDAO = new RegistrationDAO();

    public boolean insert(Registration enrollment) {
        return registrationDAO.insertRegistration(enrollment);
    }

    public boolean updateStatus(UUID id, String status) {
        String sql = "UPDATE registration SET status = ? WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in EnrollmentDAO.updateStatus: " + e.getMessage(), e);
            return false;
        }
    }

    public List<Registration> findExpiredPending() {
        List<Registration> list = new ArrayList<>();
        String sql = "SELECT id, user_id, course_id, enrolled_at, status, progress_percent, " +
                     "amount, payment_method_id, transaction_id, payment_status, paid_at " +
                     "FROM registration WHERE payment_status = 'pending' AND enrolled_at < (NOW() - INTERVAL '24 hours')";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
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
                list.add(r);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findExpiredPending: " + e.getMessage(), e);
        }
        return list;
    }
}
