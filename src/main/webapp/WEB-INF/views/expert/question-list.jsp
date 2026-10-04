<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="w-full px-4 sm:px-6 lg:px-8 pt-6 pb-16 flex flex-col md:flex-row gap-6">
    <aside class="w-full md:w-44 shrink-0">
        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
            <nav class="flex flex-col">
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${courseId}"
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition border-l-4 border-transparent">
                    <i class="fa-solid fa-book-open text-slate-400 text-sm"></i>
                    <span>Lesson</span>
                </a>
                <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}"
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition border-l-4 border-transparent">
                    <i class="fa-solid fa-clipboard-question text-slate-400 text-sm"></i>
                    <span>Quiz</span>
                </a>
                <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-bold bg-slate-100 text-slate-900 border-l-4 border-blue-600">
                    <i class="fa-solid fa-list-check text-blue-600 text-sm"></i>
                    <span>Question Bank</span>
                </a>
            </nav>
        </div>
    </aside>

    <div class="flex-1 min-w-0">
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="flex items-center justify-between mb-6">
                <a href="${pageContext.request.contextPath}/expert/dashboard"
                   class="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 hover:text-slate-900 transition text-sm font-semibold shadow-sm group">
                    <i class="fa-solid fa-arrow-left text-xs transition-transform group-hover:-translate-x-1"></i>
                    <span>Quay lại</span>
                </a>
                <h1 class="text-xl sm:text-2xl font-black text-slate-900">Question List</h1>
                <div class="w-24"></div>
            </div>

            <c:if test="${param.saved == 'true'}">
                <div class="mb-5 p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm font-semibold">Question saved successfully.</div>
            </c:if>
            <c:if test="${param.deleted == 'false'}">
                <div class="mb-5 p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold">Cannot delete. The question is already used in a Quiz or data is invalid.</div>
            </c:if>

            <form method="get" action="${pageContext.request.contextPath}/questions/manage" class="mb-6 flex flex-col sm:flex-row gap-3">
                <input type="hidden" name="courseId" value="${courseId}">
                <input name="keyword" value="${keyword}" placeholder="Search question content..."
                       class="flex-1 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none text-sm">
                <select name="type" class="sm:w-64 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none">
                    <option value="">All types</option>
                    <option value="single_choice" ${type == 'single_choice' ? 'selected' : ''}>Single choice</option>
                    <option value="multiple_choice" ${type == 'multiple_choice' ? 'selected' : ''}>Multiple choice</option>
                    <option value="text" ${type == 'text' ? 'selected' : ''}>Text</option>
                </select>
                <button class="px-5 py-2.5 rounded-xl bg-slate-900 text-white font-bold text-sm hover:bg-slate-800">Search</button>
            </form>

            <div class="overflow-x-auto border border-slate-200 rounded-xl">
                <table class="w-full text-left text-sm text-slate-600">
                    <thead class="bg-slate-50 text-slate-700 text-xs font-bold border-b border-slate-200">
                        <tr>
                            <th class="px-5 py-4 w-14 text-center">#</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Question</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Type</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Options</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800 w-36">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:choose>
                            <c:when test="${not empty questions}">
                                <c:forEach var="q" items="${questions}" varStatus="s">
                                    <tr class="hover:bg-slate-50/80 transition-colors">
                                        <td class="px-5 py-4 text-center font-bold text-slate-400 text-xs">${s.count}</td>
                                        <td class="px-5 py-4 font-medium text-slate-900 max-w-xl">
                                            <div class="flex items-center space-x-2.5">
                                                <i class="fa-regular fa-circle-question text-blue-500 text-sm"></i>
                                                <span>${q.content}</span>
                                            </div>
                                        </td>
                                        <td class="px-5 py-4">
                                            <span class="px-2.5 py-1 rounded-lg bg-blue-50 text-blue-700 text-xs font-bold whitespace-nowrap">${q.type}</span>
                                        </td>
                                        <td class="px-5 py-4 text-center font-semibold text-slate-700">${q.options.size()}</td>
                                        <td class="px-5 py-4 text-center space-x-3 text-xs font-semibold whitespace-nowrap">
                                            <a href="${pageContext.request.contextPath}/questions/detail?id=${q.id}&courseId=${courseId}"
                                               class="text-blue-600 hover:text-blue-800 hover:underline transition">Edit</a>
                                            <a href="${pageContext.request.contextPath}/questions/manage?action=delete&id=${q.id}&courseId=${courseId}"
                                               class="text-rose-600 hover:text-rose-800 hover:underline transition"
                                               onclick="return confirm('Xóa câu hỏi này? Chỉ câu hỏi chưa được dùng trong Quiz mới xóa được.');">Delete</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="5" class="px-6 py-12 text-center text-slate-400 text-sm">
                                        <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300"></i>
                                        No questions found.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <div class="mt-6 flex justify-end">
                <a href="${pageContext.request.contextPath}/questions/detail?courseId=${courseId}"
                   class="inline-flex items-center px-5 py-2.5 bg-slate-900 hover:bg-slate-800 text-white font-bold rounded-xl text-sm transition shadow-sm space-x-2">
                    <i class="fa-solid fa-plus text-xs"></i>
                    <span>Create Question</span>
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
