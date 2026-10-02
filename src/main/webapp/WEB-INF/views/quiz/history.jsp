<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="mb-8">
        <h1 class="text-3xl font-black text-slate-900">Lịch Sử Làm Bài</h1>
        <p class="text-slate-500 mt-1">${quiz != null ? quiz.name : 'Các bài thi trắc nghiệm'}</p>
    </div>

    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table class="w-full text-left text-sm text-slate-600">
            <thead class="bg-slate-50 text-slate-800 uppercase text-xs font-bold border-b border-slate-200">
                <tr>
                    <th class="px-6 py-4">Lần thi</th>
                    <th class="px-6 py-4">Thời gian</th>
                    <th class="px-6 py-4">Điểm số</th>
                    <th class="px-6 py-4">Kết quả</th>
                    <th class="px-6 py-4 text-right">Chi tiết</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                <c:forEach var="sub" items="${submissions}" varStatus="status">
                    <tr class="hover:bg-slate-50">
                        <td class="px-6 py-4 font-semibold text-slate-900">#${status.count}</td>
                        <td class="px-6 py-4"><fmt:formatDate value="${sub.submittedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                        <td class="px-6 py-4 font-bold text-slate-900"><fmt:formatNumber value="${sub.score}" maxFractionDigits="1"/></td>
                        <td class="px-6 py-4">
                            <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold ${sub.status eq 'passed' ? 'bg-emerald-50 text-emerald-700' : 'bg-rose-50 text-rose-700'}">
                                ${sub.status eq 'passed' ? 'Passed' : 'Failed'}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <a href="${pageContext.request.contextPath}/quiz?action=result&submissionId=${sub.id}" class="font-semibold text-blue-600 hover:underline">View Details</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />