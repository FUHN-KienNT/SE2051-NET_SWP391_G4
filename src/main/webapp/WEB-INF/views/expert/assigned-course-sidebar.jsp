<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<section aria-labelledby="assignedCoursesHeading" class="mt-6 border-t border-border-default pt-4">
    <h2 id="assignedCoursesHeading" class="px-2 mb-3 text-sm font-bold text-text-primary">Assigned Courses</h2>
    <form method="GET" action="${pageContext.request.contextPath}/lessons/manage" role="search" aria-label="Search assigned courses" class="flex gap-2 mb-3">
        <input type="hidden" name="sort" value="${lessonSort}">
        <input type="hidden" name="direction" value="${lessonDirection}">
        <input type="hidden" name="lessonStatus" value="${lessonStatus}">
        <input type="hidden" name="courseId" value="${course.id}">
        <label for="courseSearch" class="sr-only">Search assigned courses</label>
        <input id="courseSearch" name="courseSearch" type="search" value="${fn:escapeXml(courseSearch)}"
               placeholder="Search courses..."
               class="min-w-0 flex-1 rounded-lg border border-border-default bg-surface-card px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
        <button type="submit" aria-label="Search courses" title="Search courses"
                class="shrink-0 flex items-center justify-center w-10 h-10 rounded-lg bg-brand-700 text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
            <i class="fa-solid fa-magnifying-glass" aria-hidden="true"></i>
        </button>
    </form>
    <div class="flex items-center justify-between gap-2 px-2 mb-2 text-xs text-text-secondary">
        <span role="status">${courseTotal} ${courseTotal eq 1 ? 'course' : 'courses'}</span>
        <c:if test="${not empty courseSearch}">
            <c:url var="clearCourseSearchUrl" value="/lessons/manage"><c:param name="sort" value="${lessonSort}" /><c:param name="direction" value="${lessonDirection}" /><c:param name="lessonStatus" value="${lessonStatus}" /><c:param name="courseId" value="${course.id}" /></c:url>
            <a href="${fn:escapeXml(clearCourseSearchUrl)}" class="text-brand-700 underline rounded focus-visible:ring-2 focus-visible:ring-brand-700">Clear</a>
        </c:if>
    </div>
    <c:choose>
        <c:when test="${not empty assignedCourses}">
            <nav aria-label="Assigned courses" class="hidden lg:flex flex-col gap-1 max-h-96 overflow-y-auto p-1">
                <c:set var="currentCourseListed" value="${false}" />
                <c:forEach var="assignedCourse" items="${assignedCourses}">
                    <c:if test="${assignedCourse.id eq course.id}"><c:set var="currentCourseListed" value="${true}" /></c:if>
                    <c:url var="assignedCourseUrl" value="/lessons/manage"><c:param name="sort" value="${lessonSort}" /><c:param name="direction" value="${lessonDirection}" /><c:param name="lessonStatus" value="${lessonStatus}" />
                        <c:param name="courseId" value="${assignedCourse.id}" />
                        <c:param name="courseSearch" value="${courseSearch}" />
                        <c:param name="coursePage" value="${coursePage}" />
                    </c:url>
                    <a href="${fn:escapeXml(assignedCourseUrl)}"
                       aria-current="${assignedCourse.id eq course.id ? 'page' : 'false'}"
                       class="flex items-start gap-2 rounded-lg px-3 py-3 text-sm break-words ${assignedCourse.id eq course.id ? 'bg-brand-50 text-brand-900 font-semibold border-l-4 border-brand-700' : 'text-text-secondary hover:bg-surface-card hover:text-text-primary border-l-4 border-transparent'} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                        <i class="fa-solid fa-book shrink-0 mt-1" aria-hidden="true"></i>
                        <span class="min-w-0"><c:out value="${assignedCourse.title}" /></span>
                    </a>
                </c:forEach>
            </nav>
            <form method="GET" action="${pageContext.request.contextPath}/lessons/manage" class="flex items-center gap-2 lg:hidden">
        <input type="hidden" name="sort" value="${lessonSort}">
        <input type="hidden" name="direction" value="${lessonDirection}">
        <input type="hidden" name="lessonStatus" value="${lessonStatus}">
                <input type="hidden" name="courseSearch" value="${fn:escapeXml(courseSearch)}">
                <input type="hidden" name="coursePage" value="${coursePage}">
                <label for="assignedCourseSelect" class="sr-only">Assigned course</label>
                <select id="assignedCourseSelect" name="courseId" required onchange="this.form.requestSubmit()"
                        class="min-w-0 flex-1 rounded-lg border border-border-default bg-surface-card px-3 py-2.5 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                    <option value="" ${not currentCourseListed ? 'selected' : ''} disabled>Select course</option>
                    <c:forEach var="assignedCourse" items="${assignedCourses}">
                        <option value="${assignedCourse.id}" ${assignedCourse.id eq course.id ? 'selected' : ''}><c:out value="${assignedCourse.title}" /></option>
                    </c:forEach>
                </select>
                <button type="submit" aria-label="Open course" title="Open course"
                        class="shrink-0 flex items-center justify-center w-10 h-10 rounded-lg bg-brand-700 text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-arrow-right" aria-hidden="true"></i>
                </button>
            </form>
        </c:when>
        <c:otherwise>
            <p class="px-2 text-sm text-text-secondary">${empty courseSearch ? 'No assigned courses.' : 'No matching courses.'}</p>
        </c:otherwise>
    </c:choose>
    <c:if test="${courseTotalPages gt 1}">
        <nav aria-label="Assigned course pages" class="mt-3 flex items-center justify-between gap-2 px-1 text-xs text-text-secondary">
            <c:choose>
                <c:when test="${coursePage gt 1}">
                    <c:url var="previousCoursePageUrl" value="/lessons/manage"><c:param name="sort" value="${lessonSort}" /><c:param name="direction" value="${lessonDirection}" /><c:param name="lessonStatus" value="${lessonStatus}" />
                        <c:param name="courseId" value="${course.id}" /><c:param name="courseSearch" value="${courseSearch}" /><c:param name="coursePage" value="${coursePage - 1}" />
                    </c:url>
                    <a href="${fn:escapeXml(previousCoursePageUrl)}" aria-label="Previous course page" title="Previous course page" class="flex items-center justify-center w-9 h-9 rounded-lg border border-border-default hover:bg-surface-card focus-visible:ring-2 focus-visible:ring-brand-700"><i class="fa-solid fa-chevron-left" aria-hidden="true"></i></a>
                </c:when>
                <c:otherwise><span aria-disabled="true" class="flex items-center justify-center w-9 h-9 text-text-secondary opacity-50"><i class="fa-solid fa-chevron-left" aria-hidden="true"></i></span></c:otherwise>
            </c:choose>
            <span>Page ${coursePage} / ${courseTotalPages}</span>
            <c:choose>
                <c:when test="${coursePage lt courseTotalPages}">
                    <c:url var="nextCoursePageUrl" value="/lessons/manage"><c:param name="sort" value="${lessonSort}" /><c:param name="direction" value="${lessonDirection}" /><c:param name="lessonStatus" value="${lessonStatus}" />
                        <c:param name="courseId" value="${course.id}" /><c:param name="courseSearch" value="${courseSearch}" /><c:param name="coursePage" value="${coursePage + 1}" />
                    </c:url>
                    <a href="${fn:escapeXml(nextCoursePageUrl)}" aria-label="Next course page" title="Next course page" class="flex items-center justify-center w-9 h-9 rounded-lg border border-border-default hover:bg-surface-card focus-visible:ring-2 focus-visible:ring-brand-700"><i class="fa-solid fa-chevron-right" aria-hidden="true"></i></a>
                </c:when>
                <c:otherwise><span aria-disabled="true" class="flex items-center justify-center w-9 h-9 text-text-secondary opacity-50"><i class="fa-solid fa-chevron-right" aria-hidden="true"></i></span></c:otherwise>
            </c:choose>
        </nav>
    </c:if>
</section>
