package com.learnhub.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class QuestionExcelFileTest {

    @Test
    @DisplayName("Tạo file mẫu và đọc lại các dòng tiêu đề và dữ liệu ví dụ")
    void testWriteAndReadTemplate() throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        QuestionExcelFile.writeTemplate(out);
        byte[] bytes = out.toByteArray();
        assertTrue(bytes.length > 0);

        List<String[]> rows = QuestionExcelFile.readRows(new ByteArrayInputStream(bytes));
        assertFalse(rows.isEmpty());

        // Hàng 1: Tiêu đề cột
        String[] header = rows.get(0);
        assertEquals("Nội dung câu hỏi", header[0]);
        assertEquals("Loại câu hỏi", header[1]);
        assertEquals("Đáp án đúng", header[6]);

        // Các hàng tiếp theo: dữ liệu mẫu
        assertTrue(rows.size() >= 4); // 1 header + 3 mẫu
        assertEquals("Servlet trong Java là gì?", rows.get(1)[0]);
        assertEquals("single_choice", rows.get(1)[1]);
    }
}
