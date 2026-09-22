package com.fpt.lms.dao;

import com.fpt.lms.entity.Payment;
import com.fpt.lms.util.DbConnection;

import java.sql.*;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Payment transactions.
 * Implements methods specified in Enrollment & Payment Class Diagram (SDS 1.1):
 * - insert()
 * - updateStatus()
 */
public class PaymentDAO {
    private static final Logger LOGGER = Logger.getLogger(PaymentDAO.class.getName());

    public boolean insert(Payment payment) {
        String sql = "INSERT INTO payment (id, registration_id, amount, payment_method, transaction_id, status, created_at, updated_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, payment.getId());
            ps.setObject(2, payment.getRegistrationId());
            ps.setBigDecimal(3, payment.getAmount());
            ps.setString(4, payment.getPaymentMethod());
            ps.setString(5, payment.getTransactionId());
            ps.setString(6, payment.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in PaymentDAO.insert: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean updateStatus(UUID id, String status) {
        String sql = "UPDATE payment SET status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in PaymentDAO.updateStatus: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean updateStatusByTransactionId(String transactionId, String status) {
        String sql = "UPDATE payment SET status = ?, updated_at = NOW() WHERE transaction_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, transactionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in PaymentDAO.updateStatusByTransactionId: " + e.getMessage(), e);
            return false;
        }
    }

    public Payment findByTransactionId(String transactionId) {
        String sql = "SELECT id, registration_id, amount, payment_method, transaction_id, status, created_at, updated_at " +
                     "FROM payment WHERE transaction_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Payment p = new Payment();
                    p.setId((UUID) rs.getObject("id"));
                    p.setRegistrationId((UUID) rs.getObject("registration_id"));
                    p.setAmount(rs.getBigDecimal("amount"));
                    p.setPaymentMethod(rs.getString("payment_method"));
                    p.setTransactionId(rs.getString("transaction_id"));
                    p.setStatus(rs.getString("status"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    p.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return p;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in PaymentDAO.findByTransactionId: " + e.getMessage(), e);
        }
        return null;
    }
}
