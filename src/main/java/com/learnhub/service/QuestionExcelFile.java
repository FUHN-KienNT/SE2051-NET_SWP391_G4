package com.learnhub.service;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * Xử lý file Excel bằng thư viện Apache POI:
 * 1. Đọc nội dung file Excel tải lên thành danh sách các chuỗi.
 * 2. Tạo file Excel mẫu (.xlsx) để người dùng tải về nhập câu hỏi.
 */
public final class QuestionExcelFile {

    private static final int MAX_SCAN_ROWS = 2000;

    private QuestionExcelFile() {
    }

    /**
     * Đọc sheet đầu tiên của file Excel.
     * Mỗi hàng trả về một mảng String tương ứng các cột theo thứ tự mẫu.
     */
    public static List<String[]> readRows(InputStream in) throws IOException {
        List<String[]> rows = new ArrayList<>();
        try (Workbook workbook = WorkbookFactory.create(in)) {
            if (workbook.getNumberOfSheets() == 0) {
                return rows;
            }

            Sheet sheet = workbook.getSheetAt(0);
            DataFormatter formatter = new DataFormatter();
            int lastRow = Math.min(sheet.getLastRowNum(), MAX_SCAN_ROWS);

            for (int r = 0; r <= lastRow; r++) {
                Row row = sheet.getRow(r);
                String[] cells = new String[QuestionImportParser.COLUMN_COUNT];
                for (int c = 0; c < cells.length; c++) {
                    Cell cell = (row == null) ? null : row.getCell(c);
                    cells[c] = (cell == null) ? "" : formatter.formatCellValue(cell).trim();
                }
                rows.add(cells);
            }
        }
        return rows;
    }

    /**
     * Tạo file Excel mẫu (.xlsx) gồm:
     * - Sheet "Câu hỏi": bảng tiêu đề và 3 dòng dữ liệu ví dụ.
     * - Sheet "Hướng dẫn": hướng dẫn chi tiết cách điền các cột.
     */
    public static void writeTemplate(OutputStream out) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            // Định dạng tiêu đề cột (chữ in đậm, nền xanh lá nhạt)
            Font boldFont = workbook.createFont();
            boldFont.setBold(true);
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFont(boldFont);
            headerStyle.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // ================== SHEET 1: CÂU HỎI ==================
            Sheet sheet = workbook.createSheet("Câu hỏi");
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < QuestionImportParser.HEADERS.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(QuestionImportParser.HEADERS[i]);
                cell.setCellStyle(headerStyle);
            }

            // Dữ liệu ví dụ 3 loại câu hỏi: single_choice, multiple_choice, fill_in_blank
            String[][] samples = {
                {"Servlet trong Java là gì?", "single_choice", "Một class Java mở rộng chức năng máy chủ", "Một giao diện người dùng", "Một giao thức mạng", "Một hệ quản trị cơ sở dữ liệu", "A"},
                {"Chọn các ngôn ngữ chạy trên máy ảo JVM:", "multiple_choice", "Java", "Kotlin", "Python", "C", "A,B"},
                {"HTML viết tắt của từ gì?", "fill_in_blank", "", "", "", "", "HyperText Markup Language, HTML"}
            };
            for (int r = 0; r < samples.length; r++) {
                Row row = sheet.createRow(r + 1);
                for (int c = 0; c < samples[r].length; c++) {
                    row.createCell(c).setCellValue(samples[r][c]);
                }
            }

            // Căn chỉnh độ rộng các cột
            int[] widths = {48, 18, 30, 30, 30, 30, 28};
            for (int i = 0; i < widths.length; i++) {
                sheet.setColumnWidth(i, widths[i] * 256);
            }
            sheet.createFreezePane(0, 1);

            // ================== SHEET 2: HƯỚNG DẪN ==================
            Sheet guide = workbook.createSheet("Hướng dẫn");
            String[] guideLines = {
                "HƯỚNG DẪN IMPORT CÂU HỎI TỪ EXCEL",
                "1. Nhập câu hỏi ở sheet \"Câu hỏi\", bắt đầu từ hàng 2. Không sửa tiêu đề ở hàng 1.",
                "2. Xóa 3 dòng ví dụ mẫu trước khi lưu file để import câu hỏi thật.",
                "3. Mỗi lần import tối đa " + QuestionImportParser.MAX_QUESTIONS + " câu hỏi.",
                "4. Cột \"Loại câu hỏi\": single_choice, multiple_choice hoặc fill_in_blank (để trống hệ thống tự nhận diện).",
                "5. Câu hỏi trắc nghiệm: điền Đáp án A-D, cột \"Đáp án đúng\" điền chữ cái A, B, C, D (ví dụ: A hoặc A,C).",
                "6. Câu hỏi điền từ: để trống Đáp án A-D, cột \"Đáp án đúng\" nhập các từ khóa đúng cách nhau bằng dấu phẩy.",
                "7. Nội dung câu hỏi tối đa " + QuestionService.MAX_CHARS_QUESTION_CONTENT + " ký tự (bao gồm cả khoảng trắng).",
                "8. Toàn bộ file sẽ được kiểm tra: nếu có bất kỳ lỗi nào hệ thống sẽ báo rõ số dòng để bạn sửa lại."
            };
            for (int i = 0; i < guideLines.length; i++) {
                Cell cell = guide.createRow(i).createCell(0);
                cell.setCellValue(guideLines[i]);
                if (i == 0) cell.setCellStyle(headerStyle);
            }
            guide.setColumnWidth(0, 100 * 256);

            workbook.write(out);
        }
    }
}
