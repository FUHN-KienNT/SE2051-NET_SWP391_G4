package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class QuestionOption implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID questionId;
    private String optionText;
    private boolean isCorrect;
    private Timestamp updatedAt;

    /**
     * Creates an instance with the supplied values.
     */
    public QuestionOption() {
        this.isCorrect = false;
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param questionId the question id identifier
     * @param optionText the option text
     * @param isCorrect the is correct
     */
    public QuestionOption(UUID id, UUID questionId, String optionText, boolean isCorrect) {
        this.id = id;
        this.questionId = questionId;
        this.optionText = optionText;
        this.isCorrect = isCorrect;
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
     * Returns question id.
     *
     * @return the question id
     */
    public UUID getQuestionId() { return questionId; }
    /**
     * Sets question id.
     *
     * @param questionId the question id identifier
     */
    public void setQuestionId(UUID questionId) { this.questionId = questionId; }

    /**
     * Returns option text.
     *
     * @return the option text
     */
    public String getOptionText() { return optionText; }
    /**
     * Sets option text.
     *
     * @param optionText the option text
     */
    public void setOptionText(String optionText) { this.optionText = optionText; }

    /**
     * Checks whether correct.
     *
     * @return true when the condition holds; false otherwise
     */
    public boolean isCorrect() { return isCorrect; }
    /**
     * Sets correct.
     *
     * @param correct the correct
     */
    public void setCorrect(boolean correct) { isCorrect = correct; }

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
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "QuestionOption{id=" + id + ", optionText='" + optionText + "', isCorrect=" + isCorrect + "}";
    }
}
