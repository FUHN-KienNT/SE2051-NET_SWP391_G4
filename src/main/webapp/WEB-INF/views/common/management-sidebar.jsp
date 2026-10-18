<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- 
  LearnHub Unified Management Sidebar
  Shared across 3 roles: ROLE_ADMIN, ROLE_MANAGER, ROLE_EXPERT
  Follows DESIGN_SYSTEM.md & AGENTS.md
--%>
<c:set var="userRole" value="${sessionScope.currentUser.roleCode}" />
<c:set var="isAdmin" value="${userRole eq 'ROLE_ADMIN' or userRole eq 'admin'}" />
<c:set var="isManager" value="${userRole eq 'ROLE_MANAGER' or userRole eq 'manager'}" />
<c:set var="isExpert" value="${userRole eq 'ROLE_EXPERT' or userRole eq 'expert'}" />

<aside class="relative z-40 w-full shrink-0 border-b border-border-default bg-surface-card lg:min-h-screen lg:w-64 lg:border-b-0 lg:border-r flex flex-col justify-between" aria-label="Management workspace">
    <div class="flex flex-col">
        <%-- Header Branding & Notification Bar --%>
        <div class="flex items-center justify-between gap-3 px-4 py-4 lg:px-5 lg:py-5 border-b border-border-default">
            <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-3 rounded-lg text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                <span class="min-w-0">
                    <span class="block text-2xl font-bold leading-tight">LearnHub</span>
                    <span class="block text-xs font-medium text-text-secondary">
                        <c:choose>
                            <c:when test="${isAdmin}">Admin Portal</c:when>
                            <c:when test="${isManager}">Manager Workspace</c:when>
                            <c:when test="${isExpert}">Expert Studio</c:when>
                            <c:otherwise>Management</c:otherwise>
                        </c:choose>
                    </span>
                </span>
            </a>

            <div class="flex items-center gap-1.5">
                <button type="button" id="notificationButton" class="relative inline-flex h-9 w-9 items-center justify-center rounded-lg text-text-secondary hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700" aria-label="Open notifications" aria-expanded="false" aria-controls="notificationPanel">
                    <i class="fa-regular fa-bell" aria-hidden="true"></i>
                    <span id="notificationUnreadDot" class="hidden absolute right-1.5 top-1.5 h-2 w-2 rounded-full bg-status-success" aria-hidden="true"></span>
                </button>
                <button type="button" id="managementMenuButton" class="inline-flex min-h-9 items-center gap-2 rounded-lg border border-border-default px-2.5 text-xs font-semibold text-text-primary hover:bg-brand-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 lg:hidden" aria-controls="managementNavigation" aria-expanded="false">
                    <i class="fa-solid fa-bars" aria-hidden="true"></i> Menu
                </button>
            </div>
        </div>

        <%-- Notification Panel Flyout --%>
        <section id="notificationPanel" data-notification-url="${pageContext.request.contextPath}/notifications" class="hidden absolute left-4 right-4 top-16 overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-xl lg:left-full lg:right-auto lg:top-4 lg:ml-2 lg:w-80 z-50" aria-labelledby="notificationHeading" tabindex="-1">
            <div class="flex items-center justify-between gap-4 border-b border-border-default px-4 py-3 bg-surface">
                <h2 id="notificationHeading" class="text-xs font-bold text-text-primary uppercase tracking-wider">Notifications</h2>
                <button type="button" id="notificationReadAll" disabled class="inline-flex items-center gap-1 rounded-lg px-2 py-1 text-xs font-medium text-text-secondary hover:bg-brand-50 hover:text-brand-700 disabled:cursor-not-allowed disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                    <i class="fa-solid fa-check-double text-[11px]" aria-hidden="true"></i> Mark all read
                </button>
            </div>
            <div class="max-h-80 overflow-y-auto divide-y divide-border-default">
                <p id="notificationStatus" class="hidden px-4 py-6 text-xs text-text-secondary text-center" role="status" aria-live="polite"></p>
                <button type="button" id="notificationRetry" class="hidden mx-4 mb-3 rounded-lg px-3 py-1.5 text-xs font-semibold text-brand-700 hover:bg-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Retry</button>
                <ul id="notificationList" class="divide-y divide-border-default" aria-label="Notification list"></ul>
                <p id="notificationLimitNote" class="hidden border-t border-border-default px-4 py-2.5 text-[11px] text-text-secondary text-center">Showing 20 most recent notifications.</p>
            </div>
        </section>

        <%-- Vertical Navigation Links --%>
        <nav id="managementNavigation" class="hidden px-3 py-4 space-y-5 lg:block" aria-label="Management navigation">
            
            <%-- Group 1: Workspace & Dashboard (All 3 Roles) --%>
            <div>
                <p class="px-3 mb-1.5 text-[11px] font-bold uppercase tracking-wider text-text-secondary opacity-75">Workspace</p>
                <a href="${pageContext.request.contextPath}${isExpert ? '/expert/dashboard' : isManager ? '/manager/dashboard' : '/admin/dashboard'}" 
                   class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'dashboard' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                   aria-current="${param.activeSection eq 'dashboard' ? 'page' : 'false'}">
                    <i class="fa-solid fa-gauge-high w-5 text-center text-sm" aria-hidden="true"></i>
                    <span>Dashboard</span>
                </a>
            </div>

            <%-- Group 2: Content & Training (Expert & Manager only) --%>
            <c:if test="${isExpert or isManager}">
                <div>
                    <p class="px-3 mb-1.5 text-[11px] font-bold uppercase tracking-wider text-text-secondary opacity-75">Content &amp; Training</p>
                    <div class="space-y-0.5">
                        <%-- Course management (Manager only) --%>
                        <c:if test="${isManager}">
                            <a href="${pageContext.request.contextPath}/admin/courses" 
                               class="flex items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'courses' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                               aria-current="${param.activeSection eq 'courses' ? 'page' : 'false'}">
                                <span class="flex items-center gap-3">
                                    <i class="fa-solid fa-book-open w-5 text-center text-sm" aria-hidden="true"></i>
                                    <span>Course management</span>
                                </span>
                            </a>
                        </c:if>

                        <%-- Expert-only items --%>
                        <c:if test="${isExpert}">
                            <c:set var="targetCourseId" value="${not empty param.courseId ? param.courseId : (not empty courseId ? courseId : (not empty course.id ? course.id : ''))}" />
                            <c:set var="courseQuery" value="${not empty targetCourseId ? '?courseId='.concat(targetCourseId) : ''}" />

                            <a href="${pageContext.request.contextPath}/lessons/manage${courseQuery}" 
                               class="flex items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'lessons' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                               aria-current="${param.activeSection eq 'lessons' ? 'page' : 'false'}">
                                <span class="flex items-center gap-3">
                                    <i class="fa-solid fa-layer-group w-5 text-center text-sm" aria-hidden="true"></i>
                                    <span>Lesson management</span>
                                </span>
                            </a>
                            <a href="${pageContext.request.contextPath}/questions/manage${courseQuery}" 
                               class="flex items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'questions' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                               aria-current="${param.activeSection eq 'questions' ? 'page' : 'false'}">
                                <span class="flex items-center gap-3">
                                    <i class="fa-solid fa-clipboard-question w-5 text-center text-sm" aria-hidden="true"></i>
                                    <span>Question bank</span>
                                </span>
                            </a>
                            <a href="${pageContext.request.contextPath}/quiz/manage${courseQuery}" 
                               class="flex items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'quiz' || param.activeSection eq 'quizzes' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                               aria-current="${param.activeSection eq 'quiz' || param.activeSection eq 'quizzes' ? 'page' : 'false'}">
                                <span class="flex items-center gap-3">
                                    <i class="fa-solid fa-list-check w-5 text-center text-sm" aria-hidden="true"></i>
                                    <span>Quizzes &amp; Exams</span>
                                </span>
                            </a>
                        </c:if>

                        <%-- Manager-only: Lesson review --%>
                        <c:if test="${isManager}">
                            <a href="${pageContext.request.contextPath}/admin/lesson-review" 
                               class="flex items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'review' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                               aria-current="${param.activeSection eq 'review' ? 'page' : 'false'}">
                                <span class="flex items-center gap-3">
                                    <i class="fa-solid fa-file-circle-check w-5 text-center text-sm" aria-hidden="true"></i>
                                    <span>Lesson review</span>
                                </span>
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:if>

            <%-- Group 3: System Administration (Admin only) --%>
            <c:if test="${isAdmin}">
                <div>
                    <p class="px-3 mb-1.5 text-[11px] font-bold uppercase tracking-wider text-text-secondary opacity-75">System</p>
                    <div class="space-y-0.5">
                        <a href="${pageContext.request.contextPath}/admin/users" 
                           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'users' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                           aria-current="${param.activeSection eq 'users' ? 'page' : 'false'}">
                            <i class="fa-solid fa-users w-5 text-center text-sm" aria-hidden="true"></i>
                            <span>User management</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/settings" 
                           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 ${param.activeSection eq 'settings' ? 'bg-brand-50 text-brand-900 font-semibold border-r-4 border-brand-700' : 'text-text-secondary hover:bg-brand-50 hover:text-brand-700'}" 
                           aria-current="${param.activeSection eq 'settings' ? 'page' : 'false'}">
                            <i class="fa-solid fa-sliders w-5 text-center text-sm" aria-hidden="true"></i>
                            <span>System settings</span>
                        </a>
                    </div>
                </div>
            </c:if>

        </nav>
    </div>

    <%-- Footer: Compact User Profile & Quick Actions --%>
    <div class="border-t border-border-default p-3 bg-surface-card">
        <%-- User info --%>
        <div class="flex items-center gap-2.5 mb-2 px-1">
            <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-brand-50 text-brand-700 font-bold text-xs border border-brand-100">
                <c:out value="${empty sessionScope.currentUser.fullName ? 'LH' : fn:substring(sessionScope.currentUser.fullName, 0, 2)}" />
            </div>
            <div class="min-w-0 flex-1">
                <div class="flex items-center gap-1.5">
                    <p class="truncate text-xs font-bold text-text-primary"><c:out value="${sessionScope.currentUser.username}" /></p>
                    <span class="px-1.5 py-0.2 rounded-full text-[10px] font-semibold bg-brand-50 text-brand-700 border border-brand-100">
                        <c:choose>
                            <c:when test="${isAdmin}">Admin</c:when>
                            <c:when test="${isManager}">Manager</c:when>
                            <c:when test="${isExpert}">Expert</c:when>
                            <c:otherwise>Staff</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <p class="truncate text-[11px] text-text-secondary"><c:out value="${sessionScope.currentUser.email}" /></p>
            </div>
        </div>

        <%-- 3 quick action buttons in a row --%>
        <div class="grid grid-cols-3 gap-1 pt-2 border-t border-border-default/70">
            <a href="${pageContext.request.contextPath}/home" 
               class="inline-flex items-center justify-center gap-1 rounded-lg py-1.5 px-1 text-[11px] font-medium text-text-secondary hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 transition" 
               title="Back to LearnHub">
                <i class="fa-solid fa-house text-[10px]" aria-hidden="true"></i>
                <span>Home</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" 
               class="inline-flex items-center justify-center gap-1 rounded-lg py-1.5 px-1 text-[11px] font-medium text-text-secondary hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 transition" 
               title="My profile">
                <i class="fa-regular fa-user text-[10px]" aria-hidden="true"></i>
                <span>Profile</span>
            </a>
            <a href="${pageContext.request.contextPath}/auth/logout" 
               class="inline-flex items-center justify-center gap-1 rounded-lg py-1.5 px-1 text-[11px] font-medium text-status-danger hover:bg-red-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 transition" 
               title="Sign out">
                <i class="fa-solid fa-arrow-right-from-bracket text-[10px]" aria-hidden="true"></i>
                <span>Sign out</span>
            </a>
        </div>
    </div>
</aside>

<%-- Mobile Drawer & Notifications Script --%>
<script>
    (function () {
        const button = document.getElementById('managementMenuButton');
        const navigation = document.getElementById('managementNavigation');
        if (!button || !navigation) return;
        button.addEventListener('click', function () {
            const expanded = button.getAttribute('aria-expanded') === 'true';
            button.setAttribute('aria-expanded', String(!expanded));
            navigation.classList.toggle('hidden', expanded);
        });
    })();
</script>
<script src="${pageContext.request.contextPath}/assets/js/notifications.js" defer></script>
