package com.learnhub.service;

import com.learnhub.dao.LearningProcessDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.dto.LessonDTO;
import com.learnhub.entity.LearningProcess;
import com.learnhub.entity.Lesson;
import com.learnhub.entity.Registration;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class LearningProcessService {

    private final LearningProcessDAO learningProcessDAO;
    private final RegistrationDAO registrationDAO;
    private final LessonDAO lessonDAO;

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
        return learningProcessDAO.findContinueLearning(userId);
    }

    public Registration findRegistration(UUID userId, UUID courseId) {
        return registrationDAO.findByUserAndCourse(userId, courseId);
    }

    public List<ContinueLearningDTO> getStudentCourses(UUID userId) {
        return learningProcessDAO.findStudentCourses(userId);
    }

    public LessonDTO getLessonForStudent(
            UUID lessonId,
            UUID registrationId
    ) {
        Lesson lesson = lessonDAO.findById(lessonId);
        if (lesson == null) return null;

        LessonDTO dto = new LessonDTO(
                lesson.getId(),
                lesson.getModuleId(),
                lesson.getTitle(),
                lesson.getContent(),
                lesson.getOrderIndex()
        );

        dto.setMaterialUrl(lesson.getMaterialUrl());

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

    public void markLessonComplete(
            UUID registrationId,
            UUID lessonId
    ) {
        LearningProcess process =
                learningProcessDAO.findByRegistrationAndLesson(
                        registrationId, lessonId
                );

        if (process == null) {
            process = new LearningProcess(
                    UUID.randomUUID(),
                    registrationId,
                    lessonId,
                    "completed"
            );
        } else {
            process.setStatus("completed");
        }

        process.setCompletedAt(
                new Timestamp(System.currentTimeMillis())
        );

        learningProcessDAO.save(process);

        registrationDAO.updateProgressPercent(
                registrationId,
                getProgressPercent(registrationId)
        );
    }

    public int getProgressPercent(UUID registrationId) {
        int completed =
                learningProcessDAO.countCompletedLessons(registrationId);

        int total =
                learningProcessDAO.countTotalLessons(registrationId);

        if (total <= 0) return 0;

        return Math.min(
                100,
                (int) Math.round(100.0 * completed / total)
        );
    }
    public Map<String, String> getLessonStatuses(
            UUID registrationId
    ) {
        return learningProcessDAO.findLessonStatuses(registrationId);
    }

    public int getCompletedCount(UUID registrationId, List<Lesson> orderedLessons) {
        Map<String, String> statuses = getLessonStatuses(registrationId);
        return (int) orderedLessons.stream()
                .filter(l -> "completed".equals(statuses.get(l.getId().toString())))
                .count();
    }
}