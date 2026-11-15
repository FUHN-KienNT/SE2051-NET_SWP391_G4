package com.learnhub.entity;

import com.learnhub.constant.AppConstants;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class Lesson implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID moduleId;
    private String title;
    private String content;
    private int orderIndex;
    private Integer durationMinutes;
    private String type = "content";
    private String videoUrl;
    private UUID quizId;
    private String publicationStatus = AppConstants.LessonStatus.DRAFT;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private String declineReason;
    private String materialUrl;
    private String moduleTitle;
    private String quizTitle;
    private UUID courseId;
    private String status;

    /**
     * Creates an instance with the supplied values.
     */
    public Lesson() {
        this.orderIndex = 0;
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param moduleId the module id identifier
     * @param title the title
     * @param content the content
     * @param orderIndex the order index
     */
    public Lesson(UUID id, UUID moduleId, String title, String content, int orderIndex) {
        this.id = id;
        this.moduleId = moduleId;
        this.title = title;
        this.content = content;
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
     * Returns content.
     *
     * @return the content
     */
    public String getContent() { return content; }
    /**
     * Sets content.
     *
     * @param content the content
     */
    public void setContent(String content) { this.content = content; }

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
     * Returns duration minutes.
     *
     * @return the duration minutes
     */
    public Integer getDurationMinutes() { return durationMinutes; }
    /**
     * Returns type.
     *
     * @return the type
     */
    public String getType() { return type; }
    /**
     * Sets type.
     *
     * @param type the type
     */
    public void setType(String type) { this.type = type; }
    /**
     * Returns video url.
     *
     * @return the video url
     */
    public String getVideoUrl() { return videoUrl; }
    /**
     * Sets video url.
     *
     * @param videoUrl the video url
     */
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }
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
     * Sets duration minutes.
     *
     * @param durationMinutes the duration minutes
     */
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }

    /**
     * Returns publication status.
     *
     * @return the publication status
     */
    public String getPublicationStatus() { return publicationStatus; }
    /**
     * Sets publication status.
     *
     * @param publicationStatus the publication status
     */
    public void setPublicationStatus(String publicationStatus) { this.publicationStatus = publicationStatus; }

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
     * Returns decline reason.
     *
     * @return the decline reason
     */
    public String getDeclineReason() { return declineReason; }
    /**
     * Sets decline reason.
     *
     * @param declineReason the decline reason
     */
    public void setDeclineReason(String declineReason) { this.declineReason = declineReason; }

    /**
     * Returns material url.
     *
     * @return the material url
     */
    public String getMaterialUrl() { return materialUrl; }
    /**
     * Sets material url.
     *
     * @param materialUrl the material url
     */
    public void setMaterialUrl(String materialUrl) { this.materialUrl = materialUrl; }

    /**
     * Returns module title.
     *
     * @return the module title
     */
    public String getModuleTitle() { return moduleTitle; }
    /**
     * Returns quiz title.
     *
     * @return the quiz title
     */
    public String getQuizTitle() { return quizTitle; }
    /**
     * Sets quiz title.
     *
     * @param quizTitle the quiz title
     */
    public void setQuizTitle(String quizTitle) { this.quizTitle = quizTitle; }
    /**
     * Sets module title.
     *
     * @param moduleTitle the module title
     */
    public void setModuleTitle(String moduleTitle) { this.moduleTitle = moduleTitle; }

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
     * Returns status.
     *
     * @return the status
     */
    public String getStatus() { return status; }
    /**
     * Sets status.
     *
     * @param status the status
     */
    public void setStatus(String status) { this.status = status; }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "Lesson{id=" + id + ", title='" + title + "', orderIndex=" + orderIndex + "}";
    }
}
