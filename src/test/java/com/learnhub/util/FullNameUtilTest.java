package com.learnhub.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class FullNameUtilTest {
    @Test
    void acceptsNamesWithUnicodeLettersAndCommonNamePunctuation() {
        assertEquals("Nguyễn Văn A", FullNameUtil.normalizeOrNull("  Nguyễn Văn A  "));
        assertEquals("O’Neill", FullNameUtil.normalizeOrNull("O’Neill"));
        assertEquals("Jean-Luc Picard", FullNameUtil.normalizeOrNull("Jean-Luc Picard"));
        assertEquals("J. R. R. Tolkien", FullNameUtil.normalizeOrNull("J. R. R. Tolkien"));
        assertEquals("Jose\u0301", FullNameUtil.normalizeOrNull("Jose\u0301"));
        assertEquals("李", FullNameUtil.normalizeOrNull("李"));
        assertEquals("Nguyễn...", FullNameUtil.normalizeOrNull("Nguyễn..."));
        assertEquals("An--", FullNameUtil.normalizeOrNull("An--"));
    }

    @Test
    void rejectsMissingNamesAndNonNameCharacters() {
        assertNull(FullNameUtil.normalizeOrNull(null));
        assertNull(FullNameUtil.normalizeOrNull(" \t "));
        assertNull(FullNameUtil.normalizeOrNull("Nguyễn abc@123"));
        assertNull(FullNameUtil.normalizeOrNull("Nguyễn 123"));
        assertNull(FullNameUtil.normalizeOrNull("Nguyễn_An"));
        assertNull(FullNameUtil.normalizeOrNull("..."));
        assertNull(FullNameUtil.normalizeOrNull("a".repeat(256)));
        assertEquals("a".repeat(255), FullNameUtil.normalizeOrNull("a".repeat(255)));
    }
}
