package com.learnhub.service;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.LessonDAO;
import com.learnhub.dao.ModuleDAO;
import com.learnhub.dao.QuizDAO;
import com.learnhub.entity.Quiz;
import com.learnhub.entity.Question;
import com.learnhub.dto.LessonDTO;
import com.learnhub.dto.ManagerDashboardDTO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Module;
import com.learnhub.entity.Lesson;
import com.learnhub.entity.User;
import com.learnhub.constant.AppConstants;
import com.learnhub.util.CloudinaryClient;
import com.learnhub.util.LessonHtml;
import com.learnhub.util.YouTubeVideo;

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
    private final QuizDAO quizDAO;

    public void requireCourseAccess(UUID expertId, UUID courseId) {
        Course course = courseId == null ? null : courseDAO.findById(courseId);
        if (expertId == null || course == null
                || !expertId.equals(course.getExpertId())) {
            throw new SecurityException("Course access denied.");
        }
    }

    private Module requireModuleAccess(UUID expertId, UUID moduleId) {
        Module module = moduleId == null ? null : moduleDAO.findById(moduleId);
        if (module == null) {
            throw new SecurityException("Module access denied.");
        }
        requireCourseAccess(expertId, module.getCourseId());
        return module;
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
        this(lessonDAO, courseDAO, moduleDAO, new QuizDAO());
    }

    public LessonService(LessonDAO lessonDAO, CourseDAO courseDAO, ModuleDAO moduleDAO, QuizDAO quizDAO) {
        this.lessonDAO = lessonDAO;
        this.courseDAO = courseDAO;
        this.moduleDAO = moduleDAO;
        this.quizDAO = quizDAO;
    }

    public Course getCourseForExpert(UUID expertId, UUID courseId) {
        Course course = courseDAO.findCourseWithLessonSummaries(courseId);
        if (expertId == null || course == null || !expertId.equals(course.getExpertId())) {
            throw new SecurityException("Course access denied.");
        }
        return course;
    }

    public Map<UUID, Integer> getNextLessonOrders(Course course, UUID editedLessonId) {
        Map<UUID, Integer> orders = new LinkedHashMap<>();
        if (course == null || course.getModules() == null) return orders;
        for (Module module : course.getModules()) {
            int count = module.getLessons().size();
            if (module.getLessons().stream().anyMatch(lesson -> lesson.getId().equals(editedLessonId))) count--;
            orders.put(module.getId(), count + 1);
        }
        return orders;
    }

    public LessonDTO getLesson(UUID expertId, UUID lessonId) {
        Lesson l = requireLessonAccess(expertId, lessonId);
        LessonDTO dto = new LessonDTO(l.getId(), l.getModuleId(), l.getTitle(), l.getContent(), l.getOrderIndex());
        dto.setMaterialUrl(l.getMaterialUrl());
        dto.setDurationMinutes(l.getDurationMinutes());
        dto.setPublicationStatus(l.getPublicationStatus());
        dto.setType(l.getType());
        dto.setVideoUrl(l.getVideoUrl());
        dto.setQuizId(l.getQuizId());
        return dto;
    }

    public record LessonListRow(Module module, Lesson lesson) {
        public Module getModule() { return module; }
        public Lesson getLesson() { return lesson; }
    }

    public record LessonListData(List<LessonListRow> rows, String sort,
                                 String direction, String status, UUID moduleId) {
        public Map<Module, List<Lesson>> lessonsByModule() {
            Map<Module, List<Lesson>> groups = new LinkedHashMap<>();
            rows.stream().sorted(Comparator
                    .comparingInt((LessonListRow row) -> row.module().getOrderIndex())
                    .thenComparing(row -> row.module().getId(), Comparator.nullsLast(Comparator.naturalOrder())))
                    .forEach(row -> {
                        List<Lesson> lessons = groups.computeIfAbsent(row.module(), module -> new ArrayList<>());
                        if (row.lesson() != null) lessons.add(row.lesson());
                    });
            return groups;
        }
    }

    public LessonListData buildLessonList(List<Module> modules, String sort,
                                          String direction, String status, UUID moduleId) {
        return buildLessonList(modules, sort, direction, status, moduleId, "");
    }

    public LessonListData buildLessonList(List<Module> modules, String sort,
                                          String direction, String status, UUID moduleId, String search) {
        String keyword = search == null ? "" : search.strip().toLowerCase(Locale.ROOT);
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
                    if (status.isEmpty() && keyword.isEmpty()) rows.add(new LessonListRow(module, null));
                } else {
                    for (Lesson lesson : lessons) {
                        if ((status.isEmpty() || status.equals(lesson.getPublicationStatus()))
                                && (keyword.isEmpty() || (lesson.getTitle() != null
                                && lesson.getTitle().toLowerCase(Locale.ROOT).contains(keyword)))) {
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

    public record LessonSaveResult(boolean saved, Map<String, String> errors) {}

    public boolean saveLesson(UUID expertId, LessonDTO dto) {
        return saveLesson(expertId, null, dto).saved();
    }

    public LessonSaveResult saveLesson(UUID expertId, UUID courseId, LessonDTO dto) {
        if (dto == null) return new LessonSaveResult(false, Map.of("lesson", "Missing lesson."));
        dto.setPublicationStatus(AppConstants.LessonStatus.DRAFT);
        Map<String, String> errors = validateLesson(expertId, courseId, dto);
        if (!errors.isEmpty()) return new LessonSaveResult(false, errors);

        Lesson lesson = new Lesson(dto.getId(), dto.getModuleId(), dto.getTitle(),
                "quiz".equals(dto.getType()) ? "" : LessonHtml.sanitize(dto.getContent()), dto.getOrderIndex());
        lesson.setMaterialUrl(dto.getMaterialUrl());
        lesson.setDurationMinutes(dto.getDurationMinutes());
        lesson.setType(dto.getType());
        lesson.setVideoUrl("video".equals(dto.getType()) ? dto.getVideoUrl().strip() : null);
        lesson.setQuizId("quiz".equals(dto.getType()) ? dto.getQuizId() : null);
        lesson.setPublicationStatus(AppConstants.LessonStatus.DRAFT);
        return new LessonSaveResult(lessonDAO.save(lesson), Map.of());
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
        return validateLesson(expertId, null, dto);
    }

    private Map<String, String> validateLesson(UUID expertId, UUID courseId, LessonDTO dto) {
        if (courseId != null) requireCourseAccess(expertId, courseId);
        Map<String, String> errors = new LinkedHashMap<>();
        if (dto.getDurationMinutes() == null || dto.getDurationMinutes() < 1
                || dto.getDurationMinutes() > 1440) {
            errors.put("durationMinutes", "Estimated duration must be a whole number of minutes between 1 and 1440.");
        }
        if (dto.getModuleId() == null) {
            errors.put("moduleId", "Please select a valid module.");
        } else {
            Module module = moduleDAO.findById(dto.getModuleId());
            if (module == null) throw new SecurityException("Module access denied.");
            if (courseId != null && !courseId.equals(module.getCourseId())) {
                throw new SecurityException("Module does not belong to this course.");
            }
            if (courseId == null) requireCourseAccess(expertId, module.getCourseId());
            Lesson existing = dto.getId() == null ? null : lessonDAO.findById(dto.getId());
            if (existing != null && !dto.getModuleId().equals(existing.getModuleId())) {
                Module source = requireModuleAccess(expertId, existing.getModuleId());
                if (courseId != null && !courseId.equals(source.getCourseId())) {
                    throw new SecurityException("Lesson does not belong to this course.");
                }
            }
        }
        if (dto.getTitle() == null || dto.getTitle().isBlank()) {
            errors.put("title", "Please enter a lesson title.");
        } else if (dto.getTitle().codePointCount(0, dto.getTitle().length()) > 255) {
            errors.put("title", "Lesson title must not exceed 255 characters.");
        }
        String type = dto.getType() == null ? "" : dto.getType();
        switch (type) {
            case "content" -> {
                if (!LessonHtml.hasText(dto.getContent())) errors.put("content", "Please enter lesson content.");
            }
            case "video" -> {
                if (YouTubeVideo.videoId(dto.getVideoUrl()) == null)
                    errors.put("videoUrl", "Please enter a valid YouTube video URL.");
            }
            case "quiz" -> {
                Quiz quiz = quizDAO.findById(dto.getQuizId());
                if (quiz == null || !java.util.Objects.equals(dto.getModuleId(), quiz.getModuleId())
                        || !quiz.isPublished()) {
                    errors.put("quizId", "Please select a published quiz from the selected module.");
                }
            }
            default -> errors.put("type", "Please select a valid lesson type.");
        }
        if (dto.getOrderIndex() < 1) {
            errors.put("orderIndex", "Order index must be a whole number greater than or equal to 1.");
        } else if (dto.getModuleId() != null) {
            int count = lessonDAO.countByModuleId(dto.getModuleId(), dto.getId());
            if (dto.getOrderIndex() > count + 1)
                errors.put("orderIndex", "Maximum allowed order index is " + (count + 1) + ".");
        }
        return errors;
    }

    public record LessonListFilter(String sort, String direction, String status,
                                   UUID moduleId, String search) {}

    public LessonListFilter lessonListFilter(String sort, String direction, String durationSort,
                                             String status, String moduleId, String search) {
        if (durationSort != null) {
            sort = "asc".equals(durationSort) || "desc".equals(durationSort) ? "duration" : "module";
            direction = durationSort;
        }
        UUID selectedModule = moduleId == null || moduleId.isBlank()
                ? null : UUID.fromString(moduleId.strip());
        return new LessonListFilter(sort, direction, status, selectedModule,
                search == null ? "" : search.strip());
    }

    public LessonListData buildLessonList(List<Module> modules, LessonListFilter filter) {
        return buildLessonList(modules, filter.sort(), filter.direction(), filter.status(),
                filter.moduleId(), filter.search());
    }

    public Lesson getLessonForManager(User manager, UUID lessonId) {
        requireManager(manager);
        Lesson lesson = lessonDAO.findById(lessonId);
        if (lesson == null) throw new IllegalArgumentException("Lesson not found.");
        return lesson;
    }

    public record LessonPreviewData(Lesson lesson, Quiz quiz,
                                    List<Question> questions) {}

    public LessonPreviewData getLessonPreview(User user, UUID lessonId) {
        if (user == null || !(AppConstants.Role.EXPERT.equalsIgnoreCase(user.getRoleCode())
                || AppConstants.Role.MANAGER.equalsIgnoreCase(user.getRoleCode()))) {
            throw new SecurityException("Expert or Manager access required.");
        }
        Lesson lesson = lessonDAO.findById(lessonId);
        if (lesson == null) {
            throw new IllegalArgumentException("Lesson not found.");
        }
        if (AppConstants.Role.EXPERT.equalsIgnoreCase(user.getRoleCode())) {
            requireCourseAccess(user.getId(), lesson.getCourseId());
        }
        Quiz quiz = null;
        List<com.learnhub.entity.Question> questions = List.of();
        if ("quiz".equals(lesson.getType())) {
            quiz = quizDAO.findById(lesson.getQuizId());
            if (quiz != null && lesson.getModuleId().equals(quiz.getModuleId())) {
                questions = quizDAO.findQuestions(quiz.getId());
            } else {
                quiz = null;
            }
        }
        return new LessonPreviewData(lesson, quiz, questions);
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

    public Course getCourseForLessonReview(User manager, UUID courseId) {
        requireManager(manager);
        Course course = courseDAO.findCourseWithLessonSummaries(courseId);
        if (course == null) throw new IllegalArgumentException("Course not found.");
        return course;
    }

    public List<ManagerDashboardDTO.PendingReviewItem> getCoursesAwaitingReview(User manager) {
        requireManager(manager);
        return lessonDAO.findCoursesAwaitingReview(0);
    }

    public boolean reviewLesson(User manager, UUID courseId, UUID lessonId,
                                Timestamp expectedUpdatedAt, String decision) {
        return reviewLesson(manager, courseId, lessonId, expectedUpdatedAt, decision, null);
    }

    public boolean reviewLesson(User manager, UUID courseId, UUID lessonId,
                                Timestamp expectedUpdatedAt, String decision, String declineReason) {
        requireManager(manager);
        if (courseId == null || lessonId == null || expectedUpdatedAt == null
                || !(AppConstants.LessonStatus.PUBLISHED.equals(decision)
                    || AppConstants.LessonStatus.DECLINE.equals(decision))) {
            throw new IllegalArgumentException("Invalid lesson review.");
        }
        String reason = null;
        if (AppConstants.LessonStatus.DECLINE.equals(decision)) {
            reason = declineReason == null ? "" : declineReason.strip();
            if (reason.isEmpty() || reason.codePoints().allMatch(
                    c -> Character.isWhitespace(c) || Character.isSpaceChar(c)
                            || Character.getType(c) == Character.FORMAT)) {
                throw new IllegalArgumentException("Please enter a reason for declining this lesson.");
            }
        }
        return lessonDAO.reviewPublication(courseId, lessonId, expectedUpdatedAt, decision, reason);
    }

    public String attachMaterial(UUID expertId, UUID lessonId,
                                 InputStream fileStream, String filename) {
        Lesson lesson = requireLessonAccess(expertId, lessonId);
        String secureUrl = CloudinaryClient.uploadFile(fileStream, filename);
        lesson.setMaterialUrl(secureUrl);
        lesson.setPublicationStatus(AppConstants.LessonStatus.DRAFT);
        if (!lessonDAO.update(lesson)) throw new IllegalStateException("Cannot attach lesson material.");
        return secureUrl;
    }
}
