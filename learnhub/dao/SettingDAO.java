package com.learnhub.dao;

import com.learnhub.entity.Setting;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SettingDAO {
    private static final Logger LOGGER = Logger.getLogger(SettingDAO.class.getName());

    public List<Setting> findActiveCategories() {
        List<Setting> categories = new ArrayList<>();
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                     "FROM setting WHERE type = 'category' AND status = TRUE ORDER BY sort_order ASC, name ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.add(mapResultSetToSetting(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findActiveCategories: " + e.getMessage(), e);
        }
        return categories;
    }

    public List<Setting> findByType(String type) {
        List<Setting> list = new ArrayList<>();
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                     "FROM setting WHERE type = ? AND status = TRUE ORDER BY sort_order ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSetting(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByType: " + e.getMessage(), e);
        }
        return list;
    }

    public Setting findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                     "FROM setting WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSetting(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findById: " + e.getMessage(), e);
        }
        return null;
    }

    public Setting findByCode(String code) {
        if (code == null) return null;
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                     "FROM setting WHERE code = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSetting(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByCode: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Find all role settings (merged from RoleDAO).
     */
    public List<Setting> findAllRoles() {
        return findByType("role");
    }

    public List<Setting> findAll() {
        List<Setting> list = new ArrayList<>();
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                     "FROM setting ORDER BY type ASC, sort_order ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSetting(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findAll: " + e.getMessage(), e);
        }
        return list;
    }

    private Setting mapResultSetToSetting(ResultSet rs) throws SQLException {
        Setting s = new Setting();
        s.setId((UUID) rs.getObject("id"));
        s.setType(rs.getString("type"));
        s.setCode(rs.getString("code"));
        s.setName(rs.getString("name"));
        s.setDescription(rs.getString("description"));
        s.setStatus(rs.getBoolean("status"));
        s.setSortOrder(rs.getInt("sort_order"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setUpdatedAt(rs.getTimestamp("updated_at"));
        return s;
    }
}
