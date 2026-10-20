<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="lessons" />
    </jsp:include>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-7xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">
            <div class="bg-surface-card rounded-xl border border-border-default shadow-sm p-6 sm:p-8">
            <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <a href="${pageContext.request.contextPath}/expert/dashboard"
                               class="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-lg border border-border-default bg-surface-card hover:bg-surface text-text-secondary hover:text-text-primary transition text-sm font-semibold shadow-sm group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                <i class="fa-solid fa-arrow-left text-xs transition-transform group-hover:-translate-x-1"></i>
                                <span>Quay lại</span>
                            </a>
                            <h1 class="text-xl sm:text-2xl font-bold text-text-primary">Lesson List</h1>
                            <a href="${pageContext.request.contextPath}/lessons/manage?action=create&courseId=${course.id}"
                               class="inline-flex items-center justify-center gap-2 px-4 py-2.5 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-lg text-sm transition focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                <i class="fa-solid fa-plus text-xs" aria-hidden="true"></i>
                                <span>Create Lesson</span>
                            </a>
                        </div>
            <c:if test="${not empty course}">
                <p class="mb-6 text-sm font-semibold text-text-primary break-words"><c:out value="${course.title}" /></p>
            </c:if>
            <c:if test="${param.submitted eq 'true'}">
                <p role="status" class="mb-4 text-sm text-status-success">Lesson submitted for Manager review.</p>
            </c:if>
            <c:if test="${param.availability eq 'inactive'}">
                <p role="status" class="mb-4 text-sm text-status-success">Lesson set to inactive.</p>
            </c:if>
            <c:if test="${param.availability eq 'active'}">
                <p role="status" class="mb-4 text-sm text-status-success">Lesson set to active.</p>
            </c:if>
            <form id="lessonListFilters" method="GET" action="${pageContext.request.contextPath}/lessons/manage">
                <input type="hidden" name="courseId" value="${course.id}">
                <input type="hidden" name="courseSearch" value="${fn:escapeXml(courseSearch)}">
                <input type="hidden" name="coursePage" value="${coursePage}">
                <input type="hidden" name="sort" value="${lessonSort}">
                <input type="hidden" name="direction" value="${lessonDirection}">
                <noscript><button type="submit" class="mb-3 rounded-lg border border-border-default px-3 py-2 text-sm">Apply filter</button></noscript>
            </form>
            <div class="overflow-x-auto border border-border-default rounded-xl">
                <table class="w-full text-left text-sm text-text-secondary">
                    <thead class="bg-surface text-slate-700 text-xs font-bold border-b border-border-default">
                        <tr>
                            <th class="px-5 py-4 w-14 text-center">#</th>
                            <c:url var="moduleSortUrl" value="/lessons/manage">
                                <c:param name="courseId" value="${course.id}" />
                                <c:param name="courseSearch" value="${courseSearch}" />
                                <c:param name="coursePage" value="${coursePage}" />
                                <c:param name="lessonStatus" value="${lessonStatus}" />
                                <c:param name="sort" value="module" />
                                <c:param name="direction" value="${lessonSort eq 'module' and lessonDirection eq 'asc' ? 'desc' : 'asc'}" />
                            </c:url>
                            <th scope="col" aria-sort="${lessonSort eq 'module' ? (lessonDirection eq 'asc' ? 'ascending' : 'descending') : 'none'}" class="px-5 py-4 font-bold text-text-primary ">
                                <span class="inline-flex items-center gap-1">Module
                                    <a href="${fn:escapeXml(moduleSortUrl)}" aria-label="Sort module ${lessonSort eq 'module' and lessonDirection eq 'asc' ? 'descending' : 'ascending'}"
                                       title="Sort module ${lessonSort eq 'module' and lessonDirection eq 'asc' ? 'descending' : 'ascending'}"
                                       class="inline-flex items-center justify-center w-8 h-8 rounded-lg ${lessonSort eq 'module' ? 'text-brand-700 bg-brand-50' : 'text-text-secondary hover:bg-surface-card'} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                        <i class="fa-solid ${lessonSort eq 'module' ? (lessonDirection eq 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'}" aria-hidden="true"></i>
                                    </a>
                                </span>
                            </th>
                            <th class="px-5 py-4 font-bold text-text-primary">Lesson Title</th>
                            <th scope="col" class="px-5 py-4 text-center font-bold text-text-primary whitespace-nowrap">
                                <label for="lessonStatus" class="inline-flex items-center gap-2">Status <i class="fa-solid fa-filter ${empty lessonStatus ? 'text-text-secondary' : 'text-brand-700'}" aria-hidden="true"></i></label>
                                <select id="lessonStatus" name="lessonStatus" form="lessonListFilters" aria-label="Filter lesson status" onchange="this.form.requestSubmit()"
                                        class="block mt-1 mx-auto max-w-full rounded-lg border border-border-default bg-surface-card px-2 py-1.5 text-xs font-medium text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                                    <option value="" ${empty lessonStatus ? 'selected' : ''}>All</option>
                                    <option value="draft" ${lessonStatus eq 'draft' ? 'selected' : ''}>Draft</option>
                                    <option value="decline" ${lessonStatus eq 'decline' ? 'selected' : ''}>Decline</option>
                                    <option value="published" ${lessonStatus eq 'published' ? 'selected' : ''}>Published</option>
                                    <option value="archived" ${lessonStatus eq 'archived' ? 'selected' : ''}>Archived</option>
                                </select>
                            </th>
                            <c:url var="durationSortUrl" value="/lessons/manage">
                                <c:param name="courseId" value="${course.id}" />
                                <c:param name="courseSearch" value="${courseSearch}" />
                                <c:param name="coursePage" value="${coursePage}" />
                                <c:param name="lessonStatus" value="${lessonStatus}" />
                                <c:param name="sort" value="duration" />
                                <c:param name="direction" value="${lessonSort eq 'duration' and lessonDirection eq 'asc' ? 'desc' : 'asc'}" />
                            </c:url>
                            <th scope="col" aria-sort="${lessonSort eq 'duration' ? (lessonDirection eq 'asc' ? 'ascending' : 'descending') : 'none'}" class="px-5 py-4 font-bold text-text-primary text-center whitespace-nowrap">
                                <span class="inline-flex items-center gap-1">Duration
                                    <a href="${fn:escapeXml(durationSortUrl)}" aria-label="Sort duration ${lessonSort eq 'duration' and lessonDirection eq 'asc' ? 'descending' : 'ascending'}"
                                       title="Sort duration ${lessonSort eq 'duration' and lessonDirection eq 'asc' ? 'descending' : 'ascending'}"
                                       class="inline-flex items-center justify-center w-8 h-8 rounded-lg ${lessonSort eq 'duration' ? 'text-brand-700 bg-brand-50' : 'text-text-secondary hover:bg-surface-card'} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                        <i class="fa-solid ${lessonSort eq 'duration' ? (lessonDirection eq 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'}" aria-hidden="true"></i>
                                    </a>
                                </span>
                            </th>
                            <th class="px-5 py-4 text-center font-bold text-text-primary w-36">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-border-default">
                        <c:choose>
                            <c:when test="${not empty lessonRows}">
                                <c:set var="globalIndex" value="1" />
                                <c:forEach var="lessonRow" items="${lessonRows}">
                                    <c:set var="module" value="${lessonRow.module}" />
                                    <c:set var="les" value="${lessonRow.lesson}" />
                                    <c:choose>
                                        <c:when test="${not empty les}">
                                                <tr class="hover:bg-surface/80 transition-colors">
                                                    <td class="px-5 py-4 text-center font-bold text-text-secondary text-xs">
                                                        ${globalIndex}
                                                    </td>
                                                    <td class="px-5 py-4 font-semibold text-text-primary text-xs">
                                                        ${module.title}
                                                    </td>
                                                    <td class="px-5 py-4 font-medium text-text-primary">
                                                        <div class="flex items-center space-x-2.5">
                                                            <i class="fa-regular fa-circle-play text-brand-700 text-sm"></i>
                                                            <span>${les.title}</span>
                                                        </div>
                                                    </td>
                                                    <td class="px-5 py-4 text-center whitespace-nowrap">
                                                        <span class="text-xs font-semibold capitalize ${les.publicationStatus eq 'published' ? 'text-status-success' : les.publicationStatus eq 'draft' ? 'text-status-warning' : les.publicationStatus eq 'decline' ? 'text-status-danger' : 'text-text-secondary'}">
                                                            <c:out value="${les.publicationStatus}" />
                                                        </span>
                                                    </td>
                                                    <td class="px-5 py-4 text-center whitespace-nowrap text-xs">
                                                        <c:choose>
                                                            <c:when test="${not empty les.durationMinutes}">${les.durationMinutes} min</c:when>
                                                            <c:otherwise>Not set</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="px-5 py-4 text-center space-x-3 text-xs font-semibold whitespace-nowrap">
                                                        <a href="${pageContext.request.contextPath}/lessons/manage?action=edit&id=${les.id}&courseId=${course.id}"
                                                           class="inline-flex rounded-lg px-3 py-2 text-brand-700 hover:bg-brand-50 hover:text-brand-800 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Edit</a>
                                                       <c:if test="${les.publicationStatus eq 'published' || les.publicationStatus eq 'archived'}">
                                                       <form action="${pageContext.request.contextPath}/lessons/manage"
                                                             method="post" class="inline-block">
                                                           <input type="hidden" name="action" value="${les.publicationStatus eq 'archived' ? 'activate' : 'deactivate'}">
                                                           <input type="hidden" name="id" value="${les.id}">
                                                           <input type="hidden" name="courseId" value="${course.id}">
                                                           <input type="hidden" name="csrfToken" value="${sessionScope.lessonActionToken}">
                                                           <input type="hidden" name="updatedAt" value="${les.updatedAt}">
                                                           <button type="submit"
                                                                   class="inline-flex items-center gap-2 rounded-lg px-3 py-2 ${les.publicationStatus eq 'archived' ? 'text-brand-700 hover:bg-brand-50 focus-visible:ring-brand-700' : 'text-status-danger hover:bg-rose-50 focus-visible:ring-status-danger'} focus-visible:outline-none focus-visible:ring-2"
                                                                   data-confirm="${les.publicationStatus eq 'archived' ? 'Set this lesson active again?' : 'Set this lesson inactive? The lesson and learning progress will be preserved.'}"
                                                                   data-confirm-title="${les.publicationStatus eq 'archived' ? 'Active Lesson' : 'Inactive Lesson'}"
                                                                   data-confirm-type="${les.publicationStatus eq 'archived' ? 'success' : 'danger'}"
                                                                   data-confirm-cancel="Cancel"
                                                                   data-confirm-btn="${les.publicationStatus eq 'archived' ? 'Active' : 'Inactive'}">
                                                               <i class="fa-solid ${les.publicationStatus eq 'archived' ? 'fa-toggle-on' : 'fa-toggle-off'}" aria-hidden="true"></i>
                                                               ${les.publicationStatus eq 'archived' ? 'Active' : 'Inactive'}
                                                           </button>
                                                       </form>
                                                       </c:if>
                                                    </td>
                                                </tr>
                                            <c:set var="globalIndex" value="${globalIndex + 1}" />
                                        </c:when>
                                        <c:otherwise>
                                            <tr class="bg-surface/40">
                                                <td class="px-5 py-3.5 text-center text-slate-300 text-xs">-</td>
                                                <td class="px-5 py-3.5 font-semibold text-text-secondary text-xs">${module.title}</td>
                                                <td colspan="4" class="px-5 py-3.5 text-xs text-text-secondary italic">
                                                    Chưa có bài học nào trong chương này
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="px-6 py-12 text-center text-text-secondary text-sm">
                                        <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300"></i>
                                        <c:choose>
                                            <c:when test="${not empty lessonStatus}">No lessons match the selected status.</c:when>
                                            <c:otherwise>Khóa học này hiện chưa có module hoặc bài giảng nào.</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>
</div>

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
