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

    public List<Lesson> getLessons(UUID expertId, UUID moduleId) {
        requireModuleAccess(expertId, moduleId);
        return lessonDAO.findByModuleId(moduleId);
    }

    public LessonDTO getLesson(UUID expertId, UUID lessonId) {
        Lesson l = requireLessonAccess(expertId, lessonId);
        LessonDTO dto = new LessonDTO(l.getId(), l.getModuleId(), l.getTitle(), l.getContent(), l.getOrderIndex());
        dto.setMaterialUrl(l.getMaterialUrl());
        return dto;
    }

    public void saveLesson(UUID expertId, LessonDTO dto) {
        if (dto == null) return;
        requireModuleAccess(expertId, dto.getModuleId());
        if (dto.getId() != null && lessonDAO.findById(dto.getId()) != null) {
            requireLessonAccess(expertId, dto.getId());
        }
        Lesson lesson = new Lesson(dto.getId(), dto.getModuleId(),
                dto.getTitle(), dto.getContent(), dto.getOrderIndex());
        lesson.setMaterialUrl(dto.getMaterialUrl());
        lessonDAO.save(lesson);
    }

    public void deleteLesson(UUID expertId, UUID lessonId) {
        requireLessonAccess(expertId, lessonId);
        lessonDAO.delete(lessonId);
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
