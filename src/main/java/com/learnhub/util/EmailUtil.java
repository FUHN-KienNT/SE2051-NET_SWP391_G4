package com.learnhub.util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.nio.charset.StandardCharsets;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailUtil {
    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    private EmailUtil() {
    }

    public static boolean sendEmail(String toEmail, String subject, String bodyHtml) {
        String host = System.getenv("SMTP_HOST");
        String username = System.getenv("SMTP_USERNAME");
        String password = System.getenv("SMTP_PASSWORD");
        String from = System.getenv("SMTP_FROM");
        String port = System.getenv("SMTP_PORT");
        if (isBlank(username) || isBlank(password) || "app_specific_password_here".equals(password)) {
            LOGGER.warning("SMTP_USERNAME and SMTP_PASSWORD must be configured in the Tomcat process.");
            return false;
        }
        if (isBlank(host)) host = "smtp.gmail.com";
        if (isBlank(from)) from = username;
        int smtpPort;
        try {
            smtpPort = isBlank(port) ? 587 : Integer.parseInt(port.trim());
            if (smtpPort < 1 || smtpPort > 65535) throw new NumberFormatException("Invalid SMTP port");
        } catch (NumberFormatException e) {
            LOGGER.warning("Invalid SMTP_PORT; email was not sent.");
            return false;
        }

        Properties properties = new Properties();
        properties.put("mail.smtp.host", host.trim());
        properties.put("mail.smtp.port", Integer.toString(smtpPort));
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.starttls.required", "true");
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "10000");
        properties.put("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username.trim(), password);
            }
        });
        try {
            MimeMessage message = new MimeMessage(session);
            InternetAddress sender = new InternetAddress(from.trim(), true);
            InternetAddress recipient = new InternetAddress(toEmail, true);
            sender.validate();
            recipient.validate();
            message.setFrom(sender);
            message.setRecipient(Message.RecipientType.TO, recipient);
            message.setSubject(subject, StandardCharsets.UTF_8.name());
            message.setContent(bodyHtml, "text/html; charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (MessagingException | IllegalArgumentException e) {
            LOGGER.log(Level.WARNING, "Unable to send email", e);
            return false;
        }
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    public static void sendEnrollmentSuccess(String toEmail, String studentName, String courseTitle) {
        String subject = "LearnHub - Kích hoạt khóa học thành công: " + courseTitle;
        String body = "<h3>Xin chào " + escapeHtml(studentName) + ",</h3>" +
                "<p>Chúc mừng bạn đã đăng ký và thanh toán thành công khóa học <strong>" + escapeHtml(courseTitle) + "</strong>.</p>" +
                "<p>Bạn có thể truy cập vào hệ thống LearnHub và bắt đầu học tập ngay bây giờ.</p>" +
                "<br><p>Trân trọng,<br>LearnHub Support Team</p>";
        sendEmail(toEmail, subject, body);
    }

    private static String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
}
