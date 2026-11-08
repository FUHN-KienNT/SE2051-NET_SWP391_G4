package com.learnhub.controller;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.ModuleDAO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Module;
import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.QuestionExcelFile;
import com.learnhub.service.QuestionImportResult;
import com.learnhub.service.QuestionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

/**
 * Expert Question Bank:
 * list, create, edit and hide questions, import questions from Excel.
 */
@WebServlet(
        name = "QuestionServlet",
        urlPatterns = {
                "/expert/questions",
                "/expert/questions/detail"
        }
)
@MultipartConfig(maxFileSize = QuestionServlet.MAX_IMPORT_FILE_BYTES,
        maxRequestSize = QuestionServlet.MAX_IMPORT_FILE_BYTES + 1024 * 1024)
public class QuestionServlet extends HttpServlet {

    static final long MAX_IMPORT_FILE_BYTES = 5L * 1024 * 1024;
    private static final String IMPORT_RESULT_KEY = "questionImportResult";

    private final QuestionService service =
            new QuestionService();
    private final CourseDAO courseDAO =
            new CourseDAO();
    private final CourseService courseService = new CourseService();
    private final ModuleDAO moduleDAO =
            new ModuleDAO();

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

        if ("template".equalsIgnoreCase(req.getParameter("action"))) {
            sendImportTemplate(resp);
            return;
        }

        String path = req.getServletPath();

        UUID courseId = ControllerSupport.optionalUuid(req.getParameter("courseId"));
        UUID moduleId = ControllerSupport.optionalUuid(req.getParameter("moduleId"));
        if (moduleId != null && !"/expert/questions/detail".equals(path)) {
            Module m = moduleDAO.findById(moduleId);
            if (m != null) {
                if (courseId != null && !courseId.equals(m.getCourseId())) {
                    courseId = m.getCourseId();
                }
            } else {
                moduleId = null;
            }
        }

        List<Course> courses = courseDAO.findByExpertId(user.getId());
        req.setAttribute("courses", courses);

        List<Module> modules;
        if (courseId != null) {
            List<Module> courseModules = moduleDAO.findByCourseId(courseId);
            if (courseModules.isEmpty()) {
                req.setAttribute("courseHasNoModules", true);
                modules = moduleDAO.findByExpertId(user.getId());
            } else {
                req.setAttribute("courseHasNoModules", false);
                modules = courseModules;
            }
        } else {
            req.setAttribute("courseHasNoModules", false);
            modules = moduleDAO.findByExpertId(user.getId());
        }
        req.setAttribute("modules", modules);
        req.setAttribute("courseId", courseId);
        req.setAttribute("course", courseId != null ? courseDAO.findById(courseId) : null);
        req.setAttribute("moduleId", moduleId);

        // Match Lesson List and Quiz List: show searchable assigned courses in the sidebar.
        int coursePage = 1;
        try {
            coursePage = Integer.parseInt(req.getParameter("coursePage"));
        } catch (NumberFormatException ignored) {
        }
        var navigation = courseService.getAssignedCourseNavigation(
                user.getId(), req.getParameter("courseSearch"), coursePage);
        req.setAttribute("assignedCourses", navigation.courses());
        req.setAttribute("courseSearch", navigation.search());
        req.setAttribute("coursePage", navigation.page());
        req.setAttribute("courseTotalPages", navigation.totalPages());
        req.setAttribute("courseTotal", navigation.totalCourses());

