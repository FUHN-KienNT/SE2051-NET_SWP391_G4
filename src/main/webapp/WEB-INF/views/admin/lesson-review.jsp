<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="lessonHtml" uri="/WEB-INF/lesson-html.tld" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/lesson-content.css?v=2">

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-16">
    <div class="flex flex-wrap items-center gap-4 mb-6">
        <a href="${pageContext.request.contextPath}/admin/course-detail?id=${course.id}"
           class="inline-flex items-center gap-2 px-3 py-2 border border-border-default rounded-lg text-sm text-text-secondary hover:bg-surface-card focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
            <i class="fa-solid fa-arrow-left" aria-hidden="true"></i> Course Detail
        </a>
        <div class="min-w-0">
            <h1 class="text-2xl font-bold text-text-primary">Lesson Review</h1>
            <p class="text-sm text-text-secondary break-words"><c:out value="${course.title}" /></p>
        </div>
    </div>
    <c:if test="${param.reviewed eq 'true'}">
        <p role="status" class="mb-4 text-sm text-status-success">Lesson review saved.</p>
    </c:if>
    <section aria-label="Lessons" class="border-t border-border-default">
        <c:forEach var="les" items="${lessons}">
            <article class="py-6 border-b border-border-default">
                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                    <div class="min-w-0">
                        <p class="text-xs text-text-secondary break-words"><c:out value="${les.moduleTitle}" /></p>
                        <h2 class="text-lg font-bold text-text-primary break-words"><c:out value="${les.title}" /></h2>
                        <dl class="mt-2 flex flex-wrap gap-x-6 gap-y-2 text-sm">
                            <div class="flex gap-2">
                                <dt class="text-text-secondary">Status</dt>
                                <dd class="font-semibold text-text-primary"><c:out value="${les.publicationStatus}" /></dd>
                            </div>
                            <div class="flex gap-2">
                                <dt class="text-text-secondary">Estimated duration</dt>
                                <dd class="text-text-primary">
                                    <c:choose>
                                        <c:when test="${not empty les.durationMinutes}">${les.durationMinutes} min</c:when>
                                        <c:otherwise>Not set</c:otherwise>
                                    </c:choose>
                                </dd>
                            </div>
                        </dl>
                    </div>
                    <c:if test="${les.publicationStatus eq 'draft'}">
                        <form method="POST" action="${pageContext.request.contextPath}/admin/lesson-review" class="flex flex-wrap gap-2 shrink-0">
                            <input type="hidden" name="csrfToken" value="${sessionScope.lessonReviewToken}">
                            <input type="hidden" name="courseId" value="${course.id}">
                            <input type="hidden" name="lessonId" value="${les.id}">
                            <input type="hidden" name="updatedAt" value="${les.updatedAt}">
                            <button type="submit" name="decision" value="published" aria-label="Approve lesson"
                                    class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-brand-700 text-white text-sm font-semibold hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                <i class="fa-solid fa-check" aria-hidden="true"></i> Approve
                            </button>
                            <button type="submit" name="decision" value="decline" aria-label="Decline lesson"
                                    class="inline-flex items-center gap-2 px-4 py-2 rounded-lg border border-border-default text-status-danger text-sm font-semibold hover:bg-surface-card focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                <i class="fa-solid fa-xmark" aria-hidden="true"></i> Decline
                            </button>
                        </form>
                    </c:if>
                </div>
                <details class="mt-4">
                    <summary class="cursor-pointer text-sm font-semibold text-brand-700 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Content</summary>
                    <div class="lesson-content mt-3 break-words text-sm text-text-primary">${lessonHtml:sanitize(les.content)}</div>
                </details>
            </article>
        </c:forEach>
        <c:if test="${empty lessons}">
            <p class="py-8 text-sm text-text-secondary">No lessons in this course.</p>
        </c:if>
    </section>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
