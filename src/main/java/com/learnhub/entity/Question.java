package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Question implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID moduleId;
    private String content;
    private String type;
    private String status = "public"; // public | draft | hidden
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private String moduleTitle;
    private UUID courseId;
    private String courseTitle;
    private int orderIndex;
    private List<QuestionOption> options = new ArrayList<>();

    public Question() {
        this.type = "single_choice";
        this.status = "public";
    }

    public Question(UUID id, String content, String type) {
        this();
        this.id = id;
        this.content = content;
        this.type = type;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getModuleId() { return moduleId; }
    public void setModuleId(UUID moduleId) { this.moduleId = moduleId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getStatus() { return status != null ? status : "public"; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getModuleTitle() { return moduleTitle; }
    public void setModuleTitle(String moduleTitle) { this.moduleTitle = moduleTitle; }

    public UUID getCourseId() { return courseId; }
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    public List<QuestionOption> getOptions() { return options; }
    public void setOptions(List<QuestionOption> options) { this.options = options; }

    public void addOption(QuestionOption option) {
        if (this.options == null) {
            this.options = new ArrayList<>();
        }
        this.options.add(option);
    }

    public boolean isFillInBlank() {
        return "fill_in_blank".equalsIgnoreCase(type) || "text".equalsIgnoreCase(type);
    }

    public boolean isSingleChoice() {
        return "single_choice".equalsIgnoreCase(type);
    }

    public boolean isMultipleChoice() {
        return "multiple_choice".equalsIgnoreCase(type);
    }

    public boolean isHidden() {
        return "hidden".equalsIgnoreCase(status);
    }

    public boolean isPublic() {
        return "public".equalsIgnoreCase(status);
    }

    @Override
    public String toString() {
        return "Question{id=" + id + ", content='" + content + "', type='" + type + "', status='" + status + "'}";
    }
}
