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

            <%-- Direct Quiz Link under Lesson --%>
            <c:set var="currentModule" value="${null}" />
            <c:forEach items="${course.modules}" var="moduleItem">
                <c:if test="${not empty lesson and moduleItem.id eq lesson.moduleId}">
                    <c:set var="currentModule" value="${moduleItem}" />
                </c:if>
            </c:forEach>

            <c:if test="${not empty currentModule and not empty currentModule.quizzes}">
                <div class="mt-6 p-6 rounded-xl border border-brand-200 bg-brand-50/50 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                    <div class="flex items-start gap-3.5">
                        <div class="w-10 h-10 rounded-xl bg-brand-100 text-brand-700 flex items-center justify-center font-bold shrink-0 mt-0.5">
                            <i class="fa-solid fa-clipboard-question text-lg"></i>
                        </div>
                        <div>
                            <p class="text-xs font-bold uppercase tracking-wider text-brand-700">Ôn tập kiến thức</p>
                            <h3 class="text-base font-bold text-text-primary mt-0.5">Bài kiểm tra ôn tập của chương này</h3>
                            <div class="flex flex-wrap items-center gap-3 mt-1.5 text-xs text-text-secondary">
                                <c:forEach var="qz" items="${currentModule.quizzes}" varStatus="qst">
                                    <span class="font-medium text-slate-700">
                                        <i class="fa-solid fa-circle-check text-brand-600 mr-1"></i>${qz.title} (${qz.questionCount} câu hỏi)
                                    </span>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                    <div class="flex items-center gap-2 shrink-0 w-full sm:w-auto">
                        <c:forEach var="qz" items="${currentModule.quizzes}" varStatus="qst">
                            <c:url value="/quiz" var="directQuizUrl">
                                <c:param name="quizId" value="${qz.id}" />
                                <c:param name="courseId" value="${course.id}" />
                            </c:url>
                            <a href="${fn:escapeXml(directQuizUrl)}"
                               class="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-lg bg-brand-700 hover:bg-brand-800 text-white text-sm font-semibold shadow-sm transition">
                                <span>Vào làm Quiz</span>
                                <i class="fa-solid fa-arrow-right text-xs"></i>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

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