package com.learnhub.controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.entity.Registration;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SePay Webhook Endpoint.
 * Receives JSON webhook notification whenever money transfer arrives in bank account.
 * URL: /api/payment/sepay-webhook
 * Method: POST
 */
@WebServlet(name = "SePayWebhookServlet", urlPatterns = {"/api/payment/sepay-webhook"})
public class SePayWebhookServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SePayWebhookServlet.class.getName());
    private final RegistrationDAO registrationDAO = new RegistrationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String requestBody = sb.toString();
        LOGGER.info("SePay Webhook Received Body: " + requestBody);

        if (requestBody.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"success\": false, \"message\": \"Empty body\"}");
            return;
        }

        try {
            JsonObject json = JsonParser.parseString(requestBody).getAsJsonObject();
            
            // SePay fields: content (nội dung chuyển khoản), transferAmount, id, referenceCode...
            String content = json.has("content") ? json.get("content").getAsString() : "";
            long transferAmount = json.has("transferAmount") ? json.get("transferAmount").getAsLong() : 0;
            String transactionId = json.has("id") ? json.get("id").getAsString() : ("SP" + System.currentTimeMillis());

            // Tìm mã đơn dạng: LH<8_CHAR_HEX>
            String matchedRegPrefix = null;
            if (content != null && content.toUpperCase().contains("LH")) {
                int idx = content.toUpperCase().indexOf("LH");
                String sub = content.substring(idx);
                // Lấy chuỗi sau LH gồm 8 ký tự alphanumeric
                String[] parts = sub.split("[^a-zA-Z0-9]");
                if (parts.length > 0) {
                    matchedRegPrefix = parts[0].toUpperCase(); // Ví dụ LH4A8B9C12
                }
            }

            LOGGER.info("SePay Webhook Extracted Code: " + matchedRegPrefix + ", Amount: " + transferAmount);

            boolean updated = false;
            if (matchedRegPrefix != null && matchedRegPrefix.length() >= 4) {
                String hexPart = matchedRegPrefix.substring(2); // Cắt bỏ "LH"
                // Quét các đơn đang pending để tìm đơn có ID bắt đầu bằng chuỗi hex này
                List<Registration> pendingList = registrationDAO.findRegistrations("", "pending", 0, 50);
                for (Registration reg : pendingList) {
                    String regHex = reg.getId().toString().replace("-", "").substring(0, 8).toUpperCase();
                    if (regHex.startsWith(hexPart)) {
                        reg.setTransactionId(transactionId);
                        registrationDAO.updateRegistrationStatus(reg.getId(), "enrolled", "paid");
                        LOGGER.info("SePay Webhook Success: Activated registration " + reg.getId());
                        updated = true;
                        break;
                    }
                }
            }

            if (updated) {
                out.write("{\"success\": true, \"message\": \"Payment processed successfully\"}");
            } else {
                LOGGER.warning("SePay Webhook: No matching pending registration found for content: " + content);
                out.write("{\"success\": false, \"message\": \"Order not found or already paid\"}");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing SePay Webhook JSON", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"success\": false, \"message\": \"Internal error: " + e.getMessage() + "\"}");
        }
    }
}
