package com.learnhub.dto;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class LearningProcessDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID registrationId;
    private UUID lessonId;
    private String status;
    private Timestamp completedAt;

    public LearningProcessDTO() {
    }

    public LearningProcessDTO(UUID id, UUID registrationId, UUID lessonId, String status, Timestamp completedAt) {
        this.id = id;
        this.registrationId = registrationId;
        this.lessonId = lessonId;
        this.status = status;
        this.completedAt = completedAt;
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
}
