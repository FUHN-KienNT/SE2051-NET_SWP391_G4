package com.learnhub.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Global Error Controller.
 * Intercepts HTTP errors and exceptions forwarded from web.xml or filters,
 * logs diagnostic details, and forwards to user-friendly error views.
 */
@WebServlet(name = "ErrorServlet", urlPatterns = {"/error"})
public class ErrorServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ErrorServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleError(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleError(req, resp);
    }

    private void handleError(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Retrieve standard Jakarta servlet error attributes
        Integer statusCode = (Integer) req.getAttribute("jakarta.servlet.error.status_code");
        String message = (String) req.getAttribute("jakarta.servlet.error.message");
        Throwable exception = (Throwable) req.getAttribute("jakarta.servlet.error.exception");
        String requestUri = (String) req.getAttribute("jakarta.servlet.error.request_uri");

        // Fallback to query parameter if called directly, e.g. /error?code=404
        if (statusCode == null) {
            String codeParam = req.getParameter("code");
            if (codeParam != null && !codeParam.trim().isEmpty()) {
                try {
                    statusCode = Integer.parseInt(codeParam.trim());
                } catch (NumberFormatException ignored) {
                }
            }
        }

        if (statusCode == null) {
            statusCode = HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        }

        if (requestUri == null) {
            requestUri = req.getRequestURI();
        }

        // Log appropriately based on error severity
        if (exception != null) {
            LOGGER.log(Level.SEVERE, "Unhandled Exception at [" + requestUri + "]: " + exception.getMessage(), exception);
        } else if (statusCode >= 500) {
            LOGGER.log(Level.SEVERE, "Server Error (" + statusCode + ") at [" + requestUri + "]: " + (message != null ? message : "No details"));
        } else {
            LOGGER.log(Level.WARNING, "Client Error (" + statusCode + ") at [" + requestUri + "]: " + (message != null ? message : "No details"));
        }

        req.setAttribute("statusCode", statusCode);
        req.setAttribute("errorMessage", message);
        req.setAttribute("requestUri", requestUri);

        // Forward to the appropriate JSP view
        if (statusCode == HttpServletResponse.SC_NOT_FOUND) {
            req.getRequestDispatcher("/WEB-INF/views/common/404.jsp").forward(req, resp);
        } else if (statusCode == HttpServletResponse.SC_FORBIDDEN) {
            req.getRequestDispatcher("/WEB-INF/views/common/403.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/common/500.jsp").forward(req, resp);
        }
    }
}
