package com.learnhub.service;

import com.learnhub.dao.LearningProcessDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.LessonDTO;
import com.learnhub.dto.CourseDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.LearningProcess;
import com.learnhub.entity.Lesson;
import com.learnhub.entity.Registration;

import java.math.BigDecimal;
import java.util.*;
import java.sql.Connection;
import java.sql.SQLException;
import com.learnhub.util.DbConnection;

public class LearningProcessService {

    private final LearningProcessDAO learningProcessDAO;
    private final RegistrationDAO registrationDAO;
    private final LessonDAO lessonDAO;
    private final CourseService courseService = new CourseService();
    public record StudentDashboardData(
            List<ContinueLearningDTO> myCourses,
            List<CourseDTO> availableCourses, String sort) {}

    public LearningProcessService() {
        this.learningProcessDAO = new LearningProcessDAO();
        this.registrationDAO = new RegistrationDAO();
        this.lessonDAO = new LessonDAO();
    }

    public LearningProcessService(
            LearningProcessDAO learningProcessDAO,
            RegistrationDAO registrationDAO,
            LessonDAO lessonDAO
    ) {
        this.learningProcessDAO = learningProcessDAO;
        this.registrationDAO = registrationDAO;
        this.lessonDAO = lessonDAO;
    }

    public ContinueLearningDTO getContinueLearning(UUID userId) {
        ContinueLearningDTO suggestion = learningProcessDAO.findContinueLearning(userId);
        if (suggestion != null) {
            getStudentCourses(userId).stream()
                    .filter(course -> course.getCourseId().equals(suggestion.getCourseId()))
                    .findFirst().ifPresent(course -> {
                        suggestion.setProgressPercent(course.getProgressPercent());
                        suggestion.setLessonCount(course.getLessonCount());
                        suggestion.setCompletedLessonCount(course.getCompletedLessonCount());
                    });
        }
        return suggestion;
    }

    public Registration findRegistration(UUID userId, UUID courseId) {
        return registrationDAO.findByUserAndCourse(userId, courseId);
    }

    public List<ContinueLearningDTO> getStudentCourses(UUID userId) {
        List<ContinueLearningDTO> courses =
                learningProcessDAO.findStudentCourses(userId);
        for (ContinueLearningDTO course : courses) {
            course.setProgressPercent(calculateProgressPercent(
                    course.getCompletedLessonCount(), course.getLessonCount()));
        }
        return courses;
    }

    private int calculateProgressPercent(int completed, int total) {
        return total <= 0 ? 0
                : Math.min(100, (int) Math.round(100.0 * completed / total));
    }

    public int getProgressPercent(UUID registrationId) {
        int completed = learningProcessDAO.countCompletedLessons(registrationId);
        int total = learningProcessDAO.countTotalLessons(registrationId);
        return calculateProgressPercent(completed, total);
    }

    public Map<String, String> getLessonStatuses(UUID registrationId) {
        return learningProcessDAO.findLessonStatuses(registrationId);
    }

    public int getCompletedCount(UUID registrationId, List<Lesson> orderedLessons) {
        Map<String, String> statuses = getLessonStatuses(registrationId);
        return (int) orderedLessons.stream()
                .filter(l -> "completed".equals(
                        statuses.get(l.getId().toString())))
                .count();
    }

    public StudentDashboardData buildStudentDashboard(
            List<ContinueLearningDTO> enrolled, String search, UUID categoryId, String sort) {
        String keyword = search.toLowerCase(Locale.ROOT);
        if (!Set.of(
                "newest", "title_asc", "price_asc", "price_desc"
        ).contains(sort == null ? "" : sort)) {
            sort = "newest";
        }

        Set<UUID> enrolledIds = new HashSet<>();

        List<ContinueLearningDTO> myCourses = new ArrayList<>();

        for (ContinueLearningDTO course : enrolled) {
            enrolledIds.add(course.getCourseId());

            if (course.getCourseTitle()
                    .toLowerCase(Locale.ROOT)
                    .contains(keyword)) {
                myCourses.add(course);
            }
        }

        int count =
                courseService.countPublicCourses(search, categoryId);

        List<CourseDTO> availableCourses = new ArrayList<>();

        List<CourseDTO> publishedCourses =
                courseService.searchPublicCourses(
                        search,
                        categoryId,
                        1,
                        Math.max(1, count)
                );

        for (CourseDTO course : publishedCourses) {
            if (!enrolledIds.contains(course.getId())
                    && course.getTitle()
                    .toLowerCase(Locale.ROOT)
                    .contains(keyword)) {
                availableCourses.add(course);
            }
        }

        Comparator<CourseDTO> priceOrder = Comparator.comparing(course ->
                course.getPrice() == null
                        ? BigDecimal.ZERO
                        : course.getPrice()
        );

        if ("title_asc".equals(sort)) {
            availableCourses.sort(
                    Comparator.comparing(
                            CourseDTO::getTitle,
                            String.CASE_INSENSITIVE_ORDER
                    ).thenComparing(CourseDTO::getId)
            );
        } else if ("price_asc".equals(sort)) {
            availableCourses.sort(
                    priceOrder.thenComparing(CourseDTO::getId)
            );
        } else if ("price_desc".equals(sort)) {
            availableCourses.sort(
                    priceOrder.reversed().thenComparing(CourseDTO::getId)
            );
        }
        return new StudentDashboardData(myCourses, availableCourses, sort);
    }

