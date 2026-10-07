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
                        <h1 class="text-2xl sm:text-3xl font-bold text-slate-800 tracking-tight">Assigned Courses</h1>
                        <p class="text-slate-500 text-sm mt-1">Danh sách các khóa học được phân công xây dựng nội dung bài giảng & đề thi</p>
                    </div>
                </div>
            </div>

            <!-- Stats Quick Cards -->
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                <div class="bg-white p-6 rounded-xl border border-slate-100 shadow-sm flex items-center space-x-4">
                    <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl font-bold">
                        <i class="fa-solid fa-graduation-cap"></i>
                    </div>
                    <div>
                        <p class="text-xs font-semibold uppercase text-slate-500">KHÓA HỌC ĐƯỢC GIAO</p>
                        <h3 class="text-2xl font-bold text-slate-800">3</h3>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-xl border border-slate-100 shadow-sm flex items-center space-x-4">
                    <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl font-bold">
                        <i class="fa-solid fa-folder-tree"></i>
                    </div>
                    <div>
                        <p class="text-xs font-semibold uppercase text-slate-500">TRẠNG THÁI HỆ THỐNG</p>
                        <h3 class="text-2xl font-bold text-emerald-600">Đang hoạt động</h3>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-xl border border-slate-100 shadow-sm flex items-center space-x-4">
                    <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl font-bold">
                        <i class="fa-solid fa-chalkboard-user"></i>
                    </div>
                    <div>
                        <p class="text-xs font-semibold uppercase text-slate-500">PHÂN QUYỀN</p>
                        <h3 class="text-xl font-bold text-slate-800">Subject Expert</h3>
                    </div>
                </div>
            </div>



            <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
                <div class="p-4 sm:p-6 border-b border-slate-100 flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                    <h2 class="font-bold text-slate-800 text-lg min-w-0">Danh Sách Khóa Học (Assigned Courses)</h2>
                    <div class="relative w-full lg:max-w-xs">
                        <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                            <i class="fa-solid fa-magnifying-glass text-sm"></i>
                        </div>
                        <input type="text"
                               id="courseSearchInput"
                               placeholder="Search courses..."
                               class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all">
                    </div>
                </div>
                <div class="overflow-x-auto p-4 text-center text-slate-500 text-sm py-10">
                    <p>No courses available to display.</p>
                </div>
            </div>

        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
