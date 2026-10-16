<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="w-full px-4 sm:px-6 lg:px-8 pt-6 pb-16 flex flex-col md:flex-row gap-6">
    <!-- Sidebar Navigation -->
    <aside class="w-full md:w-52 shrink-0">
        <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm p-2 space-y-1">
            <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${courseId}"
               class="flex items-center space-x-3 px-3.5 py-3 text-sm font-semibold text-slate-600 hover:bg-slate-50 hover:text-slate-900 rounded-xl transition">
                <i class="fa-solid fa-book-open text-slate-400 w-4 text-center"></i>
                <span>Bài học (Lesson)</span>
            </a>
            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}"
               class="flex items-center space-x-3 px-3.5 py-3 text-sm font-semibold text-slate-600 hover:bg-slate-50 hover:text-slate-900 rounded-xl transition">
                <i class="fa-solid fa-clipboard-question text-slate-400 w-4 text-center"></i>
                <span>Bài thi (Quiz)</span>
            </a>
            <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
               class="flex items-center space-x-3 px-3.5 py-3 text-sm font-bold bg-emerald-50 text-emerald-800 rounded-xl transition">
                <i class="fa-solid fa-list-check text-emerald-600 w-4 text-center"></i>
                <span>Ngân hàng câu hỏi</span>
            </a>
        </div>
    </aside>

    <!-- Main Form Area -->
    <main class="flex-1 min-w-0 max-w-4xl">
        <!-- Breadcrumb & Top Actions Header -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
            <div>
                <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-700 mb-1">
                    <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}" class="hover:underline">Question Bank</a>
                    <span>/</span>
                    <span class="text-slate-500">${empty question ? 'Create Question' : 'Edit Question'}</span>
                </div>
                <h1 class="text-2xl sm:text-3xl font-black text-slate-900">
                    ${empty question ? 'Tạo câu hỏi mới' : 'Chỉnh sửa câu hỏi'}
                </h1>
            </div>

            <div class="flex flex-wrap items-center gap-2.5">
                <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}"
                   class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-50 transition shadow-sm">
                    <i class="fa-solid fa-clipboard-question mr-1.5 text-slate-500"></i>Quản lý Quiz
                </a>
                <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
                   class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-50 transition shadow-sm">
                    <i class="fa-solid fa-arrow-left mr-1.5 text-slate-500"></i>Danh sách câu hỏi
                </a>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="mb-5 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold flex items-center gap-3">
                <i class="fa-solid fa-circle-exclamation text-rose-500 text-base"></i>
                <span>${error}</span>
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/questions/detail" id="questionForm" class="space-y-6">
            <input type="hidden" name="id" value="${question.id}">

            <!-- CARD 1: Basic Classification & Status -->
            <section class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
                <div class="flex items-center justify-between pb-4 mb-6 border-b border-slate-100">
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-6 bg-emerald-600 rounded-full inline-block"></span>
                        <h2 class="text-lg font-black text-slate-900">Thông tin phân loại & Trạng thái</h2>
                    </div>
                    <!-- Top Save Button -->
                    <button type="submit" class="inline-flex items-center px-5 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs shadow-sm transition">
                        <i class="fa-solid fa-floppy-disk mr-2"></i>Lưu câu hỏi
                    </button>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <!-- Course Filter / Selector -->
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">
                            Khóa học áp dụng
                        </label>
                        <select name="courseId" id="courseSelect" onchange="filterModulesByCourse(this.value)"
                                class="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 transition">
                            <option value="">-- Chọn khóa học --</option>
                            <c:forEach var="c" items="${courses}">
                                <option value="${c.id}" ${(courseId eq c.id.toString() or question.courseId eq c.id) ? 'selected' : ''}>${c.title}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Module Selector -->
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">
                            Chương / Module <span class="text-rose-500">*</span>
                        </label>
                        <select name="moduleId" id="moduleSelect" required
                                class="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 transition">
                            <option value="">-- Chọn module --</option>
                            <c:forEach var="m" items="${modules}">
                                <option value="${m.id}" data-course="${m.courseId}" ${(question.moduleId eq m.id or moduleId eq m.id) ? 'selected' : ''}>${m.title}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Status Selector -->
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">
                            Trạng thái câu hỏi <span class="text-rose-500">*</span>
                        </label>
                        <select name="status" class="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 transition">
                            <option value="public" ${empty question.status or question.status eq 'public' ? 'selected' : ''}>Công khai (Public)</option>
                            <option value="draft" ${question.status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft)</option>
                            <option value="hidden" ${question.status eq 'hidden' ? 'selected' : ''}>Đã ẩn (Hidden)</option>
                        </select>
                    </div>
                </div>
            </section>

            <!-- CARD 2: Question Content & Type -->
            <section class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-5">
                <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-6 bg-emerald-600 rounded-full inline-block"></span>
                        <h2 class="text-lg font-black text-slate-900">Nội dung câu hỏi</h2>
                    </div>
                    <!-- Live Word Counter with limit -->
                    <div id="wordCountBadge" class="inline-flex items-center px-3 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-700 border border-slate-200 transition-colors">
                        <i class="fa-solid fa-pen-nib mr-1.5 text-slate-400"></i>
                        Số từ: <span id="wordCountNum" class="mx-1">0</span> / 120 từ
                    </div>
                </div>

                <!-- Textarea for Question Content -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">
                        Nội dung chi tiết / Tiêu đề câu hỏi <span class="text-rose-500">*</span>
                    </label>
                    <textarea name="content" id="questionContent" rows="4" required
                              oninput="onContentChange()"
                              placeholder="Nhập nội dung câu hỏi tại đây... (Ví dụ: Trong Java Servlet, phương thức nào được gọi khi có yêu cầu HTTP GET?)"
                              class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none text-sm transition leading-relaxed">${question.content}</textarea>
                    
                    <div id="wordCountAlert" class="hidden mt-1.5 text-xs font-bold text-rose-600 flex items-center gap-1.5">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <span>Nội dung đã vượt quá giới hạn 120 từ! Vui lòng rút gọn nội dung câu hỏi.</span>
                    </div>
                </div>

                <!-- Question Type Selection -->
                <div class="pt-2">
                    <label class="block text-xs font-bold text-slate-700 mb-2">
                        Loại câu hỏi <span class="text-rose-500">*</span>
                    </label>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                        <label class="type-card flex items-start gap-3 p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition">
                            <input type="radio" name="type" value="single_choice"
                                   ${empty question.type or question.type eq 'single_choice' ? 'checked' : ''}
                                   onchange="onTypeChanged('single_choice')" class="mt-1 accent-emerald-600">
                            <div>
                                <div class="font-bold text-xs text-slate-800">Một đáp án đúng (Single)</div>
                                <div class="text-[11px] text-slate-400 mt-0.5">Chọn duy nhất 1 phương án chính xác trong danh sách lựa chọn.</div>
                            </div>
                        </label>

                        <label class="type-card flex items-start gap-3 p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition">
                            <input type="radio" name="type" value="multiple_choice"
                                   ${question.type eq 'multiple_choice' ? 'checked' : ''}
                                   onchange="onTypeChanged('multiple_choice')" class="mt-1 accent-emerald-600">
                            <div>
                                <div class="font-bold text-xs text-slate-800">Nhiều đáp án đúng (Multiple)</div>
                                <div class="text-[11px] text-slate-400 mt-0.5">Học viên cần chọn đủ các phương án đúng.</div>
                            </div>
                        </label>

                        <label class="type-card flex items-start gap-3 p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition">
                            <input type="radio" name="type" value="fill_in_blank"
                                   ${question.type eq 'fill_in_blank' or question.type eq 'text' ? 'checked' : ''}
                                   onchange="onTypeChanged('fill_in_blank')" class="mt-1 accent-emerald-600">
                            <div>
                                <div class="font-bold text-xs text-slate-800">Điền vào chỗ trống (Fill in blank)</div>
                                <div class="text-[11px] text-slate-400 mt-0.5">Nhập 1 hoặc 2 từ khóa đáp án. Học viên điền khớp sẽ có điểm.</div>
                            </div>
                        </label>
                    </div>
                </div>
            </section>

            <!-- CARD 3A: Answer Options for Single/Multiple Choice -->
            <section id="choiceOptionsBox" class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
                <div class="flex items-center justify-between pb-4 mb-4 border-b border-slate-100">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="w-2.5 h-6 bg-emerald-600 rounded-full inline-block"></span>
                            <h2 class="text-lg font-black text-slate-900">Danh sách phương án lựa chọn</h2>
                        </div>
                        <p class="text-xs text-slate-500 mt-1">
                            Đánh dấu tích vào phương án đúng. Với loại Một đáp án, chỉ được chọn đúng 1 đáp án.
                        </p>
                    </div>
                    <button type="button" onclick="addOptionRow()"
                            class="px-3.5 py-2 rounded-xl bg-emerald-50 hover:bg-emerald-100 text-emerald-800 text-xs font-bold transition">
                        <i class="fa-solid fa-plus mr-1.5"></i>Thêm lựa chọn
                    </button>
                </div>

                <div id="choiceRows" class="space-y-3">
                    <c:choose>
                        <c:when test="${not empty question.options and question.type ne 'fill_in_blank' and question.type ne 'text'}">
                            <c:forEach var="o" items="${question.options}" varStatus="status">
                                <div class="choice-row flex items-center gap-3 p-2.5 rounded-xl border border-slate-200 bg-slate-50/50">
                                    <input type="hidden" name="optionId" value="${o.id}">
                                    <div class="flex items-center justify-center w-8">
                                        <input type="${question.type eq 'single_choice' ? 'radio' : 'checkbox'}"
                                               name="correctIndex" value="${status.index}"
                                               ${o.correct ? 'checked' : ''}
                                               class="correct-box w-4 h-4 accent-emerald-600 cursor-pointer">
                                    </div>
                                    <input type="text" name="optionText" value="${o.optionText}" required
                                           placeholder="Nhập nội dung lựa chọn..."
                                           class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500">
                                    <button type="button" onclick="removeOptionRow(this)"
                                            class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                        <i class="fa-solid fa-trash-can text-xs"></i>
                                    </button>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- Default 4 Choices -->
                            <c:forEach var="label" items="${['A', 'B', 'C', 'D']}" varStatus="st">
                                <div class="choice-row flex items-center gap-3 p-2.5 rounded-xl border border-slate-200 bg-slate-50/50">
                                    <input type="hidden" name="optionId" value="">
                                    <div class="flex items-center justify-center w-8">
                                        <input type="radio" name="correctIndex" value="${st.index}" ${st.index == 0 ? 'checked' : ''}
                                               class="correct-box w-4 h-4 accent-emerald-600 cursor-pointer">
                                    </div>
                                    <input type="text" name="optionText" required
                                           placeholder="Phương án ${label}..."
                                           class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500">
                                    <button type="button" onclick="removeOptionRow(this)"
                                            class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                        <i class="fa-solid fa-trash-can text-xs"></i>
                                    </button>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

            <!-- CARD 3B: Keywords Box for Fill in the Blank -->
            <section id="fillBlankBox" class="hidden bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
                <div class="flex items-center justify-between pb-4 mb-4 border-b border-slate-100">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="w-2.5 h-6 bg-purple-600 rounded-full inline-block"></span>
                            <h2 class="text-lg font-black text-slate-900">Từ khóa đáp án chấp nhận (Điền vào chỗ trống)</h2>
                        </div>
                        <p class="text-xs text-slate-500 mt-1">
                            Nhập 1 hoặc 2 từ khóa đáp án chuẩn (có thể thêm từ đồng nghĩa/viết tắt). Học viên điền trùng 1 trong các từ khóa này (không phân biệt hoa thường) sẽ được tính điểm trọn vẹn.
                        </p>
                    </div>
                    <button type="button" onclick="addKeywordRow()"
                            class="px-3.5 py-2 rounded-xl bg-purple-50 hover:bg-purple-100 text-purple-800 text-xs font-bold transition">
                        <i class="fa-solid fa-plus mr-1.5"></i>Thêm từ khóa khác
                    </button>
                </div>

                <div id="keywordRows" class="space-y-3">
                    <c:choose>
                        <c:when test="${not empty question.options and (question.type eq 'fill_in_blank' or question.type eq 'text')}">
                            <c:forEach var="o" items="${question.options}" varStatus="status">
                                <div class="keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20">
                                    <input type="hidden" name="optionId" value="${o.id}">
                                    <span class="w-8 text-center text-xs font-bold text-purple-700">#${status.count}</span>
                                    <input type="text" name="optionText" value="${o.optionText}" required
                                           placeholder="Nhập từ khóa đáp án (ví dụ: HttpServlet hoặc doGet)..."
                                           class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
                                    <button type="button" onclick="removeKeywordRow(this)"
                                            class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                        <i class="fa-solid fa-trash-can text-xs"></i>
                                    </button>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- Default 2 Keywords -->
                            <div class="keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20">
                                <input type="hidden" name="optionId" value="">
                                <span class="w-8 text-center text-xs font-bold text-purple-700">#1</span>
                                <input type="text" name="optionText" required
                                       placeholder="Từ khóa chính (Ví dụ: doGet)..."
                                       class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
                                <button type="button" onclick="removeKeywordRow(this)"
                                        class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                    <i class="fa-solid fa-trash-can text-xs"></i>
                                </button>
                            </div>
                            <div class="keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20">
                                <input type="hidden" name="optionId" value="">
                                <span class="w-8 text-center text-xs font-bold text-purple-700">#2</span>
                                <input type="text" name="optionText"
                                       placeholder="Từ khóa phụ / viết tắt thay thế (Tùy chọn)..."
                                       class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
                                <button type="button" onclick="removeKeywordRow(this)"
                                        class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                    <i class="fa-solid fa-trash-can text-xs"></i>
                                </button>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

            <!-- CARD 4: Question Verification Panel -->
            <section class="bg-slate-50 rounded-2xl border border-slate-200 p-5">
                <div class="flex items-center justify-between mb-3">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-shield-halved text-emerald-600 text-sm"></i>
                        <h3 class="font-bold text-xs uppercase tracking-wider text-slate-700">Kiểm tra tính hợp lệ của câu hỏi (Verification)</h3>
                    </div>
                    <button type="button" onclick="verifyQuestion()" class="text-xs font-bold text-emerald-700 hover:underline">
                        <i class="fa-solid fa-rotate mr-1"></i>Kiểm tra lại
                    </button>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs" id="verifyChecklist">
                    <div class="flex items-center gap-2" id="chkContent">
                        <i class="fa-solid fa-circle-check text-slate-300"></i>
                        <span class="text-slate-600">Nội dung câu hỏi không rỗng</span>
                    </div>
                    <div class="flex items-center gap-2" id="chkWords">
                        <i class="fa-solid fa-circle-check text-slate-300"></i>
                        <span class="text-slate-600">Độ dài câu hỏi &le; 120 từ</span>
                    </div>
                    <div class="flex items-center gap-2" id="chkModule">
                        <i class="fa-solid fa-circle-check text-slate-300"></i>
                        <span class="text-slate-600">Đã chọn Chương / Module</span>
                    </div>
                    <div class="flex items-center gap-2" id="chkAnswers">
                        <i class="fa-solid fa-circle-check text-slate-300"></i>
                        <span class="text-slate-600">Phương án &amp; đáp án đúng hợp lệ</span>
                    </div>
                </div>
            </section>

            <!-- Bottom Action Buttons -->
            <div class="flex items-center justify-between pt-2">
                <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
                   class="px-6 py-3 rounded-xl border border-slate-200 text-slate-700 font-bold text-sm bg-white hover:bg-slate-50 transition shadow-sm">
                    <i class="fa-solid fa-arrow-left mr-2 text-slate-400"></i>Quay lại danh sách
                </a>
                <button type="submit" id="saveQuestionBtn" class="px-8 py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm shadow-md transition">
                    <i class="fa-solid fa-floppy-disk mr-2"></i>Lưu câu hỏi
                </button>
            </div>
        </form>
    </main>
