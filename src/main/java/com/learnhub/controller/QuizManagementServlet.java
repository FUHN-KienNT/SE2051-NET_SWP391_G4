package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.ModuleDAO;
import com.learnhub.dao.QuestionDAO;
import com.learnhub.entity.Course;
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

    private final QuizManagementService service =
            new QuizManagementService();

    private final ModuleDAO moduleDAO =
            new ModuleDAO();

    private final QuestionDAO questionDAO =
            new QuestionDAO();

    private final CourseDAO courseDAO =
            new CourseDAO();

    // =========================================================
    // CURRENT USER
    // =========================================================

    private User currentUser(HttpServletRequest req) {

        HttpSession session = req.getSession(false);

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute(
                AppConstants.SessionKey.CURRENT_USER
        );
    }

    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req);

        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String path = req.getServletPath();

        // =====================================================
        // QUIZ DETAIL
        // =====================================================

        if ("/quiz/detail".equals(path)) {

            handleDetailGet(req, resp, user);
            return;
        }

        // =====================================================
        // QUIZ LIST
        // =====================================================

        handleListGet(req, resp, user);
    }

    // =========================================================
    // QUIZ DETAIL GET
    // =========================================================

    private void handleDetailGet(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        UUID courseId =
                parseUUID(req.getParameter("courseId"));

        List<Course> courses = courseDAO.findByExpertId(user.getId());
        req.setAttribute("courses", courses);

        Course course = courseId == null
                ? null
                : courseDAO.findById(courseId);

        List<Module> modules;

        if (courseId != null) {
            modules = moduleDAO.findByCourseId(courseId);
        } else {
            modules = moduleDAO.findByExpertId(user.getId());
        }

        List<Question> questions =
                questionDAO.search(null, null, null, null, null);

        List<UUID> selectedQuestionIds =
                new ArrayList<>();

        req.setAttribute("course", course);
        req.setAttribute("courseId", courseId);
        req.setAttribute("modules", modules);
        req.setAttribute("questions", questions);
        req.setAttribute(
                "selectedQuestionIds",
                selectedQuestionIds
        );

        UUID defaultFilterModuleId = parseUUID(req.getParameter("moduleId"));

        // -----------------------------------------------------
        // EDIT EXISTING QUIZ
        // -----------------------------------------------------

        String id = req.getParameter("id");

        if (id != null && !id.isBlank()) {

            UUID quizId = parseUUID(id);

            if (quizId != null) {

                Quiz quiz = service.get(quizId);

                if (quiz != null) {

                    req.setAttribute("quiz", quiz);
                    defaultFilterModuleId = quiz.getModuleId();

                    selectedQuestionIds =
                            service.getQuestionIds(quizId);

                    req.setAttribute(
                            "selectedQuestionIds",
                            selectedQuestionIds
                    );

                    /*
                     * If courseId was not supplied when opening
                     * the Edit page, determine the course from
                     * the quiz's module.
                     */
                    if (courseId == null) {

                        Module module =
                                moduleDAO.findById(
                                        quiz.getModuleId()
                                );

                        if (module != null) {

                            courseId =
                                    module.getCourseId();

                            course =
                                    courseDAO.findById(
                                            courseId
                                    );

                            req.setAttribute(
                                    "courseId",
                                    courseId
                            );

                            req.setAttribute(
                                    "course",
                                    course
                            );

                            req.setAttribute(
                                    "modules",
                                    moduleDAO.findByCourseId(
                                            courseId
                                    )
                            );
                        }
                    }
                }
            }
        }

        // Ẩn các câu hỏi đã ẩn (trừ câu đang nằm sẵn trong quiz đang sửa)
        req.setAttribute(
                "questions",
                filterHidden(questions, selectedQuestionIds)
        );

        req.setAttribute("defaultFilterModuleId", defaultFilterModuleId);

        req.getRequestDispatcher(
                "/WEB-INF/views/expert/quiz-detail.jsp"
        ).forward(req, resp);
    }

    // =========================================================
    // QUIZ LIST GET
    // =========================================================

    private void handleListGet(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        String keyword =
                req.getParameter("keyword");

        UUID courseId =
                parseUUID(req.getParameter("courseId"));

        UUID moduleId =
                parseUUID(req.getParameter("moduleId"));

        String status =
                req.getParameter("status");

        List<Course> courses = courseDAO.findByExpertId(user.getId());
        req.setAttribute("courses", courses);

        Course course = courseId == null
                ? null
                : courseDAO.findById(courseId);

        List<Module> modules;

        if (courseId != null) {
            modules =
                    moduleDAO.findByCourseId(courseId);
        } else {
            modules =
                    moduleDAO.findByExpertId(user.getId());
        }

        req.setAttribute(
                "keyword",
                keyword == null ? "" : keyword
        );

        req.setAttribute(
                "moduleId",
                moduleId
        );

        req.setAttribute(
                "courseId",
                courseId
        );

        req.setAttribute(
                "status",
                status == null ? "" : status
        );

        req.setAttribute(
                "course",
                course
        );

        req.setAttribute(
                "modules",
                modules
        );

        // =====================================================
        // HIDE / UNHIDE / DELETE
        // =====================================================

        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action) || "hide".equalsIgnoreCase(action)) {

            UUID quizId =
                    parseUUID(req.getParameter("id"));

            boolean ok =
                    service.hide(
                            user.getId(),
                            quizId
                    );

            StringBuilder redirect =
                    new StringBuilder(
                            req.getContextPath()
                                    + "/quiz/manage?hidden="
                                    + ok
                    );

            if (courseId != null) {
                redirect.append(
                        "&courseId="
                ).append(courseId);
            }

            resp.sendRedirect(
                    redirect.toString()
            );

            return;
        }

        if ("unhide".equalsIgnoreCase(action)) {
            UUID quizId = parseUUID(req.getParameter("id"));
            boolean ok = service.unhide(user.getId(), quizId);

            StringBuilder redirect =
                    new StringBuilder(
                            req.getContextPath()
                                    + "/quiz/manage?unhidden="
                                    + ok
                    );

            if (courseId != null) {
                redirect.append("&courseId=").append(courseId);
            }

            resp.sendRedirect(redirect.toString());
            return;
        }

        req.setAttribute(
                "quizzes",
                service.findByExpert(
                        user.getId(),
                        keyword,
                        moduleId,
                        courseId,
                        status
                )
        );

        req.getRequestDispatcher(
                "/WEB-INF/views/expert/quiz-list.jsp"
        ).forward(req, resp);
    }

    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User user = currentUser(req);

        if (user == null) {
            resp.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED
            );
            return;
        }

        // -----------------------------------------------------
        // Read submitted data
        // -----------------------------------------------------

        UUID id =
                parseUUID(req.getParameter("id"));

        UUID courseId =
                parseUUID(req.getParameter("courseId"));

        UUID moduleId =
                parseUUID(req.getParameter("moduleId"));

        String title =
                req.getParameter("title");

        String status =
                req.getParameter("status");
        if (status == null || status.isBlank()) {
            status = "published";
        }

        String imageUrl =
                req.getParameter("imageUrl");

        Integer timeLimit =
                parseInteger(
                        req.getParameter("timeLimit")
                );

        BigDecimal passScore =
                parseBigDecimal(
                        req.getParameter("passScore")
                );

        // -----------------------------------------------------
        // Read selected questions
        // -----------------------------------------------------

        List<UUID> questionIds =
                new ArrayList<>();

        String[] rawQuestionIds =
                req.getParameterValues("questionId");

        if (rawQuestionIds != null) {

            for (String raw : rawQuestionIds) {

                UUID questionId =
                        parseUUID(raw);

                if (questionId != null
                        && !questionIds.contains(questionId)) {

                    questionIds.add(questionId);
                }
            }
        }

        // =====================================================
        // SAVE
        // =====================================================

        // Không cho thêm câu hỏi đã ẩn vào quiz
        // (câu đã ẩn nhưng đang có sẵn trong quiz thì được giữ lại)
        List<UUID> oldQuestionIds =
                id == null
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

        String errorMessage =
                "Không thể lưu Quiz. Vui lòng kiểm tra Module, tiêu đề, thời gian, điểm đạt (0-10) và các câu hỏi được chọn.";

        if (!rejectedIds.isEmpty()) {
            errorMessage =
                    "Không thể thêm câu hỏi đã ẩn vào Quiz. Các câu hỏi đó đã được bỏ chọn.";
        }

        boolean ok =
                rejectedIds.isEmpty()
                        && service.save(
                        user.getId(),
                        id,
                        moduleId,
                        title,
                        timeLimit,
                        passScore,
                        status,
                        imageUrl,
                        questionIds
                );

        // =====================================================
        // SUCCESS
        // =====================================================

        if (ok) {

            StringBuilder redirect =
                    new StringBuilder(
                            req.getContextPath()
                                    + "/quiz/manage?saved=true"
                    );

            if (courseId != null) {

                redirect.append(
                        "&courseId="
                ).append(courseId);
            }

            resp.sendRedirect(
                    redirect.toString()
            );

            return;
        }

        // =====================================================
        // SAVE FAILED
        // =====================================================

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

        req.setAttribute(
                "quiz",
                formQuiz
        );

        req.setAttribute(
                "selectedQuestionIds",
                questionIds
        );

        req.setAttribute(
                "error",
                errorMessage
        );

        // -----------------------------------------------------
        // Reload course/modules/questions
        // -----------------------------------------------------

        List<Course> courses = courseDAO.findByExpertId(user.getId());
        req.setAttribute("courses", courses);

        Course course = courseId == null
                ? null
                : courseDAO.findById(courseId);

        List<Module> modules;

        if (courseId != null) {

            modules =
                    moduleDAO.findByCourseId(courseId);

        } else {

            modules =
                    moduleDAO.findByExpertId(user.getId());
        }

        req.setAttribute(
                "courseId",
                courseId
        );

        req.setAttribute(
                "course",
                course
        );

        req.setAttribute(
                "modules",
                modules
        );

        req.setAttribute(
                "questions",
                filterHidden(
                        questionDAO.search(null, null, null, null, null),
                        questionIds
                )
        );

        req.setAttribute("defaultFilterModuleId", moduleId);

        req.getRequestDispatcher(
                "/WEB-INF/views/expert/quiz-detail.jsp"
        ).forward(req, resp);
    }

    // =========================================================
    // PARSE HELPERS
    // =========================================================

    private UUID parseUUID(String value) {

        if (value == null || value.isBlank()) {
            return null;
        }

        try {
            return UUID.fromString(value.trim());

        } catch (IllegalArgumentException e) {
            return null;
        }
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