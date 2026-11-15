package com.learnhub.entity;

import java.io.Serializable;
import java.util.UUID;

public class QuizAnswer implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID quizSubmissionId;
    private UUID quizQuestionId;
    private UUID questionOptionId;

    // Helper / joined fields
    private String questionContent;
    private String selectedOptionText;
    private boolean isCorrect;

    /**
     * Creates an instance with the supplied values.
     */
    public QuizAnswer() {
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param quizSubmissionId the quiz submission id identifier
     * @param quizQuestionId the quiz question id identifier
     * @param questionOptionId the question option id identifier
     */
    public QuizAnswer(UUID id, UUID quizSubmissionId, UUID quizQuestionId, UUID questionOptionId) {
        this.id = id;
        this.quizSubmissionId = quizSubmissionId;
        this.quizQuestionId = quizQuestionId;
        this.questionOptionId = questionOptionId;
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
     * Returns quiz submission id.
     *
     * @return the quiz submission id
     */
    public UUID getQuizSubmissionId() { return quizSubmissionId; }
    /**
     * Sets quiz submission id.
     *
     * @param quizSubmissionId the quiz submission id identifier
     */
    public void setQuizSubmissionId(UUID quizSubmissionId) { this.quizSubmissionId = quizSubmissionId; }

    /**
     * Returns quiz question id.
     *
     * @return the quiz question id
     */
    public UUID getQuizQuestionId() { return quizQuestionId; }
    /**
     * Sets quiz question id.
     *
     * @param quizQuestionId the quiz question id identifier
     */
    public void setQuizQuestionId(UUID quizQuestionId) { this.quizQuestionId = quizQuestionId; }

    /**
     * Returns question option id.
     *
     * @return the question option id
     */
    public UUID getQuestionOptionId() { return questionOptionId; }
    /**
     * Sets question option id.
     *
     * @param questionOptionId the question option id identifier
     */
    public void setQuestionOptionId(UUID questionOptionId) { this.questionOptionId = questionOptionId; }

    /**
     * Returns question content.
     *
     * @return the question content
     */
    public String getQuestionContent() { return questionContent; }
    /**
     * Sets question content.
     *
     * @param questionContent the question content
     */
    public void setQuestionContent(String questionContent) { this.questionContent = questionContent; }

    /**
     * Returns selected option text.
     *
     * @return the selected option text
     */
    public String getSelectedOptionText() { return selectedOptionText; }
    /**
     * Sets selected option text.
     *
     * @param selectedOptionText the selected option text
     */
    public void setSelectedOptionText(String selectedOptionText) { this.selectedOptionText = selectedOptionText; }

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
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "QuizAnswer{id=" + id + ", quizSubmissionId=" + quizSubmissionId + "}";
    }
}
