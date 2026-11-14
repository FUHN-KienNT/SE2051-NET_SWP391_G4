package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import com.learnhub.service.RegistrationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller for Course Registrations management (List & Detail).
 * Accessible to Manager only.
 * Enforces Controller -> Service -> DAO clean architecture.
 */
@WebServlet(name = "RegistrationServlet", urlPatterns = {"/manager/registrations"})
public class RegistrationServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(RegistrationServlet.class.getName());

    private final RegistrationService registrationService = new RegistrationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), null);
            return;
        }

        if (!isAuthorizedRole(currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager privileges required.");
            return;
        }

        req.setAttribute("basePath", req.getServletPath());

        String action = req.getParameter("action");
        String idParam = req.getParameter("id");

        if ("detail".equalsIgnoreCase(action) || (idParam != null && !idParam.trim().isEmpty() && action == null)) {
            handleDetail(req, resp, idParam);
            return;
        }

        handleList(req, resp);
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        String status = req.getParameter("status");
        String paymentStatus = req.getParameter("paymentStatus");

        int page = 1;
        int pageSize = 10;
        try {
            if (req.getParameter("page") != null) {
                page = Math.max(1, Integer.parseInt(req.getParameter("page")));
            }
        } catch (NumberFormatException ignored) {}

        try {
            if (req.getParameter("pageSize") != null) {
                pageSize = Math.max(1, Math.min(100, Integer.parseInt(req.getParameter("pageSize"))));
            }
        } catch (NumberFormatException ignored) {}

        RegistrationService.RegistrationPageData data = registrationService.getRegistrations(
                search, status, paymentStatus, page, pageSize);

        req.setAttribute("registrations", data.list());
        req.setAttribute("currentPage", data.currentPage());
        req.setAttribute("pageSize", data.pageSize());
        req.setAttribute("totalCount", data.totalCount());
        req.setAttribute("totalPages", data.totalPages());
        req.setAttribute("search", search != null ? search.trim() : "");
        req.setAttribute("status", status != null ? status.trim() : "all");
        req.setAttribute("paymentStatus", paymentStatus != null ? paymentStatus.trim() : "all");
        req.setAttribute("stats", data.stats());

        req.getRequestDispatcher("/WEB-INF/views/admin/registration-list.jsp").forward(req, resp);
    }

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp, String idParam) throws ServletException, IOException {
        try {
            UUID id = UUID.fromString(idParam.trim());
            RegistrationService.RegistrationDetailData detail = registrationService.getRegistrationDetail(id);
            if (detail == null || detail.registration() == null) {
                resp.sendRedirect(req.getContextPath() + req.getServletPath() + "?error=not_found");
                return;
            }

            req.setAttribute("registration", detail.registration());
            req.setAttribute("student", detail.student());
            req.setAttribute("course", detail.course());

            req.getRequestDispatcher("/WEB-INF/views/admin/registration-detail.jsp").forward(req, resp);
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Error loading registration detail: " + ex.getMessage(), ex);
            resp.sendRedirect(req.getContextPath() + req.getServletPath() + "?error=invalid_id");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), null);
            return;
        }

        if (!isAuthorizedRole(currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager privileges required.");
            return;
        }

        String action = req.getParameter("action");
        String idParam = req.getParameter("id");

        if ("updateStatus".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
            try {
                UUID id = UUID.fromString(idParam.trim());
                String newStatus = req.getParameter("status");
                String newPaymentStatus = req.getParameter("paymentStatus");

                boolean updated = registrationService.updateRegistrationStatus(id, newStatus, newPaymentStatus);
                String redirectUrl = req.getContextPath() + req.getServletPath() + "?action=detail&id=" + id;
                if (updated) {
                    resp.sendRedirect(redirectUrl + "&success=updated");
                } else {
                    resp.sendRedirect(redirectUrl + "&error=update_failed");
                }
                return;
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING, "Error updating registration: " + ex.getMessage(), ex);
                resp.sendRedirect(req.getContextPath() + req.getServletPath() + "?error=invalid_data");
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + req.getServletPath());
    }

    private boolean isAuthorizedRole(User user) {
        return user != null && AppConstants.Role.MANAGER.equalsIgnoreCase(user.getRoleCode());
    }
}