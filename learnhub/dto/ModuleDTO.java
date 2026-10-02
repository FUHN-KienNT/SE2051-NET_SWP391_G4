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

    public ModuleDTO() {
        this.orderIndex = 0;
    }

    public ModuleDTO(UUID id, UUID courseId, String title, String content, int orderIndex) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.content = content;
        this.orderIndex = orderIndex;
    }

    public ModuleDTO(UUID id, UUID courseId, String title, String content, int orderIndex, int lessonCount, int quizCount) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.content = content;
        this.orderIndex = orderIndex;
        this.lessonCount = lessonCount;
        this.quizCount = quizCount;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getCourseId() {
        return courseId;
    }

    public void setCourseId(UUID courseId) {
        this.courseId = courseId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getOrderIndex() {
        return orderIndex;
    }

    public void setOrderIndex(int orderIndex) {
        this.orderIndex = orderIndex;
    }

    public int getLessonCount() {
        return lessonCount;
    }

    public void setLessonCount(int lessonCount) {
        this.lessonCount = lessonCount;
    }

    public int getQuizCount() {
        return quizCount;
    }

    public void setQuizCount(int quizCount) {
        this.quizCount = quizCount;
    }
}
