package com.learnhub.util;

import java.util.regex.Pattern;

public final class FullNameUtil {
    private static final Pattern ALLOWED_CHARACTERS = Pattern.compile("[\\p{L}\\p{M}\\p{Zs}.'’-]+");

    private FullNameUtil() {}

    /**
     * Trims a name supplied by a form or an OAuth provider.
     * Accepts at least one Unicode letter, with spaces and common name punctuation.
     * Returns null if the input is missing, contains other characters, or exceeds 255 characters.
     * Callers must reject null before creating or updating a user.
     */
    public static String normalizeOrNull(String value) {
        if (value == null) return null;

        String name = value.strip();
        if (name.codePointCount(0, name.length()) > 255
                || !ALLOWED_CHARACTERS.matcher(name).matches()
                || name.codePoints().noneMatch(Character::isLetter)) return null;
        return name;
    }
}
