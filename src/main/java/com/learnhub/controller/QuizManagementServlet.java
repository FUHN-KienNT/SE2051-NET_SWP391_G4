package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.ModuleDAO;
import com.learnhub.dao.QuestionDAO;
import com.learnhub.entity.Module;
import com.learnhub.entity.Question;
import com.learnhub.entity.Quiz;
import com.learnhub.entity.User;
import com.learnhub.service.QuizManagementService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.Set;
import java.util.HashSet;

/**
 * Expert Quiz List / Detail controller.
 */
@WebServlet(
        name = "QuizManagementServlet",
        urlPatterns = {
                "/expert/quizzes",
                "/expert/quizzes/detail"
        }
)
public class QuizManagementServlet extends HttpServlet {
    private static final String SESS_QUIZ_COURSE_ID = "quizList_courseId";
    private static final String SESS_QUIZ_MODULE_ID = "quizList_moduleId";
    private static final String SESS_QUIZ_STATUS = "quizList_status";
    private static final String SESS_QUIZ_KEYWORD = "quizList_keyword";

    private final QuizManagementService service = new QuizManagementService();
    private final ModuleDAO moduleDAO = new ModuleDAO();

    private final QuestionDAO questionDAO = new QuestionDAO();

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {
        User user = ControllerSupport.currentUser(req);

        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String path = req.getServletPath();

        if ("/expert/quizzes/detail".equals(path)) {
            handleDetailGet(req, resp, user);
            return;
        }

        handleListGet(req, resp, user);
    }

    private void handleDetailGet(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {
        UUID courseId = ControllerSupport.optionalUuid(req.getParameter("courseId"));
        UUID defaultFilterModuleId = ControllerSupport.optionalUuid(req.getParameter("moduleId"));

        String id = req.getParameter("id");
        if ((id == null || id.isBlank())) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                if (courseId == null) {
                    courseId = (UUID) session.getAttribute(SESS_QUIZ_COURSE_ID);
                }
                if (defaultFilterModuleId == null) {
                    defaultFilterModuleId = (UUID) session.getAttribute(SESS_QUIZ_MODULE_ID);
                }
            }
        }

        List<UUID> selectedQuestionIds = new ArrayList<>();
        Quiz quiz = null;

        if (id != null && !id.isBlank()) {
            UUID quizId = ControllerSupport.optionalUuid(id);
            if (quizId != null) {
                // Không cho phép truy cập màn hình chỉnh sửa với Quiz đã được sử dụng
                if (service.isUsed(quizId)) {
                    redirectToList(req, resp, "cannotEditUsedQuiz=true");
                    return;
                }
                quiz = service.get(quizId);
                if (quiz != null) {
                    req.setAttribute("quiz", quiz);
                    defaultFilterModuleId = quiz.getModuleId();
                    selectedQuestionIds = service.getQuestionIds(quizId);

                    // Khi sửa Quiz đã có, luôn lấy đúng khóa học của module thuộc Quiz đó
                    if (quiz.getCourseId() != null) {
                        courseId = quiz.getCourseId();
                    } else if (quiz.getModuleId() != null) {
                        Module module = moduleDAO.findById(quiz.getModuleId());
                        if (module != null) {
                            courseId = module.getCourseId();
                        }
                    }
                }
            }
        }

        if (defaultFilterModuleId != null) {
            Module module = moduleDAO.findById(defaultFilterModuleId);
            if (module != null) {
                courseId = module.getCourseId();
            }
        } else if (courseId != null) {
            // Nếu tạo Quiz mới khi đã chọn trước Khóa học (nhưng chưa chọn Module cụ thể),
            // tự động chọn sẵn Module đầu tiên của khóa học đó để giữ mạch thao tác
            List<Module> courseModules = moduleDAO.findByCourseId(courseId);
            if (!courseModules.isEmpty()) {
                defaultFilterModuleId = courseModules.get(0).getId();
            }
        }

        loadDetailReferenceData(req, user, courseId);
        loadQuestionsForDetail(req, selectedQuestionIds);
        req.setAttribute("selectedQuestionIds", selectedQuestionIds);
        req.setAttribute("defaultFilterModuleId", defaultFilterModuleId);

