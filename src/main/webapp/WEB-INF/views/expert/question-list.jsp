<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <div>
            <p class="text-xs font-bold uppercase tracking-wider text-blue-600">Expert Workspace</p>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900 mt-1">Question List</h1>
            <p class="text-sm text-slate-500 mt-1">Shared Question Bank dùng để xây dựng các Quiz.</p>
        </div>
        <div class="flex gap-2">
            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${param.courseId}" class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-slate-700 font-bold text-sm hover:bg-slate-50">
                <i class="fa-solid fa-clipboard-question mr-2"></i>Quiz Management
            </a>
            <a href="${pageContext.request.contextPath}/questions/detail?courseId=${param.courseId}" class="px-4 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm shadow-sm">
                <i class="fa-solid fa-plus mr-2"></i>New Question
            </a>
        </div>
    </div>

    <c:if test="${param.saved == 'true'}">
        <div class="mb-5 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm font-semibold">Question saved successfully.</div>
    </c:if>
    <c:if test="${param.deleted == 'false'}">
        <div class="mb-5 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold">Cannot delete. The question is already used in a Quiz or data is invalid.</div>
    </c:if>

    <form method="get" class="bg-white rounded-2xl border border-slate-200 shadow-sm p-4 mb-6 grid grid-cols-1 md:grid-cols-[1fr_220px_auto] gap-3">
        <div class="relative">
            <i class="fa-solid fa-magnifying-glass absolute left-4 top-3.5 text-slate-400"></i>
            <input name="keyword" value="${keyword}" placeholder="Search question content..."
                   class="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none text-sm">
        </div>
        <select name="type" class="px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none">
            <option value="">All types</option>
            <option value="single_choice" ${type == 'single_choice' ? 'selected' : ''}>Single choice</option>
            <option value="multiple_choice" ${type == 'multiple_choice' ? 'selected' : ''}>Multiple choice</option>
            <option value="text" ${type == 'text' ? 'selected' : ''}>Text</option>
        </select>
        <button class="px-5 py-2.5 rounded-xl bg-slate-900 text-white font-bold text-sm hover:bg-slate-800">Search</button>
    </form>

    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center">
            <h2 class="font-black text-slate-900">Question Bank</h2>
            <span class="text-xs font-bold text-slate-400">${questions.size()} questions</span>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-xs uppercase text-slate-500">
                    <tr>
                        <th class="text-left px-5 py-3 w-12">#</th>
                        <th class="text-left px-5 py-3">Question</th>
                        <th class="text-left px-5 py-3">Type</th>
                        <th class="text-center px-5 py-3">Options</th>
                        <th class="text-right px-5 py-3">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    <c:forEach var="q" items="${questions}" varStatus="s">
                        <tr class="hover:bg-slate-50">
                            <td class="px-5 py-4 text-slate-400 font-bold">${s.count}</td>
                            <td class="px-5 py-4 max-w-2xl">
                                <div class="font-semibold text-slate-800">${q.content}</div>
                                <div class="text-[11px] text-slate-400 mt-1">${q.id}</div>
                            </td>
                            <td class="px-5 py-4">
                                <span class="px-2.5 py-1 rounded-lg bg-blue-50 text-blue-700 text-xs font-bold">${q.type}</span>
                            </td>
                            <td class="px-5 py-4 text-center text-slate-600">${q.options.size()}</td>
                            <td class="px-5 py-4 text-right whitespace-nowrap">
                                <a href="${pageContext.request.contextPath}/questions/detail?id=${q.id}" class="text-blue-600 font-bold hover:underline mr-4">Edit</a>
                                <a href="${pageContext.request.contextPath}/questions/manage?action=delete&id=${q.id}"
                                   onclick="return confirm('Xóa câu hỏi này? Chỉ câu hỏi chưa được dùng trong Quiz mới xóa được.');"
                                   class="text-rose-600 font-bold hover:underline">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty questions}">
                        <tr><td colspan="5" class="px-5 py-12 text-center text-slate-400">No questions found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
