package com.learnhub.service;

import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

/**
 * Đọc và kiểm tra (validate) dữ liệu câu hỏi từ các hàng trong file Excel.
 * - Độc lập với thư viện POI và Database, giúp code rõ ràng và dễ kiểm thử.
 * - Quy tắc: Gom tất cả lỗi trong file. Nếu có dù chỉ 1 lỗi thì không lưu câu nào.
 */
public final class QuestionImportParser {

    public static final String[] HEADERS = {
            "Nội dung câu hỏi", "Loại câu hỏi",
            "Đáp án A", "Đáp án B", "Đáp án C", "Đáp án D",
            "Đáp án đúng"
    };
    public static final int COLUMN_COUNT = HEADERS.length;
    public static final int MAX_QUESTIONS = 500;

    static final String SINGLE = "single_choice";
    static final String MULTIPLE = "multiple_choice";
    static final String FILL = "fill_in_blank";

    private static final String[] LETTERS = {"A", "B", "C", "D"};

    private QuestionImportParser() {
    }

    /**
     * Phân tích danh sách hàng đọc từ Excel thành đối tượng QuestionImportResult.
     */
    public static QuestionImportResult parse(List<String[]> rows) {
        QuestionImportResult result = new QuestionImportResult();

        if (rows == null || rows.isEmpty()) {
            result.addError("File Excel không có dữ liệu.");
            return result;
        }

        // Bước 1: Kiểm tra hàng tiêu đề (Hàng 1 trong Excel)
        String headerError = checkHeader(rows.get(0));
        if (headerError != null) {
            result.addError(headerError);
            return result;
        }

        // Bước 2: Duyệt từng hàng dữ liệu (bắt đầu từ hàng thứ 2)
        int dataRowCount = 0;
        for (int i = 1; i < rows.size(); i++) {
            String[] row = rows.get(i);
            if (isBlankRow(row)) {
                continue; // Bỏ qua hàng trống
            }

            dataRowCount++;
            if (dataRowCount > MAX_QUESTIONS) {
                result.addError("File có hơn " + MAX_QUESTIONS + " câu hỏi. Vui lòng chia nhỏ file.");
                break;
            }

            // Số dòng thực tế trong Excel = chỉ số mảng i + 1
            parseRow(i + 1, row, result);
        }

        if (dataRowCount == 0) {
            result.addError("File không có câu hỏi nào. Hãy nhập dữ liệu từ hàng thứ 2.");
        }

        return result;
    }

    // =========================================================================
    // 1. KIỂM TRA TIÊU ĐỀ HÀNG 1
    // =========================================================================

    private static String checkHeader(String[] headerRow) {
        for (int i = 0; i < COLUMN_COUNT; i++) {
            String actual = getCell(headerRow, i).toLowerCase(Locale.ROOT);
            String expected = HEADERS[i].toLowerCase(Locale.ROOT);

            // Bỏ qua dấu tiếng Việt để người dùng gõ có dấu hay không dấu đều nhận
            String normActual = removeDiacritics(actual);
            String normExpected = removeDiacritics(expected);

            if (!normActual.equals(normExpected)) {
                return "Hàng 1 không đúng mẫu: Cột " + (char) ('A' + i) + " phải là \"" + HEADERS[i] + "\".";
            }
        }
        return null;
    }

    // =========================================================================
    // 2. PHÂN TÍCH TỪNG HÀNG DỮ LIỆU
    // =========================================================================

