package com.learnhub.service;

import com.learnhub.dao.NotificationDAO;
import com.learnhub.entity.Notification;
import com.learnhub.util.EmailUtil;

import java.util.List;
import java.util.UUID;

public class NotificationService {
    private final NotificationDAO notificationDAO;

    public NotificationService() {
        this.notificationDAO = new NotificationDAO();
    }

    public void notifyEnrollmentSuccess(UUID userId, String courseTitle) {
        Notification n = new Notification();
        n.setId(UUID.randomUUID());
        n.setUserId(userId);
        n.setContent("Chuc mung! Ban da dang ky va thanh toan thanh cong khoa hoc: " + courseTitle);
        n.setStatus("unread");
        notificationDAO.insert(n);
        EmailUtil.sendEnrollmentSuccess("student@learnhub.edu.vn", "Hoc Vien", courseTitle);
    }

    public List<Notification> getUserNotifications(UUID userId) {
        return notificationDAO.findByUserId(userId);
    }
}
