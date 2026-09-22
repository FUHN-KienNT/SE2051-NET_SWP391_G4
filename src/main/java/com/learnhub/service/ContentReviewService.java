package com.learnhub.service;

import com.learnhub.dao.ContentReviewDAO;
import com.learnhub.entity.ContentReview;

import java.util.List;
import java.util.UUID;

/**
 * Service managing content reviews by subject experts and managers.
 * Implements methods specified in Content Management Class Diagram (SDS 2.1):
 * - submitContent()
 * - approveContent()
 * - rejectContent()
 */
public class ContentReviewService {
    private final ContentReviewDAO contentReviewDAO;
    private final NotificationService notificationService;

    public ContentReviewService() {
        this.contentReviewDAO = new ContentReviewDAO();
        this.notificationService = new NotificationService();
    }

    public boolean submitContent(UUID lessonId, UUID expertId) {
        ContentReview cr = new ContentReview();
        cr.setId(UUID.randomUUID());
        cr.setLessonId(lessonId);
        cr.setExpertId(expertId);
        cr.setStatus("pending");
        return contentReviewDAO.insert(cr);
    }

    public boolean approveContent(UUID reviewId, UUID managerId) {
        return contentReviewDAO.updateStatus(reviewId, managerId, "approved", "Noi dung da duoc phe duyet hop le.");
    }

    public boolean rejectContent(UUID reviewId, UUID managerId, String reason) {
        return contentReviewDAO.updateStatus(reviewId, managerId, "rejected", reason);
    }

    public List<ContentReview> getPendingReviews() {
        return contentReviewDAO.findPendingReviews();
    }
}
