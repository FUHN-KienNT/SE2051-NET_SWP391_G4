package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Question implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private String content;
    private String type;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private int orderIndex;
    private List<QuestionOption> options = new ArrayList<>();

    public Question() {
        this.type = "single_choice";
    }

    public Question(UUID id, String content, String type) {
        this();
        this.id = id;
        this.content = content;
        this.type = type;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

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

    @Override
    public String toString() {
        return "Question{id=" + id + ", content='" + content + "', type='" + type + "'}";
    }
}
