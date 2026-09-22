package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class ContentReview implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID lessonId;
    private UUID expertId;
    private UUID reviewerId;
    private String status;
    private String comments;
    private Timestamp submittedAt;
    private Timestamp reviewedAt;

    // Helper / joined fields
    private String lessonTitle;
    private String expertName;
    private String reviewerName;

    public ContentReview() {
        this.status = "pending";
    }

    public ContentReview(UUID id, UUID lessonId, UUID expertId, String status) {
        this();
        this.id = id;
        this.lessonId = lessonId;
        this.expertId = expertId;
        this.status = status;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getLessonId() { return lessonId; }
    public void setLessonId(UUID lessonId) { this.lessonId = lessonId; }

    public UUID getExpertId() { return expertId; }
    public void setExpertId(UUID expertId) { this.expertId = expertId; }

    public UUID getReviewerId() { return reviewerId; }
    public void setReviewerId(UUID reviewerId) { this.reviewerId = reviewerId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }

    public String getLessonTitle() { return lessonTitle; }
    public void setLessonTitle(String lessonTitle) { this.lessonTitle = lessonTitle; }

    public String getExpertName() { return expertName; }
    public void setExpertName(String expertName) { this.expertName = expertName; }

    public String getReviewerName() { return reviewerName; }
    public void setReviewerName(String reviewerName) { this.reviewerName = reviewerName; }

    @Override
    public String toString() {
        return "ContentReview{id=" + id + ", lessonId=" + lessonId + ", status='" + status + "'}";
    }
}
