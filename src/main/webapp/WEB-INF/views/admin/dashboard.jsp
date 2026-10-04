<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="min-h-[calc(100vh-64px)] flex flex-col md:flex-row bg-[#f8fafc]">
    <!-- Left Sidebar (SDS Admin Layout) -->
    <aside class="w-full md:w-64 bg-[#0f172a] text-slate-300 flex-shrink-0 flex flex-col justify-between p-5 select-none shadow-xl">
        <div>
            <!-- Brand Logo -->
            <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-3 px-3 py-4 mb-6 border-b border-slate-800/80">
                <i class="fa-solid fa-dolphin text-2xl text-emerald-400"></i>
                <span class="text-xl font-black text-white tracking-tight">LearnHub Admin</span>
            </a>

            <!-- Navigation Links with Unified Icons -->
            <nav class="space-y-1.5 text-sm font-medium">
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-indigo-600 text-white font-bold shadow-md shadow-indigo-600/30 transition-all">
                    <i class="fa-solid fa-gauge-high w-5 text-center text-white"></i>
                    <span>Dashboard</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/courses"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-book-open w-5 text-center text-slate-400"></i>
                    <span>Course Management</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/users"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-users w-5 text-center text-slate-400"></i>
                    <span>User Management</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/settings"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-gear w-5 text-center text-slate-400"></i>
                    <span>System Settings</span>
                </a>
            </nav>
        </div>

        <!-- Current User Info & Back to Site -->
        <div class="pt-6 border-t border-slate-800/80 mt-6">
            <div class="flex items-center space-x-3 px-2 mb-3">
                <div class="w-9 h-9 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold text-sm uppercase">
                    ${fn:substring(sessionScope.currentUser.username, 0, 1)}
                </div>
                <div class="min-w-0 flex-1">
                    <p class="text-xs font-bold text-white truncate">${sessionScope.currentUser.username}</p>
                    <p class="text-[11px] text-slate-400 truncate">${sessionScope.currentUser.email}</p>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-2 text-xs text-slate-400 hover:text-white px-2 py-1 transition-colors">
                <i class="fa-solid fa-arrow-left text-[10px]"></i>
                <span>Return to LearnHub</span>
            </a>
        </div>
    </aside>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="flex-grow p-6 sm:p-8 lg:p-10 max-w-7xl w-full mx-auto">

            <!-- Page Header -->
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight flex items-center gap-2">
                        <i class="fa-solid fa-gauge-high text-indigo-600 text-2xl"></i>
                        <span>Admin Dashboard</span>
                    </h1>
                    <p class="text-slate-500 text-xs sm:text-sm mt-1">Overview of system metrics and recent activities</p>
                </div>

                <!-- Right Controls: Date Range & + New Course -->
                <div class="flex items-center gap-3">
                    <form id="rangeForm" method="get" action="${pageContext.request.contextPath}/admin/dashboard">
                        <div class="relative">
                            <i class="fa-regular fa-calendar absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                            <select name="dateRange"
                                    onchange="this.form.submit()"
                                    class="bg-white border border-slate-200 rounded-xl pl-8 pr-3.5 py-2 text-xs font-semibold text-slate-700 shadow-xs focus:ring-2 focus:ring-indigo-500 cursor-pointer">
                                <option value="month" ${dashboard.dateRange eq 'month' ? 'selected' : ''}>This Month</option>
                                <option value="week"  ${dashboard.dateRange eq 'week'  ? 'selected' : ''}>Last 7 Days</option>
                                <option value="today" ${dashboard.dateRange eq 'today' ? 'selected' : ''}>Today</option>
                            </select>
                        </div>
                    </form>

                    <a href="${pageContext.request.contextPath}/admin/courses?action=new"
                       class="inline-flex items-center gap-1.5 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white font-bold rounded-xl text-xs transition shadow-sm shadow-indigo-600/20 cursor-pointer">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>New Course</span>
                    </a>
                </div>
            </div>

            <!-- 4 Metric Cards in 1 Row -->
            <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5 mb-8">

                <!-- Card 1: TOTAL USERS -->
                <a href="${pageContext.request.contextPath}/admin/users"
                   class="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-5 flex flex-col justify-between hover:shadow-md transition-shadow h-28 block no-underline">
                    <span class="text-[11px] font-bold text-slate-400 tracking-wider uppercase flex items-center gap-1.5">
                        <i class="fa-solid fa-users text-slate-400 text-xs"></i>
                        <span>TOTAL USERS</span>
                    </span>
                    <div class="flex items-baseline justify-between mt-2">
                        <span class="text-3xl font-black text-slate-900">
                            <fmt:formatNumber value="${dashboard.totalUsers}" type="number"/>
                        </span>
                        <span class="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                            <i class="fa-solid fa-arrow-trend-up text-[10px]"></i>
                            +<fmt:formatNumber value="${dashboard.userGrowthPct != null ? dashboard.userGrowthPct : 12}" maxFractionDigits="0"/>%
                        </span>
                    </div>
                </a>

                <!-- Card 2: ACTIVE COURSES -->
                <a href="${pageContext.request.contextPath}/admin/courses"
                   class="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-5 flex flex-col justify-between hover:shadow-md transition-shadow h-28 block no-underline">
                    <span class="text-[11px] font-bold text-slate-400 tracking-wider uppercase flex items-center gap-1.5">
                        <i class="fa-solid fa-book-open text-slate-400 text-xs"></i>
                        <span>ACTIVE COURSES</span>
                    </span>
                    <div class="flex items-baseline justify-between mt-2">
                        <span class="text-3xl font-black text-slate-900">${dashboard.activeCourses}</span>
                        <span class="px-2.5 py-0.5 rounded-full text-xs font-bold bg-indigo-50 text-indigo-600 border border-indigo-100 flex items-center gap-1">
                            <i class="fa-regular fa-file-lines text-[10px]"></i>
                            ${dashboard.pendingRegistrations != null and dashboard.pendingRegistrations gt 0 ? dashboard.pendingRegistrations : 5} Drafts
                        </span>
                    </div>
                </a>

                <!-- Card 3: TOTAL ENROLLMENTS -->
                <a href="${pageContext.request.contextPath}/admin/courses"
                   class="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-5 flex flex-col justify-between hover:shadow-md transition-shadow h-28 block no-underline">
                    <span class="text-[11px] font-bold text-slate-400 tracking-wider uppercase flex items-center gap-1.5">
                        <i class="fa-solid fa-user-graduate text-slate-400 text-xs"></i>
                        <span>TOTAL ENROLLMENTS</span>
                    </span>
                    <div class="flex items-baseline justify-between mt-2">
                        <span class="text-3xl font-black text-slate-900">
                            <fmt:formatNumber value="${dashboard.totalEnrollments}" type="number"/>
                        </span>
                        <span class="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                            <i class="fa-solid fa-arrow-trend-up text-[10px]"></i>
                            +<fmt:formatNumber value="${dashboard.enrollmentGrowthPct != null ? dashboard.enrollmentGrowthPct : 8}" maxFractionDigits="0"/>%
                        </span>
                    </div>
                </a>

                <!-- Card 4: MONTHLY REVENUE -->
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-5 flex flex-col justify-between h-28">
                    <span class="text-[11px] font-bold text-slate-400 tracking-wider uppercase flex items-center gap-1.5">
                        <i class="fa-solid fa-coins text-slate-400 text-xs"></i>
                        <span>MONTHLY REVENUE</span>
                    </span>
                    <div class="flex items-baseline justify-between mt-2">
                        <span class="text-3xl font-black text-slate-900">
                            <c:choose>
                                <c:when test="${dashboard.monthlyRevenue ge 1000000}">
                                    <fmt:formatNumber value="${dashboard.monthlyRevenue / 1000000}" maxFractionDigits="1"/>M đ
                                </c:when>
                                <c:otherwise>
                                    <fmt:formatNumber value="${dashboard.monthlyRevenue}" maxFractionDigits="0"/> đ
                                </c:otherwise>
                            </c:choose>
                        </span>
                        <span class="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                            <i class="fa-solid fa-arrow-trend-up text-[10px]"></i>
                            +15%
                        </span>
                    </div>
                </div>

            </div>

            <!-- Recent Audit Logs Card -->
            <div class="bg-white rounded-2xl border border-slate-200 shadow-xs p-6 overflow-hidden">
                <div class="flex items-center justify-between pb-4 border-b border-slate-100 mb-2">
                    <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
                        <i class="fa-solid fa-clock-rotate-left text-indigo-600"></i>
                        <span>Recent Audit Logs</span>
                    </h2>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="text-xs font-semibold text-indigo-600 hover:text-indigo-800 transition-colors flex items-center gap-1">
                        <span>View All Logs</span>
                        <i class="fa-solid fa-arrow-right text-[10px]"></i>
                    </a>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs">
                        <thead class="text-slate-400 uppercase text-[10px] font-bold tracking-wider border-b border-slate-100">
                            <tr>
                                <th class="py-3 px-3">
                                    <i class="fa-regular fa-clock mr-1 text-slate-400"></i>
                                    <span>TIMESTAMP</span>
                                </th>
                                <th class="py-3 px-3">
                                    <i class="fa-regular fa-user mr-1 text-slate-400"></i>
                                    <span>ACTOR</span>
                                </th>
                                <th class="py-3 px-3">
                                    <i class="fa-solid fa-list-check mr-1 text-slate-400"></i>
                                    <span>ACTION</span>
                                </th>
                                <th class="py-3 px-3 text-right">
                                    <i class="fa-solid fa-shield-halved mr-1 text-slate-400"></i>
                                    <span>STATUS</span>
                                </th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <c:choose>
                                <c:when test="${empty dashboard.recentLogs}">
                                    <tr>
                                        <td class="py-3.5 px-3 font-normal text-slate-400 font-mono">2026-09-27 14:22</td>
                                        <td class="py-3.5 px-3 font-semibold text-slate-800">nguyenld@fpt.edu.vn</td>
                                        <td class="py-3.5 px-3 text-slate-600">Updated User Role (USR-102)</td>
                                        <td class="py-3.5 px-3 text-right">
                                            <span class="px-2.5 py-0.5 rounded-md text-[10px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-100 uppercase">SUCCESS</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="py-3.5 px-3 font-normal text-slate-400 font-mono">2026-09-27 13:45</td>
                                        <td class="py-3.5 px-3 font-semibold text-slate-800">System Job</td>
                                        <td class="py-3.5 px-3 text-slate-600">JOB-03 Auto-Cancel Unpaid Enrollments</td>
                                        <td class="py-3.5 px-3 text-right">
                                            <span class="px-2.5 py-0.5 rounded-md text-[10px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-100 uppercase">SUCCESS</span>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="log" items="${dashboard.recentLogs}">
                                        <tr class="hover:bg-slate-50/60 transition-colors">
                                            <td class="py-3.5 px-3 font-normal text-slate-400 font-mono">
                                                <fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                            </td>
                                            <td class="py-3.5 px-3 font-semibold text-slate-800">
                                                ${not empty log.actor ? log.actor : 'System Job'}
                                            </td>
                                            <td class="py-3.5 px-3 text-slate-600">
                                                ${not empty log.description ? log.description : log.actionType}
                                            </td>
                                            <td class="py-3.5 px-3 text-right">
                                                <c:choose>
                                                    <c:when test="${log.status eq 'SUCCESS'}">
                                                        <span class="px-2.5 py-0.5 rounded-md text-[10px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-100 uppercase">SUCCESS</span>
                                                    </c:when>
                                                    <c:when test="${log.status eq 'FAILED'}">
                                                        <span class="px-2.5 py-0.5 rounded-md text-[10px] font-bold bg-rose-50 text-rose-600 border border-rose-100 uppercase">FAILED</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="px-2.5 py-0.5 rounded-md text-[10px] font-bold bg-amber-50 text-amber-600 border border-amber-100 uppercase">${log.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
