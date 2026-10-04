package com.learnhub.dao;

import com.learnhub.entity.Course;
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

    public List<Course> findPublishedCourses(String search, UUID categoryId, int offset, int limit) {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                "s.name as category_name, u.username as expert_name, " +
                "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) as module_count, " +
                "(SELECT COUNT(*) FROM lesson l JOIN module m ON l.module_id = m.id WHERE m.course_id = c.id) as lesson_count " +
                "FROM course c " +
                "LEFT JOIN setting s ON c.category_id = s.id " +
                "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                "WHERE c.status = 'published' ");

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

    public int countPublishedCourses(String search, UUID categoryId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM course c WHERE c.status = 'published' ");
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

    public Course findById(UUID id) {
        if (id == null) return null;
        String sql = "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                     "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                     "s.name as category_name, u.username as expert_name, " +
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

    public Course findCourseWithModulesAndLessons(UUID courseId) {
        Course course = findById(courseId);
        if (course == null) return null;

        String moduleSql = "SELECT id, course_id, title, content, order_index, created_at, updated_at " +
                           "FROM module WHERE course_id = ? ORDER BY order_index ASC";
        String lessonSql = "SELECT id, module_id, title, content, order_index, created_at, updated_at " +
                           "FROM lesson WHERE module_id = ? ORDER BY order_index ASC";

        List<Module> modules = new ArrayList<>();
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement mPs = conn.prepareStatement(moduleSql)) {
            mPs.setObject(1, courseId);
            try (ResultSet mRs = mPs.executeQuery()) {
                while (mRs.next()) {
                    Module m = new Module();
                    m.setId((UUID) mRs.getObject("id"));
                    m.setCourseId((UUID) mRs.getObject("course_id"));
                    m.setTitle(mRs.getString("title"));
                    m.setContent(mRs.getString("content"));
                    m.setOrderIndex(mRs.getInt("order_index"));
                    m.setCreatedAt(mRs.getTimestamp("created_at"));
                    m.setUpdatedAt(mRs.getTimestamp("updated_at"));

                    try (PreparedStatement lPs = conn.prepareStatement(lessonSql)) {
                        lPs.setObject(1, m.getId());
                        try (ResultSet lRs = lPs.executeQuery()) {
                            List<Lesson> lessons = new ArrayList<>();
                            while (lRs.next()) {
                                Lesson l = new Lesson();
                                l.setId((UUID) lRs.getObject("id"));
                                l.setModuleId((UUID) lRs.getObject("module_id"));
                                l.setTitle(lRs.getString("title"));
                                l.setContent(lRs.getString("content"));
                                l.setOrderIndex(lRs.getInt("order_index"));
                                l.setCreatedAt(lRs.getTimestamp("created_at"));
                                l.setUpdatedAt(lRs.getTimestamp("updated_at"));
                                l.setCourseId(courseId);
                                lessons.add(l);
                            }
                            m.setLessons(lessons);
                        }
                    }
                    modules.add(m);
                }
            }
            course.setModules(modules);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findCourseWithModulesAndLessons: " + e.getMessage(), e);
        }
        return course;
    }

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
            c.setExpertName(rs.getString("expert_name"));
            c.setModuleCount(rs.getInt("module_count"));
            c.setLessonCount(rs.getInt("lesson_count"));
            c.setEnrolledCount(rs.getInt("enrolled_count"));
        } catch (SQLException ignored) {
        }
        return c;
    }

    public List<Course> findAllCoursesForManagement(String search, UUID categoryId, String status, String priceType, String sortBy, String sortOrder, int offset, int limit) {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                "s.name as category_name, u.username as expert_name, " +
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
    public List<Course> findByExpertId(UUID expertId, int offset, int limit) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.id, c.title, c.description, c.price, c.thumbnail_url, c.status, " +
                     "c.category_id, c.created_by, c.expert_id, c.created_at, c.updated_at, " +
                     "s.name as category_name, u.username as expert_name, " +
                     "(SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) as module_count, " +
                     "(SELECT COUNT(*) FROM lesson l JOIN module m ON l.module_id = m.id WHERE m.course_id = c.id) as lesson_count " +
                     "FROM course c " +
                     "LEFT JOIN setting s ON c.category_id = s.id " +
                     "LEFT JOIN \"user\" u ON c.expert_id = u.id " +
                     "WHERE c.expert_id = ? " +
                     "ORDER BY c.updated_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, expertId);
            ps.setInt(2, limit);
            ps.setInt(3, offset);
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
    
    public int countByExpertId(UUID expertId) {
        String sql = "SELECT COUNT(*) FROM course WHERE expert_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, expertId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in CourseDAO.countByExpertId: " + e.getMessage(), e);
        }
        return 0;
    }
}
