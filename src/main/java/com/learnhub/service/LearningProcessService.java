package com.learnhub.service;

import com.learnhub.dao.LearningProcessDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.LearningProcess;
import com.learnhub.entity.Lesson;

import java.sql.Timestamp;
import java.util.UUID;

/**
 * Service managing student learning progress.
 * Implements methods specified in Lesson Learning Class Diagram (SDS 4.1):
 * - getLessonForStudent()
 * - markLessonComplete()
 * - getProgressPercent()
 */
public class LearningProcessService {
    private final LearningProcessDAO learningProcessDAO;
    private final RegistrationDAO registrationDAO;
    private final LessonDAO lessonDAO;

    public LearningProcessService() {
        this.learningProcessDAO = new LearningProcessDAO();
        this.registrationDAO = new RegistrationDAO();
        this.lessonDAO = new LessonDAO();
    }

    public LearningProcessService(LearningProcessDAO learningProcessDAO, RegistrationDAO registrationDAO, LessonDAO lessonDAO) {
        this.learningProcessDAO = learningProcessDAO;
        this.registrationDAO = registrationDAO;
        this.lessonDAO = lessonDAO;
    }

    public ContinueLearningDTO getContinueLearning(UUID userId) {
        return learningProcessDAO.findContinueLearning(userId);
    }

    public LessonDTO getLessonForStudent(UUID lessonId, UUID registrationId) {
        Lesson l = lessonDAO.findById(lessonId);
        if (l == null) return null;

        LessonDTO dto = new LessonDTO(l.getId(), l.getModuleId(), l.getTitle(), l.getContent(), l.getOrderIndex());
        dto.setMaterialUrl(l.getMaterialUrl());

        LearningProcess lp = learningProcessDAO.findByRegistrationAndLesson(registrationId, lessonId);
        if (lp != null) {
            dto.setStatus(lp.getStatus());
        } else {
            dto.setStatus("not_started");
            LearningProcess newLp = new LearningProcess(UUID.randomUUID(), registrationId, lessonId, "in_progress");
            learningProcessDAO.save(newLp);
        }
        return dto;
    }

    public void markLessonComplete(UUID registrationId, UUID lessonId) {
        LearningProcess lp = learningProcessDAO.findByRegistrationAndLesson(registrationId, lessonId);
        if (lp == null) {
            lp = new LearningProcess(UUID.randomUUID(), registrationId, lessonId, "completed");
            lp.setCompletedAt(new Timestamp(System.currentTimeMillis()));
        } else {
            lp.setStatus("completed");
            lp.setCompletedAt(new Timestamp(System.currentTimeMillis()));
        }
        learningProcessDAO.save(lp);

        int progress = getProgressPercent(registrationId);
        registrationDAO.updateProgressPercent(registrationId, progress);
    }

    public int getProgressPercent(UUID registrationId) {
        int completed = learningProcessDAO.countCompletedLessons(registrationId);
        int total = learningProcessDAO.countTotalLessons(registrationId);
        if (total <= 0) return 0;
        return (int) Math.round(((double) completed / total) * 100);
    }
}
