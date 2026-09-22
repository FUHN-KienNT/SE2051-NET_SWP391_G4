package com.fpt.lms.service;

import com.fpt.lms.dao.LessonDAO;
import com.fpt.lms.dto.LessonDTO;
import com.fpt.lms.entity.Lesson;
import com.fpt.lms.util.CloudinaryClient;

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

    public LessonService() {
        this.lessonDAO = new LessonDAO();
    }

    public LessonService(LessonDAO lessonDAO) {
        this.lessonDAO = lessonDAO;
    }

    public List<Lesson> getLessons(UUID moduleId) {
        return lessonDAO.findByModuleId(moduleId);
    }

    public LessonDTO getLesson(UUID lessonId) {
        Lesson l = lessonDAO.findById(lessonId);
        if (l == null) return null;
        LessonDTO dto = new LessonDTO(l.getId(), l.getModuleId(), l.getTitle(), l.getContent(), l.getOrderIndex());
        dto.setMaterialUrl(l.getMaterialUrl());
        return dto;
    }

    public void saveLesson(LessonDTO dto) {
        if (dto == null) return;
        Lesson l = new Lesson(dto.getId(), dto.getModuleId(), dto.getTitle(), dto.getContent(), dto.getOrderIndex());
        l.setMaterialUrl(dto.getMaterialUrl());
        lessonDAO.save(l);
    }

    public void deleteLesson(UUID lessonId) {
        lessonDAO.delete(lessonId);
    }

    public void reorderLessons(UUID moduleId, List<UUID> orderedIds) {
        if (orderedIds == null) return;
        for (int i = 0; i < orderedIds.size(); i++) {
            lessonDAO.updateOrderIndex(orderedIds.get(i), i + 1);
        }
    }

    public String attachMaterial(UUID lessonId, InputStream fileStream, String filename) {
        String secureUrl = CloudinaryClient.uploadFile(fileStream, filename);
        Lesson l = lessonDAO.findById(lessonId);
        if (l != null) {
            l.setMaterialUrl(secureUrl);
            lessonDAO.update(l);
        }
        return secureUrl;
    }
}
