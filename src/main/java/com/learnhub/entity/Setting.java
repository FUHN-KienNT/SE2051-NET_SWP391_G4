package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

/**
 * Entity representing a system configuration or master data item in the LearnHub platform.
 * Mapped to the database table: "setting".
 *
 * <p>Supports various configuration types such as role, category, payment_method, and notification_type.</p>
 *
 * @author NguyenLD - System Administration Module
 */
public class Setting implements Serializable {

    private static final long serialVersionUID = 1L;

    private UUID id;
    private String type;
    private String code;
    private String name;
    private String description;
    private boolean status;
    private int sortOrder;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    /**
     * Default no-argument constructor.
     */
    public Setting() {
    }

    /**
     * Parameterized constructor for initializing key setting attributes.
     *
     * @param id          Unique identifier of the setting
     * @param type        Type/category group of the setting (e.g. role, category)
     * @param code        Unique alphanumeric code (e.g. ROLE_ADMIN, web_dev)
     * @param name        Human-readable display name
     * @param description Detailed description or administrative notes
     * @param status      Active status (true = active, false = inactive)
     * @param sortOrder   Display priority order
     */
    public Setting(UUID id, String type, String code, String name,
                   String description, boolean status, int sortOrder) {
        this.id = id;
        this.type = type;
        this.code = code;
        this.name = name;
        this.description = description;
        this.status = status;
        this.sortOrder = sortOrder;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    /**
     * Returns string representation of ID, or empty string if null.
     *
     * @return String representation of UUID
     */
    public String getIdString() {
        return id != null ? id.toString() : "";
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    /**
     * Alias for {@link #getName()} for JSP EL compatibility.
     *
     * @return Display value/name
     */
    public String getValue() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "Setting{"
                + "id=" + id
                + ", type='" + type + '\''
                + ", code='" + code + '\''
                + ", name='" + name + '\''
                + ", status=" + status
                + ", sortOrder=" + sortOrder
                + '}';
    }
}
