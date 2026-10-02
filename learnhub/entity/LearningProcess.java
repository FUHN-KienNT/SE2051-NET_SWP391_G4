package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class LearningProcess implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID registrationId;
    private UUID lessonId;
    private String status;
    private Timestamp completedAt;
    private Timestamp createdAt;

    // Helper / joined fields
    private String lessonTitle;
    private int orderIndex;

    public LearningProcess() {
        this.status = "not_started";
    }

    public LearningProcess(UUID id, UUID registrationId, UUID lessonId, String status) {
        this.id = id;
        this.registrationId = registrationId;
        this.lessonId = lessonId;
        this.status = status;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getRegistrationId() { return registrationId; }
    public void setRegistrationId(UUID registrationId) { this.registrationId = registrationId; }

    public UUID getLessonId() { return lessonId; }
    public void setLessonId(UUID lessonId) { this.lessonId = lessonId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getLessonTitle() { return lessonTitle; }
    public void setLessonTitle(String lessonTitle) { this.lessonTitle = lessonTitle; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    @Override
    public String toString() {
        return "LearningProcess{id=" + id + ", registrationId=" + registrationId + ", lessonId=" + lessonId + ", status='" + status + "'}";
    }
}
