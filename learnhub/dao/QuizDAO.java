package com.learnhub.dao;

import com.learnhub.entity.Question;
import com.learnhub.entity.Quiz;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/** DAO for Quiz entity and Expert quiz management. */
public class QuizDAO {
    private static final Logger LOGGER = Logger.getLogger(QuizDAO.class.getName());

    public Quiz findById(UUID id) {
        if (id == null) return null;
        String sql = baseSelect() + " WHERE q.id=?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.findById", e);
        }
        return null;
    }

    public List<Quiz> findByExpertId(UUID expertId, String keyword, UUID moduleId) {
        return findByExpertId(expertId, keyword, moduleId, null);
    }

    public List<Quiz> findByExpertId(UUID expertId, String keyword, UUID moduleId, UUID courseId) {
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
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.findByExpertId", e);
        }
        return list;
    }

    public List<Quiz> findByModuleId(UUID moduleId) {
        List<Quiz> list = new ArrayList<>();
        String sql = baseSelect() + " WHERE q.module_id=? ORDER BY q.created_at ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, moduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.findByModuleId", e);
        }
        return list;
    }

    public boolean insert(Quiz quiz) {
        String sql = "INSERT INTO quiz (id,module_id,title,time_limit,pass_score,created_at,updated_at) " +
                     "VALUES (COALESCE(?,gen_random_uuid()),?,?,?,?,?,NOW(),NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, quiz.getId());
            ps.setObject(2, quiz.getModuleId());
            ps.setString(3, quiz.getTitle().trim());
            if (quiz.getTimeLimit() == null) ps.setNull(4, Types.INTEGER);
            else ps.setInt(4, quiz.getTimeLimit());
            if (quiz.getPassScore() == null) ps.setBigDecimal(5, new java.math.BigDecimal("5.0"));
            else ps.setBigDecimal(5, quiz.getPassScore());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.insert", e);
            return false;
        }
    }

    public boolean update(Quiz quiz) {
        if (quiz == null || quiz.getId() == null) return false;
        String sql = "UPDATE quiz SET module_id=?,title=?,time_limit=?,pass_score=?,updated_at=NOW() WHERE id=?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, quiz.getModuleId());
            ps.setString(2, quiz.getTitle().trim());
            if (quiz.getTimeLimit() == null) ps.setNull(3, Types.INTEGER);
            else ps.setInt(3, quiz.getTimeLimit());
            if (quiz.getPassScore() == null) ps.setBigDecimal(4, new java.math.BigDecimal("5.0"));
            else ps.setBigDecimal(4, quiz.getPassScore());
            ps.setObject(5, quiz.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.update", e);
            return false;
        }
    }

    public boolean delete(UUID id) {
        if (id == null) return false;
        String sql = "DELETE FROM quiz WHERE id=?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in QuizDAO.delete", e);
            return false;
        }
    }

    public boolean belongsToExpert(UUID quizId, UUID expertId) {
        String sql = "SELECT EXISTS(SELECT 1 FROM quiz q " +
                     "JOIN module m ON q.module_id=m.id " +
                     "JOIN course c ON m.course_id=c.id " +
                     "WHERE q.id=? AND c.expert_id=?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, quizId);
            ps.setObject(2, expertId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean moduleBelongsToExpert(UUID moduleId, UUID expertId) {
        String sql = "SELECT EXISTS(SELECT 1 FROM module m " +
                     "JOIN course c ON m.course_id=c.id " +
                     "WHERE m.id=? AND c.expert_id=?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, moduleId);
            ps.setObject(2, expertId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public List<Question> findQuestions(UUID quizId) {
        return new QuestionDAO().findQuestionsByQuizId(quizId);
    }

    private String baseSelect() {
        return "SELECT q.id,q.module_id,q.title,q.time_limit,q.pass_score,q.created_at,q.updated_at," +
               "m.title module_title,c.id course_id,c.title course_title," +
               "(SELECT COUNT(*) FROM quiz_question qq WHERE qq.quiz_id=q.id) question_count " +
               "FROM quiz q JOIN module m ON q.module_id=m.id JOIN course c ON m.course_id=c.id";
    }

    private Quiz map(ResultSet rs) throws SQLException {
        Quiz q = new Quiz();
        q.setId((UUID) rs.getObject("id"));
        q.setModuleId((UUID) rs.getObject("module_id"));
        q.setTitle(rs.getString("title"));
        int tl = rs.getInt("time_limit");
        q.setTimeLimit(rs.wasNull() ? null : tl);
        q.setPassScore(rs.getBigDecimal("pass_score"));
        q.setCreatedAt(rs.getTimestamp("created_at"));
        q.setUpdatedAt(rs.getTimestamp("updated_at"));
        q.setModuleTitle(rs.getString("module_title"));
        q.setQuestionCount(rs.getInt("question_count"));
        return q;
    }
}
