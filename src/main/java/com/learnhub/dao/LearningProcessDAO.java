package com.learnhub.dao;

import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.entity.LearningProcess;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

public class LearningProcessDAO {

    private static final Logger LOGGER =
            Logger.getLogger(LearningProcessDAO.class.getName());

    /**
     * Returns a suggested unfinished lesson for the home page.
     */
    public ContinueLearningDTO findContinueLearning(UUID userId) {
        if (userId == null) return null;

        String sql = """
                SELECT c.id AS course_id,
                       c.title AS course_title,
                       c.thumbnail_url,
                       s.name AS category_name,
                       r.progress_percent,
                       (SELECT COUNT(*) FROM module cm
                        WHERE cm.course_id = c.id) AS module_count,
                       (SELECT COUNT(*) FROM lesson cl
                        JOIN module lm ON cl.module_id = lm.id
                        WHERE lm.course_id = c.id) AS lesson_count,
                       l.id AS lesson_id,
                       l.title AS lesson_title,
                       m.title AS module_title
                FROM registration r
                JOIN course c ON c.id = r.course_id
                JOIN module m ON m.course_id = c.id
                JOIN lesson l ON l.module_id = m.id
                LEFT JOIN learning_process lp
                       ON lp.registration_id = r.id
                      AND lp.lesson_id = l.id
                LEFT JOIN setting s ON s.id = c.category_id
                WHERE r.user_id = ?
                  AND r.status = 'enrolled'
                  AND (COALESCE(c.price, 0) <= 0
                       OR r.payment_status = 'paid')
                  AND (lp.status IS NULL OR lp.status <> 'completed')
                ORDER BY CASE WHEN lp.status = 'in_progress'
                              THEN 0 ELSE 1 END,
                         r.enrolled_at DESC,
                         m.order_index, m.id, l.order_index, l.id
                LIMIT 1
                """;

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ContinueLearningDTO course = new ContinueLearningDTO();

                    course.setCourseId((UUID) rs.getObject("course_id"));
                    course.setCourseTitle(rs.getString("course_title"));
                    course.setThumbnailUrl(rs.getString("thumbnail_url"));
                    course.setCategoryName(rs.getString("category_name"));
                    course.setModuleCount(rs.getInt("module_count"));
                    course.setLessonCount(rs.getInt("lesson_count"));
                    course.setLessonId((UUID) rs.getObject("lesson_id"));
                    course.setLessonTitle(rs.getString("lesson_title"));
                    course.setModuleTitle(rs.getString("module_title"));
                    course.setProgressPercent(rs.getInt("progress_percent"));

                    return course;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load suggested lesson", e);
        }

