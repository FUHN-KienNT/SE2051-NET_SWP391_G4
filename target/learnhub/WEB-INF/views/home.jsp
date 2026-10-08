<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="LearnHub | Learn at your pace" scope="request" />
<c:set var="pageLanguage" value="en" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main lang="en" class="flex-grow bg-surface">
    <c:choose>
        <c:when test="${empty sessionScope.currentUser}">
            <section aria-labelledby="home-heading" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16 lg:py-20">
                <div class="grid lg:grid-cols-2 gap-10 lg:gap-16 items-center">
                    <div>
                        <p class="text-sm font-semibold uppercase tracking-wide text-brand-700 mb-4">Learn your way</p>
                        <h1 id="home-heading" class="max-w-2xl text-4xl sm:text-5xl lg:text-6xl font-bold leading-tight tracking-tight text-text-primary">Start your learning journey with <span class="text-brand-700">LearnHub.</span></h1>
                        <p class="mt-6 max-w-xl text-base sm:text-lg leading-relaxed text-text-secondary">Explore practical courses, learn one lesson at a time, and build skills at your own pace.</p>
                        <div class="mt-8 flex flex-wrap items-center gap-5">
                            <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center justify-center gap-2 rounded-lg bg-brand-700 px-6 py-3 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Explore courses <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
                            <a href="${pageContext.request.contextPath}/auth/register" class="rounded-lg text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Create a free account</a>
                        </div>
                    </div>
                    <div aria-hidden="true" class="relative overflow-hidden rounded-3xl bg-brand-100 p-6 sm:p-10 min-h-64 sm:min-h-80 flex items-center justify-center">
                        <div class="absolute -top-16 -right-16 h-48 w-48 rounded-full bg-brand-50"></div>
                        <div class="absolute -bottom-20 -left-12 h-56 w-56 rounded-full bg-brand-50"></div>
                        <div class="relative w-full max-w-sm rounded-2xl bg-surface-inverse p-5 sm:p-6 shadow-xl -rotate-2">
                            <div class="flex gap-2 mb-6"><span class="h-2 w-2 rounded-full bg-brand-500"></span><span class="h-2 w-2 rounded-full bg-brand-500"></span><span class="h-2 w-2 rounded-full bg-brand-500"></span></div>
                            <i class="fa-solid fa-laptop-code text-4xl text-brand-100"></i>
                            <p class="mt-5 text-xl font-bold text-white">Learn by doing</p>
                            <p class="mt-2 text-sm leading-relaxed text-slate-300">Practical lessons for skills you can use.</p>
                            <div class="mt-6 flex items-center gap-3"><span class="h-2 w-20 rounded-full bg-brand-500"></span><span class="h-2 w-12 rounded-full bg-brand-900"></span><span class="h-2 w-16 rounded-full bg-brand-900"></span></div>
                        </div>
                    </div>
                </div>
            </section>
        </c:when>
        <c:otherwise>
            <section aria-labelledby="home-heading" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 sm:pt-16 pb-12 sm:pb-16">
                <div class="mb-8 sm:mb-10">
                    <p class="text-sm font-semibold uppercase tracking-wide text-brand-700 mb-3">Your learning</p>
                    <h1 id="home-heading" class="text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-text-primary break-words">Welcome back, <c:out value="${sessionScope.currentUser.username}"/>!</h1>
                    <p class="mt-3 text-base text-text-secondary">Pick up where you left off and keep moving forward.</p>
                </div>
                <c:choose>
                    <c:when test="${not empty continueLearning}">
                        <section aria-labelledby="continue-heading" class="grid lg:grid-cols-2 gap-8 lg:gap-12 items-center rounded-3xl bg-surface-inverse p-6 sm:p-8 lg:p-10">
                            <div class="min-w-0">
                                <p class="text-sm font-semibold text-brand-100 mb-2">Continue learning</p>
                                <h2 id="continue-heading" class="text-2xl sm:text-3xl font-bold leading-snug text-white break-words"><c:out value="${continueLearning.courseTitle}"/></h2>
                                <p class="mt-3 text-sm text-slate-300"><c:out value="${continueLearning.categoryName}" default="Course"/> <span aria-hidden="true">·</span> ${continueLearning.moduleCount} modules <span aria-hidden="true">·</span> ${continueLearning.lessonCount} lessons</p>
                                <div class="mt-6 rounded-xl bg-white/10 p-4">
                                    <p class="text-xs font-semibold uppercase tracking-wide text-brand-100">Your next lesson</p>
                                    <p class="mt-2 font-semibold text-white break-words"><c:out value="${continueLearning.lessonTitle}"/></p>
                                    <p class="mt-1 text-sm text-slate-300 break-words"><c:out value="${continueLearning.moduleTitle}"/></p>
                                </div>
                                <div class="mt-6">
                                    <div class="flex items-center justify-between gap-3 text-sm text-slate-200 mb-2"><span>Course progress</span><span class="font-semibold">${continueLearning.progressPercent}%</span></div>
                                    <div role="progressbar" aria-label="Course progress" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${continueLearning.progressPercent}" class="h-2 overflow-hidden rounded-full bg-white/20"><span class="block h-full rounded-full bg-brand-500" style="width: ${continueLearning.progressPercent}%"></span></div>
                                </div>
                                <a href="${pageContext.request.contextPath}/learn/lesson?courseId=${continueLearning.courseId}&amp;lessonId=${continueLearning.lessonId}" class="mt-7 inline-flex items-center justify-center gap-2 rounded-lg bg-surface-card px-6 py-3 text-sm font-semibold text-brand-900 hover:bg-brand-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 focus-visible:ring-offset-surface-inverse">Continue lesson <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
                            </div>
                            <div class="min-w-0 overflow-hidden rounded-2xl bg-surface-card shadow-sm">
                                <div class="relative h-48 sm:h-56 bg-brand-100 flex items-center justify-center overflow-hidden">
                                    <i class="fa-solid fa-laptop-code text-5xl text-brand-700" aria-hidden="true"></i>
                                    <c:if test="${not empty continueLearning.thumbnailUrl}"><img src="<c:out value='${continueLearning.thumbnailUrl}'/>" alt="" loading="lazy" onerror="this.hidden=true" class="absolute inset-0 w-full h-full object-cover"></c:if>
                                </div>
                                <div class="p-5 sm:p-6">
                                    <p class="text-xs font-semibold uppercase tracking-wide text-brand-700"><c:out value="${continueLearning.categoryName}" default="Course"/></p>
                                    <h3 class="mt-2 text-xl font-bold leading-snug text-text-primary break-words"><c:out value="${continueLearning.courseTitle}"/></h3>
                                    <p class="mt-3 text-sm text-text-secondary">${continueLearning.moduleCount} modules <span aria-hidden="true">·</span> ${continueLearning.lessonCount} lessons</p>
                                    <a href="${pageContext.request.contextPath}/courses?action=detail&amp;id=${continueLearning.courseId}" class="mt-5 inline-flex items-center gap-2 rounded-lg text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">View course <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
                                </div>
                            </div>
                        </section>
                    </c:when>
                    <c:otherwise>
                        <section aria-labelledby="start-heading" class="rounded-3xl bg-surface-inverse p-6 sm:p-8 lg:p-10 text-white">
                            <p class="text-sm font-semibold text-brand-100 mb-2">Your learning starts here</p>
                            <h2 id="start-heading" class="text-2xl sm:text-3xl font-bold">Ready for your next course?</h2>
                            <p class="mt-3 max-w-xl text-sm sm:text-base leading-relaxed text-slate-300">Explore the catalog and choose a course to begin your next lesson.</p>
                            <a href="${pageContext.request.contextPath}/courses" class="mt-6 inline-flex items-center justify-center gap-2 rounded-lg bg-surface-card px-6 py-3 text-sm font-semibold text-brand-900 hover:bg-brand-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 focus-visible:ring-offset-surface-inverse">Explore courses <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
                        </section>
                    </c:otherwise>
                </c:choose>
            </section>
        </c:otherwise>
    </c:choose>

    <section aria-labelledby="categories-heading" class="bg-surface-card border-y border-border-default py-14 sm:py-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-7">
                <div>
                    <p class="text-sm font-semibold text-brand-700 mb-2">Explore by topic</p>
                    <h2 id="categories-heading" class="text-2xl sm:text-3xl font-bold text-text-primary">Choose what to learn next</h2>
                </div>
                <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center gap-2 text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 rounded-lg">All courses <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
            </div>
            <c:choose>
                <c:when test="${not empty categories}">
                    <div class="flex flex-wrap gap-3">
                        <c:forEach var="cat" items="${categories}">
                            <a href="${pageContext.request.contextPath}/courses?categoryId=${cat.id}" class="inline-flex items-center rounded-lg border border-border-default bg-surface-card px-4 py-3 text-sm font-semibold text-text-primary hover:border-brand-700 hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                <c:out value="${cat.name}"/>
                            </a>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise><p class="text-text-secondary">Topics will appear here as courses become available.</p></c:otherwise>
            </c:choose>
        </div>
    </section>

    <section aria-labelledby="featured-heading" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-8">
                <div>
                    <p class="text-sm font-semibold text-brand-700 mb-2"><c:choose><c:when test="${empty sessionScope.currentUser}">Start exploring</c:when><c:otherwise>Discover more</c:otherwise></c:choose></p>
                    <h2 id="featured-heading" class="text-2xl sm:text-3xl font-bold text-text-primary"><c:choose><c:when test="${empty sessionScope.currentUser}">Featured courses</c:when><c:otherwise>Explore more courses</c:otherwise></c:choose></h2>
                    <p class="mt-2 text-text-secondary">Find a course that fits your interests and your schedule.</p>
                </div>
                <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center gap-2 rounded-lg text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">View all courses <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
            </div>
            <c:choose>
                <c:when test="${not empty featuredCourses}">
                    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                        <c:forEach var="course" items="${featuredCourses}">
                            <a href="${pageContext.request.contextPath}/courses?action=detail&amp;id=${course.id}" class="group flex flex-col overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-sm hover:shadow-md hover:border-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                <div class="relative h-44 bg-brand-50 flex items-center justify-center overflow-hidden">
                                    <i class="fa-solid fa-book-open text-4xl text-brand-700" aria-hidden="true"></i>
                                    <c:if test="${not empty course.thumbnailUrl}"><img src="<c:out value='${course.thumbnailUrl}'/>" alt="" loading="lazy" onerror="this.hidden=true" class="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"></c:if>
                                </div>
                                <div class="flex flex-col flex-grow p-5">
                                    <p class="text-xs font-semibold uppercase tracking-wide text-brand-700"><c:out value="${course.categoryName}" default="Course"/></p>
                                    <h3 class="text-lg font-bold leading-snug text-text-primary mt-2 group-hover:text-brand-700 line-clamp-2"><c:out value="${course.title}"/></h3>
                                    <c:if test="${not empty course.expertName}"><p class="mt-2 text-sm text-text-secondary line-clamp-1"><c:out value="${course.expertName}"/></p></c:if>
                                    <p class="mt-3 text-sm text-text-secondary">${course.moduleCount} modules <span aria-hidden="true">·</span> ${course.lessonCount} lessons</p>
                                    <div class="flex items-center justify-between gap-3 mt-auto pt-5">
                                        <span class="text-base font-bold text-text-primary"><c:choose><c:when test="${course.price le 0}"><span class="text-brand-700">Free</span></c:when><c:otherwise><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise></c:choose></span>
                                        <span class="text-sm font-semibold text-brand-700">View course <i class="fa-solid fa-arrow-right ml-1" aria-hidden="true"></i></span>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="rounded-xl border border-border-default bg-surface px-6 py-12 text-center">
                        <i class="fa-solid fa-book-open text-3xl text-brand-700" aria-hidden="true"></i>
                        <h3 class="mt-4 text-lg font-bold text-text-primary">No featured courses yet</h3>
                        <p class="mt-2 text-sm text-text-secondary">Explore the catalog for courses available now.</p>
                        <a href="${pageContext.request.contextPath}/courses" class="inline-flex mt-5 rounded-lg bg-brand-700 px-5 py-3 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Browse all courses</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <section aria-labelledby="benefits-heading" class="bg-surface-card border-t border-border-default py-16 lg:py-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="max-w-2xl mb-9">
                <p class="text-sm font-semibold text-brand-700 mb-2">Learn your way</p>
                <h2 id="benefits-heading" class="text-2xl sm:text-3xl font-bold text-text-primary">Make every step count</h2>
                <p class="mt-3 text-text-secondary">Move from your first lesson to confident practice with tools built around learning.</p>
            </div>
            <div class="grid md:grid-cols-3 gap-6">
                <div class="rounded-xl border border-border-default bg-surface p-6">
                    <span class="w-12 h-12 rounded-xl bg-brand-100 text-brand-900 flex items-center justify-center text-xl" aria-hidden="true"><i class="fa-solid fa-play"></i></span>
                    <h3 class="text-lg font-bold text-text-primary mt-5">Learn at your pace</h3>
                    <p class="text-sm leading-relaxed text-text-secondary mt-2">Work through course lessons when it suits your schedule.</p>
                </div>
                <div class="rounded-xl border border-border-default bg-surface p-6">
                    <span class="w-12 h-12 rounded-xl bg-brand-100 text-brand-900 flex items-center justify-center text-xl" aria-hidden="true"><i class="fa-solid fa-list-check"></i></span>
                    <h3 class="text-lg font-bold text-text-primary mt-5">Practice what you learn</h3>
                    <p class="text-sm leading-relaxed text-text-secondary mt-2">Use quizzes to check your understanding as you go.</p>
                </div>
                <div class="rounded-xl border border-border-default bg-surface p-6">
                    <span class="w-12 h-12 rounded-xl bg-brand-100 text-brand-900 flex items-center justify-center text-xl" aria-hidden="true"><i class="fa-solid fa-chart-line"></i></span>
                    <h3 class="text-lg font-bold text-text-primary mt-5">See your progress</h3>
                    <p class="text-sm leading-relaxed text-text-secondary mt-2">Keep track of completed lessons and your next step.</p>
                </div>
            </div>
            <div class="mt-12 rounded-2xl bg-surface-inverse px-6 py-8 sm:px-10 sm:py-10 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-6">
                <div>
                    <h2 class="text-2xl font-bold text-white">Ready to begin?</h2>
                    <p class="mt-2 text-sm text-slate-300">Find a course and start building a skill today.</p>
                </div>
                <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center justify-center gap-2 rounded-lg bg-brand-700 px-6 py-3 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 focus-visible:ring-offset-surface-inverse whitespace-nowrap">Explore courses <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
