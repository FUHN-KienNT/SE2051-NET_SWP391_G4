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
                            <div class="flex flex-wrap items-center gap-2">
                            <c:if test="${canCreateModule}">
                                <button type="button" id="openCreateModule"
                                        class="rounded-lg border border-brand-700 px-4 py-2.5 text-sm font-bold text-brand-700 hover:bg-brand-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                                    Create Module
                                </button>
                            </c:if>
                            <c:if test="${not empty course}">
                            <a href="${pageContext.request.contextPath}/expert/lessons/create?courseId=${course.id}"
                               class="inline-flex items-center justify-center gap-2 px-4 py-2.5 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-lg text-sm transition focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                <i class="fa-solid fa-plus text-xs" aria-hidden="true"></i>
                                <span>Create Lesson</span>
                            </a>
                            </c:if>
                            </div>
                        </div>
            <div class="mb-5 flex flex-wrap items-center gap-2 text-sm text-text-primary">
                <details id="lessonCoursePicker" class="group relative w-full min-w-0 sm:w-72">
                    <summary class="flex min-h-9 cursor-pointer list-none items-center justify-between gap-2 rounded-lg border border-border-default bg-surface-card px-3 py-1.5 focus-visible:ring-2 focus-visible:ring-brand-700 [&::-webkit-details-marker]:hidden">
                        <span class="truncate"><c:out value="${course.title}" default="No assigned courses" /></span>
                        <i class="fa-solid fa-chevron-down shrink-0 text-xs text-text-secondary group-open:rotate-180" aria-hidden="true"></i>
                    </summary>
                    <div class="absolute inset-x-0 top-full z-20 mt-1 rounded-lg border border-border-default bg-surface-card shadow-lg">
                        <ul id="lessonCourseOptions" aria-label="Assigned courses" class="max-h-60 overflow-y-auto">
                            <c:forEach items="${assignedCourses}" var="assignedCourse">
                                <c:url var="assignedCourseUrl" value="/expert/lessons">
                                    <c:param name="courseId" value="${assignedCourse.id}" />
                                </c:url>
                                <li data-course-option>
                                    <a href="${fn:escapeXml(assignedCourseUrl)}" title="${fn:escapeXml(assignedCourse.title)}"
                                       aria-current="${assignedCourse.id eq course.id ? 'page' : 'false'}"
                                       class="flex h-12 items-center px-3 hover:bg-brand-50 focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-brand-700 ${assignedCourse.id eq course.id ? 'bg-brand-50 font-semibold text-brand-900' : ''}">
                                        <span class="truncate"><c:out value="${assignedCourse.title}" /></span>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                        <p id="courseSearchStatus" role="status" class="px-3 py-2 text-xs text-text-secondary" ${not empty assignedCourses ? 'hidden' : ''}>No matching courses.</p>
                    </div>
                </details>
                <div class="w-full sm:w-44">
                    <label for="courseNameSearch" class="sr-only">Course name</label>
                    <input type="search" id="courseNameSearch" aria-controls="lessonCourseOptions"
                           placeholder="Search by course name..."
                           class="min-h-9 w-full rounded-lg border border-border-default bg-surface-card px-3 py-1.5 focus:outline-none focus:ring-2 focus:ring-brand-700">
                </div>
            </div>
            <script>
                (() => {
                    const search = document.getElementById('courseNameSearch');
                    const picker = document.getElementById('lessonCoursePicker');
                    const options = document.getElementById('lessonCourseOptions');
                    const courses = Array.from(options.querySelectorAll('[data-course-option]'));
                    const status = document.getElementById('courseSearchStatus');
                    const normalize = text => text.trim().toLocaleLowerCase('vi')
                        .normalize('NFD').replace(/\p{M}/gu, '').replace(/đ/g, 'd');
                    const showResults = () => {
                        const keyword = normalize(search.value);
                        for (const course of courses) {
                            course.hidden = !normalize(course.textContent).includes(keyword);
                        }
                        status.hidden = courses.some(course => !course.hidden);
                        options.scrollTop = 0;
                        picker.open = true;
                    };
                    search.addEventListener('input', showResults);
                    search.addEventListener('keydown', event => {
                        if (event.key === 'Enter' && !event.isComposing) {
                            showResults();
                            options.querySelector('li:not([hidden]) a')?.focus();
                        }
                    });
                    document.addEventListener('click', event => {
                        if (!picker.contains(event.target) && event.target !== search) picker.open = false;
                    });
                    document.addEventListener('keydown', event => {
                        if (event.key === 'Escape' && picker.open) {
                            picker.open = false;
                            if (picker.contains(document.activeElement)) picker.querySelector('summary').focus();
                        }
                    });
                })();
            </script>
            <c:if test="${canCreateModule}">
                <dialog id="createModuleDialog" aria-labelledby="createModuleHeading"
                        class="fixed inset-0 m-auto w-11/12 max-w-sm rounded-xl border border-border-default bg-surface-card p-6 text-text-primary shadow-xl backdrop:bg-slate-900/50">
                    <form method="post" action="${pageContext.request.contextPath}/expert/lessons" class="space-y-4">
                        <input type="hidden" name="action" value="createModule">
                        <input type="hidden" name="moduleId">
                        <input type="hidden" name="courseId" value="${course.id}">
                        <input type="hidden" name="csrfToken" value="${sessionScope.lessonActionToken}">
                        <h2 id="createModuleHeading" class="text-lg font-bold">Create Module</h2>
                        <label for="moduleTitle" class="block text-sm font-semibold">Module Name</label>
                        <input id="moduleTitle" name="moduleTitle" required maxlength="255" autofocus
                               class="w-full rounded-lg border border-border-default bg-surface-card px-3 py-2 focus:outline-none focus:ring-2 focus:ring-brand-700">
                        <div class="flex justify-end gap-2">
                            <button type="button" id="cancelCreateModule"
                                    class="rounded-lg border border-border-default px-4 py-2 text-sm font-semibold hover:bg-surface focus-visible:ring-2 focus-visible:ring-brand-700">Cancel</button>
                            <button type="submit"
                                    class="rounded-lg bg-brand-700 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700">Save</button>
                        </div>
                    </form>
                </dialog>
                <script>
                    (() => {
                        const dialog = document.getElementById('createModuleDialog');
                        const form = dialog.querySelector('form');
                        const heading = document.getElementById('createModuleHeading');
                        const open = (moduleId = '', title = '') => {
                            form.elements.namedItem('action').value = moduleId ? 'renameModule' : 'createModule';
                            form.elements.namedItem('moduleId').value = moduleId;
                            form.elements.namedItem('moduleTitle').value = title;
                            heading.textContent = moduleId ? 'Rename Module' : 'Create Module';
                            dialog.showModal();
                        };
                        document.getElementById('openCreateModule').addEventListener('click', () => open());
                        document.addEventListener('click', event => {
                            const button = event.target.closest('[data-rename-module]');
                            if (button) open(button.dataset.renameModule, button.dataset.moduleTitle);
                        });
                        document.getElementById('cancelCreateModule').addEventListener('click', () => dialog.close());
                        dialog.addEventListener('close', () => dialog.querySelector('form').reset());
                    })();
                </script>
            </c:if>
            <c:if test="${param.submitted eq 'true'}">
                <p role="status" class="mb-4 text-sm text-status-success">Lesson submitted for Manager review.</p>
            </c:if>
            <c:if test="${param.moduleAction eq 'createModule' or param.moduleAction eq 'renameModule' or param.moduleAction eq 'hideModule' or param.moduleAction eq 'showModule'}">
                <p role="status" class="mb-4 text-sm text-status-success">
                    ${param.moduleAction eq 'createModule' ? 'Module created.' : param.moduleAction eq 'renameModule' ? 'Module renamed.' : param.moduleAction eq 'hideModule' ? 'Module hidden.' : 'Module visible.'}
                </p>
            </c:if>
            <c:if test="${param.availability eq 'inactive'}">
                <p role="status" class="mb-4 text-sm text-status-success">Lesson set to inactive.</p>
            </c:if>
            <c:if test="${param.availability eq 'active'}">
                <p role="status" class="mb-4 text-sm text-status-success">Lesson set to active.</p>
            </c:if>
            <form class="mb-5 flex flex-wrap items-end justify-between gap-4 text-sm text-text-primary" id="lessonListFilters" method="GET" action="${pageContext.request.contextPath}/expert/lessons">
                <input type="hidden" name="courseId" value="${course.id}">
                <div class="flex w-full items-end gap-2 sm:w-auto">
                    <div class="min-w-0 flex-1 sm:w-56">
                        <label for="lessonSearch" class="font-medium">Lesson Title</label>
                        <input id="lessonSearch" name="lessonSearch" type="search" value="${fn:escapeXml(lessonSearch)}"
                               placeholder="Search lessons..."
                               class="mt-1 block w-full rounded-lg border border-border-default bg-surface-card px-2 py-1.5 text-xs focus:outline-none focus:ring-2 focus:ring-brand-700">
                    </div>
                    <button type="submit" class="rounded-lg bg-brand-700 px-3 py-1.5 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Search</button>
                </div>
                <div class="ml-auto flex max-w-full flex-wrap items-end justify-end gap-4">
                    <div>
                        <label for="lessonModuleId" class="inline-flex items-center gap-2">Module <i class="fa-solid fa-filter ${empty lessonModuleId ? 'text-text-secondary' : 'text-brand-700'}" aria-hidden="true"></i></label>
                        <select id="lessonModuleId" name="lessonModuleId" aria-label="Filter lesson module" onchange="this.form.requestSubmit()"
                                class="block mt-1 w-48 max-w-full rounded-lg border border-border-default bg-surface-card px-2 py-1.5 text-xs font-medium text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                            <option value="" ${empty lessonModuleId ? 'selected' : ''}>All</option>
                            <c:forEach var="filterModule" items="${modules}">
                                <option value="${filterModule.id}" ${filterModule.id eq lessonModuleId ? 'selected' : ''}><c:out value="${filterModule.title}" /></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label for="lessonStatus" class="inline-flex items-center gap-2">Status <i class="fa-solid fa-filter ${empty lessonStatus ? 'text-text-secondary' : 'text-brand-700'}" aria-hidden="true"></i></label>
                        <select id="lessonStatus" name="lessonStatus" aria-label="Filter lesson status" onchange="this.form.requestSubmit()"
                                class="block mt-1 max-w-full rounded-lg border border-border-default bg-surface-card px-2 py-1.5 text-xs font-medium text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                            <option value="" ${empty lessonStatus ? 'selected' : ''}>All</option>
                            <option value="draft" ${lessonStatus eq 'draft' ? 'selected' : ''}>Draft</option>
                            <option value="decline" ${lessonStatus eq 'decline' ? 'selected' : ''}>Decline</option>
                            <option value="published" ${lessonStatus eq 'published' ? 'selected' : ''}>Published</option>
                            <option value="archived" ${lessonStatus eq 'archived' ? 'selected' : ''}>Archived</option>
                        </select>
                    </div>
                    <div>
                        <label for="durationSort" class="font-medium">Duration</label>
                        <select id="durationSort" name="durationSort" onchange="this.form.requestSubmit()"
                                class="mt-1 block rounded-lg border border-border-default bg-surface-card px-2 py-1.5 text-xs font-medium focus:outline-none focus:ring-2 focus:ring-brand-700">
                            <option value="" ${lessonSort ne 'duration' ? 'selected' : ''}>Default</option>
                            <option value="asc" ${lessonSort eq 'duration' and lessonDirection eq 'asc' ? 'selected' : ''}>Ascending</option>
                            <option value="desc" ${lessonSort eq 'duration' and lessonDirection eq 'desc' ? 'selected' : ''}>Descending</option>
                        </select>
                    </div>
                </div>
            </form>

            <div class="space-y-3">
                <c:forEach var="group" items="${lessonsByModule}" varStatus="moduleLoop">
                    <div class="relative">
                        <details class="group rounded-xl border border-border-default bg-surface-card" ${moduleLoop.first ? 'open' : ''}>
                            <summary class="flex cursor-pointer list-none h-14 items-center gap-2 rounded-xl bg-surface pl-4 pr-24 sm:pr-52 font-semibold text-text-primary hover:bg-brand-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-brand-700 [&::-webkit-details-marker]:hidden">
                                <i class="fa-solid fa-chevron-down shrink-0 text-xs text-text-secondary transition-transform group-open:rotate-180" aria-hidden="true"></i>
                                <span class="min-w-0 truncate"><c:out value="${group.key.title}" /></span>
                            </summary>
                            <div class="overflow-x-auto border-t border-border-default">
                                <table class="w-full text-left text-sm text-text-secondary" aria-label="${fn:escapeXml(group.key.title)}">
                                    <thead class="bg-surface text-xs font-bold text-text-primary">
                                        <tr>
                                            <th scope="col" class="px-5 py-4">Lesson Title</th>
                                            <th scope="col" class="px-5 py-4">Type</th>
                                            <th scope="col" class="px-5 py-4 text-center">Status</th>
                                            <th scope="col" class="px-5 py-4 text-center" aria-sort="${lessonSort eq 'duration' ? (lessonDirection eq 'asc' ? 'ascending' : 'descending') : 'none'}">Duration</th>
                                            <th scope="col" class="px-5 py-4 text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-border-default">
                                        <c:forEach var="les" items="${group.value}">
                                            <tr class="hover:bg-surface">
                                                <c:url var="lessonEditUrl" value="/expert/lessons/edit">
                                                    <c:param name="id" value="${les.id}" />
                                                    <c:param name="courseId" value="${course.id}" />
                                                </c:url>
                                                <td class="px-5 py-4 font-medium text-text-primary">
                                                    <a href="${fn:escapeXml(lessonEditUrl)}"
                                                       class="rounded hover:text-brand-700 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                                        <c:out value="${les.title}" />
                                                    </a>
                                                </td>
                                                <td class="px-5 py-4 capitalize"><c:out value="${les.type}" default="content" /></td>
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
                                                    <a href="${fn:escapeXml(lessonEditUrl)}"
                                                       class="inline-flex rounded-lg px-3 py-2 text-brand-700 hover:bg-brand-50 hover:text-brand-800 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Edit</a>
                                                   <c:if test="${les.publicationStatus eq 'published' || les.publicationStatus eq 'archived'}">
                                                   <form action="${pageContext.request.contextPath}/expert/lessons"
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
                                        </c:forEach>
                                        <c:if test="${empty group.value}">
                                            <tr><td colspan="5" class="px-5 py-4 text-sm">Chưa có bài học nào trong chương này.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </details>
                        <div class="absolute right-2 top-2 flex items-center gap-1">
                            <button type="button" data-rename-module="${group.key.id}" data-module-title="${fn:escapeXml(group.key.title)}"
                                    aria-label="Rename module" title="Rename module"
                                    class="inline-flex h-10 items-center gap-2 rounded-lg px-2 text-sm font-semibold text-brand-700 hover:bg-brand-50 focus-visible:ring-2 focus-visible:ring-brand-700">
                                <i class="fa-solid fa-pen" aria-hidden="true"></i><span class="hidden sm:inline">Rename</span>
                            </button>
                            <form method="post" action="${pageContext.request.contextPath}/expert/lessons">
                                <input type="hidden" name="action" value="${group.key.hidden ? 'showModule' : 'hideModule'}">
                                <input type="hidden" name="courseId" value="${course.id}">
                                <input type="hidden" name="moduleId" value="${group.key.id}">
                                <input type="hidden" name="csrfToken" value="${sessionScope.lessonActionToken}">
                                <button type="submit" aria-label="${group.key.hidden ? 'Show module' : 'Hide module'}"
                                        title="${group.key.hidden ? 'Show module' : 'Hide module'}"
                                        data-confirm="${group.key.hidden ? 'Show this module to students?' : 'Hide this module and its lessons from students?'}"
                                        class="inline-flex h-10 items-center gap-2 rounded-lg px-2 text-sm font-semibold focus-visible:ring-2 ${group.key.hidden ? 'text-brand-700 hover:bg-brand-50 focus-visible:ring-brand-700' : 'text-status-danger hover:bg-surface focus-visible:ring-status-danger'}">
                                    <i class="fa-solid ${group.key.hidden ? 'fa-eye' : 'fa-eye-slash'}" aria-hidden="true"></i>
                                    <span class="hidden sm:inline">${group.key.hidden ? 'Show' : 'Hide'}</span>
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty lessonsByModule}">
                    <p class="px-6 py-12 text-center text-sm text-text-secondary">
                        <c:choose>
                            <c:when test="${not empty lessonSearch or not empty lessonStatus or not empty lessonModuleId}">No lessons match the selected filters.</c:when>
                            <c:otherwise>Khóa học này hiện chưa có module hoặc bài giảng nào.</c:otherwise>
                        </c:choose>
                    </p>
                </c:if>
            </div>
        </div>
    </main>
</div>
</div>

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
