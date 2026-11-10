<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />


<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="users" />
    </jsp:include>
    <div class="flex-1 flex flex-col min-w-0">
    <main class="flex-grow p-6 sm:p-8 lg:p-10 max-w-7xl w-full mx-auto">
            <!-- Page Header -->
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
                        <i class="fa-solid fa-users text-[#047857]"></i>
                        <span>User Management</span>
                    </h1>
                    <p class="text-slate-500 text-xs sm:text-sm mt-1">Quản lý danh sách người dùng, vai trò và trạng thái tài khoản LearnHub</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/user-detail?action=new"
                       class="inline-flex items-center gap-1.5 px-4 py-2.5 bg-[#047857] hover:bg-[#065f46] active:bg-[#064e3b] text-white font-bold rounded-xl text-xs transition shadow-sm shadow-[#047857]/20">
                        <i class="fa-solid fa-user-plus text-xs"></i>
                        <span>Thêm người dùng</span>
                    </a>
                </div>
            </div>

            <!-- Flash Success Notification -->
            <c:if test="${not empty sessionScope.flashMessage}">
                <div class="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm flex items-center justify-between shadow-sm">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-check text-emerald-600 text-base" aria-hidden="true"></i>
                        <span class="font-medium"><c:out value="${sessionScope.flashMessage}" /></span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-800 p-1" aria-label="Dismiss">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
                <c:remove var="flashMessage" scope="session"/>
            </c:if>

            <!-- Flash Error Notification -->
            <c:if test="${not empty sessionScope.flashError}">
                <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base" aria-hidden="true"></i>
                        <span class="font-medium"><c:out value="${sessionScope.flashError}" /></span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800 p-1" aria-label="Dismiss">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
                <c:remove var="flashError" scope="session"/>
            </c:if>

            <!-- Filter & Search Bar -->
            <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs mb-6">
                <form action="${pageContext.request.contextPath}/admin/users" method="get" class="flex flex-col md:flex-row gap-3">
                    <input type="hidden" name="pageSize" value="${pageSize}">
                    <!-- Search Field -->
                    <div class="relative flex-1">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        <input type="text"
                               name="search"
                               value="${search}"
                               placeholder="Tìm theo tên đăng nhập, họ tên hoặc email..."
                               class="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#047857] bg-white">
                    </div>

                    <!-- Role Dropdown -->
                    <div class="relative w-full md:w-52">
                        <i class="fa-solid fa-shield-halved absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        <select name="roleId"
                                class="w-full pl-9 pr-8 py-2 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-[#047857] cursor-pointer appearance-none">
                            <option value="">Tất cả vai trò</option>
                            <c:forEach var="role" items="${roles}">
                                <c:set var="roleIdStrValue" value="${role.id.toString()}" />
                                <option value="${role.id}" ${param.roleId eq roleIdStrValue or selectedRole eq roleIdStrValue ? 'selected' : ''}>
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
                                class="w-full pl-9 pr-8 py-2 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-[#047857] cursor-pointer appearance-none">
                            <option value="">Tất cả trạng thái</option>
                            <option value="active" ${selectedStatus eq 'active' ? 'selected' : ''}>Hoạt động (Active)</option>
                            <option value="inactive" ${selectedStatus eq 'inactive' ? 'selected' : ''}>Tạm ngưng (Inactive)</option>
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
                                    <i class="fa-regular fa-id-card mr-1.5 text-slate-400"></i>
                                    <span>Họ và tên</span>
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
                                        <td colspan="6" class="py-12 text-center text-slate-400">
                                            <i class="fa-solid fa-user-slash text-4xl text-slate-300 mb-3 block"></i>
                                            <p class="text-sm font-medium">Không tìm thấy người dùng phù hợp</p>
                                            <a href="${pageContext.request.contextPath}/admin/users" class="mt-2 inline-block text-xs text-[#047857] hover:underline">
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
                                                    <div class="w-8 h-8 rounded-full bg-[#e8f5e9] text-[#047857] flex items-center justify-center font-bold text-xs uppercase border border-emerald-100">
                                                        ${not empty u.fullName ? fn:substring(u.fullName, 0, 1) : fn:substring(u.username, 0, 1)}
                                                    </div>
                                                    <div>
                                                        <span class="font-bold text-slate-900 block">${u.username}</span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 font-semibold text-slate-800 text-[13px]">
                                                <c:choose>
                                                    <c:when test="${not empty u.fullName}">
                                                        <c:out value="${u.fullName}" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-slate-400 italic font-normal text-[11px]">Chưa cập nhật</span>
                                                    </c:otherwise>
                                                </c:choose>
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
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                                            <i class="fa-solid fa-circle-pause text-[10px]"></i>
                                                            <span>Inactive</span>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-6 py-4 text-right">
                                                <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.id}"
                                                   class="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-bold text-[#047857] hover:text-[#065f46] hover:bg-[#e8f5e9] rounded-lg transition-colors">
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
                    <div class="px-6 py-4 border-t border-slate-100 flex flex-col md:flex-row items-center justify-between gap-4 bg-slate-50/40">
                        <div class="flex flex-wrap items-center gap-4 text-xs text-slate-500 font-medium">
                            <div>
                                Hiển thị <span class="font-bold text-slate-800">${(currentPage - 1) * pageSize + 1}</span> -
                                <span class="font-bold text-slate-800">${currentPage * pageSize gt totalUsers ? totalUsers : currentPage * pageSize}</span>
                                trên tổng số <span class="font-bold text-slate-800">${totalUsers}</span> người dùng
                            </div>

                            <!-- Page Size Selector -->
                            <div class="flex items-center gap-1.5 border-l border-slate-200 pl-4">
                                <span>Hiển thị:</span>
                                <select onchange="location.href=this.value"
                                        class="bg-white border border-slate-200 rounded-lg px-2 py-1 text-xs font-bold text-slate-700 focus:outline-none focus:ring-1 focus:ring-[#047857] cursor-pointer">
                                    <option value="${pageContext.request.contextPath}/admin/users?page=1&pageSize=10&search=${search}&roleId=${roleId}&status=${selectedStatus}" ${pageSize eq 10 ? 'selected' : ''}>10 / trang</option>
                                    <option value="${pageContext.request.contextPath}/admin/users?page=1&pageSize=20&search=${search}&roleId=${roleId}&status=${selectedStatus}" ${pageSize eq 20 ? 'selected' : ''}>20 / trang</option>
                                    <option value="${pageContext.request.contextPath}/admin/users?page=1&pageSize=50&search=${search}&roleId=${roleId}&status=${selectedStatus}" ${pageSize eq 50 ? 'selected' : ''}>50 / trang</option>
                                </select>
                            </div>
                        </div>

                        <!-- Pagination Controls -->
                        <div class="flex items-center space-x-1 select-none">
                            <!-- First Page Button (<<) -->
                            <c:choose>
                                <c:when test="${currentPage gt 1}">
                                    <a href="${pageContext.request.contextPath}/admin/users?page=1&pageSize=${pageSize}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                       class="rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition inline-flex items-center justify-center w-8 h-8"
                                       title="Trang đầu">
                                        <i class="fa-solid fa-angles-left text-[11px]"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="rounded-lg border border-slate-200 bg-slate-100 text-xs font-bold text-slate-300 cursor-not-allowed inline-flex items-center justify-center w-8 h-8"
                                          title="Trang đầu">
                                        <i class="fa-solid fa-angles-left text-[11px]"></i>
                                    </span>
                                </c:otherwise>
                            </c:choose>

                            <!-- Prev Page Button (< Trước) -->
                            <c:choose>
                                <c:when test="${currentPage gt 1}">
                                    <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage - 1}&pageSize=${pageSize}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                       class="px-2.5 rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition inline-flex items-center gap-1 h-8">
                                        <i class="fa-solid fa-chevron-left text-[10px]"></i>
                                        <span class="hidden sm:inline">Trước</span>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2.5 rounded-lg border border-slate-200 bg-slate-100 text-xs font-bold text-slate-300 cursor-not-allowed inline-flex items-center gap-1 h-8">
                                        <i class="fa-solid fa-chevron-left text-[10px]"></i>
                                        <span class="hidden sm:inline">Trước</span>
                                    </span>
                                </c:otherwise>
                            </c:choose>

                            <!-- Dynamic Page Numbers with Ellipsis -->
                            <c:forEach var="p" items="${pageNumbers}">
                                <c:choose>
                                    <c:when test="${p eq '...'}">
                                        <span class="px-2 text-xs font-bold text-slate-400 select-none self-center">...</span>
                                    </c:when>
                                    <c:when test="${p eq currentPage.toString()}">
                                        <span class="min-w-[32px] h-8 px-2.5 flex items-center justify-center rounded-lg bg-[#047857] text-white font-bold text-xs shadow-xs">
                                            ${p}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/admin/users?page=${p}&pageSize=${pageSize}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                           class="min-w-[32px] h-8 px-2.5 flex items-center justify-center rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition">
                                            ${p}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <!-- Next Page Button (Sau >) -->
                            <c:choose>
                                <c:when test="${currentPage lt totalPages}">
                                    <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage + 1}&pageSize=${pageSize}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                       class="px-2.5 rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition inline-flex items-center gap-1 h-8">
                                        <span class="hidden sm:inline">Sau</span>
                                        <i class="fa-solid fa-chevron-right text-[10px]"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2.5 rounded-lg border border-slate-200 bg-slate-100 text-xs font-bold text-slate-300 cursor-not-allowed inline-flex items-center gap-1 h-8">
                                        <span class="hidden sm:inline">Sau</span>
                                        <i class="fa-solid fa-chevron-right text-[10px]"></i>
                                    </span>
                                </c:otherwise>
                            </c:choose>

                            <!-- Last Page Button (>>) -->
                            <c:choose>
                                <c:when test="${currentPage lt totalPages}">
                                    <a href="${pageContext.request.contextPath}/admin/users?page=${totalPages}&pageSize=${pageSize}&search=${search}&roleId=${roleId}&status=${selectedStatus}"
                                       class="rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-100 transition inline-flex items-center justify-center w-8 h-8"
                                       title="Trang cuối">
                                        <i class="fa-solid fa-angles-right text-[11px]"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="rounded-lg border border-slate-200 bg-slate-100 text-xs font-bold text-slate-300 cursor-not-allowed inline-flex items-center justify-center w-8 h-8"
                                          title="Trang cuối">
                                        <i class="fa-solid fa-angles-right text-[11px]"></i>
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

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
