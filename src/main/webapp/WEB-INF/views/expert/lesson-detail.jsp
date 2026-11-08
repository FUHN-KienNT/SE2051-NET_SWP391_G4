<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="lessonHtml" uri="/WEB-INF/lesson-html.tld" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/lesson-content.css?v=2">

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-16">
    <div class="min-w-0">
        <div class="bg-surface-card rounded-xl border border-border-default shadow-sm p-6 sm:p-8">
            <div class="flex flex-wrap items-center gap-4 pb-5 mb-6 border-b border-border-default">
                <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}"
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
            <form action="${pageContext.request.contextPath}/expert/lessons" method="POST" novalidate class="space-y-6 w-full">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="csrfToken" value="${sessionScope.lessonActionToken}">
                <input type="hidden" name="courseId" value="${course.id}">
                <input type="hidden" name="id" value="${lesson != null ? lesson.id : ''}">

                <div>
                    <label for="moduleId" class="block text-sm font-semibold text-text-primary mb-2">Module <span class="text-status-danger">*</span></label>
                    <select id="moduleId" name="moduleId" required
                            aria-invalid="${not empty fieldErrors.moduleId}" aria-describedby="moduleId-error"
                            class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition">
                        <option value="" data-next-order="1">-- Chọn Module cho bài giảng --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" data-next-order="${nextLessonOrders[m.id]}" ${lesson != null && lesson.moduleId eq m.id ? 'selected' : ''}>
                                <c:out value="${m.title}" />
                            </option>
                        </c:forEach>
                    </select>
                    <p id="moduleId-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.moduleId ? 'hidden' : ''}>
                        <c:out value="${fieldErrors.moduleId}" />
                    </p>
                </div>

                <div>
                    <label for="title" class="block text-sm font-semibold text-text-primary mb-2">Lesson Title <span class="text-status-danger">*</span></label>
                    <input type="text" id="title" name="title" required
                    aria-invalid="${not empty fieldErrors.title}" aria-describedby="title-error"
                           value="${fn:escapeXml(lesson != null ? lesson.title : '')}"
                           placeholder="Nhập tiêu đề bài giảng..."
                           class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition">
                    <p id="title-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.title ? 'hidden' : ''}>
                        <c:out value="${fieldErrors.title}" />
                    </p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div>
                        <label for="orderIndex" class="block text-sm font-semibold text-text-primary mb-2">Order Index</label>
                        <input type="number" id="orderIndex" name="orderIndex" min="1"
                               aria-invalid="${not empty fieldErrors.orderIndex}" aria-describedby="orderIndex-error"
                               value="${lesson != null ? lesson.orderIndex : defaultOrderIndex}"
                               class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700">
                        <p id="orderIndex-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.orderIndex ? 'hidden' : ''}>
                            <c:out value="${fieldErrors.orderIndex}" />
                        </p>
                    </div>
                    <div>
                        <label for="durationMinutes" class="block text-sm font-semibold text-text-primary mb-2">
                            Estimated Duration (minutes) <span class="text-status-danger">*</span>
                        </label>
                        <input type="number" id="durationMinutes" name="durationMinutes" min="1" max="1440" step="1" required
                               aria-invalid="${not empty fieldErrors.durationMinutes}" aria-describedby="durationMinutes-error"
                               value="${lesson != null ? lesson.durationMinutes : ''}"
                               class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700">
                        <p id="durationMinutes-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.durationMinutes ? 'hidden' : ''}>
                            <c:out value="${fieldErrors.durationMinutes}" />
                        </p>
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

                <div>
                    <label for="lessonType" class="block text-sm font-semibold text-text-primary mb-2">Type <span class="text-status-danger">*</span></label>
                    <select id="lessonType" name="type" required aria-invalid="${not empty fieldErrors.type}" aria-describedby="lessonType-error"
                            class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                        <option value="content" ${empty lesson or lesson.type eq 'content' ? 'selected' : ''}>Content</option>
                        <option value="video" ${lesson.type eq 'video' ? 'selected' : ''}>Video</option>
                        <option value="quiz" ${lesson.type eq 'quiz' ? 'selected' : ''}>Quiz</option>
                    </select>
                    <p id="lessonType-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.type ? 'hidden' : ''}>
                        <c:out value="${fieldErrors.type}" />
                    </p>
                </div>

                <div id="videoFields" ${lesson.type ne 'video' ? 'hidden' : ''}>
                    <label for="videoUrl" class="block text-sm font-semibold text-text-primary mb-2">YouTube URL <span class="text-status-danger">*</span></label>
                    <input type="url" id="videoUrl" name="videoUrl" value="${fn:escapeXml(lesson.videoUrl)}"
                           aria-invalid="${not empty fieldErrors.videoUrl}" aria-describedby="videoUrl-error" placeholder="https://www.youtube.com/watch?v=..."
                           class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                    <p id="videoUrl-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.videoUrl ? 'hidden' : ''}>
                        <c:out value="${fieldErrors.videoUrl}" />
                    </p>
                </div>

                <div id="quizFields" ${lesson.type ne 'quiz' ? 'hidden' : ''}>
                    <label for="quizId" class="block text-sm font-semibold text-text-primary mb-2">Quiz <span class="text-status-danger">*</span></label>
                    <select id="quizId" name="quizId" aria-invalid="${not empty fieldErrors.quizId}" aria-describedby="quizId-error"
                            class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700">
                        <option value="">-- Select a quiz --</option>
                        <c:forEach var="q" items="${lessonQuizzes}">
                            <option value="${q.id}" data-module-id="${q.moduleId}" ${lesson.quizId eq q.id ? 'selected' : ''}><c:out value="${q.title}" /></option>
                        </c:forEach>
                    </select>
                    <p id="quizId-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.quizId ? 'hidden' : ''}>
                        <c:out value="${fieldErrors.quizId}" />
                    </p>
                </div>

                <div id="contentFields">
                    <label id="contentLabel" for="content" class="block text-sm font-semibold text-text-primary mb-2">Content <span id="contentRequired" class="text-status-danger">*</span></label>
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
                    </div>
                    <textarea id="content" name="content" rows="10" required
                    aria-invalid="${not empty fieldErrors.content}" aria-describedby="content-error"
                              placeholder="Enter lesson content..."
                              class="w-full px-4 py-2.5 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition"><c:out value="${lessonHtml:sanitize(lesson.content)}" /></textarea>
                    <p id="content-error" class="mt-1 text-sm text-status-danger" ${empty fieldErrors.content ? 'hidden' : ''}>
                        <c:out value="${fieldErrors.content}" />
                    </p>
                </div>

                <div class="pt-6 flex flex-wrap items-center gap-3 border-t border-border-default">
                    <button type="submit"
                            class="px-6 py-2.5 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-lg text-sm transition shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                        Save
                    </button>
                    <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}"
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
<script src="${pageContext.request.contextPath}/assets/js/lesson-type.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const moduleSelect = document.getElementById('moduleId');
        const orderInput = document.getElementById('orderIndex');
        moduleSelect.addEventListener('change', function () {
            const option = this.options[this.selectedIndex];
            orderInput.value = option.dataset.nextOrder || '1';
        });
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
