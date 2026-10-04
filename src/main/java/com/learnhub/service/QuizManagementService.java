package com.learnhub.service;

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

    private final QuizDAO quizDAO = new QuizDAO();
    private final QuizQuestionDAO qqDAO = new QuizQuestionDAO();

    // =========================================================
    // FIND QUIZZES
    // =========================================================

    public List<Quiz> findByExpert(
            UUID expertId,
            String keyword,
            UUID moduleId) {

        return quizDAO.findByExpertId(
                expertId,
                keyword,
                moduleId
        );
    }

    public List<Quiz> findByExpert(
            UUID expertId,
            String keyword,
            UUID moduleId,
            UUID courseId) {

        return quizDAO.findByExpertId(
                expertId,
                keyword,
                moduleId,
                courseId
        );
    }

    // =========================================================
    // GET QUIZ
    // =========================================================

    public Quiz get(UUID id) {
        return quizDAO.findById(id);
    }

    // =========================================================
    // GET QUESTION IDS
    // =========================================================

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
     * Creates or updates a Quiz.
     *
     * Validation is performed here.
     * Actual database save is handled by QuizDAO
     * in a single transaction.
     */
    public boolean save(
            UUID expertId,
            UUID id,
            UUID moduleId,
            String title,
            Integer timeLimit,
            BigDecimal passScore,
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
        // Time Limit
        // -----------------------------------------------------

        if (timeLimit != null) {

            if (timeLimit < 1 || timeLimit > 600) {
                return false;
            }
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
                safeQuestionIds
        );
    }

    // =========================================================
    // DELETE QUIZ
    // =========================================================

    public boolean delete(UUID expertId, UUID id) {

        if (expertId == null || id == null) {
            return false;
        }

        if (!quizDAO.belongsToExpert(id, expertId)) {
            return false;
        }

        return quizDAO.delete(id);
    }
}