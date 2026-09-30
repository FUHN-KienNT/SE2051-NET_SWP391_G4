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
                <div class="absolute right-0 mt-1 w-52 bg-white border border-slate-200 rounded-xl shadow-xl py-2 hidden group-hover:block transition-all z-50">
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
        <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}" class="hover:text-blue-600 text-blue-600 font-semibold transition truncate max-w-sm">${not empty course ? course.title : 'Course'}</a>
        <span>&gt;</span>
        <span class="text-slate-700 font-bold">Lesson Detail</span>
    </nav>
</div>

<div class="w-full px-4 sm:px-6 lg:px-8 pb-16 flex flex-col md:flex-row gap-6">
    <!-- Sidebar gọn bên trái -->
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
            </nav>
        </div>
    </aside>

    <div class="flex-1 min-w-0">
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="flex items-center justify-between pb-5 mb-6 border-b border-slate-100">
                <h1 class="text-xl sm:text-2xl font-black text-slate-900">Lesson Detail</h1>
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}" 
                   class="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 hover:text-slate-900 transition text-sm font-semibold shadow-sm group">
                    <i class="fa-solid fa-arrow-left text-xs transition-transform group-hover:-translate-x-1"></i>
                    <span>Quay lại</span>
                </a>
            </div>

            <form action="${pageContext.request.contextPath}/lessons/manage" method="POST" class="space-y-6 w-full">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="courseId" value="${course.id}">
                <input type="hidden" name="id" value="${lesson != null ? lesson.id : ''}">

                <div>
                    <label for="moduleId" class="block text-sm font-bold text-slate-800 mb-2">Module <span class="text-rose-500">*</span></label>
                    <select id="moduleId" name="moduleId" required 
                            class="w-full px-4 py-2.5 bg-slate-50 border border-slate-300 rounded-xl text-sm text-slate-800 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition">
                        <option value="" data-next-order="1">-- Chọn Module cho bài giảng --</option>
                        <c:forEach var="m" items="${modules}">
                            <c:set var="nextOrder" value="1" />
                            <c:if test="${not empty m.lessons}">
                                <c:forEach var="l" items="${m.lessons}">
                                    <c:set var="nextOrder" value="${l.orderIndex + 1}" />
                                </c:forEach>
                            </c:if>
                            <option value="${m.id}" data-next-order="${nextOrder}" ${lesson != null && lesson.moduleId eq m.id ? 'selected' : ''}>
                                ${m.title}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label for="title" class="block text-sm font-bold text-slate-800 mb-2">Lesson Title <span class="text-rose-500">*</span></label>
                    <input type="text" id="title" name="title" required 
                           value="${lesson != null ? lesson.title : ''}"
                           placeholder="Nhập tiêu đề bài giảng..." 
                           class="w-full px-4 py-2.5 bg-slate-50 border border-slate-300 rounded-xl text-sm text-slate-800 placeholder-slate-400 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition">
                </div>

                <div>
                    <label for="content" class="block text-sm font-bold text-slate-800 mb-2">Content <span class="text-rose-500">*</span></label>
                    <textarea id="content" name="content" rows="10" required
                              placeholder="Enter lesson content (text, or a video/document link)..."
                              class="w-full px-4 py-2.5 bg-slate-50 border border-slate-300 rounded-xl text-sm text-slate-800 placeholder-slate-400 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition">${lesson != null ? lesson.content : ''}</textarea>
                </div>

                <!-- Field 4: Order Index -->
                <div class="w-44">
                    <label for="orderIndex" class="block text-sm font-bold text-slate-800 mb-2">Order Index</label>
                    <input type="number" id="orderIndex" name="orderIndex" min="1" 
                           value="${lesson != null ? lesson.orderIndex : defaultOrderIndex}"
                           class="w-full px-4 py-2.5 bg-slate-50 border border-slate-300 rounded-xl text-sm text-slate-800 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-center font-bold">
                </div>

                <div class="pt-4 flex items-center space-x-3 border-t border-slate-100">
                    <button type="submit" 
                            class="px-6 py-2.5 bg-slate-900 hover:bg-slate-800 text-white font-bold rounded-xl text-sm transition shadow-sm">
                        Save
                    </button>
                    <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}" 
                       class="px-6 py-2.5 bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 font-semibold rounded-xl text-sm transition">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>
                       
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const moduleSelect = document.getElementById('moduleId');
        const orderInput = document.getElementById('orderIndex');
        const lessonIdInput = document.querySelector('input[name="id"]');
        
        if (moduleSelect && orderInput) {
            moduleSelect.addEventListener('change', function() {
                // Khi tạo mới (chưa có lessonId), tự động cập nhật orderIndex theo module được chọn
                if (!lessonIdInput || !lessonIdInput.value) {
                    const selectedOption = this.options[this.selectedIndex];
                    const nextOrder = selectedOption ? selectedOption.getAttribute('data-next-order') : '1';
                    orderInput.value = nextOrder || 1;
                }
            });
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />