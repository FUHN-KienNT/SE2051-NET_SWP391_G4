package com.learnhub.entity;

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
    private boolean hidden;
    private String content;
    private int orderIndex;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private String courseTitle;
    private List<Lesson> lessons = new ArrayList<>();
    private List<Quiz> quizzes = new ArrayList<>();

    /**
     * Creates an instance with the supplied values.
     */
    public Module() {
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
    public Module(UUID id, UUID courseId, String title, String content, int orderIndex) {
        this.id = id;
        this.courseId = courseId;
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
     * Checks whether hidden.
     *
     * @return true when the condition holds; false otherwise
     */
    public boolean isHidden() { return hidden; }
    /**
     * Sets hidden.
     *
     * @param hidden the hidden
     */
    public void setHidden(boolean hidden) { this.hidden = hidden; }

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
     * Returns lessons.
     *
     * @return the lessons
     */
    public List<Lesson> getLessons() { return lessons; }
    /**
     * Sets lessons.
     *
     * @param lessons the lessons
     */
    public void setLessons(List<Lesson> lessons) { this.lessons = lessons; }

    /**
     * Returns quizzes.
     *
     * @return the quizzes
     */
    public List<Quiz> getQuizzes() { return quizzes; }
    /**
     * Sets quizzes.
     *
     * @param quizzes the quizzes
     */
    public void setQuizzes(List<Quiz> quizzes) { this.quizzes = quizzes; }

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
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "Module{id=" + id + ", title='" + title + "', orderIndex=" + orderIndex + "}";
    }
}
