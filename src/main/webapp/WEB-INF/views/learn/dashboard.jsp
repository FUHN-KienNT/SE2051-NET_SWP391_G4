<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageLanguage" value="en" scope="request" />
<c:set var="pageTitle" value="My Courses - LearnHub" scope="request" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main data-learning-user="${sessionScope.currentUser.id}"
      data-learning-context="${fn:escapeXml(pageContext.request.contextPath)}"
      class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">

    <div class="rounded-2xl border border-brand-100 bg-brand-50 p-6 sm:p-8 mb-8">
        <p class="text-sm font-semibold text-brand-700 mb-2">
            Learning Space
        </p>
        <h1 class="text-3xl font-bold text-text-primary">
            My Courses
        </h1>
        <p class="mt-3 text-text-secondary">
            Continue learning and discover new courses tailored to you.
        </p>
    </div>

    <c:if test="${param.notice eq 'no-lessons'}">
        <p role="status"
           class="mb-6 rounded-xl bg-amber-50 border border-amber-200 p-4 text-status-warning">
            This course does not have any lessons yet. Please check back later.
        </p>
    </c:if>

    <form action="${pageContext.request.contextPath}/my-enrollments"
          method="get"
          class="mb-10 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 rounded-xl border border-border-default bg-surface-card p-5 shadow-sm">

        <div class="sm:col-span-2 lg:col-span-1">
            <label for="search" class="block text-sm font-semibold mb-2">
                Search Courses
            </label>
            <input id="search"
                   name="search"
                   value="${fn:escapeXml(search)}"
                   placeholder="Enter a course name"
                   class="w-full rounded-lg border border-border-default px-3 py-2.5 focus:ring-2 focus:ring-brand-700 focus:outline-none">
        </div>

        <div>
            <label for="categoryId" class="block text-sm font-semibold mb-2">
                Category · Available Courses
            </label>
            <select id="categoryId"
                    name="categoryId"
                    class="w-full rounded-lg border border-border-default px-3 py-2.5 bg-white focus:ring-2 focus:ring-brand-700 focus:outline-none">
                <option value="">All Categories</option>

                <c:forEach items="${categories}" var="category">
                    <option value="${category.id}"
                            ${selectedCategory eq category.id.toString() ? 'selected' : ''}>
                        <c:out value="${category.name}" />
                    </option>
                </c:forEach>
            </select>
        </div>

        <div>
            <label for="sort" class="block text-sm font-semibold mb-2">
                Sort · Available Courses
            </label>
            <select id="sort"
                    name="sort"
                    class="w-full rounded-lg border border-border-default px-3 py-2.5 bg-white focus:ring-2 focus:ring-brand-700 focus:outline-none">
                <option value="newest" ${sort eq 'newest' ? 'selected' : ''}>
                    Newest
                </option>
                <option value="title_asc" ${sort eq 'title_asc' ? 'selected' : ''}>
                    Title A–Z
                </option>
                <option value="price_asc" ${sort eq 'price_asc' ? 'selected' : ''}>
                    Price: Low to High
                </option>
                <option value="price_desc" ${sort eq 'price_desc' ? 'selected' : ''}>
                    Price: High to Low
                </option>
            </select>
        </div>

        <div class="flex items-end gap-3">
            <button type="submit"
                    class="rounded-lg bg-brand-700 hover:bg-brand-800 text-white font-semibold px-5 py-2.5 focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                Apply
            </button>

            <a href="${pageContext.request.contextPath}/my-enrollments"
               class="rounded-lg border border-border-default px-4 py-2.5 font-medium hover:bg-slate-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                Reset
            </a>
        </div>
    </form>

    <%-- My Courses --%>
    <section class="mb-12"
             data-course-section
             aria-labelledby="my-heading">

        <h2 id="my-heading" class="text-2xl font-bold mb-5">
            Enrolled Courses
            <span class="text-base font-medium text-text-secondary">
                (${fn:length(myCourses)})
            </span>
        </h2>

        <c:choose>
            <c:when test="${empty myCourses}">
                <p class="rounded-xl border border-dashed border-border-default p-8 bg-surface-card text-text-secondary">
                    No matching enrolled courses found. Explore the courses below.
                </p>
            </c:when>

            <c:otherwise>
                <div id="my-course-list"
                     class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

                    <c:forEach items="${myCourses}" var="course">
                        <article data-course-card
                                 class="flex flex-col overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-sm">
                            <a href="${pageContext.request.contextPath}/learn/course?id=${course.courseId}"
                               aria-label="Xem chi tiết khóa học">
                            <c:choose>
                                <c:when test="${not empty course.thumbnailUrl}">
                                    <img src="${fn:escapeXml(course.thumbnailUrl)}"
                                         alt=""
                                         loading="lazy"
                                         class="h-44 w-full object-cover">
                                </c:when>
                                <c:otherwise>
                                    <div class="h-44 bg-brand-50 flex items-center justify-center text-brand-700 text-4xl">
                                        <i class="fa-solid fa-book-open"
                                           aria-hidden="true"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </a>
                            <div class="p-5 flex flex-col flex-grow">
                                <p class="text-xs font-semibold text-brand-700 mb-2">
                                    <c:out value="${empty course.categoryName ? 'Course' : course.categoryName}" />
                                </p>

                                <h3 class="text-lg font-bold break-words">
                                    <a href="${pageContext.request.contextPath}/learn/course?id=${course.courseId}">
                                        <c:out value="${course.courseTitle}" />
                                    </a>
                                </h3>

                                <p class="text-sm text-text-secondary mt-2">
                                    ${course.moduleCount} modules ·
                                    ${course.lessonCount} lessons
                                </p>

                                <div class="mt-5 mb-5">
                                    <div class="flex justify-between text-sm mb-2">
                                        <span>Progress</span>
                                        <span class="font-semibold text-brand-700">
                                            ${course.progressPercent}%
                                        </span>
                                    </div>

                                    <progress value="${course.progressPercent}"
                                              max="100"
                                              aria-label="Learning progress"
                                              class="w-full h-2 rounded-full overflow-hidden text-brand-700 bg-slate-200 [&::-webkit-progress-bar]:bg-slate-200 [&::-webkit-progress-value]:bg-brand-700 [&::-moz-progress-bar]:bg-brand-700">
                                    </progress>

                                    <c:if test="${not empty course.lessonTitle}">
                                        <p data-resume-label
                                           class="mt-2 text-sm text-text-secondary">
                                            Next lesson:
                                            <c:out value="${course.lessonTitle}" />
                                        </p>
                                    </c:if>
                                </div>

                                <c:url value="/my-enrollments" var="continueUrl">
                                    <c:param name="action" value="continue" />
                                    <c:param name="courseId"
                                             value="${course.courseId}" />
                                </c:url>

                                <a data-continue-course="${course.courseId}"
                                   href="${fn:escapeXml(continueUrl)}"
                                   class="mt-auto text-center rounded-lg bg-brand-700 hover:bg-brand-800 text-white font-semibold py-2.5 px-4 focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                    Continue Learning
                                </a>
                            </div>
                        </article>
                    </c:forEach>
                </div>

                <div class="mt-6 flex justify-center gap-3"
                     data-list-controls
                     hidden>
                    <button type="button"
                            data-more
                            aria-controls="my-course-list"
                            class="rounded-lg border border-brand-700 text-brand-700 font-semibold px-5 py-2.5 hover:bg-brand-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                        Show More
                    </button>
                    <button type="button"
                            data-less
                            aria-controls="my-course-list"
                            class="rounded-lg border border-border-default font-semibold px-5 py-2.5 hover:bg-slate-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                        Show Less
                    </button>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <%-- Available Courses --%>
    <section data-course-section aria-labelledby="available-heading">

        <h2 id="available-heading" class="text-2xl font-bold mb-5">
            Available Courses
            <span class="text-base font-medium text-text-secondary">
                (${fn:length(availableCourses)})
            </span>
        </h2>

        <c:choose>
            <c:when test="${empty availableCourses}">
                <p class="rounded-xl border border-dashed border-border-default p-8 bg-surface-card text-text-secondary">
                    No matching courses found. Try a different search term or category.
                </p>
            </c:when>

            <c:otherwise>
                <div id="available-course-list"
                     class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

                    <c:forEach items="${availableCourses}" var="course">
                        <article data-course-card
                                 class="flex flex-col overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-sm">

                            <c:choose>
                                <c:when test="${not empty course.thumbnailUrl}">
                                    <img src="${fn:escapeXml(course.thumbnailUrl)}"
                                         alt=""
                                         loading="lazy"
                                         class="h-44 w-full object-cover">
                                </c:when>
                                <c:otherwise>
                                    <div class="h-44 bg-brand-50 flex items-center justify-center text-brand-700 text-4xl">
                                        <i class="fa-solid fa-graduation-cap"
                                           aria-hidden="true"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <div class="p-5 flex flex-col flex-grow">
                                <p class="text-xs font-semibold text-brand-700 mb-2">
                                    <c:out value="${empty course.categoryName ? 'Course' : course.categoryName}" />
                                </p>

                                <h3 class="text-lg font-bold break-words">
                                    <c:out value="${course.title}" />
                                </h3>

                                <p class="text-sm text-text-secondary mt-2">
                                    <c:out value="${empty course.expertName ? 'LearnHub' : course.expertName}" />
                                </p>

                                <p class="text-sm text-text-secondary mt-2">
                                    ${course.moduleCount} modules ·
                                    ${course.lessonCount} lessons
                                </p>

                                <p class="text-lg font-bold text-brand-700 mt-4 mb-5">
                                    <c:choose>
                                        <c:when test="${empty course.price or course.price le 0}">
                                            Free
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${course.price}"
                                                              pattern="#,##0" /> VND
                                        </c:otherwise>
                                    </c:choose>
                                </p>

                                <c:url value="/course-detail" var="detailUrl">
                                    <c:param name="id" value="${course.id}" />
                                </c:url>

                                <a href="${fn:escapeXml(detailUrl)}"
                                   class="mt-auto text-center rounded-lg border border-brand-700 text-brand-700 hover:bg-brand-50 font-semibold px-4 py-2.5 focus-visible:ring-2 focus-visible:ring-brand-700">
                                    View Details
                                </a>
                            </div>
                        </article>
                    </c:forEach>
                </div>

                <div class="mt-6 flex justify-center gap-3"
                     data-list-controls
                     hidden>
                    <button type="button"
                            data-more
                            aria-controls="available-course-list"
                            class="rounded-lg border border-brand-700 text-brand-700 font-semibold px-5 py-2.5 hover:bg-brand-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                        Show More
                    </button>
                    <button type="button"
                            data-less
                            aria-controls="available-course-list"
                            class="rounded-lg border border-border-default font-semibold px-5 py-2.5 hover:bg-slate-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                        Show Less
                    </button>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<style>
    [hidden] {
        display: none !important;
    }

    progress {
        accent-color: currentColor;
    }
