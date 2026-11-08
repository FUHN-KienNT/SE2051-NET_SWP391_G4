package com.learnhub.service;

import com.learnhub.dao.UserDAO;
import com.learnhub.util.AvatarCloudinary;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Iterator;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

public class AvatarService {
    public static final int MAX_BYTES = 5 * 1024 * 1024;
    private static final Logger LOG = Logger.getLogger(AvatarService.class.getName());
    public enum Result { SUCCESS, INVALID_IMAGE, FAILED }
    public interface Storage {
        String upload(byte[] bytes, String publicId) throws IOException, InterruptedException;
        void delete(String publicId) throws IOException, InterruptedException;
    }
    private final Storage storage;
    private final UserDAO users;
    public AvatarService() { this(new AvatarCloudinary(), new UserDAO()); }
    public AvatarService(Storage storage, UserDAO users) { this.storage = storage; this.users = users; }

    public Result update(UUID userId, byte[] bytes) {
        if (userId == null || !validImage(bytes)) return Result.INVALID_IMAGE;
        String publicId = "learnhub/avatars/" + UUID.randomUUID();
        try {
            String url = storage.upload(bytes, publicId);
            boolean saved;
            try { saved = users.updateOwnAvatar(userId, url); }
            catch (RuntimeException e) { LOG.log(Level.WARNING, "Avatar database update failed", e); saved = false; }
            if (!saved) {
                try { storage.delete(publicId); }
                catch (IOException | RuntimeException e) { LOG.log(Level.WARNING, "Could not clean up avatar " + publicId, e); }
                catch (InterruptedException e) { Thread.currentThread().interrupt(); LOG.log(Level.WARNING, "Avatar cleanup interrupted: " + publicId, e); }
                return Result.FAILED;
            }
            return Result.SUCCESS;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            LOG.log(Level.WARNING, "Avatar upload interrupted", e);
            return Result.FAILED;
        } catch (IOException | RuntimeException e) {
            LOG.log(Level.WARNING, "Avatar upload failed", e);
            return Result.FAILED;
        }
    }

    static boolean validImage(byte[] bytes) {
        if (bytes == null || bytes.length == 0 || bytes.length > MAX_BYTES) return false;
        try (ImageInputStream input = ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))) {
            if (input == null) return false;
            Iterator<ImageReader> readers = ImageIO.getImageReaders(input);
            if (!readers.hasNext()) return false;
            ImageReader reader = readers.next();
            try {
                String format = reader.getFormatName();
                if (!"JPEG".equalsIgnoreCase(format) && !"PNG".equalsIgnoreCase(format)) return false;
                reader.setInput(input, true, true);
                int width = reader.getWidth(0), height = reader.getHeight(0);
                if (width <= 0 || height <= 0 || (long) width * height > 20_000_000) return false;
                return reader.read(0) != null;
            } finally { reader.dispose(); }
        } catch (IOException | RuntimeException e) { return false; }
    }
}
