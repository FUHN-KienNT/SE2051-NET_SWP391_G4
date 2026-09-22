package com.fpt.lms.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class QuizSubmission implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID quizId;
    private UUID userId;
    private BigDecimal score;
    private Timestamp submittedAt;
    private Boolean passStatus;

    // Helper / joined fields
    private String quizTitle;
    private String userName;
    private int totalQuestions;
    private int correctAnswers;
    private List<QuizAnswer> answers = new ArrayList<>();

    public QuizSubmission() {
    }

    public QuizSubmission(UUID id, UUID quizId, UUID userId, BigDecimal score, Boolean passStatus) {
        this.id = id;
        this.quizId = quizId;
        this.userId = userId;
        this.score = score;
        this.passStatus = passStatus;
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

    public String getQuizTitle() { return quizTitle; }
    public void setQuizTitle(String quizTitle) { this.quizTitle = quizTitle; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public int getCorrectAnswers() { return correctAnswers; }
    public void setCorrectAnswers(int correctAnswers) { this.correctAnswers = correctAnswers; }

    public List<QuizAnswer> getAnswers() { return answers; }
    public void setAnswers(List<QuizAnswer> answers) { this.answers = answers; }

    @Override
    public String toString() {
        return "QuizSubmission{id=" + id + ", quizId=" + quizId + ", score=" + score + "}";
    }
}
