<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="currentSection" value="${empty param.activeSection ? 'lessons' : param.activeSection}" />
<c:choose>
    <c:when test="${currentSection eq 'questions'}">
        <c:set var="sectionManageUrl" value="/questions/manage" />
    </c:when>
    <c:when test="${currentSection eq 'quiz' or currentSection eq 'quizzes'}">
        <c:set var="sectionManageUrl" value="/quiz/manage" />
    </c:when>
    <c:otherwise>
        <c:set var="sectionManageUrl" value="/lessons/manage" />
    </c:otherwise>
</c:choose>
<c:set var="selectedCourseId" value="${not empty course.id ? course.id : (not empty courseId ? courseId : param.courseId)}" />

<section aria-labelledby="assignedCoursesHeading" class="management-sidebar-course-list mt-5 border-t border-border-default pt-4">
    <h2 id="assignedCoursesHeading" class="mb-3 px-2 text-sm font-semibold text-text-primary">Assigned Courses</h2>
    <form method="GET" action="${pageContext.request.contextPath}${sectionManageUrl}" role="search" aria-label="Search assigned courses" class="mb-3 flex items-center gap-2 px-1">
        <input type="hidden" name="courseId" value="${selectedCourseId}">
        <input type="hidden" name="coursePage" value="1">
        <c:choose>
            <c:when test="${currentSection eq 'lessons'}">
                <input type="hidden" name="lessonModuleId" value="${lessonModuleId}">
                <input type="hidden" name="lessonStatus" value="${lessonStatus}">
                <input type="hidden" name="sort" value="${lessonSort}">
                <input type="hidden" name="direction" value="${lessonDirection}">
            </c:when>
            <c:when test="${currentSection eq 'questions'}">
                <input type="hidden" name="moduleId" value="${moduleId}">
                <input type="hidden" name="type" value="${type}">
                <input type="hidden" name="status" value="${status}">
                <input type="hidden" name="keyword" value="${fn:escapeXml(keyword)}">
            </c:when>
            <c:when test="${currentSection eq 'quiz' or currentSection eq 'quizzes'}">
                <input type="hidden" name="moduleId" value="${moduleId}">
                <input type="hidden" name="status" value="${status}">
                <input type="hidden" name="keyword" value="${fn:escapeXml(keyword)}">
            </c:when>
        </c:choose>
        <label for="assignedCourseSearch" class="sr-only">Search courses</label>
        <input id="assignedCourseSearch" type="search" name="courseSearch" value="${fn:escapeXml(courseSearch)}" placeholder="Search courses..."
               class="min-w-0 flex-1 rounded-lg border border-border-default bg-surface-card px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
        <button type="submit" aria-label="Search courses" title="Search courses"
                class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-brand-700 text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
            <i class="fa-solid fa-magnifying-glass" aria-hidden="true"></i>
        </button>
    </form>
    <div class="flex items-center justify-between gap-2 px-2 mb-2 text-xs text-text-secondary">
        <span role="status">${courseTotal} ${courseTotal eq 1 ? 'course' : 'courses'}</span>
        <c:if test="${not empty courseSearch}">
            <c:url var="clearCourseSearchUrl" value="${sectionManageUrl}">
                <c:param name="courseId" value="${selectedCourseId}" />
                <c:choose>
                    <c:when test="${currentSection eq 'lessons'}">
                        <c:param name="lessonModuleId" value="${lessonModuleId}" />
                        <c:param name="sort" value="${lessonSort}" />
                        <c:param name="direction" value="${lessonDirection}" />
                        <c:param name="lessonStatus" value="${lessonStatus}" />
                    </c:when>
                    <c:when test="${currentSection eq 'questions'}">
                        <c:param name="moduleId" value="${moduleId}" />
                        <c:param name="type" value="${type}" />
                        <c:param name="status" value="${status}" />
                        <c:param name="keyword" value="${keyword}" />
                    </c:when>
                    <c:when test="${currentSection eq 'quiz' or currentSection eq 'quizzes'}">
                        <c:param name="moduleId" value="${moduleId}" />
                        <c:param name="status" value="${status}" />
                        <c:param name="keyword" value="${keyword}" />
                    </c:when>
                </c:choose>
            </c:url>
            <a href="${fn:escapeXml(clearCourseSearchUrl)}" class="text-brand-700 underline rounded focus-visible:ring-2 focus-visible:ring-brand-700">Clear</a>
        </c:if>
    </div>
    <c:choose>
        <c:when test="${not empty assignedCourses}">
            <div role="group" aria-label="Assigned courses" class="hidden max-h-96 flex-col gap-1 overflow-y-auto p-1 lg:flex">
                <c:if test="${currentSection eq 'questions' or currentSection eq 'quiz' or currentSection eq 'quizzes'}">
                    <c:url var="allCoursesUrl" value="${sectionManageUrl}">
                        <c:param name="courseSearch" value="${courseSearch}" />
                        <c:param name="coursePage" value="${coursePage}" />
                        <c:choose>
                            <c:when test="${currentSection eq 'questions'}">
                                <c:param name="type" value="${type}" />
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:when>
                            <c:otherwise>
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:otherwise>
                        </c:choose>
                    </c:url>
                    <a href="${fn:escapeXml(allCoursesUrl)}"
                       aria-current="${empty selectedCourseId ? 'page' : 'false'}"
                       class="flex items-start gap-2 rounded-lg px-3 py-2.5 text-sm break-words ${empty selectedCourseId ? 'border border-brand-100 bg-brand-50 text-brand-900 font-semibold' : 'border border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                        <i class="fa-solid fa-layer-group shrink-0 mt-1" aria-hidden="true"></i>
                        <span class="min-w-0">All Courses</span>
                    </a>
                </c:if>
                <c:set var="currentCourseListed" value="${false}" />
                <c:forEach var="assignedCourse" items="${assignedCourses}">
                    <c:if test="${assignedCourse.id eq selectedCourseId}"><c:set var="currentCourseListed" value="${true}" /></c:if>
                    <c:url var="assignedCourseUrl" value="${sectionManageUrl}">
                        <c:param name="courseId" value="${assignedCourse.id}" />
                        <c:param name="courseSearch" value="${courseSearch}" />
                        <c:param name="coursePage" value="${coursePage}" />
                        <c:choose>
                            <c:when test="${currentSection eq 'lessons'}">
                                <c:param name="sort" value="${lessonSort}" />
                                <c:param name="direction" value="${lessonDirection}" />
                                <c:param name="lessonStatus" value="${lessonStatus}" />
                            </c:when>
                            <c:when test="${currentSection eq 'questions'}">
                                <c:param name="type" value="${type}" />
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:when>
                            <c:when test="${currentSection eq 'quiz' or currentSection eq 'quizzes'}">
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:when>
                        </c:choose>
                    </c:url>
                    <a href="${fn:escapeXml(assignedCourseUrl)}"
                       aria-current="${assignedCourse.id eq selectedCourseId ? 'page' : 'false'}"
                       class="flex items-start gap-2 rounded-lg px-3 py-3 text-sm break-words ${assignedCourse.id eq selectedCourseId ? 'border border-brand-100 bg-brand-50 text-brand-900 font-semibold' : 'border border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                        <i class="fa-solid fa-book shrink-0 mt-1" aria-hidden="true"></i>
                        <span class="min-w-0"><c:out value="${assignedCourse.title}" /></span>
                    </a>
                </c:forEach>
            </div>
            <form method="GET" action="${pageContext.request.contextPath}${sectionManageUrl}" class="flex items-center gap-2 lg:hidden">
                <input type="hidden" name="courseSearch" value="${fn:escapeXml(courseSearch)}">
                <input type="hidden" name="coursePage" value="${coursePage}">
                <c:choose>
                    <c:when test="${currentSection eq 'lessons'}">
                        <input type="hidden" name="sort" value="${lessonSort}">
                        <input type="hidden" name="direction" value="${lessonDirection}">
                        <input type="hidden" name="lessonStatus" value="${lessonStatus}">
                    </c:when>
                    <c:when test="${currentSection eq 'questions'}">
                        <input type="hidden" name="type" value="${type}">
                        <input type="hidden" name="status" value="${status}">
                        <input type="hidden" name="keyword" value="${fn:escapeXml(keyword)}">
                    </c:when>
                    <c:when test="${currentSection eq 'quiz' or currentSection eq 'quizzes'}">
                        <input type="hidden" name="status" value="${status}">
                        <input type="hidden" name="keyword" value="${fn:escapeXml(keyword)}">
                    </c:when>
                </c:choose>
                <label for="assignedCourseSelect" class="sr-only">Assigned course</label>
                <select id="assignedCourseSelect" name="courseId" ${currentSection eq 'lessons' ? 'required' : ''} onchange="this.form.requestSubmit()"
                        class="min-w-0 flex-1 rounded-lg border border-border-default bg-surface-card px-3 py-2.5 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                    <c:choose>
                        <c:when test="${currentSection eq 'lessons'}">
                            <option value="" ${not currentCourseListed ? 'selected' : ''} disabled>Select course</option>
                        </c:when>
                        <c:otherwise>
                            <option value="" ${empty selectedCourseId ? 'selected' : ''}>-- All Courses --</option>
                        </c:otherwise>
                    </c:choose>
                    <c:forEach var="assignedCourse" items="${assignedCourses}">
                        <option value="${assignedCourse.id}" ${assignedCourse.id eq selectedCourseId ? 'selected' : ''}><c:out value="${assignedCourse.title}" /></option>
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
        <div role="group" aria-label="Assigned course pages" class="mt-3 flex items-center justify-between gap-2 px-1 text-xs text-text-secondary">
            <c:choose>
                <c:when test="${coursePage gt 1}">
                    <c:url var="previousCoursePageUrl" value="${sectionManageUrl}">
                        <c:param name="courseId" value="${selectedCourseId}" />
                        <c:param name="courseSearch" value="${courseSearch}" />
                        <c:param name="coursePage" value="${coursePage - 1}" />
                        <c:choose>
                            <c:when test="${currentSection eq 'lessons'}">
                                <c:param name="lessonModuleId" value="${lessonModuleId}" />
                                <c:param name="sort" value="${lessonSort}" />
                                <c:param name="direction" value="${lessonDirection}" />
                                <c:param name="lessonStatus" value="${lessonStatus}" />
                            </c:when>
                            <c:when test="${currentSection eq 'questions'}">
                                <c:param name="moduleId" value="${moduleId}" />
                                <c:param name="type" value="${type}" />
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:when>
                            <c:when test="${currentSection eq 'quiz' or currentSection eq 'quizzes'}">
                                <c:param name="moduleId" value="${moduleId}" />
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:when>
                        </c:choose>
                    </c:url>
                    <a href="${fn:escapeXml(previousCoursePageUrl)}" aria-label="Previous course page" title="Previous course page" class="flex items-center justify-center w-9 h-9 rounded-lg border border-border-default hover:bg-surface-card focus-visible:ring-2 focus-visible:ring-brand-700"><i class="fa-solid fa-chevron-left" aria-hidden="true"></i></a>
                </c:when>
                <c:otherwise><span aria-disabled="true" class="flex items-center justify-center w-9 h-9 text-text-secondary opacity-50"><i class="fa-solid fa-chevron-left" aria-hidden="true"></i></span></c:otherwise>
            </c:choose>
            <span>Page ${coursePage} / ${courseTotalPages}</span>
            <c:choose>
                <c:when test="${coursePage lt courseTotalPages}">
                    <c:url var="nextCoursePageUrl" value="${sectionManageUrl}">
                        <c:param name="courseId" value="${selectedCourseId}" />
                        <c:param name="courseSearch" value="${courseSearch}" />
                        <c:param name="coursePage" value="${coursePage + 1}" />
                        <c:choose>
                            <c:when test="${currentSection eq 'lessons'}">
                                <c:param name="lessonModuleId" value="${lessonModuleId}" />
                                <c:param name="sort" value="${lessonSort}" />
                                <c:param name="direction" value="${lessonDirection}" />
                                <c:param name="lessonStatus" value="${lessonStatus}" />
                            </c:when>
                            <c:when test="${currentSection eq 'questions'}">
                                <c:param name="moduleId" value="${moduleId}" />
                                <c:param name="type" value="${type}" />
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:when>
                            <c:when test="${currentSection eq 'quiz' or currentSection eq 'quizzes'}">
                                <c:param name="moduleId" value="${moduleId}" />
                                <c:param name="status" value="${status}" />
                                <c:param name="keyword" value="${keyword}" />
                            </c:when>
                        </c:choose>
                    </c:url>
                    <a href="${fn:escapeXml(nextCoursePageUrl)}" aria-label="Next course page" title="Next course page" class="flex items-center justify-center w-9 h-9 rounded-lg border border-border-default hover:bg-surface-card focus-visible:ring-2 focus-visible:ring-brand-700"><i class="fa-solid fa-chevron-right" aria-hidden="true"></i></a>
                </c:when>
                <c:otherwise><span aria-disabled="true" class="flex items-center justify-center w-9 h-9 text-text-secondary opacity-50"><i class="fa-solid fa-chevron-right" aria-hidden="true"></i></span></c:otherwise>
            </c:choose>
        </div>
    </c:if>
</section>
