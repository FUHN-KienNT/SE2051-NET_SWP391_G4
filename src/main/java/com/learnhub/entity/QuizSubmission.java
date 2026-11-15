package com.learnhub.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.UUID;

public class QuizSubmission implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID quizId;
    private UUID userId;
    private BigDecimal score;
    private Timestamp submittedAt;
    private Boolean passStatus;

    public QuizSubmission() {
    }

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
     * Returns user id.
     *
     * @return the user id
     */
    public UUID getUserId() { return userId; }
    /**
     * Sets user id.
     *
     * @param userId the user id identifier
     */
    public void setUserId(UUID userId) { this.userId = userId; }

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

    /**
     * Returns pass status.
     *
     * @return true when the condition holds; false otherwise
     */
    public Boolean getPassStatus() { return passStatus; }
    /**
     * Sets pass status.
     *
     * @param passStatus the pass status
     */
    public void setPassStatus(Boolean passStatus) { this.passStatus = passStatus; }

    @Override
    public String toString() {
        return "QuizSubmission{id=" + id + ", quizId=" + quizId + ", score=" + score + "}";
    }
}
