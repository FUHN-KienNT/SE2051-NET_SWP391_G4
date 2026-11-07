<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageLanguage" value="en" scope="request" />
<c:set var="pageTitle" value="My Courses - LearnHub" scope="request" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main data-learning-user="${sessionScope.currentUser.id}"
      data-learning-context="${fn:escapeXml(pageContext.request.contextPath)}"
      class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">

    <div class="mb-6 flex flex-wrap items-center justify-between gap-4 rounded-xl border border-brand-100 bg-brand-50 px-5 py-4">
        <div>
            <p class="text-sm font-semibold text-brand-700">Learning Space</p>
            <h1 class="text-2xl font-bold text-text-primary">My Courses</h1>
            <p class="mt-1 text-sm text-text-secondary">Continue learning and discover new courses tailored to you.</p>
        </div>
        <a href="${pageContext.request.contextPath}/courses"
           class="rounded-lg bg-brand-700 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
            Discover New Course
        </a>
    </div>

    <c:if test="${param.notice eq 'no-lessons'}">
        <p role="status"
           class="mb-6 rounded-xl bg-amber-50 border border-amber-200 p-4 text-status-warning">
            This course does not have any lessons yet. Please check back later.
        </p>
    </c:if>

    <div class="mb-6 flex flex-wrap items-end justify-between gap-4 rounded-xl border border-border-default bg-surface-card p-4">
        <dl class="flex flex-wrap gap-x-4 gap-y-1 text-sm">
            <div class="flex gap-1"><dt>Total Courses</dt><dd class="font-bold"><c:out value="${requestScope.enrolledCourseCount}" default="0" /></dd></div>
            <div class="flex gap-1"><dt>Complete</dt><dd class="font-bold text-status-success"><c:out value="${requestScope.completedCourseCount}" default="0" /></dd></div>
            <div class="flex gap-1"><dt>On-going</dt><dd class="font-bold text-status-warning"><c:out value="${requestScope.ongoingCourseCount}" default="0" /></dd></div>
        </dl>
        <form id="studentCourseFilters" action="${pageContext.request.contextPath}/my-enrollments" method="get"
              class="flex w-full flex-wrap items-end gap-3 text-sm lg:w-auto lg:justify-end">
            <div class="w-full sm:w-64">
                <label for="search" class="mb-1 block font-semibold">Course Name</label>
                <div class="flex gap-2">
                <input id="search" name="search" type="search" value="${fn:escapeXml(search)}"
                       placeholder="Enter a course name"
                       class="min-w-0 flex-1 rounded-lg border border-border-default bg-surface-card px-3 py-2 focus:outline-none focus:ring-2 focus:ring-brand-700">
                    <button type="submit" class="rounded-lg bg-brand-700 px-3 py-2 font-semibold text-white hover:bg-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Search</button>
                </div>
            </div>
            <div class="w-full sm:w-44">
                <label for="categoryId" class="mb-1 block font-semibold">Category</label>
                <select id="categoryId" name="categoryId"
                        class="w-full rounded-lg border border-border-default bg-surface-card px-3 py-2 focus:outline-none focus:ring-2 focus:ring-brand-700">
                    <option value="">All Categories</option>
                    <c:forEach items="${categories}" var="category">
                        <option value="${category.id}" ${selectedCategory eq category.id.toString() ? 'selected' : ''}>
                            <c:out value="${category.name}" />
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="w-full sm:w-auto">
                <label for="status" class="mb-1 block font-semibold">Status</label>
                <select id="status" name="status"
                        class="w-full rounded-lg border border-border-default bg-surface-card px-3 py-2 focus:outline-none focus:ring-2 focus:ring-brand-700">
                    <option value="">All Statuses</option>
                    <option value="completed" ${selectedStatus eq 'completed' ? 'selected' : ''}>Complete</option>
                    <option value="enrolled" ${selectedStatus eq 'enrolled' ? 'selected' : ''}>On-going</option>
                </select>
            </div>
            <div class="w-full sm:w-auto">
                <label for="sort" class="mb-1 block font-semibold">Sort By</label>
                <select id="sort" name="sort"
                        class="w-full rounded-lg border border-border-default bg-surface-card px-3 py-2 focus:outline-none focus:ring-2 focus:ring-brand-700">
                    <option value="newest" ${sort eq 'newest' ? 'selected' : ''}>Newest</option>
                    <option value="progress_desc" ${sort eq 'progress_desc' ? 'selected' : ''}>Progress: High to Low</option>
                    <option value="progress_asc" ${sort eq 'progress_asc' ? 'selected' : ''}>Progress: Low to High</option>
                </select>
            </div>
        </form>
    </div>

    <%-- My Courses --%>
    <section class="mb-12"
             data-course-section
             aria-labelledby="my-heading">

        <h2 id="my-heading" class="text-2xl font-bold mb-5">
            Enrolled Courses
        </h2>

        <c:choose>
            <c:when test="${empty myCourses}">
                <p class="rounded-xl border border-dashed border-border-default p-8 bg-surface-card text-text-secondary">
                    No enrolled courses match your filters.
                </p>
            </c:when>

            <c:otherwise>
                <div id="my-course-list"
                     class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

                    <c:forEach items="${myCourses}" var="course">
                        <article data-course-card
                                 class="relative flex flex-col overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-sm">
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
                            <div class="p-5 flex flex-col flex-grow">
                                <p class="text-xs font-semibold text-brand-700 mb-2">
                                    <c:out value="${empty course.categoryName ? 'Course' : course.categoryName}" />
                                </p>

                                <h3 class="text-lg font-bold break-words">
                                    <a href="${pageContext.request.contextPath}/learn/course?id=${course.courseId}" class="after:absolute after:inset-0 after:cursor-pointer after:content-[''] hover:text-brand-700 focus-visible:text-brand-700 focus-visible:after:ring-2 focus-visible:after:ring-inset focus-visible:after:ring-brand-700">
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
                                   class="relative z-10 mt-auto text-center rounded-lg bg-brand-700 hover:bg-brand-800 text-white font-semibold py-2.5 px-4 focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
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
    document.querySelectorAll('#studentCourseFilters select').forEach(select => {
        select.addEventListener('change', () => select.form.requestSubmit());
    });

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

    // Show more or fewer enrolled courses.
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
