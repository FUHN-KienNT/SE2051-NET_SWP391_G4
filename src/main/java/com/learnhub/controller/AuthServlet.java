package com.learnhub.controller;

import com.learnhub.entity.User;
import com.learnhub.service.UserService;
import com.learnhub.util.EmailUtil;
import com.learnhub.util.PasswordHashUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet(name = "AuthServlet", urlPatterns = {
        "/auth/login", "/auth/register", "/auth/verify-email", "/auth/resend-code", "/auth/logout"
})
public class AuthServlet extends HttpServlet {
    private static final String PENDING_REGISTRATION = "auth.pendingRegistration";
    private static final SecureRandom CODE_RANDOM = new SecureRandom();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession authSession = req.getSession(false);
        if (authSession != null) {
            Object oauthError = authSession.getAttribute("oauth.error");
            if (oauthError != null) {
                req.setAttribute("errorMessage", oauthError);
                authSession.removeAttribute("oauth.error");
            }
        }
        if ("/auth/logout".equals(path)) {
            if (authSession != null) authSession.invalidate();
            resp.sendRedirect(req.getContextPath() + "/home?logout=success");
            return;
        }
        if ("/auth/register".equals(path)) {
            if (req.getParameter("expired") != null) {
                req.setAttribute("errorMessage", "Your verification session expired. Please sign up again.");
            }
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }
        if ("/auth/verify-email".equals(path)) {
            PendingRegistration pending = authSession == null ? null :
                    (PendingRegistration) authSession.getAttribute(PENDING_REGISTRATION);
            if (pending == null) {
                resp.sendRedirect(req.getContextPath() + "/auth/register?expired=1");
                return;
            }
            showVerification(req, resp, pending);
            return;
        }
        if ("/auth/login".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }
        resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        switch (req.getServletPath()) {
            case "/auth/login" -> login(req, resp);
            case "/auth/register" -> register(req, resp);
            case "/auth/verify-email" -> verify(req, resp);
            case "/auth/resend-code" -> resend(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    private void login(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        User user = userService.login(email, req.getParameter("password"));
        if (user == null) {
            req.setAttribute("email", email);
            req.setAttribute("errorMessage", "Email hoặc mật khẩu không chính xác, hoặc tài khoản đã bị khóa.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        req.changeSessionId();
        session.removeAttribute(PENDING_REGISTRATION);
        session.setAttribute("currentUser", user);
        session.setAttribute("userName", user.getUsername());
        session.setAttribute("userRole", user.getRoleCode());

        String redirectUri = req.getParameter("redirect_uri");
        if (redirectUri != null && !redirectUri.trim().isEmpty()) {
            resp.sendRedirect(redirectUri);
        } else if ("ROLE_ADMIN".equalsIgnoreCase(user.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } else {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }

    private void register(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = trim(req.getParameter("username"));
        String email = trim(req.getParameter("email")).toLowerCase(Locale.ROOT);
        String password = req.getParameter("password");
        String confirmation = req.getParameter("confirmPassword");
        req.setAttribute("username", username);
        req.setAttribute("email", email);

        String error = null;
        if (!username.matches("^[\\p{L}\\p{N}._-]{3,255}$") || email.length() > 255 ||
                !email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            error = "Enter a valid username and email address.";
        } else if (password == null || password.length() < 8 || password.length() > 72 ||
                password.getBytes(StandardCharsets.UTF_8).length > 72) {
            error = "Password must be at least 8 characters and no more than 72 bytes.";
        } else if (!password.equals(confirmation)) {
            error = "Passwords do not match.";
        } else if (userService.isRegistrationIdentityTaken(username, email)) {
            error = "This email or username is already in use.";
        }
        if (error != null) {
            req.setAttribute("errorMessage", error);
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        synchronized (session) {
            PendingRegistration previous = (PendingRegistration) session.getAttribute(PENDING_REGISTRATION);
            if (previous != null && previous.getEmail().equals(email) && !previous.canResend(Instant.now())) {
                previous.updateDetails(username, PasswordHashUtil.hashPassword(password));
                resp.sendRedirect(req.getContextPath() + "/auth/verify-email?wait=1");
                return;
            }
            String code = newCode();
            PendingRegistration candidate = new PendingRegistration(
                    username, email, PasswordHashUtil.hashPassword(password), code, Instant.now());
            if (!sendVerificationCode(email, code)) {
                req.setAttribute("errorMessage", "We could not send the verification email. Please try again later.");
                req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
                return;
            }
            session.setAttribute(PENDING_REGISTRATION, candidate);
        }
        resp.sendRedirect(req.getContextPath() + "/auth/verify-email?sent=1");
    }

    private void verify(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/register?expired=1");
            return;
        }
        synchronized (session) {
            PendingRegistration pending = (PendingRegistration) session.getAttribute(PENDING_REGISTRATION);
            if (pending == null) {
                resp.sendRedirect(req.getContextPath() + "/auth/register?expired=1");
                return;
            }
            VerificationResult result = pending.checkCode(req.getParameter("code"), Instant.now());
            if (result == VerificationResult.VALID) {
                User registered = userService.registerVerified(
                        pending.getUsername(), pending.getEmail(), pending.getPasswordHash());
                if (registered != null) {
                    session.removeAttribute(PENDING_REGISTRATION);
                    resp.sendRedirect(req.getContextPath() + "/auth/login?verified=success");
                    return;
                }
                req.setAttribute("errorMessage", "Account creation failed. This email or username may already be in use.");
            } else if (result == VerificationResult.EXPIRED) {
                req.setAttribute("errorMessage", "This code has expired. Request a new code.");
            } else if (result == VerificationResult.LOCKED) {
                req.setAttribute("errorMessage", "Too many incorrect attempts. Request a new code.");
            } else {
                req.setAttribute("errorMessage", "Incorrect code. Please try again.");
            }
            showVerification(req, resp, pending);
        }
    }

    private void resend(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/register?expired=1");
            return;
        }
        synchronized (session) {
            PendingRegistration pending = (PendingRegistration) session.getAttribute(PENDING_REGISTRATION);
            if (pending == null) {
                resp.sendRedirect(req.getContextPath() + "/auth/register?expired=1");
                return;
            }
            if (!pending.canResend(Instant.now())) {
                resp.sendRedirect(req.getContextPath() + "/auth/verify-email?wait=1");
                return;
            }
            String code = newCode();
            if (!sendVerificationCode(pending.getEmail(), code)) {
                req.setAttribute("errorMessage", "We could not send a new code. Please try again later.");
                showVerification(req, resp, pending);
                return;
            }
            pending.replaceCode(code, Instant.now());
        }
        resp.sendRedirect(req.getContextPath() + "/auth/verify-email?sent=1");
    }

    private void showVerification(HttpServletRequest req, HttpServletResponse resp, PendingRegistration pending)
            throws ServletException, IOException {
        req.setAttribute("pendingEmail", pending.getEmail());
        req.getRequestDispatcher("/WEB-INF/views/auth/verify-email.jsp").forward(req, resp);
    }

    private boolean sendVerificationCode(String email, String code) {
        String body = "<p>Use this code to finish creating your LearnHub account:</p>"
                + "<p style=\"font-size:24px;font-weight:bold;letter-spacing:4px\">" + code + "</p>"
                + "<p>The code expires in 10 minutes. If you did not sign up, you can ignore this email.</p>";
        return EmailUtil.sendEmail(email, "LearnHub verification code", body);
    }

    private static String newCode() {
        return String.format(Locale.ROOT, "%06d", CODE_RANDOM.nextInt(1_000_000));
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private enum VerificationResult { VALID, INVALID, EXPIRED, LOCKED }

    /** Registration data remains in the user's HTTP session until the code is verified. */
    private static final class PendingRegistration implements Serializable {
        private static final long serialVersionUID = 1L;
        private static final Duration CODE_LIFETIME = Duration.ofMinutes(10);
        private static final Duration RESEND_DELAY = Duration.ofSeconds(60);
        private static final int MAX_ATTEMPTS = 5;

        private String username;
        private final String email;
        private String passwordHash;
        private String codeHash;
        private Instant sentAt;
        private int failedAttempts;

        private PendingRegistration(String username, String email, String passwordHash, String code, Instant now) {
            this.username = username;
            this.email = email;
            this.passwordHash = passwordHash;
            replaceCode(code, now);
        }

        private String getUsername() { return username; }
        private String getEmail() { return email; }
        private String getPasswordHash() { return passwordHash; }

        private void updateDetails(String username, String passwordHash) {
            this.username = username;
            this.passwordHash = passwordHash;
        }

        private boolean canResend(Instant now) {
            return !now.isBefore(sentAt.plus(RESEND_DELAY));
        }

        private void replaceCode(String code, Instant now) {
            codeHash = BCrypt.hashpw(code, BCrypt.gensalt(10));
            sentAt = now;
            failedAttempts = 0;
        }

        private VerificationResult checkCode(String code, Instant now) {
            if (!now.isBefore(sentAt.plus(CODE_LIFETIME))) return VerificationResult.EXPIRED;
            if (failedAttempts >= MAX_ATTEMPTS) return VerificationResult.LOCKED;
            if (code != null && code.matches("[0-9]{6}") && BCrypt.checkpw(code, codeHash)) {
                return VerificationResult.VALID;
            }
            failedAttempts++;
            return failedAttempts >= MAX_ATTEMPTS ? VerificationResult.LOCKED : VerificationResult.INVALID;
        }
    }
}