    private static void parseRow(int rowNum, String[] row, QuestionImportResult result) {
        List<String> errors = new ArrayList<>();
        Question question = new Question();
        question.setId(UUID.randomUUID());

        // --- Cột 0: Nội dung câu hỏi ---
        String content = getCell(row, 0);
        if (content.isEmpty()) {
            errors.add("thiếu nội dung câu hỏi.");
        } else if (content.length() > QuestionService.MAX_CHARS_QUESTION_CONTENT) {
            errors.add("nội dung câu hỏi vượt quá " + QuestionService.MAX_CHARS_QUESTION_CONTENT + " ký tự (bao gồm cả khoảng trắng).");
        }
        question.setContent(content);

        // --- Cột 1: Loại câu hỏi ---
        String typeRaw = getCell(row, 1);
        String type = resolveType(typeRaw);
        if (!typeRaw.isEmpty() && type == null) {
            errors.add("loại câu hỏi không hợp lệ (hỗ trợ: single_choice, multiple_choice, fill_in_blank).");
            flushErrors(rowNum, errors, result);
            return;
        }

        // Tự suy luận loại nếu người dùng để trống:
        // Nếu các đáp án A-D đều trống -> điền từ (fill_in_blank)
        String correctRaw = getCell(row, 6);
        boolean hasChoices = !getCell(row, 2).isEmpty() || !getCell(row, 3).isEmpty();
        if (type == null && !hasChoices && !correctRaw.isEmpty()) {
            type = FILL;
        }

        // --- Cột 2 đến 6: Đáp án & Đáp án đúng ---
        if (FILL.equals(type)) {
            parseFillInBlank(row, correctRaw, question, errors);
        } else {
            parseChoiceQuestion(row, correctRaw, type, question, errors);
        }

        // Tổng hợp kết quả của hàng
        if (errors.isEmpty()) {
            result.addQuestion(question);
        } else {
            flushErrors(rowNum, errors, result);
        }
    }

    /**
     * Xử lý câu hỏi trắc nghiệm (single_choice hoặc multiple_choice).
     */
    private static void parseChoiceQuestion(String[] row, String correctRaw, String type,
                                            Question question, List<String> errors) {
        String[] optionsText = new String[4];
        int filledCount = 0;
        int highestFilled = -1;

        for (int i = 0; i < 4; i++) {
            optionsText[i] = getCell(row, 2 + i); // Cột 2 = A, 3 = B, 4 = C, 5 = D
            if (!optionsText[i].isEmpty()) {
                filledCount++;
                highestFilled = i;
            }
        }

        // Phải có tối thiểu 2 đáp án A và B
        if (filledCount < 2) {
            errors.add("câu hỏi trắc nghiệm cần ít nhất 2 đáp án (A và B).");
        } else {
            // Kiểm tra xem có bị để trống ngắt quãng không (ví dụ điền A, C nhưng để trống B)
            for (int i = 0; i < highestFilled; i++) {
                if (optionsText[i].isEmpty()) {
                    errors.add("Đáp án " + LETTERS[i] + " đang để trống trong khi Đáp án " + LETTERS[highestFilled] + " có dữ liệu. Vui lòng điền lần lượt từ A.");
                }
            }
        }

        // Đọc danh sách đáp án đúng (A, B, C, D hoặc 1, 2, 3, 4)
        Set<Integer> correctIndexes = new LinkedHashSet<>();
        if (correctRaw.isEmpty()) {
            errors.add("thiếu đáp án đúng.");
        } else {
            String[] tokens = correctRaw.split("[,;/|\\s]+");
            for (String token : tokens) {
                if (token.isEmpty()) continue;
                int index = parseLetterToIndex(token);
                if (index < 0) {
                    errors.add("đáp án đúng \"" + token + "\" không hợp lệ. Chỉ chấp nhận A, B, C, D (hoặc 1, 2, 3, 4).");
                } else if (optionsText[index].isEmpty()) {
                    errors.add("đáp án đúng là " + LETTERS[index] + " nhưng nội dung Đáp án " + LETTERS[index] + " đang để trống.");
                } else {
                    correctIndexes.add(index);
                }
            }
        }

        // Xác định loại câu hỏi cuối cùng
        String finalType = type;
        if (finalType == null) {
            finalType = (correctIndexes.size() > 1) ? MULTIPLE : SINGLE;
        } else if (SINGLE.equals(finalType) && correctIndexes.size() > 1) {
            errors.add("câu hỏi 1 đáp án (single_choice) nhưng lại chọn " + correctIndexes.size() + " đáp án đúng.");
        }
        question.setType(finalType);

        // Tạo danh sách Option nếu không có lỗi
        if (errors.isEmpty()) {
            List<QuestionOption> options = new ArrayList<>();
            for (int i = 0; i < 4; i++) {
                if (optionsText[i].isEmpty()) continue;
                QuestionOption opt = new QuestionOption();
                opt.setId(UUID.randomUUID());
                opt.setQuestionId(question.getId());
                opt.setOptionText(optionsText[i]);
                opt.setCorrect(correctIndexes.contains(i));
                options.add(opt);
            }
            question.setOptions(options);
        }
    }

