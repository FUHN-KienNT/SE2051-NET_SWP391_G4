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

        public PendingReviewItem() {}

        public PendingReviewItem(UUID courseId, String courseTitle, String categoryName, String expertName, int pendingLessonCount) {
            this.courseId = courseId;
            this.courseTitle = courseTitle;
            this.categoryName = categoryName;
            this.expertName = expertName;
            this.pendingLessonCount = pendingLessonCount;
        }

        public UUID getCourseId() { return courseId; }
        public void setCourseId(UUID courseId) { this.courseId = courseId; }

        public String getCourseTitle() { return courseTitle; }
        public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

        public String getCategoryName() { return categoryName; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

        public String getExpertName() { return expertName; }
        public void setExpertName(String expertName) { this.expertName = expertName; }

        public int getPendingLessonCount() { return pendingLessonCount; }
        public void setPendingLessonCount(int pendingLessonCount) { this.pendingLessonCount = pendingLessonCount; }
    }

    public ManagerDashboardDTO() {}

    // ── Getters and Setters ───────────────────────────────────────────────────

    public int getTotalCourses() { return totalCourses; }
    public void setTotalCourses(int totalCourses) { this.totalCourses = totalCourses; }

    public int getPublishedCourses() { return publishedCourses; }
    public void setPublishedCourses(int publishedCourses) { this.publishedCourses = publishedCourses; }

    public int getUnpublishedCourses() { return unpublishedCourses; }
    public void setUnpublishedCourses(int unpublishedCourses) { this.unpublishedCourses = unpublishedCourses; }

    public int getPendingReviewsCount() { return pendingReviewsCount; }
    public void setPendingReviewsCount(int pendingReviewsCount) { this.pendingReviewsCount = pendingReviewsCount; }

    public int getUnassignedCoursesCount() { return unassignedCoursesCount; }
    public void setUnassignedCoursesCount(int unassignedCoursesCount) { this.unassignedCoursesCount = unassignedCoursesCount; }

    public long getTotalEnrollments() { return totalEnrollments; }
    public void setTotalEnrollments(long totalEnrollments) { this.totalEnrollments = totalEnrollments; }

    public double getEnrollmentGrowthPct() { return enrollmentGrowthPct; }
    public void setEnrollmentGrowthPct(double enrollmentGrowthPct) { this.enrollmentGrowthPct = enrollmentGrowthPct; }

    public String getDateRange() { return dateRange; }
    public void setDateRange(String dateRange) { this.dateRange = dateRange; }

    public String getSearch() { return search; }
    public void setSearch(String search) { this.search = search; }

    public String getSelectedCategory() { return selectedCategory; }
    public void setSelectedCategory(String selectedCategory) { this.selectedCategory = selectedCategory; }

    public List<PendingReviewItem> getPendingReviews() { return pendingReviews; }
    public void setPendingReviews(List<PendingReviewItem> pendingReviews) { this.pendingReviews = pendingReviews; }

    public List<Course> getUnassignedCourses() { return unassignedCourses; }
    public void setUnassignedCourses(List<Course> unassignedCourses) { this.unassignedCourses = unassignedCourses; }

    public List<Course> getCourses() { return courses; }
    public void setCourses(List<Course> courses) { this.courses = courses; }

    public int getTotalCatalogCourses() { return totalCatalogCourses; }
    public void setTotalCatalogCourses(int totalCatalogCourses) { this.totalCatalogCourses = totalCatalogCourses; }

    public List<Registration> getRecentEnrollments() { return recentEnrollments; }
    public void setRecentEnrollments(List<Registration> recentEnrollments) { this.recentEnrollments = recentEnrollments; }

    public List<User> getInstructors() { return instructors; }
    public void setInstructors(List<User> instructors) { this.instructors = instructors; }

    public List<Setting> getCategories() { return categories; }
    public void setCategories(List<Setting> categories) { this.categories = categories; }
}
