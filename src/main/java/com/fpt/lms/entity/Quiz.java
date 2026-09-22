package com.fpt.lms.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Quiz implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID moduleId;
    private String title;
    private Integer timeLimit;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private String moduleTitle;
    private int questionCount;
    private List<Question> questions = new ArrayList<>();

    public Quiz() {
    }

    public Quiz(UUID id, UUID moduleId, String title, Integer timeLimit) {
        this.id = id;
        this.moduleId = moduleId;
        this.title = title;
        this.timeLimit = timeLimit;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getModuleId() { return moduleId; }
    public void setModuleId(UUID moduleId) { this.moduleId = moduleId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Integer getTimeLimit() { return timeLimit; }
    public void setTimeLimit(Integer timeLimit) { this.timeLimit = timeLimit; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getModuleTitle() { return moduleTitle; }
    public void setModuleTitle(String moduleTitle) { this.moduleTitle = moduleTitle; }

    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }

    public List<Question> getQuestions() { return questions; }
    public void setQuestions(List<Question> questions) { this.questions = questions; }

    @Override
    public String toString() {
        return "Quiz{id=" + id + ", title='" + title + "', timeLimit=" + timeLimit + "}";
    }
}
