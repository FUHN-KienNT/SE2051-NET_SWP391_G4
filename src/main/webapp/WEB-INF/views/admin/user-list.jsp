<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h1 class="text-3xl font-black text-slate-900">Quản Lý Người Dùng</h1>
            <p class="text-slate-500 mt-1">Danh sách tài khoản trong hệ thống LearnHub</p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/users?action=new" class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-sm transition shadow-sm">
            + Thêm người dùng
        </a>
    </div>

    <!-- Filter Bar -->
    <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm mb-6">
        <form action="${pageContext.request.contextPath}/admin/users" method="get" class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div class="md:col-span-2">
                <input type="text" name="search" value="${search}" placeholder="Tìm theo tên hoặc email..." class="w-full px-4 py-2 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
                <select name="roleId" class="w-full px-3 py-2 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500">
                    <option value="">Tất cả vai trò</option>
                    <c:forEach var="role" items="${roles}">
                        <option value="${role.id}" ${roleId eq role.id.toString() ? 'selected' : ''}>${role.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="flex space-x-2">
                <button type="submit" class="flex-1 py-2 px-4 bg-blue-600 text-white rounded-xl font-bold text-sm hover:bg-blue-700 transition">
                    Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/users" class="py-2 px-4 bg-slate-100 text-slate-600 rounded-xl font-bold text-sm hover:bg-slate-200 transition">
                    Đặt lại
                </a>
            </div>
        </form>
    </div>

    <!-- User Table -->
    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table class="w-full text-left text-sm text-slate-600">
            <thead class="bg-slate-50 text-slate-800 uppercase text-xs font-bold border-b border-slate-200">
                <tr>
                    <th class="px-6 py-4">Tên tài khoản</th>
                    <th class="px-6 py-4">Email</th>
                    <th class="px-6 py-4">Vai trò</th>
                    <th class="px-6 py-4">Trạng thái</th>
                    <th class="px-6 py-4 text-right">Thao tác</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                <c:forEach var="u" items="${users}">
                    <tr class="hover:bg-slate-50">
                        <td class="px-6 py-4 font-semibold text-slate-900">${u.username}</td>
                        <td class="px-6 py-4">${u.email}</td>
                        <td class="px-6 py-4"><span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700">${u.roleName}</span></td>
                        <td class="px-6 py-4">
                            <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold ${u.status eq 'active' ? 'bg-emerald-50 text-emerald-700' : 'bg-rose-50 text-rose-700'}">
                                ${u.status}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right space-x-2">
                            <a href="${pageContext.request.contextPath}/admin/users?action=edit&id=${u.id}" class="font-semibold text-blue-600 hover:underline">Sửa</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />