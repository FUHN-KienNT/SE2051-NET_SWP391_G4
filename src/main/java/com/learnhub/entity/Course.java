package com.learnhub.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Course implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private String title;
    private String description;
    private BigDecimal price;
    private String thumbnailUrl;
    private String status;
    private UUID categoryId;
    private UUID createdBy;
    private UUID expertId;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined / helper fields
    private String categoryName;
    private Boolean categoryStatus;
    private String expertName;
    private String createdByName;
    private int moduleCount;
    private int lessonCount;
    private int enrolledCount;
    private List<Module> modules = new ArrayList<>();

    /**
     * Creates an instance with the supplied values.
     */
    public Course() {
        this.price = BigDecimal.ZERO;
        this.status = "draft";
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
     * @param createdBy the created by
     * @param expertId the expert id identifier
     */
    public Course(UUID id, String title, String description, BigDecimal price, String thumbnailUrl, String status, UUID categoryId, UUID createdBy, UUID expertId) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.price = price;
        this.thumbnailUrl = thumbnailUrl;
        this.status = status;
        this.categoryId = categoryId;
        this.createdBy = createdBy;
        this.expertId = expertId;
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

    /**
     * Returns thumbnail.
     *
     * @return the thumbnail
     */
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
     * Returns created by.
     *
     * @return the created by
     */
    public UUID getCreatedBy() { return createdBy; }
    /**
     * Sets created by.
     *
     * @param createdBy the created by
     */
    public void setCreatedBy(UUID createdBy) { this.createdBy = createdBy; }

    /**
     * Returns expert id.
     *
     * @return the expert id
     */
    public UUID getExpertId() { return expertId; }
    /**
     * Sets expert id.
     *
     * @param expertId the expert id identifier
     */
    public void setExpertId(UUID expertId) { this.expertId = expertId; }

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
     * Returns created by name.
     *
     * @return the created by name
     */
    public String getCreatedByName() { return createdByName; }
    /**
     * Sets created by name.
     *
     * @param createdByName the created by name
     */
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

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

    /**
     * Returns enrolled count.
     *
     * @return the enrolled count
     */
    public int getEnrolledCount() { return enrolledCount; }
    /**
     * Sets enrolled count.
     *
     * @param enrolledCount the enrolled count
     */
    public void setEnrolledCount(int enrolledCount) { this.enrolledCount = enrolledCount; }

    /**
     * Returns modules.
     *
     * @return the modules
     */
    public List<Module> getModules() { return modules; }
    /**
     * Sets modules.
     *
     * @param modules the modules
     */
    public void setModules(List<Module> modules) { this.modules = modules; }

    /**
     * Returns course code.
     *
     * @return the course code
     */
    public String getCourseCode() {
        if (id == null) return "CRS-NEW";
        String s = id.toString();
        if (s.length() >= 36) {
            String lastDigits = s.substring(s.lastIndexOf("-") + 1);
            try {
                long num = Long.parseLong(lastDigits, 16);
                return "CRS-" + (100 + (num % 900));
            } catch (Exception ignored) {
            }
        }
        return "CRS-" + s.substring(0, 4).toUpperCase();
    }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "Course{id=" + id + ", title='" + title + "', price=" + price + "}";
    }
}
