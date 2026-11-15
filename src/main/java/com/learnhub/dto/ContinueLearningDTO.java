package com.learnhub.dto;

import java.util.UUID;

public class ContinueLearningDTO {
    private UUID courseId;
    private String courseTitle;
    private String categoryName;
    private UUID categoryId;
    private String registrationStatus;
    private String thumbnailUrl;
    private int moduleCount;
    private int lessonCount;
    private int completedLessonCount;
    private UUID lessonId;
    private String lessonTitle;
    private String moduleTitle;
    private int progressPercent;

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
     * Returns category name.
     *
     * @return the category name
     */
    public String getCategoryName() { return categoryName; }
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
     * Returns registration status.
     *
     * @return the registration status
     */
    public String getRegistrationStatus() { return registrationStatus; }
    /**
     * Sets registration status.
     *
     * @param registrationStatus the registration status
     */
    public void setRegistrationStatus(String registrationStatus) { this.registrationStatus = registrationStatus; }
    /**
     * Sets category name.
     *
     * @param categoryName the category name
     */
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

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
     * Returns completed lesson count.
     *
     * @return the completed lesson count
     */
    public int getCompletedLessonCount() { return completedLessonCount; }
    /**
     * Sets completed lesson count.
     *
     * @param completedLessonCount the completed lesson count
     */
    public void setCompletedLessonCount(int completedLessonCount) { this.completedLessonCount = completedLessonCount; }

    /**
     * Returns lesson id.
     *
     * @return the lesson id
     */
    public UUID getLessonId() { return lessonId; }
    /**
     * Sets lesson id.
     *
     * @param lessonId the lesson id identifier
     */
    public void setLessonId(UUID lessonId) { this.lessonId = lessonId; }

    /**
     * Returns lesson title.
     *
     * @return the lesson title
     */
    public String getLessonTitle() { return lessonTitle; }
    /**
     * Sets lesson title.
     *
     * @param lessonTitle the lesson title
     */
    public void setLessonTitle(String lessonTitle) { this.lessonTitle = lessonTitle; }

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
     * Returns progress percent.
     *
     * @return the progress percent
     */
    public int getProgressPercent() { return progressPercent; }
    /**
     * Sets progress percent.
     *
     * @param progressPercent the progress percent
     */
    public void setProgressPercent(int progressPercent) { this.progressPercent = progressPercent; }
}
