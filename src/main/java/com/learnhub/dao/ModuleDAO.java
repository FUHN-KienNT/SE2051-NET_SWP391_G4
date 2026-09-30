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

        String sql = "SELECT id, course_id, title, content, order_index, created_at, updated_at " +
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

        String sql = "SELECT id, course_id, title, content, order_index, created_at, updated_at " +
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

        String sql = "INSERT INTO module (id, course_id, title, content, order_index, created_at, updated_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, NOW(), NOW())";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, module.getId());
            ps.setObject(2, module.getCourseId());
            ps.setString(3, module.getTitle());
            ps.setString(4, module.getContent());
            ps.setInt(5, module.getOrderIndex());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in ModuleDAO.insert: " + e.getMessage(), e);
            return false;
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

    private Module mapResultSetToModule(ResultSet rs) throws SQLException {
        Module m = new Module();
        m.setId((UUID) rs.getObject("id"));
        m.setCourseId((UUID) rs.getObject("course_id"));
        m.setTitle(rs.getString("title"));
        m.setContent(rs.getString("content"));
        m.setOrderIndex(rs.getInt("order_index"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setUpdatedAt(rs.getTimestamp("updated_at"));
        return m;
    }
}
