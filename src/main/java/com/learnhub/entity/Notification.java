package com.learnhub.entity;

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

    /**
     * Creates an instance with the supplied values.
     */
    public Notification() {
        this.status = "unread";
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param userId the user id identifier
     * @param typeId the type id identifier
     * @param content the content
     * @param status the status
     */
    public Notification(UUID id, UUID userId, UUID typeId, String content, String status) {
        this();
        this.id = id;
        this.userId = userId;
        this.typeId = typeId;
        this.content = content;
        this.status = status;
    }

    /**
     * Returns id.
     *
     * @return the id
     */
    public UUID getId() { return id; }
    /**
     * Sets id.
     *
     * @param id the id identifier
     */
    public void setId(UUID id) { this.id = id; }

    /**
     * Returns user id.
     *
     * @return the user id
     */
    public UUID getUserId() { return userId; }
    /**
     * Sets user id.
     *
     * @param userId the user id identifier
     */
    public void setUserId(UUID userId) { this.userId = userId; }

    /**
     * Returns type id.
     *
     * @return the type id
     */
    public UUID getTypeId() { return typeId; }
    /**
     * Sets type id.
     *
     * @param typeId the type id identifier
     */
    public void setTypeId(UUID typeId) { this.typeId = typeId; }

    /**
     * Returns content.
     *
     * @return the content
     */
    public String getContent() { return content; }
    /**
     * Sets content.
     *
     * @param content the content
     */
    public void setContent(String content) { this.content = content; }

    /**
     * Returns status.
     *
     * @return the status
     */
    public String getStatus() { return status; }
    /**
     * Sets status.
     *
     * @param status the status
     */
    public void setStatus(String status) { this.status = status; }

    /**
     * Returns sent at.
     *
     * @return the sent at
     */
    public Timestamp getSentAt() { return sentAt; }
    /**
     * Sets sent at.
     *
     * @param sentAt the sent at
     */
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }

    /**
     * Returns created at.
     *
     * @return the created at
     */
    public Timestamp getCreatedAt() { return createdAt; }
    /**
     * Sets created at.
     *
     * @param createdAt the created at
     */
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    /**
     * Returns type name.
     *
     * @return the type name
     */
    public String getTypeName() { return typeName; }
    /**
     * Sets type name.
     *
     * @param typeName the type name
     */
    public void setTypeName(String typeName) { this.typeName = typeName; }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "Notification{id=" + id + ", userId=" + userId + ", status='" + status + "'}";
    }
}
