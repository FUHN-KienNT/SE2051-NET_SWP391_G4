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
}
