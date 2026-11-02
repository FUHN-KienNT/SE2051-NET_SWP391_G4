<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="lessonHtml" uri="/WEB-INF/lesson-html.tld" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/lesson-content.css?v=2">

<main data-lesson-user="${sessionScope.currentUser.id}"
      data-lesson-course="${course.id}"
      data-lesson-id="${lesson.id}"
      data-lesson-title="${fn:escapeXml(lesson.title)}"
      data-lesson-context="${fn:escapeXml(pageContext.request.contextPath)}"
      class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

    <nav aria-label="Breadcrumb"
         class="mb-6 flex flex-wrap items-center gap-2 text-sm text-text-secondary">
        <a href="${pageContext.request.contextPath}/my-enrollments"
           class="rounded font-semibold text-brand-700 hover:text-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700">
            Khóa học của tôi
        </a>
        <span aria-hidden="true">/</span>
        <span class="break-words">
            <c:out value="${course.title}" />
        </span>
    </nav>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 items-start">

        <%-- Sidebar: course progress, modules, lessons and quizzes --%>
        <jsp:include page="/WEB-INF/views/learn/sidebar.jsp" />

        <%-- Main lesson content --%>
        <section aria-labelledby="lesson-heading"
                 class="lg:col-span-3 min-w-0">

            <article class="rounded-xl border border-border-default bg-surface-card shadow-sm overflow-hidden">

                <header class="p-6 sm:p-8 border-b border-border-default">
                    <p class="text-sm font-semibold text-brand-700 mb-2">
                        Bài học
                    </p>

                    <h1 id="lesson-heading"
                        class="text-2xl sm:text-3xl font-bold text-text-primary break-words">
                        <c:out value="${lesson.title}" />
                    </h1>

                    <c:if test="${lesson.status eq 'completed'}">
                        <p class="inline-flex items-center gap-2 mt-4 rounded-lg bg-brand-50 px-3 py-2 text-sm font-semibold text-status-success">
                            <i class="fa-solid fa-circle-check"
                               aria-hidden="true"></i>
                            Đã hoàn thành
                        </p>
                    </c:if>
                </header>

                <div class="p-6 sm:p-8 space-y-6">

                    <c:if test="${lesson.type eq 'video' and not empty videoEmbedUrl}">
                        <div class="aspect-video overflow-hidden rounded-xl border border-border-default bg-surface-inverse">
                            <iframe src="${fn:escapeXml(videoEmbedUrl)}" title="${fn:escapeXml(lesson.title)}"
                                    class="w-full h-full border-0" allow="autoplay; encrypted-media; fullscreen; picture-in-picture"
                                    referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
                        </div>
                        <p class="text-sm text-text-secondary">Video tự phát ở chế độ tắt tiếng. Bạn có thể bật âm thanh trong trình phát.</p>
                    </c:if>
                    <c:if test="${lesson.type ne 'video' and not empty lesson.materialUrl}">
                        <div class="aspect-video overflow-hidden rounded-xl border border-border-default bg-surface">
                            <iframe src="${fn:escapeXml(lesson.materialUrl)}"
                                    title="${fn:escapeXml(lesson.title)}"
                                    class="w-full h-full border-0"
                                    allow="fullscreen; picture-in-picture"
                                    allowfullscreen>
                            </iframe>
                        </div>

                        <a href="${fn:escapeXml(lesson.materialUrl)}"
                           target="_blank"
                           rel="noopener noreferrer"
                           class="inline-flex items-center gap-2 rounded text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700">
                            <i class="fa-solid fa-arrow-up-right-from-square"
                               aria-hidden="true"></i>
                            Mở tài liệu trong tab mới
                        </a>
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty lesson.content}">
                            <div class="lesson-content text-text-primary leading-relaxed break-words">${lessonHtml:sanitize(lesson.content)}</div>
                        </c:when>

                        <c:when test="${empty lesson.materialUrl and lesson.type ne 'video'}">
                            <p class="text-text-secondary">
                                Bài học chưa có nội dung.
                            </p>
                        </c:when>
                    </c:choose>
                </div>

                <%-- Mark Complete is placed after the lesson content --%>
                <footer class="p-6 sm:px-8 border-t border-border-default bg-surface flex flex-col sm:flex-row sm:items-center justify-between gap-4">

                    <p class="text-sm text-text-secondary">
                        Hoàn thành bài học để cập nhật tiến độ của bạn.
                    </p>

                    <c:choose>
                        <c:when test="${lesson.status eq 'completed'}">
                            <button type="button"
                                    disabled
                                    class="inline-flex items-center justify-center gap-2 rounded-lg bg-brand-100 text-brand-900 px-5 py-3 font-semibold cursor-default">
                                <i class="fa-solid fa-check"
                                   aria-hidden="true"></i>
                                Đã hoàn thành
                            </button>
                        </c:when>

                        <c:otherwise>
                            <form action="${pageContext.request.contextPath}/learn/complete"
                                  method="post">

                                <input type="hidden"
                                       name="courseId"
                                       value="${course.id}">

                                <input type="hidden"
                                       name="registrationId"
                                       value="${registration.id}">

                                <input type="hidden"
                                       name="lessonId"
                                       value="${lesson.id}">

                                <button type="submit"
                                        class="w-full inline-flex items-center justify-center gap-2 rounded-lg bg-brand-700 hover:bg-brand-800 text-white px-5 py-3 font-semibold focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                    <i class="fa-solid fa-check"
                                       aria-hidden="true"></i>
                                    Mark Complete
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </footer>
            </article>

            <nav aria-label="Điều hướng bài học"
                 class="flex flex-wrap justify-between gap-3 mt-6">

                <c:if test="${not empty prevLesson}">
                    <c:url value="/learn/lesson" var="previousUrl">
                        <c:param name="courseId" value="${course.id}" />
                        <c:param name="lessonId" value="${prevLesson.id}" />
                    </c:url>

                    <a href="${fn:escapeXml(previousUrl)}"
                       class="rounded-lg border border-border-default bg-surface-card px-4 py-3 text-sm font-semibold hover:bg-slate-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                        &larr; Bài trước
                    </a>
                </c:if>

                <c:if test="${not empty nextLesson}">
                    <c:url value="/learn/lesson" var="nextUrl">
                        <c:param name="courseId" value="${course.id}" />
                        <c:param name="lessonId" value="${nextLesson.id}" />
                    </c:url>

                    <a href="${fn:escapeXml(nextUrl)}"
                       class="ml-auto rounded-lg bg-brand-700 hover:bg-brand-800 text-white px-4 py-3 text-sm font-semibold focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                        Bài tiếp theo &rarr;
                    </a>
                </c:if>
            </nav>
        </section>
    </div>
</main>

<style>
    .viewer-module summary::-webkit-details-marker {
        display: none;
    }

    progress {
        accent-color: currentColor;
    }


    .lesson-content img,
    .lesson-content video,
    .lesson-content iframe {
        max-width: 100%;
    }

    .lesson-content pre {
        max-width: 100%;
        overflow-x: auto;
    }

    .lesson-content table {
        display: block;
        max-width: 100%;
        overflow-x: auto;
    }
</style>

<script src="${pageContext.request.contextPath}/assets/js/lesson-last-viewed.js"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
