package com.learnhub.dao;

import com.learnhub.entity.Setting;
import com.learnhub.util.DbConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for master configurations and system settings.
 * Mapped to the "setting" database table.
 *
 * <p>Handles CRUD operations, pagination, filtering, searching, uniqueness checks,
 * status updates, and display order reordering.</p>
 *
 * @author NguyenLD - System Administration Module
 */
public class SettingDAO {

    private static final Logger LOGGER = Logger.getLogger(SettingDAO.class.getName());

    /**
     * Retrieves all active course categories ordered by sort order and name.
     *
     * @return List of active category Settings
     */
    public List<Setting> findActiveCategories() {
        List<Setting> categories = new ArrayList<>();
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at "
                + "FROM setting WHERE type = 'category' AND status = TRUE ORDER BY sort_order ASC, name ASC";

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

    /**
     * Retrieves all active settings belonging to a specific configuration type.
     *
     * @param type Configuration type (e.g. role, category, payment_method)
     * @return List of matching active Settings
     */
    public List<Setting> findByType(String type) {
        List<Setting> list = new ArrayList<>();
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at "
                + "FROM setting WHERE type = ? AND status = TRUE ORDER BY sort_order ASC";

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

    /**
     * Finds a setting by its unique UUID identifier.
     *
     * @param id Setting UUID
     * @return Setting entity, or null if not found
     */
    public Setting findById(UUID id) {
        if (id == null) {
            return null;
        }

        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at "
                + "FROM setting WHERE id = ?";

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

    /**
     * Finds a setting by its unique system code.
     *
     * @param code Unique code (e.g. ROLE_ADMIN, web_dev)
     * @return Setting entity, or null if not found
     */
    public Setting findByCode(String code) {
        if (code == null) {
            return null;
        }

        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at "
                + "FROM setting WHERE code = ?";

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
     * Retrieves all active role settings.
     *
     * @return List of role Settings
     */
    public List<Setting> findAllRoles() {
        return findByType("role");
    }

    /**
     * Retrieves all settings across all types without pagination.
     *
     * @return Complete list of settings
     */
    public List<Setting> findAll() {
        List<Setting> list = new ArrayList<>();
        String sql = "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at "
                + "FROM setting ORDER BY type ASC, sort_order ASC";

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

    /**
     * Searches, filters, sorts, and paginates system settings.
     *
     * @param search    Keyword to match in name, code, or description
     * @param type      Setting type filter (or null/all)
     * @param status    Status filter (active, inactive, or null/all)
     * @param sortBy    Column name to sort by
     * @param sortOrder Sorting direction (ASC, DESC)
     * @param offset    Pagination record offset
     * @param limit     Maximum records per page
     * @return Paginated list of matching settings
     */
    public List<Setting> findSettings(String search, String type, String status,
                                      String sortBy, String sortOrder, int offset, int limit) {
        List<Setting> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, type, code, name, description, status, sort_order, created_at, updated_at "
                + "FROM setting WHERE 1=1 ");

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

    /**
     * Counts the total number of settings matching the given filter criteria.
     *
     * @param search Keyword filter
     * @param type   Setting type filter
     * @param status Setting status filter
     * @return Total count of matching records
     */
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

    /**
     * Retrieves all distinct setting types currently in the system.
     *
     * @return Sorted list of distinct type strings
     */
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

    /**
     * Checks if a setting name already exists (case-insensitive), optionally excluding a specific ID.
     *
     * @param name      Setting name to check
     * @param excludeId ID to exclude (e.g. current setting ID during update)
     * @return true if name already exists, false otherwise
     */
    public boolean existsByName(String name, UUID excludeId) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }

        String sql = excludeId != null
                ? "SELECT COUNT(*) FROM setting WHERE LOWER(name) = LOWER(?) AND id <> ?"
                : "SELECT COUNT(*) FROM setting WHERE LOWER(name) = LOWER(?)";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            if (excludeId != null) {
                ps.setObject(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in SettingDAO.existsByName: " + e.getMessage(), e);
        }
        return false;
    }

    /**
     * Updates the active/inactive status of a setting.
     *
     * @param id     Setting UUID
     * @param status New active state (true = active, false = inactive)
     * @return true if status was updated, false otherwise
     */
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

    /**
     * Performs a batch update of sort orders for multiple settings inside a single transaction.
     *
     * @param orderMap Map of Setting UUIDs to new integer sort order values
     * @return true if all orders were saved successfully, false if rolled back
     */
    public boolean updateSortOrders(Map<UUID, Integer> orderMap) {
        if (orderMap == null || orderMap.isEmpty()) {
            return true;
        }

        String sql = "UPDATE setting SET sort_order = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (Map.Entry<UUID, Integer> entry : orderMap.entrySet()) {
                    ps.setInt(1, entry.getValue());
                    ps.setObject(2, entry.getKey());
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Rollback transaction error in updateSortOrders: " + ex.getMessage(), ex);
                return false;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in SettingDAO.updateSortOrders: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Inserts a new setting record into the database.
     *
     * @param setting Setting entity containing new values
     * @return true if successfully inserted, false otherwise
     */
    public boolean insert(Setting setting) {
        String sql = "INSERT INTO setting (id, type, code, name, description, status, sort_order, created_at, updated_at) "
                + "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, ?, ?, NOW(), NOW())";

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

    /**
     * Updates all editable attributes of an existing setting.
     *
     * @param setting Setting entity with updated values and valid ID
     * @return true if updated, false otherwise
     */
    public boolean update(Setting setting) {
        String sql = "UPDATE setting SET type = ?, code = ?, name = ?, description = ?, "
                + "status = ?, sort_order = ?, updated_at = NOW() WHERE id = ?";

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

    // -------------------------------------------------------------------------
    // Private Helpers
    // -------------------------------------------------------------------------

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
