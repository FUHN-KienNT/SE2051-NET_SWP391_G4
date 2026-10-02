<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="LearnHub | Find your next skill" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main lang="en" class="flex-grow bg-surface">
    <section aria-labelledby="home-heading" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-14 lg:pt-20 lg:pb-20">
        <div class="grid lg:grid-cols-2 gap-10 lg:gap-16 items-center">
            <div>
                <p class="inline-flex rounded-full bg-brand-50 px-4 py-2 text-sm font-semibold text-brand-900 mb-6">A place to keep learning</p>
                <h1 id="home-heading" class="text-4xl sm:text-5xl lg:text-6xl font-bold leading-tight tracking-tight text-text-primary">
                    Find your next skill. <span class="text-brand-700">Start learning today.</span>
                </h1>
                <p class="mt-6 text-base sm:text-lg leading-relaxed text-text-secondary max-w-xl">
                    Explore expert-led courses, learn at your own pace, and put new knowledge into practice.
                </p>
                <form action="${pageContext.request.contextPath}/courses" method="get" role="search" class="mt-8 max-w-xl">
                    <label for="home-course-search" class="block text-sm font-semibold text-text-primary mb-2">What would you like to learn?</label>
                    <div class="flex flex-col sm:flex-row gap-3">
                        <div class="relative flex-grow">
                            <i class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary" aria-hidden="true"></i>
                            <input id="home-course-search" name="search" type="search" placeholder="Search courses or topics" class="w-full h-12 rounded-lg border border-border-default bg-surface-card pl-11 pr-4 text-text-primary placeholder:text-text-secondary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                        </div>
                        <button type="submit" class="h-12 px-6 rounded-lg bg-brand-700 text-white font-semibold hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2 whitespace-nowrap">Search courses</button>
                    </div>
                </form>
                <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center gap-2 mt-6 text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2 rounded-lg">
                    Browse all courses <i class="fa-solid fa-arrow-right" aria-hidden="true"></i>
                </a>
            </div>
            <div class="rounded-3xl bg-surface-inverse p-5 sm:p-8 lg:p-10 text-white overflow-hidden">
                <div class="mb-7">
                    <p class="text-sm font-semibold text-brand-100">Your learning starts here</p>
                    <h2 class="text-2xl font-bold mt-2">Explore a course</h2>
                </div>
                <c:choose>
                    <c:when test="${not empty featuredCourses}">
                        <c:set var="spotlight" value="${featuredCourses[0]}" />
                        <a href="${pageContext.request.contextPath}/courses?action=detail&amp;id=${spotlight.id}" class="block overflow-hidden rounded-2xl bg-surface-card text-text-primary shadow-sm group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 focus-visible:ring-offset-surface-inverse">
                            <div class="relative h-48 sm:h-56 bg-brand-50 flex items-center justify-center overflow-hidden">
                                <i class="fa-solid fa-book-open text-5xl text-brand-700" aria-hidden="true"></i>
                                <c:if test="${not empty spotlight.thumbnailUrl}">
                                    <img src="<c:out value='${spotlight.thumbnailUrl}'/>" alt="" loading="lazy" onerror="this.hidden=true" class="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                </c:if>
                            </div>
                            <div class="p-5 sm:p-6">
                                <p class="text-xs font-semibold uppercase tracking-wide text-brand-700"><c:out value="${spotlight.categoryName}" default="Course"/></p>
                                <h3 class="mt-2 text-xl font-bold leading-snug group-hover:text-brand-700"><c:out value="${spotlight.title}"/></h3>
                                <p class="mt-3 text-sm text-text-secondary">${spotlight.moduleCount} modules <span aria-hidden="true">·</span> ${spotlight.lessonCount} lessons</p>
                                <span class="inline-flex items-center gap-2 mt-5 text-sm font-semibold text-brand-700">View course <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></span>
                            </div>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="rounded-2xl bg-surface-card p-8 text-text-primary text-center">
                            <i class="fa-solid fa-book-open text-4xl text-brand-700" aria-hidden="true"></i>
                            <p class="font-semibold mt-4">Your next course is on its way.</p>
                            <p class="text-sm text-text-secondary mt-2">Browse the catalog to see what is available.</p>
                            <a href="${pageContext.request.contextPath}/courses" class="inline-flex mt-5 text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 rounded-lg">Browse courses</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>

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
        <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-8">
            <div>
                <p class="text-sm font-semibold text-brand-700 mb-2">Start exploring</p>
                <h2 id="featured-heading" class="text-2xl sm:text-3xl font-bold text-text-primary">Featured courses</h2>
                <p class="mt-2 text-text-secondary">Find a course that fits your interests and your schedule.</p>
            </div>
            <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center gap-2 text-sm font-semibold text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 rounded-lg">View all courses <i class="fa-solid fa-arrow-right" aria-hidden="true"></i></a>
        </div>
        <c:choose>
            <c:when test="${not empty featuredCourses}">
                <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    <c:forEach var="course" items="${featuredCourses}">
                        <a href="${pageContext.request.contextPath}/courses?action=detail&amp;id=${course.id}" class="group flex flex-col overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-sm hover:shadow-md hover:border-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            <div class="relative h-48 bg-brand-50 flex items-center justify-center overflow-hidden">
                                <i class="fa-solid fa-book-open text-4xl text-brand-700" aria-hidden="true"></i>
                                <c:if test="${not empty course.thumbnailUrl}">
                                    <img src="<c:out value='${course.thumbnailUrl}'/>" alt="" loading="lazy" onerror="this.hidden=true" class="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                </c:if>
                            </div>
                            <div class="flex flex-col flex-grow p-5">
                                <p class="text-xs font-semibold uppercase tracking-wide text-brand-700"><c:out value="${course.categoryName}" default="Course"/></p>
                                <h3 class="text-lg font-bold leading-snug text-text-primary mt-2 group-hover:text-brand-700 line-clamp-2"><c:out value="${course.title}"/></h3>
                                <c:if test="${not empty course.expertName}"><p class="mt-2 text-sm text-text-secondary line-clamp-1"><c:out value="${course.expertName}"/></p></c:if>
                                <p class="mt-3 text-sm text-text-secondary">${course.moduleCount} modules <span aria-hidden="true">·</span> ${course.lessonCount} lessons</p>
                                <div class="flex items-center justify-between gap-3 mt-auto pt-5">
                                    <span class="text-base font-bold text-text-primary">
                                        <c:choose>
                                            <c:when test="${course.price le 0}"><span class="text-brand-700">Free</span></c:when>
                                            <c:otherwise><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="text-sm font-semibold text-brand-700">View course <i class="fa-solid fa-arrow-right ml-1" aria-hidden="true"></i></span>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="rounded-xl border border-border-default bg-surface-card px-6 py-12 text-center">
                    <i class="fa-solid fa-book-open text-3xl text-brand-700" aria-hidden="true"></i>
                    <h3 class="mt-4 text-lg font-bold text-text-primary">No featured courses yet</h3>
                    <p class="mt-2 text-sm text-text-secondary">Explore the catalog for courses available now.</p>
                    <a href="${pageContext.request.contextPath}/courses" class="inline-flex mt-5 rounded-lg bg-brand-700 px-5 py-3 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Browse all courses</a>
                </div>
            </c:otherwise>
        </c:choose>
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