        return null;
    }

    /**
     * Returns enrolled courses and their actual completion progress.
     * The first lesson is used when browser storage has no saved lesson.
     */
    public List<ContinueLearningDTO> findStudentCourses(UUID userId) {
        String sql = """
                SELECT c.id,
                       c.title,
                       c.thumbnail_url,
                       s.name AS category_name,
                       (SELECT COUNT(*) FROM module
                        WHERE course_id = c.id) AS module_count,
                       (SELECT COUNT(*) FROM lesson l
                        JOIN module m ON m.id = l.module_id
                        WHERE m.course_id = c.id) AS lesson_count,
                       (SELECT COUNT(*) FROM learning_process lp
                        JOIN lesson l ON l.id = lp.lesson_id
                        JOIN module m ON m.id = l.module_id
                        WHERE lp.registration_id = r.id
                          AND lp.status = 'completed'
                          AND m.course_id = c.id) AS completed_count,
                       first_lesson.lesson_id,
                       first_lesson.lesson_title
                FROM registration r
                JOIN course c ON c.id = r.course_id
                LEFT JOIN setting s ON s.id = c.category_id
                LEFT JOIN LATERAL (
                    SELECT l.id AS lesson_id,
                           l.title AS lesson_title
                    FROM lesson l
                    JOIN module m ON m.id = l.module_id
                    WHERE m.course_id = c.id
                    ORDER BY m.order_index, m.id, l.order_index, l.id
                    LIMIT 1
                ) first_lesson ON TRUE
                WHERE r.user_id = ?
                  AND r.status IN ('enrolled', 'completed')
                  AND (COALESCE(c.price, 0) <= 0
                       OR r.payment_status = 'paid')
                ORDER BY r.enrolled_at DESC, c.id
                """;

        List<ContinueLearningDTO> result = new ArrayList<>();

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ContinueLearningDTO course = new ContinueLearningDTO();

                    course.setCourseId((UUID) rs.getObject("id"));
                    course.setCourseTitle(rs.getString("title"));
                    course.setThumbnailUrl(rs.getString("thumbnail_url"));
                    course.setCategoryName(rs.getString("category_name"));
                    course.setModuleCount(rs.getInt("module_count"));

                    int total = rs.getInt("lesson_count");
                    int completed = rs.getInt("completed_count");

                    course.setLessonCount(total);
                    course.setCompletedLessonCount(completed);
                    course.setProgressPercent(
                            total == 0 ? 0 : Math.min(
                                    100,
                                    (int) Math.round(100.0 * completed / total)
                            )
                    );

                    course.setLessonId((UUID) rs.getObject("lesson_id"));
                    course.setLessonTitle(rs.getString("lesson_title"));

                    result.add(course);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Cannot load student courses", e
            );
        }

        return result;
    }

    public LearningProcess findByRegistrationAndLesson(
            UUID registrationId,
            UUID lessonId
    ) {
        if (registrationId == null || lessonId == null) return null;

        String sql = """
                SELECT id, registration_id, lesson_id, status, completed_at
                FROM learning_process
                WHERE registration_id = ? AND lesson_id = ?
                """;

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, registrationId);
            ps.setObject(2, lessonId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LearningProcess process = new LearningProcess();

                    process.setId((UUID) rs.getObject("id"));
                    process.setRegistrationId(
                            (UUID) rs.getObject("registration_id")
                    );
                    process.setLessonId((UUID) rs.getObject("lesson_id"));
                    process.setStatus(rs.getString("status"));
                    process.setCompletedAt(rs.getTimestamp("completed_at"));

                    return process;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load learning process", e);
        }

        return null;
    }

    public void save(LearningProcess process) {
        LearningProcess existing = findByRegistrationAndLesson(
                process.getRegistrationId(),
                process.getLessonId()
        );

        if (existing != null) {
            updateStatus(existing.getId(), process.getStatus());
            return;
        }

        String sql = """
                INSERT INTO learning_process
                    (id, registration_id, lesson_id, status, completed_at)
                VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?)
                ON CONFLICT (registration_id, lesson_id)
                DO UPDATE SET status = EXCLUDED.status,
                              completed_at = CASE
                                  WHEN EXCLUDED.status = 'completed'
                                      THEN COALESCE(learning_process.completed_at, EXCLUDED.completed_at)
                                  ELSE learning_process.completed_at
                              END
                """;

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, process.getId());
            ps.setObject(2, process.getRegistrationId());
            ps.setObject(3, process.getLessonId());
            ps.setString(
                    4,
                    process.getStatus() == null
                            ? "not_started"
                            : process.getStatus()
            );
            ps.setTimestamp(
                    5,
                    "completed".equalsIgnoreCase(process.getStatus())
                            ? new Timestamp(System.currentTimeMillis())
                            : process.getCompletedAt()
            );

            ps.executeUpdate();

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot save learning process", e);
        }
    }

    public void updateStatus(UUID id, String status) {
        String sql = """
                UPDATE learning_process
                SET status = ?,
                    completed_at = CASE WHEN ? = 'completed'
                                        THEN COALESCE(completed_at, NOW())
                                        ELSE completed_at END
                WHERE id = ?
                """;

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, status);
            ps.setObject(3, id);
            ps.executeUpdate();

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot update lesson status", e);
        }
    }

    public int countCompletedLessons(UUID registrationId) {
        String sql = """
                SELECT COUNT(*)
                FROM learning_process
                WHERE registration_id = ? AND status = 'completed'
                """;

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, registrationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot count completed lessons", e);
        }

        return 0;
    }

    public int countTotalLessons(UUID registrationId) {
        String sql = """
                SELECT COUNT(l.id)
                FROM lesson l
                JOIN module m ON l.module_id = m.id
                JOIN registration r ON m.course_id = r.course_id
                WHERE r.id = ?
                """;

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, registrationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot count total lessons", e);
        }

        return 0;
    }
    public Map<String, String> findLessonStatuses(
            UUID registrationId
    ) {
        Map<String, String> statuses =
                new java.util.HashMap<>();

        String sql =
                "SELECT lesson_id, status FROM learning_process " +
                        "WHERE registration_id = ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, registrationId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    statuses.put(
                            rs.getObject("lesson_id").toString(),
                            rs.getString("status")
                    );
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Cannot load lesson states", e
            );
        }

        return statuses;
    }
}
