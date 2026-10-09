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
                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="px-6 py-3">
                                            <div class="flex items-center space-x-3">
                                                <div class="w-8 h-8 rounded-full bg-[#e8f5e9] text-[#047857] flex items-center justify-center font-bold text-xs">N</div>
                                                <div>
                                                    <div class="font-bold text-slate-900">Nguyễn Văn A</div>
                                                    <div class="text-xs text-slate-500">nguyenvana@gmail.com</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="px-6 py-3">
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-bold bg-slate-100 text-slate-600">Student</span>
                                        </td>
                                        <td class="px-6 py-3">
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-[#e8f5e9] text-[#2e7d32]">
                                                <span class="w-1.5 h-1.5 rounded-full bg-[#2e7d32]"></span> Active
                                            </span>
                                        </td>
                                    </tr>
                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="px-6 py-3">
                                            <div class="flex items-center space-x-3">
                                                <div class="w-8 h-8 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center font-bold text-xs">T</div>
                                                <div>
                                                    <div class="font-bold text-slate-900">Trần Thị B</div>
                                                    <div class="text-xs text-slate-500">tranthib@learnhub.com</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="px-6 py-3">
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-bold bg-amber-50 text-amber-700">Manager</span>
                                        </td>
                                        <td class="px-6 py-3">
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-[#e8f5e9] text-[#2e7d32]">
                                                <span class="w-1.5 h-1.5 rounded-full bg-[#2e7d32]"></span> Active
                                            </span>
                                        </td>
                                    </tr>
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
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                    datasets: [{
                        label: 'Revenue (VND)',
                        data: [15000000, 22000000, 18000000, 29000000, 34000000, 42500000],
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
                    labels: ['Python', 'Java', 'Web Dev', 'Data Sci', 'UI/UX'],
                    datasets: [{
                        label: 'Enrollments',
                        data: [320, 210, 180, 95, 49],
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
