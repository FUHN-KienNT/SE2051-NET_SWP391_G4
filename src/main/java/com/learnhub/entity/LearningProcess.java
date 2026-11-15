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

    /**
     * Creates an instance with the supplied values.
     */
    public LearningProcess() {
        this.status = "not_started";
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param registrationId the registration id identifier
     * @param lessonId the lesson id identifier
     * @param status the status
     */
    public LearningProcess(UUID id, UUID registrationId, UUID lessonId, String status) {
        this.id = id;
        this.registrationId = registrationId;
        this.lessonId = lessonId;
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
     * Returns registration id.
     *
     * @return the registration id
     */
    public UUID getRegistrationId() { return registrationId; }
    /**
     * Sets registration id.
     *
     * @param registrationId the registration id identifier
     */
    public void setRegistrationId(UUID registrationId) { this.registrationId = registrationId; }

    /**
     * Returns lesson id.
     *
     * @return the lesson id
     */
    public UUID getLessonId() { return lessonId; }
    /**
     * Sets lesson id.
     *
     * @param lessonId the lesson id identifier
     */
    public void setLessonId(UUID lessonId) { this.lessonId = lessonId; }

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
     * Returns completed at.
     *
     * @return the completed at
     */
    public Timestamp getCompletedAt() { return completedAt; }
    /**
     * Sets completed at.
     *
     * @param completedAt the completed at
     */
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }

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
     * Returns lesson title.
     *
     * @return the lesson title
     */
    public String getLessonTitle() { return lessonTitle; }
    /**
     * Sets lesson title.
     *
     * @param lessonTitle the lesson title
     */
    public void setLessonTitle(String lessonTitle) { this.lessonTitle = lessonTitle; }

    /**
     * Returns order index.
     *
     * @return the order index
     */
    public int getOrderIndex() { return orderIndex; }
    /**
     * Sets order index.
     *
     * @param orderIndex the order index
     */
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "LearningProcess{id=" + id + ", registrationId=" + registrationId + ", lessonId=" + lessonId + ", status='" + status + "'}";
    }
}
