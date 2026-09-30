<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />
<main class="flex-grow py-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <!-- Breadcrumb -->
    <nav class="flex items-center text-xs text-slate-400 font-medium mb-4 space-x-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-blue-600 transition">Trang chủ</a>
        <span>/</span>
        <a href="${pageContext.request.contextPath}/expert/dashboard" class="hover:text-blue-600 transition">Khóa học được giao</a>
        <span>/</span>
        <span class="text-slate-600 font-semibold truncate max-w-md">${not empty course ? course.title : 'Quản lý nội dung'}</span>
    </nav>
    <!-- Header & Thao tác -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <div>
            <div class="flex items-center gap-3">
                <span class="px-2.5 py-0.5 rounded-md text-xs font-bold bg-blue-100 text-blue-800 uppercase">Curriculum Builder</span>
                <span class="text-xs text-slate-400 font-semibold">${not empty modules ? modules.size() : 0} chương &bull; ${not empty lessons ? lessons.size() : 0} bài học</span>
            </div>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900 mt-1">${not empty course ? course.title : 'Quản Lý Bài Giảng'}</h1>
        </div>
        <div class="flex items-center gap-3 shrink-0">
            <a href="${pageContext.request.contextPath}/expert/dashboard" class="px-4 py-2 border border-slate-300 text-slate-700 rounded-xl text-sm font-semibold hover:bg-slate-50 transition">
                <i class="fa-solid fa-arrow-left mr-1.5"></i> Quay lại
            </a>
            <button class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-sm transition">
                <i class="fa-solid fa-plus mr-1.5"></i> Thêm bài học mới
            </button>
        </div>
    </div>
    <!-- Danh sách Modules & Bài học -->
    <div class="space-y-6">
        <c:choose>
            <c:when test="${not empty modules}">
                <c:forEach var="module" items="${modules}" varStatus="mLoop">
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                        <!-- Tiêu đề Chương (Module Header) -->
                        <div class="p-5 bg-slate-50/80 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                            <div class="flex items-center gap-3">
                                <span class="w-8 h-8 rounded-lg bg-blue-600 text-white font-black text-sm flex items-center justify-center shadow-sm">
                                    ${mLoop.count}
                                </span>
                                <div>
                                    <h2 class="font-bold text-slate-900 text-base sm:text-lg">${module.title}</h2>
                                    <c:if test="${not empty module.content}">
                                        <p class="text-xs text-slate-500 mt-0.5 line-clamp-1">${module.content}</p>
                                    </c:if>
                                </div>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="px-2.5 py-1 bg-white border border-slate-200 text-slate-600 rounded-lg text-xs font-semibold">
                                    ${not empty module.lessons ? module.lessons.size() : 0} bài học
                                </span>
                            </div>
                        </div>
                        <!-- Danh sách bài học bên trong Chương (Lessons Table) -->
                        <c:choose>
                            <c:when test="${not empty module.lessons}">
                                <div class="overflow-x-auto">
                                    <table class="w-full text-left text-sm text-slate-600">
                                        <thead class="bg-white text-slate-400 uppercase text-[11px] font-bold border-b border-slate-100">
                                            <tr>
                                                <th class="px-6 py-3 w-16 text-center">STT</th>
                                                <th class="px-6 py-3">Tên bài giảng (Lesson Title)</th>
                                                <th class="px-6 py-3 w-36 text-center">Trạng thái</th>
                                                <th class="px-6 py-3 w-36 text-right">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody class="divide-y divide-slate-100">
                                            <c:forEach var="les" items="${module.lessons}" varStatus="lLoop">
                                                <tr class="hover:bg-slate-50/60 transition-colors">
                                                    <td class="px-6 py-4 text-center font-bold text-slate-400 text-xs">
                                                        ${lLoop.count}
                                                    </td>
                                                    <td class="px-6 py-4 font-semibold text-slate-900">
                                                        <div class="flex items-center gap-2.5">
                                                            <i class="fa-regular fa-circle-play text-blue-600 text-base"></i>
                                                            <span>${les.title}</span>
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-4 text-center">
                                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700">
                                                            ● Đã xuất bản
                                                        </span>
                                                    </td>
                                                    <td class="px-6 py-4 text-right space-x-3 text-xs font-semibold">
                                                        <a href="#" class="text-blue-600 hover:text-blue-800 transition">
                                                            <i class="fa-solid fa-pen-to-square mr-1"></i>Sửa
                                                        </a>
                                                        <a href="#" class="text-rose-600 hover:text-rose-800 transition">
                                                            <i class="fa-solid fa-trash-can mr-1"></i>Xóa
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="p-6 text-center text-slate-400 text-xs">
                                    Chương này hiện chưa có bài giảng nào.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center text-slate-500 shadow-sm">
                    <i class="fa-regular fa-folder-open text-5xl text-slate-300 mb-3 block"></i>
                    <p class="font-semibold text-base text-slate-700">Chưa tìm thấy nội dung khóa học</p>
                    <p class="text-xs text-slate-400 mt-1">Khóa học này hiện chưa được cấu hình chương hoặc bài học.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />