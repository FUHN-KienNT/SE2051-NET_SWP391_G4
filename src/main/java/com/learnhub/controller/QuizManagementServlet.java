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

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Expert Quiz List / Detail controller.
 */
@WebServlet(
        name = "QuizManagementServlet",
        urlPatterns = {
                "/quiz/manage",
                "/quiz/detail"
        }
)
public class QuizManagementServlet extends HttpServlet {
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

        if ("/quiz/detail".equals(path)) {
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

        loadCourseOptions(req, user, courseId);

        List<Question> questions = questionDAO.search(null, null, null, null, null);

        List<UUID> selectedQuestionIds = new ArrayList<>();

        req.setAttribute("questions", questions);
        req.setAttribute("selectedQuestionIds", selectedQuestionIds);

        UUID defaultFilterModuleId = ControllerSupport.optionalUuid(req.getParameter("moduleId"));

        String id = req.getParameter("id");

        if (id != null && !id.isBlank()) {
            UUID quizId = ControllerSupport.optionalUuid(id);

            if (quizId != null) {
                Quiz quiz = service.get(quizId);

                if (quiz != null) {
                    req.setAttribute("quiz", quiz);
                    defaultFilterModuleId = quiz.getModuleId();

                    selectedQuestionIds = service.getQuestionIds(quizId);

                    req.setAttribute("selectedQuestionIds", selectedQuestionIds);

                    /*
                     * If courseId was not supplied when opening
                     * the Edit page, determine the course from
                     * the quiz's module.
                     */
                    if (courseId == null) {
                        Module module = moduleDAO.findById(quiz.getModuleId());

                        if (module != null) {
                            courseId = module.getCourseId();
                            req.setAttribute("courseId", courseId);

                            req.setAttribute("course", courseDAO.findById(courseId));

                            req.setAttribute("modules", moduleDAO.findByCourseId(courseId));
                        }
                    }
                }
            }
        }

        // Ẩn các câu hỏi đã ẩn (trừ câu đang nằm sẵn trong quiz đang sửa)
        req.setAttribute("questions", filterHidden(questions, selectedQuestionIds));

        req.setAttribute("defaultFilterModuleId", defaultFilterModuleId);

        req.getRequestDispatcher("/WEB-INF/views/expert/quiz-detail.jsp").forward(req, resp);
    }

    private void handleListGet(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");

        UUID courseId = ControllerSupport.optionalUuid(req.getParameter("courseId"));

        UUID moduleId = ControllerSupport.optionalUuid(req.getParameter("moduleId"));

        String status = req.getParameter("status");

        loadCourseOptions(req, user, courseId);

        req.setAttribute("keyword", keyword == null ? "" : keyword);

        req.setAttribute("moduleId", moduleId);

        req.setAttribute("status", status == null ? "" : status);

        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action) || "hide".equalsIgnoreCase(action)) {
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

        req.setAttribute("quizzes", service.findByExpert(user.getId(), keyword, moduleId, courseId, status));

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

        String errorMessage = "Không thể lưu Quiz. Vui lòng kiểm tra Module, tiêu đề, thời gian, điểm đạt (0-10) và các câu hỏi được chọn.";

        if (!rejectedIds.isEmpty()) {
            errorMessage =
                    "Không thể thêm câu hỏi đã ẩn vào Quiz. Các câu hỏi đó đã được bỏ chọn.";
        }

        boolean ok = rejectedIds.isEmpty() && service.save(user.getId(), id, moduleId, title,
                timeLimit, passScore, status, imageUrl, questionIds);

        if (ok) {
            redirectToList(req, resp, courseId, "saved=true");

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

        loadCourseOptions(req, user, courseId);

        req.setAttribute("questions", filterHidden(
                questionDAO.search(null, null, null, null, null), questionIds));

        req.setAttribute("defaultFilterModuleId", moduleId);

        req.getRequestDispatcher("/WEB-INF/views/expert/quiz-detail.jsp").forward(req, resp);
    }

    private void loadCourseOptions(HttpServletRequest req, User user, UUID courseId) {
        req.setAttribute("courses", courseDAO.findByExpertId(user.getId()));
        req.setAttribute("courseId", courseId);
        req.setAttribute("course", courseId == null ? null : courseDAO.findById(courseId));
        req.setAttribute("modules", courseId == null
                ? moduleDAO.findByExpertId(user.getId()) : moduleDAO.findByCourseId(courseId));
    }

    private void redirectToList(HttpServletRequest req, HttpServletResponse resp, UUID courseId, String result)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/quiz/manage?" + result
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
