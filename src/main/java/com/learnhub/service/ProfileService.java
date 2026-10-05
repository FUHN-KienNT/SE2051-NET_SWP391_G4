package com.learnhub.service;

import com.learnhub.dao.ProfileDAO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.ProfileOverview;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

public class ProfileService {
    private static final ZoneId LEARNING_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter MONTH_FORMAT = DateTimeFormatter.ofPattern("MMM", Locale.ENGLISH);
    private final LearningProcessService learningService;
    private final ProfileDAO profileDAO;

    public ProfileService() {
        this(new LearningProcessService(), new ProfileDAO());
    }

    public ProfileService(LearningProcessService learningService, ProfileDAO profileDAO) {
        this.learningService = learningService;
        this.profileDAO = profileDAO;
    }

    public ProfileOverview getOverview(UUID userId) {
        List<ContinueLearningDTO> courses = learningService.getStudentCourses(userId);
        int totalLessons = courses.stream().mapToInt(ContinueLearningDTO::getLessonCount).sum();
        int completedLessons = courses.stream().mapToInt(ContinueLearningDTO::getCompletedLessonCount).sum();
        ProfileDAO.QuizSummary quizzes = profileDAO.findQuizSummary(userId);
        LocalDate today = LocalDate.now(LEARNING_ZONE);
        Map<LocalDate, Integer> activity = new TreeMap<>(profileDAO.findDailyActivity(userId));
        activity.keySet().removeIf(day -> day.isAfter(today));

        int longest = 0;
        int run = 0;
        LocalDate previous = null;
        for (LocalDate day : activity.keySet()) {
            run = previous != null && day.equals(previous.plusDays(1)) ? run + 1 : 1;
            longest = Math.max(longest, run);
            previous = day;
        }
        int current = previous != null
                && (previous.equals(today) || previous.equals(today.minusDays(1))) ? run : 0;

        LocalDate firstSunday = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY))
                .minusWeeks(51);
        List<ProfileOverview.ActivityWeek> weeks = new ArrayList<>(52);
        for (int week = 0; week < 52; week++) {
            LocalDate firstDay = firstSunday.plusWeeks(week);
            String monthLabel = week == 0 ? firstDay.format(MONTH_FORMAT) : "";
            List<ProfileOverview.ActivityDay> days = new ArrayList<>(7);
            for (int weekday = 0; weekday < 7; weekday++) {
                LocalDate day = firstDay.plusDays(weekday);
                if (day.getDayOfMonth() == 1) monthLabel = day.format(MONTH_FORMAT);
                days.add(new ProfileOverview.ActivityDay(day, activity.getOrDefault(day, 0),
                        day.isAfter(today)));
            }
            weeks.add(new ProfileOverview.ActivityWeek(monthLabel, days));
        }
        return new ProfileOverview(courses, totalLessons, completedLessons, quizzes.submissions(),
                quizzes.passed(), quizzes.averageScore(), current, longest, weeks);
    }
}
