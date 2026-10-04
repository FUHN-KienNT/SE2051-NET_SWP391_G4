<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-16 flex flex-col lg:flex-row gap-6">
    <aside class="w-full lg:w-52 shrink-0">
        <div class="bg-surface-card rounded-xl border border-border-default overflow-hidden shadow-sm">
            <nav class="flex flex-wrap lg:flex-col p-2 gap-1">
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}"
                   class="flex items-center space-x-2.5 rounded-lg px-4 py-3 text-sm font-bold bg-brand-50 text-brand-900 border-l-4 border-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-book-open text-brand-700 text-sm"></i>
                    <span>Lesson</span>
                </a>
                <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${course.id}"
                   class="flex items-center space-x-2.5 rounded-lg px-4 py-3 text-sm font-medium text-text-secondary hover:bg-surface hover:text-text-primary transition border-l-4 border-transparent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-clipboard-question text-text-secondary text-sm"></i>
                    <span>Quiz</span>
                </a>
            </nav>
        </div>
    </aside>

    <div class="flex-1 min-w-0">
        <div class="bg-surface-card rounded-xl border border-border-default shadow-sm p-6 sm:p-8">
            <div class="flex flex-wrap items-center gap-4 pb-5 mb-6 border-b border-border-default">
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}"
                    class="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-lg border border-border-default bg-surface-card hover:bg-surface text-text-secondary hover:text-text-primary transition text-sm font-semibold shadow-sm group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-arrow-left text-xs transition-transform group-hover:-translate-x-1"></i>
                        <span>Quay lại</span>
                </a>
                <h1 class="text-xl sm:text-2xl font-bold text-text-primary">Lesson Detail</h1>
            </div>
            <form action="${pageContext.request.contextPath}/lessons/manage" method="POST" class="space-y-6 w-full">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="courseId" value="${course.id}">
                <input type="hidden" name="id" value="${lesson != null ? lesson.id : ''}">

                <div>
                    <label for="moduleId" class="block text-sm font-semibold text-text-primary mb-2">Module <span class="text-status-danger">*</span></label>
                    <select id="moduleId" name="moduleId" required
                            class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition">
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
                    <label for="title" class="block text-sm font-semibold text-text-primary mb-2">Lesson Title <span class="text-status-danger">*</span></label>
                    <input type="text" id="title" name="title" required
                           value="${lesson != null ? lesson.title : ''}"
                           placeholder="Nhập tiêu đề bài giảng..."
                           class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition">
                </div>

                <div>
                    <label for="content" class="block text-sm font-semibold text-text-primary mb-2">Content <span class="text-status-danger">*</span></label>
                    <textarea id="content" name="content" rows="10" required
                              placeholder="Enter lesson content (text, or a video/document link)..."
                              class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition">${lesson != null ? lesson.content : ''}</textarea>
                </div>

                <!-- Field 4: Order Index -->
                <div class="w-44">
                    <label for="orderIndex" class="block text-sm font-semibold text-text-primary mb-2">Order Index</label>
                    <input type="number" id="orderIndex" name="orderIndex" min="1"
                           value="${lesson != null ? lesson.orderIndex : defaultOrderIndex}"
                           class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition text-center font-bold">
                </div>

                <div class="pt-6 flex flex-wrap items-center gap-3 border-t border-border-default">
                    <button type="submit"
                            class="px-6 py-2.5 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-lg text-sm transition shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                        Save
                    </button>
                    <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}"
                       class="px-6 py-2.5 bg-surface-card border border-border-default text-slate-700 hover:bg-surface font-semibold rounded-lg text-sm transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</main>

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