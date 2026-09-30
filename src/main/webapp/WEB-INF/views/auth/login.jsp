<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow flex items-center justify-center py-16 px-4">
    <div class="max-w-md w-full bg-white p-8 rounded-2xl border border-slate-200 shadow-xl">
        <div class="text-center mb-8">
            <div class="w-12 h-12 rounded-xl bg-blue-600 text-white flex items-center justify-center mx-auto mb-3 shadow-md">
                <i class="fa-solid fa-lock text-xl"></i>
            </div>
            <h2 class="text-2xl font-black text-slate-900">Đăng Nhập</h2>
            <p class="text-sm text-slate-500 mt-1">Chào mừng bạn quay trở lại với LearnHub</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm flex items-center">
                <i class="fa-solid fa-circle-exclamation mr-3 text-rose-500"></i>
                <span>${errorMessage}</span>
            </div>
        </c:if>

        <c:if test="${not empty message}">
            <div class="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm flex items-center">
                <i class="fa-solid fa-circle-check mr-3 text-emerald-500"></i>
                <span>${message}</span>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post" class="space-y-4">
            <div>
                <label for="email" class="block text-sm font-semibold text-slate-700 mb-1">Email hoặc Tên đăng nhập</label>
                <input id="email" name="email" type="text" required value="${email != null ? email : param.email}" class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm" placeholder="name@example.com">
            </div>

            <div>
                <label for="password" class="block text-sm font-semibold text-slate-700 mb-1">Mật khẩu</label>
                <input id="password" name="password" type="password" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm" placeholder="••••••••">
            </div>

            <button type="submit" class="w-full py-3 px-4 text-sm font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-md transition">
                Đăng Nhập
            </button>
        </form>

        <div class="mt-6 text-center text-sm text-slate-500">
            Chưa có tài khoản?
            <a href="${pageContext.request.contextPath}/register" class="font-semibold text-blue-600 hover:underline">Đăng ký ngay</a>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />