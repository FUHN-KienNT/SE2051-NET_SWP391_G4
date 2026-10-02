package com.learnhub.entity;

import java.io.Serializable;
import java.util.UUID;

public class QuizQuestion implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID quizId;
    private UUID questionId;
    private int orderIndex;

    // Helper / joined field
    private Question question;

    public QuizQuestion() {
        this.orderIndex = 0;
    }

    public QuizQuestion(UUID id, UUID quizId, UUID questionId, int orderIndex) {
        this.id = id;
        this.quizId = quizId;
        this.questionId = questionId;
        this.orderIndex = orderIndex;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getQuizId() { return quizId; }
    public void setQuizId(UUID quizId) { this.quizId = quizId; }

    public UUID getQuestionId() { return questionId; }
    public void setQuestionId(UUID questionId) { this.questionId = questionId; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    public Question getQuestion() { return question; }
    public void setQuestion(Question question) { this.question = question; }

    @Override
    public String toString() {
        return "QuizQuestion{id=" + id + ", quizId=" + quizId + ", questionId=" + questionId + "}";
    }
}
