<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="min-h-[calc(100vh-64px)] flex flex-col md:flex-row bg-[#f8fafc]">
    

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="flex-grow p-6 sm:p-8 lg:p-10 max-w-7xl w-full mx-auto">

            <!-- Page Header -->
            <div class="mb-6">
                <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                    <div>
                        <c:choose>
                            <c:when test="${sessionScope.userRole eq 'manager' || sessionScope.userRole eq 'ROLE_MANAGER'}">
                                <h1 class="text-2xl sm:text-3xl font-bold text-slate-800 tracking-tight">Manager Dashboard</h1>
                                <p class="text-slate-500 text-sm mt-1">Tổng quan về hệ thống khóa học</p>
                            </c:when>
                            <c:otherwise>
                                <h1 class="text-2xl sm:text-3xl font-bold text-slate-800 tracking-tight">Admin Dashboard</h1>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <c:choose>
                <c:when test="${sessionScope.userRole eq 'manager' || sessionScope.userRole eq 'ROLE_MANAGER'}">
                    <!-- Manager Metrics -->
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                        <div class="bg-white p-6 rounded-xl border border-slate-100 shadow-sm flex items-center space-x-4">
                            <div class="w-12 h-12 rounded-xl bg-[#e8f5e9] text-[#047857] flex items-center justify-center text-xl font-bold">
                                <i class="fa-solid fa-book-open"></i>
                            </div>
                            <div>
                                <p class="text-xs font-semibold uppercase text-slate-500">TỔNG SỐ KHÓA HỌC</p>
                                <h3 class="text-2xl font-bold text-slate-800">
                                    <fmt:formatNumber value="${dashboard.activeCourses != null ? dashboard.activeCourses : 0}" type="number"/>
                                </h3>
                            </div>
                        </div>
                        <div class="bg-white p-6 rounded-xl border border-slate-100 shadow-sm flex items-center space-x-4">
                            <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl font-bold">
                                <i class="fa-solid fa-server"></i>
                            </div>
                            <div>
                                <p class="text-xs font-semibold uppercase text-slate-500">TRẠNG THÁI HỆ THỐNG</p>
                                <h3 class="text-2xl font-bold text-emerald-600">Đang hoạt động</h3>
                            </div>
                        </div>
                        <div class="bg-white p-6 rounded-xl border border-slate-100 shadow-sm flex items-center space-x-4">
                            <div class="w-12 h-12 rounded-xl bg-[#e8f5e9] text-[#047857] flex items-center justify-center text-xl font-bold">
                                <i class="fa-solid fa-user-tie"></i>
                            </div>
                            <div>
                                <p class="text-xs font-semibold uppercase text-slate-500">PHÂN QUYỀN</p>
                                <h3 class="text-xl font-bold text-slate-800">Manager</h3>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
                        <div class="p-4 sm:p-6 border-b border-slate-100 flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                            <h2 class="font-bold text-slate-800 text-lg min-w-0">Quản lý nhanh (Quick Access)</h2>
                        </div>
                        <div class="overflow-x-auto p-8 text-center text-slate-500 text-sm py-12">
                            <i class="fa-solid fa-book-open text-4xl text-slate-300 mb-3 block"></i>
                            <p class="mb-4">Truy cập vào trang quản lý khóa học để xem danh sách chi tiết.</p>
                            <a href="${pageContext.request.contextPath}/admin/courses" class="inline-flex items-center gap-2 px-4 py-2 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-lg text-sm transition">
                                <i class="fa-solid fa-arrow-right"></i>
                                Đi tới Quản lý khóa học
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Admin Metrics -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <!-- Card 1: Total Users -->
                        <div class="bg-white rounded-[16px] border border-slate-100 p-5 shadow-sm flex flex-col justify-between h-28 relative">
                            <p class="text-[11px] font-bold uppercase text-[#94a3b8] tracking-wider">TOTAL USERS</p>
                            <div class="flex items-end justify-between mt-auto">
                                <h3 class="text-3xl font-bold text-[#1e293b]">
                                    <fmt:formatNumber value="${dashboard.totalUsers != null ? dashboard.totalUsers : 0}" type="number"/>
                                </h3>
                                <span class="bg-[#dcfce7] text-[#166534] rounded-full px-2.5 py-0.5 text-[10px] font-bold mb-1">
                                    +<fmt:formatNumber value="${dashboard.userGrowthPct != null ? dashboard.userGrowthPct : 0}" type="number" maxFractionDigits="0"/>%
                                </span>
                            </div>
                        </div>

                        <!-- Card 2: System Setting -->
                        <div class="bg-white rounded-[16px] border border-slate-100 p-5 shadow-sm flex flex-col justify-between h-28 relative">
                            <p class="text-[11px] font-bold uppercase text-[#94a3b8] tracking-wider">SYSTEM SETTING</p>
                            <div class="flex items-end justify-between mt-auto">
                                <h3 class="text-xl font-bold text-[#1e293b] flex items-center gap-2">
                                    <span class="w-2.5 h-2.5 rounded-full bg-emerald-500"></span> Stable
                                </h3>
                                <a href="${pageContext.request.contextPath}/admin/settings" class="bg-[#f1f5f9] hover:bg-[#e2e8f0] text-[#475569] rounded-full px-3 py-1 text-[11px] font-bold mb-0.5 transition flex items-center gap-1">
                                    Modify <i class="fa-solid fa-arrow-right text-[9px]"></i>
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Charts Section -->
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                        <!-- Monthly Revenue Chart -->
                        <div class="bg-white rounded-[16px] border border-slate-100 p-5 shadow-sm flex flex-col">
                            <div class="flex items-center justify-between mb-4">
                                <div>
                                    <p class="text-[11px] font-bold uppercase text-[#94a3b8] tracking-wider">MONTHLY REVENUE</p>
                                    <h3 class="text-2xl font-bold text-[#1e293b] flex items-end gap-1">
                                        <fmt:formatNumber value="${dashboard.monthlyRevenue != null ? dashboard.monthlyRevenue : 0}" pattern="#,###"/> <span class="text-sm text-slate-400">VND</span>
                                    </h3>
                                </div>
                                <span class="bg-[#dcfce7] text-[#166534] rounded-full px-2.5 py-0.5 text-[10px] font-bold">+15%</span>
                            </div>
                            <div class="relative flex-1 w-full" style="min-height: 250px;">
                                <canvas id="revenueChart"></canvas>
                            </div>
                        </div>

                        <!-- Total Enrollments Chart -->
                        <div class="bg-white rounded-[16px] border border-slate-100 p-5 shadow-sm flex flex-col">
                            <div class="flex items-center justify-between mb-4">
                                <div>
                                    <p class="text-[11px] font-bold uppercase text-[#94a3b8] tracking-wider">TOTAL ENROLLMENTS</p>
                                    <h3 class="text-2xl font-bold text-[#1e293b]">
                                        <fmt:formatNumber value="${dashboard.totalEnrollments != null ? dashboard.totalEnrollments : 0}" type="number"/>
                                        <span class="text-sm text-slate-400">lượt</span>
                                    </h3>
                                </div>
                                <span class="bg-[#dcfce7] text-[#166534] rounded-full px-2.5 py-0.5 text-[10px] font-bold">+8%</span>
                            </div>
                            <div class="relative flex-1 w-full" style="min-height: 250px;">
                                <canvas id="enrollmentChart"></canvas>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden mb-6">
                        <div class="p-4 sm:p-6 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                            <h2 class="font-bold text-slate-800 text-lg">Quản lý người dùng (Quick Access)</h2>
                            <div class="relative w-full sm:max-w-xs">
                                <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                    <i class="fa-solid fa-magnifying-glass text-sm"></i>
                                </div>
                                <input type="text" placeholder="Tìm kiếm nhanh..." class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#047857] transition-all">
                            </div>
                        </div>
                        
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-sm whitespace-nowrap">
                                <thead class="bg-slate-50 border-b border-slate-100 text-[11px] font-bold text-slate-500 uppercase">
                                    <tr>
                                        <th class="px-6 py-4">User</th>
                                        <th class="px-6 py-4">Role</th>
                                        <th class="px-6 py-4">Status</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100">
                                    <c:if test="${empty dashboard.recentUsers}">
                                        <tr>
                                            <td colspan="3" class="px-6 py-4 text-center text-slate-500 text-sm">Chưa có người dùng nào.</td>
                                        </tr>
                                    </c:if>
                                    <c:forEach var="u" items="${dashboard.recentUsers}">
                                        <tr class="hover:bg-slate-50 transition">
                                            <td class="px-6 py-3">
                                                <div class="flex items-center space-x-3">
                                                    <div class="w-8 h-8 rounded-full bg-[#e8f5e9] text-[#047857] flex items-center justify-center font-bold text-xs uppercase border border-emerald-100">
                                                        ${fn:substring(u.username, 0, 1)}
                                                    </div>
                                                    <div>
                                                        <div class="font-bold text-slate-900">${u.username}</div>
                                                        <div class="text-xs text-slate-500">${u.email}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-3">
                                                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-bold bg-slate-100 text-slate-600">${u.roleName}</span>
                                            </td>
                                            <td class="px-6 py-3">
                                                <c:choose>
                                                    <c:when test="${u.status == 'active'}">
                                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-[#e8f5e9] text-[#2e7d32]">
                                                            <span class="w-1.5 h-1.5 rounded-full bg-[#2e7d32]"></span> Active
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-rose-50 text-rose-700">
                                                            <span class="w-1.5 h-1.5 rounded-full bg-rose-600"></span> ${u.status}
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <div class="p-5 bg-slate-50/50 border-t border-slate-100 flex justify-center">
                            <a href="${pageContext.request.contextPath}/admin/users" class="inline-flex items-center gap-2 px-5 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-lg text-sm transition shadow-sm">
                                <i class="fa-solid fa-users"></i> Đi tới Quản lý người dùng <i class="fa-solid fa-arrow-right ml-1"></i>
                            </a>
                        </div>
                    </div>

                </c:otherwise>
            </c:choose>

        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        if (document.getElementById('revenueChart')) {
            const ctxRev = document.getElementById('revenueChart').getContext('2d');
            new Chart(ctxRev, {
                type: 'line',
                data: {
                    labels: ${dashboard.revenueLabelsJson != null ? dashboard.revenueLabelsJson : "[]"},
                    datasets: [{
                        label: 'Revenue (VND)',
                        data: ${dashboard.revenueDataJson != null ? dashboard.revenueDataJson : "[]"},
                        borderColor: '#047857',
                        backgroundColor: 'rgba(4, 120, 87, 0.1)',
                        borderWidth: 3,
                        tension: 0.4,
                        fill: true,
                        pointBackgroundColor: '#fff',
                        pointBorderColor: '#047857',
                        pointBorderWidth: 2,
                        pointRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, border: {display: false}, grid: {color: '#f1f5f9'} },
                        x: { border: {display: false}, grid: {display: false} }
                    }
                }
            });
        }

        if (document.getElementById('enrollmentChart')) {
            const ctxEnr = document.getElementById('enrollmentChart').getContext('2d');
            new Chart(ctxEnr, {
                type: 'bar',
                data: {
                    labels: ${dashboard.enrollmentLabelsJson != null ? dashboard.enrollmentLabelsJson : "[]"},
                    datasets: [{
                        label: 'Enrollments',
                        data: ${dashboard.enrollmentDataJson != null ? dashboard.enrollmentDataJson : "[]"},
                        backgroundColor: '#10b981',
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, border: {display: false}, grid: {color: '#f1f5f9'} },
                        x: { border: {display: false}, grid: {display: false} }
                    }
                }
            });
        }
    });
</script>

        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
