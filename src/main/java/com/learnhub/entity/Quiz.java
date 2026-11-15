package com.learnhub.entity;

import com.learnhub.constant.AppConstants;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Quiz implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID moduleId;
    private String title;
    private Integer timeLimit;
    private java.math.BigDecimal passScore;
    private String status = AppConstants.QuizStatus.PUBLISHED;
    private String imageUrl;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private UUID courseId;
    private String courseTitle;
    private String moduleTitle;
    private int questionCount;
    private int usedCount;

    /**
     * Creates an instance with the supplied values.
     */
    public Quiz() {
    }

    public UUID getId() { return id; }
    /**
     * Sets id.
     *
     * @param id the id identifier
     */
    public void setId(UUID id) { this.id = id; }

    /**
     * Returns module id.
     *
     * @return the module id
     */
    public UUID getModuleId() { return moduleId; }
    /**
     * Sets module id.
     *
     * @param moduleId the module id identifier
     */
    public void setModuleId(UUID moduleId) { this.moduleId = moduleId; }

    /**
     * Returns title.
     *
     * @return the title
     */
    public String getTitle() { return title; }
    /**
     * Sets title.
     *
     * @param title the title
     */
    public void setTitle(String title) { this.title = title; }

    /**
     * Returns time limit.
     *
     * @return the time limit
     */
    public Integer getTimeLimit() { return timeLimit; }
    /**
     * Sets time limit.
     *
     * @param timeLimit the time limit
     */
    public void setTimeLimit(Integer timeLimit) { this.timeLimit = timeLimit; }

    /**
     * Returns pass score.
     *
     * @return the pass score
     */
    public java.math.BigDecimal getPassScore() { return passScore; }
    /**
     * Sets pass score.
     *
     * @param passScore the pass score
     */
    public void setPassScore(java.math.BigDecimal passScore) { this.passScore = passScore; }

    /**
     * Returns status.
     *
     * @return the status
     */
    public String getStatus() { return status != null ? status : AppConstants.QuizStatus.PUBLISHED; }
    /**
     * Sets status.
     *
     * @param status the status
     */
    public void setStatus(String status) { this.status = status; }

    /**
     * Returns image url.
     *
     * @return the image url
     */
    public String getImageUrl() { return imageUrl; }
    /**
     * Sets image url.
     *
     * @param imageUrl the image url
     */
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    /**
     * Returns created at.
     *
     * @return the created at
     */
    public Timestamp getCreatedAt() { return createdAt; }
    /**
     * Sets created at.
     *
     * @param createdAt the created at
     */
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    /**
     * Returns updated at.
     *
     * @return the updated at
     */
    public Timestamp getUpdatedAt() { return updatedAt; }
    /**
     * Sets updated at.
     *
     * @param updatedAt the updated at
     */
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    /**
     * Returns course id.
     *
     * @return the course id
     */
    public UUID getCourseId() { return courseId; }
    /**
     * Sets course id.
     *
     * @param courseId the course id identifier
     */
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

    /**
     * Returns course title.
     *
     * @return the course title
     */
    public String getCourseTitle() { return courseTitle; }
    /**
     * Sets course title.
     *
     * @param courseTitle the course title
     */
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    /**
     * Returns module title.
     *
     * @return the module title
     */
    public String getModuleTitle() { return moduleTitle; }
    /**
     * Sets module title.
     *
     * @param moduleTitle the module title
     */
    public void setModuleTitle(String moduleTitle) { this.moduleTitle = moduleTitle; }

    /**
     * Returns question count.
     *
     * @return the question count
     */
    public int getQuestionCount() { return questionCount; }
    /**
     * Sets question count.
     *
     * @param questionCount the question count
     */
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }

    /**
     * Returns used count.
     *
     * @return the used count
     */
    public int getUsedCount() { return usedCount; }
    /**
     * Sets used count.
     *
     * @param usedCount the used count
     */
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    /**
     * Checks whether used.
     *
     * @return true when the condition holds; false otherwise
     */
    public boolean isUsed() { return usedCount > 0; }

    public boolean isHidden() {
        return AppConstants.QuizStatus.HIDDEN.equalsIgnoreCase(status);
    }

    /**
     * Checks whether published.
     *
     * @return true when the condition holds; false otherwise
     */
    public boolean isPublished() {
        return AppConstants.QuizStatus.PUBLISHED.equalsIgnoreCase(status);
    }

    @Override
    public String toString() {
        return "Quiz{id=" + id + ", title='" + title + "', timeLimit=" + timeLimit + ", status='" + status + "'}";
    }
}
