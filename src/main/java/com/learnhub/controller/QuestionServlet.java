package com.learnhub.controller;

import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import com.learnhub.service.QuestionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Expert Question Bank:
 * list, create, edit and delete questions.
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

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        /*
         * courseId được giữ xuyên suốt để sidebar
         * (Lesson / Quiz / Question Bank) luôn trỏ đúng khóa học.
         */
        String courseId = readCourseId(req);
        req.setAttribute("courseId", courseId);

        /*
         * QUESTION DETAIL
         */
        if ("/questions/detail".equals(path)) {

            String id = req.getParameter("id");

            if (id != null && !id.isBlank()) {

                try {

                    UUID questionId =
                            UUID.fromString(id);

                    Question question =
                            service.get(questionId);

                    if (question != null) {
                        req.setAttribute(
                                "question",
                                question
                        );
                    }

                } catch (IllegalArgumentException ignored) {
                    /*
                     * Invalid UUID.
                     */
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
        String keyword =
                req.getParameter("keyword");

        String type =
                req.getParameter("type");

        req.setAttribute(
                "keyword",
                keyword == null ? "" : keyword
        );

        req.setAttribute(
                "type",
                type == null ? "" : type
        );

        /*
         * DELETE
         */
        if ("delete".equalsIgnoreCase(
                req.getParameter("action"))) {

            try {

                String id =
                        req.getParameter("id");

                UUID questionId =
                        UUID.fromString(id);

                boolean ok =
                        service.delete(questionId);

                resp.sendRedirect(
                        req.getContextPath()
                        + "/questions/manage?deleted="
                        + ok
                        + courseSuffix(courseId)
                );

            } catch (Exception e) {

                resp.sendRedirect(
                        req.getContextPath()
                        + "/questions/manage?deleted=false"
                        + courseSuffix(courseId)
                );
            }

            return;
        }

        req.setAttribute(
                "questions",
                service.search(keyword, type)
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

        String courseId = readCourseId(req);
        req.setAttribute("courseId", courseId);

        /*
         * Question ID.
         *
         * null = CREATE
         * UUID = UPDATE
         */
        String id =
                req.getParameter("id");

        UUID questionId = null;

        try {

            if (id != null && !id.isBlank()) {
                questionId =
                        UUID.fromString(id);
            }

        } catch (IllegalArgumentException ignored) {
            questionId = null;
        }

        String content =
                req.getParameter("content");

        String type =
                req.getParameter("type");

        /*
         * IMPORTANT:
         * Lấy optionId cùng với optionText.
         */
        String[] optionIds =
                req.getParameterValues("optionId");

        String[] optionTexts =
                req.getParameterValues("optionText");

        String[] correctIndexes =
                req.getParameterValues("correctIndex");

        boolean ok =
                service.save(
                        questionId,
                        content,
                        type,
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
         *
         * Giữ nguyên dữ liệu người dùng vừa nhập.
         */
        Question question =
                new Question(
                        questionId,
                        content,
                        type
                );

        List<QuestionOption> submittedOptions =
                new ArrayList<>();

        Set<Integer> correct =
                new HashSet<>();

        /*
         * Correct indexes.
         */
        if (correctIndexes != null) {

            for (String value : correctIndexes) {

                if (value == null
                        || value.isBlank()) {
                    continue;
                }

                try {

                    correct.add(
                            Integer.parseInt(value)
                    );

                } catch (NumberFormatException ignored) {
                }
            }
        }

        /*
         * Rebuild submitted options
         * so JSP does not lose user's data.
         */
        if (optionTexts != null) {

            for (int i = 0;
                 i < optionTexts.length;
                 i++) {

                QuestionOption option =
                        new QuestionOption();

                /*
                 * Giữ ID cũ.
                 */
                if (optionIds != null
                        && i < optionIds.length
                        && optionIds[i] != null
                        && !optionIds[i].isBlank()) {

                    try {

                        option.setId(
                                UUID.fromString(
                                        optionIds[i]
                                )
                        );

                    } catch (IllegalArgumentException ignored) {
                    }
                }

                option.setQuestionId(questionId);

                option.setOptionText(
                        optionTexts[i] == null
                        ? ""
                        : optionTexts[i]
                );

                option.setCorrect(
                        correct.contains(i)
                );

                submittedOptions.add(option);
            }
        }

        question.setOptions(
                submittedOptions
        );

        req.setAttribute(
                "question",
                question
        );

        req.setAttribute(
                "error",
                "Không thể lưu câu hỏi. "
                + "Single choice cần đúng 1 đáp án; "
                + "Multiple choice cần ít nhất 1 đáp án đúng "
                + "và tối thiểu 2 lựa chọn."
        );

        req.getRequestDispatcher(
                "/WEB-INF/views/expert/question-detail.jsp"
        ).forward(req, resp);
    }

    /**
     * Đọc courseId từ request. Trả về chuỗi rỗng nếu thiếu / sai định dạng.
     */
    private static String readCourseId(HttpServletRequest req) {

        String value = req.getParameter("courseId");

        if (value == null || value.isBlank()) {
            return "";
        }

        try {
            return UUID.fromString(value.trim()).toString();
        } catch (IllegalArgumentException e) {
            return "";
        }
    }

    private static String courseSuffix(String courseId) {
        return courseId == null || courseId.isEmpty()
                ? ""
                : "&courseId=" + courseId;
    }
}

