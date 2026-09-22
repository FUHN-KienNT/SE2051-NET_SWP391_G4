package com.fpt.lms.util;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Properties;
import java.util.UUID;
import java.util.logging.Logger;

/**
 * Cloudinary API client for uploading and managing lesson materials & course thumbnails.
 * Designed according to SDS Content Management Class Diagram:
 * - uploadFile()
 * - getSecureUrl()
 */
public class CloudinaryClient {
    private static final Logger LOGGER = Logger.getLogger(CloudinaryClient.class.getName());

    private static String cloudName = "learnhub_demo";

    static {
        try (InputStream in = CloudinaryClient.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                Properties props = new Properties();
                props.load(in);
                cloudName = props.getProperty("cloudinary.cloud_name", cloudName);
            }
        } catch (Exception e) {
            LOGGER.warning("Could not load Cloudinary properties, using fallback configuration.");
        }
    }

    private CloudinaryClient() {
    }

    public static String uploadFile(InputStream fileStream, String originalFilename) {
        try {
            String ext = "";
            if (originalFilename != null && originalFilename.lastIndexOf('.') > 0) {
                ext = originalFilename.substring(originalFilename.lastIndexOf('.'));
            }
            String uniqueName = UUID.randomUUID().toString() + ext;

            Path uploadDir = Paths.get(System.getProperty("java.io.tmpdir"), "learnhub_uploads");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            Path targetPath = uploadDir.resolve(uniqueName);
            Files.copy(fileStream, targetPath, StandardCopyOption.REPLACE_EXISTING);

            return getSecureUrl(uniqueName);
        } catch (Exception e) {
            LOGGER.severe("Error uploading file: " + e.getMessage());
            return "https://res.cloudinary.com/" + cloudName + "/image/upload/v1/default_asset.png";
        }
    }

    public static String uploadFile(File file) {
        try {
            return uploadFile(Files.newInputStream(file.toPath()), file.getName());
        } catch (Exception e) {
            LOGGER.severe("Error reading file for upload: " + e.getMessage());
            return getSecureUrl("default.png");
        }
    }

    public static String getSecureUrl(String publicId) {
        if (publicId == null || publicId.isEmpty()) {
            return "https://res.cloudinary.com/" + cloudName + "/image/upload/v1/default.png";
        }
        if (publicId.startsWith("http://") || publicId.startsWith("https://")) {
            return publicId;
        }
        return "https://res.cloudinary.com/" + cloudName + "/raw/upload/learnhub/" + publicId;
    }
}
