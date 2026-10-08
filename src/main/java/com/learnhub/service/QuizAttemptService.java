package com.learnhub.service;

import com.learnhub.dao.AnswerDAO;
import com.learnhub.dao.QuestionDAO;
import com.learnhub.dao.QuizAttemptDAO;
import com.learnhub.dao.QuizDAO;
import com.learnhub.dto.QuizAttemptDTO;
import com.learnhub.entity.Question;
import com.learnhub.entity.Quiz;
import com.learnhub.entity.QuizSubmission;

import java.math.BigDecimal;
import java.util.*;
import java.util.logging.Logger;

/**
 * Service managing Quiz attempts, scoring submissions, and auto-submits.
 * Implements methods specified in SDS Quiz Submission & Scoring Diagram (3.1, 3.2, 3.3):
 * - startQuizAttempt()
 * - submitQuizAttempt()
 * - autoSubmitExpired()
 */
public class QuizAttemptService {
    private static final Logger LOGGER = Logger.getLogger(QuizAttemptService.class.getName());

    private final QuizAttemptDAO quizAttemptDAO;
    private final AnswerDAO answerDAO;
    private final QuestionDAO questionDAO;
    private final QuizDAO quizDAO;

    public QuizAttemptService() {
        this.quizAttemptDAO = new QuizAttemptDAO();
        this.answerDAO = new AnswerDAO();
        this.questionDAO = new QuestionDAO();
        this.quizDAO = new QuizDAO();
    }

    public QuizSubmission startQuizAttempt(UUID userId, UUID quizId) {
        QuizSubmission attempt = new QuizSubmission();
        attempt.setId(UUID.randomUUID());
        attempt.setQuizId(quizId);
        attempt.setUserId(userId);
        attempt.setScore(null);
        attempt.setPassStatus(null);
        quizAttemptDAO.insertAttempt(attempt);
        return attempt;
    }

    public QuizAttemptDTO submitQuizAttempt(UUID submissionId, Map<UUID, List<UUID>> selectedAnswers) {
        QuizSubmission attempt = quizAttemptDAO.findById(submissionId);
        if (attempt == null) return null;

        Quiz quiz = quizDAO.findById(attempt.getQuizId());
        BigDecimal passScoreThreshold = (quiz != null && quiz.getPassScore() != null) ? quiz.getPassScore() : BigDecimal.valueOf(5.0);

        answerDAO.saveAnswers(submissionId, selectedAnswers);
        BigDecimal score = calculateScore(attempt.getQuizId(), selectedAnswers);
        boolean passed = score.compareTo(passScoreThreshold) >= 0;

        quizAttemptDAO.updateScore(submissionId, score, passed);
        quizAttemptDAO.updateBestFlag(submissionId);

        List<Question> questions = questionDAO.findQuestionsByQuizId(attempt.getQuizId());

        QuizAttemptDTO dto = new QuizAttemptDTO();
        dto.setAttemptId(submissionId);
        dto.setQuizId(attempt.getQuizId());
        dto.setQuizTitle(quiz != null ? quiz.getTitle() : "Quiz");
        dto.setScore(score);
        dto.setPassed(passed);
        dto.setTotalQuestions(questions.size());
        dto.setSelectedAnswers(selectedAnswers);
        return dto;
    }

    public int autoSubmitExpired() {
        List<QuizSubmission> expired = quizAttemptDAO.findExpiredAttempts();
        int count = 0;
        for (QuizSubmission a : expired) {
            submitQuizAttempt(a.getId(), Collections.emptyMap());
            count++;
        }
        LOGGER.info("Auto-submitted " + count + " expired quiz attempts.");
        return count;
    }

    public QuizSubmission getAttempt(UUID attemptId) {
        return quizAttemptDAO.findById(attemptId);
    }

    public List<QuizSubmission> getAttemptHistory(UUID userId, UUID quizId) {
        return quizAttemptDAO.findAttemptsByStudent(userId, quizId);
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
        return BigDecimal.valueOf(scoreVal).setScale(2, java.math.RoundingMode.HALF_UP);
    }

    public boolean isAllOrNothingCorrect(UUID questionId, List<UUID> selectedOptionIds) {
        if (selectedOptionIds == null || selectedOptionIds.isEmpty()) {
            return false;
        }

        List<com.learnhub.entity.QuestionOption> options = questionDAO.findOptionsByQuestionId(questionId);
        Set<UUID> correctOptionIds = new HashSet<>();
        for (com.learnhub.entity.QuestionOption opt : options) {
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
