package com.learnhub.dao;

import com.learnhub.dto.ContinueLearningDTO;
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

    public ContinueLearningDTO findContinueLearning(UUID userId) {
        if (userId == null) return null;
        String sql = "SELECT c.id AS course_id, c.title AS course_title, c.thumbnail_url, " +
                     "s.name AS category_name, r.progress_percent, " +
                     "(SELECT COUNT(*) FROM module cm WHERE cm.course_id = c.id) AS module_count, " +
                     "(SELECT COUNT(*) FROM lesson cl JOIN module lm ON cl.module_id = lm.id " +
                     "WHERE lm.course_id = c.id) AS lesson_count, " +
                     "l.id AS lesson_id, l.title AS lesson_title, m.title AS module_title " +
                     "FROM registration r " +
                     "JOIN course c ON c.id = r.course_id " +
                     "JOIN module m ON m.course_id = c.id " +
                     "JOIN lesson l ON l.module_id = m.id " +
                     "LEFT JOIN learning_process lp ON lp.registration_id = r.id AND lp.lesson_id = l.id " +
                     "LEFT JOIN setting s ON s.id = c.category_id " +
                     "WHERE r.user_id = ? AND r.status = 'enrolled' " +
                     "AND (lp.status IS NULL OR lp.status <> 'completed') " +
                     "ORDER BY CASE WHEN lp.status = 'in_progress' THEN 0 ELSE 1 END, " +
                     "lp.created_at DESC NULLS LAST, r.enrolled_at DESC, " +
                     "m.order_index ASC, l.order_index ASC LIMIT 1";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ContinueLearningDTO course = new ContinueLearningDTO();
                    course.setCourseId((UUID) rs.getObject("course_id"));
                    course.setCourseTitle(rs.getString("course_title"));
                    course.setThumbnailUrl(rs.getString("thumbnail_url"));
                    course.setCategoryName(rs.getString("category_name"));
                    course.setModuleCount(rs.getInt("module_count"));
                    course.setLessonCount(rs.getInt("lesson_count"));
                    course.setLessonId((UUID) rs.getObject("lesson_id"));
                    course.setLessonTitle(rs.getString("lesson_title"));
                    course.setModuleTitle(rs.getString("module_title"));
                    course.setProgressPercent(rs.getInt("progress_percent"));
                    return course;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findContinueLearning: " + e.getMessage(), e);
        }
        return null;
    }

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

    public int countCompletedLessonsByUser(UUID userId) {
        if (userId == null) return 0;
        String sql = "SELECT COUNT(lp.id) FROM learning_process lp " +
                     "JOIN registration r ON lp.registration_id = r.id " +
                     "WHERE r.user_id = ? AND lp.status = 'completed'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countCompletedLessonsByUser: " + e.getMessage(), e);
        }
        return 0;
    }
}
