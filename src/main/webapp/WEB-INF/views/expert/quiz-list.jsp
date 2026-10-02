<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="w-full px-4 sm:px-6 lg:px-8 pt-4 pb-3">
    <nav class="flex items-center text-xs text-slate-400 font-medium space-x-2">
        <a href="${pageContext.request.contextPath}/expert/dashboard" class="hover:text-blue-600 text-blue-600 font-semibold transition">Assigned Courses</a>
        <c:if test="${not empty course}">
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}" class="hover:text-blue-600 text-blue-600 font-semibold transition truncate max-w-sm">${course.title}</a>
        </c:if>
        <span>&gt;</span>
        <span class="text-slate-700 font-bold">Quiz</span>
    </nav>
</div>

<div class="w-full px-4 sm:px-6 lg:px-8 pb-16 flex flex-col md:flex-row gap-6">
    <!-- Sidebar giống Lesson Management -->
    <aside class="w-full md:w-44 shrink-0">
        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">

            <nav class="flex flex-col">
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${courseId}"
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition border-l-4 border-transparent">
                    <i class="fa-solid fa-book-open text-slate-400 text-sm"></i>
                    <span>Lesson</span>
                </a>
                <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}"
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-bold bg-slate-100 text-slate-900 border-l-4 border-blue-600">
                    <i class="fa-solid fa-clipboard-question text-blue-600 text-sm"></i>
                    <span>Quiz</span>
                </a>

                <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
                   class="flex items-center space-x-2.5 px-4 py-3.5 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition border-l-4 border-transparent">
                    <i class="fa-solid fa-list-check text-slate-400 text-sm"></i>
                    <span>Question Bank</span>
                </a>
            </nav>
        </div>
    </aside>

    <div class="flex-1 min-w-0">
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-5 mb-6 border-b border-slate-100">
                <div>
                    <h1 class="text-xl sm:text-2xl font-black text-slate-900">Quiz List</h1>
                    <p class="text-sm text-slate-500 mt-1">
                        Danh sách Quiz của khóa học
                        <c:if test="${not empty course}"><span class="font-semibold text-slate-700">${course.title}</span></c:if>
                        </p>
                    </div>
                    <div class="flex flex-wrap items-center gap-2">
                        <a href="${pageContext.request.contextPath}/questions/manage"
                       class="inline-flex items-center justify-center px-5 py-2.5 bg-white hover:bg-slate-50 text-slate-700 border border-slate-200 font-bold rounded-xl text-sm transition shadow-sm space-x-2">
                        <i class="fa-solid fa-list-check text-xs"></i>
                        <span>Question Bank</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/quiz/detail?courseId=${courseId}"
                       class="inline-flex items-center justify-center px-5 py-2.5 bg-slate-900 hover:bg-slate-800 text-white font-bold rounded-xl text-sm transition shadow-sm space-x-2">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>Create Quiz</span>
                    </a>
                </div>
            </div>

            <c:if test="${param.saved == 'true'}">
                <div class="mb-5 p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm font-semibold">Quiz đã được lưu.</div>
            </c:if>
            <c:if test="${param.deleted == 'false'}">
                <div class="mb-5 p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold">Không thể xóa Quiz.</div>
            </c:if>

            <form method="get" action="${pageContext.request.contextPath}/quiz/manage" class="mb-6 flex flex-col sm:flex-row gap-3">
                <input type="hidden" name="courseId" value="${courseId}">
                <input name="keyword" value="${keyword}" placeholder="Search quiz..."
                       class="flex-1 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none text-sm">
                <select name="moduleId" class="sm:w-64 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none">
                    <option value="">All modules</option>
                    <c:forEach var="m" items="${modules}">
                        <option value="${m.id}" ${moduleId eq m.id ? 'selected' : ''}>${m.title}</option>
                    </c:forEach>
                </select>
                <button class="px-5 py-2.5 rounded-xl bg-slate-900 text-white font-bold text-sm hover:bg-slate-800">Search</button>
            </form>

            <div class="overflow-x-auto border border-slate-200 rounded-xl">
                <table class="w-full text-left text-sm text-slate-600">
                    <thead class="bg-slate-50 text-slate-700 text-xs font-bold border-b border-slate-200">
                        <tr>
                            <th class="px-5 py-4 w-14 text-center">#</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Quiz Title</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Module</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Questions</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Time</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Pass Score</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800 w-36">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:choose>
                            <c:when test="${not empty quizzes}">
                                <c:forEach var="q" items="${quizzes}" varStatus="st">
                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="px-5 py-4 text-center text-slate-400 font-semibold">${st.index + 1}</td>
                                        <td class="px-5 py-4">
                                            <div class="font-bold text-slate-800">${q.title}</div>
                                        </td>
                                        <td class="px-5 py-4 text-slate-600">${q.moduleTitle}</td>
                                        <td class="px-5 py-4 text-center font-bold text-slate-700">${q.questionCount}</td>
                                        <td class="px-5 py-4 text-center">${empty q.timeLimit ? 'No limit' : q.timeLimit} <c:if test="${not empty q.timeLimit}">min</c:if></td>
                                        <td class="px-5 py-4 text-center font-bold text-slate-700">${q.passScore}</td>
                                        <td class="px-5 py-4 text-center whitespace-nowrap">
                                            <a href="${pageContext.request.contextPath}/quiz/detail?id=${q.id}&courseId=${courseId}" class="text-blue-600 font-bold hover:underline mr-3">Edit</a>
                                            <a href="${pageContext.request.contextPath}/quiz/manage?action=delete&id=${q.id}&courseId=${courseId}" onclick="return confirm('Xóa quiz này?');" class="text-rose-600 font-bold hover:underline">Delete</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="px-5 py-12 text-center text-slate-400">
                                        Chưa có Quiz nào trong khóa học này.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
