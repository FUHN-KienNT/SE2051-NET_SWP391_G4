package com.fpt.lms.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Module implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID courseId;
    private String title;
    private String content;
    private int orderIndex;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private List<Lesson> lessons = new ArrayList<>();
    private List<Quiz> quizzes = new ArrayList<>();

    public Module() {
        this.orderIndex = 0;
    }

    public Module(UUID id, UUID courseId, String title, String content, int orderIndex) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.content = content;
        this.orderIndex = orderIndex;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getCourseId() { return courseId; }
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public List<Lesson> getLessons() { return lessons; }
    public void setLessons(List<Lesson> lessons) { this.lessons = lessons; }

    public List<Quiz> getQuizzes() { return quizzes; }
    public void setQuizzes(List<Quiz> quizzes) { this.quizzes = quizzes; }

    @Override
    public String toString() {
        return "Module{id=" + id + ", title='" + title + "', orderIndex=" + orderIndex + "}";
    }
}