        /*
         * QUESTION DETAIL
         */
        if ("/expert/questions/detail".equals(path)) {

            String id = req.getParameter("id");

            if (id != null && !id.isBlank()) {
                UUID questionId = ControllerSupport.optionalUuid(id);
                if (questionId != null) {
                    Question question = service.get(questionId);
                    if (question != null) {
                        req.setAttribute("question", question);
                        if (question.getModuleId() != null) {
                            moduleId = question.getModuleId();
                            req.setAttribute("moduleId", moduleId);
                            Module mod = moduleDAO.findById(moduleId);
                            if (mod != null) {
                                courseId = mod.getCourseId();
                            }
                        }
                    }
                }
            }

            if (moduleId != null) {
                Module mod = moduleDAO.findById(moduleId);
                if (mod != null) {
                    courseId = mod.getCourseId();
                }
            } else if (courseId != null) {
                List<Module> courseModules = moduleDAO.findByCourseId(courseId);
                if (!courseModules.isEmpty()) {
                    moduleId = courseModules.get(0).getId();
                    req.setAttribute("moduleId", moduleId);
                }
            }

            req.setAttribute("courseId", courseId);
            Course selectedCourse = courseId != null ? courseDAO.findById(courseId) : null;
            req.setAttribute("course", selectedCourse);

            List<Course> detailCourses = new ArrayList<>(courses);
            if (selectedCourse != null) {
                boolean foundCourse = false;
                for (Course c : detailCourses) {
                    if (selectedCourse.getId().equals(c.getId())) {
                        foundCourse = true;
                        break;
                    }
                }
                if (!foundCourse) {
                    detailCourses.add(selectedCourse);
                }
            }
            req.setAttribute("courses", detailCourses);

            // Luôn nạp toàn bộ module của Expert (và bổ sung module của khóa học hiện tại nếu thiếu)
            List<Module> detailModules = new ArrayList<>(moduleDAO.findByExpertId(user.getId()));
            if (courseId != null) {
                Set<UUID> existingModIds = new HashSet<>();
                for (Module m : detailModules) {
                    existingModIds.add(m.getId());
                }
                for (Module cm : moduleDAO.findByCourseId(courseId)) {
                    if (!existingModIds.contains(cm.getId())) {
                        if (selectedCourse != null) {
                            cm.setCourseTitle(selectedCourse.getTitle());
                        }
                        detailModules.add(cm);
                    }
                }
            }
            req.setAttribute("modules", detailModules);

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
        if ("delete".equalsIgnoreCase(action)) {
            UUID questionId = ControllerSupport.optionalUuid(req.getParameter("id"));
            if (service.isUsedInQuiz(questionId)) {
                resp.sendRedirect(
                        req.getContextPath()
                                + "/expert/questions?cannotDelete=true"
                                + courseSuffix(courseId)
                );
                return;
            }

            boolean ok = service.delete(questionId);
            resp.sendRedirect(
                    req.getContextPath()
                            + "/expert/questions?deleted="
                            + ok
                            + courseSuffix(courseId)
            );
            return;
        }

        if ("hide".equalsIgnoreCase(action)) {
            UUID questionId = ControllerSupport.optionalUuid(req.getParameter("id"));
            boolean ok = service.hide(questionId);
            resp.sendRedirect(
                    req.getContextPath()
                            + "/expert/questions?hidden="
                            + ok
                            + courseSuffix(courseId)
            );
            return;
        }

        if ("unhide".equalsIgnoreCase(action)) {
            UUID questionId = ControllerSupport.optionalUuid(req.getParameter("id"));
            boolean ok = service.unhide(questionId);
            resp.sendRedirect(
                    req.getContextPath()
                            + "/expert/questions?unhidden="
                            + ok
                            + courseSuffix(courseId)
            );
            return;
        }

        // Kết quả import (thành công / danh sách lỗi) được lưu trong session ở lần POST trước
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute(IMPORT_RESULT_KEY) != null) {
            req.setAttribute("importResult", session.getAttribute(IMPORT_RESULT_KEY));
            session.removeAttribute(IMPORT_RESULT_KEY);
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

        User user = ControllerSupport.currentUser(req);
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = req.getParameter("action");

        // =====================================================
        // IMPORT FROM EXCEL
        // =====================================================
        if ("import_excel".equalsIgnoreCase(action)) {
            handleImportExcel(req, resp);
            return;
        }

        // =====================================================
        // SAVE SINGLE QUESTION
        // =====================================================
        UUID courseId = ControllerSupport.optionalUuid(req.getParameter("courseId"));
        UUID moduleId = ControllerSupport.optionalUuid(req.getParameter("moduleId"));
        if (moduleId != null) {
            Module selectedMod = moduleDAO.findById(moduleId);
            if (selectedMod != null) {
                courseId = selectedMod.getCourseId();
            }
        }
        req.setAttribute("courseId", courseId);
        req.setAttribute("course", courseId != null ? courseDAO.findById(courseId) : null);
        req.setAttribute("moduleId", moduleId);

        UUID questionId = ControllerSupport.optionalUuid(req.getParameter("id"));

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
                            + "/expert/questions?saved=true"
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

    /**
     * Nhận file Excel, import và lưu kết quả vào session rồi redirect (Post/Redirect/Get)
     * để trang danh sách hiển thị thông báo thành công hoặc danh sách lỗi.
     */
    private void handleImportExcel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UUID courseId = ControllerSupport.optionalUuid(req.getParameter("courseId"));
        UUID moduleId = ControllerSupport.optionalUuid(req.getParameter("moduleId"));
        String status = "draft".equalsIgnoreCase(req.getParameter("status")) ? "draft" : "public";

        QuestionImportResult result = new QuestionImportResult();
        try {
            Part file = req.getPart("excelFile");
            String fileName = file == null ? null : file.getSubmittedFileName();
            String lowerName = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);

            if (moduleId == null) {
                result.addError("Vui lòng chọn chương / module để import câu hỏi vào.");
            } else {
                Module module = moduleDAO.findById(moduleId);
                if (module == null) {
                    result.addError("Chương / module được chọn không tồn tại.");
                } else {
                    result.setModuleTitle(module.getTitle());
                    if (courseId == null) {
                        courseId = module.getCourseId();
                    }
                }
            }

            if (file == null || file.getSize() == 0 || fileName == null || fileName.isBlank()) {
                result.addError("Vui lòng chọn file Excel (.xlsx hoặc .xls) để import.");
            } else if (!lowerName.endsWith(".xlsx") && !lowerName.endsWith(".xls")) {
                result.addError("Chỉ chấp nhận file Excel (.xlsx hoặc .xls). File bạn chọn: \"" + fileName + "\".");
            }

            if (result.getErrorCount() == 0) {
                try (InputStream in = file.getInputStream()) {
                    result = service.importFromExcel(moduleId, status, fileName, in);
                }
                if (result.isSuccess() && result.getModuleTitle() == null) {
                    Module module = moduleDAO.findById(moduleId);
                    if (module != null) {
                        result.setModuleTitle(module.getTitle());
                    }
                }
            }
        } catch (IllegalStateException e) {
            // Vượt quá maxFileSize / maxRequestSize
            result = new QuestionImportResult();
            result.addError("File quá lớn. Dung lượng tối đa là " + (MAX_IMPORT_FILE_BYTES / (1024 * 1024)) + "MB.");
        } catch (ServletException | RuntimeException e) {
            result = new QuestionImportResult();
            result.addError("Không thể xử lý file tải lên. Vui lòng kiểm tra lại file và thử lại.");
        }

        req.getSession().setAttribute(IMPORT_RESULT_KEY, result);

        StringBuilder redirectUrl = new StringBuilder(req.getContextPath()).append("/expert/questions");
        boolean hasQuery = false;
        if (courseId != null) {
            redirectUrl.append("?courseId=").append(courseId);
            hasQuery = true;
        }
        if (moduleId != null) {
            redirectUrl.append(hasQuery ? "&moduleId=" : "?moduleId=").append(moduleId);
        }
        resp.sendRedirect(redirectUrl.toString());
    }

    private void sendImportTemplate(HttpServletResponse resp) throws IOException {
        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"question-import-template.xlsx\"");
        QuestionExcelFile.writeTemplate(resp.getOutputStream());
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

        User user = ControllerSupport.currentUser(req);
        UUID courseId = ControllerSupport.optionalUuid(req.getParameter("courseId"));

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
            req.setAttribute("modules", moduleDAO.findByExpertId(user.getId()));
        }

        req.getRequestDispatcher(
                "/WEB-INF/views/expert/question-detail.jsp"
        ).forward(req, resp);
    }

    private static String courseSuffix(UUID courseId) {
        return courseId == null ? "" : "&courseId=" + courseId;
    }
}
