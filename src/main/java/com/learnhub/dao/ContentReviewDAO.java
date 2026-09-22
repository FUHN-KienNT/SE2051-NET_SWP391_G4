package com.learnhub.dao;

import com.learnhub.entity.ContentReview;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Content Reviews (Expert lesson submissions and Manager reviews).
 * Implements methods specified in Content Management Class Diagram (SDS 2.1):
 * - insert()
 * - findPendingReviews()
 */
public class ContentReviewDAO {
    private static final Logger LOGGER = Logger.getLogger(ContentReviewDAO.class.getName());

    public boolean insert(ContentReview review) {
        String sql = "INSERT INTO content_review (id, lesson_id, expert_id, reviewer_id, status, comments, submitted_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, review.getId());
            ps.setObject(2, review.getLessonId());
            ps.setObject(3, review.getExpertId());
            ps.setObject(4, review.getReviewerId());
            ps.setString(5, review.getStatus() != null ? review.getStatus() : "pending");
            ps.setString(6, review.getComments());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ContentReviewDAO.insert: " + e.getMessage(), e);
            return false;
        }
    }

    public List<ContentReview> findPendingReviews() {
        List<ContentReview> list = new ArrayList<>();
        String sql = "SELECT cr.id, cr.lesson_id, cr.expert_id, cr.reviewer_id, cr.status, cr.comments, cr.submitted_at, cr.reviewed_at, " +
                     "l.title as lesson_title, u.username as expert_name, r.username as reviewer_name " +
                     "FROM content_review cr " +
                     "JOIN lesson l ON cr.lesson_id = l.id " +
                     "JOIN \"user\" u ON cr.expert_id = u.id " +
                     "LEFT JOIN \"user\" r ON cr.reviewer_id = r.id " +
                     "WHERE cr.status = 'pending' ORDER BY cr.submitted_at ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToContentReview(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findPendingReviews: " + e.getMessage(), e);
        }
        return list;
    }

    public boolean updateStatus(UUID reviewId, UUID reviewerId, String status, String comments) {
        String sql = "UPDATE content_review SET reviewer_id = ?, status = ?, comments = ?, reviewed_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, reviewerId);
            ps.setString(2, status);
            ps.setString(3, comments);
            ps.setObject(4, reviewId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in updateStatus: " + e.getMessage(), e);
            return false;
        }
    }

    private ContentReview mapResultSetToContentReview(ResultSet rs) throws SQLException {
        ContentReview cr = new ContentReview();
        cr.setId((UUID) rs.getObject("id"));
        cr.setLessonId((UUID) rs.getObject("lesson_id"));
        cr.setExpertId((UUID) rs.getObject("expert_id"));
        cr.setReviewerId((UUID) rs.getObject("reviewer_id"));
        cr.setStatus(rs.getString("status"));
        cr.setComments(rs.getString("comments"));
        cr.setSubmittedAt(rs.getTimestamp("submitted_at"));
        cr.setReviewedAt(rs.getTimestamp("reviewed_at"));
        try {
            cr.setLessonTitle(rs.getString("lesson_title"));
            cr.setExpertName(rs.getString("expert_name"));
            cr.setReviewerName(rs.getString("reviewer_name"));
        } catch (SQLException ignored) {
        }
        return cr;
    }
}
