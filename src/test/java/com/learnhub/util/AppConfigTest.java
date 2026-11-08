package com.learnhub.util;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class AppConfigTest {
    @TempDir Path directory;

    @Test
    void readsWindowsFileWithoutChangingCredentialCharacters() throws Exception {
        Path file = directory.resolve(".env");
        Files.writeString(file, "\uFEFF# Local settings\r\n\r\n"
                + "GOOGLE_CLIENT_SECRET=secret=with#hash$and\\slashes\r\n"
                + "SMTP_PASSWORD=' spaced password '\r\n"
                + "GOOGLE_REDIRECT_URI=\"http://localhost:8080/learnhub/auth/oauth/google/callback\"\r\n"
                + "GITHUB_CLIENT_ID=\r\n");
        Map<String, String> settings = AppConfig.readFile(file);
        assertEquals("secret=with#hash$and\\slashes", settings.get("GOOGLE_CLIENT_SECRET"));
        assertEquals(" spaced password ", settings.get("SMTP_PASSWORD"));
        assertEquals("http://localhost:8080/learnhub/auth/oauth/google/callback", settings.get("GOOGLE_REDIRECT_URI"));
        assertNull(AppConfig.resolve("GITHUB_CLIENT_ID", key -> null, settings));
    }

    @Test
    void environmentOverridesFileAndMissingOrBlankEnvironmentFallsBack() {
        Map<String, String> settings = Map.of("GOOGLE_CLIENT_ID", "local-id");
        assertEquals("server-id", AppConfig.resolve("GOOGLE_CLIENT_ID", key -> "server-id", settings));
        assertEquals("local-id", AppConfig.resolve("GOOGLE_CLIENT_ID", key -> null, settings));
        assertEquals("local-id", AppConfig.resolve("GOOGLE_CLIENT_ID", key -> "  ", settings));
        assertNull(AppConfig.resolve("GITHUB_CLIENT_ID", key -> null, settings));
    }

    @Test
    void malformedEntriesReportLineNumberWithoutLeakingSecrets() throws Exception {
        Path file = directory.resolve(".env");
        for (String invalid : new String[]{"SECRET='private-value", "SECRET private-value", "bad key=private-value"}) {
            Files.writeString(file, "# Config\n" + invalid);
            IllegalArgumentException error = assertThrows(IllegalArgumentException.class, () -> AppConfig.readFile(file));
            assertTrue(error.getMessage().contains("line 2"));
            assertFalse(error.getMessage().contains("private-value"));
        }
    }
}
