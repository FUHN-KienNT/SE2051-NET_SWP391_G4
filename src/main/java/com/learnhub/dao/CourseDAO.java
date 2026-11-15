package com.learnhub.dao;

import com.learnhub.entity.Course;
import com.learnhub.dto.CourseStatusCounts;
import com.learnhub.entity.Lesson;
import com.learnhub.entity.Module;
import com.learnhub.util.DbConnection;

import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Course entity.
 * Implements methods specified in SDS Course Browsing Class Diagram & Sequence Diagrams:
 * - findPublishedCourses()
 * - countPublishedCourses()
 * - findCourseWithModulesAndLessons()
 */
public class CourseDAO {
    private static final Logger LOGGER = Logger.getLogger(CourseDAO.class.getName());

    /**
     * Finds published courses.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @param offset the offset
     * @param limit the limit
     * @return the matching published courses, if present
     */
    public List<Course> findPublishedCourses(String search, UUID categoryId, int offset, int limit) {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                "s.name as category_name, s.status as category_status, u.username as expert_name, " +
                "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) as module_count, " +
                "(SELECT COUNT(*) FROM lesson l JOIN module m ON l.module_id = m.id WHERE m.course_id = c.id) as lesson_count " +
                "FROM course c " +
                "LEFT JOIN setting s ON c.category_id = s.id " +
                "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                "WHERE c.status = 'published' AND (s.id IS NULL OR s.status = TRUE) ");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(c.title) LIKE ? OR LOWER(c.description) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
        }
        if (categoryId != null) {
            sql.append("AND c.category_id = ? ");
            params.add(categoryId);
        }

