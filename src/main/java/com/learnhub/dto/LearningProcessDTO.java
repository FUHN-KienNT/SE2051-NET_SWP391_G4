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

    /**
     * Creates an instance with the supplied values.
     */
    public LearningProcessDTO() {
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param registrationId the registration id identifier
     * @param lessonId the lesson id identifier
     * @param status the status
     * @param completedAt the completed at
     */
    public LearningProcessDTO(UUID id, UUID registrationId, UUID lessonId, String status, Timestamp completedAt) {
        this.id = id;
        this.registrationId = registrationId;
        this.lessonId = lessonId;
        this.status = status;
        this.completedAt = completedAt;
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
}
