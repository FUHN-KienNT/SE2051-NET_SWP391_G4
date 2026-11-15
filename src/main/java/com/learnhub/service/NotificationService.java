package com.learnhub.service;

import com.learnhub.dao.NotificationDAO;
import com.learnhub.entity.Notification;
import com.learnhub.util.EmailUtil;

import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

public class NotificationService {
    private final NotificationDAO notificationDAO;

    /**
     * Creates an instance with the supplied values.
     */
    public NotificationService() {
        this.notificationDAO = new NotificationDAO();
    }

    /**
     * Returns user notifications.
     *
     * @param userId the user id identifier
     * @return the user notifications
     */
    public List<Notification> getUserNotifications(UUID userId) {
        return notificationDAO.findByUserId(userId);
    }

    /**
     * Returns recent notifications.
     *
     * @param userId the user id identifier
     * @param limit the limit
     * @return the recent notifications
     * @throws SQLException if the operation cannot complete
     */
    public List<Notification> getRecentNotifications(UUID userId, int limit) throws SQLException {
        return notificationDAO.findRecentByUserId(userId, limit);
    }

    /**
     * Counts unread notifications.
     *
     * @param userId the user id identifier
     * @return the number of unread notifications
     * @throws SQLException if the operation cannot complete
     */
    public int countUnreadNotifications(UUID userId) throws SQLException {
        return notificationDAO.countUnreadByUserId(userId);
    }

    /**
     * Mark as read.
     *
     * @param userId the user id identifier
     * @param notificationId the notification id identifier
     * @return true when the condition holds; false otherwise
     * @throws SQLException if the operation cannot complete
     */
    public boolean markAsRead(UUID userId, UUID notificationId) throws SQLException {
        return notificationDAO.markAsRead(userId, notificationId);
    }

    /**
     * Mark all as read.
     *
     * @param userId the user id identifier
     * @return the result of mark all as read
     * @throws SQLException if the operation cannot complete
     */
    public int markAllAsRead(UUID userId) throws SQLException {
        return notificationDAO.markAllAsRead(userId);
    }
}
