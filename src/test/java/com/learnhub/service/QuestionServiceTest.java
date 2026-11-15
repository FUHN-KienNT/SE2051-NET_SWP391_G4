package com.learnhub.service;

import com.learnhub.dao.QuestionDAO;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class QuestionServiceTest {

    /**
     * Verifies cannot delete used question.
     */
    @Test
    @DisplayName("Câu hỏi đã được dùng trong quiz/course thì KHÔNG THỂ xóa vĩnh viễn (chỉ được ẩn)")
    void testCannotDeleteUsedQuestion() {
        UUID usedQuestionId = UUID.randomUUID();

        QuestionDAO stubDao = new QuestionDAO() {
            /**
             * Checks whether used in quiz.
             *
             * @param id the id identifier
             * @return true when the condition holds; false otherwise
             */
            @Override
            public boolean isUsedInQuiz(UUID id) {
                return usedQuestionId.equals(id);
            }

            /**
             * Delete.
             *
             * @param id the id identifier
             * @return true when the condition holds; false otherwise
             */
            @Override
            public boolean delete(UUID id) {
                // Nếu được gọi xóa, chỉ xóa nếu chưa dùng
                if (isUsedInQuiz(id)) return false;
                return true;
            }
        };

        QuestionService service = new QuestionService(stubDao);

        // Kiểm tra câu hỏi đã dùng -> delete trả về false
        boolean deleteResult = service.delete(usedQuestionId);
        assertFalse(deleteResult, "Câu hỏi đã được gán vào quiz thì không được phép xóa");
    }

    /**
     * Verifies can delete unused question.
     */
    @Test
    @DisplayName("Câu hỏi chưa được dùng trong bài thi nào thì CÓ THỂ xóa vĩnh viễn")
    void testCanDeleteUnusedQuestion() {
        UUID unusedQuestionId = UUID.randomUUID();

        QuestionDAO stubDao = new QuestionDAO() {
            /**
             * Checks whether used in quiz.
             *
             * @param id the id identifier
             * @return true when the condition holds; false otherwise
             */
            @Override
            public boolean isUsedInQuiz(UUID id) {
                return false; // Chưa từng được dùng
            }

            /**
             * Delete.
             *
             * @param id the id identifier
             * @return true when the condition holds; false otherwise
             */
            @Override
            public boolean delete(UUID id) {
                return true; // Xóa thành công
            }
        };

        QuestionService service = new QuestionService(stubDao);

        boolean deleteResult = service.delete(unusedQuestionId);
        assertTrue(deleteResult, "Câu hỏi chưa dùng phải cho phép xóa vĩnh viễn");
    }

    /**
     * Verifies hide and unhide question.
     */
    @Test
    @DisplayName("Chức năng ẩn (hide) và hiện (unhide) hoạt động đúng")
    void testHideAndUnhideQuestion() {
        UUID qId = UUID.randomUUID();

        QuestionDAO stubDao = new QuestionDAO() {
            /**
             * Hide.
             *
             * @param id the id identifier
             * @return true when the condition holds; false otherwise
             */
            @Override
            public boolean hide(UUID id) {
                return true;
            }

            /**
             * Unhide.
             *
             * @param id the id identifier
             * @return true when the condition holds; false otherwise
             */
            @Override
            public boolean unhide(UUID id) {
                return true;
            }
        };

        QuestionService service = new QuestionService(stubDao);

        assertTrue(service.hide(qId));
        assertTrue(service.unhide(qId));
        assertFalse(service.hide(null));
        assertFalse(service.unhide(null));
    }
}
