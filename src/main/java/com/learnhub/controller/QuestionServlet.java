package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.ModuleDAO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Module;
import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import com.learnhub.entity.User;
import com.learnhub.service.QuestionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.*;

/**
 * Expert Question Bank:
 * list, create, edit, hide and import questions.
 */
@WebServlet(
        name = "QuestionServlet",
        urlPatterns = {
            "/questions/manage",
            "/questions/detail"
        }
)
public class QuestionServlet extends HttpServlet {

    private final QuestionService service =
            new QuestionService();
    private final CourseDAO courseDAO =
            new CourseDAO();
    private final ModuleDAO moduleDAO =
            new ModuleDAO();

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute(AppConstants.SessionKey.CURRENT_USER);
    }

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

        UUID courseId = parseUUID(req.getParameter("courseId"));
        UUID moduleId = parseUUID(req.getParameter("moduleId"));

        List<Course> courses = courseDAO.findByExpertId(user.getId());
        req.setAttribute("courses", courses);

        List<Module> modules;
        if (courseId != null) {
            modules = moduleDAO.findByCourseId(courseId);
        } else {
            modules = moduleDAO.findByExpertId(user.getId());
        }
        req.setAttribute("modules", modules);
        req.setAttribute("courseId", courseId != null ? courseId.toString() : "");
        req.setAttribute("moduleId", moduleId);

        /*
         * QUESTION DETAIL
         */
        if ("/questions/detail".equals(path)) {

            String id = req.getParameter("id");

            if (id != null && !id.isBlank()) {
                UUID questionId = parseUUID(id);
                if (questionId != null) {
                    Question question = service.get(questionId);
                    if (question != null) {
                        req.setAttribute("question", question);
                        if (question.getModuleId() != null) {
                            req.setAttribute("moduleId", question.getModuleId());
                            Module mod = moduleDAO.findById(question.getModuleId());
                            if (mod != null && courseId == null) {
                                courseId = mod.getCourseId();
                                req.setAttribute("courseId", courseId.toString());
                                req.setAttribute("modules", moduleDAO.findByCourseId(courseId));
                            }
                        }
                    }
                }
            }

            req.getRequestDispatcher(
                    "/WEB-INF/views/expert/question-detail.jsp"
            ).forward(req, resp);

            return;
        }

        /*
         * QUESTION LIST
         */
        String keyword = req.getParameter("keyword");
        String type = req.getParameter("type");
        String status = req.getParameter("status");

        req.setAttribute("keyword", keyword == null ? "" : keyword);
        req.setAttribute("type", type == null ? "" : type);
        req.setAttribute("status", status == null ? "" : status);

        /*
         * HIDE / UNHIDE / DELETE
         */
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action) || "hide".equalsIgnoreCase(action)) {
            UUID questionId = parseUUID(req.getParameter("id"));
            boolean ok = service.hide(questionId);
            resp.sendRedirect(
                    req.getContextPath()
                    + "/questions/manage?hidden="
                    + ok
                    + courseSuffix(courseId)
            );
            return;
        }

        if ("unhide".equalsIgnoreCase(action)) {
            UUID questionId = parseUUID(req.getParameter("id"));
            boolean ok = service.unhide(questionId);
            resp.sendRedirect(
                    req.getContextPath()
                    + "/questions/manage?unhidden="
                    + ok
                    + courseSuffix(courseId)
            );
            return;
        }

        req.setAttribute(
                "questions",
                service.search(keyword, type, moduleId, courseId, status)
        );

        req.getRequestDispatcher(
                "/WEB-INF/views/expert/question-list.jsp"
        ).forward(req, resp);
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User user = currentUser(req);
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = req.getParameter("action");

        // =====================================================
        // IMPORT FROM DOCS / TEXT
        // =====================================================
        if ("import_docs".equalsIgnoreCase(action)) {
            UUID courseId = parseUUID(req.getParameter("courseId"));
            UUID moduleId = parseUUID(req.getParameter("moduleId"));
            String status = req.getParameter("status");
            if (status == null || status.isBlank()) {
                status = "public";
            }
            String docText = req.getParameter("docText");

            int count = service.importFromDocument(moduleId, status, docText);

            resp.sendRedirect(
                    req.getContextPath()
                    + "/questions/manage?imported=" + count
                    + courseSuffix(courseId)
            );
            return;
        }

        // =====================================================
        // SAVE SINGLE QUESTION
        // =====================================================
        UUID courseId = parseUUID(req.getParameter("courseId"));
        UUID moduleId = parseUUID(req.getParameter("moduleId"));
        req.setAttribute("courseId", courseId != null ? courseId.toString() : "");
        req.setAttribute("moduleId", moduleId);

        UUID questionId = parseUUID(req.getParameter("id"));

        String content = req.getParameter("content");
        String type = req.getParameter("type");
        String status = req.getParameter("status");
        if (status == null || status.isBlank()) {
            status = "public";
        }

        // Check word limit on title / question content
        int wordCount = QuestionService.countWords(content);
        if (wordCount > QuestionService.MAX_WORDS_QUESTION_CONTENT) {
            forwardWithError(req, resp, questionId, moduleId, content, type, status,
                    "Nội dung câu hỏi quá dài (" + wordCount + " từ). Giới hạn tối đa là "
                    + QuestionService.MAX_WORDS_QUESTION_CONTENT + " từ.");
            return;
        }

        String[] optionIds = req.getParameterValues("optionId");
        String[] optionTexts = req.getParameterValues("optionText");
        String[] correctIndexes = req.getParameterValues("correctIndex");

        boolean ok = service.save(
                questionId,
                moduleId,
                content,
                type,
                status,
                optionIds,
                optionTexts,
                correctIndexes
        );

        /*
         * SAVE SUCCESS
         */
        if (ok) {
            resp.sendRedirect(
                    req.getContextPath()
                    + "/questions/manage?saved=true"
                    + courseSuffix(courseId)
            );
            return;
        }

        /*
         * SAVE FAILED
         */
        forwardWithError(req, resp, questionId, moduleId, content, type, status,
                "Không thể lưu câu hỏi. Vui lòng kiểm tra lại: Single choice cần đúng 1 đáp án; "
                + "Multiple choice cần ít nhất 1 đáp án đúng và tối thiểu 2 lựa chọn; "
                + "Điền vào chỗ trống cần ít nhất 1 từ khóa đáp án.");
    }

    private void forwardWithError(
            HttpServletRequest req,
            HttpServletResponse resp,
            UUID questionId,
            UUID moduleId,
            String content,
            String type,
            String status,
            String errorMsg) throws ServletException, IOException {

        User user = currentUser(req);
        UUID courseId = parseUUID(req.getParameter("courseId"));

        Question question = new Question(questionId, content, type);
        question.setModuleId(moduleId);
        question.setStatus(status);

        String[] optionIds = req.getParameterValues("optionId");
        String[] optionTexts = req.getParameterValues("optionText");
        String[] correctIndexes = req.getParameterValues("correctIndex");

        List<QuestionOption> submittedOptions = new ArrayList<>();
        Set<Integer> correct = new HashSet<>();

        if (correctIndexes != null) {
            for (String value : correctIndexes) {
                if (value == null || value.isBlank()) continue;
                try {
                    correct.add(Integer.parseInt(value));
                } catch (NumberFormatException ignored) {}
            }
        }

        if (optionTexts != null) {
            for (int i = 0; i < optionTexts.length; i++) {
                QuestionOption option = new QuestionOption();
                if (optionIds != null && i < optionIds.length && optionIds[i] != null && !optionIds[i].isBlank()) {
                    try {
                        option.setId(UUID.fromString(optionIds[i]));
                    } catch (IllegalArgumentException ignored) {}
                }
                option.setQuestionId(questionId);
                option.setOptionText(optionTexts[i] == null ? "" : optionTexts[i]);
                option.setCorrect(correct.contains(i));
                submittedOptions.add(option);
            }
        }
        question.setOptions(submittedOptions);

        req.setAttribute("question", question);
        req.setAttribute("error", errorMsg);

        if (user != null) {
            req.setAttribute("courses", courseDAO.findByExpertId(user.getId()));
            if (courseId != null) {
                req.setAttribute("modules", moduleDAO.findByCourseId(courseId));
            } else {
                req.setAttribute("modules", moduleDAO.findByExpertId(user.getId()));
            }
        }

        req.getRequestDispatcher(
                "/WEB-INF/views/expert/question-detail.jsp"
        ).forward(req, resp);
    }

    private static UUID parseUUID(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return UUID.fromString(value.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private static String courseSuffix(UUID courseId) {
        return courseId == null ? "" : "&courseId=" + courseId;
    }
}
