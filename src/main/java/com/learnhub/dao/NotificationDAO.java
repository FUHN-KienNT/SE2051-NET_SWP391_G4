package com.learnhub.dao;

import com.learnhub.entity.Notification;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificationDAO {
    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    public boolean insert(Notification notification) {
        String sql = "INSERT INTO notification (id, user_id, type_id, content, status, sent_at, created_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, notification.getId());
            ps.setObject(2, notification.getUserId());
            ps.setObject(3, notification.getTypeId());
            ps.setString(4, notification.getContent());
            ps.setString(5, notification.getStatus() != null ? notification.getStatus() : "unread");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in NotificationDAO.insert: " + e.getMessage(), e);
            return false;
        }
    }

    public List<Notification> findByUserId(UUID userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT n.id, n.user_id, n.type_id, n.content, n.status, n.sent_at, n.created_at, " +
                     "s.name as type_name " +
                     "FROM notification n " +
                     "LEFT JOIN setting s ON n.type_id = s.id " +
                     "WHERE n.user_id = ? ORDER BY n.created_at DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId((UUID) rs.getObject("id"));
                    n.setUserId((UUID) rs.getObject("user_id"));
                    n.setTypeId((UUID) rs.getObject("type_id"));
                    n.setContent(rs.getString("content"));
                    n.setStatus(rs.getString("status"));
                    n.setSentAt(rs.getTimestamp("sent_at"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    try {
                        n.setTypeName(rs.getString("type_name"));
                    } catch (SQLException ignored) {
                    }
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in NotificationDAO.findByUserId: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Notification> findRecentByUserId(UUID userId, int limit) throws SQLException {
        String sql = "SELECT n.id, n.user_id, n.type_id, n.content, n.status, n.sent_at, n.created_at, " +
                     "s.name AS type_name FROM notification n " +
                     "LEFT JOIN setting s ON n.type_id = s.id " +
                     "WHERE n.user_id = ? ORDER BY n.created_at DESC, n.id DESC LIMIT ?";
        List<Notification> notifications = new ArrayList<>();
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification notification = new Notification();
                    notification.setId((UUID) rs.getObject("id"));
                    notification.setUserId((UUID) rs.getObject("user_id"));
                    notification.setTypeId((UUID) rs.getObject("type_id"));
                    notification.setContent(rs.getString("content"));
                    notification.setStatus(rs.getString("status"));
                    notification.setSentAt(rs.getTimestamp("sent_at"));
                    notification.setCreatedAt(rs.getTimestamp("created_at"));
                    notification.setTypeName(rs.getString("type_name"));
                    notifications.add(notification);
                }
            }
        }
        return notifications;
    }

    public int countUnreadByUserId(UUID userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notification WHERE user_id = ? AND status = 'unread'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    public boolean markAsRead(UUID userId, UUID id) throws SQLException {
        String sql = "UPDATE notification SET status = 'read' WHERE id = ? AND user_id = ? " +
                     "AND status IN ('unread', 'read')";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            ps.setObject(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public int markAllAsRead(UUID userId) throws SQLException {
        String sql = "UPDATE notification SET status = 'read' WHERE user_id = ? AND status = 'unread'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            return ps.executeUpdate();
        }
    }
}
