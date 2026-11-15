package com.learnhub.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.UUID;

public class CourseDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private String title;
    private String description;
    private BigDecimal price;
    private String thumbnailUrl;
    private String status;
    private UUID categoryId;
    private String categoryName;
    private Boolean categoryStatus;
    private String expertName;
    private int moduleCount;
    private int lessonCount;

    /**
     * Creates an instance with the supplied values.
     */
    public CourseDTO() {
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param title the title
     * @param description the description
     * @param price the price
     * @param thumbnailUrl the thumbnail url
     * @param status the status
     * @param categoryId the category id identifier
     * @param categoryName the category name
     * @param expertName the expert name
     */
    public CourseDTO(UUID id, String title, String description, BigDecimal price, String thumbnailUrl, String status, UUID categoryId, String categoryName, String expertName) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.price = price;
        this.thumbnailUrl = thumbnailUrl;
        this.status = status;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.expertName = expertName;
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
     * Returns description.
     *
     * @return the description
     */
    public String getDescription() { return description; }
    /**
     * Sets description.
     *
     * @param description the description
     */
    public void setDescription(String description) { this.description = description; }

    /**
     * Returns price.
     *
     * @return the price
     */
    public BigDecimal getPrice() { return price; }
    /**
     * Sets price.
     *
     * @param price the price
     */
    public void setPrice(BigDecimal price) { this.price = price; }

    /**
     * Returns thumbnail url.
     *
     * @return the thumbnail url
     */
    public String getThumbnailUrl() { return thumbnailUrl; }
    /**
     * Sets thumbnail url.
     *
     * @param thumbnailUrl the thumbnail url
     */
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    /** Alias để JSP có thể dùng ${c.thumbnail} hoặc ${c.thumbnailUrl} đều được */
    public String getThumbnail() { return thumbnailUrl; }
    /**
     * Sets thumbnail.
     *
     * @param thumbnail the thumbnail
     */
    public void setThumbnail(String thumbnail) { this.thumbnailUrl = thumbnail; }

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
     * Returns category id.
     *
     * @return the category id
     */
    public UUID getCategoryId() { return categoryId; }
    /**
     * Sets category id.
     *
     * @param categoryId the category id identifier
     */
    public void setCategoryId(UUID categoryId) { this.categoryId = categoryId; }

    /**
     * Returns category status.
     *
     * @return true when the condition holds; false otherwise
     */
    public Boolean getCategoryStatus() { return categoryStatus; }
    /**
     * Sets category status.
     *
     * @param categoryStatus the category status
     */
    public void setCategoryStatus(Boolean categoryStatus) { this.categoryStatus = categoryStatus; }

    /**
     * Returns category name.
     *
     * @return the category name
     */
    public String getCategoryName() { return categoryName; }
    /**
     * Sets category name.
     *
     * @param categoryName the category name
     */
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    /**
     * Returns expert name.
     *
     * @return the expert name
     */
    public String getExpertName() { return expertName; }
    /**
     * Sets expert name.
     *
     * @param expertName the expert name
     */
    public void setExpertName(String expertName) { this.expertName = expertName; }

    /**
     * Returns module count.
     *
     * @return the module count
     */
    public int getModuleCount() { return moduleCount; }
    /**
     * Sets module count.
     *
     * @param moduleCount the module count
     */
    public void setModuleCount(int moduleCount) { this.moduleCount = moduleCount; }

    /**
     * Returns lesson count.
     *
     * @return the lesson count
     */
    public int getLessonCount() { return lessonCount; }
    /**
     * Sets lesson count.
     *
     * @param lessonCount the lesson count
     */
    public void setLessonCount(int lessonCount) { this.lessonCount = lessonCount; }
}
