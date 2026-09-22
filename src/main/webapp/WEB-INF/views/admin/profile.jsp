<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="bg-white p-8 rounded-2xl border border-slate-200 shadow-xl">
        <h1 class="text-2xl font-black text-slate-900 mb-6 text-center">Hồ Sơ Cá Nhân</h1>

        <div class="flex flex-col items-center mb-6">
            <div class="w-20 h-20 rounded-full bg-blue-100 text-blue-600 font-black text-2xl flex items-center justify-center mb-2">
                ${user.username != null ? user.username.substring(0, 1).toUpperCase() : 'U'}
            </div>
            <h2 class="text-lg font-bold text-slate-900">${user.username}</h2>
            <p class="text-sm text-slate-500">${user.email}</p>
        </div>

        <form action="${pageContext.request.contextPath}/admin/users" method="post" class="space-y-4">
            <input type="hidden" name="action" value="updateProfile">
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-1">Tên tài khoản</label>
                <input type="text" name="username" value="${user.username}" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm">
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-1">Email</label>
                <input type="email" name="email" value="${user.email}" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm">
            </div>
            <button type="submit" class="w-full py-3 px-4 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-md transition text-sm">
                Cập Nhật Hồ Sơ
            </button>
        </form>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />