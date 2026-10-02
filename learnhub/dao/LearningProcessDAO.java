package com.learnhub.dao;

import com.learnhub.entity.LearningProcess;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for LearningProcess tracking.
 * Implements methods specified in Lesson Learning Class Diagram (SDS 4.1):
 * - findByRegistrationAndLesson()
 * - save()
 * - updateStatus()
 */
public class LearningProcessDAO {
    private static final Logger LOGGER = Logger.getLogger(LearningProcessDAO.class.getName());

    public LearningProcess findByRegistrationAndLesson(UUID registrationId, UUID lessonId) {
        if (registrationId == null || lessonId == null) return null;
        String sql = "SELECT id, registration_id, lesson_id, status, completed_at, created_at " +
                     "FROM learning_process WHERE registration_id = ? AND lesson_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, registrationId);
            ps.setObject(2, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LearningProcess lp = new LearningProcess();
                    lp.setId((UUID) rs.getObject("id"));
                    lp.setRegistrationId((UUID) rs.getObject("registration_id"));
                    lp.setLessonId((UUID) rs.getObject("lesson_id"));
                    lp.setStatus(rs.getString("status"));
                    lp.setCompletedAt(rs.getTimestamp("completed_at"));
                    lp.setCreatedAt(rs.getTimestamp("created_at"));
                    return lp;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByRegistrationAndLesson: " + e.getMessage(), e);
        }
        return null;
    }

    public void save(LearningProcess lp) {
        LearningProcess existing = findByRegistrationAndLesson(lp.getRegistrationId(), lp.getLessonId());
        if (existing != null) {
            updateStatus(existing.getId(), lp.getStatus());
        } else {
            String sql = "INSERT INTO learning_process (id, registration_id, lesson_id, status, completed_at, created_at) " +
                         "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, NOW()) " +
                         "ON CONFLICT (registration_id, lesson_id) DO UPDATE SET status = EXCLUDED.status, completed_at = EXCLUDED.completed_at";
            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setObject(1, lp.getId());
                ps.setObject(2, lp.getRegistrationId());
                ps.setObject(3, lp.getLessonId());
                ps.setString(4, lp.getStatus() != null ? lp.getStatus() : "not_started");
                ps.setTimestamp(5, "completed".equalsIgnoreCase(lp.getStatus()) ? new Timestamp(System.currentTimeMillis()) : lp.getCompletedAt());
                ps.executeUpdate();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error in LearningProcessDAO.save: " + e.getMessage(), e);
            }
        }
    }

    public void updateStatus(UUID id, String status) {
        String sql = "UPDATE learning_process SET status = ?, completed_at = CASE WHEN ? = 'completed' THEN NOW() ELSE completed_at END WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setObject(3, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LearningProcessDAO.updateStatus: " + e.getMessage(), e);
        }
    }

    public int countCompletedLessons(UUID registrationId) {
        String sql = "SELECT COUNT(*) FROM learning_process WHERE registration_id = ? AND status = 'completed'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countCompletedLessons: " + e.getMessage(), e);
        }
        return 0;
    }

    public int countTotalLessons(UUID registrationId) {
        String sql = "SELECT COUNT(l.id) FROM lesson l " +
                     "JOIN module m ON l.module_id = m.id " +
                     "JOIN registration r ON m.course_id = r.course_id " +
                     "WHERE r.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countTotalLessons: " + e.getMessage(), e);
        }
        return 0;
    }
}
