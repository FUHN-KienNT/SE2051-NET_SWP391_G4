package com.learnhub.service;

import com.learnhub.dao.QuizDAO;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class QuizManagementServiceTest {

    private final QuizManagementService service = new QuizManagementService();

    @Test
    void rejectsQuizTitleExceeding120Words() {
        StringBuilder longTitle = new StringBuilder();
        for (int i = 1; i <= 121; i++) {
            longTitle.append("word").append(i).append(" ");
        }

        boolean result = service.save(
                UUID.randomUUID(),
                null,
                UUID.randomUUID(),
                longTitle.toString(),
                30,
                new BigDecimal("5.0"),
                Collections.emptyList()
        );

        assertFalse(result, "Quiz with title exceeding 120 words should be rejected");
    }

    @Test
    void rejectsNullOrEmptyQuizTitle() {
        boolean resultNull = service.save(
                UUID.randomUUID(),
                null,
                UUID.randomUUID(),
                null,
                30,
                new BigDecimal("5.0"),
                Collections.emptyList()
        );
        assertFalse(resultNull);

        boolean resultEmpty = service.save(
                UUID.randomUUID(),
                null,
                UUID.randomUUID(),
                "   ",
                30,
                new BigDecimal("5.0"),
                Collections.emptyList()
        );
        assertFalse(resultEmpty);
    }

    @Test
    @DisplayName("Thời gian làm bài không được để trống (không giới hạn) và phải trong khoảng 1-600 phút")
    void validatesTimeLimitRange1To600() {
        QuizDAO stubDao = new QuizDAO() {
            @Override
            public boolean saveWithQuestions(
                    UUID expertId,
                    UUID quizId,
                    UUID moduleId,
                    String title,
                    Integer timeLimit,
                    BigDecimal passScore,
                    String status,
                    String imageUrl,
                    List<UUID> questionIds) {
                return true;
            }
        };
        QuizManagementService svc = new QuizManagementService(stubDao);
        UUID expertId = UUID.randomUUID();
        UUID moduleId = UUID.randomUUID();
        BigDecimal passScore = new BigDecimal("5.0");

        assertFalse(svc.save(expertId, null, moduleId, "Quiz Test", null, passScore, Collections.emptyList()),
                "Không được phép để thời gian làm bài null (không giới hạn)");
        assertFalse(svc.save(expertId, null, moduleId, "Quiz Test", 0, passScore, Collections.emptyList()),
                "Thời gian làm bài < 1 phút phải bị từ chối");
        assertFalse(svc.save(expertId, null, moduleId, "Quiz Test", -10, passScore, Collections.emptyList()),
                "Thời gian làm bài âm phải bị từ chối");
        assertFalse(svc.save(expertId, null, moduleId, "Quiz Test", 601, passScore, Collections.emptyList()),
                "Thời gian làm bài > 600 phút phải bị từ chối");

        assertTrue(svc.save(expertId, null, moduleId, "Quiz Test", 1, passScore, Collections.emptyList()));
        assertTrue(svc.save(expertId, null, moduleId, "Quiz Test", 45, passScore, Collections.emptyList()));
        assertTrue(svc.save(expertId, null, moduleId, "Quiz Test", 600, passScore, Collections.emptyList()));
    }

    @Test
    @DisplayName("Quiz đã được dùng trong course / module thì KHÔNG THỂ xóa vĩnh viễn")
    void cannotDeleteUsedQuiz() {
        UUID expertId = UUID.randomUUID();
        UUID usedQuizId = UUID.randomUUID();

        QuizDAO stubDao = new QuizDAO() {
            @Override
            public boolean belongsToExpert(UUID quizId, UUID expId) {
                return usedQuizId.equals(quizId) && expertId.equals(expId);
            }

            @Override
            public boolean isUsed(UUID quizId) {
                return usedQuizId.equals(quizId);
            }

            @Override
            public boolean delete(UUID id) {
                return !isUsed(id);
            }
        };

        QuizManagementService svc = new QuizManagementService(stubDao);
        assertTrue(svc.isUsed(usedQuizId));
        assertFalse(svc.delete(expertId, usedQuizId),
                "Quiz đã được sử dụng trong course/module không được phép xóa vĩnh viễn");
    }

    @Test
    @DisplayName("Quiz chưa được dùng ở course hay module nào thì CÓ THỂ xóa vĩnh viễn")
    void canDeleteUnusedQuiz() {
        UUID expertId = UUID.randomUUID();
        UUID unusedQuizId = UUID.randomUUID();

        QuizDAO stubDao = new QuizDAO() {
            @Override
            public boolean belongsToExpert(UUID quizId, UUID expId) {
                return unusedQuizId.equals(quizId) && expertId.equals(expId);
            }

            @Override
            public boolean isUsed(UUID quizId) {
                return false;
            }

            @Override
            public boolean delete(UUID id) {
                return unusedQuizId.equals(id);
            }
        };

        QuizManagementService svc = new QuizManagementService(stubDao);
        assertFalse(svc.isUsed(unusedQuizId));
        assertTrue(svc.delete(expertId, unusedQuizId),
                "Quiz chưa được dùng phải cho phép xóa vĩnh viễn");
        assertFalse(svc.delete(UUID.randomUUID(), unusedQuizId),
                "Expert khác không được phép xóa quiz không thuộc quyền sở hữu");
    }
}
