<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageLanguage" value="en" scope="request" />
<c:set var="pageTitle" value="Profile - LearnHub" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />
<fmt:setLocale value="en_US" scope="page" />

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
    <div class="flex flex-wrap items-start justify-between gap-4 mb-8">
        <div>
            <p class="text-sm font-semibold uppercase tracking-wide text-brand-700 mb-2">Learning space</p>
            <h1 class="text-3xl font-bold text-text-primary">Your profile</h1>
            <p class="mt-2 text-sm text-text-secondary">
                <c:choose>
                    <c:when test="${not empty overview}">A clear view of your progress and learning streak.</c:when>
                    <c:otherwise>Your LearnHub account details.</c:otherwise>
                </c:choose>
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/account"
           class="inline-flex items-center gap-2 rounded-lg border border-border-default bg-surface-card px-4 py-2.5 text-sm font-semibold text-text-primary hover:border-brand-700 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
            <i class="fa-solid fa-gear" aria-hidden="true"></i> Edit account
        </a>
    </div>

    <div class="grid gap-6 ${empty overview ? 'max-w-xl' : 'lg:grid-cols-3'}">
        <section aria-label="Account identity" class="rounded-xl border border-border-default bg-surface-card p-6 shadow-sm flex flex-col items-center justify-center text-center">
            <div class="flex h-20 w-20 items-center justify-center rounded-full bg-brand-50 text-3xl font-bold uppercase text-brand-700" aria-hidden="true">
                <c:out value="${fn:substring(profileUser.username, 0, 1)}" />
            </div>
            <h2 class="mt-4 text-xl font-bold text-text-primary break-words"><c:out value="${profileUser.username}" /></h2>
            <p class="mt-1 text-sm text-text-secondary break-all"><c:out value="${profileUser.email}" /></p>
            <p class="mt-4 rounded-full bg-brand-50 px-3 py-1 text-xs font-semibold text-brand-700">
                <c:out value="${empty profileUser.roleName ? profileUser.roleCode : profileUser.roleName}" />
            </p>
            <p class="mt-3 text-xs text-text-secondary">
                Member since <fmt:formatDate value="${profileUser.createdAt}" pattern="MMMM yyyy" />
            </p>
        </section>

        <c:if test="${not empty overview}">
            <section aria-labelledby="courses-summary-heading" class="rounded-xl border border-border-default bg-surface-card p-6 shadow-sm">
                <h2 id="courses-summary-heading" class="flex items-center gap-3 text-base font-semibold text-text-primary">
                    <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-brand-50 text-brand-700"><i class="fa-solid fa-book-open" aria-hidden="true"></i></span>
                    Courses
                </h2>
                <p class="mt-7 text-4xl font-bold text-text-primary">${overview.courseCount}</p>
                <p class="mt-1 text-sm text-text-secondary">enrolled courses</p>
                <progress value="${overview.completedLessons}" max="${overview.totalLessons > 0 ? overview.totalLessons : 1}"
                          aria-label="Completed lessons"
                          class="mt-6 w-full h-2 rounded-full overflow-hidden text-brand-700 bg-brand-50 [&::-webkit-progress-bar]:bg-brand-50 [&::-webkit-progress-value]:bg-brand-700 [&::-moz-progress-bar]:bg-brand-700"></progress>
                <div class="mt-3 flex justify-between gap-3 text-sm">
                    <span class="text-text-secondary">Completed lessons</span>
                    <strong class="font-semibold text-text-primary">${overview.completedLessons} / ${overview.totalLessons}</strong>
                </div>
            </section>

            <section aria-labelledby="quizzes-summary-heading" class="rounded-xl border border-border-default bg-surface-card p-6 shadow-sm">
                <h2 id="quizzes-summary-heading" class="flex items-center gap-3 text-base font-semibold text-text-primary">
                    <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-brand-50 text-brand-700"><i class="fa-solid fa-clipboard-check" aria-hidden="true"></i></span>
                    Quizzes
                </h2>
                <p class="mt-7 text-4xl font-bold text-text-primary">${overview.quizSubmissions}</p>
                <p class="mt-1 text-sm text-text-secondary">submitted quizzes</p>
                <div class="mt-6 flex justify-between gap-3 border-t border-border-default pt-3 text-sm">
                    <span class="text-text-secondary">Passed</span><strong class="font-semibold text-text-primary">${overview.passedQuizzes}</strong>
                </div>
                <div class="mt-3 flex justify-between gap-3 border-t border-border-default pt-3 text-sm">
                    <span class="text-text-secondary">Average score</span>
                    <strong class="font-semibold text-text-primary">
                        <c:choose>
                            <c:when test="${not empty overview.averageScore}"><fmt:formatNumber value="${overview.averageScore}" minFractionDigits="1" maxFractionDigits="1" /> / 10</c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </strong>
                </div>
            </section>
        </c:if>
    </div>

    <c:if test="${not empty overview}">
        <section class="mt-6 rounded-xl border border-border-default bg-surface-card p-4 sm:p-6 shadow-sm" aria-labelledby="streak-heading">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <h2 id="streak-heading" class="text-xl font-bold text-text-primary">Learning streak</h2>
                    <p class="mt-1 text-sm text-text-secondary">A day counts when you finish a lesson or submit a quiz.</p>
                </div>
                <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-brand-50 text-brand-700"><i class="fa-solid fa-fire-flame-curved" aria-hidden="true"></i></span>
            </div>
            <div class="mt-6 flex flex-wrap gap-8">
                <div><p class="text-3xl font-bold text-brand-700">${overview.currentStreak} <span class="text-base font-semibold">days</span></p><p class="mt-1 text-xs text-text-secondary">Current streak</p></div>
                <div><p class="text-3xl font-bold text-brand-700">${overview.longestStreak} <span class="text-base font-semibold">days</span></p><p class="mt-1 text-xs text-text-secondary">Longest streak</p></div>
            </div>
            <div class="mt-8" role="img" aria-label="Learning activity by day over the past 52 weeks. Darker green means more completed lessons or submitted quizzes.">
                <div class="flex gap-1">
                    <div class="flex flex-col gap-1 pr-1 text-xs text-text-secondary" aria-hidden="true">
                        <span class="h-4"></span><span class="h-3"></span><span class="h-3 leading-3">M</span>
                        <span class="h-3"></span><span class="h-3 leading-3">W</span>
                        <span class="h-3"></span><span class="h-3 leading-3">F</span><span class="h-3"></span>
                    </div>
                    <c:forEach items="${overview.activityWeeks}" var="week" varStatus="weekLoop">
                        <c:choose>
                            <c:when test="${weekLoop.index < 26}"><c:set var="weekVisibility" value="hidden lg:flex" /></c:when>
                            <c:when test="${weekLoop.index < 40}"><c:set var="weekVisibility" value="hidden md:flex" /></c:when>
                            <c:otherwise><c:set var="weekVisibility" value="flex" /></c:otherwise>
                        </c:choose>
                        <div class="${weekVisibility} flex-col gap-1" aria-hidden="true">
                            <span class="relative h-4 text-xs text-text-secondary whitespace-nowrap"><c:out value="${week.monthLabel}" /></span>
                            <c:forEach items="${week.days}" var="day">
                                <c:choose>
                                    <c:when test="${day.future}"><c:set var="dayColor" value="bg-transparent" /></c:when>
                                    <c:when test="${day.level == 0}"><c:set var="dayColor" value="bg-slate-100" /></c:when>
                                    <c:when test="${day.level == 1}"><c:set var="dayColor" value="bg-brand-50" /></c:when>
                                    <c:when test="${day.level == 2}"><c:set var="dayColor" value="bg-brand-100" /></c:when>
                                    <c:when test="${day.level == 3}"><c:set var="dayColor" value="bg-brand-500" /></c:when>
                                    <c:otherwise><c:set var="dayColor" value="bg-brand-700" /></c:otherwise>
                                </c:choose>
                                <span class="block h-3 w-3 rounded-sm ${dayColor}"
                                      title="${day.date}: ${day.count} learning activities"></span>
                            </c:forEach>
                        </div>
                    </c:forEach>
                </div>
                <div class="mt-4 flex items-center justify-end gap-1 text-xs text-text-secondary" aria-hidden="true">
                    <span class="mr-1">Less</span>
                    <span class="h-3 w-3 rounded-sm bg-slate-100"></span><span class="h-3 w-3 rounded-sm bg-brand-50"></span>
                    <span class="h-3 w-3 rounded-sm bg-brand-100"></span><span class="h-3 w-3 rounded-sm bg-brand-500"></span>
                    <span class="h-3 w-3 rounded-sm bg-brand-700"></span><span class="ml-1">More</span>
                </div>
            </div>
        </section>

        <section class="mt-6 rounded-xl border border-border-default bg-surface-card p-4 sm:p-6 shadow-sm" aria-labelledby="your-courses-heading">
            <h2 id="your-courses-heading" class="text-xl font-bold text-text-primary">Your courses</h2>
            <p class="mt-1 text-sm text-text-secondary">Pick up where you left off.</p>
            <c:choose>
                <c:when test="${empty overview.courses}">
                    <p class="mt-6 rounded-lg bg-brand-50 p-4 text-sm text-text-secondary">
                        No enrolled courses yet. <a href="${pageContext.request.contextPath}/courses" class="font-semibold text-brand-700 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Explore courses</a>.
                    </p>
                </c:when>
                <c:otherwise>
                    <div class="mt-4 divide-y divide-border-default">
                        <c:forEach items="${overview.courses}" var="course">
                            <div class="flex flex-col gap-3 py-4 sm:flex-row sm:items-center">
                                <div class="min-w-0 flex-1">
                                    <p class="font-semibold text-text-primary break-words"><c:out value="${course.courseTitle}" /></p>
                                    <p class="mt-1 text-xs text-text-secondary">${course.completedLessonCount} / ${course.lessonCount} lessons completed</p>
                                </div>
                                <div class="flex items-center gap-3 sm:w-64">
                                    <progress value="${course.progressPercent}" max="100" aria-label="Progress in ${fn:escapeXml(course.courseTitle)}"
                                              class="w-full h-2 rounded-full overflow-hidden text-brand-700 bg-brand-50 [&::-webkit-progress-bar]:bg-brand-50 [&::-webkit-progress-value]:bg-brand-700 [&::-moz-progress-bar]:bg-brand-700"></progress>
                                    <span class="w-10 shrink-0 text-right text-sm font-semibold text-brand-700">${course.progressPercent}%</span>
                                </div>
                                <c:url value="/my-enrollments" var="continueUrl"><c:param name="action" value="continue" /><c:param name="courseId" value="${course.courseId}" /></c:url>
                                <a href="${fn:escapeXml(continueUrl)}" class="self-start rounded-lg px-3 py-2 text-sm font-semibold text-brand-700 hover:bg-brand-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 sm:self-auto">
                                    Continue <span class="sr-only"><c:out value="${course.courseTitle}" /></span><i class="fa-solid fa-arrow-right ml-1" aria-hidden="true"></i>
                                </a>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </c:if>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
