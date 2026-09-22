package com.learnhub.dao;

import com.learnhub.entity.User;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for User entity.
 * Implements methods specified in SDS User Management Class Diagram & Sequence Diagrams:
 * - findAll()
 * - findById()
 * - update()
 * - updateStatus()
 * - updatePassword()
 * - findUsers(search, roleId, status, offset, limit)
 * - countUsers(search, roleId, status)
 */
public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.email, u.password, u.role_id, u.status, u.created_at, u.updated_at, " +
                     "s.name as role_name, s.code as role_code " +
                     "FROM \"user\" u " +
                     "LEFT JOIN setting s ON u.role_id = s.id " +
                     "ORDER BY u.created_at DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.findAll: " + e.getMessage(), e);
        }
        return list;
    }

    public User findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT u.id, u.username, u.email, u.password, u.role_id, u.status, u.created_at, u.updated_at, " +
                     "s.name as role_name, s.code as role_code " +
                     "FROM \"user\" u " +
                     "LEFT JOIN setting s ON u.role_id = s.id " +
                     "WHERE u.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }

    public User findByEmail(String email) {
        if (email == null) return null;
        String sql = "SELECT u.id, u.username, u.email, u.password, u.role_id, u.status, u.created_at, u.updated_at, " +
                     "s.name as role_name, s.code as role_code " +
                     "FROM \"user\" u " +
                     "LEFT JOIN setting s ON u.role_id = s.id " +
                     "WHERE LOWER(u.email) = LOWER(?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.findByEmail: " + e.getMessage(), e);
        }
        return null;
    }

    public List<User> findUsers(String search, UUID roleId, String status, int offset, int limit) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT u.id, u.username, u.email, u.password, u.role_id, u.status, u.created_at, u.updated_at, " +
                "s.name as role_name, s.code as role_code " +
                "FROM \"user\" u " +
                "LEFT JOIN setting s ON u.role_id = s.id WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.username) LIKE ? OR LOWER(u.email) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
        }
        if (roleId != null) {
            sql.append("AND u.role_id = ? ");
            params.add(roleId);
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append("AND u.status = ? ");
            params.add(status.trim());
        }

        sql.append("ORDER BY u.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.findUsers: " + e.getMessage(), e);
        }
        return list;
    }

    public int countUsers(String search, UUID roleId, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM \"user\" u WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.username) LIKE ? OR LOWER(u.email) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
        }
        if (roleId != null) {
            sql.append("AND u.role_id = ? ");
            params.add(roleId);
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append("AND u.status = ? ");
            params.add(status.trim());
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
            LOGGER.log(Level.SEVERE, "Error in UserDAO.countUsers: " + e.getMessage(), e);
        }
        return 0;
    }

    public boolean insert(User user) {
        String sql = "INSERT INTO \"user\" (id, username, email, password, role_id, status, created_at, updated_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, user.getId());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setObject(5, user.getRoleId());
            ps.setString(6, user.getStatus() != null ? user.getStatus() : "active");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.insert: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean update(User user) {
        String sql = "UPDATE \"user\" SET username = ?, email = ?, role_id = ?, status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setObject(3, user.getRoleId());
            ps.setString(4, user.getStatus());
            ps.setObject(5, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.update: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean updateStatus(UUID userId, String status) {
        String sql = "UPDATE \"user\" SET status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.updateStatus: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean updatePassword(UUID userId, String newHashedPassword) {
        String sql = "UPDATE \"user\" SET password = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHashedPassword);
            ps.setObject(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in UserDAO.updatePassword: " + e.getMessage(), e);
            return false;
        }
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId((UUID) rs.getObject("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setRoleId((UUID) rs.getObject("role_id"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        try {
            u.setRoleName(rs.getString("role_name"));
            u.setRoleCode(rs.getString("role_code"));
        } catch (SQLException ignored) {
        }
        return u;
    }
}