</div>

<script>
const MAX_WORDS = 120;

function countWords(str) {
    if (!str) return 0;
    const trimmed = str.trim();
    if (!trimmed) return 0;
    return trimmed.split(/\s+/).length;
}

function onContentChange() {
    const text = document.getElementById('questionContent').value;
    const words = countWords(text);
    const numSpan = document.getElementById('wordCountNum');
    const badge = document.getElementById('wordCountBadge');
    const alertBox = document.getElementById('wordCountAlert');

    if (numSpan) numSpan.textContent = words;

    if (words > MAX_WORDS) {
        badge.classList.remove('bg-slate-100', 'text-slate-700', 'border-slate-200');
        badge.classList.add('bg-rose-50', 'text-rose-700', 'border-rose-300');
        alertBox.classList.remove('hidden');
    } else {
        badge.classList.add('bg-slate-100', 'text-slate-700', 'border-slate-200');
        badge.classList.remove('bg-rose-50', 'text-rose-700', 'border-rose-300');
        alertBox.classList.add('hidden');
    }

    verifyQuestion();
}

function getCurrentType() {
    const selectedRadio = document.querySelector('input[name="type"]:checked');
    return selectedRadio ? selectedRadio.value : 'single_choice';
}

function onTypeChanged(type) {
    const choiceBox = document.getElementById('choiceOptionsBox');
    const fillBlankBox = document.getElementById('fillBlankBox');

    if (type === 'fill_in_blank') {
        choiceBox.classList.add('hidden');
        fillBlankBox.classList.remove('hidden');

        // Disable inputs inside choice box so they are not submitted
        choiceBox.querySelectorAll('input').forEach(input => input.disabled = true);
        fillBlankBox.querySelectorAll('input').forEach(input => input.disabled = false);
    } else {
        choiceBox.classList.remove('hidden');
        fillBlankBox.classList.add('hidden');

        choiceBox.querySelectorAll('input').forEach(input => input.disabled = false);
        fillBlankBox.querySelectorAll('input').forEach(input => input.disabled = true);

        // Update radio vs checkbox
        const wantedInputType = (type === 'single_choice') ? 'radio' : 'checkbox';
        document.querySelectorAll('#choiceRows .correct-box').forEach(box => {
            box.type = wantedInputType;
        });
        renumberChoices();
    }

    verifyQuestion();
}

function filterModulesByCourse(selectedCourseId) {
    const moduleSelect = document.getElementById('moduleSelect');
    if (!moduleSelect) return;

    let hasVisible = false;
    for (let i = 0; i < moduleSelect.options.length; i++) {
        const opt = moduleSelect.options[i];
        if (!opt.value) continue;
        const optCourse = opt.getAttribute('data-course');
        if (!selectedCourseId || !optCourse || optCourse === selectedCourseId) {
            opt.style.display = '';
            hasVisible = true;
        } else {
            opt.style.display = 'none';
        }
    }
    verifyQuestion();
}

function renumberChoices() {
    document.querySelectorAll('#choiceRows .choice-row').forEach((row, idx) => {
        const box = row.querySelector('.correct-box');
        if (box) box.value = idx;
    });
}

function addOptionRow() {
    const rowsContainer = document.getElementById('choiceRows');
    const index = rowsContainer.querySelectorAll('.choice-row').length;
    const type = getCurrentType();
    const inputType = (type === 'single_choice') ? 'radio' : 'checkbox';

    const row = document.createElement('div');
    row.className = 'choice-row flex items-center gap-3 p-2.5 rounded-xl border border-slate-200 bg-slate-50/50';
    row.innerHTML = `
        <input type="hidden" name="optionId" value="">
        <div class="flex items-center justify-center w-8">
            <input type="${inputType}" name="correctIndex" value="${index}" class="correct-box w-4 h-4 accent-emerald-600 cursor-pointer">
        </div>
        <input type="text" name="optionText" required placeholder="Nội dung phương án..."
               class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500">
        <button type="button" onclick="removeOptionRow(this)"
                class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
            <i class="fa-solid fa-trash-can text-xs"></i>
        </button>
    `;
    rowsContainer.appendChild(row);
    renumberChoices();
    verifyQuestion();
}

function removeOptionRow(btn) {
    const row = btn.closest('.choice-row');
    if (row) row.remove();
    renumberChoices();
    verifyQuestion();
}

function addKeywordRow() {
    const container = document.getElementById('keywordRows');
    const count = container.querySelectorAll('.keyword-row').length + 1;
    const row = document.createElement('div');
    row.className = 'keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20';
    row.innerHTML = `
        <input type="hidden" name="optionId" value="">
        <span class="w-8 text-center text-xs font-bold text-purple-700">#${count}</span>
        <input type="text" name="optionText" required placeholder="Từ khóa đáp án bổ sung..."
               class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
        <button type="button" onclick="removeKeywordRow(this)"
                class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
            <i class="fa-solid fa-trash-can text-xs"></i>
        </button>
    `;
    container.appendChild(row);
    verifyQuestion();
}

function removeKeywordRow(btn) {
    const row = btn.closest('.keyword-row');
    if (row) row.remove();
    // Renumber badges
    document.querySelectorAll('#keywordRows .keyword-row').forEach((r, idx) => {
        const badge = r.querySelector('span');
        if (badge) badge.textContent = '#' + (idx + 1);
    });
    verifyQuestion();
}

function setCheckStatus(elemId, isValid) {
    const el = document.getElementById(elemId);
    if (!el) return;
    const icon = el.querySelector('i');
    if (isValid) {
        icon.className = 'fa-solid fa-circle-check text-emerald-600';
    } else {
        icon.className = 'fa-solid fa-circle-xmark text-rose-500';
    }
}

