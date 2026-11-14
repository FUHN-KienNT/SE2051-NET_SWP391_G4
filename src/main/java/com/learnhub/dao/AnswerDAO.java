package com.learnhub.dao;

import com.learnhub.util.DbConnection;

import java.sql.*;
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
}
