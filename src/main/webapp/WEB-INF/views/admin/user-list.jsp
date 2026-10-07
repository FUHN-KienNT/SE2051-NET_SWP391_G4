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
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-gauge-high w-5 text-center text-slate-400"></i>
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
                       class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-indigo-600 text-white font-bold shadow-md shadow-indigo-600/30 transition-all">
                        <i class="fa-solid fa-users w-5 text-center text-white"></i>
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
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
                        <i class="fa-solid fa-users text-indigo-600"></i>
                        <span>User Management</span>
                    </h1>
                    <p class="text-slate-500 text-xs sm:text-sm mt-1">Quản lý danh sách người dùng, vai trò và trạng thái tài khoản LearnHub</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/users?action=new"
                       class="inline-flex items-center gap-1.5 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white font-bold rounded-xl text-xs transition shadow-sm shadow-indigo-600/20">
                        <i class="fa-solid fa-user-plus text-xs"></i>
                        <span>Thêm người dùng</span>
                    </a>
                </div>
            </div>

            <!-- Filter & Search Bar -->
            <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs mb-6">
                <form action="${pageContext.request.contextPath}/admin/users" method="get" class="flex flex-col md:flex-row gap-3">
                    <!-- Search Field -->
                    <div class="relative flex-1">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        <input type="text"
                               name="search"
                               value="${search}"
                               placeholder="Tìm theo tên đăng nhập hoặc email..."
                               class="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white">
                    </div>

                    <!-- Role Dropdown -->
                    <div class="relative w-full md:w-52">
                        <i class="fa-solid fa-shield-halved absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        <select name="roleId"
                                class="w-full pl-9 pr-8 py-2 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 cursor-pointer appearance-none">
                            <option value="">Tất cả vai trò</option>
                            <c:forEach var="role" items="${roles}">
                                <option value="${role.id}" ${(roleId eq role.idString) or (roleId eq role.id) or (selectedRole eq role.idString) ? 'selected' : ''}>
                                    ${role.name}
                                </option>
                            </c:forEach>
                        </select>
                        <i class="fa-solid fa-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 text-[10px] pointer-events-none"></i>
                    </div>

                    <!-- Status Dropdown -->
                    <div class="relative w-full md:w-44">
                        <i class="fa-solid fa-circle-check absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        <select name="status"
                                class="w-full pl-9 pr-8 py-2 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 cursor-pointer appearance-none">
                            <option value="">Tất cả trạng thái</option>
                            <option value="active" ${selectedStatus eq 'active' ? 'selected' : ''}>Hoạt động (Active)</option>
                            <option value="inactive" ${selectedStatus eq 'inactive' ? 'selected' : ''}>Tạm ngưng (Inactive)</option>
                            <option value="banned" ${selectedStatus eq 'banned' ? 'selected' : ''}>Bị khóa (Banned)</option>
                        </select>
                        <i class="fa-solid fa-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 text-[10px] pointer-events-none"></i>
                    </div>

                    <!-- Buttons -->
                    <div class="flex items-center gap-2">
                        <button type="submit"
                                class="inline-flex items-center justify-center gap-1.5 px-4 py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-xl font-bold text-xs transition cursor-pointer">
                            <i class="fa-solid fa-filter text-xs"></i>
                            <span>Lọc</span>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/users"
                           class="inline-flex items-center justify-center gap-1.5 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-xl font-bold text-xs transition">
                            <i class="fa-solid fa-rotate-left text-xs"></i>
                            <span>Đặt lại</span>
                        </a>
                    </div>
                </form>
            </div>

            <!-- Users Table Card -->
            <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs text-slate-600">
                        <thead class="bg-slate-50/80 text-slate-400 uppercase text-[10px] font-bold tracking-wider border-b border-slate-200/80 select-none">
                            <tr>
                                <th class="px-6 py-3.5">
                                    <i class="fa-regular fa-user mr-1.5 text-slate-400"></i>
                                    <span>Tài khoản</span>
                                </th>
                                <th class="px-6 py-3.5">
                                    <i class="fa-regular fa-envelope mr-1.5 text-slate-400"></i>
                                    <span>Email</span>
                                </th>
                                <th class="px-6 py-3.5">
                                    <i class="fa-solid fa-shield-halved mr-1.5 text-slate-400"></i>
                                    <span>Vai trò</span>
                                </th>
                                <th class="px-6 py-3.5">
                                    <i class="fa-regular fa-circle-check mr-1.5 text-slate-400"></i>
                                    <span>Trạng thái</span>
                                </th>
                                <th class="px-6 py-3.5 text-right">
                                    <i class="fa-solid fa-sliders mr-1.5 text-slate-400"></i>
                                    <span>Thao tác</span>
                                </th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <c:choose>
                                <c:when test="${empty users}">
                                    <tr>
                                        <td colspan="5" class="py-12 text-center text-slate-400">
                                            <i class="fa-solid fa-user-slash text-4xl text-slate-300 mb-3 block"></i>
                                            <p class="text-sm font-medium">Không tìm thấy người dùng phù hợp</p>
                                            <a href="${pageContext.request.contextPath}/admin/users" class="mt-2 inline-block text-xs text-indigo-600 hover:underline">
                                                Xóa bộ lọc để xem tất cả
                                            </a>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="u" items="${users}">
                                        <tr class="hover:bg-slate-50/60 transition-colors">
                                            <td class="px-6 py-4">
                                                <div class="flex items-center space-x-3">
                                                    <div class="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold text-xs uppercase border border-indigo-100">
                                                        ${fn:substring(u.username, 0, 1)}
                                                    </div>
                                                    <div>
                                                        <span class="font-bold text-slate-900 block">${u.username}</span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 font-mono text-[11px] text-slate-600">
                                                ${u.email}
                                            </td>
                                            <td class="px-6 py-4">
                                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[11px] font-bold ${u.roleCode eq 'ROLE_ADMIN' ? 'bg-purple-50 text-purple-700 border border-purple-200' : (u.roleCode eq 'ROLE_MANAGER' ? 'bg-blue-50 text-blue-700 border border-blue-200' : (u.roleCode eq 'ROLE_EXPERT' ? 'bg-amber-50 text-amber-700 border border-amber-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'))}">
                                                    ${u.roleName}
                                                </span>
                                            </td>
                                            <td class="px-6 py-4">
                                                <c:choose>
                                                    <c:when test="${u.status eq 'active'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                            <i class="fa-solid fa-circle-check text-[10px]"></i>
                                                            <span>Active</span>
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${u.status eq 'banned'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                                                            <i class="fa-solid fa-ban text-[10px]"></i>
                                                            <span>Banned</span>
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-slate-100 text-slate-600 border border-slate-200">
                                                            <i class="fa-solid fa-circle-pause text-[10px]"></i>
                                                            <span>Inactive</span>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-6 py-4 text-right">
                                                <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.id}"
                                                   class="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-bold text-indigo-600 hover:text-indigo-800 hover:bg-indigo-50 rounded-lg transition-colors">
                                                    <i class="fa-solid fa-pen-to-square text-[11px]"></i>
                                                    <span>Sửa</span>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer -->
                <c:if test="${totalUsers > 0}">
                    <div class="px-6 py-4 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-3 bg-slate-50/40">
                        <div class="text-xs text-slate-500 font-medium">
                            Hiển thị <span class="font-bold text-slate-800">${(currentPage - 1) * pageSize + 1}</span> -
                            <span class="font-bold text-slate-800">${currentPage * pageSize gt totalUsers ? totalUsers : currentPage * pageSize}</span>
                            trên tổng số <span class="font-bold text-slate-800">${totalUsers}</span> người dùng
                        </div>

                        <div class="flex items-center space-x-1.5">
                            <!-- Prev Page -->
                            <c:choose>
                                <c:when test="${currentPage gt 1}">
                                    <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage - 1}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                       class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition inline-flex items-center gap-1">
                                        <i class="fa-solid fa-chevron-left text-[10px]"></i>
                                        <span>Trước</span>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-3 py-1.5 rounded-lg border border-slate-200 bg-slate-100 text-xs font-bold text-slate-400 cursor-not-allowed inline-flex items-center gap-1">
                                        <i class="fa-solid fa-chevron-left text-[10px]"></i>
                                        <span>Trước</span>
                                    </span>
                                </c:otherwise>
                            </c:choose>

                            <!-- Page Numbers -->
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:choose>
                                    <c:when test="${p eq currentPage}">
                                        <span class="px-3 py-1.5 rounded-lg bg-indigo-600 text-white font-black text-xs shadow-xs">
                                            ${p}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/admin/users?page=${p}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                           class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition">
                                            ${p}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <!-- Next Page -->
                            <c:choose>
                                <c:when test="${currentPage lt totalPages}">
                                    <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage + 1}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                       class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition inline-flex items-center gap-1">
                                        <span>Sau</span>
                                        <i class="fa-solid fa-chevron-right text-[10px]"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-3 py-1.5 rounded-lg border border-slate-200 bg-slate-100 text-xs font-bold text-slate-400 cursor-not-allowed inline-flex items-center gap-1">
                                        <span>Sau</span>
                                        <i class="fa-solid fa-chevron-right text-[10px]"></i>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />