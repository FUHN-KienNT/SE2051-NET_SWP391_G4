<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
    <!-- Breadcrumb & Top Actions Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
            <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-700 mb-1">
                <a href="${pageContext.request.contextPath}/quiz/manage" class="hover:underline">Quiz Management</a>
                <span>/</span>
                <span class="text-slate-500">${empty quiz ? 'Create Quiz' : 'Edit Quiz'}</span>
            </div>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900">${empty quiz ? 'Tạo bài kiểm tra mới' : 'Chỉnh sửa bài kiểm tra'}</h1>
            <c:if test="${not empty course}">
                <p class="text-xs text-slate-500 mt-1"><i class="fa-solid fa-book-open mr-1 text-slate-400"></i>Khóa học: <span class="font-semibold text-slate-700">${course.title}</span></p>
            </c:if>
        </div>
        <div class="flex flex-wrap items-center gap-2">
            <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}" class="inline-flex items-center px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-sm font-bold text-slate-700 hover:bg-slate-50 shadow-sm transition">
                <i class="fa-solid fa-list-check mr-2 text-slate-500"></i>Ngân hàng câu hỏi
            </a>
            <a href="${pageContext.request.contextPath}/questions/detail?courseId=${courseId}" class="inline-flex items-center px-4 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-bold shadow-sm transition">
                <i class="fa-solid fa-plus mr-2"></i>Tạo câu hỏi mới
            </a>
            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}" class="inline-flex items-center px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-sm font-bold text-slate-700 hover:bg-slate-50 transition">
                <i class="fa-solid fa-arrow-left mr-2 text-slate-400"></i>Danh sách Quiz
            </a>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="mb-5 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold flex items-center gap-3">
            <i class="fa-solid fa-circle-exclamation text-rose-500 text-base"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/quiz/detail" id="quizForm" class="space-y-6">
        <input type="hidden" name="id" value="${quiz.id}">

        <!-- SECTION 1: Quiz Basic Info -->
        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="flex items-center justify-between pb-4 mb-6 border-b border-slate-100">
                <div class="flex items-center gap-2">
                    <span class="w-2.5 h-6 bg-emerald-600 rounded-full inline-block"></span>
                    <h2 class="text-lg font-black text-slate-900">Thông tin cơ bản</h2>
                </div>
                <!-- Primary Action at top right of card -->
                <button type="submit" class="inline-flex items-center px-5 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm shadow-sm transition">
                    <i class="fa-solid fa-floppy-disk mr-2"></i>Lưu bài kiểm tra
                </button>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <!-- Quiz Title -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-bold text-slate-800 mb-2">
                        Tên bài kiểm tra <span class="text-rose-500">*</span>
                    </label>
                    <input name="title" value="${quiz.title}" required maxlength="255" placeholder="ví dụ: Kiểm tra tổng kết Chương 1 - Lập trình Servlet & JSP"
                           class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                </div>

                <!-- Course & Module Selection -->
                <div>
                    <label class="block text-sm font-bold text-slate-800 mb-2">
                        Khóa học
                    </label>
                    <select name="courseId" id="courseSelect" onchange="onCourseChange(this.value)" class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                        <option value="">-- Chọn khóa học --</option>
                        <c:forEach var="c" items="${courses}">
                            <option value="${c.id}" ${(courseId eq c.id or quiz.courseId eq c.id) ? 'selected' : ''}>${c.title}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-bold text-slate-800 mb-2">
                        Chương / Module <span class="text-rose-500">*</span>
                    </label>
                    <select name="moduleId" id="quizModuleSelect" required onchange="onQuizModuleChange(this.value)" class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                        <option value="">-- Chọn module áp dụng --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${(quiz.moduleId eq m.id or defaultFilterModuleId eq m.id) ? 'selected' : ''} data-course="${m.courseId}">${m.title}</option>
                        </c:forEach>
                    </select>
                    <p class="text-xs text-slate-400 mt-1">Khi chọn module, danh sách câu hỏi bên dưới sẽ được tự động lọc theo module tương ứng.</p>
                </div>

                <!-- Status & Image URL -->
                <div>
                    <label class="block text-sm font-bold text-slate-800 mb-2">
                        Trạng thái hiển thị <span class="text-rose-500">*</span>
                    </label>
                    <select name="status" class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                        <option value="published" ${empty quiz or quiz.status eq 'published' ? 'selected' : ''}>Công khai (Published - Học viên có thể làm bài)</option>
                        <option value="draft" ${quiz.status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft - Chỉ Expert thấy)</option>
                        <option value="hidden" ${quiz.status eq 'hidden' ? 'selected' : ''}>Ẩn (Hidden - Giữ lịch sử làm bài, học viên không thể thi mới)</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-bold text-slate-800 mb-2">
                        Ảnh đại diện Quiz (Image URL)
                    </label>
                    <div class="flex items-center gap-3">
                        <div class="relative flex-1">
                            <input name="imageUrl" id="imageUrlInput" value="${quiz.imageUrl}" placeholder="https://images.unsplash.com/photo-..."
                                   oninput="updateImagePreview(this.value)"
                                   class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                        </div>
                        <div class="w-12 h-12 rounded-xl border border-slate-200 bg-slate-100 flex items-center justify-center overflow-hidden shrink-0">
                            <img id="imagePreview" src="${empty quiz.imageUrl ? 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100&auto=format&fit=crop&q=80' : quiz.imageUrl}" 
                                 alt="Preview" class="w-full h-full object-cover"
                                 onerror="this.src='https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100&auto=format&fit=crop&q=80'">
                        </div>
                    </div>
                </div>

                <!-- Time limit & Pass score -->
                <div class="grid grid-cols-2 gap-4 md:col-span-2">
                    <div>
                        <label class="block text-sm font-bold text-slate-800 mb-2">
                            Thời gian làm bài (Phút)
                        </label>
                        <div class="relative">
                            <input type="number" name="timeLimit" min="1" max="600" value="${quiz.timeLimit}" placeholder="30"
                                   class="w-full pl-4 pr-12 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                            <span class="absolute right-3.5 top-3.5 text-xs text-slate-400 font-semibold">phút</span>
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-slate-800 mb-2">
                            Điểm qua môn (Pass score: 0 - 10) <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <input type="number" name="passScore" min="0" max="10" step="0.1" value="${empty quiz.passScore ? '5.0' : quiz.passScore}" required
                                   class="w-full pl-4 pr-12 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                            <span class="absolute right-3.5 top-3.5 text-xs text-slate-400 font-semibold">/ 10</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- SECTION 2: Select Quiz Questions -->
        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <div class="p-6 border-b border-slate-100 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                <div>
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-6 bg-emerald-600 rounded-full inline-block"></span>
                        <h2 class="text-lg font-black text-slate-900">Chọn câu hỏi vào bài kiểm tra</h2>
                    </div>
                    <p class="text-xs text-slate-500 mt-1">
                        Chọn các câu hỏi từ Question Bank. Hệ thống đã tự động lọc trước câu hỏi theo Module đã chọn.
                    </p>
                </div>
                <div class="flex items-center gap-3">
                    <span class="inline-flex items-center px-3 py-1.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        <i class="fa-solid fa-circle-check mr-1.5 text-emerald-600"></i>
                        Đã chọn: <strong id="selectedCountBadge" class="ml-1 text-sm">${empty selectedQuestionIds ? 0 : selectedQuestionIds.size()}</strong> câu
                    </span>
                    <button type="button" onclick="toggleSelectAllVisible()" class="text-xs text-slate-600 font-bold hover:text-emerald-700 border border-slate-200 px-3 py-1.5 rounded-xl bg-slate-50 hover:bg-slate-100 transition">
                        Chọn/Bỏ chọn tất cả
                    </button>
                </div>
            </div>

            <!-- Filter Controls for Questions -->
            <div class="p-4 bg-slate-50 border-b border-slate-200 grid grid-cols-1 sm:grid-cols-12 gap-3 items-center">
                <!-- Search input -->
                <div class="sm:col-span-5 relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-slate-400 text-xs"></i>
                    <input id="questionSearch" oninput="filterQuestions()" placeholder="Tìm nội dung câu hỏi..."
                           class="w-full pl-9 pr-4 py-2 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                </div>

                <!-- Module filter (Pre-filtered to quiz module) -->
                <div class="sm:col-span-4">
                    <select id="questionModuleFilter" onchange="filterQuestions()" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                        <option value="">-- Tất cả Module --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${(not empty defaultFilterModuleId and defaultFilterModuleId eq m.id) or (not empty quiz and quiz.moduleId eq m.id) ? 'selected' : ''}>
                                Module: ${m.title}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Toggle show selected only -->
                <div class="sm:col-span-3 flex items-center gap-2">
                    <label class="flex items-center gap-2 text-xs font-semibold text-slate-700 cursor-pointer select-none">
                        <input type="checkbox" id="onlySelectedFilter" onchange="filterQuestions()" class="w-3.5 h-3.5 rounded accent-emerald-600">
                        <span>Chỉ hiện câu đã chọn</span>
                    </label>
                </div>
            </div>

            <!-- Question list rows -->
            <div class="p-5 max-h-[560px] overflow-y-auto space-y-3" id="questionList">
                <c:forEach var="q" items="${questions}" varStatus="s">
                    <c:set var="selected" value="${selectedQuestionIds.contains(q.id)}"/>
                    <label class="question-item flex items-start gap-3.5 p-4 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition ${selected ? 'bg-emerald-50/40 border-emerald-300 ring-1 ring-emerald-200' : 'bg-white'}"
                           data-text="${q.content}"
                           data-module="${q.moduleId}"
                           data-type="${q.type}"
                           data-selected="${selected ? 'true' : 'false'}">
                        <input type="checkbox" name="questionId" value="${q.id}" ${selected ? 'checked' : ''}
                               onchange="onQuestionCheckChange(this)"
                               class="mt-1 question-check w-4 h-4 accent-emerald-600 rounded cursor-pointer">
                        <div class="min-w-0 flex-1">
                            <div class="flex flex-wrap items-center gap-2 mb-1.5">
                                <!-- Type badge -->
                                <c:choose>
                                    <c:when test="${q.type eq 'fill_in_blank' or q.type eq 'text'}">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold bg-purple-100 text-purple-700">
                                            <i class="fa-solid fa-pen-nib mr-1 text-[10px]"></i>Điền chỗ trống
                                        </span>
                                    </c:when>
                                    <c:when test="${q.type eq 'multiple_choice'}">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold bg-indigo-100 text-indigo-700">
                                            <i class="fa-solid fa-list-check mr-1 text-[10px]"></i>Nhiều đáp án
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold bg-blue-100 text-blue-700">
                                            <i class="fa-solid fa-circle-dot mr-1 text-[10px]"></i>1 đáp án
                                        </span>
                                    </c:otherwise>
                                </c:choose>

                                <!-- Module badge -->
                                <c:if test="${not empty q.moduleTitle}">
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-medium bg-slate-100 text-slate-700 border border-slate-200">
                                        <i class="fa-solid fa-folder mr-1 text-slate-400 text-[10px]"></i>${q.moduleTitle}
                                    </span>
                                </c:if>

                                <!-- Status badge -->
                                <c:if test="${q.status eq 'hidden'}">
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-semibold bg-rose-50 text-rose-600 border border-rose-200">
                                        <i class="fa-solid fa-eye-slash mr-1 text-[10px]"></i>Đã ẩn
                                    </span>
                                </c:if>
                            </div>

                            <div class="font-semibold text-sm text-slate-800 leading-relaxed">${q.content}</div>

                            <c:if test="${not empty q.options}">
                                <div class="mt-2.5 pt-2 border-t border-slate-100 flex flex-wrap gap-2 text-xs text-slate-500">
                                    <c:forEach var="opt" items="${q.options}">
                                        <span class="px-2 py-1 rounded bg-slate-50 border ${opt.correct ? 'border-emerald-300 text-emerald-800 font-semibold bg-emerald-50/50' : 'border-slate-200'}">
                                            <c:if test="${opt.correct}"><i class="fa-solid fa-check text-emerald-600 mr-1"></i></c:if>
                                            ${opt.optionText}
                                        </span>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </label>
                </c:forEach>

                <c:if test="${empty questions}">
                    <div class="text-center py-12 text-slate-400 text-sm">
                        <i class="fa-solid fa-folder-open text-3xl mb-2 text-slate-300 block"></i>
                        Chưa có câu hỏi nào trong Question Bank. 
                        <a class="text-emerald-700 font-bold hover:underline" href="${pageContext.request.contextPath}/questions/detail?courseId=${courseId}">
                            Tạo câu hỏi đầu tiên
                        </a>.
                    </div>
                </c:if>
            </div>
            
            <div id="noQuestionMatch" class="hidden p-8 text-center text-slate-400 text-sm">
                <i class="fa-solid fa-filter-circle-xmark text-2xl text-slate-300 mb-2 block"></i>
                Không có câu hỏi nào khớp với bộ lọc module hoặc từ khóa tìm kiếm.
            </div>
        </section>

        <!-- Bottom Action Buttons -->
        <div class="flex items-center justify-between pt-2">
            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}" class="px-6 py-3 rounded-xl border border-slate-200 text-slate-700 font-bold text-sm bg-white hover:bg-slate-50 shadow-sm transition">
                <i class="fa-solid fa-arrow-left mr-2 text-slate-400"></i>Quay lại danh sách
            </a>
            <div class="flex items-center gap-3">
                <button type="submit" class="px-8 py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm shadow-md transition">
                    <i class="fa-solid fa-floppy-disk mr-2"></i>Lưu bài kiểm tra
                </button>
            </div>
        </div>
    </form>
