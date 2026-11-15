package com.learnhub.dto;

import java.io.Serializable;
import java.util.UUID;

public class LessonDTO implements Serializable {
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
    private String publicationStatus = "draft";
    private String materialUrl;
    private String status;

    /**
     * Creates an instance with the supplied values.
     */
    public LessonDTO() {
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
    public LessonDTO(UUID id, UUID moduleId, String title, String content, int orderIndex) {
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
}
