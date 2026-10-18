<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <div class="mb-8 flex flex-wrap items-center justify-between gap-4">
        <div>
            <h1 class="text-2xl font-bold text-text-primary">Lesson Review</h1>
            <p class="mt-2 text-sm text-text-secondary">Select a course to review its draft lessons.</p>
        </div>
        <a href="${pageContext.request.contextPath}/manager/dashboard"
           class="inline-flex items-center gap-2 rounded-lg border border-border-default px-3 py-2 text-sm text-text-secondary hover:bg-surface-card focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
            <i class="fa-solid fa-arrow-left" aria-hidden="true"></i> Manager Dashboard
        </a>
    </div>

    <section aria-label="Courses awaiting lesson review" class="overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-sm">
        <c:choose>
            <c:when test="${empty pendingCourses}">
                <p class="p-6 text-sm text-text-secondary">No draft lessons awaiting review.</p>
            </c:when>
            <c:otherwise>
                <ul class="divide-y divide-border-default">
                    <c:forEach var="item" items="${pendingCourses}">
                        <li class="flex flex-col gap-4 p-4 sm:flex-row sm:items-center sm:justify-between sm:p-6">
                            <div class="min-w-0">
                                <h2 class="font-semibold text-text-primary break-words"><c:out value="${item.courseTitle}" /></h2>
                                <p class="mt-1 text-sm text-text-secondary break-words">
                                    <c:out value="${item.categoryName}" />
                                    <c:if test="${not empty item.expertName}"> · <c:out value="${item.expertName}" /></c:if>
                                </p>
                                <p class="mt-1 text-sm text-status-warning"><c:out value="${item.pendingLessonCount}" /> draft lesson(s) awaiting review</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/admin/lesson-review?courseId=${item.courseId}"
                               class="inline-flex shrink-0 items-center justify-center rounded-lg bg-brand-700 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                Review lessons
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </c:otherwise>
        </c:choose>
    </section>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
