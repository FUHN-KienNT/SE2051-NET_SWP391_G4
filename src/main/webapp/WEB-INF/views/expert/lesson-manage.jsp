<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="w-full px-4 sm:px-6 lg:px-8 pt-6 pb-16 flex flex-col md:flex-row gap-6">
    <aside class="w-full md:w-44 shrink-0">
        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
            <nav class="flex flex-col">
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}" 
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-bold bg-slate-100 text-slate-900 border-l-4 border-blue-600">
                    <i class="fa-solid fa-book-open text-blue-600 text-sm"></i>
                    <span>Lesson</span>
                </a>
                <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${course.id}" 
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition border-l-4 border-transparent">
                    <i class="fa-solid fa-clipboard-question text-slate-400 text-sm"></i>
                    <span>Quiz</span>
                </a>
                <a href="${pageContext.request.contextPath}/questions/manage?courseId=${course.id}"
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition border-l-4 border-transparent">
                    <i class="fa-solid fa-list-check text-slate-400 text-sm"></i>
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
                            <h1 class="text-xl sm:text-2xl font-black text-slate-900">Lesson List</h1>
                            <div class="w-24"></div>
                        </div>
            <div class="overflow-x-auto border border-slate-200 rounded-xl">
                <table class="w-full text-left text-sm text-slate-600">
                    <thead class="bg-slate-50 text-slate-700 text-xs font-bold border-b border-slate-200">
                        <tr>
                            <th class="px-5 py-4 w-14 text-center">#</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Module</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Lesson Title</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800 w-36">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:choose>
                            <c:when test="${not empty modules}">
                                <c:set var="globalIndex" value="1" />
                                <c:forEach var="module" items="${modules}">
                                    <c:choose>
                                        <c:when test="${not empty module.lessons}">
                                            <c:forEach var="les" items="${module.lessons}">
                                                <tr class="hover:bg-slate-50/80 transition-colors">
                                                    <td class="px-5 py-4 text-center font-bold text-slate-400 text-xs">
                                                        ${globalIndex}
                                                    </td>
                                                    <td class="px-5 py-4 font-semibold text-slate-800 text-xs">
                                                        ${module.title}
                                                    </td>
                                                    <td class="px-5 py-4 font-medium text-slate-900">
                                                        <div class="flex items-center space-x-2.5">
                                                            <i class="fa-regular fa-circle-play text-blue-500 text-sm"></i>
                                                            <span>${les.title}</span>
                                                        </div>
                                                    </td>
                                                    <td class="px-5 py-4 text-center space-x-3 text-xs font-semibold whitespace-nowrap">
                                                        <a href="${pageContext.request.contextPath}/lessons/manage?action=edit&id=${les.id}&courseId=${course.id}" 
                                                           class="text-blue-600 hover:text-blue-800 hover:underline transition">Edit</a>
                                                        <a href="${pageContext.request.contextPath}/lessons/manage?action=delete&id=${les.id}&courseId=${course.id}" 
                                                           class="text-rose-600 hover:text-rose-800 hover:underline transition" 
                                                           onclick="return confirm('Bạn có chắc chắn muốn xóa bài giảng này không?');">Delete</a>
                                                    </td>
                                                </tr>
                                                <c:set var="globalIndex" value="${globalIndex + 1}" />
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr class="bg-slate-50/40">
                                                <td class="px-5 py-3.5 text-center text-slate-300 text-xs">-</td>
                                                <td class="px-5 py-3.5 font-semibold text-slate-500 text-xs">${module.title}</td>
                                                <td colspan="2" class="px-5 py-3.5 text-xs text-slate-400 italic">
                                                    Chưa có bài học nào trong chương này
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="px-6 py-12 text-center text-slate-400 text-sm">
                                        <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300"></i>
                                        Khóa học này hiện chưa có module hoặc bài giảng nào.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <div class="mt-6 flex justify-end">
                <a href="${pageContext.request.contextPath}/lessons/manage?action=create&courseId=${course.id}" 
                   class="inline-flex items-center px-5 py-2.5 bg-slate-900 hover:bg-slate-800 text-white font-bold rounded-xl text-sm transition shadow-sm space-x-2">
                    <i class="fa-solid fa-plus text-xs"></i>
                    <span>Create Lesson</span>
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />