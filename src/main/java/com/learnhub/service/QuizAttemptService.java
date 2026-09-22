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
    private final ScoringService scoringService;
    private final AnswerDAO answerDAO;
    private final QuestionDAO questionDAO;
    private final QuizDAO quizDAO;

    public QuizAttemptService() {
        this.quizAttemptDAO = new QuizAttemptDAO();
        this.scoringService = new ScoringService();
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

        answerDAO.saveAnswers(submissionId, selectedAnswers);
        BigDecimal score = scoringService.calculateScore(attempt.getQuizId(), selectedAnswers);
        boolean passed = score.compareTo(BigDecimal.valueOf(5.0)) >= 0;

        quizAttemptDAO.updateScore(submissionId, score, passed);
        quizAttemptDAO.updateBestFlag(submissionId);

        List<Question> questions = questionDAO.findQuestionsByQuizId(attempt.getQuizId());
        Quiz quiz = quizDAO.findById(attempt.getQuizId());

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

    public List<QuizSubmission> getAttemptHistory(UUID userId, UUID quizId) {
        return quizAttemptDAO.findAttemptsByStudent(userId, quizId);
    }
}