    /**
     * Xử lý câu hỏi điền vào chỗ trống (fill_in_blank).
     */
    private static void parseFillInBlank(String[] row, String correctRaw,
                                         Question question, List<String> errors) {
        question.setType(FILL);

        // Câu điền từ thì các cột A-D phải để trống
        for (int i = 0; i < 4; i++) {
            if (!getCell(row, 2 + i).isEmpty()) {
                errors.add("câu hỏi điền từ phải để trống các cột Đáp án A đến D.");
                break;
            }
        }

        // Lấy danh sách từ khóa đúng ở cột 6 (ngăn cách bằng dấu phẩy hoặc chấm phẩy)
        List<String> keywords = new ArrayList<>();
        if (correctRaw.isEmpty()) {
            errors.add("thiếu từ khóa đáp án đúng.");
        } else {
            String[] tokens = correctRaw.split("[,;\\n]+");
            for (String kw : tokens) {
                String clean = kw.trim();
                if (!clean.isEmpty() && !keywords.contains(clean)) {
                    keywords.add(clean);
                }
            }
        }

        if (errors.isEmpty()) {
            List<QuestionOption> options = new ArrayList<>();
            for (String kw : keywords) {
                QuestionOption opt = new QuestionOption();
                opt.setId(UUID.randomUUID());
                opt.setQuestionId(question.getId());
                opt.setOptionText(kw);
                opt.setCorrect(true);
                options.add(opt);
            }
            question.setOptions(options);
        }
    }

    // =========================================================================
    // 3. CÁC HÀM TIỆN ÍCH TRỢ GIÚP (HELPERS)
    // =========================================================================

    /**
     * Nhận diện loại câu hỏi từ chuỗi nhập vào (hỗ trợ cả tiếng Anh lẫn tiếng Việt).
     */
    private static String resolveType(String raw) {
        String clean = removeDiacritics(raw.toLowerCase(Locale.ROOT)).replace(" ", "_");
        return switch (clean) {
            case "single_choice", "single", "trac_nghiem", "1_dap_an", "mot_dap_an" -> SINGLE;
            case "multiple_choice", "multiple", "nhieu_dap_an" -> MULTIPLE;
            case "fill_in_blank", "fill", "dien_tu", "dien_cho_trong" -> FILL;
            case "" -> null;
            default -> null;
        };
    }

    /**
     * Chuyển ký tự đáp án ("A", "b", "1", "2") thành index tương ứng (0, 1, 2, 3).
     */
    private static int parseLetterToIndex(String token) {
        String clean = token.replaceAll("[^a-zA-Z0-9]", "").toUpperCase(Locale.ROOT);
        if (clean.length() != 1) return -1;

        char c = clean.charAt(0);
        if (c >= 'A' && c <= 'D') return c - 'A';
        if (c >= '1' && c <= '4') return c - '1';
        return -1;
    }

    private static String getCell(String[] row, int index) {
        if (row == null || index >= row.length || row[index] == null) {
            return "";
        }
        return row[index].trim();
    }

    private static boolean isBlankRow(String[] row) {
        if (row == null) return true;
        for (String cell : row) {
            if (cell != null && !cell.trim().isEmpty()) {
                return false;
            }
        }
        return true;
    }

    private static void flushErrors(int rowNum, List<String> errors, QuestionImportResult result) {
        for (String err : errors) {
            result.addError("Dòng " + rowNum + ": " + err);
        }
    }

    private static String removeDiacritics(String text) {
        if (text == null) return "";
        String nfd = java.text.Normalizer.normalize(text, java.text.Normalizer.Form.NFD);
        return nfd.replaceAll("\\p{M}", "").replace('đ', 'd').replace('Đ', 'D').trim();
    }
}
