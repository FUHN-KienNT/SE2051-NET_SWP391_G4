package com.learnhub.service;

import com.learnhub.dao.QuestionDAO;
import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;

import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Business layer for the shared Question Bank.
 */
public class QuestionService {

    private static final Logger LOGGER = Logger.getLogger(QuestionService.class.getName());
    private final QuestionDAO dao = new QuestionDAO();

    public static final int MAX_WORDS_QUESTION_CONTENT = 120;

    public List<Question> search(String keyword, String type) {
        return search(keyword, type, null, null, null);
    }

    public List<Question> search(
            String keyword,
            String type,
            UUID moduleId,
            UUID courseId,
            String status) {

        return dao.search(keyword, type, moduleId, courseId, status);
    }

    public Question get(UUID id) {
        return dao.findById(id);
    }

    public boolean save(
            UUID id,
            String content,
            String type,
            String[] optionIds,
            String[] optionTexts,
            String[] correctIndexes) {
        return save(id, null, content, type, "public", optionIds, optionTexts, correctIndexes);
    }

    /**
     * Save question with moduleId and status support.
     */
    public boolean save(
            UUID id,
            UUID moduleId,
            String content,
            String type,
            String status,
            String[] optionIds,
            String[] optionTexts,
            String[] correctIndexes) {

        if (content == null || content.trim().isEmpty()) {
            return false;
        }

        // Limit question words
        int wordCount = countWords(content);
        if (wordCount > MAX_WORDS_QUESTION_CONTENT) {
            return false;
        }

        if (type == null || type.trim().isEmpty()) {
            return false;
        }

        String normalizedType = "single_choice";
        if ("multiple_choice".equalsIgnoreCase(type)) {
            normalizedType = "multiple_choice";
        } else if ("fill_in_blank".equalsIgnoreCase(type) || "text".equalsIgnoreCase(type)) {
            normalizedType = "fill_in_blank";
        }

        UUID questionId = id != null ? id : UUID.randomUUID();

        Question question = new Question();
        question.setId(questionId);
        question.setModuleId(moduleId);
        question.setContent(content.trim());
        question.setType(normalizedType);
        question.setStatus(status != null && !status.isBlank() ? status.trim() : "public");

        List<QuestionOption> options = new ArrayList<>();
        Set<Integer> correctIndexesSet = new HashSet<>();

        if (correctIndexes != null) {
            for (String value : correctIndexes) {
                if (value == null || value.isBlank()) continue;
                try {
                    correctIndexesSet.add(Integer.parseInt(value));
                } catch (NumberFormatException ignored) {}
            }
        }

        if (optionTexts != null) {
            for (int i = 0; i < optionTexts.length; i++) {
                String text = optionTexts[i];
                if (text == null || text.trim().isEmpty()) continue;

                QuestionOption option = new QuestionOption();
                UUID optionId = null;

                if (optionIds != null && i < optionIds.length && optionIds[i] != null && !optionIds[i].isBlank()) {
                    try {
                        optionId = UUID.fromString(optionIds[i]);
                    } catch (IllegalArgumentException ignored) {}
                }

                option.setId(optionId);
                option.setQuestionId(questionId);
                option.setOptionText(text.trim());

                if ("fill_in_blank".equals(normalizedType)) {
                    // For fill in blank, all entered keyword options are valid correct answers
                    option.setCorrect(true);
                } else {
                    option.setCorrect(correctIndexesSet.contains(i));
                }

                options.add(option);
            }
        }

        // Validation for choice questions
        if ("single_choice".equals(normalizedType) || "multiple_choice".equals(normalizedType)) {
            if (options.size() < 2) {
                return false;
            }
            if (correctIndexesSet.isEmpty()) {
                return false;
            }
            if ("single_choice".equals(normalizedType) && correctIndexesSet.size() != 1) {
                return false;
            }
        } else if ("fill_in_blank".equals(normalizedType)) {
            // Must have at least 1 keyword
            if (options.isEmpty()) {
                return false;
            }
        }

        if (id == null) {
            return dao.insert(question, options);
        }

        return dao.update(question, options);
    }

    /**
     * Soft delete / hide.
     */
    public boolean delete(UUID id) {
        if (id == null) {
            return false;
        }
        return dao.hide(id);
    }

    public boolean hide(UUID id) {
        if (id == null) return false;
        return dao.hide(id);
    }

    public boolean unhide(UUID id) {
        if (id == null) return false;
        return dao.unhide(id);
    }

    public boolean isUsedInQuiz(UUID id) {
        return dao.isUsedInQuiz(id);
    }

