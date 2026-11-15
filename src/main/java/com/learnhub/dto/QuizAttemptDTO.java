package com.learnhub.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.UUID;

public class QuizAttemptDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID quizId;
    private int totalQuestions;
    private int correctAnswers;
    private BigDecimal score;
    private Boolean passed;
    private Timestamp submittedAt;

    /**
     * Creates an instance with the supplied values.
     */
    public QuizAttemptDTO() {
    }

    public UUID getQuizId() { return quizId; }
    /**
     * Sets quiz id.
     *
     * @param quizId the quiz id identifier
     */
    public void setQuizId(UUID quizId) { this.quizId = quizId; }

    public int getTotalQuestions() { return totalQuestions; }
    /**
     * Sets total questions.
     *
     * @param totalQuestions the total questions
     */
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    /**
     * Returns correct answers.
     *
     * @return the correct answers
     */
    public int getCorrectAnswers() { return correctAnswers; }
    /**
     * Sets correct answers.
     *
     * @param correctAnswers the correct answers
     */
    public void setCorrectAnswers(int correctAnswers) { this.correctAnswers = correctAnswers; }

    /**
     * Returns score.
     *
     * @return the score
     */
    public BigDecimal getScore() { return score; }
    /**
     * Sets score.
     *
     * @param score the score
     */
    public void setScore(BigDecimal score) { this.score = score; }

    /**
     * Returns passed.
     *
     * @return true when the condition holds; false otherwise
     */
    public Boolean getPassed() { return passed; }
    /**
     * Sets passed.
     *
     * @param passed the passed
     */
    public void setPassed(Boolean passed) { this.passed = passed; }

    /**
     * Returns submitted at.
     *
     * @return the submitted at
     */
    public Timestamp getSubmittedAt() { return submittedAt; }
    /**
     * Sets submitted at.
     *
     * @param submittedAt the submitted at
     */
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }
}
