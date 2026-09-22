package com.fpt.lms.controller;

import com.fpt.lms.entity.ContentReview;
import com.fpt.lms.entity.User;
import com.fpt.lms.service.ContentReviewService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * Servlet handling Content Review workflows for Expert submissions and Manager approvals.
 * Implements methods specified in SDS Content Management Diagram (2.1, 2.3):
 * - submitForReview()
 * - approve()
 * - reject()
 */
@WebServlet(name = "ContentReviewServlet", urlPatterns = {"/content/review", "/content/submit"})
public class ContentReviewServlet extends HttpServlet {
    private final ContentReviewService reviewService = new ContentReviewService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<ContentReview> pendingReviews = reviewService.getPendingReviews();
        req.setAttribute("pendingReviews", pendingReviews);
        req.getRequestDispatcher("/WEB-INF/views/admin/content-review.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("submit".equalsIgnoreCase(action)) {
            String lessonIdStr = req.getParameter("lessonId");
            if (lessonIdStr != null) {
                reviewService.submitContent(UUID.fromString(lessonIdStr), currentUser.getId());
            }
            resp.sendRedirect(req.getContextPath() + "/lessons/manage?submitted=true");
            return;
        }

        String reviewIdStr = req.getParameter("reviewId");
        String comments = req.getParameter("comments");

        if (reviewIdStr != null) {
            UUID reviewId = UUID.fromString(reviewIdStr);
            if ("approve".equalsIgnoreCase(action)) {
                reviewService.approveContent(reviewId, currentUser.getId());
            } else if ("reject".equalsIgnoreCase(action)) {
                reviewService.rejectContent(reviewId, currentUser.getId(), comments != null ? comments : "Rejected by manager");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/content/review");
    }
}