function verifyQuestion() {
    const content = (document.getElementById('questionContent').value || '').trim();
    const words = countWords(content);
    const moduleId = (document.getElementById('moduleSelect').value || '').trim();
    const type = getCurrentType();

    const isContentValid = content.length > 0;
    const isWordsValid = words > 0 && words <= MAX_WORDS;
    const isModuleValid = moduleId.length > 0;

    let isAnswersValid = false;
    if (type === 'fill_in_blank') {
        const keywords = Array.from(document.querySelectorAll('#keywordRows input[name="optionText"]'))
            .filter(input => !input.disabled && input.value.trim().length > 0);
        isAnswersValid = keywords.length >= 1;
    } else {
        const options = Array.from(document.querySelectorAll('#choiceRows .choice-row input[name="optionText"]'))
            .filter(input => !input.disabled && input.value.trim().length > 0);
        const correctBoxes = Array.from(document.querySelectorAll('#choiceRows .correct-box:checked'))
            .filter(box => !box.disabled);

        if (type === 'single_choice') {
            isAnswersValid = options.length >= 2 && correctBoxes.length === 1;
        } else {
            isAnswersValid = options.length >= 2 && correctBoxes.length >= 1;
        }
    }

    setCheckStatus('chkContent', isContentValid);
    setCheckStatus('chkWords', isWordsValid);
    setCheckStatus('chkModule', isModuleValid);
    setCheckStatus('chkAnswers', isAnswersValid);

    return isContentValid && isWordsValid && isModuleValid && isAnswersValid;
}

document.addEventListener('DOMContentLoaded', function() {
    const type = getCurrentType();
    onTypeChanged(type);
    onContentChange();
    verifyQuestion();

    // Attach form submit validation
    document.getElementById('questionForm').addEventListener('submit', function(e) {
        if (!verifyQuestion()) {
            const words = countWords(document.getElementById('questionContent').value);
            if (words > MAX_WORDS) {
                alert('Nội dung câu hỏi quá dài (' + words + ' từ). Vui lòng giới hạn tối đa 120 từ.');
                e.preventDefault();
                return;
            }
            if (!confirm('Một số điều kiện kiểm tra hợp lệ câu hỏi chưa đạt chuẩn. Bạn có chắc chắn muốn lưu tiếp không?')) {
                e.preventDefault();
            }
        }
    });
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />