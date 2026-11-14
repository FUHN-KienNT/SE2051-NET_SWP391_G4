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
    public void setId(UUID id) { this.id = id; }

    public UUID getQuizId() { return quizId; }
    public void setQuizId(UUID quizId) { this.quizId = quizId; }

    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }

    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public Boolean getPassStatus() { return passStatus; }
    public void setPassStatus(Boolean passStatus) { this.passStatus = passStatus; }

    @Override
    public String toString() {
        return "QuizSubmission{id=" + id + ", quizId=" + quizId + ", score=" + score + "}";
    }
}
