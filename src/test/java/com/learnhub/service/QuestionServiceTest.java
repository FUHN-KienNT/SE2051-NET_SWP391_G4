package com.learnhub.service;

import com.learnhub.dao.QuestionDAO;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class QuestionServiceTest {

    @Test
    @DisplayName("Câu hỏi đã được dùng trong quiz/course thì KHÔNG THỂ xóa vĩnh viễn (chỉ được ẩn)")
    void testCannotDeleteUsedQuestion() {
        UUID usedQuestionId = UUID.randomUUID();

        QuestionDAO stubDao = new QuestionDAO() {
            @Override
            public boolean isUsedInQuiz(UUID id) {
                return usedQuestionId.equals(id);
            }

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

    @Test
    @DisplayName("Câu hỏi chưa được dùng trong bài thi nào thì CÓ THỂ xóa vĩnh viễn")
    void testCanDeleteUnusedQuestion() {
        UUID unusedQuestionId = UUID.randomUUID();

        QuestionDAO stubDao = new QuestionDAO() {
            @Override
            public boolean isUsedInQuiz(UUID id) {
                return false; // Chưa từng được dùng
            }

            @Override
            public boolean delete(UUID id) {
                return true; // Xóa thành công
            }
        };

        QuestionService service = new QuestionService(stubDao);

        boolean deleteResult = service.delete(unusedQuestionId);
        assertTrue(deleteResult, "Câu hỏi chưa dùng phải cho phép xóa vĩnh viễn");
    }

    @Test
    @DisplayName("Chức năng ẩn (hide) và hiện (unhide) hoạt động đúng")
    void testHideAndUnhideQuestion() {
        UUID qId = UUID.randomUUID();

        QuestionDAO stubDao = new QuestionDAO() {
            @Override
            public boolean hide(UUID id) {
                return true;
            }

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
