package com.learnhub.service;

import com.learnhub.dao.ProfileDAO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.ProfileOverview;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ProfileServiceTest {
    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    @Test
    void summarizesCoursesQuizzesAndStreaksWithoutCountingFutureActivity() {
        LocalDate today = LocalDate.now(ZONE);
        Map<LocalDate, Integer> activity = Map.of(
                today.minusDays(10), 1,
                today.minusDays(9), 2,
                today.minusDays(8), 1,
                today.minusDays(2), 1,
                today.minusDays(1), 3,
                today.plusDays(1), 1);
        ContinueLearningDTO course = new ContinueLearningDTO();
        course.setLessonCount(12);
        course.setCompletedLessonCount(5);

        LearningProcessService learning = new LearningProcessService() {
            @Override
            public List<ContinueLearningDTO> getStudentCourses(UUID userId) {
                return List.of(course);
            }
        };
        ProfileDAO dao = new ProfileDAO() {
            @Override
            public QuizSummary findQuizSummary(UUID userId) {
                return new QuizSummary(7, 4, new BigDecimal("8.2"));
            }

            @Override
            public Map<LocalDate, Integer> findDailyActivity(UUID userId) {
                return activity;
            }
        };

        ProfileOverview overview = new ProfileService(learning, dao).getOverview(UUID.randomUUID());
        assertEquals(1, overview.getCourseCount());
        assertEquals(5, overview.getCompletedLessons());
        assertEquals(12, overview.getTotalLessons());
        assertEquals(7, overview.getQuizSubmissions());
        assertEquals(4, overview.getPassedQuizzes());
        assertEquals(2, overview.getCurrentStreak());
        assertEquals(3, overview.getLongestStreak());
        assertEquals(52, overview.getActivityWeeks().size());
        assertTrue(overview.getActivityWeeks().stream().flatMap(week -> week.getDays().stream())
                .filter(day -> day.getDate().isAfter(today))
                .allMatch(day -> day.isFuture() && day.getCount() == 0));
    }

    @Test
    void emptyActivityHasNoStreak() {
        LearningProcessService learning = new LearningProcessService() {
            @Override
            public List<ContinueLearningDTO> getStudentCourses(UUID userId) {
                return List.of();
            }
        };
        ProfileDAO dao = new ProfileDAO() {
            @Override
            public QuizSummary findQuizSummary(UUID userId) {
                return new QuizSummary(0, 0, null);
            }

            @Override
            public Map<LocalDate, Integer> findDailyActivity(UUID userId) {
                return Map.of();
            }
        };
        ProfileOverview overview = new ProfileService(learning, dao).getOverview(UUID.randomUUID());
        assertEquals(0, overview.getCurrentStreak());
        assertEquals(0, overview.getLongestStreak());
        assertEquals(0, overview.getCompletionPercent());
    }
}
