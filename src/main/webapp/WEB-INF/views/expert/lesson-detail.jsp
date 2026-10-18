<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="lessonHtml" uri="/WEB-INF/lesson-html.tld" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/lesson-content.css?v=2">

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
            <c:if test="${not empty saveError}">
                <p role="alert" class="mb-4 text-sm text-status-danger">
                    <c:out value="${saveError}" />
                </p>
            </c:if>
            <form action="${pageContext.request.contextPath}/lessons/manage" method="POST" class="space-y-6 w-full">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="csrfToken" value="${sessionScope.lessonActionToken}">
                <input type="hidden" name="courseId" value="${course.id}">
                <input type="hidden" name="id" value="${lesson != null ? lesson.id : ''}">

                <div>
                    <label for="moduleId" class="block text-sm font-semibold text-text-primary mb-2">Module <span class="text-status-danger">*</span></label>
                    <select id="moduleId" name="moduleId" required
                            data-error="${fn:escapeXml(fieldErrors.moduleId)}"
                            class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition">
                        <option value="" data-next-order="1">-- Chọn Module cho bài giảng --</option>
                        <c:forEach var="m" items="${modules}">
                            <c:set var="nextOrder" value="1" />
                            <c:if test="${not empty m.lessons}">
                                <c:forEach var="l" items="${m.lessons}">
                                    <c:if test="${lesson == null || l.id ne lesson.id}">
                                        <c:set var="nextOrder" value="${nextOrder + 1}" />
                                    </c:if>
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
                    data-error="${fn:escapeXml(fieldErrors.title)}"
                           value="${lesson != null ? lesson.title : ''}"
                           placeholder="Nhập tiêu đề bài giảng..."
                           class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition">
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                        <label for="durationMinutes" class="block text-sm font-semibold text-text-primary mb-2">
                            Estimated Duration (minutes) <span class="text-status-danger">*</span>
                        </label>
                        <input type="number" id="durationMinutes" name="durationMinutes" min="1" max="2147483647" step="1" required
                               data-error="${fn:escapeXml(fieldErrors.durationMinutes)}"
                               value="${lesson != null ? lesson.durationMinutes : ''}"
                               class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700">
                    </div>
                    <div>
                        <label for="publicationStatus" class="block text-sm font-semibold text-text-primary mb-2">
                            Status
                        </label>
                        <input type="text" id="publicationStatus" readonly
                               value="${lesson == null ? 'Draft' : fn:escapeXml(lesson.publicationStatus)}"
                               class="w-full px-4 py-2.5 bg-surface border border-border-default rounded-lg text-sm text-text-secondary">
                    </div>
                </div>

                <div class="w-44">
                    <label for="orderIndex" class="block text-sm font-semibold text-text-primary mb-2">Order Index</label>
                    <input type="number" id="orderIndex" name="orderIndex" min="1"
                    data-error="${fn:escapeXml(fieldErrors.orderIndex)}"
                           value="${lesson != null ? lesson.orderIndex : defaultOrderIndex}"
                           class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition text-center font-bold">
                </div>

                <div>
                    <label id="contentLabel" for="content" class="block text-sm font-semibold text-text-primary mb-2">Content <span class="text-status-danger">*</span></label>
                    <div id="lessonEditorWrapper" class="relative hidden">
                        <div id="lessonToolbar" role="toolbar" aria-label="Content formatting">
                            <span class="ql-formats">
                                <select class="ql-header" aria-label="Paragraph style">
                                    <option selected>Paragraph</option><option value="2">Heading 2</option><option value="3">Heading 3</option>
                                </select>
                            </span>
                            <span class="ql-formats">
                                <button type="button" class="ql-bold" aria-label="Bold" title="Bold"></button>
                                <button type="button" class="ql-italic" aria-label="Italic" title="Italic"></button>
                                <button type="button" class="ql-underline" aria-label="Underline" title="Underline"></button>
                            </span>
                            <span class="ql-formats">
                                <button type="button" class="ql-list" value="ordered" aria-label="Numbered list" title="Numbered list"></button>
                                <button type="button" class="ql-list" value="bullet" aria-label="Bullet list" title="Bullet list"></button>
                                <button type="button" class="ql-blockquote" aria-label="Quote" title="Quote"></button>
                            </span>
                            <span class="ql-formats">
                                <button type="button" class="ql-link" aria-label="Insert link" title="Insert link"></button>
                                <button type="button" class="ql-clean" aria-label="Clear formatting" title="Clear formatting"></button>
                            </span>
                        </div>
                        <div id="lessonEditor"></div>
                        <input id="contentValidation" type="text" tabindex="-1" aria-label="Content" class="absolute bottom-0 left-0 w-px h-px opacity-0" disabled>
                    </div>
                    <textarea id="content" name="content" rows="10" required
                    data-error="${fn:escapeXml(fieldErrors.content)}"
                              placeholder="Enter lesson content..."
                              class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition"><c:out value="${lessonHtml:sanitize(lesson.content)}" /></textarea>
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

<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/lesson-editor.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const moduleSelect = document.getElementById('moduleId');
        const orderInput = document.getElementById('orderIndex');
        const fields = document.querySelectorAll('[data-error]');
        let firstError = null;

        fields.forEach(field => {
            if (field.id === 'content' && field.hidden) return;
            if (field.dataset.error) {
                field.setCustomValidity(field.dataset.error);
                if (!firstError) firstError = field;
            }
            const clearError = () => field.setCustomValidity('');
            field.addEventListener('input', clearError);
            field.addEventListener('change', clearError);
        });

        moduleSelect.addEventListener('change', function () {
            const option = this.options[this.selectedIndex];
            orderInput.value = option.dataset.nextOrder || '1';
            orderInput.setCustomValidity('');
        });

        if (firstError) {
            firstError.focus();
            firstError.reportValidity();
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
