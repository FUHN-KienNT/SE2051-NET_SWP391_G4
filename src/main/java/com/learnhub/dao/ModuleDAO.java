package com.learnhub.dao;

import com.learnhub.entity.Module;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Module entity.
 * Handles CRUD operations for course curriculum modules.
 */
public class ModuleDAO {
    private static final Logger LOGGER = Logger.getLogger(ModuleDAO.class.getName());

    public List<Module> findByCourseId(UUID courseId) {
        List<Module> list = new ArrayList<>();
        if (courseId == null) {
            return list;
        }

        String sql = "SELECT id, course_id, title, content, order_index, created_at, updated_at, hidden " +
                     "FROM module WHERE course_id = ? ORDER BY order_index ASC";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToModule(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.findByCourseId: " + e.getMessage(), e);
        }
        return list;
    }

    public Module findById(UUID id) {
        if (id == null) {
            return null;
        }

        String sql = "SELECT id, course_id, title, content, order_index, created_at, updated_at, hidden " +
                     "FROM module WHERE id = ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToModule(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean insert(Module module) {
        if (module == null) {
            return false;
        }
        String sql = "INSERT INTO module "
                + "(id, course_id, title, content, order_index, created_at, updated_at) "
                + "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, NOW(), NOW())";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, module.getId());
            ps.setObject(2, module.getCourseId());
            ps.setString(3, module.getTitle());
            ps.setString(4, module.getContent());
            ps.setInt(5, module.getOrderIndex());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.insert", e);
            return false;
        }
    }

    public boolean appendForExpert(UUID courseId, UUID expertId, String title) throws SQLException {
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement lock = conn.prepareStatement(
                        "SELECT id FROM course WHERE id = ? AND expert_id = ? FOR UPDATE")) {
                    lock.setObject(1, courseId);
                    lock.setObject(2, expertId);
                    try (ResultSet result = lock.executeQuery()) {
                        if (!result.next()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }
                try (PreparedStatement insert = conn.prepareStatement("""
                        INSERT INTO module (course_id, title, order_index)
                        SELECT ?, ?, COALESCE(MAX(order_index), 0) + 1
                        FROM module WHERE course_id = ?
                        """)) {
                    insert.setObject(1, courseId);
                    insert.setString(2, title);
                    insert.setObject(3, courseId);
                    insert.executeUpdate();
                }
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
        }
    }

    public boolean update(Module module) {
        if (module == null || module.getId() == null) {
            return false;
        }

        String sql = "UPDATE module SET title = ?, content = ?, order_index = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, module.getTitle());
            ps.setString(2, module.getContent());
            ps.setInt(3, module.getOrderIndex());
            ps.setObject(4, module.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.update: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean delete(UUID id) {
        if (id == null) {
            return false;
        }

        String sql = "DELETE FROM module WHERE id = ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.delete: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean updateOrderIndex(UUID id, int orderIndex) {
        if (id == null) {
            return false;
        }

        String sql = "UPDATE module SET order_index = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderIndex);
            ps.setObject(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.updateOrderIndex: " + e.getMessage(), e);
            return false;
        }
    }

    public int countByCourseId(UUID courseId) {
        if (courseId == null) {
            return 0;
        }

        String sql = "SELECT COUNT(*) FROM module WHERE course_id = ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.countByCourseId: " + e.getMessage(), e);
        }
        return 0;
    }

    public List<Module> findByExpertId(UUID expertId) {
        List<Module> list = new ArrayList<>();
        if (expertId == null) return list;
        String sql = "SELECT m.id,m.course_id,m.title,m.content,m.order_index,m.created_at,m.updated_at,m.hidden,c.title AS course_title " +
                "FROM module m JOIN course c ON m.course_id=c.id " +
                "WHERE c.expert_id=? ORDER BY c.title ASC,m.order_index ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, expertId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Module m = mapResultSetToModule(rs);
                    m.setCourseTitle(rs.getString("course_title"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.findByExpertId: " + e.getMessage(), e);
        }
        return list;
    }

    public boolean updateForExpert(UUID courseId, UUID moduleId, UUID expertId, String title, Boolean hidden) throws SQLException {
        String sql = """
                UPDATE module m SET title = COALESCE(?, m.title),
                    hidden = COALESCE(?, m.hidden), updated_at = NOW()
                FROM course c WHERE m.course_id = c.id
                    AND c.id = ? AND m.id = ? AND c.expert_id = ?
                """;
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setObject(2, hidden, Types.BOOLEAN);
            ps.setObject(3, courseId);
            ps.setObject(4, moduleId);
            ps.setObject(5, expertId);
            return ps.executeUpdate() == 1;
        }
    }

    private Module mapResultSetToModule(ResultSet rs) throws SQLException {
        Module m = new Module();
        m.setId((UUID) rs.getObject("id"));
        m.setCourseId((UUID) rs.getObject("course_id"));
        m.setTitle(rs.getString("title"));
        m.setHidden(rs.getBoolean("hidden"));
        m.setContent(rs.getString("content"));
        m.setOrderIndex(rs.getInt("order_index"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setUpdatedAt(rs.getTimestamp("updated_at"));
        return m;
    }
}
