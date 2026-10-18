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
 * - changeAvailability()
 * - updateOrderIndex()
 */
public class LessonDAO {
    private static final Logger LOGGER = Logger.getLogger(LessonDAO.class.getName());

    public List<Lesson> findByModuleId(UUID moduleId) {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT l.id, l.module_id, l.title, l.content, l.order_index, l.created_at, l.updated_at, " +
                     "l.duration_minutes, l.status, m.title as module_title, m.course_id " +
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
                     "l.duration_minutes, l.status, m.title as module_title, m.course_id " +
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
                     "l.duration_minutes, l.status, m.title as module_title, m.course_id " +
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

    public boolean save(Lesson lesson) {
        if (lesson == null) return false;
        if (lesson.getId() != null && findById(lesson.getId()) != null) {
            return update(lesson);
        }
        return insert(lesson);
    }

    public boolean insert(Lesson lesson) {
        if (lesson == null || lesson.getModuleId() == null || lesson.getOrderIndex() < 1) {
            return false;
        }
        String lockSql = "SELECT id FROM module WHERE id = ? FOR UPDATE";
        String insertSql = "INSERT INTO lesson "
                + "(id, module_id, title, content, order_index, duration_minutes, status, created_at, updated_at) "
                + "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Serialize insertions within the selected module.
                try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                    ps.setObject(1, lesson.getModuleId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }
                // Move existing lessons down to make room.
                List<UUID> orderedIds = readLessonOrder(conn, lesson.getModuleId());
                if (lesson.getOrderIndex() > orderedIds.size() + 1) {
                    conn.rollback();
                    return false;
                }
                // Insert the new lesson at the requested position.
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setObject(1, lesson.getId());
                    ps.setObject(2, lesson.getModuleId());
                    ps.setString(3, lesson.getTitle());
                    ps.setString(4, lesson.getContent());
                    ps.setInt(5, lesson.getOrderIndex());
                    ps.setObject(6, lesson.getDurationMinutes(), Types.INTEGER);
                    ps.setString(7, lesson.getPublicationStatus());
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "Lesson insert did not succeed."
                        );
                    }
                }
                List<UUID> savedIds = readLessonOrder(conn, lesson.getModuleId());
                savedIds.remove(lesson.getId());
                savedIds.add(lesson.getOrderIndex() - 1, lesson.getId());
                writeLessonOrder(conn, lesson.getModuleId(), savedIds);
                conn.commit();
                return true;
            } catch (SQLException e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.insert", e);
            return false;
        }
    }

    public boolean update(Lesson lesson) {
        if (lesson == null || lesson.getModuleId() == null || lesson.getOrderIndex() < 1) return false;
        Lesson existing = findById(lesson.getId());
        if (existing == null) return false;
        UUID oldModule = existing.getModuleId(), newModule = lesson.getModuleId();
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Lock modules consistently with insert/delete.
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT id FROM module WHERE id IN (?, ?) ORDER BY id FOR UPDATE")) {
                    ps.setObject(1, oldModule); ps.setObject(2, newModule);
                    int count = 0;
                    try (ResultSet rs = ps.executeQuery()) { while (rs.next()) count++; }
                    if (count != (oldModule.equals(newModule) ? 1 : 2))
                        throw new SQLException("Module no longer exists.");
                }
                List<UUID> source = readLessonOrder(conn, oldModule);
                if (!source.remove(lesson.getId()))
                    throw new SQLException("Lesson changed concurrently. Please retry.");
                List<UUID> target = oldModule.equals(newModule)
                        ? source : readLessonOrder(conn, newModule);
                if (lesson.getOrderIndex() > target.size() + 1)
                    throw new SQLException("Order index is outside the module.");
                target.add(lesson.getOrderIndex() - 1, lesson.getId());
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE lesson SET module_id=?, title=?, content=?, order_index=?, duration_minutes=?, status=?, updated_at=NOW() WHERE id=? AND module_id=?")) {
                    ps.setObject(1, newModule); ps.setString(2, lesson.getTitle());
                    ps.setString(3, lesson.getContent()); ps.setInt(4, lesson.getOrderIndex());
                    ps.setObject(5, lesson.getDurationMinutes(), Types.INTEGER);
                    ps.setString(6, lesson.getPublicationStatus());
                    ps.setObject(7, lesson.getId()); ps.setObject(8, oldModule);
                    if (ps.executeUpdate() != 1) throw new SQLException("Lesson update failed.");
                }
                if (!oldModule.equals(newModule)) writeLessonOrder(conn, oldModule, source);
                writeLessonOrder(conn, newModule, target);
                conn.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                try { conn.rollback(); } catch (SQLException rollbackError) { e.addSuppressed(rollbackError); }
                throw e;
            }
        } catch (SQLException | RuntimeException e) {
            LOGGER.log(Level.SEVERE, "Cannot update and reorder lesson", e);
            return false;
        }
    }

    private List<UUID> readLessonOrder(Connection conn, UUID moduleId) throws SQLException {
        List<UUID> ids = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT id FROM lesson WHERE module_id=? ORDER BY order_index, created_at, id")) {
            ps.setObject(1, moduleId);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) ids.add((UUID) rs.getObject("id")); }
        }
        return ids;
    }

    private void writeLessonOrder(Connection conn, UUID moduleId, List<UUID> ids) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE lesson SET order_index=?, updated_at=NOW() WHERE id=? AND module_id=?")) {
            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(1, i + 1); ps.setObject(2, ids.get(i)); ps.setObject(3, moduleId);
                ps.addBatch();
            }
            for (int count : ps.executeBatch())
                if (count != 1 && count != Statement.SUCCESS_NO_INFO) throw new SQLException("Reordering failed.");
        }
    }

    public boolean changeAvailability(UUID expertId, UUID courseId, UUID lessonId,
                                      Timestamp expectedUpdatedAt, String expectedStatus, String targetStatus) {
        String sql = "UPDATE lesson SET status=?, updated_at=NOW() "
                + "WHERE id=? AND status=? AND updated_at=? "
                + "AND module_id IN (SELECT m.id FROM module m JOIN course c ON c.id=m.course_id "
                + "WHERE c.id=? AND c.expert_id=?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, targetStatus);
            ps.setObject(2, lessonId);
            ps.setString(3, expectedStatus);
            ps.setTimestamp(4, expectedUpdatedAt);
            ps.setObject(5, courseId);
            ps.setObject(6, expertId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot change lesson availability.", e);
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

    public boolean reviewPublication(UUID courseId, UUID lessonId,
                                     Timestamp expectedUpdatedAt, String status) {
        String sql = "UPDATE lesson SET status=?, updated_at=NOW() "
                + "WHERE id=? AND status='draft' AND updated_at=? "
                + "AND module_id IN (SELECT id FROM module WHERE course_id=?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, lessonId);
            ps.setTimestamp(3, expectedUpdatedAt);
            ps.setObject(4, courseId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot save lesson review.", e);
        }
    }

    private Lesson mapResultSetToLesson(ResultSet rs) throws SQLException {
        Lesson l = new Lesson();
        l.setId((UUID) rs.getObject("id"));
        l.setModuleId((UUID) rs.getObject("module_id"));
        l.setTitle(rs.getString("title"));
        l.setContent(rs.getString("content"));
        l.setOrderIndex(rs.getInt("order_index"));
        l.setDurationMinutes((Integer) rs.getObject("duration_minutes"));
        l.setPublicationStatus(rs.getString("status"));
        l.setCreatedAt(rs.getTimestamp("created_at"));
        l.setUpdatedAt(rs.getTimestamp("updated_at"));
        try {
            l.setModuleTitle(rs.getString("module_title"));
            l.setCourseId((UUID) rs.getObject("course_id"));
        } catch (SQLException ignored) {
        }
        return l;
    }

    public int countCoursesAwaitingReview() {
        String sql = "SELECT COUNT(DISTINCT m.course_id) FROM lesson l " +
                     "JOIN module m ON l.module_id = m.id " +
                     "WHERE l.status = 'draft'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.countCoursesAwaitingReview: " + e.getMessage(), e);
        }
        return 0;
    }

    public List<com.learnhub.dto.ManagerDashboardDTO.PendingReviewItem> findCoursesAwaitingReview(int limit) {
        List<com.learnhub.dto.ManagerDashboardDTO.PendingReviewItem> list = new ArrayList<>();
        String sql = "SELECT c.id as course_id, c.title as course_title, s.name as category_name, " +
                     "u.username as expert_name, COUNT(l.id) as pending_count " +
                     "FROM course c " +
                     "JOIN module m ON m.course_id = c.id " +
                     "JOIN lesson l ON l.module_id = m.id " +
                     "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                     "LEFT JOIN setting s ON c.category_id = s.id " +
                     "WHERE l.status = 'draft' " +
                     "GROUP BY c.id, c.title, s.name, u.username " +
                     "ORDER BY pending_count DESC, c.title ASC LIMIT ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new com.learnhub.dto.ManagerDashboardDTO.PendingReviewItem(
                            (UUID) rs.getObject("course_id"),
                            rs.getString("course_title"),
                            rs.getString("category_name"),
                            rs.getString("expert_name"),
                            rs.getInt("pending_count")
                    ));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LessonDAO.findCoursesAwaitingReview: " + e.getMessage(), e);
        }
        return list;
    }
}
