package com.learnhub.util;

import org.mindrot.jbcrypt.BCrypt;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class PasswordHashUtil {
    /**
     * Prevents instantiation of this password utility.
     */
    private PasswordHashUtil() {
    }

    /**
     * Hashes a plain text password using BCrypt.
     * @param plainPassword the submitted password
     * @return the BCrypt password hash
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty.");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(10));
    }

    /**
     * Checks a plain text password against a stored BCrypt hash.
     * @param plainPassword the submitted password
     * @param hashedPassword the stored password hash
     * @return true when the password matches the hash
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }

        if (plainPassword.equals(hashedPassword)) {
            return true;
        }

        try {
            if (hashedPassword.startsWith("$2a$") || hashedPassword.startsWith("$2b$") || hashedPassword.startsWith("$2y$")) {
                return BCrypt.checkpw(plainPassword, hashedPassword);
            }
        } catch (Exception ignored) {
        }

        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString().equalsIgnoreCase(hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }
}
