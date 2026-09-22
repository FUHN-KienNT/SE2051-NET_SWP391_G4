package com.learnhub.service;

import com.learnhub.dao.QuestionDAO;
import com.learnhub.dao.QuizAttemptDAO;
import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import com.learnhub.entity.QuizSubmission;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

/**
 * Service for calculating Quiz scores.
 * Implements methods specified in SDS Quiz Submission & Scoring Diagram (3.1):
 * - calculateScore()
 * - isAllOrNothingCorrect()
 * - getBestAttemptScore()
 */
public class ScoringService {
    private final QuestionDAO questionDAO;
    private final QuizAttemptDAO quizAttemptDAO;

    public ScoringService() {
        this.questionDAO = new QuestionDAO();
        this.quizAttemptDAO = new QuizAttemptDAO();
    }

    public ScoringService(QuestionDAO questionDAO, QuizAttemptDAO quizAttemptDAO) {
        this.questionDAO = questionDAO;
        this.quizAttemptDAO = quizAttemptDAO;
    }

    public BigDecimal calculateScore(UUID quizId, Map<UUID, List<UUID>> selectedAnswers) {
        List<Question> questions = questionDAO.findQuestionsByQuizId(quizId);
        if (questions == null || questions.isEmpty()) {
            return BigDecimal.ZERO;
        }

        int totalQuestions = questions.size();
        int correctCount = 0;

        for (Question q : questions) {
            List<UUID> selected = selectedAnswers != null ? selectedAnswers.get(q.getId()) : Collections.emptyList();
            if (isAllOrNothingCorrect(q.getId(), selected)) {
                correctCount++;
            }
        }

        double scoreVal = ((double) correctCount / totalQuestions) * 10.0;
        return BigDecimal.valueOf(scoreVal).setScale(2, RoundingMode.HALF_UP);
    }

    public boolean isAllOrNothingCorrect(UUID questionId, List<UUID> selectedOptionIds) {
        if (selectedOptionIds == null || selectedOptionIds.isEmpty()) {
            return false;
        }

        List<QuestionOption> options = questionDAO.findOptionsByQuestionId(questionId);
        Set<UUID> correctOptionIds = new HashSet<>();
        for (QuestionOption opt : options) {
            if (opt.isCorrect()) {
                correctOptionIds.add(opt.getId());
            }
        }

        Set<UUID> userSelected = new HashSet<>(selectedOptionIds);
        return correctOptionIds.equals(userSelected);
    }

    public BigDecimal getBestAttemptScore(UUID userId, UUID quizId) {
        List<QuizSubmission> attempts = quizAttemptDAO.findAttemptsByStudent(userId, quizId);
        BigDecimal maxScore = BigDecimal.ZERO;
        for (QuizSubmission a : attempts) {
            if (a.getScore() != null && a.getScore().compareTo(maxScore) > 0) {
                maxScore = a.getScore();
            }
        }
        return maxScore;
    }
}
