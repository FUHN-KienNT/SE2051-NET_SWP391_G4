package com.fpt.lms.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class QuizAttemptDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID attemptId;
    private UUID quizId;
    private String quizTitle;
    private UUID userId;
    private String userName;
    private int totalQuestions;
    private int correctAnswers;
    private BigDecimal score;
    private Boolean passed;
    private Timestamp submittedAt;
    private Map<UUID, List<UUID>> selectedAnswers = new HashMap<>();

    public QuizAttemptDTO() {
    }

    public UUID getAttemptId() { return attemptId; }
    public void setAttemptId(UUID attemptId) { this.attemptId = attemptId; }

    public UUID getQuizId() { return quizId; }
    public void setQuizId(UUID quizId) { this.quizId = quizId; }

    public String getQuizTitle() { return quizTitle; }
    public void setQuizTitle(String quizTitle) { this.quizTitle = quizTitle; }

    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public int getCorrectAnswers() { return correctAnswers; }
    public void setCorrectAnswers(int correctAnswers) { this.correctAnswers = correctAnswers; }

    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }

    public Boolean getPassed() { return passed; }
    public void setPassed(Boolean passed) { this.passed = passed; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public Map<UUID, List<UUID>> getSelectedAnswers() { return selectedAnswers; }
    public void setSelectedAnswers(Map<UUID, List<UUID>> selectedAnswers) { this.selectedAnswers = selectedAnswers; }
}
