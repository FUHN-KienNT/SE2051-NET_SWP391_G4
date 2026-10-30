package com.learnhub.service;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertFalse;

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
}