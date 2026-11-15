package com.learnhub.service;

import com.learnhub.dao.UserDAO;
import org.junit.jupiter.api.Test;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.UUID;
import static org.junit.jupiter.api.Assertions.*;

class AvatarServiceTest {
    static class Store implements AvatarService.Storage {
        boolean failUpload, deleted;
        int uploads;
        String id;
        /**
         * Upload.
         *
         * @param bytes the bytes
         * @param publicId the public id identifier
         * @return the result of upload
         * @throws IOException if the operation cannot complete
         */
        public String upload(byte[] bytes, String publicId) throws IOException {
            uploads++; id = publicId;
            if (failUpload) throw new IOException("unavailable");
            return "https://res.cloudinary.com/example/image/upload/avatar.png";
        }
        /**
         * Delete.
         *
         * @param publicId the public id identifier
         */
        public void delete(String publicId) { assertEquals(id, publicId); deleted = true; }
    }
    static class Users extends UserDAO {
        boolean save = true;
        UUID id;
        String url;
        /**
         * Update own avatar.
         *
         * @param userId the user id identifier
         * @param avatarUrl the avatar url
         * @return true when the condition holds; false otherwise
         */
        public boolean updateOwnAvatar(UUID userId, String avatarUrl) { id = userId; url = avatarUrl; return save; }
    }
    /**
     * Image.
     *
     * @param format the format
     * @return the result of image
     * @throws IOException if the operation cannot complete
     */
    private static byte[] image(String format) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        assertTrue(ImageIO.write(new BufferedImage(2, 2, BufferedImage.TYPE_INT_RGB), format, out));
        return out.toByteArray();
    }
    /**
     * Accepts decoded png and jpeg and saves for current user.
     *
     * @throws IOException if the operation cannot complete
     */
    @Test void acceptsDecodedPngAndJpegAndSavesForCurrentUser() throws IOException {
        for (String format : new String[]{"png", "jpeg"}) {
            Store storage = new Store(); Users users = new Users(); UUID id = UUID.randomUUID();
            assertEquals(AvatarService.Result.SUCCESS, new AvatarService(storage, users).update(id, image(format)));
            assertEquals(id, users.id); assertNotNull(users.url); assertFalse(storage.deleted);
        }
    }
    /**
     * Rejects empty oversized and invalid images before upload.
     *
     * @throws IOException if the operation cannot complete
     */
    @Test void rejectsEmptyOversizedAndInvalidImagesBeforeUpload() throws IOException {
        Store storage = new Store(); AvatarService service = new AvatarService(storage, new Users());
        for (byte[] data : new byte[][] {new byte[0], new byte[AvatarService.MAX_BYTES + 1], "not a png".getBytes(), image("gif")}) {
            assertEquals(AvatarService.Result.INVALID_IMAGE, service.update(UUID.randomUUID(), data));
        }
        assertEquals(0, storage.uploads);
    }
    /**
     * Upload failure does not save and database failure deletes new image.
     *
     * @throws IOException if the operation cannot complete
     */
    @Test void uploadFailureDoesNotSaveAndDatabaseFailureDeletesNewImage() throws IOException {
        Store storage = new Store(); Users users = new Users(); AvatarService service = new AvatarService(storage, users);
        storage.failUpload = true;
        assertEquals(AvatarService.Result.FAILED, service.update(UUID.randomUUID(), image("png")));
        assertNull(users.id); assertFalse(storage.deleted);
        storage.failUpload = false; users.save = false;
        assertEquals(AvatarService.Result.FAILED, service.update(UUID.randomUUID(), image("png")));
        assertTrue(storage.deleted);
    }
}
