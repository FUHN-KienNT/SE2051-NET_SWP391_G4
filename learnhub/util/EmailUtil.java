package com.learnhub.util;

import java.util.logging.Logger;

public class EmailUtil {
    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    private EmailUtil() {
    }

    public static boolean sendEmail(String toEmail, String subject, String bodyHtml) {
        LOGGER.info("Sending email to " + toEmail + " | Subject: " + subject);
        return true;
    }

    public static void sendEnrollmentSuccess(String toEmail, String studentName, String courseTitle) {
        String subject = "LearnHub - Kích hoạt khóa học thành công: " + courseTitle;
        String body = "<h3>Xin chào " + studentName + ",</h3>" +
                "<p>Chúc mừng bạn đã đăng ký và thanh toán thành công khóa học <strong>" + courseTitle + "</strong>.</p>" +
                "<p>Bạn có thể truy cập vào hệ thống LearnHub và bắt đầu học tập ngay bây giờ.</p>" +
                "<br><p>Trân trọng,<br>LearnHub Support Team</p>";
        sendEmail(toEmail, subject, body);
    }
}
