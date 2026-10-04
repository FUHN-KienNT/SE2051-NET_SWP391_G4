package com.learnhub.dao;

import com.learnhub.entity.Question;
import com.learnhub.entity.Quiz;
import com.learnhub.util.DbConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO for Quiz entity and Expert quiz management.
 */
public class QuizDAO {

    private static final Logger LOGGER = Logger.getLogger(QuizDAO.class.getName());

    // =========================================================
    // FIND QUIZ
    // =========================================================

    public Quiz findById(UUID id) {
        if (id == null) {
            return null;
        }

        String sql = baseSelect() + " WHERE q.id=?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.findById", e);
        }

        return null;
    }

    public List<Quiz> findByExpertId(UUID expertId, String keyword, UUID moduleId) {
        return findByExpertId(expertId, keyword, moduleId, null);
    }

    public List<Quiz> findByExpertId(
            UUID expertId,
            String keyword,
            UUID moduleId,
            UUID courseId) {

        List<Quiz> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(baseSelect());
        sql.append(" WHERE c.expert_id=? ");

        List<Object> params = new ArrayList<>();
        params.add(expertId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND q.title ILIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        if (moduleId != null) {
            sql.append("AND q.module_id=? ");
            params.add(moduleId);
        }

        if (courseId != null) {
            sql.append("AND c.id=? ");
            params.add(courseId);
        }

        sql.append("ORDER BY q.updated_at DESC");

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.findByExpertId", e);
        }

        return list;
    }

    public List<Quiz> findByModuleId(UUID moduleId) {

        List<Quiz> list = new ArrayList<>();

        String sql = baseSelect()
                + " WHERE q.module_id=? ORDER BY q.created_at ASC";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, moduleId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.findByModuleId", e);
        }

        return list;
    }

    // =========================================================
    // CREATE QUIZ
    // =========================================================

    public boolean insert(Quiz quiz) {

        if (quiz == null || quiz.getModuleId() == null
                || quiz.getTitle() == null
                || quiz.getTitle().trim().isEmpty()) {
            return false;
        }

        /*
         * IMPORTANT:
         *
         * quiz table has 7 columns:
         *
         * id
         * module_id
         * title
         * time_limit
         * pass_score
         * created_at
         * updated_at
         *
         * Therefore VALUES must contain exactly 7 values.
         */
        String sql =
                "INSERT INTO quiz " +
                "(id,module_id,title,time_limit,pass_score,created_at,updated_at) " +
                "VALUES (?,?,?,?,?,NOW(),NOW())";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            UUID id = quiz.getId() != null
                    ? quiz.getId()
                    : UUID.randomUUID();

            ps.setObject(1, id);
            ps.setObject(2, quiz.getModuleId());
            ps.setString(3, quiz.getTitle().trim());

            if (quiz.getTimeLimit() == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, quiz.getTimeLimit());
            }

            if (quiz.getPassScore() == null) {
                ps.setBigDecimal(5, new BigDecimal("5.0"));
            } else {
                ps.setBigDecimal(5, quiz.getPassScore());
            }

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.insert", e);
            return false;
        }
    }

    // =========================================================
    // UPDATE QUIZ
    // =========================================================

    public boolean update(Quiz quiz) {

        if (quiz == null || quiz.getId() == null
                || quiz.getModuleId() == null
                || quiz.getTitle() == null
                || quiz.getTitle().trim().isEmpty()) {
            return false;
        }

        String sql =
                "UPDATE quiz SET " +
                "module_id=?," +
                "title=?," +
                "time_limit=?," +
                "pass_score=?," +
                "updated_at=NOW() " +
                "WHERE id=?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, quiz.getModuleId());
            ps.setString(2, quiz.getTitle().trim());

            if (quiz.getTimeLimit() == null) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, quiz.getTimeLimit());
            }

            if (quiz.getPassScore() == null) {
                ps.setBigDecimal(4, new BigDecimal("5.0"));
            } else {
                ps.setBigDecimal(4, quiz.getPassScore());
            }

            ps.setObject(5, quiz.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.update", e);
            return false;
        }
    }

    // =========================================================
    // SAVE QUIZ + QUESTIONS IN ONE TRANSACTION
    // =========================================================

    /**
     * Creates or updates a quiz and its question relationships
     * in ONE database transaction.
     *
     * This prevents the following bad situation:
     *
     * Quiz inserted successfully
     *       ↓
     * Question relationship fails
     *       ↓
     * Quiz remains as an incomplete record
     */
    public boolean saveWithQuestions(
            UUID expertId,
            UUID quizId,
            UUID moduleId,
            String title,
            Integer timeLimit,
            BigDecimal passScore,
            List<UUID> questionIds) {

        if (expertId == null
                || moduleId == null
                || title == null
                || title.trim().isEmpty()
                || passScore == null) {
            return false;
        }

        if (timeLimit != null
                && (timeLimit < 1 || timeLimit > 600)) {
            return false;
        }

        if (passScore.compareTo(BigDecimal.ZERO) < 0
                || passScore.compareTo(BigDecimal.TEN) > 0) {
            return false;
        }

        Connection conn = null;

        try {
            conn = DbConnection.getConnection();
            conn.setAutoCommit(false);

            // -------------------------------------------------
            // 1. Check module belongs to current Expert
            // -------------------------------------------------

            if (!moduleBelongsToExpert(conn, moduleId, expertId)) {
                conn.rollback();
                return false;
            }

            UUID finalQuizId;

            // -------------------------------------------------
            // 2. CREATE
            // -------------------------------------------------

            if (quizId == null) {

                finalQuizId = UUID.randomUUID();

                String insertSql =
                        "INSERT INTO quiz " +
                        "(id,module_id,title,time_limit,pass_score,created_at,updated_at) " +
                        "VALUES (?,?,?,?,?,NOW(),NOW())";

                try (PreparedStatement ps =
                             conn.prepareStatement(insertSql)) {

                    ps.setObject(1, finalQuizId);
                    ps.setObject(2, moduleId);
                    ps.setString(3, title.trim());

                    if (timeLimit == null) {
                        ps.setNull(4, Types.INTEGER);
                    } else {
                        ps.setInt(4, timeLimit);
                    }

                    ps.setBigDecimal(5, passScore);

                    int affected = ps.executeUpdate();

                    if (affected != 1) {
                        conn.rollback();
                        return false;
                    }
                }

            } else {

                // -------------------------------------------------
                // 3. UPDATE
                // -------------------------------------------------

                if (!belongsToExpert(conn, quizId, expertId)) {
                    conn.rollback();
                    return false;
                }

                finalQuizId = quizId;

                String updateSql =
                        "UPDATE quiz SET " +
                        "module_id=?," +
                        "title=?," +
                        "time_limit=?," +
                        "pass_score=?," +
                        "updated_at=NOW() " +
                        "WHERE id=?";

                try (PreparedStatement ps =
                             conn.prepareStatement(updateSql)) {

                    ps.setObject(1, moduleId);
                    ps.setString(2, title.trim());

                    if (timeLimit == null) {
                        ps.setNull(3, Types.INTEGER);
                    } else {
                        ps.setInt(3, timeLimit);
                    }

                    ps.setBigDecimal(4, passScore);
                    ps.setObject(5, finalQuizId);

                    int affected = ps.executeUpdate();

                    if (affected != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                // Remove old question relationships first.
                String deleteQuestions =
                        "DELETE FROM quiz_question WHERE quiz_id=?";

                try (PreparedStatement ps =
                             conn.prepareStatement(deleteQuestions)) {

                    ps.setObject(1, finalQuizId);
                    ps.executeUpdate();
                }
            }

            // -------------------------------------------------
            // 4. INSERT SELECTED QUESTIONS
            // -------------------------------------------------

            if (questionIds != null && !questionIds.isEmpty()) {

                String insertQuestion =
                        "INSERT INTO quiz_question " +
                        "(id,quiz_id,question_id,order_index) " +
                        "VALUES (gen_random_uuid(),?,?,?)";

                Set<UUID> uniqueQuestionIds =
                        new LinkedHashSet<>(questionIds);

                try (PreparedStatement ps =
                             conn.prepareStatement(insertQuestion)) {

                    int orderIndex = 1;

                    for (UUID questionId : uniqueQuestionIds) {

                        if (questionId == null) {
                            continue;
                        }

                        ps.setObject(1, finalQuizId);
                        ps.setObject(2, questionId);
                        ps.setInt(3, orderIndex++);

                        ps.addBatch();
                    }

                    ps.executeBatch();
                }
            }

            // -------------------------------------------------
            // 5. COMMIT
            // -------------------------------------------------

            conn.commit();

            return true;

        } catch (SQLException e) {

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    LOGGER.log(Level.SEVERE,
                            "Rollback failed in QuizDAO.saveWithQuestions",
                            rollbackError);
                }
            }

            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.saveWithQuestions", e);

            return false;

        } finally {

            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING,
                            "Error closing connection",
                            e);
                }
            }
        }
    }

    // =========================================================
    // DELETE QUIZ
    // =========================================================

    public boolean delete(UUID id) {

        if (id == null) {
            return false;
        }

        String sql = "DELETE FROM quiz WHERE id=?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, id);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.delete", e);
            return false;
        }
    }

    // =========================================================
    // EXPERT OWNERSHIP
    // =========================================================

    public boolean belongsToExpert(UUID quizId, UUID expertId) {

        if (quizId == null || expertId == null) {
            return false;
        }

        String sql =
                "SELECT EXISTS(" +
                "SELECT 1 " +
                "FROM quiz q " +
                "JOIN module m ON q.module_id=m.id " +
                "JOIN course c ON m.course_id=c.id " +
                "WHERE q.id=? AND c.expert_id=?" +
                ")";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, quizId);
            ps.setObject(2, expertId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.belongsToExpert", e);
            return false;
        }
    }

    public boolean moduleBelongsToExpert(
            UUID moduleId,
            UUID expertId) {

        if (moduleId == null || expertId == null) {
            return false;
        }

        String sql =
                "SELECT EXISTS(" +
                "SELECT 1 " +
                "FROM module m " +
                "JOIN course c ON m.course_id=c.id " +
                "WHERE m.id=? AND c.expert_id=?" +
                ")";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, moduleId);
            ps.setObject(2, expertId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Error in QuizDAO.moduleBelongsToExpert", e);
            return false;
        }
    }

    // =========================================================
    // HELPER OWNERSHIP METHODS FOR TRANSACTION
    // =========================================================

    private boolean moduleBelongsToExpert(
            Connection conn,
            UUID moduleId,
            UUID expertId) throws SQLException {

        String sql =
                "SELECT EXISTS(" +
                "SELECT 1 " +
                "FROM module m " +
                "JOIN course c ON m.course_id=c.id " +
                "WHERE m.id=? AND c.expert_id=?" +
                ")";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, moduleId);
            ps.setObject(2, expertId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        }
    }

    private boolean belongsToExpert(
            Connection conn,
            UUID quizId,
            UUID expertId) throws SQLException {

        String sql =
                "SELECT EXISTS(" +
                "SELECT 1 " +
                "FROM quiz q " +
                "JOIN module m ON q.module_id=m.id " +
                "JOIN course c ON m.course_id=c.id " +
                "WHERE q.id=? AND c.expert_id=?" +
                ")";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, quizId);
            ps.setObject(2, expertId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        }
    }

    // =========================================================
    // OTHER METHODS
    // =========================================================

    public List<Question> findQuestions(UUID quizId) {
        return new QuestionDAO().findQuestionsByQuizId(quizId);
    }

    // =========================================================
    // SQL MAPPING
    // =========================================================

    private String baseSelect() {

        return "SELECT " +
                "q.id," +
                "q.module_id," +
                "q.title," +
                "q.time_limit," +
                "q.pass_score," +
                "q.created_at," +
                "q.updated_at," +
                "m.title module_title," +
                "c.id course_id," +
                "c.title course_title," +
                "(SELECT COUNT(*) " +
                " FROM quiz_question qq " +
                " WHERE qq.quiz_id=q.id) question_count " +
                "FROM quiz q " +
                "JOIN module m ON q.module_id=m.id " +
                "JOIN course c ON m.course_id=c.id";
    }

    private Quiz map(ResultSet rs) throws SQLException {

        Quiz q = new Quiz();

        q.setId((UUID) rs.getObject("id"));
        q.setModuleId((UUID) rs.getObject("module_id"));
        q.setTitle(rs.getString("title"));

        int timeLimit = rs.getInt("time_limit");
        q.setTimeLimit(rs.wasNull() ? null : timeLimit);

        q.setPassScore(rs.getBigDecimal("pass_score"));
        q.setCreatedAt(rs.getTimestamp("created_at"));
        q.setUpdatedAt(rs.getTimestamp("updated_at"));
        q.setModuleTitle(rs.getString("module_title"));
        q.setQuestionCount(rs.getInt("question_count"));

        return q;
    }
}