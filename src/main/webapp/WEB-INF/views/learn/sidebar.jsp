<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Sidebar dùng chung cho trang bài học (learn/viewer.jsp) và trang quiz (quiz/info.jsp).
     Cần các attribute: course, registration, lessonStatuses, completedLessons, totalLessons, progressPercent.
     Tuỳ trang: "lesson" (đang xem bài học) hoặc "quiz" (đang xem quiz). --%>
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
                ${(module.id eq lesson.moduleId) or (module.id eq quiz.moduleId) ? 'open' : ''}>

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
                    <c:forEach items="${module.quizzes}" var="qz">
                        <c:set var="isCurrentQuiz" value="${qz.id eq quiz.id}" />

                        <c:url value="/quiz" var="quizUrl">
                            <c:param name="quizId" value="${qz.id}" />
                            <c:param name="courseId" value="${course.id}" />
                        </c:url>

                        <li>
                            <a href="${fn:escapeXml(quizUrl)}"
                               aria-current="${isCurrentQuiz ? 'page' : 'false'}"
                               class="flex items-start gap-3 rounded-lg p-3 text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${isCurrentQuiz ? 'bg-brand-50 text-brand-900 font-semibold' : 'text-text-primary hover:bg-surface'}">

                                <i class="fa-solid fa-list-check text-brand-700 mt-1 shrink-0"
                                   aria-hidden="true"></i>

                                <span class="min-w-0">
                                    <span class="block break-words">
                                        <c:out value="${qz.title}" />
                                    </span>
                                    <span class="block text-xs text-text-secondary mt-1">
                                        Quiz · ${qz.questionCount} câu hỏi
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

<style>
    .viewer-module summary::-webkit-details-marker {
        display: none;
    }

    progress {
        accent-color: currentColor;
    }
</style>
