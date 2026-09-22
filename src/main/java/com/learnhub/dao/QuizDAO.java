package com.learnhub.dao;

import com.learnhub.entity.Quiz;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

public class QuizDAO {
    private static final Logger LOGGER = Logger.getLogger(QuizDAO.class.getName());

    public Quiz findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT q.id, q.module_id, q.title, q.time_limit, q.created_at, q.updated_at, " +
                     "m.title as module_title, " +
                     "(SELECT COUNT(*) FROM quiz_question qq WHERE qq.quiz_id = q.id) as question_count " +
                     "FROM quiz q " +
                     "JOIN module m ON q.module_id = m.id " +
                     "WHERE q.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Quiz q = new Quiz();
                    q.setId((UUID) rs.getObject("id"));
                    q.setModuleId((UUID) rs.getObject("module_id"));
                    q.setTitle(rs.getString("title"));
                    int tl = rs.getInt("time_limit");
                    q.setTimeLimit(rs.wasNull() ? null : tl);
                    q.setCreatedAt(rs.getTimestamp("created_at"));
                    q.setUpdatedAt(rs.getTimestamp("updated_at"));
                    q.setModuleTitle(rs.getString("module_title"));
                    q.setQuestionCount(rs.getInt("question_count"));
                    return q;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }

    public List<Quiz> findByModuleId(UUID moduleId) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT q.id, q.module_id, q.title, q.time_limit, q.created_at, q.updated_at, " +
                     "m.title as module_title, " +
                     "(SELECT COUNT(*) FROM quiz_question qq WHERE qq.quiz_id = q.id) as question_count " +
                     "FROM quiz q " +
                     "JOIN module m ON q.module_id = m.id " +
                     "WHERE q.module_id = ? ORDER BY q.created_at ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, moduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Quiz q = new Quiz();
                    q.setId((UUID) rs.getObject("id"));
                    q.setModuleId((UUID) rs.getObject("module_id"));
                    q.setTitle(rs.getString("title"));
                    int tl = rs.getInt("time_limit");
                    q.setTimeLimit(rs.wasNull() ? null : tl);
                    q.setCreatedAt(rs.getTimestamp("created_at"));
                    q.setUpdatedAt(rs.getTimestamp("updated_at"));
                    q.setModuleTitle(rs.getString("module_title"));
                    q.setQuestionCount(rs.getInt("question_count"));
                    list.add(q);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.findByModuleId: " + e.getMessage(), e);
        }
        return list;
    }
}
