package com.learnhub.dao;

import com.learnhub.util.DbConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

public class ProfileDAO {
    public record QuizSummary(int submissions, int passed, BigDecimal averageScore) {}

    public QuizSummary findQuizSummary(UUID userId) {
        String sql = """
                SELECT COUNT(*) AS submissions,
                       COUNT(*) FILTER (WHERE pass_status = TRUE) AS passed,
                       ROUND(AVG(score), 1) AS average_score
                FROM quiz_submission
                WHERE user_id = ? AND score IS NOT NULL
                """;
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return new QuizSummary(rs.getInt("submissions"), rs.getInt("passed"),
                        rs.getBigDecimal("average_score"));
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot load profile quiz summary", e);
        }
    }

    public Map<LocalDate, Integer> findDailyActivity(UUID userId) {
        String sql = """
                SELECT activity_day, COUNT(*) AS activity_count
                FROM (
                    SELECT (lp.completed_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date AS activity_day
                    FROM learning_process lp
                    JOIN registration r ON r.id = lp.registration_id
                    WHERE r.user_id = ? AND lp.status = 'completed' AND lp.completed_at IS NOT NULL
                    UNION ALL
                    SELECT (qs.submitted_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date AS activity_day
                    FROM quiz_submission qs
                    WHERE qs.user_id = ? AND qs.score IS NOT NULL
                ) activity
                GROUP BY activity_day
                ORDER BY activity_day
                """;
        Map<LocalDate, Integer> activity = new TreeMap<>();
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            ps.setObject(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date day = rs.getDate("activity_day");
                    activity.put(day.toLocalDate(), rs.getInt("activity_count"));
                }
            }
            return activity;
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot load profile activity", e);
        }
    }
}
