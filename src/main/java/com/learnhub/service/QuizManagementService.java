package com.learnhub.service;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.QuizDAO;
import com.learnhub.dao.QuizQuestionDAO;
import com.learnhub.entity.Quiz;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Business layer for Expert Quiz List/Detail.
 */
public class QuizManagementService {

    private final QuizDAO quizDAO;
    private final QuizQuestionDAO qqDAO;

    /**
     * Creates an instance with the supplied values.
     */
    public QuizManagementService() {
        this(new QuizDAO(), new QuizQuestionDAO());
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param quizDAO the quiz dao
     */
    public QuizManagementService(QuizDAO quizDAO) {
        this(quizDAO, new QuizQuestionDAO());
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param quizDAO the quiz dao
     * @param qqDAO the qq dao
     */
    public QuizManagementService(QuizDAO quizDAO, QuizQuestionDAO qqDAO) {
        this.quizDAO = quizDAO;
        this.qqDAO = qqDAO;
    }

    // =========================================================
    // FIND QUIZZES
    // =========================================================

    /**
     * Finds by expert.
     *
     * @param expertId the expert id identifier
     * @param keyword the keyword
     * @param moduleId the module id identifier
     * @param courseId the course id identifier
     * @param status the status
     * @return the matching by expert, if present
     */
    public List<Quiz> findByExpert(
            UUID expertId,
            String keyword,
            UUID moduleId,
            UUID courseId,
            String status) {

        return quizDAO.findByExpertId(
                expertId,
                keyword,
                moduleId,
                courseId,
                status
        );
    }

    // =========================================================
    // GET QUIZ
    // =========================================================

    /**
     * Get.
     *
     * @param id the id identifier
     * @return the result of get
     */
    public Quiz get(UUID id) {
        return quizDAO.findById(id);
    }

    // =========================================================
    // GET QUESTION IDS
    // =========================================================

    /**
     * Returns question ids.
     *
     * @param quizId the quiz id identifier
     * @return the question ids
     */
    public List<UUID> getQuestionIds(UUID quizId) {

        if (quizId == null) {
            return new ArrayList<>();
        }

        return qqDAO.findQuestionIds(quizId);
    }

    // =========================================================
    // SAVE QUIZ
    // =========================================================

    /**
     * Save.
     *
     * @param expertId the expert id identifier
     * @param id the id identifier
     * @param moduleId the module id identifier
     * @param title the title
     * @param timeLimit the time limit
     * @param passScore the pass score
     * @param questionIds the question ids
     * @return true when the condition holds; false otherwise
     */
    public boolean save(
            UUID expertId,
            UUID id,
            UUID moduleId,
            String title,
            Integer timeLimit,
            BigDecimal passScore,
            List<UUID> questionIds) {
        return save(expertId, id, moduleId, title, timeLimit, passScore,
                AppConstants.QuizStatus.PUBLISHED, null, questionIds);
    }

    /**
     * Creates or updates a Quiz with status and image support.
     */
    public boolean save(
            UUID expertId,
            UUID id,
            UUID moduleId,
            String title,
            Integer timeLimit,
            BigDecimal passScore,
            String status,
            String imageUrl,
            List<UUID> questionIds) {

        // -----------------------------------------------------
        // Basic validation
        // -----------------------------------------------------

        if (expertId == null) {
            return false;
        }

        if (moduleId == null) {
            return false;
        }

        if (title == null || title.trim().isEmpty()) {
            return false;
        }

        title = title.trim();

        // -----------------------------------------------------
        // Title character limit: max 120 characters
        // -----------------------------------------------------

        if (title.length() > 120) {
            return false;
        }

        // -----------------------------------------------------
        // Time Limit: required, 1 - 600 minutes
        // -----------------------------------------------------

        if (timeLimit == null || timeLimit < 1 || timeLimit > 600) {
            return false;
        }

        // -----------------------------------------------------
        // Pass Score
        // -----------------------------------------------------

        if (passScore == null) {
            return false;
        }

        if (passScore.compareTo(BigDecimal.ZERO) < 0
                || passScore.compareTo(BigDecimal.TEN) > 0) {
            return false;
        }

        // -----------------------------------------------------
        // Normalize Question IDs
        // -----------------------------------------------------

        List<UUID> safeQuestionIds = new ArrayList<>();

        if (questionIds != null) {

            for (UUID questionId : questionIds) {

                if (questionId != null
                        && !safeQuestionIds.contains(questionId)) {

                    safeQuestionIds.add(questionId);
                }
            }
        }

        // -----------------------------------------------------
        // Save everything in one transaction
        // -----------------------------------------------------

        return quizDAO.saveWithQuestions(
                expertId,
                id,
                moduleId,
                title,
                timeLimit,
                passScore,
                status,
                imageUrl,
                safeQuestionIds
        );
    }

    // =========================================================
    // HIDE / UNHIDE / DELETE QUIZ
    // =========================================================

    /**
     * Hide.
     *
     * @param expertId the expert id identifier
     * @param id the id identifier
     * @return true when the condition holds; false otherwise
     */
    public boolean hide(UUID expertId, UUID id) {
        if (expertId == null || id == null) {
            return false;
        }

        if (!quizDAO.belongsToExpert(id, expertId)) {
            return false;
        }

        return quizDAO.hide(id);
    }

    /**
     * Unhide.
     *
     * @param expertId the expert id identifier
     * @param id the id identifier
     * @return true when the condition holds; false otherwise
     */
    public boolean unhide(UUID expertId, UUID id) {
        if (expertId == null || id == null) {
            return false;
        }

        if (!quizDAO.belongsToExpert(id, expertId)) {
            return false;
        }

        return quizDAO.unhide(id);
    }

    /**
     * Checks whether used.
     *
     * @param id the id identifier
     * @return true when the condition holds; false otherwise
     */
    public boolean isUsed(UUID id) {
        if (id == null) {
            return false;
        }
        return quizDAO.isUsed(id);
    }

    /**
     * Xóa vĩnh viễn quiz nếu thuộc về expert và chưa từng được sử dụng trong khóa học / chương học nào.
     * Nếu quiz đã được dùng thì trả về false (chỉ được phép ẩn).
     */
    public boolean delete(UUID expertId, UUID id) {
        if (expertId == null || id == null) {
            return false;
        }

        if (!quizDAO.belongsToExpert(id, expertId)) {
            return false;
        }

        if (quizDAO.isUsed(id)) {
            return false;
        }

        return quizDAO.delete(id);
    }
}
