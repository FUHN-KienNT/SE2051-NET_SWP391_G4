package com.learnhub.util;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/** Local OAuth/mail settings; process environment takes precedence over the external .env file. */
public final class AppConfig {
    private AppConfig() {}

    private static final class LocalFile {
        private static final Map<String, String> VALUES = loadLocalFile();
    }

    public static String get(String name) {
        return resolve(name, System::getenv, LocalFile.VALUES);
    }

    static String resolve(String name, Function<String, String> environment, Map<String, String> local) {
        String value = environment.apply(name);
        if (value == null || value.isBlank()) value = local.get(name);
        return value == null || value.isBlank() ? null : value;
    }

    private static Map<String, String> loadLocalFile() {
        String configuredPath = System.getProperty("learnhub.envFile");
        boolean explicit = configuredPath != null && !configuredPath.isBlank();
        Path path = Path.of(explicit ? configuredPath : ".env");
        try {
            return readFile(path);
        } catch (NoSuchFileException e) {
            if (!explicit) return Map.of();
            throw new IllegalStateException("Configured learnhub.envFile does not exist.");
        } catch (IOException e) {
            throw new IllegalStateException("Unable to read LearnHub .env file.");
        }
    }

    /** Single-line KEY=VALUE entries; optional matching quotes, no interpolation or escape expansion. */
    static Map<String, String> readFile(Path path) throws IOException {
        Map<String, String> values = new HashMap<>();
        int lineNumber = 0;
        for (String raw : Files.readAllLines(path, StandardCharsets.UTF_8)) {
            lineNumber++;
            if (lineNumber == 1 && raw.startsWith("\uFEFF")) raw = raw.substring(1);
            String line = raw.trim();
            if (line.isEmpty() || line.startsWith("#")) continue;
            int separator = line.indexOf('=');
            if (separator < 1) throw invalidLine(lineNumber);
            String key = line.substring(0, separator).trim();
            if (!key.matches("[A-Za-z_][A-Za-z0-9_]*")) throw invalidLine(lineNumber);
            String value = line.substring(separator + 1).trim();
            if (value.startsWith("\"") || value.startsWith("'")) {
                if (value.length() < 2 || value.charAt(value.length() - 1) != value.charAt(0)) {
                    throw invalidLine(lineNumber);
                }
                value = value.substring(1, value.length() - 1);
            }
            values.put(key, value);
        }
        return Map.copyOf(values);
    }

    private static IllegalArgumentException invalidLine(int lineNumber) {
        // Never include the original line: it can contain a credential.
        return new IllegalArgumentException("Invalid .env entry at line " + lineNumber + ". Use KEY=VALUE.");
    }
}
