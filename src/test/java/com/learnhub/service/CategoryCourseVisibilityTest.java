package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.SettingDAO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Setting;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class CategoryCourseVisibilityTest {

    @Test
    void courseEntityTracksCategoryStatus() {
        Course course = new Course();
        assertNull(course.getCategoryStatus());

        course.setCategoryStatus(true);
        assertTrue(course.getCategoryStatus());

        course.setCategoryStatus(false);
        assertFalse(course.getCategoryStatus());
    }

    @Test
    void courseDaoCountsByCategoryAccurately() {
        CourseDAO courseDAO = new CourseDAO();
        Map<UUID, Integer> grouped = courseDAO.countCoursesGroupedByCategory();
        assertNotNull(grouped);

        int count = courseDAO.countCoursesByCategoryId(null);
        assertEquals(0, count);

        // For non-existent category
        int nonExistentCount = courseDAO.countCoursesByCategoryId(UUID.randomUUID());
        assertEquals(0, nonExistentCount);
    }

    @Test
    void publishedCoursesExcludeInactiveCategories() {
        CourseDAO courseDAO = new CourseDAO();
        List<Course> published = courseDAO.findPublishedCourses(null, null, 0, 100);
        assertNotNull(published);
        for (Course c : published) {
            if (c.getCategoryId() != null && c.getCategoryStatus() != null) {
                assertTrue(c.getCategoryStatus(), "Published courses must belong to active categories");
            }
        }
    }
}
