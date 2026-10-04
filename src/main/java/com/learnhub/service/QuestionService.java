package com.learnhub.service;

import com.learnhub.dao.QuestionDAO;
import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Business layer for the shared Question Bank.
 */
public class QuestionService {

    private final QuestionDAO dao = new QuestionDAO();

    public List<Question> search(
            String keyword,
            String type) {

        return dao.search(keyword, type);
    }

    public Question get(UUID id) {
        return dao.findById(id);
    }

    /**
     * Save question.
     *
     * optionIds:
     * - existing option -> UUID of existing question_option
     * - new option -> empty/null
     */
    public boolean save(
            UUID id,
            String content,
            String type,
            String[] optionIds,
            String[] optionTexts,
            String[] correctIndexes) {

        if (content == null
                || content.trim().isEmpty()) {
            return false;
        }

        if (type == null
                || type.trim().isEmpty()) {
            return false;
        }

        /*
         * CREATE:
         * tạo UUID ngay từ Service.
         *
         * UPDATE:
         * sử dụng UUID hiện tại.
         */
        UUID questionId =
                id != null ? id : UUID.randomUUID();

        Question question = new Question();

        question.setId(questionId);
        question.setContent(content.trim());
        question.setType(type);

        List<QuestionOption> options =
                new ArrayList<>();

        Set<Integer> correctIndexesSet =
                new HashSet<>();

        /*
         * Đọc index của đáp án đúng.
         */
        if (correctIndexes != null) {

            for (String value : correctIndexes) {

                if (value == null || value.isBlank()) {
                    continue;
                }

                try {
                    correctIndexesSet.add(
                            Integer.parseInt(value)
                    );
                } catch (NumberFormatException ignored) {
                }
            }
        }

        /*
         * Đọc các option.
         */
        if (optionTexts != null) {

            for (int i = 0;
                 i < optionTexts.length;
                 i++) {

                String text = optionTexts[i];

                if (text == null
                        || text.trim().isEmpty()) {
                    continue;
                }

                QuestionOption option =
                        new QuestionOption();

                /*
                 * Nếu là option cũ:
                 * giữ nguyên ID.
                 */
                UUID optionId = null;

                if (optionIds != null
                        && i < optionIds.length
                        && optionIds[i] != null
                        && !optionIds[i].isBlank()) {

                    try {
                        optionId =
                                UUID.fromString(
                                        optionIds[i]
                                );
                    } catch (IllegalArgumentException ignored) {
                        /*
                         * ID không hợp lệ -> coi như option mới.
                         */
                    }
                }

                option.setId(optionId);
                option.setQuestionId(questionId);
                option.setOptionText(text.trim());
                option.setCorrect(
                        correctIndexesSet.contains(i)
                );

                options.add(option);
            }
        }

        /*
         * Validation cho Choice Question.
         */
        if ("single_choice".equals(type)
                || "multiple_choice".equals(type)) {

            /*
             * Phải có ít nhất 2 lựa chọn.
             */
            if (options.size() < 2) {
                return false;
            }

            /*
             * Phải có đáp án đúng.
             */
            if (correctIndexesSet.isEmpty()) {
                return false;
            }

            /*
             * Single Choice chỉ được đúng 1 đáp án.
             */
            if ("single_choice".equals(type)
                    && correctIndexesSet.size() != 1) {
                return false;
            }
        }

        /*
         * Text question:
         * không cần option.
         */

        /*
         * CREATE
         */
        if (id == null) {
            return dao.insert(question, options);
        }

        /*
         * UPDATE
         */
        return dao.update(question, options);
    }

    public boolean delete(UUID id) {

        if (id == null) {
            return false;
        }

        /*
         * Không cho xóa Question đang được Quiz sử dụng.
         */
        if (dao.isUsedInQuiz(id)) {
            return false;
        }

        return dao.delete(id);
    }

    public boolean isUsedInQuiz(UUID id) {
        return dao.isUsedInQuiz(id);
    }
}
