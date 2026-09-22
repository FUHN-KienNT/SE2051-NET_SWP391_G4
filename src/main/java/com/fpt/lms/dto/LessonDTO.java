package com.fpt.lms.dto;

import java.io.Serializable;
import java.util.UUID;

public class LessonDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID moduleId;
    private String title;
    private String content;
    private int orderIndex;
    private String materialUrl;
    private String status;

    public LessonDTO() {
    }

    public LessonDTO(UUID id, UUID moduleId, String title, String content, int orderIndex) {
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

    public String getMaterialUrl() { return materialUrl; }
    public void setMaterialUrl(String materialUrl) { this.materialUrl = materialUrl; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
