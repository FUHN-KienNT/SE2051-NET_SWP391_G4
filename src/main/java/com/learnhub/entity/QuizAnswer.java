package com.learnhub.entity;

import java.io.Serializable;
import java.util.UUID;

public class QuizAnswer implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID quizSubmissionId;
    private UUID quizQuestionId;
    private UUID questionOptionId;

    // Helper / joined fields
    private String questionContent;
    private String selectedOptionText;
    private boolean isCorrect;

    public QuizAnswer() {
    }

    public QuizAnswer(UUID id, UUID quizSubmissionId, UUID quizQuestionId, UUID questionOptionId) {
        this.id = id;
        this.quizSubmissionId = quizSubmissionId;
        this.quizQuestionId = quizQuestionId;
        this.questionOptionId = questionOptionId;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getQuizSubmissionId() { return quizSubmissionId; }
    public void setQuizSubmissionId(UUID quizSubmissionId) { this.quizSubmissionId = quizSubmissionId; }

    public UUID getQuizQuestionId() { return quizQuestionId; }
    public void setQuizQuestionId(UUID quizQuestionId) { this.quizQuestionId = quizQuestionId; }

    public UUID getQuestionOptionId() { return questionOptionId; }
    public void setQuestionOptionId(UUID questionOptionId) { this.questionOptionId = questionOptionId; }

    public String getQuestionContent() { return questionContent; }
    public void setQuestionContent(String questionContent) { this.questionContent = questionContent; }

    public String getSelectedOptionText() { return selectedOptionText; }
    public void setSelectedOptionText(String selectedOptionText) { this.selectedOptionText = selectedOptionText; }

    public boolean isCorrect() { return isCorrect; }
    public void setCorrect(boolean correct) { isCorrect = correct; }

    @Override
    public String toString() {
        return "QuizAnswer{id=" + id + ", quizSubmissionId=" + quizSubmissionId + "}";
    }
}
