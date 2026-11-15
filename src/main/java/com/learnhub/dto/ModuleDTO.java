package com.learnhub.dto;

import java.io.Serializable;
import java.util.UUID;

/**
 * Data Transfer Object for Module entity.
 */
public class ModuleDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID courseId;
    private String title;
    private String content;
    private int orderIndex;
    private int lessonCount;
    private int quizCount;

    /**
     * Creates an instance with the supplied values.
     */
    public ModuleDTO() {
        this.orderIndex = 0;
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param courseId the course id identifier
     * @param title the title
     * @param content the content
     * @param orderIndex the order index
     */
    public ModuleDTO(UUID id, UUID courseId, String title, String content, int orderIndex) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.content = content;
        this.orderIndex = orderIndex;
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param courseId the course id identifier
     * @param title the title
     * @param content the content
     * @param orderIndex the order index
     * @param lessonCount the lesson count
     * @param quizCount the quiz count
     */
    public ModuleDTO(UUID id, UUID courseId, String title, String content, int orderIndex, int lessonCount, int quizCount) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.content = content;
        this.orderIndex = orderIndex;
        this.lessonCount = lessonCount;
        this.quizCount = quizCount;
    }

    /**
     * Returns id.
     *
     * @return the id
     */
    public UUID getId() {
        return id;
    }

    /**
     * Sets id.
     *
     * @param id the id identifier
     */
    public void setId(UUID id) {
        this.id = id;
    }

    /**
     * Returns course id.
     *
     * @return the course id
     */
    public UUID getCourseId() {
        return courseId;
    }

    /**
     * Sets course id.
     *
     * @param courseId the course id identifier
     */
    public void setCourseId(UUID courseId) {
        this.courseId = courseId;
    }

    /**
     * Returns title.
     *
     * @return the title
     */
    public String getTitle() {
        return title;
    }

    /**
     * Sets title.
     *
     * @param title the title
     */
    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * Returns content.
     *
     * @return the content
     */
    public String getContent() {
        return content;
    }

    /**
     * Sets content.
     *
     * @param content the content
     */
    public void setContent(String content) {
        this.content = content;
    }

    /**
     * Returns order index.
     *
     * @return the order index
     */
    public int getOrderIndex() {
        return orderIndex;
    }

    /**
     * Sets order index.
     *
     * @param orderIndex the order index
     */
    public void setOrderIndex(int orderIndex) {
        this.orderIndex = orderIndex;
    }

    /**
     * Returns lesson count.
     *
     * @return the lesson count
     */
    public int getLessonCount() {
        return lessonCount;
    }

    /**
     * Sets lesson count.
     *
     * @param lessonCount the lesson count
     */
    public void setLessonCount(int lessonCount) {
        this.lessonCount = lessonCount;
    }

    /**
     * Returns quiz count.
     *
     * @return the quiz count
     */
    public int getQuizCount() {
        return quizCount;
    }

    /**
     * Sets quiz count.
     *
     * @param quizCount the quiz count
     */
    public void setQuizCount(int quizCount) {
        this.quizCount = quizCount;
    }
}
