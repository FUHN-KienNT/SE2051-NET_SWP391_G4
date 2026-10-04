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
    private String expertName;
    private String createdByName;
    private int moduleCount;
    private int lessonCount;
    private int enrolledCount;
    private List<Module> modules = new ArrayList<>();

    public Course() {
        this.price = BigDecimal.ZERO;
        this.status = "draft";
    }

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

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getThumbnail() { return thumbnailUrl; }
    public void setThumbnail(String thumbnail) { this.thumbnailUrl = thumbnail; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public UUID getCategoryId() { return categoryId; }
    public void setCategoryId(UUID categoryId) { this.categoryId = categoryId; }

    public UUID getCreatedBy() { return createdBy; }
    public void setCreatedBy(UUID createdBy) { this.createdBy = createdBy; }

    public UUID getExpertId() { return expertId; }
    public void setExpertId(UUID expertId) { this.expertId = expertId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getExpertName() { return expertName; }
    public void setExpertName(String expertName) { this.expertName = expertName; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public int getModuleCount() { return moduleCount; }
    public void setModuleCount(int moduleCount) { this.moduleCount = moduleCount; }

    public int getLessonCount() { return lessonCount; }
    public void setLessonCount(int lessonCount) { this.lessonCount = lessonCount; }

    public int getEnrolledCount() { return enrolledCount; }
    public void setEnrolledCount(int enrolledCount) { this.enrolledCount = enrolledCount; }

    public List<Module> getModules() { return modules; }
    public void setModules(List<Module> modules) { this.modules = modules; }

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

    @Override
    public String toString() {
        return "Course{id=" + id + ", title='" + title + "', price=" + price + "}";
    }
}
