package com.learnhub.dao;

import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Question Bank DAO.
 * A question is shared across quizzes; quiz membership is maintained by QuizQuestionDAO.
 */
public class QuestionDAO {
    private static final Logger LOGGER = Logger.getLogger(QuestionDAO.class.getName());

    public List<Question> search(String keyword, String type) {
        List<Question> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT q.id, q.content, q.type, q.created_at, q.updated_at, " +
            "(SELECT COUNT(*) FROM question_option qo WHERE qo.question_id=q.id) option_count, " +
            "(SELECT COUNT(*) FROM quiz_question qq WHERE qq.question_id=q.id) quiz_count " +
            "FROM question q WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND q.content ILIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        if (type != null && !type.trim().isEmpty()) {
            sql.append("AND q.type = ?::question_type ");
            params.add(type.trim());
        }
        sql.append("ORDER BY q.updated_at DESC, q.created_at DESC");

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) { Question q=mapQuestion(rs); q.setOptions(findOptionsByQuestionId(q.getId(), conn)); list.add(q); }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.search", e);
        }
        return list;
    }

    public Question findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT id, content, type, created_at, updated_at FROM question WHERE id=?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Question q = mapQuestion(rs);
                    q.setOptions(findOptionsByQuestionId(id, conn));
                    return q;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.findById", e);
        }
        return null;
    }

    public List<Question> findQuestionsByQuizId(UUID quizId) {
        List<Question> list = new ArrayList<>();
        if (quizId == null) return list;
        String sql = "SELECT q.id, q.content, q.type, q.created_at, q.updated_at, qq.order_index " +
                     "FROM question q JOIN quiz_question qq ON q.id=qq.question_id " +
                     "WHERE qq.quiz_id=? ORDER BY qq.order_index ASC, q.created_at ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Question q = mapQuestion(rs);
                    q.setOrderIndex(rs.getInt("order_index"));
                    q.setOptions(findOptionsByQuestionId(q.getId(), conn));
                    list.add(q);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.findQuestionsByQuizId", e);
        }
        return list;
    }

    public List<QuestionOption> findOptionsByQuestionId(UUID questionId) {
        if (questionId == null) return new ArrayList<>();
        try (Connection conn = DbConnection.getConnection()) {
            return findOptionsByQuestionId(questionId, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.findOptionsByQuestionId", e);
            return new ArrayList<>();
        }
    }

    public boolean insert(Question question, List<QuestionOption> options) {
        if (question == null || question.getContent() == null || question.getContent().trim().isEmpty()) return false;
        String sql = "INSERT INTO question (id, content, type, created_at, updated_at) " +
                     "VALUES (COALESCE(?,gen_random_uuid()), ?, ?::question_type, NOW(), NOW())";
        Connection conn = null;
        try {
            conn = DbConnection.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setObject(1, question.getId());
                ps.setString(2, question.getContent().trim());
                ps.setString(3, normalizeType(question.getType()));
                ps.executeUpdate();
            }
            UUID id = question.getId();
            if (id == null) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM question WHERE content=? ORDER BY created_at DESC LIMIT 1")) {
                    ps.setString(1, question.getContent().trim());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) id = (UUID) rs.getObject(1);
                    }
                }
            }
            question.setId(id);
            replaceOptions(conn, id, options);
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.insert", e);
            return rollback(conn);
        } finally {
            close(conn);
        }
    }

    public boolean update(Question question, List<QuestionOption> options) {
        if (question == null || question.getId() == null) return false;
        String sql = "UPDATE question SET content=?, type=?::question_type, updated_at=NOW() WHERE id=?";
        Connection conn = null;
        try {
            conn = DbConnection.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, question.getContent().trim());
                ps.setString(2, normalizeType(question.getType()));
                ps.setObject(3, question.getId());
                ps.executeUpdate();
            }
            replaceOptions(conn, question.getId(), options);
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.update", e);
            return rollback(conn);
        } finally {
            close(conn);
        }
    }

    public boolean delete(UUID id) {
        if (id == null) return false;
        String sql = "DELETE FROM question WHERE id=?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // A question already used by a quiz cannot be deleted because quiz_question has no ON DELETE CASCADE.
            LOGGER.log(Level.WARNING, "Question cannot be deleted: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean isUsedInQuiz(UUID questionId) {
        if (questionId == null) return false;
        String sql = "SELECT EXISTS(SELECT 1 FROM quiz_question WHERE question_id=?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        } catch (SQLException e) {
            return false;
        }
    }

    private void replaceOptions(Connection conn, UUID questionId, List<QuestionOption> options) throws SQLException {
        if (questionId == null) throw new SQLException("Question id was not generated.");
        try (PreparedStatement del = conn.prepareStatement("DELETE FROM question_option WHERE question_id=?")) {
            del.setObject(1, questionId);
            del.executeUpdate();
        }
        if (options == null) return;
        String sql = "INSERT INTO question_option (id, question_id, option_text, is_correct) " +
                     "VALUES (COALESCE(?,gen_random_uuid()),?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (QuestionOption o : options) {
                if (o == null || o.getOptionText() == null || o.getOptionText().trim().isEmpty()) continue;
                ps.setObject(1, o.getId());
                ps.setObject(2, questionId);
                ps.setString(3, o.getOptionText().trim());
                ps.setBoolean(4, o.isCorrect());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private List<QuestionOption> findOptionsByQuestionId(UUID id, Connection conn) throws SQLException {
        List<QuestionOption> list = new ArrayList<>();
        String sql = "SELECT id, question_id, option_text, is_correct " +
                     "FROM question_option WHERE question_id=? ORDER BY id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuestionOption o = new QuestionOption();
                    o.setId((UUID) rs.getObject("id"));
                    o.setQuestionId((UUID) rs.getObject("question_id"));
                    o.setOptionText(rs.getString("option_text"));
                    o.setCorrect(rs.getBoolean("is_correct"));
                            list.add(o);
                }
            }
        }
        return list;
    }

    private Question mapQuestion(ResultSet rs) throws SQLException {
        Question q = new Question();
        q.setId((UUID) rs.getObject("id"));
        q.setContent(rs.getString("content"));
        q.setType(rs.getString("type"));
        q.setCreatedAt(rs.getTimestamp("created_at"));
        q.setUpdatedAt(rs.getTimestamp("updated_at"));
        return q;
    }

    private static String normalizeType(String type) {
        if ("multiple_choice".equals(type)) return "multiple_choice";
        if ("text".equals(type)) return "text";
        return "single_choice";
    }

    private static void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i=0; i<params.size(); i++) ps.setObject(i+1, params.get(i));
    }

    private boolean rollback(Connection conn) {
        try { if (conn != null) conn.rollback(); } catch (SQLException ignored) {}
        return false;
    }

    private void close(Connection conn) {
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
}