</main>

<script>
function updateImagePreview(url) {
    const preview = document.getElementById('imagePreview');
    if (url && url.trim().length > 0) {
        preview.src = url.trim();
    } else {
        preview.src = 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100&auto=format&fit=crop&q=80';
    }
}

function onQuizModuleChange(selectedModuleId) {
    const moduleFilter = document.getElementById('questionModuleFilter');
    if (moduleFilter && selectedModuleId) {
        moduleFilter.value = selectedModuleId;
        filterQuestions();
    }
}

function onCourseChange(courseId) {
    if (!courseId) return;
    const currentUrl = new URL(window.location.href);
    currentUrl.searchParams.set('courseId', courseId);
    window.location.href = currentUrl.toString();
}

function onQuestionCheckChange(checkbox) {
    const item = checkbox.closest('.question-item');
    if (checkbox.checked) {
        item.classList.add('bg-emerald-50/40', 'border-emerald-300', 'ring-1', 'ring-emerald-200');
        item.classList.remove('bg-white');
        item.dataset.selected = 'true';
    } else {
        item.classList.remove('bg-emerald-50/40', 'border-emerald-300', 'ring-1', 'ring-emerald-200');
        item.classList.add('bg-white');
        item.dataset.selected = 'false';
    }
    updateSelectedCount();
}

function updateSelectedCount() {
    const checked = document.querySelectorAll('.question-check:checked').length;
    const badge = document.getElementById('selectedCountBadge');
    if (badge) badge.textContent = checked;
}

function filterQuestions() {
    const keyword = (document.getElementById('questionSearch').value || '').toLowerCase().trim();
    const targetModule = (document.getElementById('questionModuleFilter').value || '').trim();
    const onlySelected = document.getElementById('onlySelectedFilter') ? document.getElementById('onlySelectedFilter').checked : false;

    let visibleCount = 0;
    const items = document.querySelectorAll('.question-item');
    items.forEach(function(row) {
        const text = (row.dataset.text || '').toLowerCase();
        const mod = (row.dataset.module || '').trim();
        const isSelected = row.dataset.selected === 'true';

        let matchesKeyword = keyword === '' || text.includes(keyword);
        let matchesModule = targetModule === '' || mod === targetModule;
        let matchesSelected = !onlySelected || isSelected;

        if (matchesKeyword && matchesModule && matchesSelected) {
            row.style.display = 'flex';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });

    const noMatchMsg = document.getElementById('noQuestionMatch');
    if (noMatchMsg) {
        if (visibleCount === 0 && items.length > 0) {
            noMatchMsg.classList.remove('hidden');
        } else {
            noMatchMsg.classList.add('hidden');
        }
    }
}

function toggleSelectAllVisible() {
    const visibleCheckboxes = Array.from(document.querySelectorAll('.question-item'))
        .filter(item => item.style.display !== 'none')
        .map(item => item.querySelector('.question-check'));

    if (visibleCheckboxes.length === 0) return;

    const allChecked = visibleCheckboxes.every(cb => cb.checked);
    visibleCheckboxes.forEach(cb => {
        cb.checked = !allChecked;
        onQuestionCheckChange(cb);
    });
}

// Initial filter execution on DOM load
document.addEventListener('DOMContentLoaded', function() {
    filterQuestions();
    updateSelectedCount();
});
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
