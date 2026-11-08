<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:url var="reviewFormAction" value="${reviewAction}" />
<form method="post" action="${fn:escapeXml(reviewFormAction)}" class="space-y-3">
    <input type="hidden" name="csrfToken" value="${sessionScope.lessonReviewToken}">
    <input type="hidden" name="courseId" value="${reviewLesson.courseId}">
    <input type="hidden" name="id" value="${reviewLesson.id}">
    <input type="hidden" name="lessonId" value="${reviewLesson.id}">
    <input type="hidden" name="updatedAt" value="${reviewLesson.updatedAt}">
    <div class="flex flex-wrap gap-3">
        <button type="submit" name="decision" value="published" formnovalidate
                class="inline-flex items-center justify-center gap-2 rounded-lg bg-brand-700 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
            <i class="fa-solid fa-check" aria-hidden="true"></i> Accept
        </button>
        <button type="button" aria-expanded="false" aria-controls="decline-panel-${reviewLesson.id}"
                onclick="const panel=this.form.querySelector('[data-decline-panel]'); panel.hidden=false; const reason=panel.querySelector('textarea'); reason.required=true; reason.focus(); this.setAttribute('aria-expanded','true');"
                class="inline-flex items-center justify-center gap-2 rounded-lg border border-status-danger px-4 py-2 text-sm font-semibold text-status-danger hover:bg-surface focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
            <i class="fa-solid fa-xmark" aria-hidden="true"></i> Decline
        </button>
    </div>
    <div id="decline-panel-${reviewLesson.id}" data-decline-panel hidden class="space-y-2">
        <label for="decline-reason-${reviewLesson.id}" class="block text-sm font-semibold text-text-primary">Reason for declining <span class="text-status-danger">*</span></label>
        <textarea id="decline-reason-${reviewLesson.id}" name="declineReason" rows="3"
                  class="block w-full rounded-lg border border-border-default bg-surface-card px-3 py-2 text-sm text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700"><c:out value="${param.declineReason}" /></textarea>
        <button type="submit" name="decision" value="decline"
                class="rounded-lg bg-status-danger px-4 py-2 text-sm font-semibold text-white hover:opacity-90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Confirm Decline</button>
    </div>
</form>