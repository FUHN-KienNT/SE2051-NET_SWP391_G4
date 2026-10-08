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

            <nav class="space-y-1.5 text-sm font-medium">
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-indigo-600 text-white font-bold shadow-md shadow-indigo-600/30 transition-all">
                    <i class="fa-solid fa-gauge-high w-5 text-center text-white"></i>
                    <span>Dashboard</span>
                </a>

                <c:if test="${sessionScope.userRole eq 'manager' || sessionScope.userRole eq 'ROLE_MANAGER'}">
                    <a href="${pageContext.request.contextPath}/admin/courses"
                       class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                        <i class="fa-solid fa-book-open w-5 text-center text-slate-400"></i>
                        <span>Course Management</span>
                    </a>
                </c:if>

                <c:if test="${sessionScope.userRole eq 'admin' || sessionScope.userRole eq 'ROLE_ADMIN'}">
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
                </c:if>
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
                                <p class="text-slate-500 text-sm mt-1">Tổng quan về số lượng người dùng và hệ thống</p>
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
                            <div class="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center text-xl font-bold">
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
                            <div class="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center text-xl font-bold">
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
                            <a href="${pageContext.request.contextPath}/admin/courses" class="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg text-sm transition">
                                <i class="fa-solid fa-arrow-right"></i>
                                Đi tới Quản lý khóa học
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Admin Metrics -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                        <!-- Card 1 -->
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
                        
                        <!-- Card 2 -->
                        <div class="bg-white rounded-[16px] border border-slate-100 p-5 shadow-sm flex flex-col justify-between h-28 relative">
                            <p class="text-[11px] font-bold uppercase text-[#94a3b8] tracking-wider">TOTAL ENROLLMENTS</p>
                            <div class="flex items-end justify-between mt-auto">
                                <h3 class="text-3xl font-bold text-[#1e293b]">
                                    <fmt:formatNumber value="${dashboard.totalEnrollments != null ? dashboard.totalEnrollments : 0}" type="number"/>
                                </h3>
                                <span class="bg-[#dcfce7] text-[#166534] rounded-full px-2.5 py-0.5 text-[10px] font-bold mb-1">
                                    +<fmt:formatNumber value="${dashboard.enrollmentGrowthPct != null ? dashboard.enrollmentGrowthPct : 0}" type="number" maxFractionDigits="0"/>%
                                </span>
                            </div>
                        </div>

                        <!-- Card 3 -->
                        <div class="bg-white rounded-[16px] border border-slate-100 p-5 shadow-sm flex flex-col justify-between h-28 relative">
                            <p class="text-[11px] font-bold uppercase text-[#94a3b8] tracking-wider">MONTHLY REVENUE</p>
                            <div class="flex items-end justify-between mt-auto">
                                <h3 class="text-3xl font-bold text-[#1e293b] flex items-end gap-1">
                                    <fmt:formatNumber value="${dashboard.monthlyRevenue != null ? dashboard.monthlyRevenue : 0}" pattern="#,###"/> <span class="text-2xl underline decoration-2 underline-offset-4">đ</span>
                                </h3>
                                <span class="bg-[#dcfce7] text-[#166534] rounded-full px-2.5 py-0.5 text-[10px] font-bold mb-1">+15%</span>
                            </div>
                        </div>

                        <!-- Card 4 -->
                        <div class="bg-white rounded-[16px] border border-slate-100 p-5 shadow-sm flex flex-col justify-between h-28 relative">
                            <p class="text-[11px] font-bold uppercase text-[#94a3b8] tracking-wider">SYSTEM SETTING</p>
                            <div class="flex items-end justify-between mt-auto">
                                <h3 class="text-xl font-bold text-[#1e293b] flex items-center gap-2">
                                    <span class="w-2.5 h-2.5 rounded-full bg-emerald-500"></span> Stable
                                </h3>
                                <a href="${pageContext.request.contextPath}/admin/settings" class="bg-[#f1f5f9] hover:bg-[#e2e8f0] text-[#475569] rounded-full px-3 py-1 text-[11px] font-bold mb-0.5 transition flex items-center gap-1">
                                    View <i class="fa-solid fa-arrow-right text-[9px]"></i>
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
                        <div class="p-4 sm:p-6 border-b border-slate-100 flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                            <h2 class="font-bold text-slate-800 text-lg min-w-0">Quản lý nhanh (Quick Access)</h2>
                            <div class="relative w-full lg:max-w-xs">
                                <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                    <i class="fa-solid fa-magnifying-glass text-sm"></i>
                                </div>
                                <input type="text"
                                       placeholder="Tìm kiếm nhanh..."
                                       class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all">
                            </div>
                        </div>
                        <div class="overflow-x-auto p-8 text-center text-slate-500 text-sm py-12">
                            <i class="fa-solid fa-users text-4xl text-slate-300 mb-3 block"></i>
                            <p class="mb-4">Truy cập vào trang quản lý người dùng để xem danh sách chi tiết.</p>
                            <a href="${pageContext.request.contextPath}/admin/users" class="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg text-sm transition">
                                <i class="fa-solid fa-arrow-right"></i>
                                Đi tới Quản lý người dùng
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
