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

    public boolean isModuleVisible(Quiz quiz) {
        if (quiz == null) return false;
        var module = new com.learnhub.dao.ModuleDAO().findById(quiz.getModuleId());
        return module != null && !module.isHidden();
    }

    public QuizSubmission startQuizAttempt(UUID userId, UUID quizId) {
        Quiz quiz = quizDAO.findById(quizId);
        if (quiz == null || !quiz.isPublished()) throw new SecurityException("Quiz is not available.");
        var module = new com.learnhub.dao.ModuleDAO().findById(quiz.getModuleId());
        var learning = new LearningProcessService();
        var course = module == null || module.isHidden() ? null : new CourseService().getPublishedCourseCurriculum(module.getCourseId());
        var registration = course == null ? null : learning.findRegistration(userId, course.getId());
        if (!learning.isAccessibleRegistration(registration, course)) throw new SecurityException("Course access denied.");
        QuizSubmission attempt = new QuizSubmission();
        attempt.setId(UUID.randomUUID());
        attempt.setQuizId(quizId);
        attempt.setUserId(userId);
        attempt.setScore(null);
        attempt.setPassStatus(null);
        if (!quizAttemptDAO.insertAttempt(attempt)) throw new IllegalStateException("Cannot start quiz attempt.");
        return attempt;
    }

    public QuizAttemptDTO submitQuizAttempt(
            UUID submissionId,
            Map<UUID, List<UUID>> selectedAnswers,
            Map<UUID, String> textAnswers) {

        QuizSubmission attempt = quizAttemptDAO.findById(submissionId);
        if (attempt == null) return null;

        Quiz quiz = quizDAO.findById(attempt.getQuizId());
        BigDecimal passScoreThreshold = (quiz != null && quiz.getPassScore() != null)
                ? quiz.getPassScore() : BigDecimal.valueOf(5.0);

        Map<UUID, List<UUID>> mergedAnswers = new HashMap<>();
        if (selectedAnswers != null) {
            mergedAnswers.putAll(selectedAnswers);
        }

        List<Question> questions = questionDAO.findQuestionsByQuizId(attempt.getQuizId());
        for (Question q : questions) {
            if (q.isFillInBlank()) {
                String userText = textAnswers != null ? textAnswers.get(q.getId()) : null;
                if (userText != null && !userText.trim().isEmpty()) {
                    String normUserText = userText.trim().toLowerCase();
                    List<com.learnhub.entity.QuestionOption> options = questionDAO.findOptionsByQuestionId(q.getId());
                    for (com.learnhub.entity.QuestionOption opt : options) {
                        String optText = opt.getOptionText() != null ? opt.getOptionText().trim().toLowerCase() : "";
                        if (!optText.isEmpty() && (normUserText.equals(optText) || normUserText.contains(optText))) {
                            mergedAnswers.put(q.getId(), List.of(opt.getId()));
                            break;
                        }
                    }
                }
            }
        }

        answerDAO.saveAnswers(submissionId, mergedAnswers);
        int correctAnswers = countCorrectAnswers(questions, mergedAnswers, textAnswers);
        BigDecimal score = calculateScore(attempt.getQuizId(), mergedAnswers, textAnswers);
        boolean passed = score.compareTo(passScoreThreshold) >= 0;

        if (!quizAttemptDAO.updateScore(submissionId, score, passed)) {
            throw new IllegalStateException("Cannot save quiz result.");
        }
        quizAttemptDAO.updateBestFlag(submissionId);
        if (passed) new LearningProcessService().completeQuizLessons(attempt.getUserId(), attempt.getQuizId());

        QuizAttemptDTO dto = new QuizAttemptDTO();
        dto.setAttemptId(submissionId);
        dto.setQuizId(attempt.getQuizId());
        dto.setQuizTitle(quiz != null ? quiz.getTitle() : "Quiz");
        dto.setScore(score);
        dto.setPassed(passed);
        dto.setTotalQuestions(questions.size());
        dto.setCorrectAnswers(correctAnswers);
        dto.setSelectedAnswers(mergedAnswers);
        return dto;
    }

    public QuizSubmission getAttempt(UUID attemptId) {
        return quizAttemptDAO.findById(attemptId);
    }

    public List<QuizSubmission> getAttemptHistory(UUID userId, UUID quizId) {
        return quizAttemptDAO.findAttemptsByStudent(userId, quizId);
    }

    public int countCorrectAnswers(
            List<Question> questions,
            Map<UUID, List<UUID>> selectedAnswers,
            Map<UUID, String> textAnswers) {

        if (questions == null || questions.isEmpty()) {
            return 0;
        }

        int correctCount = 0;
        for (Question q : questions) {
            if (q.isFillInBlank()) {
                String userText = textAnswers != null ? textAnswers.get(q.getId()) : null;
                boolean isCorrect = false;
                List<com.learnhub.entity.QuestionOption> options = questionDAO.findOptionsByQuestionId(q.getId());
                if (userText != null && !userText.trim().isEmpty()) {
                    String normUserText = userText.trim().toLowerCase();
                    for (com.learnhub.entity.QuestionOption opt : options) {
                        String optText = opt.getOptionText() != null ? opt.getOptionText().trim().toLowerCase() : "";
                        if (!optText.isEmpty() && (normUserText.equals(optText))) {
                            isCorrect = true;
                            break;
                        }
                    }
                }
                if (isCorrect) {
                    correctCount++;
                }
            } else {
                List<UUID> selected = selectedAnswers != null ? selectedAnswers.get(q.getId()) : Collections.emptyList();
                if (isAllOrNothingCorrect(q.getId(), selected)) {
                    correctCount++;
                }
            }
        }
        return correctCount;
    }

    public BigDecimal calculateScore(
            UUID quizId,
            Map<UUID, List<UUID>> selectedAnswers,
            Map<UUID, String> textAnswers) {

        List<Question> questions = questionDAO.findQuestionsByQuizId(quizId);
        if (questions == null || questions.isEmpty()) {
            return BigDecimal.ZERO;
        }

        int totalQuestions = questions.size();
        int correctCount = countCorrectAnswers(questions, selectedAnswers, textAnswers);
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
}
