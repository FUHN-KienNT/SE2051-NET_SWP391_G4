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

    public List<Setting> findSettings(String search, String type, String status, String sortBy, String sortOrder, int offset, int limit) {
        List<Setting> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                "FROM setting WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(name) LIKE ? OR LOWER(code) LIKE ? OR LOWER(COALESCE(description, '')) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        if (type != null && !type.trim().isEmpty() && !type.equalsIgnoreCase("all")) {
            sql.append("AND type = ? ");
            params.add(type.trim());
        }

        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            if ("active".equalsIgnoreCase(status) || "true".equalsIgnoreCase(status)) {
                sql.append("AND status = TRUE ");
            } else if ("inactive".equalsIgnoreCase(status) || "false".equalsIgnoreCase(status)) {
                sql.append("AND status = FALSE ");
            }
        }

        String orderCol = "type ASC, sort_order";
        if ("name".equalsIgnoreCase(sortBy)) {
            orderCol = "name";
        } else if ("code".equalsIgnoreCase(sortBy)) {
            orderCol = "code";
        } else if ("type".equalsIgnoreCase(sortBy)) {
            orderCol = "type";
        } else if ("sort_order".equalsIgnoreCase(sortBy) || "order".equalsIgnoreCase(sortBy)) {
            orderCol = "sort_order";
        } else if ("status".equalsIgnoreCase(sortBy)) {
            orderCol = "status";
        } else if ("created_at".equalsIgnoreCase(sortBy) || "date".equalsIgnoreCase(sortBy)) {
            orderCol = "created_at";
        }

        String direction = "ASC";
        if ("desc".equalsIgnoreCase(sortOrder)) {
            direction = "DESC";
        }

        sql.append("ORDER BY ").append(orderCol).append(" ").append(direction).append(" LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSetting(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in SettingDAO.findSettings: " + e.getMessage(), e);
        }
        return list;
    }

    public int countSettings(String search, String type, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM setting WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(name) LIKE ? OR LOWER(code) LIKE ? OR LOWER(COALESCE(description, '')) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        if (type != null && !type.trim().isEmpty() && !type.equalsIgnoreCase("all")) {
            sql.append("AND type = ? ");
            params.add(type.trim());
        }

        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            if ("active".equalsIgnoreCase(status) || "true".equalsIgnoreCase(status)) {
                sql.append("AND status = TRUE ");
            } else if ("inactive".equalsIgnoreCase(status) || "false".equalsIgnoreCase(status)) {
                sql.append("AND status = FALSE ");
            }
        }

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in SettingDAO.countSettings: " + e.getMessage(), e);
        }
        return 0;
    }

    public List<String> findAllTypes() {
        List<String> types = new ArrayList<>();
        String sql = "SELECT DISTINCT type FROM setting ORDER BY type ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                types.add(rs.getString("type"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in SettingDAO.findAllTypes: " + e.getMessage(), e);
        }
        return types;
    }

    public boolean updateStatus(UUID id, boolean status) {
        String sql = "UPDATE setting SET status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            ps.setObject(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in SettingDAO.updateStatus: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean insert(Setting setting) {
        String sql = "INSERT INTO setting (id, type, code, name, description, status, sort_order, created_at, updated_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, setting.getId());
            ps.setString(2, setting.getType());
            ps.setString(3, setting.getCode());
            ps.setString(4, setting.getName());
            ps.setString(5, setting.getDescription());
            ps.setBoolean(6, setting.isStatus());
            ps.setInt(7, setting.getSortOrder());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in SettingDAO.insert: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean update(Setting setting) {
        String sql = "UPDATE setting SET type = ?, code = ?, name = ?, description = ?, status = ?, sort_order = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, setting.getType());
            ps.setString(2, setting.getCode());
            ps.setString(3, setting.getName());
            ps.setString(4, setting.getDescription());
            ps.setBoolean(5, setting.isStatus());
            ps.setInt(6, setting.getSortOrder());
            ps.setObject(7, setting.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in SettingDAO.update: " + e.getMessage(), e);
            return false;
        }
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
