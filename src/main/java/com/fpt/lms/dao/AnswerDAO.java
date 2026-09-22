package com.fpt.lms.dao;

import com.fpt.lms.entity.QuizAnswer;
import com.fpt.lms.util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for student answers.
 * Implements methods specified in SDS Quiz Submission & Scoring Diagram (3.1):
 * - saveAnswers()
 */
public class AnswerDAO {
    private static final Logger LOGGER = Logger.getLogger(AnswerDAO.class.getName());

    public void saveAnswers(UUID submissionId, Map<UUID, List<UUID>> selectedAnswers) {
        if (submissionId == null || selectedAnswers == null || selectedAnswers.isEmpty()) {
            return;
        }

        String findQuizQuestionSql = "SELECT id FROM quiz_question WHERE quiz_id = (SELECT quiz_id FROM quiz_submission WHERE id = ?) AND question_id = ?";
        String insertSql = "INSERT INTO quiz_answer (id, quiz_submission_id, quiz_question_id, question_option_id) VALUES (gen_random_uuid(), ?, ?, ?)";

        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement findQqPs = conn.prepareStatement(findQuizQuestionSql);
                 PreparedStatement insertPs = conn.prepareStatement(insertSql)) {

                for (Map.Entry<UUID, List<UUID>> entry : selectedAnswers.entrySet()) {
                    UUID questionId = entry.getKey();
                    List<UUID> optionIds = entry.getValue();

                    findQqPs.setObject(1, submissionId);
                    findQqPs.setObject(2, questionId);
                    UUID quizQuestionId = null;
                    try (ResultSet rs = findQqPs.executeQuery()) {
                        if (rs.next()) {
                            quizQuestionId = (UUID) rs.getObject("id");
                        }
                    }

                    if (quizQuestionId != null && optionIds != null) {
                        for (UUID optionId : optionIds) {
                            insertPs.setObject(1, submissionId);
                            insertPs.setObject(2, quizQuestionId);
                            insertPs.setObject(3, optionId);
                            insertPs.addBatch();
                        }
                    }
                }
                insertPs.executeBatch();
                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in AnswerDAO.saveAnswers: " + e.getMessage(), e);
        }
    }

    public List<QuizAnswer> findBySubmissionId(UUID submissionId) {
        List<QuizAnswer> list = new ArrayList<>();
        String sql = "SELECT qa.id, qa.quiz_submission_id, qa.quiz_question_id, qa.question_option_id, " +
                     "q.content as question_content, qo.option_text as option_text, qo.is_correct " +
                     "FROM quiz_answer qa " +
                     "JOIN quiz_question qq ON qa.quiz_question_id = qq.id " +
                     "JOIN question q ON qq.question_id = q.id " +
                     "JOIN question_option qo ON qa.question_option_id = qo.id " +
                     "WHERE qa.quiz_submission_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuizAnswer a = new QuizAnswer();
                    a.setId((UUID) rs.getObject("id"));
                    a.setQuizSubmissionId((UUID) rs.getObject("quiz_submission_id"));
                    a.setQuizQuestionId((UUID) rs.getObject("quiz_question_id"));
                    a.setQuestionOptionId((UUID) rs.getObject("question_option_id"));
                    a.setQuestionContent(rs.getString("question_content"));
                    a.setSelectedOptionText(rs.getString("option_text"));
                    a.setCorrect(rs.getBoolean("is_correct"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in AnswerDAO.findBySubmissionId: " + e.getMessage(), e);
        }
        return list;
    }
}
