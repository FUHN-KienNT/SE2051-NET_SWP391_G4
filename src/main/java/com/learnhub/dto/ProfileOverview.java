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

    /**
     * Creates an instance with the supplied values.
     *
     * @param courses the courses
     * @param totalLessons the total lessons
     * @param completedLessons the completed lessons
     * @param quizSubmissions the quiz submissions
     * @param passedQuizzes the passed quizzes
     * @param averageScore the average score
     * @param currentStreak the current streak
     * @param longestStreak the longest streak
     * @param activityWeeks the activity weeks
     */
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

    /**
     * Returns courses.
     *
     * @return the courses
     */
    public List<ContinueLearningDTO> getCourses() { return courses; }
    /**
     * Returns course count.
     *
     * @return the course count
     */
    public int getCourseCount() { return courses.size(); }
    /**
     * Returns total lessons.
     *
     * @return the total lessons
     */
    public int getTotalLessons() { return totalLessons; }
    /**
     * Returns completed lessons.
     *
     * @return the completed lessons
     */
    public int getCompletedLessons() { return completedLessons; }
    /**
     * Returns completion percent.
     *
     * @return the completion percent
     */
    public int getCompletionPercent() {
        return totalLessons == 0 ? 0 : (int) Math.round(100.0 * completedLessons / totalLessons);
    }
    /**
     * Returns quiz submissions.
     *
     * @return the quiz submissions
     */
    public int getQuizSubmissions() { return quizSubmissions; }
    /**
     * Returns passed quizzes.
     *
     * @return the passed quizzes
     */
    public int getPassedQuizzes() { return passedQuizzes; }
    /**
     * Returns average score.
     *
     * @return the average score
     */
    public BigDecimal getAverageScore() { return averageScore; }
    /**
     * Returns current streak.
     *
     * @return the current streak
     */
    public int getCurrentStreak() { return currentStreak; }
    /**
     * Returns longest streak.
     *
     * @return the longest streak
     */
    public int getLongestStreak() { return longestStreak; }
    /**
     * Returns activity weeks.
     *
     * @return the activity weeks
     */
    public List<ActivityWeek> getActivityWeeks() { return activityWeeks; }

    public static class ActivityWeek {
        private final String monthLabel;
        private final List<ActivityDay> days;

        /**
         * Creates an instance with the supplied values.
         *
         * @param monthLabel the month label
         * @param days the days
         */
        public ActivityWeek(String monthLabel, List<ActivityDay> days) {
            this.monthLabel = monthLabel;
            this.days = List.copyOf(days);
        }

        /**
         * Returns month label.
         *
         * @return the month label
         */
        public String getMonthLabel() { return monthLabel; }
        /**
         * Returns days.
         *
         * @return the days
         */
        public List<ActivityDay> getDays() { return days; }
    }

    public static class ActivityDay {
        private final LocalDate date;
        private final int count;
        private final boolean future;

        /**
         * Creates an instance with the supplied values.
         *
         * @param date the date
         * @param count the count
         * @param future the future
         */
        public ActivityDay(LocalDate date, int count, boolean future) {
            this.date = date;
            this.count = count;
            this.future = future;
        }

        /**
         * Returns date.
         *
         * @return the date
         */
        public LocalDate getDate() { return date; }
        /**
         * Returns count.
         *
         * @return the count
         */
        public int getCount() { return count; }
        /**
         * Checks whether future.
         *
         * @return true when the condition holds; false otherwise
         */
        public boolean isFuture() { return future; }
        /**
         * Returns level.
         *
         * @return the level
         */
        public int getLevel() {
            if (count <= 0) return 0;
            if (count == 1) return 1;
            if (count <= 3) return 2;
            if (count <= 6) return 3;
            return 4;
        }
    }
}
