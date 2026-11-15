package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Question implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID moduleId;
    private String content;
    private String type;
    private String status = "public"; // public | draft | hidden
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private String moduleTitle;
    private UUID courseId;
    private String courseTitle;
    private int quizCount; // Số bài thi/quiz đang sử dụng câu hỏi này
    private List<QuestionOption> options = new ArrayList<>();

    /**
     * Creates an instance with the supplied values.
     */
    public Question() {
        this.type = "single_choice";
        this.status = "public";
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param content the content
     * @param type the type
     */
    public Question(UUID id, String content, String type) {
        this();
        this.id = id;
        this.content = content;
        this.type = type;
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
     * Returns status.
     *
     * @return the status
     */
    public String getStatus() { return status != null ? status : "public"; }
    /**
     * Sets status.
     *
     * @param status the status
     */
    public void setStatus(String status) { this.status = status; }

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

    public int getQuizCount() { return quizCount; }
    /**
     * Sets quiz count.
     *
     * @param quizCount the quiz count
     */
    public void setQuizCount(int quizCount) { this.quizCount = quizCount; }

    /**
     * Returns options.
     *
     * @return the options
     */
    public List<QuestionOption> getOptions() { return options; }
    /**
     * Sets options.
     *
     * @param options the options
     */
    public void setOptions(List<QuestionOption> options) { this.options = options; }

    /**
     * Add option.
     *
     * @param option the option
     */
    public void addOption(QuestionOption option) {
        if (this.options == null) {
            this.options = new ArrayList<>();
        }
        this.options.add(option);
    }

    /**
     * Checks whether fill in blank.
     *
     * @return true when the condition holds; false otherwise
     */
    public boolean isFillInBlank() {
        return "fill_in_blank".equalsIgnoreCase(type);
    }

    public boolean isMultipleChoice() {
        return "multiple_choice".equalsIgnoreCase(type);
    }

    @Override
    public String toString() {
        return "Question{id=" + id + ", content='" + content + "', type='" + type + "', status='" + status + "'}";
    }
}
