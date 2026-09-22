package com.fpt.lms.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID userId;
    private UUID typeId;
    private String content;
    private String status;
    private Timestamp sentAt;
    private Timestamp createdAt;

    // Helper / joined field
    private String typeName;

    public Notification() {
        this.status = "unread";
    }

    public Notification(UUID id, UUID userId, UUID typeId, String content, String status) {
        this();
        this.id = id;
        this.userId = userId;
        this.typeId = typeId;
        this.content = content;
        this.status = status;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }

    public UUID getTypeId() { return typeId; }
    public void setTypeId(UUID typeId) { this.typeId = typeId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    @Override
    public String toString() {
        return "Notification{id=" + id + ", userId=" + userId + ", status='" + status + "'}";
    }
}
