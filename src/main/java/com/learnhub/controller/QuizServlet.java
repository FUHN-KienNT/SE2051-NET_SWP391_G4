package com.learnhub.controller;

import com.learnhub.dao.QuestionDAO;
import com.learnhub.dao.QuizDAO;
import com.learnhub.dto.QuizAttemptDTO;
import com.learnhub.entity.Question;
import com.learnhub.entity.Quiz;
import com.learnhub.entity.QuizSubmission;
import com.learnhub.entity.User;
import com.learnhub.service.QuizAttemptService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

/**
 * Quiz Servlet handling taking, submitting, reviewing quizzes, and viewing quiz overview.
 * Implements methods specified in SDS Quiz Submission & Scoring Diagram (3.1, 3.2):
 * - startAttempt()
 * - submitAttempt()
 * - viewHistory()
 * - viewQuizOverview()
 */
@WebServlet(name = "QuizServlet", urlPatterns = {"/quiz", "/quiz/take", "/quiz/submit", "/quiz/history", "/quiz/view", "/quiz/info"})
public class QuizServlet extends HttpServlet {
    private final QuizAttemptService quizService = new QuizAttemptService();
    private final QuizDAO quizDAO = new QuizDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            String redirectUri = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUri += "?" + req.getQueryString();
            }
            String encodedUri = java.net.URLEncoder.encode(redirectUri, "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login&redirect_uri=" + encodedUri);
            return;
        }

        String path = req.getServletPath();

        if ("/quiz/take".equals(path)) {
            // Chỉ vào trang làm bài khi đã bấm "Bắt đầu" (có attemptId). Gõ thẳng URL thì rơi xuống màn hình giới thiệu bên dưới.
            String attemptIdStr = req.getParameter("attemptId");
            if (attemptIdStr != null) {
                try {
                    UUID attemptId = UUID.fromString(attemptIdStr);
                    QuizSubmission attempt = quizService.getAttempt(attemptId);

                    if (attempt != null
                            && user.getId().equals(attempt.getUserId())
                            && attempt.getScore() == null) {
                        Quiz quiz = quizDAO.findById(attempt.getQuizId());
                        List<Question> questions = questionDAO.findQuestionsByQuizId(attempt.getQuizId());

                        req.setAttribute("quiz", quiz);
                        req.setAttribute("questions", questions);
                        req.setAttribute("attempt", attempt);

                        req.getRequestDispatcher("/WEB-INF/views/quiz/take.jsp").forward(req, resp);
                        return;
                    }
                } catch (Exception ignored) {
                }
            }
        }

        if ("/quiz/history".equals(path)) {
            String quizIdStr = req.getParameter("quizId");
            if (quizIdStr != null) {
                try {
                    UUID quizId = UUID.fromString(quizIdStr);
                    List<QuizSubmission> history = quizService.getAttemptHistory(user.getId(), quizId);
                    req.setAttribute("history", history);
                    req.getRequestDispatcher("/WEB-INF/views/quiz/history.jsp").forward(req, resp);
                    return;
                } catch (Exception ignored) {
                }
            }
        }

        // Default: Quiz Viewer / Overview screen (/quiz, /quiz/view, /quiz/info)
        String quizIdStr = req.getParameter("quizId");
        if (quizIdStr != null) {
            try {
                UUID quizId = UUID.fromString(quizIdStr);
                Quiz quiz = quizDAO.findById(quizId);
                if (quiz != null) {
                    List<Question> questions = questionDAO.findQuestionsByQuizId(quizId);
                    List<QuizSubmission> history = quizService.getAttemptHistory(user.getId(), quizId);

                    BigDecimal highestScore = null;
                    boolean passedAny = false;
                    List<QuizSubmission> completedAttempts = new ArrayList<>();
                    if (history != null) {
                        for (QuizSubmission sub : history) {
                            if (sub.getScore() != null) {
                                completedAttempts.add(sub);
                                if (highestScore == null || sub.getScore().compareTo(highestScore) > 0) {
                                    highestScore = sub.getScore();
                                }
                                if (sub.getPassStatus() != null && sub.getPassStatus()) {
                                    passedAny = true;
                                }
                            }
                        }
                    }

                    req.setAttribute("quiz", quiz);
                    req.setAttribute("questionCount", questions != null ? questions.size() : 0);
                    req.setAttribute("history", completedAttempts);
                    req.setAttribute("hasAttempted", !completedAttempts.isEmpty());
                    req.setAttribute("highestScore", highestScore);
                    req.setAttribute("passed", passedAny);
                    req.setAttribute("courseId", req.getParameter("courseId"));

                    req.getRequestDispatcher("/WEB-INF/views/quiz/info.jsp").forward(req, resp);
                    return;
                }
            } catch (Exception ignored) {
            }
        }

        resp.sendRedirect(req.getContextPath() + "/courses");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Bấm nút "Bắt đầu làm bài" ở màn hình giới thiệu: tạo lượt làm bài rồi redirect sang trang làm bài
        if ("/quiz/take".equals(req.getServletPath())) {
            HttpSession session = req.getSession(false);
            User user = session != null ? (User) session.getAttribute("currentUser") : null;
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/auth/login?error=must_login");
                return;
            }
            try {
                UUID quizId = UUID.fromString(req.getParameter("quizId"));
                QuizSubmission attempt = quizService.startQuizAttempt(user.getId(), quizId);
                resp.sendRedirect(req.getContextPath() + "/quiz/take?attemptId=" + attempt.getId());
                return;
            } catch (Exception ignored) {
            }
            resp.sendRedirect(req.getContextPath() + "/courses");
            return;
        }

        String attemptIdStr = req.getParameter("attemptId");
        if (attemptIdStr != null) {
            try {
                UUID attemptId = UUID.fromString(attemptIdStr);
                Map<UUID, List<UUID>> selectedAnswers = new HashMap<>();

                for (String paramName : req.getParameterMap().keySet()) {
                    if (paramName.startsWith("question_")) {
                        String qIdStr = paramName.substring("question_".length());
                        UUID qId = UUID.fromString(qIdStr);
                        String[] vals = req.getParameterValues(paramName);
                        List<UUID> optIds = new ArrayList<>();
                        for (String v : vals) {
                            optIds.add(UUID.fromString(v));
                        }
                        selectedAnswers.put(qId, optIds);
                    }
                }

                QuizAttemptDTO result = quizService.submitQuizAttempt(attemptId, selectedAnswers);
                Quiz quiz = quizDAO.findById(result.getQuizId());
                req.setAttribute("quiz", quiz);
                req.setAttribute("result", result);
                req.getRequestDispatcher("/WEB-INF/views/quiz/result.jsp").forward(req, resp);
                return;
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
