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
 *
 * A question is shared across quizzes.
 * Quiz membership is maintained by QuizQuestionDAO.
 */
public class QuestionDAO {

    private static final Logger LOGGER =
            Logger.getLogger(QuestionDAO.class.getName());

    public List<Question> search(String keyword, String type) {
        List<Question> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT q.id, q.content, q.type, q.created_at, q.updated_at, "
                + "(SELECT COUNT(*) FROM question_option qo "
                + " WHERE qo.question_id=q.id) option_count, "
                + "(SELECT COUNT(*) FROM quiz_question qq "
                + " WHERE qq.question_id=q.id) quiz_count "
                + "FROM question q WHERE 1=1 "
        );

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
                while (rs.next()) {
                    Question q = mapQuestion(rs);
                    q.setOptions(findOptionsByQuestionId(q.getId(), conn));
                    list.add(q);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.search", e);
        }

        return list;
    }

    public Question findById(UUID id) {
        if (id == null) {
            return null;
        }

        String sql =
                "SELECT id, content, type, created_at, updated_at "
                + "FROM question WHERE id=?";

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

        if (quizId == null) {
            return list;
        }

        String sql =
                "SELECT q.id, q.content, q.type, q.created_at, q.updated_at, "
                + "qq.order_index "
                + "FROM question q "
                + "JOIN quiz_question qq ON q.id=qq.question_id "
                + "WHERE qq.quiz_id=? "
                + "ORDER BY qq.order_index ASC, q.created_at ASC";

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
            LOGGER.log(Level.SEVERE,
                    "Error in QuestionDAO.findQuestionsByQuizId", e);
        }

        return list;
    }

    public List<QuestionOption> findOptionsByQuestionId(UUID questionId) {
        if (questionId == null) {
            return new ArrayList<>();
        }

        try (Connection conn = DbConnection.getConnection()) {
            return findOptionsByQuestionId(questionId, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuestionDAO.findOptionsByQuestionId", e);
            return new ArrayList<>();
        }
    }

    /**
     * CREATE question.
     */
    public boolean insert(
            Question question,
            List<QuestionOption> options) {

        if (question == null
                || question.getId() == null
                || question.getContent() == null
                || question.getContent().trim().isEmpty()) {
            return false;
        }

        String sql =
                "INSERT INTO question "
                + "(id, content, type, created_at, updated_at) "
                + "VALUES (?, ?, ?::question_type, NOW(), NOW())";

        Connection conn = null;

        try {
            conn = DbConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setObject(1, question.getId());
                ps.setString(2, question.getContent().trim());
                ps.setString(3, normalizeType(question.getType()));

                ps.executeUpdate();
            }

            insertOptions(conn, question.getId(), options);

            conn.commit();
            return true;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.insert", e);
            return rollback(conn);

        } finally {
            close(conn);
        }
    }

    /**
     * UPDATE question.
     *
     * IMPORTANT:
     * Không xóa toàn bộ question_option.
     * Các option cũ sẽ được UPDATE bằng ID cũ.
     * Option mới sẽ INSERT.
     */
    public boolean update(
            Question question,
            List<QuestionOption> options) {

        if (question == null
                || question.getId() == null
                || question.getContent() == null
                || question.getContent().trim().isEmpty()) {
            return false;
        }

        String sql =
                "UPDATE question "
                + "SET content=?, type=?::question_type, updated_at=NOW() "
                + "WHERE id=?";

        Connection conn = null;

        try {
            conn = DbConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update question
            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, question.getContent().trim());
                ps.setString(2, normalizeType(question.getType()));
                ps.setObject(3, question.getId());

                int affected = ps.executeUpdate();

                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Update / insert options
            updateOptions(conn, question.getId(), options);

            conn.commit();
            return true;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuestionDAO.update", e);
            return rollback(conn);

        } finally {
            close(conn);
        }
    }

    /**
     * DELETE question.
     */
    public boolean delete(UUID id) {
        if (id == null) {
            return false;
        }

        String sql = "DELETE FROM question WHERE id=?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                    "Question cannot be deleted: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Check question is currently used in a quiz.
     */
    public boolean isUsedInQuiz(UUID questionId) {
        if (questionId == null) {
            return false;
        }

        String sql =
                "SELECT EXISTS("
                + "SELECT 1 FROM quiz_question "
                + "WHERE question_id=?"
                + ")";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, questionId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                    "Error in QuestionDAO.isUsedInQuiz", e);
            return false;
        }
    }

    /**
     * Insert options for a newly created question.
     */
    private void insertOptions(
            Connection conn,
            UUID questionId,
            List<QuestionOption> options) throws SQLException {

        if (questionId == null || options == null) {
            return;
        }

        String sql =
                "INSERT INTO question_option "
                + "(id, question_id, option_text, is_correct) "
                + "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            for (QuestionOption option : options) {

                if (option == null
                        || option.getOptionText() == null
                        || option.getOptionText().trim().isEmpty()) {
                    continue;
                }

                UUID optionId = option.getId();

                if (optionId == null) {
                    optionId = UUID.randomUUID();
                }

                ps.setObject(1, optionId);
                ps.setObject(2, questionId);
                ps.setString(3, option.getOptionText().trim());
                ps.setBoolean(4, option.isCorrect());

                ps.addBatch();
            }

            ps.executeBatch();
        }
    }

    /**
     * Update existing options by ID.
     *
     * Existing option:
     *     UPDATE question_option ...
     *
     * New option:
     *     INSERT question_option ...
     *
     * Removed option:
     *     DELETE only if it has never been used in quiz_answer.
     *
     * This keeps old question_option IDs alive when they are referenced
     * by quiz_answer.
     */
    private void updateOptions(
            Connection conn,
            UUID questionId,
            List<QuestionOption> options) throws SQLException {

        if (questionId == null) {
            throw new SQLException("Question id is null.");
        }

        if (options == null) {
            return;
        }

        Set<UUID> submittedOptionIds = new HashSet<>();

        String updateSql =
                "UPDATE question_option "
                + "SET option_text=?, is_correct=? "
                + "WHERE id=? AND question_id=?";

        String insertSql =
                "INSERT INTO question_option "
                + "(id, question_id, option_text, is_correct) "
                + "VALUES (?, ?, ?, ?)";

        try (PreparedStatement updatePs =
                     conn.prepareStatement(updateSql);
             PreparedStatement insertPs =
                     conn.prepareStatement(insertSql)) {

            for (QuestionOption option : options) {

                if (option == null
                        || option.getOptionText() == null
                        || option.getOptionText().trim().isEmpty()) {
                    continue;
                }

                UUID optionId = option.getId();

                /*
                 * Existing option:
                 * giữ nguyên ID.
                 */
                if (optionId != null) {

                    submittedOptionIds.add(optionId);

                    updatePs.setString(
                            1,
                            option.getOptionText().trim()
                    );

                    updatePs.setBoolean(
                            2,
                            option.isCorrect()
                    );

                    updatePs.setObject(3, optionId);
                    updatePs.setObject(4, questionId);

                    updatePs.addBatch();

                } else {

                    /*
                     * New option:
                     * tạo ID mới.
                     */
                    UUID newId = UUID.randomUUID();

                    insertPs.setObject(1, newId);
                    insertPs.setObject(2, questionId);
                    insertPs.setString(
                            3,
                            option.getOptionText().trim()
                    );
                    insertPs.setBoolean(
                            4,
                            option.isCorrect()
                    );

                    insertPs.addBatch();
                }
            }

            updatePs.executeBatch();
            insertPs.executeBatch();
        }

        /*
         * Xử lý các option đã bị xóa khỏi form.
         *
         * Chỉ xóa nếu option chưa từng được sử dụng trong quiz_answer.
         * Nếu đã được sử dụng thì giữ lại để không phá FK.
         */
        deleteRemovedOptions(
                conn,
                questionId,
                submittedOptionIds
        );
    }

    /**
     * Delete options removed from the edit form,
     * but never delete an option already referenced by quiz_answer.
     */
    private void deleteRemovedOptions(
            Connection conn,
            UUID questionId,
            Set<UUID> submittedOptionIds) throws SQLException {

        String selectSql =
                "SELECT id "
                + "FROM question_option "
                + "WHERE question_id=?";

        List<UUID> existingIds = new ArrayList<>();

        try (PreparedStatement ps =
                     conn.prepareStatement(selectSql)) {

            ps.setObject(1, questionId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    existingIds.add(
                            (UUID) rs.getObject("id")
                    );
                }
            }
        }

        String checkAnswerSql =
                "SELECT EXISTS("
                + "SELECT 1 FROM quiz_answer "
                + "WHERE question_option_id=?"
                + ")";

        String deleteSql =
                "DELETE FROM question_option WHERE id=?";

        try (PreparedStatement checkPs =
                     conn.prepareStatement(checkAnswerSql);
             PreparedStatement deletePs =
                     conn.prepareStatement(deleteSql)) {

            for (UUID existingId : existingIds) {

                /*
                 * Option vẫn còn trên form -> không xóa.
                 */
                if (submittedOptionIds.contains(existingId)) {
                    continue;
                }

                /*
                 * Kiểm tra option có được dùng trong quiz_answer không.
                 */
                checkPs.setObject(1, existingId);

                boolean used = false;

                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        used = rs.getBoolean(1);
                    }
                }

                /*
                 * Nếu chưa được dùng -> có thể xóa.
                 */
                if (!used) {
                    deletePs.setObject(1, existingId);
                    deletePs.executeUpdate();
                }

                /*
                 * Nếu đã được dùng:
                 * KHÔNG DELETE.
                 *
                 * Lý do:
                 * quiz_answer.question_option_id
                 * đang tham chiếu tới option này.
                 */
            }
        }
    }

    private List<QuestionOption> findOptionsByQuestionId(
            UUID id,
            Connection conn) throws SQLException {

        List<QuestionOption> list = new ArrayList<>();

        String sql =
                "SELECT id, question_id, option_text, is_correct "
                + "FROM question_option "
                + "WHERE question_id=? "
                + "ORDER BY id";

        try (PreparedStatement ps =
                     conn.prepareStatement(sql)) {

            ps.setObject(1, id);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    QuestionOption o =
                            new QuestionOption();

                    o.setId(
                            (UUID) rs.getObject("id")
                    );

                    o.setQuestionId(
                            (UUID) rs.getObject("question_id")
                    );

                    o.setOptionText(
                            rs.getString("option_text")
                    );

                    o.setCorrect(
                            rs.getBoolean("is_correct")
                    );

                    list.add(o);
                }
            }
        }

        return list;
    }

    private Question mapQuestion(ResultSet rs)
            throws SQLException {

        Question q = new Question();

        q.setId((UUID) rs.getObject("id"));
        q.setContent(rs.getString("content"));
        q.setType(rs.getString("type"));
        q.setCreatedAt(rs.getTimestamp("created_at"));
        q.setUpdatedAt(rs.getTimestamp("updated_at"));

        return q;
    }

    private static String normalizeType(String type) {

        if ("multiple_choice".equals(type)) {
            return "multiple_choice";
        }

        if ("text".equals(type)) {
            return "text";
        }

        return "single_choice";
    }

    private static void bind(
            PreparedStatement ps,
            List<Object> params) throws SQLException {

        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private boolean rollback(Connection conn) {

        try {
            if (conn != null) {
                conn.rollback();
            }
        } catch (SQLException ignored) {
        }

        return false;
    }

    private void close(Connection conn) {

        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException ignored) {
        }
    }
}