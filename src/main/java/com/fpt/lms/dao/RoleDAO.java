package com.fpt.lms.dao;

import com.fpt.lms.entity.Setting;
import com.fpt.lms.util.DbConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for User Roles.
 * Implements methods specified in User Management Class Diagram (SDS 6.1):
 * - findAllRoles()
 * - findById()
 */
public class RoleDAO {
    private static final Logger LOGGER = Logger.getLogger(RoleDAO.class.getName());

    public List<Setting> findAllRoles() {
        List<Setting> roles = new ArrayList<>();
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                     "FROM setting WHERE type = 'role' AND status = TRUE ORDER BY sort_order ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
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
                roles.add(s);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findAllRoles: " + e.getMessage(), e);
        }
        return roles;
    }

    public Setting findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at " +
                     "FROM setting WHERE id = ? AND type = 'role'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in RoleDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }
}
