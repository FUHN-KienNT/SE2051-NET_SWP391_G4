package com.fpt.lms.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class QuestionOption implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID questionId;
    private String optionText;
    private boolean isCorrect;
    private Timestamp updatedAt;

    public QuestionOption() {
        this.isCorrect = false;
    }

    public QuestionOption(UUID id, UUID questionId, String optionText, boolean isCorrect) {
        this.id = id;
        this.questionId = questionId;
        this.optionText = optionText;
        this.isCorrect = isCorrect;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getQuestionId() { return questionId; }
    public void setQuestionId(UUID questionId) { this.questionId = questionId; }

    public String getOptionText() { return optionText; }
    public void setOptionText(String optionText) { this.optionText = optionText; }

    public boolean isCorrect() { return isCorrect; }
    public void setCorrect(boolean correct) { isCorrect = correct; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "QuestionOption{id=" + id + ", optionText='" + optionText + "', isCorrect=" + isCorrect + "}";
    }
}
