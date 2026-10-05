package com.learnhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class ProfileOverview {
    private final List<ContinueLearningDTO> courses;
    private final int totalLessons;
    private final int completedLessons;
    private final int quizSubmissions;
    private final int passedQuizzes;
    private final BigDecimal averageScore;
    private final int currentStreak;
    private final int longestStreak;
    private final List<ActivityWeek> activityWeeks;

    public ProfileOverview(List<ContinueLearningDTO> courses, int totalLessons, int completedLessons,
                           int quizSubmissions, int passedQuizzes, BigDecimal averageScore,
                           int currentStreak, int longestStreak, List<ActivityWeek> activityWeeks) {
        this.courses = List.copyOf(courses);
        this.totalLessons = totalLessons;
        this.completedLessons = completedLessons;
        this.quizSubmissions = quizSubmissions;
        this.passedQuizzes = passedQuizzes;
        this.averageScore = averageScore;
        this.currentStreak = currentStreak;
        this.longestStreak = longestStreak;
        this.activityWeeks = List.copyOf(activityWeeks);
    }

    public List<ContinueLearningDTO> getCourses() { return courses; }
    public int getCourseCount() { return courses.size(); }
    public int getTotalLessons() { return totalLessons; }
    public int getCompletedLessons() { return completedLessons; }
    public int getCompletionPercent() {
        return totalLessons == 0 ? 0 : (int) Math.round(100.0 * completedLessons / totalLessons);
    }
    public int getQuizSubmissions() { return quizSubmissions; }
    public int getPassedQuizzes() { return passedQuizzes; }
    public BigDecimal getAverageScore() { return averageScore; }
    public int getCurrentStreak() { return currentStreak; }
    public int getLongestStreak() { return longestStreak; }
    public List<ActivityWeek> getActivityWeeks() { return activityWeeks; }

    public static class ActivityWeek {
        private final String monthLabel;
        private final List<ActivityDay> days;

        public ActivityWeek(String monthLabel, List<ActivityDay> days) {
            this.monthLabel = monthLabel;
            this.days = List.copyOf(days);
        }

        public String getMonthLabel() { return monthLabel; }
        public List<ActivityDay> getDays() { return days; }
    }

    public static class ActivityDay {
        private final LocalDate date;
        private final int count;
        private final boolean future;

        public ActivityDay(LocalDate date, int count, boolean future) {
            this.date = date;
            this.count = count;
            this.future = future;
        }

        public LocalDate getDate() { return date; }
        public int getCount() { return count; }
        public boolean isFuture() { return future; }
        public int getLevel() {
            if (count <= 0) return 0;
            if (count == 1) return 1;
            if (count <= 3) return 2;
            if (count <= 6) return 3;
            return 4;
        }
    }
}