</style>

<script>
    // Restore the last lesson separately for each user and course.
    (() => {
        const root = document.querySelector('[data-learning-user]');
        if (!root) return;

        const userId = root.dataset.learningUser;
        const contextPath = root.dataset.learningContext;

        const uuidPattern =
                /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

        function storageKey(courseId) {
            return 'learnhub:lastLesson:'
                    + contextPath + ':'
                    + userId + ':'
                    + courseId;
        }

        function readSaved(courseId) {
            try {
                const saved = JSON.parse(
                        localStorage.getItem(storageKey(courseId))
                );

                if (saved
                        && typeof saved.lessonId === 'string'
                        && uuidPattern.test(saved.lessonId)) {
                    return saved;
                }
            } catch (error) {
                // Continue uses the first lesson if storage is unavailable.
            }

            return null;
        }

        root.querySelectorAll('[data-continue-course]').forEach(link => {
            const courseId = link.dataset.continueCourse;
            const defaultUrl = link.href;
            const saved = readSaved(courseId);

            const label = link.closest('[data-course-card]')
                    .querySelector('[data-resume-label]');

            if (saved && label) {
                label.textContent =
                        typeof saved.lessonTitle === 'string'
                        && saved.lessonTitle.trim()
                                ? 'Resume: ' + saved.lessonTitle
                                : 'Resume the last lesson';
            }

            function updateLink() {
                const latest = readSaved(courseId);
                const url = new URL(defaultUrl, window.location.href);

                if (latest) {
                    url.searchParams.set('lessonId', latest.lessonId);
                }

                link.href = url.toString();
            }

            updateLink();

            // Read again when clicked in case another tab saved a new lesson.
            link.addEventListener('click', updateLink);
        });
    })();

    // Each section expands and collapses independently.
    document.querySelectorAll('[data-course-section]').forEach(section => {
        const cards = [...section.querySelectorAll('[data-course-card]')];
        const controls = section.querySelector('[data-list-controls]');

        if (!controls || cards.length <= 3) return;

        const more = controls.querySelector('[data-more]');
        const less = controls.querySelector('[data-less]');

        let visible = 3;

        function update() {
            cards.forEach((card, index) => {
                card.hidden = index >= visible;
            });

            controls.hidden = false;
            more.hidden = visible >= cards.length;
            less.hidden = visible <= 3;
        }

        more.addEventListener('click', () => {
            const firstNew = visible;

            visible = Math.min(visible + 3, cards.length);
            update();

            if (cards[firstNew]) {
                cards[firstNew].querySelector('a').focus();
            }
        });

        less.addEventListener('click', () => {
            visible = 3;
            update();
            more.focus();
        });

        update();
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
