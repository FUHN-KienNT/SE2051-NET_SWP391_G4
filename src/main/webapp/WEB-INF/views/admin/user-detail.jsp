<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="bg-white p-8 rounded-2xl border border-slate-200 shadow-xl">
        <h1 class="text-2xl font-black text-slate-900 mb-6">${not empty user ? 'Cập Nhật Người Dùng' : 'Thêm Người Dùng Mới'}</h1>

        <form action="${pageContext.request.contextPath}/admin/users" method="post" class="space-y-4">
            <input type="hidden" name="action" value="save">
            <c:if test="${not empty user}">
                <input type="hidden" name="id" value="${user.id}">
            </c:if>

            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-1">Tên tài khoản</label>
                <input type="text" name="username" value="${user.username}" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm">
            </div>

            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-1">Email</label>
                <input type="email" name="email" value="${user.email}" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm">
            </div>

            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-1">Mật khẩu ${not empty user ? '(để trống nếu không đổi)' : ''}</label>
                <input type="password" name="password" ${empty user ? 'required' : ''} class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm">
            </div>

            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-1">Vai trò</label>
                <select name="roleId" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm">
                    <c:forEach var="role" items="${roles}">
                        <option value="${role.id}" ${user.roleId eq role.id ? 'selected' : ''}>${role.name}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-1">Trạng thái</label>
                <select name="status" class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm">
                    <option value="active" ${user.status eq 'active' ? 'selected' : ''}>Hoạt động</option>
                    <option value="inactive" ${user.status eq 'inactive' ? 'selected' : ''}>Tạm khóa</option>
                </select>
            </div>

            <div class="pt-4 flex justify-end space-x-3">
                <a href="${pageContext.request.contextPath}/admin/users" class="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-xl text-sm transition">
                    Hủy bỏ
                </a>
                <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-sm shadow-md transition">
                    Lưu thông tin
                </button>
            </div>
        </form>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />