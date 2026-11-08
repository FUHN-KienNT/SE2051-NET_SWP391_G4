package com.learnhub.controller;

import com.learnhub.dao.CourseDAO;
import com.learnhub.dao.RegistrationDAO;
import com.learnhub.dao.UserDAO;
import com.learnhub.entity.Course;
import com.learnhub.entity.Registration;
import com.learnhub.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller for Course Registrations management (List & Detail).
 * Accessible to Admin and Manager roles.
 */
@WebServlet(name = "RegistrationServlet", urlPatterns = {"/manager/registrations", "/admin/registrations"})
public class RegistrationServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(RegistrationServlet.class.getName());

    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = ControllerSupport.currentUser(req);
        if (currentUser == null) {
            ControllerSupport.redirectToLogin(req, resp, ControllerSupport.requestUri(req), null);
            return;
        }

        HttpSession session = req.getSession(false);
        String sessionRole = session != null ? (String) session.getAttribute("userRole") : null;
        if (!isAuthorizedRole(currentUser, sessionRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager or Admin privileges required.");
            return;
        }

        req.setAttribute("basePath", req.getServletPath());

        String action = req.getParameter("action");
        String idParam = req.getParameter("id");
        req.setAttribute("registrationPath", req.getServletPath());

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

        int offset = (page - 1) * pageSize;
        List<Registration> list = registrationDAO.findRegistrations(search, status, paymentStatus, offset, pageSize);
        int totalCount = registrationDAO.countRegistrations(search, status, paymentStatus);
        int totalPages = totalCount > 0 ? (int) Math.ceil((double) totalCount / pageSize) : 1;
        Map<String, Object> stats = registrationDAO.getRegistrationStats(search, status, paymentStatus);

        req.setAttribute("registrations", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("search", search != null ? search.trim() : "");
        req.setAttribute("status", status != null ? status.trim() : "all");
        req.setAttribute("paymentStatus", paymentStatus != null ? paymentStatus.trim() : "all");
        req.setAttribute("stats", stats);

        req.getRequestDispatcher("/WEB-INF/views/admin/registration-list.jsp").forward(req, resp);
    }

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp, String idParam) throws ServletException, IOException {
        try {
            UUID id = UUID.fromString(idParam.trim());
            Registration reg = registrationDAO.findById(id);
            if (reg == null) {
                resp.sendRedirect(req.getContextPath() + req.getServletPath() + "?error=not_found");
                return;
            }

            User student = userDAO.findById(reg.getUserId());
            Course course = courseDAO.findById(reg.getCourseId());

            req.setAttribute("registration", reg);
            req.setAttribute("student", student);
            req.setAttribute("course", course);

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

        HttpSession session = req.getSession(false);
        String sessionRole = session != null ? (String) session.getAttribute("userRole") : null;
        if (!isAuthorizedRole(currentUser, sessionRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied: Manager or Admin privileges required.");
            return;
        }

        String action = req.getParameter("action");
        String idParam = req.getParameter("id");

        if ("updateStatus".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
            try {
                UUID id = UUID.fromString(idParam.trim());
                String newStatus = req.getParameter("status");
                String newPaymentStatus = req.getParameter("paymentStatus");

                if (newStatus == null || newStatus.trim().isEmpty()) {
                    Registration existing = registrationDAO.findById(id);
                    if ("failed".equalsIgnoreCase(newPaymentStatus)) {
                        newStatus = "cancelled";
                    } else if (existing != null && "completed".equalsIgnoreCase(existing.getStatus())) {
                        newStatus = "completed";
                    } else {
                        newStatus = "enrolled";
                    }
                }

                boolean updated = registrationDAO.updateRegistrationStatus(id, newStatus, newPaymentStatus);
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

    private boolean isAuthorizedRole(User user, String sessionRole) {
        if (user == null) return false;
        String rCode = user.getRoleCode() != null ? user.getRoleCode() : "";
        String rName = user.getRoleName() != null ? user.getRoleName() : "";
        String sRole = sessionRole != null ? sessionRole : "";

        return "ROLE_ADMIN".equalsIgnoreCase(rCode)
                || "ROLE_MANAGER".equalsIgnoreCase(rCode)
                || "admin".equalsIgnoreCase(sRole)
                || "manager".equalsIgnoreCase(sRole)
                || "Administrator".equalsIgnoreCase(rName)
                || "Admin".equalsIgnoreCase(rName)
                || "Manager".equalsIgnoreCase(rName);
    }
}
