<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h1 class="text-3xl font-black text-slate-900">Quản Lý Bài Giảng</h1>
            <p class="text-slate-500 mt-1">${course.title}</p>
        </div>
        <button class="px-5 py-2.5 bg-blue-600 text-white rounded-xl font-bold text-sm hover:bg-blue-700 shadow-sm transition">
            + Thêm bài giảng mới
        </button>
    </div>

    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table class="w-full text-left text-sm text-slate-600">
            <thead class="bg-slate-50 text-slate-800 uppercase text-xs font-bold border-b border-slate-200">
                <tr>
                    <th class="px-6 py-4">Tên bài giảng</th>
                    <th class="px-6 py-4">Thời lượng</th>
                    <th class="px-6 py-4">Trạng thái</th>
                    <th class="px-6 py-4 text-right">Thao tác</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                <c:forEach var="les" items="${lessons}">
                    <tr class="hover:bg-slate-50">
                        <td class="px-6 py-4 font-semibold text-slate-900">${les.name}</td>
                        <td class="px-6 py-4">${les.duration} phút</td>
                        <td class="px-6 py-4">
                            <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700">Đã xuất bản</span>
                        </td>
                        <td class="px-6 py-4 text-right space-x-2">
                            <a href="#" class="font-semibold text-blue-600 hover:underline">Sửa</a>
                            <a href="#" class="font-semibold text-rose-600 hover:underline">Xóa</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />