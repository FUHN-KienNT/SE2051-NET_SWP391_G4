package com.learnhub.dto;

import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Data Transfer Object dedicated exclusively to the Manager Dashboard (/manager/dashboard).
 * Encapsulates the 4 KPI metric cards, curriculum submission review queue,
 * unassigned course allocation queue, catalog table preview, and recent student enrollments.
 */
public class ManagerDashboardDTO implements Serializable {

    // ── Metric Cards (KPIs) ──────────────────────────────────────────────────
    private int totalCourses;
    private int publishedCourses;
    private int unpublishedCourses;
    private int pendingReviewsCount;
    private int unassignedCoursesCount;
    private long totalEnrollments;
    private double enrollmentGrowthPct;

    // ── Filter State ─────────────────────────────────────────────────────────
    private String dateRange = "month"; // "month" | "quarter" | "all"
    private String search = "";
    private String selectedCategory = "";

    // ── Action Queues ────────────────────────────────────────────────────────
    private List<PendingReviewItem> pendingReviews = new ArrayList<>();
    private List<Course> unassignedCourses = new ArrayList<>();

    // ── Course Catalog Table ─────────────────────────────────────────────────
    private List<Course> courses = new ArrayList<>();
    private int totalCatalogCourses;

    // ── Real-time Recent Registrations Feed ──────────────────────────────────
    private List<Registration> recentEnrollments = new ArrayList<>();

    // ── Lookup Reference Data ────────────────────────────────────────────────
    private List<User> instructors = new ArrayList<>();
    private List<Setting> categories = new ArrayList<>();

    /**
     * Inner helper class for items in the curriculum review queue.
     */
    public static class PendingReviewItem implements Serializable {
        private UUID courseId;
        private String courseTitle;
        private String categoryName;
        private String expertName;
        private int pendingLessonCount;

        /**
         * Creates an instance with the supplied values.
         */
        public PendingReviewItem() {}

        /**
         * Creates an instance with the supplied values.
         *
         * @param courseId the course id identifier
         * @param courseTitle the course title
         * @param categoryName the category name
         * @param expertName the expert name
         * @param pendingLessonCount the pending lesson count
         */
        public PendingReviewItem(UUID courseId, String courseTitle, String categoryName, String expertName, int pendingLessonCount) {
            this.courseId = courseId;
            this.courseTitle = courseTitle;
            this.categoryName = categoryName;
            this.expertName = expertName;
            this.pendingLessonCount = pendingLessonCount;
        }

        /**
         * Returns course id.
         *
         * @return the course id
         */
        public UUID getCourseId() { return courseId; }
        /**
         * Sets course id.
         *
         * @param courseId the course id identifier
         */
        public void setCourseId(UUID courseId) { this.courseId = courseId; }

        /**
         * Returns course title.
         *
         * @return the course title
         */
        public String getCourseTitle() { return courseTitle; }
        /**
         * Sets course title.
         *
         * @param courseTitle the course title
         */
        public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

        /**
         * Returns category name.
         *
         * @return the category name
         */
        public String getCategoryName() { return categoryName; }
        /**
         * Sets category name.
         *
         * @param categoryName the category name
         */
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

        /**
         * Returns expert name.
         *
         * @return the expert name
         */
        public String getExpertName() { return expertName; }
        /**
         * Sets expert name.
         *
         * @param expertName the expert name
         */
        public void setExpertName(String expertName) { this.expertName = expertName; }

        /**
         * Returns pending lesson count.
         *
         * @return the pending lesson count
         */
        public int getPendingLessonCount() { return pendingLessonCount; }
        /**
         * Sets pending lesson count.
         *
         * @param pendingLessonCount the pending lesson count
         */
        public void setPendingLessonCount(int pendingLessonCount) { this.pendingLessonCount = pendingLessonCount; }
    }

    /**
     * Creates an instance with the supplied values.
     */
    public ManagerDashboardDTO() {}

    // ── Getters and Setters ───────────────────────────────────────────────────

    /**
     * Returns total courses.
     *
     * @return the total courses
     */
    public int getTotalCourses() { return totalCourses; }
    /**
     * Sets total courses.
     *
     * @param totalCourses the total courses
     */
    public void setTotalCourses(int totalCourses) { this.totalCourses = totalCourses; }

    /**
     * Returns published courses.
     *
     * @return the published courses
     */
    public int getPublishedCourses() { return publishedCourses; }
    /**
     * Sets published courses.
     *
     * @param publishedCourses the published courses
     */
    public void setPublishedCourses(int publishedCourses) { this.publishedCourses = publishedCourses; }

    /**
     * Returns unpublished courses.
     *
     * @return the unpublished courses
     */
    public int getUnpublishedCourses() { return unpublishedCourses; }
    /**
     * Sets unpublished courses.
     *
     * @param unpublishedCourses the unpublished courses
     */
    public void setUnpublishedCourses(int unpublishedCourses) { this.unpublishedCourses = unpublishedCourses; }

    /**
     * Returns pending reviews count.
     *
     * @return the pending reviews count
     */
    public int getPendingReviewsCount() { return pendingReviewsCount; }
    /**
     * Sets pending reviews count.
     *
     * @param pendingReviewsCount the pending reviews count
     */
    public void setPendingReviewsCount(int pendingReviewsCount) { this.pendingReviewsCount = pendingReviewsCount; }

    /**
     * Returns unassigned courses count.
     *
     * @return the unassigned courses count
     */
    public int getUnassignedCoursesCount() { return unassignedCoursesCount; }
    /**
     * Sets unassigned courses count.
     *
     * @param unassignedCoursesCount the unassigned courses count
     */
    public void setUnassignedCoursesCount(int unassignedCoursesCount) { this.unassignedCoursesCount = unassignedCoursesCount; }

    /**
     * Returns total enrollments.
     *
     * @return the total enrollments
     */
    public long getTotalEnrollments() { return totalEnrollments; }
    /**
     * Sets total enrollments.
     *
     * @param totalEnrollments the total enrollments
     */
    public void setTotalEnrollments(long totalEnrollments) { this.totalEnrollments = totalEnrollments; }

    /**
     * Returns enrollment growth pct.
     *
     * @return the enrollment growth pct
     */
    public double getEnrollmentGrowthPct() { return enrollmentGrowthPct; }
    /**
     * Sets enrollment growth pct.
     *
     * @param enrollmentGrowthPct the enrollment growth pct
     */
    public void setEnrollmentGrowthPct(double enrollmentGrowthPct) { this.enrollmentGrowthPct = enrollmentGrowthPct; }

    /**
     * Returns date range.
     *
     * @return the date range
     */
    public String getDateRange() { return dateRange; }
    /**
     * Sets date range.
     *
     * @param dateRange the date range
     */
    public void setDateRange(String dateRange) { this.dateRange = dateRange; }

    /**
     * Returns search.
     *
     * @return the search
     */
    public String getSearch() { return search; }
    /**
     * Sets search.
     *
     * @param search the search
     */
    public void setSearch(String search) { this.search = search; }

    /**
     * Returns selected category.
     *
     * @return the selected category
     */
    public String getSelectedCategory() { return selectedCategory; }
    /**
     * Sets selected category.
     *
     * @param selectedCategory the selected category
     */
    public void setSelectedCategory(String selectedCategory) { this.selectedCategory = selectedCategory; }

    /**
     * Returns pending reviews.
     *
     * @return the pending reviews
     */
    public List<PendingReviewItem> getPendingReviews() { return pendingReviews; }
    /**
     * Sets pending reviews.
     *
     * @param pendingReviews the pending reviews
     */
    public void setPendingReviews(List<PendingReviewItem> pendingReviews) { this.pendingReviews = pendingReviews; }

    /**
     * Returns unassigned courses.
     *
     * @return the unassigned courses
     */
    public List<Course> getUnassignedCourses() { return unassignedCourses; }
    /**
     * Sets unassigned courses.
     *
     * @param unassignedCourses the unassigned courses
     */
    public void setUnassignedCourses(List<Course> unassignedCourses) { this.unassignedCourses = unassignedCourses; }

    /**
     * Returns courses.
     *
     * @return the courses
     */
    public List<Course> getCourses() { return courses; }
    /**
     * Sets courses.
     *
     * @param courses the courses
     */
    public void setCourses(List<Course> courses) { this.courses = courses; }

    /**
     * Returns total catalog courses.
     *
     * @return the total catalog courses
     */
    public int getTotalCatalogCourses() { return totalCatalogCourses; }
    /**
     * Sets total catalog courses.
     *
     * @param totalCatalogCourses the total catalog courses
     */
    public void setTotalCatalogCourses(int totalCatalogCourses) { this.totalCatalogCourses = totalCatalogCourses; }

    /**
     * Returns recent enrollments.
     *
     * @return the recent enrollments
     */
    public List<Registration> getRecentEnrollments() { return recentEnrollments; }
    /**
     * Sets recent enrollments.
     *
     * @param recentEnrollments the recent enrollments
     */
    public void setRecentEnrollments(List<Registration> recentEnrollments) { this.recentEnrollments = recentEnrollments; }

    /**
     * Returns instructors.
     *
     * @return the instructors
     */
    public List<User> getInstructors() { return instructors; }
    /**
     * Sets instructors.
     *
     * @param instructors the instructors
     */
    public void setInstructors(List<User> instructors) { this.instructors = instructors; }

    /**
     * Returns categories.
     *
     * @return the categories
     */
    public List<Setting> getCategories() { return categories; }
    /**
     * Sets categories.
     *
     * @param categories the categories
     */
    public void setCategories(List<Setting> categories) { this.categories = categories; }
}
