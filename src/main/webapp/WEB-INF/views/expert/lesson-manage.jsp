<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<header class="sticky top-0 z-50 bg-white border-b border-slate-200 shadow-sm">
    <div class="w-full px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
            <div class="flex items-center space-x-3 shrink-0">
                <a href="${pageContext.request.contextPath}/expert/dashboard" class="flex items-center space-x-2.5">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-600 flex items-center justify-center text-white shadow-md shadow-blue-500/20">
                        <i class="fa-solid fa-graduation-cap text-xl"></i>
                    </div>
                    <span class="text-2xl font-black bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">LearnHub</span>
                </a>
                <span class="px-2.5 py-0.5 text-xs font-bold bg-purple-50 text-purple-700 rounded-full border border-purple-200">
                    Expert
                </span>
            </div>

            <div class="relative group">
                <button class="flex items-center space-x-2.5 p-1.5 rounded-xl hover:bg-slate-50 transition focus:outline-none">
                    <div class="w-9 h-9 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-600 text-white font-bold flex items-center justify-center shadow-sm text-sm">
                        ${not empty sessionScope.currentUser ? fn:substring(sessionScope.currentUser.username, 0, 1) : 'E'}
                    </div>
                    <div class="hidden sm:block text-left">
                        <p class="text-sm font-bold text-slate-800 leading-tight">
                            ${not empty sessionScope.currentUser ? sessionScope.currentUser.username : 'Subject Expert'}
                        </p>
                        <p class="text-[11px] font-semibold text-purple-600">Subject Expert</p>
                    </div>
                    <i class="fa-solid fa-angle-down text-xs text-slate-400 ml-1 transition-transform group-hover:rotate-180"></i>
                </button>
                <div class="absolute right-0 mt-1 w-52 bg-white border border-slate-200 rounded-xl shadow-xl py-2 opacity-0 invisible pointer-events-none group-hover:opacity-100 group-hover:visible group-hover:pointer-events-auto transition-all duration-200 ease-out z-50 before:content-[''] before:absolute before:-top-3 before:left-0 before:right-0 before:h-3">
                    <div class="px-4 py-2 border-b border-slate-100">
                        <p class="text-[11px] uppercase font-bold text-slate-400">Tài khoản</p>
                        <p class="text-sm font-semibold text-slate-800 truncate">${sessionScope.currentUser.email}</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/expert/dashboard" class="flex items-center px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition">
                        <i class="fa-solid fa-chalkboard-user w-5 text-slate-400 mr-2"></i> Khóa học được giao
                    </a>
                    <div class="border-t border-slate-100 my-1"></div>
                    <a href="${pageContext.request.contextPath}/logout" class="flex items-center px-4 py-2 text-sm text-rose-600 hover:bg-rose-50 transition">
                        <i class="fa-solid fa-arrow-right-from-bracket w-5 mr-2"></i> Đăng xuất
                    </a>
                </div>
            </div>
        </div>
    </div>
</header>

<div class="w-full px-4 sm:px-6 lg:px-8 pt-4 pb-3">
    <nav class="flex items-center text-xs text-slate-400 font-medium space-x-2">
        <a href="${pageContext.request.contextPath}/expert/dashboard" class="hover:text-blue-600 text-blue-600 font-semibold transition">Assigned Courses</a>
        <span>&gt;</span>
        <span class="text-slate-700 font-bold truncate max-w-xl">${not empty course ? course.title : 'Course Title'}</span>
    </nav>
</div>

<div class="w-full px-4 sm:px-6 lg:px-8 pb-16 flex flex-col md:flex-row gap-6">
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
            <h1 class="text-xl sm:text-2xl font-black text-slate-900 mb-6">Lesson List</h1>

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