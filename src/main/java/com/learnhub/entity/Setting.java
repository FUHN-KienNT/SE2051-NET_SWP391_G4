package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

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

    public Setting() {
    }

    public Setting(UUID id, String type, String code, String name, String description, boolean status, int sortOrder) {
        this.id = id;
        this.type = type;
        this.code = code;
        this.name = name;
        this.description = description;
        this.status = status;
        this.sortOrder = sortOrder;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getIdString() { return id != null ? id.toString() : ""; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getValue() { return name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "Setting{id=" + id + ", type='" + type + "', code='" + code + "', name='" + name + "'}";
    }
}
