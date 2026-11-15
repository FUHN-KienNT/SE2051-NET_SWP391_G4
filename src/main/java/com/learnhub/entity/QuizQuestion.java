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

    /**
     * Creates an instance with the supplied values.
     */
    public QuizQuestion() {
        this.orderIndex = 0;
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param quizId the quiz id identifier
     * @param questionId the question id identifier
     * @param orderIndex the order index
     */
    public QuizQuestion(UUID id, UUID quizId, UUID questionId, int orderIndex) {
        this.id = id;
        this.quizId = quizId;
        this.questionId = questionId;
        this.orderIndex = orderIndex;
    }

    /**
     * Returns id.
     *
     * @return the id
     */
    public UUID getId() { return id; }
    /**
     * Sets id.
     *
     * @param id the id identifier
     */
    public void setId(UUID id) { this.id = id; }

    /**
     * Returns quiz id.
     *
     * @return the quiz id
     */
    public UUID getQuizId() { return quizId; }
    /**
     * Sets quiz id.
     *
     * @param quizId the quiz id identifier
     */
    public void setQuizId(UUID quizId) { this.quizId = quizId; }

    /**
     * Returns question id.
     *
     * @return the question id
     */
    public UUID getQuestionId() { return questionId; }
    /**
     * Sets question id.
     *
     * @param questionId the question id identifier
     */
    public void setQuestionId(UUID questionId) { this.questionId = questionId; }

    /**
     * Returns order index.
     *
     * @return the order index
     */
    public int getOrderIndex() { return orderIndex; }
    /**
     * Sets order index.
     *
     * @param orderIndex the order index
     */
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    /**
     * Returns question.
     *
     * @return the question
     */
    public Question getQuestion() { return question; }
    /**
     * Sets question.
     *
     * @param question the question
     */
    public void setQuestion(Question question) { this.question = question; }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "QuizQuestion{id=" + id + ", quizId=" + quizId + ", questionId=" + questionId + "}";
    }
}
