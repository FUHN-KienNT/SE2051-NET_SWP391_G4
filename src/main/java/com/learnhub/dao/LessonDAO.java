package com.learnhub.dao;

import com.learnhub.entity.Lesson;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Lesson entity.
 * Implements methods specified in SDS Lesson Learning & Content Management Class Diagrams:
 * - findByModuleId()
 * - findById()
 * - findByCourseId()
 * - save()
 * - delete()
 * - updateOrderIndex()
 */
public class LessonDAO {
    private static final Logger LOGGER = Logger.getLogger(LessonDAO.class.getName());

    public List<Lesson> findByModuleId(UUID moduleId) {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT l.id, l.module_id, l.title, l.content, l.order_index, l.created_at, l.updated_at, " +
                     "m.title as module_title, m.course_id " +
                     "FROM lesson l " +
                     "JOIN module m ON l.module_id = m.id " +
                     "WHERE l.module_id = ? ORDER BY l.order_index ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, moduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLesson(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.findByModuleId: " + e.getMessage(), e);
        }
        return list;
    }

    public Lesson findById(UUID lessonId) {
        if (lessonId == null) return null;
        String sql = "SELECT l.id, l.module_id, l.title, l.content, l.order_index, l.created_at, l.updated_at, " +
                     "m.title as module_title, m.course_id " +
                     "FROM lesson l " +
                     "JOIN module m ON l.module_id = m.id " +
                     "WHERE l.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToLesson(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }

    public List<Lesson> findByCourseId(UUID courseId) {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT l.id, l.module_id, l.title, l.content, l.order_index, l.created_at, l.updated_at, " +
                     "m.title as module_title, m.course_id " +
                     "FROM lesson l " +
                     "JOIN module m ON l.module_id = m.id " +
                     "WHERE m.course_id = ? ORDER BY m.order_index ASC, l.order_index ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLesson(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.findByCourseId: " + e.getMessage(), e);
        }
        return list;
    }

    public void save(Lesson lesson) {
        if (lesson.getId() != null && findById(lesson.getId()) != null) {
            update(lesson);
        } else {
            insert(lesson);
        }
    }

    public boolean insert(Lesson lesson) {
        String sql = "INSERT INTO lesson (id, module_id, title, content, order_index, created_at, updated_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, lesson.getId());
            ps.setObject(2, lesson.getModuleId());
            ps.setString(3, lesson.getTitle());
            ps.setString(4, lesson.getContent());
            ps.setInt(5, lesson.getOrderIndex());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.insert: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean update(Lesson lesson) {
        String sql = "UPDATE lesson SET title = ?, content = ?, order_index = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, lesson.getTitle());
            ps.setString(2, lesson.getContent());
            ps.setInt(3, lesson.getOrderIndex());
            ps.setObject(4, lesson.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.update: " + e.getMessage(), e);
            return false;
        }
    }

    public void delete(UUID lessonId) {
        String deleteProgressSql = "DELETE FROM learning_process WHERE lesson_id = ?";
        String sql = "DELETE FROM lesson WHERE id = ?";
        try (Connection conn = DbConnection.getConnection()) {
            try (PreparedStatement psProgress = conn.prepareStatement(deleteProgressSql)) {
                psProgress.setObject(1, lessonId);
                psProgress.executeUpdate();
            } catch (SQLException ignored) {
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setObject(1, lessonId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.delete: " + e.getMessage(), e);
        }
    }

    public void updateOrderIndex(UUID lessonId, int orderIndex) {
        String sql = "UPDATE lesson SET order_index = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderIndex);
            ps.setObject(2, lessonId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.updateOrderIndex: " + e.getMessage(), e);
        }
    }

    private Lesson mapResultSetToLesson(ResultSet rs) throws SQLException {
        Lesson l = new Lesson();
        l.setId((UUID) rs.getObject("id"));
        l.setModuleId((UUID) rs.getObject("module_id"));
        l.setTitle(rs.getString("title"));
        l.setContent(rs.getString("content"));
        l.setOrderIndex(rs.getInt("order_index"));
        l.setCreatedAt(rs.getTimestamp("created_at"));
        l.setUpdatedAt(rs.getTimestamp("updated_at"));
        try {
            l.setModuleTitle(rs.getString("module_title"));
            l.setCourseId((UUID) rs.getObject("course_id"));
        } catch (SQLException ignored) {
        }
        return l;
    }
}
