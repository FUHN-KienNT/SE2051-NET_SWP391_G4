<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="lessonHtml" uri="/WEB-INF/lesson-html.tld" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/lesson-content.css?v=2">

<main class="mx-auto w-full max-w-5xl flex-grow px-4 py-8 sm:px-6 lg:px-8">
    <c:url var="previewBackUrl" value="${backPath}">
        <c:param name="courseId" value="${lesson.courseId}" />
    </c:url>
    <a href="${fn:escapeXml(previewBackUrl)}"
       class="mb-6 inline-flex items-center gap-2 rounded-lg border border-border-default bg-surface-card px-4 py-2 text-sm font-semibold text-text-primary hover:bg-brand-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
        <i class="fa-solid fa-arrow-left" aria-hidden="true"></i> Back
    </a>
    <c:if test="${not empty reviewError}">
        <p role="alert" class="mb-4 rounded-lg border border-status-danger bg-surface-card p-4 text-sm text-status-danger"><c:out value="${reviewError}" /></p>
    </c:if>
    <c:if test="${not empty lesson.declineReason and lesson.publicationStatus eq 'decline'}">
        <aside class="mb-4 rounded-lg border border-status-danger bg-surface-card p-4" aria-label="Decline reason">
            <h2 class="text-sm font-semibold text-status-danger">Reason for declining</h2>
            <p class="mt-2 whitespace-pre-wrap break-words text-sm text-text-primary"><c:out value="${lesson.declineReason}" /></p>
        </aside>
    </c:if>
    <article class="overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-sm">
        <header class="border-b border-border-default p-6 sm:p-8">
            <h1 class="break-words text-2xl font-bold text-text-primary sm:text-3xl"><c:out value="${lesson.title}" /></h1>
        </header>
        <div class="space-y-6 p-6 sm:p-8">
            <c:if test="${lesson.type eq 'video' and not empty videoEmbedUrl}">
                <div class="aspect-video overflow-hidden rounded-xl border border-border-default bg-surface-inverse">
                    <iframe src="${fn:escapeXml(videoEmbedUrl)}" title="${fn:escapeXml(lesson.title)}"
                            class="h-full w-full border-0" allow="autoplay; encrypted-media; fullscreen; picture-in-picture"
                            referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
                </div>
            </c:if>
            <c:choose>
                <c:when test="${lesson.type eq 'quiz'}">
                    <c:choose>
                        <c:when test="${not empty quiz}">
                            <h2 class="break-words text-xl font-semibold text-text-primary"><c:out value="${quiz.title}" /></h2>
                            <c:forEach var="question" items="${questions}" varStatus="questionLoop">
                                <section class="space-y-3 rounded-lg border border-border-default p-4">
                                    <h3 class="font-semibold text-text-primary">Question ${questionLoop.count}</h3>
                                    <p class="whitespace-pre-wrap break-words text-text-primary"><c:out value="${question.content}" /></p>
                                    <ul class="space-y-2">
                                        <c:forEach var="option" items="${question.options}">
                                            <li class="break-words rounded-lg border p-3 text-sm ${option.correct ? 'border-brand-100 bg-brand-50 text-brand-900' : 'border-border-default text-text-primary'}">
                                                <c:out value="${option.optionText}" />
                                                <c:if test="${option.correct}"><span class="ml-2 font-semibold"><i class="fa-solid fa-check" aria-hidden="true"></i> Correct answer</span></c:if>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </section>
                            </c:forEach>
                            <c:if test="${empty questions}"><p class="text-text-secondary">This quiz has no questions.</p></c:if>
                        </c:when>
                        <c:otherwise><p class="text-text-secondary">The linked quiz is unavailable.</p></c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <div class="lesson-content break-words leading-relaxed text-text-primary">${lessonHtml:sanitize(lesson.content)}</div>
                    <c:if test="${empty lesson.content and lesson.type ne 'video'}"><p class="text-text-secondary">This lesson has no content.</p></c:if>
                </c:otherwise>
            </c:choose>
        </div>
        <c:if test="${isManagerPreview and lesson.publicationStatus eq 'draft'}">
            <footer class="border-t border-border-default bg-surface p-6 sm:p-8">
                <c:set var="reviewLesson" value="${lesson}" scope="request" />
                <jsp:include page="/WEB-INF/views/common/lesson-review-actions.jsp" />
            </footer>
        </c:if>
    </article>
</main>
</body>
</html>