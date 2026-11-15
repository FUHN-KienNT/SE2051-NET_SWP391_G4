package com.learnhub.entity;

import java.sql.Timestamp;
import java.util.UUID;

/**
 * Entity representing a system audit log entry.
 * Maps to the audit_log table.
 */
public class AuditLog {

    private UUID id;
    private String actor;
    private String actionType;
    private String description;
    private String status;
    private Timestamp createdAt;

    /**
     * Creates an instance with the supplied values.
     */
    public AuditLog() {}

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param actor the actor
     * @param actionType the action type
     * @param description the description
     * @param status the status
     * @param createdAt the created at
     */
    public AuditLog(UUID id, String actor, String actionType, String description, String status, Timestamp createdAt) {
        this.id = id;
        this.actor = actor;
        this.actionType = actionType;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
    }

    // ── Getters & Setters ──────────────────────────────────────────────────────

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
     * Returns actor.
     *
     * @return the actor
     */
    public String getActor() { return actor; }
    /**
     * Sets actor.
     *
     * @param actor the actor
     */
    public void setActor(String actor) { this.actor = actor; }

    /**
     * Returns action type.
     *
     * @return the action type
     */
    public String getActionType() { return actionType; }
    /**
     * Sets action type.
     *
     * @param actionType the action type
     */
    public void setActionType(String actionType) { this.actionType = actionType; }

    /**
     * Returns description.
     *
     * @return the description
     */
    public String getDescription() { return description; }
    /**
     * Sets description.
     *
     * @param description the description
     */
    public void setDescription(String description) { this.description = description; }

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
}
