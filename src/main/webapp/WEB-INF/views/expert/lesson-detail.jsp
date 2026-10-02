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
            </nav>
        </div>
    </aside>

    <div class="flex-1 min-w-0">
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="flex items-center gap-4 pb-5 mb-6 border-b border-slate-100">
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}"
                    class="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 hover:text-slate-900 transition text-sm font-semibold shadow-sm group">
                    <i class="fa-solid fa-arrow-left text-xs transition-transform group-hover:-translate-x-1"></i>
                        <span>Quay lại</span>
                </a>
                <h1 class="text-xl sm:text-2xl font-black text-slate-900">Lesson Detail</h1>
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