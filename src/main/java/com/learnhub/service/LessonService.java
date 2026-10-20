package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.ModuleDAO;
import com.learnhub.dto.LessonDTO;
import com.learnhub.dto.ManagerDashboardDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Module;
import com.learnhub.entity.Lesson;
import com.learnhub.entity.User;
import com.learnhub.constant.AppConstants;
import com.learnhub.util.CloudinaryClient;
import com.learnhub.util.LessonHtml;

import java.io.InputStream;
import java.util.List;
import java.util.UUID;
import java.util.Map;
import java.util.LinkedHashMap;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Locale;
import java.util.Set;

/**
 * Service handling Lesson management and materials upload.
 * Implements methods specified in SDS Lesson Learning & Content Management Diagrams:
 * - getLessons()
 * - getLesson()
 * - saveLesson()
 * - changeLessonAvailability()
 * - reorderLessons()
 * - attachMaterial()
 */
public class LessonService {
    private final LessonDAO lessonDAO;
    private final CourseDAO courseDAO;
    private final ModuleDAO moduleDAO;

    public void requireCourseAccess(UUID expertId, UUID courseId) {
        Course course = courseId == null ? null : courseDAO.findById(courseId);
        if (expertId == null || course == null
                || !expertId.equals(course.getExpertId())) {
            throw new SecurityException("Course access denied.");
        }
    }

    private void requireModuleAccess(UUID expertId, UUID moduleId) {
        Module module = moduleId == null ? null : moduleDAO.findById(moduleId);
        if (module == null) {
            throw new SecurityException("Module access denied.");
        }
        requireCourseAccess(expertId, module.getCourseId());
    }

    private Lesson requireLessonAccess(UUID expertId, UUID lessonId) {
        Lesson lesson = lessonId == null ? null : lessonDAO.findById(lessonId);
        if (lesson == null) {
            throw new SecurityException("Lesson access denied.");
        }
        requireModuleAccess(expertId, lesson.getModuleId());
        return lesson;
    }

    public LessonService() {
        this(new LessonDAO());
    }

    public LessonService(LessonDAO lessonDAO) {
        this(lessonDAO, new CourseDAO(), new ModuleDAO());
    }

    public LessonService(LessonDAO lessonDAO, CourseDAO courseDAO, ModuleDAO moduleDAO) {
        this.lessonDAO = lessonDAO;
        this.courseDAO = courseDAO;
        this.moduleDAO = moduleDAO;
    }

    public LessonDTO getLesson(UUID expertId, UUID lessonId) {
        Lesson l = requireLessonAccess(expertId, lessonId);
        LessonDTO dto = new LessonDTO(l.getId(), l.getModuleId(), l.getTitle(), l.getContent(), l.getOrderIndex());
        dto.setMaterialUrl(l.getMaterialUrl());
        dto.setDurationMinutes(l.getDurationMinutes());
        dto.setPublicationStatus(l.getPublicationStatus());
        return dto;
    }

    public record LessonListRow(Module module, Lesson lesson) {
        public Module getModule() { return module; }
        public Lesson getLesson() { return lesson; }
    }

    public record LessonListData(List<LessonListRow> rows, String sort,
                                 String direction, String status, UUID moduleId) {}

    public LessonListData buildLessonList(List<Module> modules, String sort,
                                          String direction, String status, UUID moduleId) {
        sort = "duration".equals(sort) ? "duration" : "module";
        direction = "duration".equals(sort) && "desc".equals(direction) ? "desc" : "asc";
        status = status == null ? "" : status.strip().toLowerCase(Locale.ROOT);
        if (!Set.of("draft", "decline", "published", "archived").contains(status)) status = "";
        if (moduleId != null && (modules == null || modules.stream()
                .noneMatch(module -> moduleId.equals(module.getId())))) {
            throw new IllegalArgumentException("Module does not belong to the selected course.");
        }
        List<LessonListRow> rows = new ArrayList<>();
        if (modules != null) {
            for (Module module : modules) {
                if (moduleId != null && !moduleId.equals(module.getId())) continue;
                List<Lesson> lessons = module.getLessons();
                if (lessons == null || lessons.isEmpty()) {
                    if (status.isEmpty()) rows.add(new LessonListRow(module, null));
                } else {
                    for (Lesson lesson : lessons) {
                        if (status.isEmpty() || status.equals(lesson.getPublicationStatus())) {
                            rows.add(new LessonListRow(module, lesson));
                        }
                    }
                }
            }
        }
        Comparator<LessonListRow> moduleOrder = Comparator
                .comparingInt((LessonListRow row) -> row.module().getOrderIndex())
                .thenComparing(row -> row.module().getId(), Comparator.nullsLast(Comparator.naturalOrder()));
        Comparator<LessonListRow> lessonOrder = Comparator
                .comparingInt((LessonListRow row) -> row.lesson() == null ? 0 : row.lesson().getOrderIndex())
                .thenComparing(row -> row.lesson() == null ? null : row.lesson().getId(),
                        Comparator.nullsLast(Comparator.naturalOrder()));
        Comparator<LessonListRow> order;
        if ("duration".equals(sort)) {
            Comparator<Integer> durationOrder = "desc".equals(direction)
                    ? Comparator.reverseOrder() : Comparator.naturalOrder();
            order = Comparator.comparing((LessonListRow row) -> row.lesson() == null
                            ? null : row.lesson().getDurationMinutes(), Comparator.nullsLast(durationOrder))
                    .thenComparing(moduleOrder).thenComparing(lessonOrder);
        } else {
            order = moduleOrder.thenComparing(lessonOrder);
        }
        rows.sort(order);
        return new LessonListData(List.copyOf(rows), sort, direction, status, moduleId);
    }

