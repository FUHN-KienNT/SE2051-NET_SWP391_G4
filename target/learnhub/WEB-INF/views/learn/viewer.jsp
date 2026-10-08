<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

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
        <aside aria-label="Nội dung khóa học"
               class="lg:col-span-1 min-w-0 rounded-xl border border-border-default bg-surface-card shadow-sm overflow-hidden">

            <div class="p-5 border-b border-border-default">
                <p class="text-xs font-semibold uppercase tracking-wide text-brand-700 mb-2">
                    Nội dung khóa học
                </p>

                <h2 class="text-lg font-bold text-text-primary break-words">
                    <c:out value="${course.title}" />
                </h2>

                <div class="flex justify-between gap-3 text-sm mt-4 mb-2">
                    <span class="text-text-secondary">
                        Đã hoàn thành ${completedLessons}/${totalLessons} bài
                    </span>
                    <span class="font-semibold text-brand-700">
                        ${progressPercent}%
                    </span>
                </div>

                <progress value="${progressPercent}"
                          max="100"
                          aria-label="Tiến độ khóa học"
                          class="w-full h-2 rounded-full overflow-hidden text-brand-700 bg-slate-200 [&::-webkit-progress-bar]:bg-slate-200 [&::-webkit-progress-value]:bg-brand-700 [&::-moz-progress-bar]:bg-brand-700">
                </progress>
            </div>

            <div class="divide-y divide-border-default">
                <c:forEach items="${course.modules}"
                           var="module"
                           varStatus="moduleStatus">

                    <details class="viewer-module group"
                             ${module.id eq lesson.moduleId ? 'open' : ''}>

                        <summary class="list-none cursor-pointer flex items-start justify-between gap-3 p-4 hover:bg-surface focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-brand-700">

                            <span class="min-w-0">
                                <span class="block text-xs text-text-secondary mb-1">
                                    Chương ${moduleStatus.count}
                                </span>

                                <span class="block text-sm font-semibold text-text-primary break-words">
                                    <c:out value="${module.title}" />
                                </span>

                                <span class="block text-xs text-text-secondary mt-1">
                                    ${fn:length(module.lessons)} bài học ·
                                    ${fn:length(module.quizzes)} quiz
                                </span>
                            </span>

                            <i class="fa-solid fa-chevron-down text-xs text-text-secondary mt-2 transition-transform group-open:rotate-180"
                               aria-hidden="true"></i>
                        </summary>

                        <ul class="space-y-1 px-2 pb-3">

                            <%-- Lessons --%>
                            <c:forEach items="${module.lessons}" var="item">
                                <c:set var="isCurrent"
                                       value="${item.id eq lesson.id}" />

                                <c:set var="itemStatus"
                                       value="${lessonStatuses[item.id.toString()]}" />

                                <c:url value="/learn/lesson" var="lessonUrl">
                                    <c:param name="courseId"
                                             value="${course.id}" />
                                    <c:param name="lessonId"
                                             value="${item.id}" />
                                </c:url>

                                <li>
                                    <a href="${fn:escapeXml(lessonUrl)}"
                                       aria-current="${isCurrent ? 'page' : 'false'}"
                                       class="flex items-start gap-3 rounded-lg p-3 text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${isCurrent ? 'bg-brand-50 text-brand-900 font-semibold' : 'text-text-primary hover:bg-surface'}">

                                        <i class="fa-solid ${itemStatus eq 'completed' ? 'fa-circle-check text-status-success' : 'fa-file-lines text-text-secondary'} mt-1 shrink-0"
                                           aria-hidden="true"></i>

                                        <span class="min-w-0">
                                            <span class="block break-words">
                                                <c:out value="${item.title}" />
                                            </span>

                                            <span class="block text-xs mt-1 ${itemStatus eq 'completed' ? 'text-status-success' : 'text-text-secondary'}">
                                                <c:choose>
                                                    <c:when test="${itemStatus eq 'completed'}">
                                                        Đã hoàn thành
                                                    </c:when>
                                                    <c:when test="${isCurrent}">
                                                        Đang xem
                                                    </c:when>
                                                    <c:when test="${itemStatus eq 'in_progress'}">
                                                        Đang học
                                                    </c:when>
                                                    <c:otherwise>
                                                        Chưa học
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </span>
                                    </a>
                                </li>
                            </c:forEach>

                            <%-- Quizzes --%>
                            <c:forEach items="${module.quizzes}" var="quiz">
                                <c:url value="/quiz/take" var="quizUrl">
                                    <c:param name="quizId"
                                             value="${quiz.id}" />
                                </c:url>

                                <li>
                                    <a href="${fn:escapeXml(quizUrl)}"
                                       class="flex items-start gap-3 rounded-lg p-3 text-sm text-text-primary hover:bg-surface focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">

                                        <i class="fa-solid fa-list-check text-brand-700 mt-1 shrink-0"
                                           aria-hidden="true"></i>

                                        <span class="min-w-0">
                                            <span class="block font-medium break-words">
                                                <c:out value="${quiz.title}" />
                                            </span>
                                            <span class="block text-xs text-text-secondary mt-1">
                                                Quiz · ${quiz.questionCount} câu hỏi
                                            </span>
                                        </span>
                                    </a>
                                </li>
                            </c:forEach>

                            <c:if test="${empty module.lessons and empty module.quizzes}">
                                <li class="p-3 text-sm text-text-secondary">
                                    Chương này chưa có nội dung.
                                </li>
                            </c:if>
                        </ul>
                    </details>
                </c:forEach>

                <c:if test="${empty course.modules}">
                    <p class="p-5 text-sm text-text-secondary">
                        Khóa học chưa có chương.
                    </p>
                </c:if>
            </div>
        </aside>

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

                    <c:if test="${not empty lesson.materialUrl}">
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
                            <div class="lesson-content text-text-primary leading-relaxed break-words">${lesson.content}</div>
                        </c:when>

                        <c:when test="${empty lesson.materialUrl}">
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

    .lesson-content {
        white-space: pre-wrap;
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

<script>
    // Remember the last viewed lesson for this account and course.
    (() => {
        const viewer = document.querySelector('[data-lesson-id]');
        if (!viewer) return;

        const data = viewer.dataset;

        if (!data.lessonUser || !data.lessonCourse || !data.lessonId) {
            return;
        }

        const key = 'learnhub:lastLesson:'
                + data.lessonContext + ':'
                + data.lessonUser + ':'
                + data.lessonCourse;

        try {
            localStorage.setItem(key, JSON.stringify({
                lessonId: data.lessonId,
                lessonTitle: data.lessonTitle
            }));
        } catch (error) {
            // Learning still works if browser storage is unavailable.
        }
    })();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />