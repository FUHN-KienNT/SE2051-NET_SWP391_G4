package com.fpt.lms.dao;

import com.fpt.lms.entity.Notification;
import com.fpt.lms.util.DbConnection;

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

    public boolean markAsRead(UUID id) {
        String sql = "UPDATE notification SET status = 'read' WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in NotificationDAO.markAsRead: " + e.getMessage(), e);
            return false;
        }
    }
}
