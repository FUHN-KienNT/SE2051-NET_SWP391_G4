package com.learnhub.service;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.learnhub.entity.User;
import com.learnhub.util.DbConnection;
import com.learnhub.util.PasswordHashUtil;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Base64;
import java.util.Locale;
import java.util.UUID;

/** OAuth 2.0 integration and account resolution for Google and GitHub. */
public class OAuthService {
    public enum Provider { GOOGLE, GITHUB }
    public record Profile(String id, String email, String name) {}

    private static final SecureRandom RANDOM = new SecureRandom();
    private final HttpClient http = HttpClient.newBuilder().followRedirects(HttpClient.Redirect.NEVER).build();

    public static String setting(String name) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? null : value.trim();
    }

    public static String callbackSetting(Provider p) {
        return setting(p == Provider.GOOGLE ? "GOOGLE_REDIRECT_URI" : "GITHUB_REDIRECT_URI");
    }

    public static String clientId(Provider p) { return setting(p == Provider.GOOGLE ? "GOOGLE_CLIENT_ID" : "GITHUB_CLIENT_ID"); }
    private static String clientSecret(Provider p) { return setting(p == Provider.GOOGLE ? "GOOGLE_CLIENT_SECRET" : "GITHUB_CLIENT_SECRET"); }

    public static String newState() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public String authorizationUrl(Provider provider, String state) {
        String clientId = clientId(provider);
        if (clientId == null || clientSecret(provider) == null || callbackSetting(provider) == null) return null;
        String endpoint = provider == Provider.GOOGLE ? "https://accounts.google.com/o/oauth2/v2/auth" : "https://github.com/login/oauth/authorize";
        String scope = provider == Provider.GOOGLE ? "openid email profile" : "read:user user:email";
        return endpoint + "?client_id=" + enc(clientId) + "&redirect_uri=" + enc(callbackSetting(provider))
                + "&response_type=code&scope=" + enc(scope) + "&state=" + enc(state);
    }

    public Profile fetchProfile(Provider provider, String code) throws IOException, InterruptedException {
        String tokenUrl = provider == Provider.GOOGLE ? "https://oauth2.googleapis.com/token" : "https://github.com/login/oauth/access_token";
        String body = "client_id=" + enc(clientId(provider)) + "&client_secret=" + enc(clientSecret(provider))
                + "&code=" + enc(code) + "&redirect_uri=" + enc(callbackSetting(provider)) + "&grant_type=authorization_code";
        HttpRequest tokenRequest = HttpRequest.newBuilder(URI.create(tokenUrl)).header("Accept", "application/json")
                .header("Content-Type", "application/x-www-form-urlencoded").POST(HttpRequest.BodyPublishers.ofString(body)).build();
        JsonObject token = json(send(tokenRequest));
        String accessToken = token.has("access_token") ? token.get("access_token").getAsString() : null;
        if (accessToken == null || accessToken.isBlank()) throw new IOException("OAuth token exchange failed");

        if (provider == Provider.GOOGLE) {
            HttpRequest userRequest = HttpRequest.newBuilder(URI.create("https://www.googleapis.com/oauth2/v3/userinfo"))
                    .header("Authorization", "Bearer " + accessToken).GET().build();
            JsonObject user = json(send(userRequest));
            if (!user.has("email_verified") || !user.get("email_verified").getAsBoolean()) throw new IOException("Verified email required");
            return new Profile(required(user, "sub"), required(user, "email"), optional(user, "name", optional(user, "given_name", "Google user")));
        }

        HttpRequest userRequest = HttpRequest.newBuilder(URI.create("https://api.github.com/user"))
                .header("Authorization", "Bearer " + accessToken).header("Accept", "application/vnd.github+json").header("X-GitHub-Api-Version", "2022-11-28").GET().build();
        JsonObject user = json(send(userRequest));
        String email = null;
        HttpRequest emailRequest = HttpRequest.newBuilder(URI.create("https://api.github.com/user/emails"))
                .header("Authorization", "Bearer " + accessToken).header("Accept", "application/vnd.github+json").GET().build();
        JsonArray emails = JsonParser.parseString(send(emailRequest)).getAsJsonArray();
        for (var item : emails) {
            JsonObject candidate = item.getAsJsonObject();
            if (candidate.has("verified") && candidate.get("verified").getAsBoolean()) {
                if (candidate.has("primary") && candidate.get("primary").getAsBoolean()) { email = candidate.get("email").getAsString(); break; }
                if (email == null) email = candidate.get("email").getAsString();
            }
        }
        if (email == null) throw new IOException("Verified email required");
        return new Profile(required(user, "id"), email, optional(user, "name", optional(user, "login", "GitHub user")));
    }

    public User resolveAccount(Provider provider, Profile profile) throws SQLException {
        String email = profile.email().trim().toLowerCase(Locale.ROOT);
        if (email.isBlank()) throw new SQLException("Verified email required");
        String providerColumn = provider == Provider.GOOGLE ? "google_user_id" : "github_user_id";
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                User user = null;
                boolean foundByProvider = false;
                String linkedProviderId = null;
                String userSelect = "SELECT u.id,u.username,u.email,u.password,u.role_id,u.status,u." + providerColumn + ",s.name role_name,s.code role_code FROM \"user\" u LEFT JOIN setting s ON s.id=u.role_id ";
                try (PreparedStatement ps = conn.prepareStatement(userSelect + "WHERE u." + providerColumn + "=? FOR UPDATE OF u")) {
                    ps.setString(1, profile.id());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) { user = readUser(rs); linkedProviderId = rs.getString(providerColumn); foundByProvider = true; }
                    }
                }
                if (user == null) {
                    try (PreparedStatement ps = conn.prepareStatement(userSelect + "WHERE lower(u.email)=? ORDER BY u.created_at LIMIT 2 FOR UPDATE OF u")) {
                        ps.setString(1, email);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) { user = readUser(rs); linkedProviderId = rs.getString(providerColumn); }
                            if (rs.next()) throw new SQLException("Email matches multiple accounts");
                        }
                    }
                }
                if (user != null && !"active".equalsIgnoreCase(user.getStatus())) throw new SQLException("Account inactive");
                if (user == null) {
                    user = createUser(conn, profile, email, provider);
                } else if (!foundByProvider) {
                    if (linkedProviderId != null && !linkedProviderId.equals(profile.id())) {
                        throw new SQLException("A different account from this provider is already linked");
                    }
                    if (linkedProviderId == null) {
                        try (PreparedStatement ps = conn.prepareStatement("UPDATE \"user\" SET " + providerColumn + "=? WHERE id=? AND " + providerColumn + " IS NULL")) {
                            ps.setString(1, profile.id()); ps.setObject(2, user.getId());
                            if (ps.executeUpdate() != 1) throw new SQLException("Could not link provider account");
                        }
                    }
                }
                conn.commit();
                return user;
            } catch (Exception e) {
                conn.rollback();
                if (e instanceof SQLException sql) throw sql;
                throw new SQLException("Could not resolve OAuth account", e);
            }
        }
    }

    private User createUser(Connection conn, Profile profile, String email, Provider provider) throws Exception {
        String base = profile.name() == null ? "learner" : profile.name().trim().replaceAll("[^\\p{L}\\p{N}._-]", "_");
        if (base.isBlank()) base = "learner";
        String username = base.length() > 220 ? base.substring(0, 220) : base;
        UUID roleId;
        try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' AND status=TRUE LIMIT 1"); ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) throw new SQLException("Student role is not configured");
            roleId = (UUID) rs.getObject(1);
        }
        User user = new User(); user.setId(UUID.randomUUID()); user.setUsername(username); user.setEmail(email);
        user.setPassword(PasswordHashUtil.hashPassword(UUID.randomUUID().toString() + newState())); user.setRoleId(roleId); user.setStatus("active");
        String googleId = provider == Provider.GOOGLE ? profile.id() : null;
        String githubId = provider == Provider.GITHUB ? profile.id() : null;
        try (PreparedStatement ps = conn.prepareStatement("INSERT INTO \"user\"(id,username,email,password,role_id,status,google_user_id,github_user_id) VALUES(?,?,?,?,?,'active',?,?)")) {
            ps.setObject(1,user.getId()); ps.setString(2,user.getUsername()); ps.setString(3,email); ps.setString(4,user.getPassword()); ps.setObject(5,roleId);
            ps.setString(6,googleId); ps.setString(7,githubId); ps.executeUpdate();
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT s.name role_name,s.code role_code FROM setting s WHERE s.id=?")) {
            ps.setObject(1,roleId); try (ResultSet rs=ps.executeQuery()) { if(rs.next()) { user.setRoleName(rs.getString(1)); user.setRoleCode(rs.getString(2)); } }
        }
        return user;
    }

    private static User readUser(ResultSet rs) throws SQLException {
        User u = new User(); u.setId((UUID)rs.getObject("id")); u.setUsername(rs.getString("username")); u.setEmail(rs.getString("email")); u.setPassword(rs.getString("password"));
        u.setRoleId((UUID)rs.getObject("role_id")); u.setStatus(rs.getString("status")); u.setRoleName(rs.getString("role_name")); u.setRoleCode(rs.getString("role_code")); return u;
    }
    private String send(HttpRequest request) throws IOException, InterruptedException {
        HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) throw new IOException("OAuth provider returned HTTP " + response.statusCode());
        return response.body();
    }
    private static JsonObject json(String body) throws IOException { try { return JsonParser.parseString(body).getAsJsonObject(); } catch (RuntimeException e) { throw new IOException("Invalid OAuth response",e); } }
    private static String required(JsonObject o,String key) throws IOException { String v=optional(o,key,null); if(v==null||v.isBlank()) throw new IOException("OAuth profile missing " + key); return v; }
    private static String optional(JsonObject o,String key,String fallback) { return o.has(key)&&!o.get(key).isJsonNull()?o.get(key).getAsString():fallback; }
    private static String enc(String s) { return URLEncoder.encode(s,StandardCharsets.UTF_8); }
}
