package com.learnhub.service;

import com.learnhub.entity.Question;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Kết quả import câu hỏi từ Excel: danh sách lỗi (nếu có) hoặc thống kê khi thành công.
 * Được lưu tạm trong session để hiển thị sau khi redirect (Post/Redirect/Get).
 */
public class QuestionImportResult implements Serializable {
    private static final long serialVersionUID = 1L;

    /** Chỉ lưu tối đa số lỗi này để tránh trang quá dài; số lỗi thật vẫn được đếm đầy đủ. */
    public static final int MAX_ERRORS_SHOWN = 100;

    private final List<String> errors = new ArrayList<>();
    private int errorCount;

    private List<Question> questions = new ArrayList<>();
    private int importedCount;
    private int singleCount;
    private int multipleCount;
    private int fillCount;

    private String fileName;
    private String moduleTitle;

    public void addError(String message) {
        errorCount++;
        if (errors.size() < MAX_ERRORS_SHOWN) {
            errors.add(message);
        }
    }

    public void addQuestion(Question question) {
        questions.add(question);
        switch (question.getType()) {
            case "multiple_choice" -> multipleCount++;
            case "fill_in_blank" -> fillCount++;
            default -> singleCount++;
        }
    }

    /** Gọi sau khi lưu DB thành công. */
    public void markImported() {
        importedCount = questions.size();
        questions = new ArrayList<>();
    }

    /** Gọi khi không lưu được: bỏ dữ liệu đã parse và các số liệu thống kê. */
    public void markNotImported() {
        questions = new ArrayList<>();
        importedCount = 0;
        singleCount = 0;
        multipleCount = 0;
        fillCount = 0;
    }

    /** Kiểm tra xem kết quả có hợp lệ (không có lỗi và có dữ liệu). */
    public boolean isValid() {
        return errorCount == 0 && (importedCount > 0 || !questions.isEmpty());
    }

    /** Thành công: không có lỗi và đã có câu hỏi (đã parse hoặc đã import vào DB). */
    public boolean isSuccess() {
        return isValid();
    }

    public List<String> getErrors() { return errors; }
    public int getErrorCount() { return errorCount; }
    public int getHiddenErrorCount() { return errorCount - errors.size(); }

    public List<Question> getQuestions() { return questions; }
    public int getImportedCount() { return importedCount > 0 ? importedCount : questions.size(); }
    public int getSingleCount() { return singleCount; }
    public int getMultipleCount() { return multipleCount; }
    public int getFillCount() { return fillCount; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getModuleTitle() { return moduleTitle; }
    public void setModuleTitle(String moduleTitle) { this.moduleTitle = moduleTitle; }
}
