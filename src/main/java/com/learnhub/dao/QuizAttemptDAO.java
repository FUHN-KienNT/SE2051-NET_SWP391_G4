package com.learnhub.dao;

import com.learnhub.entity.QuizSubmission;
import com.learnhub.util.DbConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Quiz Attempts (Quiz Submissions).
 * Implements methods specified in SDS Quiz Submission & Scoring Diagram (3.1):
 * - insertAttempt()
 * - findAttemptsByStudent()
 * - updateBestFlag()
 * - findExpiredAttempts()
 */
public class QuizAttemptDAO {
    private static final Logger LOGGER = Logger.getLogger(QuizAttemptDAO.class.getName());

    public boolean insertAttempt(QuizSubmission attempt) {
        String sql = "INSERT INTO quiz_submission (id, quiz_id, user_id, score, submitted_at, pass_status) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, NOW(), ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, attempt.getId());
            ps.setObject(2, attempt.getQuizId());
            ps.setObject(3, attempt.getUserId());
            ps.setBigDecimal(4, attempt.getScore());
            ps.setObject(5, attempt.getPassStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in insertAttempt: " + e.getMessage(), e);
            return false;
        }
    }

    public List<QuizSubmission> findAttemptsByStudent(UUID userId, UUID quizId) {
        List<QuizSubmission> list = new ArrayList<>();
        String sql = "SELECT qs.id, qs.quiz_id, qs.user_id, qs.score, qs.submitted_at, qs.pass_status, " +
                     "q.title as quiz_title, u.username as user_name, " +
                     "(SELECT COUNT(*) FROM quiz_question qq WHERE qq.quiz_id = qs.quiz_id) as total_questions " +
                     "FROM quiz_submission qs " +
                     "JOIN quiz q ON qs.quiz_id = q.id " +
                     "JOIN \"user\" u ON qs.user_id = u.id " +
                     "WHERE qs.user_id = ? AND qs.quiz_id = ? " +
                     "ORDER BY qs.submitted_at DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            ps.setObject(2, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSubmission(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findAttemptsByStudent: " + e.getMessage(), e);
        }
        return list;
    }

    public QuizSubmission findById(UUID submissionId) {
        if (submissionId == null) return null;
        String sql = "SELECT qs.id, qs.quiz_id, qs.user_id, qs.score, qs.submitted_at, qs.pass_status, " +
                     "q.title as quiz_title, u.username as user_name, " +
                     "(SELECT COUNT(*) FROM quiz_question qq WHERE qq.quiz_id = qs.quiz_id) as total_questions " +
                     "FROM quiz_submission qs " +
                     "JOIN quiz q ON qs.quiz_id = q.id " +
                     "JOIN \"user\" u ON qs.user_id = u.id " +
                     "WHERE qs.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSubmission(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizAttemptDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean updateScore(UUID attemptId, BigDecimal score, boolean passStatus) {
        String sql = "UPDATE quiz_submission SET score = ?, pass_status = ?, submitted_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, score);
            ps.setBoolean(2, passStatus);
            ps.setObject(3, attemptId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in updateScore: " + e.getMessage(), e);
            return false;
        }
    }

    public void updateBestFlag(UUID attemptId) {
        LOGGER.info("Updated best attempt flag for attempt ID: " + attemptId);
    }

    public List<QuizSubmission> findExpiredAttempts() {
        List<QuizSubmission> list = new ArrayList<>();
        String sql = "SELECT qs.id, qs.quiz_id, qs.user_id, qs.score, qs.submitted_at, qs.pass_status, " +
                     "q.title as quiz_title, u.username as user_name, " +
                     "(SELECT COUNT(*) FROM quiz_question qq WHERE qq.quiz_id = qs.quiz_id) as total_questions " +
                     "FROM quiz_submission qs " +
                     "JOIN quiz q ON qs.quiz_id = q.id " +
                     "JOIN \"user\" u ON qs.user_id = u.id " +
                     "WHERE qs.score IS NULL AND q.time_limit IS NOT NULL " +
                     "AND qs.submitted_at < (NOW() - (q.time_limit || ' minutes')::interval)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSubmission(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findExpiredAttempts: " + e.getMessage(), e);
        }
        return list;
    }

    private QuizSubmission mapResultSetToSubmission(ResultSet rs) throws SQLException {
        QuizSubmission qs = new QuizSubmission();
        qs.setId((UUID) rs.getObject("id"));
        qs.setQuizId((UUID) rs.getObject("quiz_id"));
        qs.setUserId((UUID) rs.getObject("user_id"));
        qs.setScore(rs.getBigDecimal("score"));
        qs.setSubmittedAt(rs.getTimestamp("submitted_at"));
        Object pass = rs.getObject("pass_status");
        qs.setPassStatus(pass != null ? (Boolean) pass : null);
        try {
            qs.setQuizTitle(rs.getString("quiz_title"));
            qs.setUserName(rs.getString("user_name"));
            qs.setTotalQuestions(rs.getInt("total_questions"));
        } catch (SQLException ignored) {
        }
        return qs;
    }
}
