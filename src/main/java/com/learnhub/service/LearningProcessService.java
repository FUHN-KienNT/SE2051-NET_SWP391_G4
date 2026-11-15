package com.learnhub.service;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.LearningProcessDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.LessonDTO;
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
            String sort, String status, int totalCourses, long completedCourses, long ongoingCourses) {}

    /**
     * Creates an instance with the supplied values.
     */
    public LearningProcessService() {
        this.learningProcessDAO = new LearningProcessDAO();
        this.registrationDAO = new RegistrationDAO();
        this.lessonDAO = new LessonDAO();
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param learningProcessDAO the learning process dao
     * @param registrationDAO the registration dao
     * @param lessonDAO the lesson dao
     */
    public LearningProcessService(
            LearningProcessDAO learningProcessDAO,
            RegistrationDAO registrationDAO,
            LessonDAO lessonDAO
    ) {
        this.learningProcessDAO = learningProcessDAO;
        this.registrationDAO = registrationDAO;
        this.lessonDAO = lessonDAO;
    }

    /**
     * Returns continue learning.
     *
     * @param userId the user id identifier
     * @return the continue learning
     */
    public ContinueLearningDTO getContinueLearning(UUID userId) {
        ContinueLearningDTO suggestion = learningProcessDAO.findContinueLearning(userId);
        if (suggestion != null) {
            ContinueLearningDTO course = findEnrolledCourse(userId, suggestion.getCourseId());
            if (course != null) {
                suggestion.setProgressPercent(course.getProgressPercent());
                suggestion.setLessonCount(course.getLessonCount());
                suggestion.setCompletedLessonCount(course.getCompletedLessonCount());
            }
        }
        return suggestion;
    }

    /**
     * Finds registration.
     *
     * @param userId the user id identifier
     * @param courseId the course id identifier
     * @return the matching registration, if present
     */
    public Registration findRegistration(UUID userId, UUID courseId) {
        return registrationDAO.findByUserAndCourse(userId, courseId);
    }

    /**
     * Returns student courses.
     *
     * @param userId the user id identifier
     * @return the student courses
     */
    public List<ContinueLearningDTO> getStudentCourses(UUID userId) {
        List<ContinueLearningDTO> courses =
                learningProcessDAO.findStudentCourses(userId);
        for (ContinueLearningDTO course : courses) {
            course.setProgressPercent(calculateProgressPercent(
                    course.getCompletedLessonCount(), course.getLessonCount()));
        }
        return courses;
    }

    /**
     * Checks whether course completed.
     *
     * @param course the course
     * @return true when the condition holds; false otherwise
     */
    public boolean isCourseCompleted(ContinueLearningDTO course) {
        return course.getLessonCount() > 0
                && course.getCompletedLessonCount() == course.getLessonCount();
    }

    /**
     * Calculate progress percent.
     *
     * @param completed the completed
     * @param total the total
     * @return the result of calculate progress percent
     */
    private int calculateProgressPercent(int completed, int total) {
        return total <= 0 ? 0
                : Math.min(100, (int) Math.round(100.0 * completed / total));
    }

    /**
     * Returns progress percent.
     *
     * @param registrationId the registration id identifier
     * @return the progress percent
     */
    public int getProgressPercent(UUID registrationId) {
        int completed = learningProcessDAO.countCompletedLessons(registrationId);
        int total = learningProcessDAO.countTotalLessons(registrationId);
        return calculateProgressPercent(completed, total);
    }

    /**
     * Returns lesson statuses.
     *
     * @param registrationId the registration id identifier
     * @return the lesson statuses
     */
    public Map<String, String> getLessonStatuses(UUID registrationId) {
        return learningProcessDAO.findLessonStatuses(registrationId);
    }

    /**
     * Returns completed count.
     *
     * @param registrationId the registration id identifier
     * @param orderedLessons the ordered lessons
     * @return the completed count
     */
    public int getCompletedCount(UUID registrationId, List<Lesson> orderedLessons) {
        Map<String, String> statuses = getLessonStatuses(registrationId);
        return (int) orderedLessons.stream()
                .filter(l -> "completed".equals(
                        statuses.get(l.getId().toString())))
                .count();
    }

    /**
     * Build student dashboard.
     *
     * @param enrolled the enrolled
     * @param search the search
     * @param categoryId the category id identifier
     * @param sort the sort
     * @param status the status
     * @return the result of build student dashboard
     */
    public StudentDashboardData buildStudentDashboard(
            List<ContinueLearningDTO> enrolled, String search, UUID categoryId, String sort, String status) {
        String keyword = search == null ? "" : search.strip().toLowerCase(Locale.ROOT);
        String selectedStatus = "completed".equals(status) || "enrolled".equals(status) ? status : "";
        List<ContinueLearningDTO> myCourses = new ArrayList<>(enrolled.stream()
                .filter(course -> course.getCourseTitle().toLowerCase(Locale.ROOT).contains(keyword))
                .filter(course -> categoryId == null || categoryId.equals(course.getCategoryId()))
                .filter(course -> selectedStatus.isEmpty()
                        || ("completed".equals(selectedStatus) == isCourseCompleted(course)))
                .toList());

        Comparator<ContinueLearningDTO> byProgress = Comparator.comparingInt(ContinueLearningDTO::getProgressPercent);
        if ("progress_asc".equals(sort)) {
            myCourses.sort(byProgress);
        } else if ("progress_desc".equals(sort)) {
            myCourses.sort(byProgress.reversed());
        } else {
            // findStudentCourses supplies newest enrollments first.
            sort = "newest";
        }
        long completedCourses = enrolled.stream().filter(this::isCourseCompleted).count();
        return new StudentDashboardData(myCourses, sort, selectedStatus, enrolled.size(),
                completedCourses, enrolled.size() - completedCourses);
    }

    /**
     * Resolve continue lesson.
     *
     * @param enrolled the enrolled
     * @param courseIdValue the course id value
     * @param savedLessonValue the saved lesson value
     * @return the result of resolve continue lesson
     */
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

                boolean belongsToCourse = lessonDAO.isVisibleInCourse(candidate, selected.getCourseId());

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

    /**
     * Finds enrolled course.
     *
     * @param userId the user id identifier
     * @param courseId the course id identifier
     * @return the matching enrolled course, if present
     */
    public ContinueLearningDTO findEnrolledCourse(UUID userId, UUID courseId) {
        ContinueLearningDTO course = learningProcessDAO.findStudentCourse(userId, courseId);
        if (course != null) {
            course.setProgressPercent(calculateProgressPercent(course.getCompletedLessonCount(), course.getLessonCount()));
        }
        return course;
    }

    /**
     * Returns lesson for student.
     *
     * @param lessonId the lesson id identifier
     * @param registrationId the registration id identifier
     * @return the lesson for student
     */
    public LessonDTO getLessonForStudent(UUID lessonId, UUID registrationId) {
        Lesson lesson = lessonDAO.findById(lessonId);
        if (lesson == null || !AppConstants.LessonStatus.PUBLISHED.equals(lesson.getPublicationStatus())) return null;
        Map<String, String> statuses = new HashMap<>();
        LearningProcess process = learningProcessDAO.findByRegistrationAndLesson(registrationId, lessonId);
        if (process != null) statuses.put(lessonId.toString(), process.getStatus());
        return lessonForStudent(lesson, registrationId, statuses);
    }

    /**
     * Lesson for student.
     *
     * @param lesson the lesson
     * @param registrationId the registration id identifier
     * @param statuses the statuses
     * @return the result of lesson for student
     */
    private LessonDTO lessonForStudent(Lesson lesson, UUID registrationId, Map<String, String> statuses) {
        String status = statuses.get(lesson.getId().toString());
        if (status == null) {
            status = learningProcessDAO.startLessonIfAbsent(registrationId, lesson.getId());
            statuses.put(lesson.getId().toString(), status);
        }
        LessonDTO dto = new LessonDTO(lesson.getId(), lesson.getModuleId(), lesson.getTitle(),
                lesson.getContent(), lesson.getOrderIndex());
        dto.setMaterialUrl(lesson.getMaterialUrl());
        dto.setDurationMinutes(lesson.getDurationMinutes());
        dto.setPublicationStatus(lesson.getPublicationStatus());
        dto.setType(lesson.getType());
        dto.setVideoUrl(lesson.getVideoUrl());
        dto.setQuizId(lesson.getQuizId());
        dto.setStatus(status);
        return dto;
    }

    public record LessonViewerData(Course course, Registration registration, LessonDTO lesson,
                                   Map<String, String> statuses, Lesson previous, Lesson next,
                                   int completedCount, int totalCount, int progressPercent) {}

    /**
     * Returns lesson viewer.
     *
     * @param userId the user id identifier
     * @param courseId the course id identifier
     * @param lessonId the lesson id identifier
     * @return the lesson viewer
     */
    public LessonViewerData getLessonViewer(UUID userId, UUID courseId, UUID lessonId) {
        Registration registration = findRegistration(userId, courseId);
        Course course = courseService.getPublishedCourseCurriculum(courseId);
        if (!isAccessibleRegistration(registration, course)) throw new SecurityException("Course access denied.");

        List<Lesson> lessons = course.getModules().stream().flatMap(module -> module.getLessons().stream()).toList();
        int index = -1;
        for (int i = 0; i < lessons.size(); i++) {
            if (lessonId.equals(lessons.get(i).getId())) {
                index = i;
                break;
            }
        }
        if (index < 0) throw new SecurityException("Lesson access denied.");
        Map<String, String> statuses = getLessonStatuses(registration.getId());
        LessonDTO lesson = lessonForStudent(lessons.get(index), registration.getId(), statuses);
        int completed = (int) lessons.stream()
                .filter(item -> "completed".equals(statuses.get(item.getId().toString()))).count();
        return new LessonViewerData(course, registration, lesson, statuses,
                index > 0 ? lessons.get(index - 1) : null,
                index + 1 < lessons.size() ? lessons.get(index + 1) : null,
                completed, lessons.size(), calculateProgressPercent(completed, lessons.size()));
    }

    /**
     * Checks whether accessible registration.
     *
     * @param registration the registration
     * @param course the course
     * @return true when the condition holds; false otherwise
     */
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

    /**
     * Checks whether study is allowed.
     *
     * @param registration the registration
     * @param course the course
     * @param lessonId the lesson id identifier
     * @return true when the condition holds; false otherwise
     */
    public boolean canStudy(Registration registration, Course course, UUID lessonId) {
        if (registration == null || course == null) return false;
        if (!isAccessibleRegistration(registration, course)) return false;
        return course.getModules().stream()
                .flatMap(module -> module.getLessons().stream())
                .anyMatch(lesson -> lesson.getId().equals(lessonId)
                        && AppConstants.LessonStatus.PUBLISHED.equals(lesson.getPublicationStatus()));
    }

    /**
     * Checks whether quiz lesson available.
     *
     * @param lesson the lesson
     * @return true when the condition holds; false otherwise
     */
    public boolean isQuizLessonAvailable(LessonDTO lesson) {
        var quiz = new com.learnhub.dao.QuizDAO().findById(lesson.getQuizId());
        return quiz != null && quiz.isPublished() && lesson.getModuleId().equals(quiz.getModuleId());
    }

    /**
     * Complete lesson for student.
     *
     * @param userId the user id identifier
     * @param courseId the course id identifier
     * @param registrationId the registration id identifier
     * @param lessonId the lesson id identifier
     */
    public void completeLessonForStudent(UUID userId, UUID courseId, UUID registrationId, UUID lessonId) {
        Registration registration = findRegistration(userId, courseId);
        Course course = courseService.getCourseById(courseId);
        if (!isAccessibleRegistration(registration, course) || !registrationId.equals(registration.getId())
                || !lessonDAO.isVisibleInCourse(lessonId, courseId)) {
            throw new SecurityException("Course access denied.");
        }
        markLessonComplete(registrationId, lessonId);
    }

    /**
     * Mark lesson complete.
     *
     * @param registrationId the registration id identifier
     * @param lessonId the lesson id identifier
     */
    public void markLessonComplete(UUID registrationId, UUID lessonId) {
        Lesson lesson = lessonDAO.findById(lessonId);
        if (lesson == null || !AppConstants.LessonStatus.PUBLISHED.equals(lesson.getPublicationStatus())) {
            throw new SecurityException("Lesson is not available.");
        }
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                registrationDAO.lockRegistration(conn, registrationId);
                if ("quiz".equals(lesson.getType())) {
                    Registration registration = registrationDAO.findById(registrationId);
                    if (registration == null || !new com.learnhub.dao.QuizAttemptDAO().hasPassed(
                            conn, registration.getUserId(), lesson.getQuizId())) {
                        throw new SecurityException("Pass the linked quiz to complete this lesson.");
                    }
                }
                learningProcessDAO.completeLesson(conn, registrationId, lessonId);
                var counts = learningProcessDAO.readProgressCounts(conn, registrationId);
                int percent = calculateProgressPercent(counts.completed(), counts.total());
                boolean completed = counts.total() > 0 && counts.completed() == counts.total();
                registrationDAO.updateLearningProgress(conn, registrationId, percent, completed);
                conn.commit();
            } catch (SQLException | RuntimeException e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
        } catch (SecurityException e) {
            throw e;
        } catch (SQLException | RuntimeException e) {
            throw new IllegalStateException("Cannot save learning progress.", e);
        }
    }

    /** Quiz scoring calls this only after saving the result; stored pass status is checked again. */
    public void completeQuizLessons(UUID userId, UUID quizId) {
        var quiz = new com.learnhub.dao.QuizDAO().findById(quizId);
        if (quiz == null || !quiz.isPublished()) return;
        var module = new com.learnhub.dao.ModuleDAO().findById(quiz.getModuleId());
        if (module == null || module.isHidden()) return;
        Course course = courseService.getPublishedCourseCurriculum(module.getCourseId());
        Registration registration = findRegistration(userId, module.getCourseId());
        if (!isAccessibleRegistration(registration, course)) return;
        for (Lesson lesson : lessonDAO.findByModuleId(module.getId())) {
            if ("quiz".equals(lesson.getType()) && quizId.equals(lesson.getQuizId())
                    && AppConstants.LessonStatus.PUBLISHED.equals(lesson.getPublicationStatus())) {
                markLessonComplete(registration.getId(), lesson.getId());
            }
        }
    }
}
