package com.learnhub.controller;

import com.learnhub.service.PaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
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
    private final PaymentService paymentService = new PaymentService();

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

        PaymentService.SePayResult result = paymentService.processSePayWebhook(requestBody);

        resp.setStatus(result.httpStatusCode());
        out.write(String.format("{\"success\": %b, \"message\": \"%s\"}", result.success(), result.message()));
    }
}