    public ContinueLearningDTO resolveContinueLesson(
            List<ContinueLearningDTO> enrolled, String courseIdValue, String savedLessonValue) {
        ContinueLearningDTO selected = enrolled.stream()
                .filter(course ->
                        course.getCourseId().toString().equals(courseIdValue))
                .findFirst()
                .orElse(null);

        if (selected == null) {
            throw new SecurityException("Course access denied.");
        }

        if (selected.getLessonId() == null) {
            return selected;
        }

        UUID targetLessonId = selected.getLessonId();

        if (savedLessonValue != null && !savedLessonValue.isBlank()) {
            try {
                UUID candidate = UUID.fromString(savedLessonValue);

                Course curriculum =
                        courseService.getPublishedCourseCurriculum(
                                selected.getCourseId()
                        );

                boolean belongsToCourse = curriculum != null
                        && curriculum.getModules().stream()
                        .flatMap(module ->
                                module.getLessons().stream())
                        .anyMatch(lesson ->
                                lesson.getId().equals(candidate));

                if (belongsToCourse) {
                    targetLessonId = candidate;
                }
            } catch (IllegalArgumentException ignored) {
                // Invalid browser state uses the first lesson.
            }
        }
        selected.setLessonId(targetLessonId);
        return selected;
    }

    public ContinueLearningDTO findEnrolledCourse(UUID userId, UUID courseId) {
        return getStudentCourses(userId).stream()
                .filter(course -> courseId.equals(course.getCourseId()))
                .findFirst().orElse(null);
    }

    public LessonDTO getLessonForStudent(
            UUID lessonId,
            UUID registrationId
    ) {
        Lesson lesson = lessonDAO.findById(lessonId);
        if (lesson == null || !"published".equals(lesson.getPublicationStatus())) return null;

        LessonDTO dto = new LessonDTO(
                lesson.getId(),
                lesson.getModuleId(),
                lesson.getTitle(),
                lesson.getContent(),
                lesson.getOrderIndex()
        );

        dto.setMaterialUrl(lesson.getMaterialUrl());
        dto.setDurationMinutes(lesson.getDurationMinutes());
        dto.setPublicationStatus(lesson.getPublicationStatus());

        LearningProcess process =
                learningProcessDAO.findByRegistrationAndLesson(
                        registrationId, lessonId
                );

        dto.setStatus(
                process == null ? "in_progress" : process.getStatus()
        );

        if (process == null) {
            LearningProcess newProcess = new LearningProcess(
                    UUID.randomUUID(),
                    registrationId,
                    lessonId,
                    "in_progress"
            );

            learningProcessDAO.save(newProcess);
        }

        return dto;
    }

    public boolean isAccessibleRegistration(Registration registration, Course course) {
        if (registration == null || course == null) return false;
        boolean active =
                "enrolled".equalsIgnoreCase(registration.getStatus())
                        || "completed".equalsIgnoreCase(registration.getStatus());

        boolean paymentAllowed =
                course.getPrice() == null
                        || course.getPrice().compareTo(BigDecimal.ZERO) <= 0
                        || "paid".equalsIgnoreCase(registration.getPaymentStatus());

        return active && paymentAllowed;
    }

    public boolean canStudy(Registration registration, Course course, UUID lessonId) {
        if (registration == null || course == null) return false;
        if (!isAccessibleRegistration(registration, course)) return false;
        return course.getModules().stream()
                .flatMap(module -> module.getLessons().stream())
                .anyMatch(lesson -> lesson.getId().equals(lessonId)
                        && "published".equals(lesson.getPublicationStatus()));
    }

    public void markLessonComplete(UUID registrationId, UUID lessonId) {
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                registrationDAO.lockRegistration(conn, registrationId);
                learningProcessDAO.completeLesson(conn, registrationId, lessonId);
                var counts = learningProcessDAO.readProgressCounts(conn, registrationId);
                int percent = calculateProgressPercent(counts.completed(), counts.total());
                registrationDAO.updateProgressPercent(conn, registrationId, percent);
                conn.commit();
            } catch (SQLException | RuntimeException e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
        } catch (SQLException | RuntimeException e) {
            throw new IllegalStateException("Cannot save learning progress.", e);
        }
    }
}