        req.getRequestDispatcher("/WEB-INF/views/expert/quiz-detail.jsp").forward(req, resp);
    }

    private void handleListGet(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);

        String resetParam = req.getParameter("reset");
        boolean isReset = "true".equalsIgnoreCase(resetParam) || "1".equals(resetParam);

        if (isReset) {
            session.removeAttribute(SESS_QUIZ_COURSE_ID);
            session.removeAttribute(SESS_QUIZ_MODULE_ID);
            session.removeAttribute(SESS_QUIZ_STATUS);
            session.removeAttribute(SESS_QUIZ_KEYWORD);
        }

        UUID courseId = null;
        UUID moduleId = null;
        String status = "";
        String keyword = "";

        if (!isReset) {
            boolean isFilterSubmit = req.getParameter("filter") != null;
            boolean isCourseFilter = req.getParameter("courseFilter") != null;

            if (isCourseFilter) {
                courseId = ControllerSupport.resolveCoursePickerFilter(
                        req, session, SESS_QUIZ_COURSE_ID, SESS_QUIZ_MODULE_ID);
                if (courseId != null) {
                    Object savedMod = session.getAttribute(SESS_QUIZ_MODULE_ID);
                    if (savedMod instanceof UUID prevModId) {
                        Module pm = moduleDAO.findById(prevModId);
                        if (pm != null && courseId.equals(pm.getCourseId())) {
                            moduleId = prevModId;
                        } else {
                            session.removeAttribute(SESS_QUIZ_MODULE_ID);
                        }
                    }
                }
            } else {
                courseId = ControllerSupport.resolveUuidFilter(
                        req, session, "courseId", SESS_QUIZ_COURSE_ID, isFilterSubmit);
                moduleId = ControllerSupport.resolveUuidFilter(
                        req, session, "moduleId", SESS_QUIZ_MODULE_ID, isFilterSubmit);
            }

            status = ControllerSupport.resolveStringFilter(
                    req, session, "status", SESS_QUIZ_STATUS, isFilterSubmit);
            keyword = ControllerSupport.resolveStringFilter(
                    req, session, "keyword", SESS_QUIZ_KEYWORD, isFilterSubmit);
            if (keyword != null && keyword.length() > 120) {
                keyword = keyword.substring(0, 120);
            }
        }

        if (moduleId != null) {
            Module m = moduleDAO.findById(moduleId);
            if (m != null) {
                if (courseId != null && !courseId.equals(m.getCourseId())) {
                    courseId = m.getCourseId();
                    session.setAttribute(SESS_QUIZ_COURSE_ID, courseId);
                }
            } else {
                moduleId = null;
                session.removeAttribute(SESS_QUIZ_MODULE_ID);
            }
        }

        loadCourseOptions(req, user, courseId);

        req.setAttribute("keyword", keyword == null ? "" : keyword);

        req.setAttribute("moduleId", moduleId);

        req.setAttribute("status", status == null ? "" : status);

        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            UUID quizId = ControllerSupport.optionalUuid(req.getParameter("id"));
            if (service.isUsed(quizId)) {
                redirectToList(req, resp, courseId, "cannotDelete=true");
                return;
            }

            boolean ok = service.delete(user.getId(), quizId);
            redirectToList(req, resp, courseId, "deleted=" + ok);
            return;
        }

        if ("hide".equalsIgnoreCase(action)) {
            UUID quizId = ControllerSupport.optionalUuid(req.getParameter("id"));

            boolean ok = service.hide(user.getId(), quizId);

            redirectToList(req, resp, courseId, "hidden=" + ok);

            return;
        }

        if ("unhide".equalsIgnoreCase(action)) {
            UUID quizId = ControllerSupport.optionalUuid(req.getParameter("id"));
            boolean ok = service.unhide(user.getId(), quizId);

            redirectToList(req, resp, courseId, "unhidden=" + ok);
            return;
        }

        List<Quiz> quizzes = service.findByExpert(user.getId(), keyword, moduleId, courseId, status);
        for (Quiz q : quizzes) {
            if (service.isUsed(q.getId())) {
                q.setUsedCount(1);
            }
        }
        req.setAttribute("quizzes", quizzes);

        req.getRequestDispatcher("/WEB-INF/views/expert/quiz-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User user = ControllerSupport.currentUser(req);

        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        UUID id = ControllerSupport.optionalUuid(req.getParameter("id"));

        UUID courseId = ControllerSupport.optionalUuid(req.getParameter("courseId"));

        UUID moduleId = ControllerSupport.optionalUuid(req.getParameter("moduleId"));
        if (moduleId != null) {
            Module m = moduleDAO.findById(moduleId);
            if (m != null) {
                courseId = m.getCourseId();
            } else {
                moduleId = null;
            }
        }

        // Không cho phép chỉnh sửa bài kiểm tra đã được sử dụng (trong bài học hoặc đã có lượt nộp bài)
        if (id != null && service.isUsed(id)) {
            redirectToList(req, resp, "cannotEditUsedQuiz=true");
            return;
        }

        String title = req.getParameter("title");

        String status = req.getParameter("status");
        if (status == null || status.isBlank()) {
            status = AppConstants.QuizStatus.PUBLISHED;
        }

        String imageUrl = req.getParameter("imageUrl");

        Integer timeLimit = parseInteger(req.getParameter("timeLimit"));

        BigDecimal passScore = parseBigDecimal(req.getParameter("passScore"));

        List<UUID> questionIds = new ArrayList<>();

        String[] rawQuestionIds = req.getParameterValues("questionId");

        if (rawQuestionIds != null) {
            for (String raw : rawQuestionIds) {
                UUID questionId = ControllerSupport.optionalUuid(raw);

                if (questionId != null
                        && !questionIds.contains(questionId)) {
                    questionIds.add(questionId);
                }
            }
        }

        // Không cho thêm câu hỏi đã ẩn vào quiz
        // (câu đã ẩn nhưng đang có sẵn trong quiz thì được giữ lại)
        List<UUID> oldQuestionIds = id == null
                        ? new ArrayList<>()
                        : service.getQuestionIds(id);

        List<UUID> rejectedIds = new ArrayList<>();

        for (UUID qid : questionIds) {
            Question q = questionDAO.findById(qid);

            if (q != null
                    && "hidden".equalsIgnoreCase(q.getStatus())
                    && !oldQuestionIds.contains(qid)) {
                rejectedIds.add(qid);
            }
        }

        questionIds.removeAll(rejectedIds);

        int titleChars = (title == null) ? 0 : title.length();
        String errorMessage = "Không thể lưu Quiz. Vui lòng kiểm tra Module, tiêu đề (tối đa 120 ký tự), thời gian (1-600 phút), điểm đạt (0-10) và các câu hỏi được chọn.";
        if (title == null || title.trim().isEmpty()) {
            errorMessage = "Tên bài kiểm tra không được để trống.";
        } else if (titleChars > 120) {
            errorMessage = "Tên bài kiểm tra không được vượt quá 120 ký tự (bao gồm cả khoảng trắng, hiện tại: " + titleChars + " ký tự).";
        } else if (timeLimit == null || timeLimit < 1 || timeLimit > 600) {
            errorMessage = "Thời gian làm bài phải từ 1 đến 600 phút (không để trống).";
        }

        if (!rejectedIds.isEmpty()) {
            errorMessage =
                    "Không thể thêm câu hỏi đã ẩn vào Quiz. Các câu hỏi đó đã được bỏ chọn.";
        }

        boolean ok = rejectedIds.isEmpty() && (titleChars <= 120) && service.save(user.getId(), id, moduleId, title,
                timeLimit, passScore, status, imageUrl, questionIds);

        if (ok) {
            redirectToList(req, resp, "saved=true");

            return;
        }

        Quiz formQuiz = new Quiz();

        formQuiz.setId(id);
        formQuiz.setModuleId(moduleId);
        formQuiz.setTitle(title);
        formQuiz.setTimeLimit(timeLimit);
        formQuiz.setStatus(status);
        formQuiz.setImageUrl(imageUrl);

        if (passScore != null) {
            formQuiz.setPassScore(passScore);
        } else {
            formQuiz.setPassScore(
                    new BigDecimal("5.0")
            );
        }

        req.setAttribute("quiz", formQuiz);
        req.setAttribute("selectedQuestionIds", questionIds);
        req.setAttribute("error", errorMessage);
        req.setAttribute("defaultFilterModuleId", moduleId);

        loadDetailReferenceData(req, user, courseId);
        loadQuestionsForDetail(req, questionIds);

        req.getRequestDispatcher("/WEB-INF/views/expert/quiz-detail.jsp").forward(req, resp);
    }

    private void loadDetailReferenceData(HttpServletRequest req, User user, UUID courseId) {
        req.setAttribute("courses", courseDAO.findByExpertId(user.getId()));
        req.setAttribute("courseId", courseId);
        req.setAttribute("course", courseId == null ? null : courseDAO.findById(courseId));

        List<Module> allModules = new ArrayList<>(moduleDAO.findByExpertId(user.getId()));
        if (courseId != null) {
            Set<UUID> existingModIds = new HashSet<>();
            for (Module m : allModules) {
                existingModIds.add(m.getId());
            }
            for (Module cm : moduleDAO.findByCourseId(courseId)) {
                if (!existingModIds.contains(cm.getId())) {
                    allModules.add(cm);
                }
            }
        }
        req.setAttribute("modules", allModules);
    }

    private void loadQuestionsForDetail(HttpServletRequest req, List<UUID> selectedQuestionIds) {
        List<Question> questions = questionDAO.search(null, null, null, null, null);
        if (!selectedQuestionIds.isEmpty()) {
            Set<UUID> loadedIds = new HashSet<>();
            for (Question q : questions) {
                loadedIds.add(q.getId());
            }
            for (UUID qId : selectedQuestionIds) {
                if (!loadedIds.contains(qId)) {
                    Question extra = questionDAO.findById(qId);
                    if (extra != null) {
                        questions.add(extra);
                        loadedIds.add(qId);
                    }
                }
            }
        }
        req.setAttribute("questions", filterHidden(questions, selectedQuestionIds));
    }

    private void loadCourseOptions(HttpServletRequest req, User user, UUID courseId) {
        req.setAttribute("courses", courseDAO.findByExpertId(user.getId()));
        req.setAttribute("courseId", courseId);
        req.setAttribute("course", courseId == null ? null : courseDAO.findById(courseId));
        if (courseId == null) {
            req.setAttribute("courseHasNoModules", false);
            req.setAttribute("modules", moduleDAO.findByExpertId(user.getId()));
        } else {
            List<Module> courseModules = moduleDAO.findByCourseId(courseId);
            if (courseModules.isEmpty()) {
                req.setAttribute("courseHasNoModules", true);
                req.setAttribute("modules", moduleDAO.findByExpertId(user.getId()));
            } else {
                req.setAttribute("courseHasNoModules", false);
                req.setAttribute("modules", courseModules);
            }
        }
    }

    private void redirectToList(
            HttpServletRequest req,
            HttpServletResponse resp,
            String result)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/expert/quizzes?" + result);
    }

    private void redirectToList(
            HttpServletRequest req,
            HttpServletResponse resp,
            UUID courseId,
            String result)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/expert/quizzes?" + result
                + (courseId == null ? "" : "&courseId=" + courseId));
    }

    /**
     * Loại bỏ câu hỏi đã ẩn khỏi danh sách chọn,
     * trừ những câu đang nằm sẵn trong quiz (để Expert còn bỏ chọn được).
     */
    private List<Question> filterHidden(
            List<Question> all,
            List<UUID> selectedIds) {
        List<Question> result = new ArrayList<>();

        for (Question q : all) {
            boolean hidden = "hidden".equalsIgnoreCase(q.getStatus());

            if (!hidden || selectedIds.contains(q.getId())) {
                result.add(q);
            }
        }

        return result;
    }

    private Integer parseInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        try {
            return Integer.valueOf(value.trim());

        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        if (value == null || value.isBlank()) {
            return new BigDecimal("5.0");
        }

        try {
            return new BigDecimal(value.trim());

        } catch (NumberFormatException e) {
            return null;
        }
    }
}
