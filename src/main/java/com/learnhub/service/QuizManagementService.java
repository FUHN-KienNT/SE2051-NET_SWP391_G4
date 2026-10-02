package com.learnhub.service;

import com.learnhub.dao.QuizDAO;
import com.learnhub.dao.QuizQuestionDAO;
import com.learnhub.entity.Quiz;

import java.util.List;
import java.util.UUID;

/** Business layer for Expert Quiz List/Detail. */
public class QuizManagementService {
    private final QuizDAO quizDAO = new QuizDAO();
    private final QuizQuestionDAO qqDAO = new QuizQuestionDAO();

    public List<Quiz> findByExpert(UUID expertId, String keyword, UUID moduleId) {
        return quizDAO.findByExpertId(expertId, keyword, moduleId);
    }

    public List<Quiz> findByExpert(UUID expertId, String keyword, UUID moduleId, UUID courseId) {
        return quizDAO.findByExpertId(expertId, keyword, moduleId, courseId);
    }

    public Quiz get(UUID id) {
        return quizDAO.findById(id);
    }

    public List<UUID> getQuestionIds(UUID quizId) {
        return qqDAO.findQuestionIds(quizId);
    }

    public boolean save(UUID expertId, UUID id, UUID moduleId, String title,
                        Integer timeLimit, java.math.BigDecimal passScore, List<UUID> questionIds) {
        if (expertId == null || moduleId == null || title == null || title.trim().isEmpty()) return false;
        if (!quizDAO.moduleBelongsToExpert(moduleId, expertId)) return false;
        if (timeLimit != null && (timeLimit < 1 || timeLimit > 600)) return false;
        if (passScore == null || passScore.compareTo(java.math.BigDecimal.ZERO) < 0 || passScore.compareTo(java.math.BigDecimal.TEN) > 0) return false;

        Quiz q = new Quiz();
        q.setId(id != null ? id : UUID.randomUUID());
        q.setModuleId(moduleId);
        q.setTitle(title.trim());
        q.setTimeLimit(timeLimit);
        q.setPassScore(passScore);

        boolean ok = id == null
                ? quizDAO.insert(q)
                : quizDAO.belongsToExpert(id, expertId) && quizDAO.update(q);

        if (!ok) return false;
        return qqDAO.replaceQuestions(q.getId(), questionIds);
    }

    public boolean delete(UUID expertId, UUID id) {
        return id != null && quizDAO.belongsToExpert(id, expertId) && quizDAO.delete(id);
    }
}
