<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="userRole" value="${sessionScope.currentUser.roleCode}" />
<c:set var="isAdmin" value="${userRole eq 'ROLE_ADMIN' or userRole eq 'admin'}" />
<c:set var="isManager" value="${userRole eq 'ROLE_MANAGER' or userRole eq 'manager'}" />
<c:set var="isExpert" value="${userRole eq 'ROLE_EXPERT' or userRole eq 'expert'}" />
<c:set var="dashboardPath" value="${isExpert ? '/expert/dashboard' : isManager ? '/manager/dashboard' : '/admin/dashboard'}" />

<aside id="managementSidebar" data-collapsed="false" class="management-sidebar relative z-40 flex w-full shrink-0 flex-col border-b border-border-default bg-surface-card shadow-sm lg:min-h-screen lg:w-64 lg:rounded-r-2xl lg:border-b-0 lg:border-r" aria-label="Management workspace">
    <div>
        <div class="management-sidebar-header flex items-center gap-3 px-4 py-4 lg:px-5 lg:py-5">
            <a href="${pageContext.request.contextPath}/home" class="management-sidebar-brand inline-flex min-w-0 items-center rounded-lg text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700" aria-label="LearnHub home" title="LearnHub home">
                <span class="whitespace-nowrap text-2xl font-bold tracking-tight">LearnHub</span>
            </a>
            <button type="button" id="managementMenuButton" class="ml-auto inline-flex h-10 w-10 items-center justify-center rounded-lg border border-border-default text-text-secondary hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 lg:hidden" aria-label="Open management menu" aria-controls="managementNavigation" aria-expanded="false">
                <i class="fa-solid fa-bars" aria-hidden="true"></i>
            </button>
        </div>

        <button type="button" id="managementCollapseButton" class="absolute -right-4 top-6 z-50 hidden h-8 w-8 items-center justify-center rounded-full border border-border-default bg-surface-card text-text-secondary shadow-sm hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 lg:inline-flex" aria-label="Collapse sidebar" aria-controls="managementSidebar" aria-expanded="true" title="Collapse sidebar">
            <i id="managementCollapseIcon" class="fa-solid fa-chevron-left text-xs" aria-hidden="true"></i>
        </button>

        <nav id="managementNavigation" class="hidden space-y-5 px-3 pb-5 pt-3 lg:block" aria-label="Management navigation">
            <div>
                <p class="management-sidebar-heading mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-text-secondary">Overview</p>
                <a href="${pageContext.request.contextPath}${dashboardPath}"
                   class="management-sidebar-link flex min-h-10 items-center gap-3 rounded-lg border px-3 py-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'dashboard' ? 'border-brand-100 bg-brand-50 font-semibold text-brand-900' : 'border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'}"
                   aria-label="Dashboard" aria-current="${param.activeSection eq 'dashboard' ? 'page' : 'false'}" title="Dashboard">
                    <i class="fa-solid fa-table-cells-large w-5 text-center" aria-hidden="true"></i>
                    <span class="management-sidebar-label">Dashboard</span>
                </a>
            </div>

            <c:if test="${isManager}">
                <div class="border-t border-border-default pt-4">
                    <p class="management-sidebar-heading mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-text-secondary">Content &amp; Review</p>
                    <a href="${pageContext.request.contextPath}/manager/courses"
                       class="management-sidebar-link flex min-h-10 items-center gap-3 rounded-lg border px-3 py-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'courses' ? 'border-brand-100 bg-brand-50 font-semibold text-brand-900' : 'border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'}"
                       aria-label="Courses" aria-current="${param.activeSection eq 'courses' ? 'page' : 'false'}" title="Courses">
                        <i class="fa-solid fa-book-open w-5 text-center" aria-hidden="true"></i>
                        <span class="management-sidebar-label">Courses</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/lesson-review"
                       class="management-sidebar-link flex min-h-10 items-center gap-3 rounded-lg border px-3 py-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'review' ? 'border-brand-100 bg-brand-50 font-semibold text-brand-900' : 'border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'}"
                       aria-label="Lesson Review" aria-current="${param.activeSection eq 'review' ? 'page' : 'false'}" title="Lesson Review">
                        <i class="fa-solid fa-clipboard-check w-5 text-center" aria-hidden="true"></i>
                        <span class="management-sidebar-label">Lesson Review</span>
                    </a>
                </div>
            </c:if>

            <c:if test="${isExpert}">
                <c:set var="targetCourseId" value="${not empty param.courseId ? param.courseId : (not empty courseId ? courseId : (not empty course.id ? course.id : ''))}" />
                <c:set var="courseQuery" value="${not empty targetCourseId ? '?courseId='.concat(targetCourseId) : ''}" />
                <div class="border-t border-border-default pt-4">
                    <p class="management-sidebar-heading mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-text-secondary">Content Authoring</p>
                    <a href="${pageContext.request.contextPath}/expert/questions${courseQuery}"
                       class="management-sidebar-link flex min-h-10 items-center gap-3 rounded-lg border px-3 py-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'questions' ? 'border-brand-100 bg-brand-50 font-semibold text-brand-900' : 'border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'}"
                       aria-label="Question Bank" aria-current="${param.activeSection eq 'questions' ? 'page' : 'false'}" title="Question Bank">
                        <i class="fa-solid fa-clipboard-question w-5 text-center" aria-hidden="true"></i>
                        <span class="management-sidebar-label">Question Bank</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/expert/quizzes${courseQuery}"
                       class="management-sidebar-link flex min-h-10 items-center gap-3 rounded-lg border px-3 py-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'quiz' || param.activeSection eq 'quizzes' ? 'border-brand-100 bg-brand-50 font-semibold text-brand-900' : 'border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'}"
                       aria-label="Quizzes and Exams" aria-current="${param.activeSection eq 'quiz' || param.activeSection eq 'quizzes' ? 'page' : 'false'}" title="Quizzes and Exams">
                        <i class="fa-solid fa-list-check w-5 text-center" aria-hidden="true"></i>
                        <span class="management-sidebar-label">Quizzes &amp; Exams</span>
                    </a>
                </div>
            </c:if>

            <c:if test="${isAdmin}">
                <div class="border-t border-border-default pt-4">
                    <p class="management-sidebar-heading mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-text-secondary">System</p>
                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="management-sidebar-link flex min-h-10 items-center gap-3 rounded-lg border px-3 py-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'users' ? 'border-brand-100 bg-brand-50 font-semibold text-brand-900' : 'border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'}"
                       aria-label="User Management" aria-current="${param.activeSection eq 'users' ? 'page' : 'false'}" title="User Management">
                        <i class="fa-solid fa-users w-5 text-center" aria-hidden="true"></i>
                        <span class="management-sidebar-label">User Management</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/settings"
                       class="management-sidebar-link flex min-h-10 items-center gap-3 rounded-lg border px-3 py-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'settings' ? 'border-brand-100 bg-brand-50 font-semibold text-brand-900' : 'border-transparent text-text-secondary hover:bg-surface hover:text-text-primary'}"
                       aria-label="System Settings" aria-current="${param.activeSection eq 'settings' ? 'page' : 'false'}" title="System Settings">
                        <i class="fa-solid fa-sliders w-5 text-center" aria-hidden="true"></i>
                        <span class="management-sidebar-label">System Settings</span>
                    </a>
                </div>
            </c:if>

            <c:if test="${isExpert and param.activeSection eq 'lessons' and courseTotal ne null}">
                <jsp:include page="/WEB-INF/views/expert/assigned-course-sidebar.jsp" />
            </c:if>
        </nav>
    </div>

    <div id="managementSidebarFooter" class="mt-auto hidden border-t border-border-default p-3 lg:block">
        <button type="button" id="notificationButton" class="management-sidebar-link relative flex min-h-10 w-full items-center gap-3 rounded-lg px-3 py-2 text-left text-sm font-medium text-text-secondary hover:bg-surface hover:text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700" aria-label="Open notifications" aria-controls="notificationPanel" aria-expanded="false" title="Notifications">
            <i class="fa-regular fa-bell w-5 text-center" aria-hidden="true"></i>
            <span class="management-sidebar-label">Notifications</span>
            <span id="notificationUnreadDot" class="absolute right-3 top-2 hidden h-2 w-2 rounded-full bg-status-success" aria-hidden="true"></span>
        </button>
        <div class="management-sidebar-account mt-2 flex items-center gap-1 rounded-xl border border-border-default bg-surface p-1">
            <a href="${pageContext.request.contextPath}/profile" class="management-sidebar-profile flex min-w-0 flex-1 items-center gap-2 rounded-lg p-1 text-text-primary hover:bg-brand-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700" aria-label="My profile" title="My profile">
                <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-50 text-xs font-bold uppercase text-brand-900"><c:out value="${empty sessionScope.currentUser.fullName ? 'LH' : fn:substring(sessionScope.currentUser.fullName, 0, 1)}" /></span>
                <span class="management-sidebar-profile-copy min-w-0 flex-1">
                    <span class="block truncate text-xs font-semibold"><c:out value="${empty sessionScope.currentUser.fullName ? sessionScope.currentUser.username : sessionScope.currentUser.fullName}" /></span>
                    <span class="block text-xs text-text-secondary"><c:choose><c:when test="${isAdmin}">Admin</c:when><c:when test="${isManager}">Manager</c:when><c:when test="${isExpert}">Expert</c:when></c:choose></span>
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/auth/logout" class="management-sidebar-signout inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-lg text-text-secondary hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700" aria-label="Sign out" title="Sign out"><i class="fa-solid fa-arrow-right-from-bracket" aria-hidden="true"></i></a>
        </div>
    </div>

    <section id="notificationPanel" data-notification-url="${pageContext.request.contextPath}/notifications" class="absolute bottom-24 left-4 right-4 z-50 hidden overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-xl lg:bottom-4 lg:left-full lg:right-auto lg:ml-2 lg:w-80" aria-labelledby="notificationHeading" tabindex="-1">
        <div class="flex items-center justify-between gap-4 border-b border-border-default bg-surface px-4 py-3">
            <h2 id="notificationHeading" class="text-xs font-bold uppercase tracking-wider text-text-primary">Notifications</h2>
            <button type="button" id="notificationReadAll" disabled class="inline-flex items-center gap-1 rounded-lg px-2 py-1 text-xs font-medium text-text-secondary hover:bg-brand-50 hover:text-brand-700 disabled:cursor-not-allowed disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700"><i class="fa-solid fa-check-double text-xs" aria-hidden="true"></i> Mark all read</button>
        </div>
        <div class="max-h-80 divide-y divide-border-default overflow-y-auto">
            <p id="notificationStatus" class="hidden px-4 py-6 text-center text-xs text-text-secondary" role="status" aria-live="polite"></p>
            <button type="button" id="notificationRetry" class="mx-4 mb-3 hidden rounded-lg px-3 py-1.5 text-xs font-semibold text-brand-700 hover:bg-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Retry</button>
            <ul id="notificationList" class="divide-y divide-border-default" aria-label="Notification list"></ul>
            <p id="notificationLimitNote" class="hidden border-t border-border-default px-4 py-2.5 text-center text-xs text-text-secondary">Showing 20 most recent notifications.</p>
        </div>
    </section>
</aside>

<script>
    (function () {
        const sidebar = document.getElementById('managementSidebar');
        const menuButton = document.getElementById('managementMenuButton');
        const collapseButton = document.getElementById('managementCollapseButton');
        const collapseIcon = document.getElementById('managementCollapseIcon');
        const brand = sidebar && sidebar.querySelector('.management-sidebar-brand');
        const navigation = document.getElementById('managementNavigation');
        const footer = document.getElementById('managementSidebarFooter');
        if (!sidebar || !menuButton || !collapseButton || !collapseIcon || !brand || !navigation || !footer) return;

        function setCollapsed(collapsed) {
            sidebar.dataset.collapsed = String(collapsed);
            brand.style.display = collapsed && window.matchMedia('(min-width: 1024px)').matches
                ? 'none'
                : 'inline-flex';
            collapseButton.setAttribute('aria-expanded', String(!collapsed));
            collapseButton.setAttribute('aria-label', collapsed ? 'Expand sidebar' : 'Collapse sidebar');
            collapseButton.title = collapsed ? 'Expand sidebar' : 'Collapse sidebar';
            collapseIcon.classList.toggle('fa-chevron-left', !collapsed);
            collapseIcon.classList.toggle('fa-chevron-right', collapsed);
        }

        try {
            setCollapsed(localStorage.getItem('learnhub-management-sidebar-collapsed') === 'true');
        } catch (error) {
            setCollapsed(false);
        }

        collapseButton.addEventListener('click', function () {
            const collapsed = sidebar.dataset.collapsed !== 'true';
            setCollapsed(collapsed);
            try { localStorage.setItem('learnhub-management-sidebar-collapsed', String(collapsed)); } catch (error) { /* Storage can be disabled. */ }
        });

        window.addEventListener('resize', function () {
            setCollapsed(sidebar.dataset.collapsed === 'true');
        });

        menuButton.addEventListener('click', function () {
            const expanded = menuButton.getAttribute('aria-expanded') === 'true';
            menuButton.setAttribute('aria-expanded', String(!expanded));
            menuButton.setAttribute('aria-label', expanded ? 'Open management menu' : 'Close management menu');
            navigation.classList.toggle('hidden', expanded);
            footer.classList.toggle('hidden', expanded);
        });
    })();
</script>
<script src="${pageContext.request.contextPath}/assets/js/notifications.js" defer></script>