    public boolean saveLesson(UUID expertId, LessonDTO dto) {
        if (dto == null) return false;
        dto.setPublicationStatus(AppConstants.LessonStatus.DRAFT);
        if (!validateLesson(expertId, dto).isEmpty()) return false;
        dto.setContent(LessonHtml.sanitize(dto.getContent()));
        requireModuleAccess(expertId, dto.getModuleId());
        if (dto.getId() != null && lessonDAO.findById(dto.getId()) != null) {
            requireLessonAccess(expertId, dto.getId());
        }
        Lesson lesson = new Lesson(dto.getId(), dto.getModuleId(),
                dto.getTitle(), dto.getContent(), dto.getOrderIndex());
        lesson.setMaterialUrl(dto.getMaterialUrl());
        lesson.setDurationMinutes(dto.getDurationMinutes());
        lesson.setPublicationStatus(AppConstants.LessonStatus.DRAFT);
        return lessonDAO.save(lesson);
    }

    public boolean changeLessonAvailability(UUID expertId, UUID courseId, UUID lessonId,
                                            Timestamp expectedUpdatedAt, boolean activate) {
        requireCourseAccess(expertId, courseId);
        Lesson lesson = requireLessonAccess(expertId, lessonId);
        if (!courseId.equals(lesson.getCourseId())) {
            throw new SecurityException("Lesson does not belong to this course.");
        }
        if (expectedUpdatedAt == null) throw new IllegalArgumentException("Missing lesson version.");
        String expectedStatus = activate
                ? AppConstants.LessonStatus.ARCHIVED : AppConstants.LessonStatus.PUBLISHED;
        String targetStatus = activate
                ? AppConstants.LessonStatus.PUBLISHED : AppConstants.LessonStatus.ARCHIVED;
        if (!expectedStatus.equals(lesson.getPublicationStatus())) return false;
        return lessonDAO.changeAvailability(expertId, courseId, lessonId,
                expectedUpdatedAt, expectedStatus, targetStatus);
    }

    public Map<String, String> validateLesson(UUID expertId, LessonDTO dto) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (dto.getDurationMinutes() == null || dto.getDurationMinutes() < 1) {
            errors.put("durationMinutes", "Estimated duration must be a whole number of minutes greater than zero.");
        }
        if (dto.getModuleId() == null) {
            errors.put("moduleId", "Please select a valid module.");
        } else {
            requireModuleAccess(expertId, dto.getModuleId());
            if (dto.getId() != null && lessonDAO.findById(dto.getId()) != null)
                requireLessonAccess(expertId, dto.getId());
        }
        if (dto.getTitle() == null || dto.getTitle().isBlank()) {
            errors.put("title", "Please enter a lesson title.");
        } else if (dto.getTitle().codePointCount(0, dto.getTitle().length()) > 255) {
            errors.put("title", "Lesson title must not exceed 255 characters.");
        }
        if (!LessonHtml.hasText(dto.getContent()))
            errors.put("content", "Please enter lesson content.");
        if (dto.getOrderIndex() < 1) {
            errors.put("orderIndex", "Order index must be a whole number greater than or equal to 1.");
        } else if (dto.getModuleId() != null) {
            long count = lessonDAO.findByModuleId(dto.getModuleId()).stream()
                    .filter(l -> !l.getId().equals(dto.getId())).count();
            if (dto.getOrderIndex() > count + 1)
                errors.put("orderIndex", "Maximum allowed order index is " + (count + 1) + ".");
        }
        return errors;
    }

    public void reorderLessons(UUID moduleId, List<UUID> orderedIds) {
        if (orderedIds == null) return;
        for (int i = 0; i < orderedIds.size(); i++) {
            lessonDAO.updateOrderIndex(orderedIds.get(i), i + 1);
        }
    }

    public record LessonReviewData(Course course, List<Lesson> lessons) {}

    private void requireManager(User manager) {
        if (manager == null || !AppConstants.Role.MANAGER.equalsIgnoreCase(manager.getRoleCode())) {
            throw new SecurityException("Manager access required.");
        }
    }

    public LessonReviewData getLessonsForReview(User manager, UUID courseId) {
        requireManager(manager);
        Course course = courseDAO.findById(courseId);
        if (course == null) throw new IllegalArgumentException("Course not found.");
        return new LessonReviewData(course, lessonDAO.findByCourseId(courseId));
    }

    public List<ManagerDashboardDTO.PendingReviewItem> getCoursesAwaitingReview(User manager) {
        requireManager(manager);
        return lessonDAO.findCoursesAwaitingReview(0);
    }

    public boolean reviewLesson(User manager, UUID courseId, UUID lessonId,
                                Timestamp expectedUpdatedAt, String decision) {
        requireManager(manager);
        if (courseId == null || lessonId == null || expectedUpdatedAt == null
                || !(AppConstants.LessonStatus.PUBLISHED.equals(decision)
                    || AppConstants.LessonStatus.DECLINE.equals(decision))) {
            throw new IllegalArgumentException("Invalid lesson review.");
        }
        return lessonDAO.reviewPublication(courseId, lessonId, expectedUpdatedAt, decision);
    }

    public String attachMaterial(UUID expertId, UUID lessonId,
                                 InputStream fileStream, String filename) {
        Lesson lesson = requireLessonAccess(expertId, lessonId);
        String secureUrl = CloudinaryClient.uploadFile(fileStream, filename);
        lesson.setMaterialUrl(secureUrl);
        lesson.setPublicationStatus(AppConstants.LessonStatus.DRAFT);
        lessonDAO.update(lesson);
        return secureUrl;
    }
}
