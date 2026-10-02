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

    public AuditLog() {}

    public AuditLog(UUID id, String actor, String actionType, String description, String status, Timestamp createdAt) {
        this.id = id;
        this.actor = actor;
        this.actionType = actionType;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
    }

    // ── Getters & Setters ──────────────────────────────────────────────────────

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getActor() { return actor; }
    public void setActor(String actor) { this.actor = actor; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