    public static int countWords(String text) {
        if (text == null || text.trim().isEmpty()) {
            return 0;
        }
        String trimmed = text.trim().replaceAll("\\s+", " ");
        return trimmed.split(" ").length;
    }
    public int importFromDocument(UUID moduleId, String status, String docText) {
        if (docText == null || docText.trim().isEmpty()) {
            return 0;
        }

        String[] lines = docText.split("\\r?\\n");
        int count = 0;

        String currentContent = null;
        String currentType = "single_choice";
        List<String> currentOptionTexts = new ArrayList<>();
        List<String> currentCorrectIndexes = new ArrayList<>();

        for (int i = 0; i <= lines.length; i++) {
            String line = (i < lines.length) ? lines[i].trim() : "";
            boolean isEndOfFile = (i == lines.length);

            boolean isNewQuestionHeader = false;
            if (!isEndOfFile) {
                String lower = line.toLowerCase();
                if (lower.startsWith("câu ") || lower.startsWith("cau ") || lower.startsWith("question ")
                        || line.matches("^\\d+[\\.\\:\\)].*")) {
                    isNewQuestionHeader = true;
                }
            }

            if (isNewQuestionHeader || isEndOfFile) {
                // Save previous question if exists
                if (currentContent != null && !currentContent.isBlank()) {
                    if (currentCorrectIndexes.size() > 1 && !"fill_in_blank".equals(currentType)) {
                        currentType = "multiple_choice";
                    }
                    boolean saved = save(
                            null,
                            moduleId,
                            currentContent,
                            currentType,
                            status != null ? status : "public",
                            null,
                            currentOptionTexts.toArray(new String[0]),
                            currentCorrectIndexes.toArray(new String[0])
                    );
                    if (saved) {
                        count++;
                    }
                }

                // Reset for next question
                currentContent = null;
                currentType = "single_choice";
                currentOptionTexts = new ArrayList<>();
                currentCorrectIndexes = new ArrayList<>();

                if (isEndOfFile) break;

                // Extract content without leading "Câu 1:" etc.
                int colonIdx = line.indexOf(':');
                int dotIdx = line.indexOf('.');
                int startContentIdx = 0;
                if (colonIdx > 0 && colonIdx < 15) {
                    startContentIdx = colonIdx + 1;
                } else if (dotIdx > 0 && dotIdx < 10) {
                    startContentIdx = dotIdx + 1;
                }
                currentContent = line.substring(startContentIdx).trim();
                continue;
            }

            if (currentContent == null) {
                if (!line.isEmpty()) {
                    currentContent = line;
                }
                continue;
            }

            // Check if line is option: A. B. C. D. or *A. or [x] A.
            String trimmedLine = line;
            boolean isCorrect = false;
            if (trimmedLine.startsWith("*") || trimmedLine.startsWith("+") || trimmedLine.startsWith("[x]")) {
                isCorrect = true;
                trimmedLine = trimmedLine.replaceFirst("^(\\*|\\+|\\[x\\])\\s*", "");
            }

            // Check fill in blank answers (e.g. "Đáp án: keyword1, keyword2")
            String lowerLine = trimmedLine.toLowerCase();
            if (lowerLine.startsWith("đáp án:") || lowerLine.startsWith("dap an:")
                    || lowerLine.startsWith("answer:") || lowerLine.startsWith("keywords:")) {
                currentType = "fill_in_blank";
                int colon = trimmedLine.indexOf(':');
                String answerStr = (colon >= 0) ? trimmedLine.substring(colon + 1).trim() : "";
                String[] keywords = answerStr.split("[,;]");
                for (String kw : keywords) {
                    if (!kw.trim().isEmpty()) {
                        currentOptionTexts.add(kw.trim());
                    }
                }
                continue;
            }

            // Match choice options like "A.", "B)", "[A]", "A -"
            if (trimmedLine.matches("^[A-Ha-h][\\.\\:\\-\\)]\\s*.*")) {
                int optIdx = currentOptionTexts.size();
                String optText = trimmedLine.replaceFirst("^[A-Ha-h][\\.\\:\\-\\)]\\s*", "").trim();
                currentOptionTexts.add(optText);
                if (isCorrect) {
                    currentCorrectIndexes.add(String.valueOf(optIdx));
                }
            } else if (!trimmedLine.isEmpty()) {
                // Continuation of question content if no options added yet
                if (currentOptionTexts.isEmpty()) {
                    currentContent += " " + trimmedLine;
                }
            }
        }

        // Determine if multiple_choice
        if (currentCorrectIndexes.size() > 1 && !"fill_in_blank".equals(currentType)) {
            currentType = "multiple_choice";
        }

        return count;
    }
}
