package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.ModuleDAO;
import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Module;
import com.learnhub.entity.Lesson;
import com.learnhub.util.CloudinaryClient;

import java.io.InputStream;
import java.util.List;
import java.util.UUID;
import java.util.Map;
import java.util.LinkedHashMap;

/**
 * Service handling Lesson management and materials upload.
 * Implements methods specified in SDS Lesson Learning & Content Management Diagrams:
 * - getLessons()
 * - getLesson()
 * - saveLesson()
 * - deleteLesson()
 * - reorderLessons()
 * - attachMaterial()
 */
public class LessonService {
    private final LessonDAO lessonDAO;
    private final CourseDAO courseDAO = new CourseDAO();
    private final ModuleDAO moduleDAO = new ModuleDAO();

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
        this.lessonDAO = new LessonDAO();
    }

    public LessonService(LessonDAO lessonDAO) {
        this.lessonDAO = lessonDAO;
    }

    public LessonDTO getLesson(UUID expertId, UUID lessonId) {
        Lesson l = requireLessonAccess(expertId, lessonId);
        LessonDTO dto = new LessonDTO(l.getId(), l.getModuleId(), l.getTitle(), l.getContent(), l.getOrderIndex());
        dto.setMaterialUrl(l.getMaterialUrl());
        return dto;
    }

    public boolean saveLesson(UUID expertId, LessonDTO dto) {
        if (dto == null) return false;
        if (!validateLesson(expertId, dto).isEmpty()) return false;
        requireModuleAccess(expertId, dto.getModuleId());
        if (dto.getId() != null && lessonDAO.findById(dto.getId()) != null) {
            requireLessonAccess(expertId, dto.getId());
        }
        Lesson lesson = new Lesson(dto.getId(), dto.getModuleId(),
                dto.getTitle(), dto.getContent(), dto.getOrderIndex());
        lesson.setMaterialUrl(dto.getMaterialUrl());
        return lessonDAO.save(lesson);
    }

    public void deleteLesson(UUID expertId, UUID lessonId) {
        requireLessonAccess(expertId, lessonId);
        lessonDAO.delete(lessonId);
    }

    public Map<String, String> validateLesson(UUID expertId, LessonDTO dto) {
        Map<String, String> errors = new LinkedHashMap<>();
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
        if (dto.getContent() == null || dto.getContent().isBlank())
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

    public String attachMaterial(UUID expertId, UUID lessonId,
                                 InputStream fileStream, String filename) {
        Lesson lesson = requireLessonAccess(expertId, lessonId);
        String secureUrl = CloudinaryClient.uploadFile(fileStream, filename);
        lesson.setMaterialUrl(secureUrl);
        lessonDAO.update(lesson);
        return secureUrl;
    }
}
