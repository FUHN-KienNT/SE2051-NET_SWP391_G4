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
      class="flex-grow py-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">

    <a href="${pageContext.request.contextPath}/my-enrollments"
       class="inline-block mb-6 rounded text-brand-700 font-semibold focus-visible:ring-2 focus-visible:ring-brand-700">
        &larr; Khóa học của tôi
    </a>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">

        <div class="lg:col-span-3 space-y-6">

            <div class="bg-surface-inverse rounded-2xl overflow-hidden aspect-video flex items-center justify-center shadow-sm">
                <c:choose>
                    <c:when test="${not empty lesson.materialUrl}">
                        <iframe class="w-full h-full"
                                src="${fn:escapeXml(lesson.materialUrl)}"
                                title="${fn:escapeXml(lesson.title)}"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen>
                        </iframe>
                    </c:when>

                    <c:otherwise>
                        <div class="text-center text-slate-400 p-8">
                            <i class="fa-regular fa-file-lines text-5xl mb-3"
                               aria-hidden="true"></i>
                            <p class="text-lg font-semibold text-white">
                                <c:out value="${lesson.title}" />
                            </p>
                            <p class="text-sm">
                                Bài học dạng tài liệu và bài tập đọc hiểu
                            </p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="bg-surface-card p-6 rounded-xl border border-border-default shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                    <h1 class="text-2xl font-bold text-text-primary">
                        <c:out value="${lesson.title}" />
                    </h1>
                    <p class="text-sm text-text-secondary mt-1">
                        Tiến độ khóa học: ${progressPercent}%
                    </p>
                </div>

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
                            class="px-5 py-2.5 rounded-lg font-semibold text-white bg-brand-700 hover:bg-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                        <i class="fa-solid fa-check mr-2"
                           aria-hidden="true"></i>
                        ${lesson.status eq 'completed' ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành'}
                    </button>
                </form>
            </div>

            <c:if test="${not empty lesson.content}">
                <div class="bg-surface-card p-6 rounded-xl border border-border-default shadow-sm">
                    <h2 class="text-lg font-bold text-text-primary mb-3">
                        Nội dung bài học
                    </h2>
                    <div class="prose max-w-none text-slate-700 text-sm leading-relaxed whitespace-pre-wrap">${lesson.content}</div>
                </div>
            </c:if>
        </div>

        <aside class="lg:col-span-1 space-y-4">
            <div class="bg-surface-card p-5 rounded-xl border border-border-default shadow-sm">
                <h2 class="font-bold text-text-primary mb-4">
                    Điều hướng bài học
                </h2>

                <div class="space-y-3">
                    <c:if test="${not empty prevLesson}">
                        <c:url value="/learn/lesson" var="previousUrl">
                            <c:param name="courseId" value="${course.id}" />
                            <c:param name="lessonId" value="${prevLesson.id}" />
                        </c:url>

                        <a href="${fn:escapeXml(previousUrl)}"
                           class="block w-full py-2.5 px-4 text-center rounded-lg font-semibold text-sm border border-border-default text-text-primary hover:bg-slate-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                            &larr; Bài trước
                        </a>
                    </c:if>

                    <c:if test="${not empty nextLesson}">
                        <c:url value="/learn/lesson" var="nextUrl">
                            <c:param name="courseId" value="${course.id}" />
                            <c:param name="lessonId" value="${nextLesson.id}" />
                        </c:url>

                        <a href="${fn:escapeXml(nextUrl)}"
                           class="block w-full py-2.5 px-4 text-center rounded-lg font-semibold text-sm bg-brand-700 text-white hover:bg-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            Bài kế tiếp &rarr;
                        </a>
                    </c:if>
                </div>
            </div>
        </aside>
    </div>
</main>

<script>
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