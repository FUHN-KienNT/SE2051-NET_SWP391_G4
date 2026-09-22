<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="mb-8">
        <h1 class="text-3xl font-black text-slate-900">Duyệt Nội Dung Khóa Học</h1>
        <p class="text-slate-500 mt-1">Danh sách yêu cầu kiểm duyệt nội dung từ giảng viên & chuyên gia</p>
    </div>

    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table class="w-full text-left text-sm text-slate-600">
            <thead class="bg-slate-50 text-slate-800 uppercase text-xs font-bold border-b border-slate-200">
                <tr>
                    <th class="px-6 py-4">Khóa học / Bài học</th>
                    <th class="px-6 py-4">Giảng viên</th>
                    <th class="px-6 py-4">Trạng thái</th>
                    <th class="px-6 py-4">Ghi chú</th>
                    <th class="px-6 py-4 text-right">Phê duyệt</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                <c:choose>
                    <c:when test="${not empty reviews}">
                        <c:forEach var="rev" items="${reviews}">
                            <tr class="hover:bg-slate-50">
                                <td class="px-6 py-4 font-semibold text-slate-900">${rev.entityId}</td>
                                <td class="px-6 py-4">${rev.expertName}</td>
                                <td class="px-6 py-4">
                                    <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold ${rev.status eq 'approved' ? 'bg-emerald-50 text-emerald-700' : (rev.status eq 'rejected' ? 'bg-rose-50 text-rose-700' : 'bg-amber-50 text-amber-700')}">
                                        ${rev.status}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-slate-500">${rev.comments}</td>
                                <td class="px-6 py-4 text-right space-x-2">
                                    <form action="${pageContext.request.contextPath}/content-review" method="post" class="inline">
                                        <input type="hidden" name="action" value="approve">
                                        <input type="hidden" name="reviewId" value="${rev.id}">
                                        <button type="submit" class="px-3 py-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-bold transition">
                                            Duyệt
                                        </button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/content-review" method="post" class="inline">
                                        <input type="hidden" name="action" value="reject">
                                        <input type="hidden" name="reviewId" value="${rev.id}">
                                        <button type="submit" class="px-3 py-1 bg-rose-600 hover:bg-rose-700 text-white rounded-lg text-xs font-bold transition">
                                            Từ chối
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="5" class="px-6 py-12 text-center text-slate-400">
                                Không có yêu cầu kiểm duyệt nào đang chờ xử lý.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />