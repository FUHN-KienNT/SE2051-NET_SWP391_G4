<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<%-- ── Extra styles scoped to this page ──────────────────────────────────── --%>
<style>
    .dash-card {
        transition: transform 0.18s ease, box-shadow 0.18s ease;
        cursor: pointer;
    }
    .dash-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 12px 28px -8px rgba(0,0,0,0.12);
    }
    .badge-success { background: #d1fae5; color: #065f46; }
    .badge-failed  { background: #fee2e2; color: #991b1b; }
    .badge-warning { background: #fef3c7; color: #92400e; }
    .badge-info    { background: #dbeafe; color: #1e40af; }
    .filter-btn {
        padding: 6px 18px;
        border-radius: 9999px;
        font-size: 0.8rem;
        font-weight: 600;
        border: 1.5px solid #e2e8f0;
        cursor: pointer;
        transition: all 0.15s;
        background: white;
        color: #475569;
    }
    .filter-btn.active {
        background: #059669;
        color: white;
        border-color: #059669;
    }
    .filter-btn:hover:not(.active) {
        background: #f1f5f9;
    }
    .quick-action-btn {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 14px 20px;
        border-radius: 14px;
        border: 1.5px solid #e2e8f0;
        background: white;
        cursor: pointer;
        font-weight: 600;
        font-size: 0.875rem;
        color: #1e293b;
        text-decoration: none;
        transition: all 0.16s;
    }
    .quick-action-btn:hover {
        border-color: #059669;
        background: #f0fdf4;
        color: #059669;
    }
    .quick-action-btn .qa-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
    }
    .growth-up   { color: #059669; }
    .growth-down { color: #dc2626; }
    .growth-flat { color: #94a3b8; }
</style>

<main class="flex-grow py-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">

    <%-- ── Page Header ───────────────────────────────────────────────────────── --%>
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <div>
            <h1 class="text-3xl font-black text-slate-900">Admin Dashboard</h1>
            <p class="text-slate-500 mt-1 text-sm">Overview of system metrics and recent activities</p>
        </div>

        <%-- ── Date Range Filter ─────────────────────────────────────────────── --%>
        <div class="flex items-center gap-2 bg-white border border-slate-200 rounded-full px-3 py-1.5 shadow-sm">
            <i class="fa-regular fa-calendar text-slate-400 text-sm"></i>
            <a href="?dateRange=today"
               class="filter-btn ${dashboard.dateRange eq 'today' ? 'active' : ''}">Today</a>
            <a href="?dateRange=week"
               class="filter-btn ${dashboard.dateRange eq 'week'  ? 'active' : ''}">Last 7 Days</a>
            <a href="?dateRange=month"
               class="filter-btn ${dashboard.dateRange eq 'month' ? 'active' : ''}">This Month</a>
        </div>
    </div>

    <%-- ── Metric Cards ───────────────────────────────────────────────────────── --%>
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5 mb-8">

        <%-- Total Users Card --%>
        <a href="${pageContext.request.contextPath}/admin/users"
           class="dash-card bg-white rounded-2xl border border-slate-200 shadow-sm p-5 block no-underline">
            <div class="flex items-start justify-between mb-3">
                <span class="text-xs font-bold uppercase tracking-widest text-slate-400">Total Users</span>
                <span class="w-9 h-9 rounded-xl bg-violet-50 flex items-center justify-center">
                    <i class="fa-solid fa-users text-violet-500 text-sm"></i>
                </span>
            </div>
            <div class="text-3xl font-black text-slate-900">${dashboard.totalUsers}</div>
            <div class="mt-2 text-xs flex items-center gap-1">
                <c:choose>
                    <c:when test="${dashboard.userGrowthPct == null}">
                        <span class="growth-flat">—</span>
                        <span class="text-slate-400">No baseline data</span>
                    </c:when>
                    <c:when test="${dashboard.userGrowthPct >= 0}">
                        <i class="fa-solid fa-arrow-trend-up growth-up"></i>
                        <span class="growth-up font-semibold">+<fmt:formatNumber value="${dashboard.userGrowthPct}" maxFractionDigits="1"/>%</span>
                        <span class="text-slate-400">vs previous period</span>
                    </c:when>
                    <c:otherwise>
                        <i class="fa-solid fa-arrow-trend-down growth-down"></i>
                        <span class="growth-down font-semibold"><fmt:formatNumber value="${dashboard.userGrowthPct}" maxFractionDigits="1"/>%</span>
                        <span class="text-slate-400">vs previous period</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="mt-1 text-xs text-slate-400">${dashboard.activeUsers} active accounts</div>
        </a>

        <%-- Active Courses Card --%>
        <a href="${pageContext.request.contextPath}/courses"
           class="dash-card bg-white rounded-2xl border border-slate-200 shadow-sm p-5 block no-underline">
            <div class="flex items-start justify-between mb-3">
                <span class="text-xs font-bold uppercase tracking-widest text-slate-400">Active Courses</span>
                <span class="w-9 h-9 rounded-xl bg-emerald-50 flex items-center justify-center">
                    <i class="fa-solid fa-book-open text-emerald-500 text-sm"></i>
                </span>
            </div>
            <div class="text-3xl font-black text-slate-900">${dashboard.activeCourses}</div>
            <div class="mt-2 text-xs flex items-center gap-1 text-slate-400">
                <i class="fa-solid fa-circle-check text-emerald-400"></i>
                Published &amp; live on platform
            </div>
            <c:if test="${dashboard.pendingRegistrations > 0}">
                <div class="mt-1 text-xs text-amber-600 font-semibold">
                    <i class="fa-solid fa-clock"></i>
                    ${dashboard.pendingRegistrations} pending registration(s)
                </div>
            </c:if>
        </a>

        <%-- Total Enrollments Card --%>
        <a href="${pageContext.request.contextPath}/admin/users"
           class="dash-card bg-white rounded-2xl border border-slate-200 shadow-sm p-5 block no-underline">
            <div class="flex items-start justify-between mb-3">
                <span class="text-xs font-bold uppercase tracking-widest text-slate-400">Total Enrollments</span>
                <span class="w-9 h-9 rounded-xl bg-sky-50 flex items-center justify-center">
                    <i class="fa-solid fa-graduation-cap text-sky-500 text-sm"></i>
                </span>
            </div>
            <div class="text-3xl font-black text-slate-900">${dashboard.totalEnrollments}</div>
            <div class="mt-2 text-xs flex items-center gap-1">
                <c:choose>
                    <c:when test="${dashboard.enrollmentGrowthPct == null}">
                        <span class="growth-flat">—</span>
                        <span class="text-slate-400">No baseline data</span>
                    </c:when>
                    <c:when test="${dashboard.enrollmentGrowthPct >= 0}">
                        <i class="fa-solid fa-arrow-trend-up growth-up"></i>
                        <span class="growth-up font-semibold">+<fmt:formatNumber value="${dashboard.enrollmentGrowthPct}" maxFractionDigits="1"/>%</span>
                        <span class="text-slate-400">vs previous period</span>
                    </c:when>
                    <c:otherwise>
                        <i class="fa-solid fa-arrow-trend-down growth-down"></i>
                        <span class="growth-down font-semibold"><fmt:formatNumber value="${dashboard.enrollmentGrowthPct}" maxFractionDigits="1"/>%</span>
                        <span class="text-slate-400">vs previous period</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </a>

        <%-- Monthly Revenue Card --%>
        <div class="dash-card bg-gradient-to-br from-emerald-500 to-teal-600 rounded-2xl shadow-sm p-5 text-white">
            <div class="flex items-start justify-between mb-3">
                <span class="text-xs font-bold uppercase tracking-widest text-emerald-100">
                    <c:choose>
                        <c:when test="${dashboard.dateRange eq 'today'}">Today's</c:when>
                        <c:when test="${dashboard.dateRange eq 'week'}">Weekly</c:when>
                        <c:otherwise>Monthly</c:otherwise>
                    </c:choose>
                    Revenue
                </span>
                <span class="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center">
                    <i class="fa-solid fa-circle-dollar-to-slot text-white text-sm"></i>
                </span>
            </div>
            <div class="text-3xl font-black">
                <fmt:formatNumber value="${dashboard.monthlyRevenue}" type="number" maxFractionDigits="0"/>
                <span class="text-emerald-100 text-xl"> ₫</span>
            </div>
            <div class="mt-2 text-xs text-emerald-100">
                <i class="fa-solid fa-wallet"></i>
                Paid registrations only
            </div>
        </div>
    </div>

    <%-- ── Main Content Grid ────────────────────────────────────────────────── --%>
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">

        <%-- ── Recent Audit Logs (spans 2 columns) ──────────────────────────── --%>
        <div class="xl:col-span-2 bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div class="flex items-center gap-2">
                    <i class="fa-solid fa-shield-halved text-slate-400"></i>
                    <h2 class="font-bold text-slate-800">Recent Audit Logs</h2>
                </div>
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="text-xs font-semibold text-emerald-600 hover:text-emerald-700 transition-colors">
                    View All Logs →
                </a>
            </div>

            <c:choose>
                <c:when test="${empty dashboard.recentLogs}">
                    <div class="flex flex-col items-center justify-center py-16 text-slate-400">
                        <i class="fa-regular fa-folder-open text-4xl mb-3"></i>
                        <p class="text-sm font-medium">No audit log entries yet.</p>
                        <p class="text-xs mt-1">System events will appear here as they occur.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm text-left">
                            <thead class="bg-slate-50 text-slate-500 uppercase text-xs font-bold border-b border-slate-100">
                                <tr>
                                    <th class="px-5 py-3">Timestamp</th>
                                    <th class="px-5 py-3">Actor</th>
                                    <th class="px-5 py-3">Action</th>
                                    <th class="px-5 py-3 text-center">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-50">
                                <c:forEach var="log" items="${dashboard.recentLogs}">
                                    <tr class="hover:bg-slate-50/60 transition-colors">
                                        <td class="px-5 py-3 text-slate-400 font-mono whitespace-nowrap text-xs">
                                            <fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                        </td>
                                        <td class="px-5 py-3 font-medium text-slate-700 max-w-[140px] truncate">
                                            <c:choose>
                                                <c:when test="${not empty log.actor}">${log.actor}</c:when>
                                                <c:otherwise><span class="text-slate-300 italic">System</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="px-5 py-3 text-slate-600 max-w-xs truncate">
                                            <c:if test="${not empty log.description}">
                                                <span title="${log.description}">${log.description}</span>
                                            </c:if>
                                            <c:if test="${empty log.description}">
                                                <span class="text-slate-400">${log.actionType}</span>
                                            </c:if>
                                        </td>
                                        <td class="px-5 py-3 text-center">
                                            <c:choose>
                                                <c:when test="${log.status eq 'SUCCESS'}">
                                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold badge-success">
                                                        <i class="fa-solid fa-circle-check text-[10px]"></i> SUCCESS
                                                    </span>
                                                </c:when>
                                                <c:when test="${log.status eq 'FAILED'}">
                                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold badge-failed">
                                                        <i class="fa-solid fa-circle-xmark text-[10px]"></i> FAILED
                                                    </span>
                                                </c:when>
                                                <c:when test="${log.status eq 'WARNING'}">
                                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold badge-warning">
                                                        <i class="fa-solid fa-triangle-exclamation text-[10px]"></i> WARNING
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold badge-info">
                                                        <i class="fa-solid fa-circle-info text-[10px]"></i> ${log.status}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- ── Right Column: Quick Actions + Stats Summary ───────────────────── --%>
        <div class="flex flex-col gap-5">

            <%-- Quick Actions Panel --%>
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
                <div class="flex items-center gap-2 mb-4">
                    <i class="fa-solid fa-bolt text-amber-400"></i>
                    <h2 class="font-bold text-slate-800">Quick Actions</h2>
                </div>
                <div class="flex flex-col gap-3">
                    <a href="${pageContext.request.contextPath}/expert/courses?action=new"
                       id="qa-new-course"
                       class="quick-action-btn">
                        <span class="qa-icon bg-emerald-50">
                            <i class="fa-solid fa-plus text-emerald-600"></i>
                        </span>
                        <div>
                            <div>Create New Course</div>
                            <div class="text-xs text-slate-400 font-normal">Publish a new learning course</div>
                        </div>
                        <i class="fa-solid fa-chevron-right ml-auto text-slate-300 text-xs"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/users"
                       id="qa-manage-users"
                       class="quick-action-btn">
                        <span class="qa-icon bg-violet-50">
                            <i class="fa-solid fa-users-gear text-violet-600"></i>
                        </span>
                        <div>
                            <div>Manage Users</div>
                            <div class="text-xs text-slate-400 font-normal">
                                Review pending requests
                                <c:if test="${dashboard.pendingRegistrations > 0}">
                                    &nbsp;<span class="inline-block px-1.5 py-0.5 bg-amber-100 text-amber-700 rounded-full text-[10px] font-bold">
                                        ${dashboard.pendingRegistrations}
                                    </span>
                                </c:if>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right ml-auto text-slate-300 text-xs"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                       id="qa-system-settings"
                       class="quick-action-btn">
                        <span class="qa-icon bg-slate-50">
                            <i class="fa-solid fa-gear text-slate-500"></i>
                        </span>
                        <div>
                            <div>System Settings</div>
                            <div class="text-xs text-slate-400 font-normal">Configure platform options</div>
                        </div>
                        <i class="fa-solid fa-chevron-right ml-auto text-slate-300 text-xs"></i>
                    </a>
                </div>
            </div>

            <%-- System Summary Panel --%>
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
                <div class="flex items-center gap-2 mb-4">
                    <i class="fa-solid fa-chart-pie text-sky-400"></i>
                    <h2 class="font-bold text-slate-800">System Summary</h2>
                </div>
                <ul class="space-y-3">
                    <li class="flex items-center justify-between text-sm">
                        <span class="flex items-center gap-2 text-slate-500">
                            <i class="fa-solid fa-user-check w-4 text-emerald-500"></i>
                            Active Users
                        </span>
                        <span class="font-bold text-slate-800">${dashboard.activeUsers}</span>
                    </li>
                    <li class="flex items-center justify-between text-sm">
                        <span class="flex items-center gap-2 text-slate-500">
                            <i class="fa-solid fa-users w-4 text-violet-500"></i>
                            Total Accounts
                        </span>
                        <span class="font-bold text-slate-800">${dashboard.totalUsers}</span>
                    </li>
                    <li class="flex items-center justify-between text-sm">
                        <span class="flex items-center gap-2 text-slate-500">
                            <i class="fa-solid fa-book w-4 text-sky-500"></i>
                            Published Courses
                        </span>
                        <span class="font-bold text-slate-800">${dashboard.activeCourses}</span>
                    </li>
                    <li class="flex items-center justify-between text-sm">
                        <span class="flex items-center gap-2 text-slate-500">
                            <i class="fa-solid fa-graduation-cap w-4 text-teal-500"></i>
                            All Enrollments
                        </span>
                        <span class="font-bold text-slate-800">${dashboard.totalEnrollments}</span>
                    </li>
                    <c:if test="${dashboard.pendingRegistrations > 0}">
                        <li class="flex items-center justify-between text-sm pt-2 border-t border-slate-100">
                            <span class="flex items-center gap-2 text-amber-600 font-semibold">
                                <i class="fa-solid fa-clock w-4"></i>
                                Pending Payments
                            </span>
                            <span class="font-bold text-amber-600">${dashboard.pendingRegistrations}</span>
                        </li>
                    </c:if>
                </ul>
            </div>

        </div>
    </div>

</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
