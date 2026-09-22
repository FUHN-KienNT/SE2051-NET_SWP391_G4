package com.learnhub.dao;

import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Question & Options.
 * Implements methods specified in SDS Quiz Submission & Scoring Diagram (3.1):
 * - findQuestionsByQuizId()
 */
public class QuestionDAO {
    private static final Logger LOGGER = Logger.getLogger(QuestionDAO.class.getName());

    public List<Question> findQuestionsByQuizId(UUID quizId) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT q.id, q.content, q.type, q.created_at, q.updated_at, qq.order_index " +
                     "FROM question q " +
                     "JOIN quiz_question qq ON q.id = qq.question_id " +
                     "WHERE qq.quiz_id = ? ORDER BY qq.order_index ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Question q = new Question();
                    q.setId((UUID) rs.getObject("id"));
                    q.setContent(rs.getString("content"));
                    q.setType(rs.getString("type"));
                    q.setCreatedAt(rs.getTimestamp("created_at"));
                    q.setUpdatedAt(rs.getTimestamp("updated_at"));
                    q.setOrderIndex(rs.getInt("order_index"));
                    q.setOptions(findOptionsByQuestionId(q.getId(), conn));
                    list.add(q);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findQuestionsByQuizId: " + e.getMessage(), e);
        }
        return list;
    }

    public List<QuestionOption> findOptionsByQuestionId(UUID questionId) {
        try (Connection conn = DbConnection.getConnection()) {
            return findOptionsByQuestionId(questionId, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting connection for findOptions: " + e.getMessage(), e);
            return new ArrayList<>();
        }
    }

    private List<QuestionOption> findOptionsByQuestionId(UUID questionId, Connection conn) throws SQLException {
        List<QuestionOption> list = new ArrayList<>();
        String sql = "SELECT id, question_id, option_text, is_correct, updated_at " +
                     "FROM question_option WHERE question_id = ? ORDER BY option_text ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuestionOption o = new QuestionOption();
                    o.setId((UUID) rs.getObject("id"));
                    o.setQuestionId((UUID) rs.getObject("question_id"));
                    o.setOptionText(rs.getString("option_text"));
                    o.setCorrect(rs.getBoolean("is_correct"));
                    o.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(o);
                }
            }
        }
        return list;
    }
}
