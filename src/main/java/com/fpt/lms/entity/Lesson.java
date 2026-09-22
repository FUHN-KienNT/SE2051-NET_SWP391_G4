package com.fpt.lms.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class Lesson implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID moduleId;
    private String title;
    private String content;
    private int orderIndex;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private String materialUrl;
    private String moduleTitle;
    private UUID courseId;
    private String status;

    public Lesson() {
        this.orderIndex = 0;
    }

    public Lesson(UUID id, UUID moduleId, String title, String content, int orderIndex) {
        this.id = id;
        this.moduleId = moduleId;
        this.title = title;
        this.content = content;
        this.orderIndex = orderIndex;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getModuleId() { return moduleId; }
    public void setModuleId(UUID moduleId) { this.moduleId = moduleId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getMaterialUrl() { return materialUrl; }
    public void setMaterialUrl(String materialUrl) { this.materialUrl = materialUrl; }

    public String getModuleTitle() { return moduleTitle; }
    public void setModuleTitle(String moduleTitle) { this.moduleTitle = moduleTitle; }

    public UUID getCourseId() { return courseId; }
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return "Lesson{id=" + id + ", title='" + title + "', orderIndex=" + orderIndex + "}";
    }
}
