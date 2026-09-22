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
import java.util.*;

/**
 * Quiz Servlet handling taking, submitting, and reviewing quizzes.
 * Implements methods specified in SDS Quiz Submission & Scoring Diagram (3.1, 3.2):
 * - startAttempt()
 * - submitAttempt()
 * - viewHistory()
 */
@WebServlet(name = "QuizServlet", urlPatterns = {"/quiz", "/quiz/take", "/quiz/submit", "/quiz/history"})
public class QuizServlet extends HttpServlet {
    private final QuizAttemptService quizService = new QuizAttemptService();
    private final QuizDAO quizDAO = new QuizDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=must_login");
            return;
        }

        String path = req.getServletPath();

        if ("/quiz/take".equals(path)) {
            String quizIdStr = req.getParameter("quizId");
            if (quizIdStr != null) {
                try {
                    UUID quizId = UUID.fromString(quizIdStr);
                    Quiz quiz = quizDAO.findById(quizId);
                    List<Question> questions = questionDAO.findQuestionsByQuizId(quizId);
                    QuizSubmission attempt = quizService.startQuizAttempt(user.getId(), quizId);

                    req.setAttribute("quiz", quiz);
                    req.setAttribute("questions", questions);
                    req.setAttribute("attempt", attempt);

                    req.getRequestDispatcher("/WEB-INF/views/quiz/take.jsp").forward(req, resp);
                    return;
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

        resp.sendRedirect(req.getContextPath() + "/courses");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
                req.setAttribute("result", result);
                req.getRequestDispatcher("/WEB-INF/views/quiz/result.jsp").forward(req, resp);
                return;
            } catch (Exception ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/courses");
    }
}
