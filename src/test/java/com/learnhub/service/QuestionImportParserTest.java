package com.learnhub.service;

import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class QuestionImportParserTest {

    private String[] createHeader() {
        return Arrays.copyOf(QuestionImportParser.HEADERS, QuestionImportParser.HEADERS.length);
    }

    @Test
    @DisplayName("Empty or null rows should return error")
    void testEmptyOrNullRows() {
        QuestionImportResult res1 = QuestionImportParser.parse(null);
        assertFalse(res1.isSuccess());
        assertTrue(res1.getErrorCount() > 0);

        QuestionImportResult res2 = QuestionImportParser.parse(Collections.emptyList());
        assertFalse(res2.isSuccess());
        assertTrue(res2.getErrorCount() > 0);
    }

    @Test
    @DisplayName("Invalid header row should fail with clear message")
    void testInvalidHeader() {
        List<String[]> rows = new ArrayList<>();
        rows.add(new String[]{"Wrong Col 1", "Wrong Col 2", "A", "B", "C", "D", "Correct"});
        rows.add(new String[]{"Câu hỏi 1", "single_choice", "A", "B", "", "", "A"});

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertFalse(res.isSuccess());
        assertTrue(res.getErrors().get(0).contains("Hàng 1 không đúng mẫu"));
    }

    @Test
    @DisplayName("Unaccented Vietnamese header should pass validation")
    void testUnaccentedHeader() {
        List<String[]> rows = new ArrayList<>();
        rows.add(new String[]{
                "Noi dung cau hoi", "Loai cau hoi",
                "Dap an A", "Dap an B", "Dap an C", "Dap an D",
                "Dap an dung"
        });
        rows.add(new String[]{"Java chạy trên đâu?", "single_choice", "JVM", "CLR", "V8", "Python VM", "A"});

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertTrue(res.isSuccess(), "Errors: " + res.getErrors());
        assertEquals(1, res.getQuestions().size());
        assertEquals("single_choice", res.getQuestions().get(0).getType());
    }

    @Test
    @DisplayName("Single choice question with 4 options parsed correctly")
    void testValidSingleChoice() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{
                "Thủ đô của Việt Nam là gì?", "single_choice",
                "Hà Nội", "TP. Hồ Chí Minh", "Đà Nẵng", "Hải Phòng",
                "A"
        });

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertTrue(res.isSuccess());
        assertEquals(1, res.getQuestions().size());

        Question q = res.getQuestions().get(0);
        assertEquals("Thủ đô của Việt Nam là gì?", q.getContent());
        assertEquals("single_choice", q.getType());
        assertEquals(4, q.getOptions().size());
        assertTrue(q.getOptions().get(0).isCorrect());
        assertFalse(q.getOptions().get(1).isCorrect());
        assertEquals(1, res.getSingleCount());
    }

    @Test
    @DisplayName("Multiple choice question with comma-separated letters and numbers parsed correctly")
    void testValidMultipleChoice() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{
                "Các ngôn ngữ nào chạy trên JVM?", "multiple_choice",
                "Java", "Kotlin", "Python", "Scala",
                "A, B, D"
        });

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertTrue(res.isSuccess(), "Errors: " + res.getErrors());
        assertEquals(1, res.getQuestions().size());

        Question q = res.getQuestions().get(0);
        assertEquals("multiple_choice", q.getType());
        assertEquals(4, q.getOptions().size());
        assertTrue(q.getOptions().get(0).isCorrect());
        assertTrue(q.getOptions().get(1).isCorrect());
        assertFalse(q.getOptions().get(2).isCorrect());
        assertTrue(q.getOptions().get(3).isCorrect());
        assertEquals(1, res.getMultipleCount());
    }

    @Test
    @DisplayName("Answer column accepting numbers (1, 3 for A, C) or punctuation (A., (C))")
    void testFlexibleAnswerFormat() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{
                "Chọn số chẵn:", "",
                "2", "3", "4", "5",
                "1, 3" // map to A (index 0) and C (index 2)
        });

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertTrue(res.isSuccess(), "Errors: " + res.getErrors());
        assertEquals(1, res.getQuestions().size());

        Question q = res.getQuestions().get(0);
        assertEquals("multiple_choice", q.getType());
        assertTrue(q.getOptions().get(0).isCorrect()); // Option '2'
        assertFalse(q.getOptions().get(1).isCorrect()); // Option '3'
        assertTrue(q.getOptions().get(2).isCorrect()); // Option '4'
    }

    @Test
    @DisplayName("Fill in blank question with keywords and empty options A-D")
    void testFillInBlank() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{
                "HTML là viết tắt của từ gì?", "fill_in_blank",
                "", "", "", "",
                "HyperText Markup Language, HTML"
        });

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertTrue(res.isSuccess(), "Errors: " + res.getErrors());
        assertEquals(1, res.getQuestions().size());

        Question q = res.getQuestions().get(0);
        assertEquals("fill_in_blank", q.getType());
        assertEquals(2, q.getOptions().size());
        assertEquals("HyperText Markup Language", q.getOptions().get(0).getOptionText());
        assertEquals("HTML", q.getOptions().get(1).getOptionText());
        assertTrue(q.getOptions().get(0).isCorrect());
        assertTrue(q.getOptions().get(1).isCorrect());
        assertEquals(1, res.getFillCount());
    }

    @Test
    @DisplayName("Auto-infer fill in blank when type is empty and options A-D are empty")
    void testAutoInferFillInBlank() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{
                "Giao thức web bảo mật là gì?", "",
                "", "", "", "",
                "HTTPS, https"
        });

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertTrue(res.isSuccess(), "Errors: " + res.getErrors());
        assertEquals(1, res.getQuestions().size());
        assertEquals("fill_in_blank", res.getQuestions().get(0).getType());
    }

    @Test
    @DisplayName("Vietnamese type aliases: trắc nghiệm, nhiều đáp án, điền chỗ trống")
    void testVietnameseTypeAliases() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{"Q1", "trắc nghiệm", "A1", "A2", "", "", "A"});
        rows.add(new String[]{"Q2", "nhiều đáp án", "B1", "B2", "B3", "", "A,B"});
        rows.add(new String[]{"Q3", "điền chỗ trống", "", "", "", "", "key1"});

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertTrue(res.isSuccess(), "Errors: " + res.getErrors());
        assertEquals(3, res.getQuestions().size());
        assertEquals("single_choice", res.getQuestions().get(0).getType());
        assertEquals("multiple_choice", res.getQuestions().get(1).getType());
        assertEquals("fill_in_blank", res.getQuestions().get(2).getType());
    }


    @Test
    @DisplayName("Gap in options (A filled, B empty, C filled) should report error")
    void testGapInOptions() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{
                "Câu hỏi?", "single_choice",
                "Đáp án A", "", "Đáp án C", "",
                "A"
        });

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertFalse(res.isSuccess());
        assertTrue(res.getErrors().get(0).contains("đang để trống"));
    }

    @Test
    @DisplayName("Correct answer pointing to empty option should report error")
    void testCorrectAnswerPointingToEmptyOption() {
        List<String[]> rows = new ArrayList<>();
        rows.add(createHeader());
        rows.add(new String[]{
                "Câu hỏi?", "single_choice",
                "Đáp án A", "Đáp án B", "", "",
                "C" // Option C is empty
        });

        QuestionImportResult res = QuestionImportParser.parse(rows);
        assertFalse(res.isSuccess());
        assertTrue(res.getErrors().get(0).contains("đáp án đúng là C nhưng"));
    }
}