        sql.append("ORDER BY c.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCourse(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.findPublishedCourses: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Finds popular published courses.
     *
     * @param excludedCourseId the excluded course id identifier
     * @param limit the limit
     * @return the matching popular published courses, if present
     */
    public List<Course> findPopularPublishedCourses(UUID excludedCourseId, int limit) {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                "s.name AS category_name, s.status AS category_status, u.username AS expert_name, " +
                "(SELECT COUNT(*) FROM registration r WHERE r.course_id = c.id " +
                "AND r.status IN ('enrolled', 'completed') " +
                "AND (c.price <= 0 OR r.payment_status = 'paid')) AS enrolled_count, " +
                "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) AS module_count, " +
                "(SELECT COUNT(*) FROM lesson l JOIN module m ON l.module_id = m.id WHERE m.course_id = c.id) AS lesson_count " +
                "FROM course c " +
                "LEFT JOIN setting s ON c.category_id = s.id " +
                "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                "WHERE c.status = 'published' AND (s.id IS NULL OR s.status = TRUE) ");
        if (excludedCourseId != null) {
            sql.append("AND c.id <> ? ");
        }
        sql.append("ORDER BY enrolled_count DESC, c.created_at DESC, c.id ASC LIMIT ?");

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int parameterIndex = 1;
            if (excludedCourseId != null) {
                ps.setObject(parameterIndex++, excludedCourseId);
            }
            ps.setInt(parameterIndex, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCourse(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.findPopularPublishedCourses: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Counts published courses.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @return the number of published courses
     */
    public int countPublishedCourses(String search, UUID categoryId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM course c LEFT JOIN setting s ON c.category_id = s.id WHERE c.status = 'published' AND (s.id IS NULL OR s.status = TRUE) ");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(c.title) LIKE ? OR LOWER(c.description) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
        }
        if (categoryId != null) {
            sql.append("AND c.category_id = ? ");
            params.add(categoryId);
        }

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countPublishedCourses: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Finds by id.
     *
     * @param id the id identifier
     * @return the matching by id, if present
     */
    public Course findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                     "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                     "s.name as category_name, s.status as category_status, u.username as expert_name, " +
                     "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) as module_count, " +
                     "(SELECT COUNT(*) FROM lesson l JOIN module m ON l.module_id = m.id WHERE m.course_id = c.id) as lesson_count " +
                     "FROM course c " +
                     "LEFT JOIN setting s ON c.category_id = s.id " +
                     "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                     "WHERE c.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCourse(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.findById: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Finds course with modules and lessons.
     *
     * @param courseId the course id identifier
     * @return the matching course with modules and lessons, if present
     */
    public Course findCourseWithModulesAndLessons(UUID courseId) {
        return findCourseCurriculum(courseId, true);
    }

    /**
     * Finds course with lesson summaries.
     *
     * @param courseId the course id identifier
     * @return the matching course with lesson summaries, if present
     */
    public Course findCourseWithLessonSummaries(UUID courseId) {
        return findCourseCurriculum(courseId, false);
    }

    /**
     * Finds course curriculum.
     *
     * @param courseId the course id identifier
     * @param includeContent the include content
     * @return the matching course curriculum, if present
     */
    private Course findCourseCurriculum(UUID courseId, boolean includeContent) {
        Course course = findById(courseId);
        if (course == null) return null;

        List<Module> modules = new ModuleDAO().findByCourseId(courseId);
        Map<UUID, Module> modulesById = new HashMap<>();
        for (Module module : modules) {
            module.setLessons(new ArrayList<>());
            modulesById.put(module.getId(), module);
        }
        LessonDAO lessons = new LessonDAO();
        List<Lesson> courseLessons = includeContent
                ? lessons.findByCourseId(courseId) : lessons.findSummariesByCourseId(courseId);
        for (Lesson lesson : courseLessons) {
            Module module = modulesById.get(lesson.getModuleId());
            if (module != null) module.getLessons().add(lesson);
        }
        course.setModules(modules);
        return course;
    }

    /**
     * Insert.
     *
     * @param course the course
     * @return true when the condition holds; false otherwise
     */
    public boolean insert(Course course) {
        String sql = "INSERT INTO course (id, title, description, price, thumbnail_url, status, category_id, created_by, expert_id, created_at, updated_at) " +
                     "VALUES (COALESCE(?, gen_random_uuid()), ?, ?, ?, ?, ?::course_status, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, course.getId());
            ps.setString(2, course.getTitle());
            ps.setString(3, course.getDescription());
            ps.setBigDecimal(4, course.getPrice());
            ps.setString(5, course.getThumbnailUrl());
            ps.setString(6, course.getStatus() != null ? course.getStatus() : "draft");
            ps.setObject(7, course.getCategoryId());
            ps.setObject(8, course.getCreatedBy());
            ps.setObject(9, course.getExpertId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.insert: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Update.
     *
     * @param course the course
     * @return true when the condition holds; false otherwise
     */
    public boolean update(Course course) {
        String sql = "UPDATE course SET title = ?, description = ?, price = ?, thumbnail_url = ?, status = ?::course_status, category_id = ?, expert_id = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, course.getTitle());
            ps.setString(2, course.getDescription());
            ps.setBigDecimal(3, course.getPrice());
            ps.setString(4, course.getThumbnailUrl());
            ps.setString(5, course.getStatus());
            ps.setObject(6, course.getCategoryId());
            ps.setObject(7, course.getExpertId());
            ps.setObject(8, course.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.update: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Map result set to course.
     *
     * @param rs the current result set
     * @return the result of map result set to course
     * @throws SQLException if the operation cannot complete
     */
    private Course mapResultSetToCourse(ResultSet rs) throws SQLException {
        Course c = new Course();
        c.setId((UUID) rs.getObject("id"));
        c.setTitle(rs.getString("title"));
        c.setDescription(rs.getString("description"));
        c.setPrice(rs.getBigDecimal("price"));
        c.setThumbnailUrl(rs.getString("thumbnail_url"));
        c.setStatus(rs.getString("status"));
        c.setCategoryId((UUID) rs.getObject("category_id"));
        c.setCreatedBy((UUID) rs.getObject("created_by"));
        c.setExpertId((UUID) rs.getObject("expert_id"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        try {
            c.setCategoryName(rs.getString("category_name"));
            Object catStatus = rs.getObject("category_status");
            if (catStatus != null) {
                c.setCategoryStatus(rs.getBoolean("category_status"));
            }
            c.setExpertName(rs.getString("expert_name"));
            c.setModuleCount(rs.getInt("module_count"));
            c.setLessonCount(rs.getInt("lesson_count"));
            c.setEnrolledCount(rs.getInt("enrolled_count"));
        } catch (SQLException ignored) {
        }
        return c;
    }

    /**
     * Finds all courses for management.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @param status the status
     * @param priceType the price type
     * @param sortBy the sort by
     * @param sortOrder the sort order
     * @param offset the offset
     * @param limit the limit
     * @return the matching all courses for management, if present
     */
    public List<Course> findAllCoursesForManagement(String search, UUID categoryId, String status, String priceType, String sortBy, String sortOrder, int offset, int limit) {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                "s.name as category_name, s.status as category_status, u.username as expert_name, " +
                "(SELECT COUNT(*) FROM registration r WHERE r.course_id = c.id) as enrolled_count, " +
                "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) as module_count, " +
                "(SELECT COUNT(*) FROM lesson l JOIN module m ON l.module_id = m.id WHERE m.course_id = c.id) as lesson_count " +
                "FROM course c " +
                "LEFT JOIN setting s ON c.category_id = s.id " +
                "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(c.title) LIKE ? OR LOWER(COALESCE(u.username, '')) LIKE ? OR CAST(c.id AS TEXT) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }
        if (categoryId != null) {
            sql.append("AND c.category_id = ? ");
            params.add(categoryId);
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append("AND c.status = ?::course_status ");
            params.add(status.trim().toLowerCase());
        }
        if (priceType != null && !priceType.trim().isEmpty() && !priceType.equalsIgnoreCase("all")) {
            if ("free".equalsIgnoreCase(priceType)) {
                sql.append("AND (c.price = 0 OR c.price IS NULL) ");
            } else if ("paid".equalsIgnoreCase(priceType)) {
                sql.append("AND c.price > 0 ");
            }
        }

        // Sorting
        String orderCol = "c.created_at";
        if ("title".equalsIgnoreCase(sortBy)) {
            orderCol = "c.title";
        } else if ("price".equalsIgnoreCase(sortBy)) {
            orderCol = "c.price";
        } else if ("enrolled".equalsIgnoreCase(sortBy) || "total_enrolled".equalsIgnoreCase(sortBy)) {
            orderCol = "enrolled_count";
        } else if ("date".equalsIgnoreCase(sortBy) || "created_at".equalsIgnoreCase(sortBy)) {
            orderCol = "c.created_at";
        }

        String direction = "DESC";
        if ("asc".equalsIgnoreCase(sortOrder)) {
            direction = "ASC";
        }

        sql.append("ORDER BY ").append(orderCol).append(" ").append(direction).append(", c.id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCourse(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.findAllCoursesForManagement: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Counts all courses for management.
     *
     * @param search the search
     * @param categoryId the category id identifier
     * @param status the status
     * @param priceType the price type
     * @return the number of all courses for management
     */
    public int countAllCoursesForManagement(String search, UUID categoryId, String status, String priceType) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM course c " +
                "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(c.title) LIKE ? OR LOWER(COALESCE(u.username, '')) LIKE ? OR CAST(c.id AS TEXT) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }
        if (categoryId != null) {
            sql.append("AND c.category_id = ? ");
            params.add(categoryId);
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append("AND c.status = ?::course_status ");
            params.add(status.trim().toLowerCase());
        }
        if (priceType != null && !priceType.trim().isEmpty() && !priceType.equalsIgnoreCase("all")) {
            if ("free".equalsIgnoreCase(priceType)) {
                sql.append("AND (c.price = 0 OR c.price IS NULL) ");
            } else if ("paid".equalsIgnoreCase(priceType)) {
                sql.append("AND c.price > 0 ");
            }
        }

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countAllCoursesForManagement: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Update status.
     *
     * @param courseId the course id identifier
     * @param status the status
     * @return true when the condition holds; false otherwise
     */
    public boolean updateStatus(UUID courseId, String status) {
        String sql = "UPDATE course SET status = ?::course_status, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.toLowerCase());
            ps.setObject(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.updateStatus: " + e.getMessage(), e);
            return false;
        }
    }
    /**
     * Finds assigned course options.
     *
     * @param expertId the expert id identifier
     * @return the matching assigned course options, if present
     */
    public List<Course> findAssignedCourseOptions(UUID expertId) {
        List<Course> courses = new ArrayList<>();
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT id, title FROM course WHERE expert_id=? ORDER BY updated_at DESC, id")) {
            ps.setObject(1, expertId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course course = new Course();
                    course.setId(rs.getObject("id", UUID.class));
                    course.setTitle(rs.getString("title"));
                    courses.add(course);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot load assigned courses.", e);
        }
        return courses;
    }

    /**
     * Finds by expert id.
     *
     * @param expertId the expert id identifier
     * @param offset the offset
     * @param limit the limit
     * @return the matching by expert id, if present
     */
    public List<Course> findByExpertId(UUID expertId, int offset, int limit) {
        return findByExpertId(expertId, offset, limit, "");
    }

    /**
     * Finds by expert id.
     *
     * @param expertId the expert id identifier
     * @param offset the offset
     * @param limit the limit
     * @param search the search
     * @return the matching by expert id, if present
     */
    public List<Course> findByExpertId(UUID expertId, int offset, int limit, String search) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                     "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                     "s.name as category_name, s.status as category_status, u.username as expert_name, " +
                     "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) as module_count, " +
                     "0 as lesson_count " +
                     "FROM course c " +
                     "LEFT JOIN setting s ON c.category_id = s.id " +
                     "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                     "WHERE c.expert_id = ? AND strpos(lower(c.title), lower(?)) > 0 " +
                     "ORDER BY c.updated_at DESC, c.id LIMIT ? OFFSET ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, expertId);
            ps.setString(2, search);
            ps.setInt(3, limit);
            ps.setInt(4, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCourse(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.findByExpertId: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Counts assigned by status.
     *
     * @param expertId the expert id identifier
     * @param search the search
     * @return the number of assigned by status
     */
    public CourseStatusCounts countAssignedByStatus(UUID expertId, String search) {
        String sql = """
                SELECT COUNT(*) AS total,
                       COUNT(*) FILTER (WHERE status='published') AS published,
                       COUNT(*) FILTER (WHERE status='draft') AS draft,
                       COUNT(*) FILTER (WHERE status='archived') AS archived
                FROM course WHERE expert_id=? AND strpos(lower(title), lower(?)) > 0
                """;
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, expertId);
            ps.setString(2, search);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return new CourseStatusCounts(rs.getInt("total"), rs.getInt("published"),
                        rs.getInt("draft"), rs.getInt("archived"));
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot count assigned courses.", e);
        }
    }

    /**
     * Counts by expert id.
     *
     * @param expertId the expert id identifier
     * @return the number of by expert id
     */
    public int countByExpertId(UUID expertId) {
        return countByExpertId(expertId, null);
    }

    /**
     * Counts by expert id.
     *
     * @param expertId the expert id identifier
     * @param status the status
     * @return the number of by expert id
     */
    public int countByExpertId(UUID expertId, String status) {
        return countByExpertId(expertId, status, "");
    }

    /**
     * Counts by expert id.
     *
     * @param expertId the expert id identifier
     * @param status the status
     * @param search the search
     * @return the number of by expert id
     */
    public int countByExpertId(UUID expertId, String status, String search) {
        String sql = "SELECT COUNT(*) FROM course WHERE expert_id = ? "
                + "AND strpos(lower(title), lower(?)) > 0"
                + (status == null ? "" : " AND status = ?::course_status");
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, expertId);
            ps.setString(2, search);
            if (status != null) {
                ps.setString(3, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
            throw new SQLException("Course count returned no result.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countByExpertId", e);
            throw new IllegalStateException("Cannot count assigned courses.", e);
        }
    }

    /**
     * Finds by expert id.
     *
     * @param expertId the expert id identifier
     * @return the matching by expert id, if present
     */
    public List<Course> findByExpertId(UUID expertId) {
        return findByExpertId(expertId, 0, 100);
    }

    /**
     * Counts total courses.
     *
     * @return the number of total courses
     */
    public int countTotalCourses() {
        String sql = "SELECT COUNT(*) FROM course";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countTotalCourses: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Counts published courses.
     *
     * @return the number of published courses
     */
    public int countPublishedCourses() {
        String sql = "SELECT COUNT(*) FROM course WHERE status = 'published'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countPublishedCourses: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Counts unpublished courses.
     *
     * @return the number of unpublished courses
     */
    public int countUnpublishedCourses() {
        String sql = "SELECT COUNT(*) FROM course WHERE status != 'published'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countUnpublishedCourses: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Counts unassigned courses.
     *
     * @return the number of unassigned courses
     */
    public int countUnassignedCourses() {
        String sql = "SELECT COUNT(*) FROM course WHERE expert_id IS NULL AND status != 'archived'";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countUnassignedCourses: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Finds unassigned courses.
     *
     * @param limit the limit
     * @return the matching unassigned courses, if present
     */
    public List<Course> findUnassignedCourses(int limit) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                     "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                     "s.name as category_name, NULL as expert_name, " +
                     "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) as module_count, " +
                     "(SELECT COUNT(*) FROM lesson l JOIN module m ON l.module_id = m.id WHERE m.course_id = c.id) as lesson_count " +
                     "FROM course c " +
                     "LEFT JOIN setting s ON c.category_id = s.id " +
                     "WHERE c.expert_id IS NULL AND c.status != 'archived' " +
                     "ORDER BY c.created_at DESC LIMIT ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCourse(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.findUnassignedCourses: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Assign expert.
     *
     * @param courseId the course id identifier
     * @param expertId the expert id identifier
     * @return true when the condition holds; false otherwise
     */
    public boolean assignExpert(UUID courseId, UUID expertId) {
        String sql = "UPDATE course SET expert_id = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, expertId);
            ps.setObject(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.assignExpert: " + e.getMessage(), e);
            return false;
        }
    }
    /**
     * Counts courses by category id.
     *
     * @param categoryId the category id identifier
     * @return the number of courses by category id
     */
    public int countCoursesByCategoryId(UUID categoryId) {
        if (categoryId == null) return 0;
        String sql = "SELECT COUNT(*) FROM course WHERE category_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countCoursesByCategoryId: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Counts courses grouped by category.
     *
     * @return the number of courses grouped by category
     */
    public Map<UUID, Integer> countCoursesGroupedByCategory() {
        Map<UUID, Integer> map = new HashMap<>();
        String sql = "SELECT category_id, COUNT(*) FROM course WHERE category_id IS NOT NULL GROUP BY category_id";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                UUID catId = (UUID) rs.getObject(1);
                if (catId != null) {
                    map.put(catId, rs.getInt(2));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countCoursesGroupedByCategory: " + e.getMessage(), e);
        }
        return map;
    }
}
