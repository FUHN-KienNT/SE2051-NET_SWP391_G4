package com.learnhub.util;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.learnhub.service.AvatarService;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.UUID;

/** Signed Cloudinary image upload and deletion; credentials are read from the process environment. */
public class AvatarCloudinary implements AvatarService.Storage {
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
    private String setting(String key) throws IOException {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) throw new IOException("Cloudinary is not configured: " + key);
        return value;
    }
    private URI endpoint(String operation) throws IOException {
        String cloud = setting("CLOUDINARY_CLOUD_NAME");
        if (!cloud.matches("[A-Za-z0-9_-]+")) throw new IOException("Invalid Cloudinary cloud name");
        return URI.create("https://api.cloudinary.com/v1_1/" + cloud + "/image/" + operation);
    }
    private String signature(String publicId, String timestamp) throws IOException {
        String text = "public_id=" + publicId + "&timestamp=" + timestamp + setting("CLOUDINARY_API_SECRET");
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-1").digest(text.getBytes(StandardCharsets.UTF_8))); }
        catch (NoSuchAlgorithmException e) { throw new IOException(e); }
    }
    @Override public String upload(byte[] bytes, String publicId) throws IOException, InterruptedException {
        String timestamp = Long.toString(Instant.now().getEpochSecond());
        String boundary = "learnhub" + UUID.randomUUID().toString().replace("-", "");
        ByteArrayOutputStream body = new ByteArrayOutputStream();
        field(body, boundary, "public_id", publicId);
        field(body, boundary, "timestamp", timestamp);
        field(body, boundary, "api_key", setting("CLOUDINARY_API_KEY"));
        field(body, boundary, "signature", signature(publicId, timestamp));
        body.write(("--" + boundary + "\r\nContent-Disposition: form-data; name=\"file\"; filename=\"avatar\"\r\nContent-Type: application/octet-stream\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        body.write(bytes);
        body.write(("\r\n--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));
        HttpRequest req = HttpRequest.newBuilder(endpoint("upload")).timeout(Duration.ofSeconds(30))
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .POST(HttpRequest.BodyPublishers.ofByteArray(body.toByteArray())).build();
        JsonObject response = send(req);
        try {
            String url = response.get("secure_url").getAsString();
            URI uri = URI.create(url);
            if (!"https".equals(uri.getScheme()) || !"res.cloudinary.com".equals(uri.getHost())
                    || !uri.getPath().startsWith("/" + setting("CLOUDINARY_CLOUD_NAME") + "/")) throw new IOException("Invalid Cloudinary URL");
            return url;
        } catch (RuntimeException e) { throw new IOException("Invalid Cloudinary response", e); }
    }
    @Override public void delete(String publicId) throws IOException, InterruptedException {
        String timestamp = Long.toString(Instant.now().getEpochSecond());
        String body = "public_id=" + enc(publicId) + "&timestamp=" + enc(timestamp) + "&api_key=" + enc(setting("CLOUDINARY_API_KEY")) + "&signature=" + enc(signature(publicId, timestamp));
        HttpRequest req = HttpRequest.newBuilder(endpoint("destroy")).timeout(Duration.ofSeconds(30))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body)).build();
        JsonObject response = send(req);
        if (!response.has("result") || !("ok".equals(response.get("result").getAsString()) || "not found".equals(response.get("result").getAsString()))) throw new IOException("Cloudinary deletion failed");
    }
    private JsonObject send(HttpRequest req) throws IOException, InterruptedException {
        HttpResponse<String> response = client.send(req, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) throw new IOException("Cloudinary returned HTTP " + response.statusCode());
        try { return JsonParser.parseString(response.body()).getAsJsonObject(); }
        catch (RuntimeException e) { throw new IOException("Invalid Cloudinary response", e); }
    }
    private static String enc(String value) { return URLEncoder.encode(value, StandardCharsets.UTF_8); }
    private static void field(ByteArrayOutputStream body, String boundary, String name, String value) throws IOException {
        body.write(("--" + boundary + "\r\nContent-Disposition: form-data; name=\"" + name + "\"\r\n\r\n" + value + "\r\n").getBytes(StandardCharsets.UTF_8));
    }
}
