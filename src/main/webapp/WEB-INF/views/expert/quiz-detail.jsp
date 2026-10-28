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
                    <input name="title" id="quizTitleInput" value="${quiz.title}" required maxlength="255"
                           oninput="verifyQuiz()"
                           placeholder="ví dụ: Kiểm tra tổng kết Chương 1 - Lập trình Servlet & JSP"
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
                    <select name="moduleId" id="quizModuleSelect" required onchange="onQuizModuleChange(this.value); verifyQuiz();" class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                        <option value="">-- Chọn module áp dụng --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${(quiz.moduleId eq m.id or defaultFilterModuleId eq m.id) ? 'selected' : ''} data-course="${m.courseId}"><c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}</option>
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
                            <input type="number" name="timeLimit" id="timeLimitInput" min="1" max="600" value="${quiz.timeLimit}" placeholder="30"
                                   oninput="verifyQuiz()"
                                   class="w-full pl-4 pr-12 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition">
                            <span class="absolute right-3.5 top-3.5 text-xs text-slate-400 font-semibold">phút</span>
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-slate-800 mb-2">
                            Điểm qua môn (Pass score: 0 - 10) <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <input type="number" name="passScore" id="passScoreInput" min="0" max="10" step="0.1" value="${empty quiz.passScore ? '5.0' : quiz.passScore}" required
                                   oninput="verifyQuiz()"
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
                        Chọn câu hỏi trong phạm vi khóa học. Bạn có thể chọn thủ công hoặc bấm nút tạo random tự động.
                    </p>
                </div>
                <div class="flex flex-wrap items-center gap-2.5">
                    <span class="inline-flex items-center px-3 py-1.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        <i class="fa-solid fa-circle-check mr-1.5 text-emerald-600"></i>
                        Đã chọn: <strong id="selectedCountBadge" class="ml-1 text-sm">${empty selectedQuestionIds ? 0 : selectedQuestionIds.size()}</strong> câu
                    </span>

                    <!-- Quick Random Selector Toolbar -->
                    <div class="inline-flex items-center bg-indigo-50 border border-indigo-200 rounded-xl p-1 gap-1.5 shadow-sm">
                        <span class="text-xs font-bold text-indigo-900 pl-2 hidden sm:inline">Số câu:</span>
                        <input type="number" id="quickRandomCount" min="1" max="100" value="10"
                               title="Số lượng câu hỏi muốn random"
                               class="w-12 text-center py-1 text-xs font-bold bg-white border border-indigo-200 rounded-lg text-indigo-900 outline-none focus:ring-1 focus:ring-indigo-500">
                        <button type="button" onclick="quickRandomQuestions()" id="btnQuickRandom"
                                class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white text-xs font-bold rounded-lg transition shadow-sm"
                                title="Bấm 1 nút để tự động chọn ngẫu nhiên câu hỏi trong khóa học">
                            <i class="fa-solid fa-dice text-xs"></i>
                            <span>Random câu hỏi</span>
                        </button>
                        <button type="button" onclick="openRandomModal()"
                                class="px-2 py-1.5 text-indigo-600 hover:bg-indigo-100 hover:text-indigo-800 rounded-lg transition text-xs"
                                title="Tùy chọn nâng cao">
                            <i class="fa-solid fa-sliders"></i>
                        </button>
                    </div>

                    <button type="button" onclick="toggleSelectAllVisible()" class="text-xs text-slate-600 font-bold hover:text-emerald-700 border border-slate-200 px-3 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 transition">
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
                                Module: <c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}
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
                           data-course="${q.courseId}"
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
                        Chưa có câu hỏi nào trong Question Bank của khóa học này.
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

        <!-- SECTION 3: Quiz Verification Panel (Kiểm tra tính hợp lệ của bài kiểm tra) -->
        <section class="bg-slate-50 rounded-2xl border border-slate-200 p-5 shadow-sm">
            <div class="flex items-center justify-between mb-3">
                <div class="flex items-center gap-2">
                    <i class="fa-solid fa-shield-halved text-emerald-600 text-sm"></i>
                    <h3 class="font-bold text-xs uppercase tracking-wider text-slate-700">Kiểm tra tính hợp lệ của bài kiểm tra (Verification)</h3>
                </div>
                <button type="button" onclick="verifyQuiz()" class="text-xs font-bold text-emerald-700 hover:underline">
                    <i class="fa-solid fa-rotate mr-1"></i>Kiểm tra lại
                </button>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs" id="verifyChecklist">
                <div class="flex items-center gap-2" id="chkQuizTitle">
                    <i class="fa-solid fa-circle-check text-slate-300"></i>
                    <span class="text-slate-600">Tên bài kiểm tra không rỗng</span>
                </div>
                <div class="flex items-center gap-2" id="chkQuizScore">
                    <i class="fa-solid fa-circle-check text-slate-300"></i>
                    <span class="text-slate-600">Điểm qua môn hợp lệ (0 &le; Điểm &le; 10)</span>
                </div>
                <div class="flex items-center gap-2" id="chkQuizModule">
                    <i class="fa-solid fa-circle-check text-slate-300"></i>
                    <span class="text-slate-600">Đã chọn Chương / Module</span>
                </div>
                <div class="flex items-center gap-2" id="chkQuizTime">
                    <i class="fa-solid fa-circle-check text-slate-300"></i>
                    <span class="text-slate-600">Thời gian làm bài hợp lệ (1 - 600 phút hoặc để trống)</span>
                </div>
                <div class="flex items-center gap-2 sm:col-span-2" id="chkQuizQuestions">
                    <i class="fa-solid fa-circle-check text-slate-300"></i>
                    <span class="text-slate-600">Đã chọn ít nhất 1 câu hỏi vào bài kiểm tra</span>
                </div>
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

<!-- Modal: Random Question Configuration -->
<div id="randomModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="relative w-full max-w-lg bg-white rounded-2xl shadow-2xl border border-slate-200 overflow-hidden transform transition-all">
        <!-- Modal Header -->
        <div class="p-5 border-b border-slate-100 flex items-center justify-between bg-slate-50">
            <div class="flex items-center gap-2.5">
                <div class="w-9 h-9 rounded-xl bg-indigo-100 text-indigo-700 flex items-center justify-center font-bold">
                    <i class="fa-solid fa-dice text-lg"></i>
                </div>
                <div>
                    <h3 class="text-base font-black text-slate-900">Tự động chọn ngẫu nhiên câu hỏi</h3>
                    <p class="text-xs text-slate-500">Tự động chọn nhanh câu hỏi thuộc phạm vi khóa học</p>
                </div>
            </div>
            <button type="button" onclick="closeRandomModal()" class="w-8 h-8 rounded-xl text-slate-400 hover:text-slate-600 hover:bg-slate-200 flex items-center justify-center transition">
                <i class="fa-solid fa-xmark text-sm"></i>
            </button>
        </div>

        <!-- Modal Body -->
        <div class="p-6 space-y-4">
            <!-- Scope info banner -->
            <div class="p-3.5 rounded-xl bg-indigo-50/70 border border-indigo-100 flex items-start gap-3 text-xs text-indigo-900">
                <i class="fa-solid fa-circle-info text-indigo-600 mt-0.5 text-sm"></i>
                <div>
                    <span class="font-bold">Khóa học áp dụng: </span>
                    <span id="modalCourseScopeName" class="font-semibold text-indigo-800">Đang tải...</span>
                    <div class="text-[11px] text-indigo-700/80 mt-0.5" id="modalPoolInfo">Đang tính toán số lượng câu hỏi khả dụng...</div>
                </div>
            </div>

            <!-- Number of questions input -->
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1.5">
                    Số lượng câu hỏi muốn chọn <span class="text-rose-500">*</span>
                </label>
                <div class="flex items-center gap-2">
                    <input type="number" id="modalRandomCount" min="1" max="100" value="10"
                           class="flex-1 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 font-bold text-sm text-slate-900 outline-none focus:bg-white focus:ring-2 focus:ring-indigo-500 transition">
                    <span class="text-xs font-bold text-slate-500">câu</span>
                </div>
                <!-- Quick number buttons -->
                <div class="flex flex-wrap items-center gap-1.5 mt-2">
                    <span class="text-[11px] font-bold text-slate-400 mr-1">Chọn nhanh:</span>
                    <button type="button" onclick="setModalCount(5)" class="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-slate-700 transition">5</button>
                    <button type="button" onclick="setModalCount(10)" class="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-slate-700 transition">10</button>
                    <button type="button" onclick="setModalCount(15)" class="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-slate-700 transition">15</button>
                    <button type="button" onclick="setModalCount(20)" class="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-slate-700 transition">20</button>
                    <button type="button" onclick="setModalCount(30)" class="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-slate-700 transition">30</button>
                    <button type="button" onclick="setModalCount('all')" class="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-slate-700 transition">Tất cả</button>
                </div>
            </div>

            <!-- Scope Selection -->
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1.5">Phạm vi câu hỏi</label>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                    <label class="flex items-start gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50/50 hover:bg-indigo-50/30 cursor-pointer transition">
                        <input type="radio" name="modalScope" value="course" checked class="mt-0.5 accent-indigo-600">
                        <div>
                            <div class="font-bold text-slate-800">Toàn bộ khóa học</div>
                            <div class="text-[11px] text-slate-500">Lấy ngẫu nhiên từ mọi module trong khóa</div>
                        </div>
                    </label>
                    <label class="flex items-start gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50/50 hover:bg-indigo-50/30 cursor-pointer transition">
                        <input type="radio" name="modalScope" value="module" class="mt-0.5 accent-indigo-600">
                        <div>
                            <div class="font-bold text-slate-800">Chỉ trong module đang chọn</div>
                            <div class="text-[11px] text-slate-500">Giới hạn trong module của quiz</div>
                        </div>
                    </label>
                </div>
            </div>

            <!-- Selection Mode -->
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1.5">Chế độ chọn</label>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                    <label class="flex items-start gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50/50 hover:bg-indigo-50/30 cursor-pointer transition">
                        <input type="radio" name="modalMode" value="replace" checked class="mt-0.5 accent-indigo-600">
                        <div>
                            <div class="font-bold text-slate-800">Chọn mới hoàn toàn</div>
                            <div class="text-[11px] text-slate-500">Bỏ chọn các câu cũ và chọn lại</div>
                        </div>
                    </label>
                    <label class="flex items-start gap-2.5 p-3 rounded-xl border border-slate-200 bg-slate-50/50 hover:bg-indigo-50/30 cursor-pointer transition">
                        <input type="radio" name="modalMode" value="append" class="mt-0.5 accent-indigo-600">
                        <div>
                            <div class="font-bold text-slate-800">Chọn thêm câu hỏi mới</div>
                            <div class="text-[11px] text-slate-500">Giữ nguyên các câu đã chọn trước đó</div>
                        </div>
                    </label>
                </div>
            </div>
        </div>

        <!-- Modal Footer -->
        <div class="p-4 bg-slate-50 border-t border-slate-100 flex items-center justify-end gap-2.5">
            <button type="button" onclick="closeRandomModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-100 text-slate-700 text-xs font-bold transition">
                Đóng
            </button>
            <button type="button" onclick="applyModalRandom()" class="px-5 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold shadow-md transition flex items-center gap-1.5">
                <i class="fa-solid fa-dice"></i>
                <span>Tạo ngẫu nhiên ngay</span>
            </button>
        </div>
    </div>
</div>

<!-- Floating Toast Notification -->
<div id="toastNotification" class="fixed bottom-6 right-6 z-50 transform translate-y-10 opacity-0 pointer-events-none transition-all duration-300">
    <div class="flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl border text-sm font-semibold" id="toastContent">
        <i id="toastIcon" class="fa-solid fa-circle-check text-base"></i>
        <span id="toastMsg">Thông báo</span>
    </div>
</div>

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
        verifyQuiz();
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
        verifyQuiz();
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

    // =========================================================
    // VERIFICATION LOGIC (KIỂM TRA TÍNH HỢP LỆ CỦA QUIZ)
    // =========================================================
    function setCheckStatus(elemId, isValid, detailText) {
        const el = document.getElementById(elemId);
        if (!el) return;
        const icon = el.querySelector('i');
        const span = el.querySelector('span');

        if (isValid) {
            icon.className = 'fa-solid fa-circle-check text-emerald-600';
            if (span) {
                span.className = 'text-slate-800 font-semibold';
            }
        } else {
            icon.className = 'fa-solid fa-circle-xmark text-rose-500';
            if (span) {
                span.className = 'text-rose-600 font-semibold';
            }
        }

        if (detailText && span) {
            if (!span.dataset.baseText) {
                span.dataset.baseText = span.textContent;
            }
            span.textContent = span.dataset.baseText + ' (' + detailText + ')';
        }
    }

    function verifyQuiz() {
        const titleInput = document.getElementById('quizTitleInput');
        const title = (titleInput ? titleInput.value : '').trim();
        const isTitleValid = title.length > 0 && title.length <= 255;

        const moduleSelect = document.getElementById('quizModuleSelect');
        const moduleId = (moduleSelect ? moduleSelect.value : '').trim();
        const isModuleValid = moduleId.length > 0;

        const passScoreInput = document.getElementById('passScoreInput');
        const passScoreVal = passScoreInput ? passScoreInput.value.trim() : '';
        const passScoreNum = parseFloat(passScoreVal);
        const isPassScoreValid = passScoreVal !== '' && !isNaN(passScoreNum) && passScoreNum >= 0 && passScoreNum <= 10;

        const timeLimitInput = document.getElementById('timeLimitInput');
        const timeLimitVal = timeLimitInput ? timeLimitInput.value.trim() : '';
        let isTimeLimitValid = true;
        if (timeLimitVal !== '') {
            const timeLimitNum = parseInt(timeLimitVal, 10);
            isTimeLimitValid = !isNaN(timeLimitNum) && timeLimitNum >= 1 && timeLimitNum <= 600;
        }

        const selectedCount = document.querySelectorAll('.question-check:checked').length;
        const isQuestionsValid = selectedCount >= 1;

        setCheckStatus('chkQuizTitle', isTitleValid);
        setCheckStatus('chkQuizModule', isModuleValid);
        setCheckStatus('chkQuizScore', isPassScoreValid);
        setCheckStatus('chkQuizTime', isTimeLimitValid);
        setCheckStatus('chkQuizQuestions', isQuestionsValid, selectedCount + ' câu đã chọn');

        return isTitleValid && isModuleValid && isQuestionsValid && isPassScoreValid && isTimeLimitValid;
    }

    // =========================================================
    // RANDOM QUESTIONS FEATURE (TỰ ĐỘNG CHỌN NGẪU NHIÊN CÂU HỎI)
    // =========================================================
    function getResolvedCourseId() {
        const courseSelect = document.getElementById('courseSelect');
        if (courseSelect && courseSelect.value) {
            return courseSelect.value.trim();
        }
        // Fallback: examine module select option's data-course
        const modSelect = document.getElementById('quizModuleSelect');
        if (modSelect && modSelect.selectedIndex >= 0) {
            const modCourse = modSelect.options[modSelect.selectedIndex].getAttribute('data-course');
            if (modCourse) return modCourse.trim();
        }
        // Fallback: check first question item's data-course
        const firstItem = document.querySelector('.question-item[data-course]');
        if (firstItem) {
            return (firstItem.getAttribute('data-course') || '').trim();
        }
        return '';
    }

    function getResolvedCourseTitle() {
        const courseSelect = document.getElementById('courseSelect');
        if (courseSelect && courseSelect.selectedIndex >= 0) {
            const text = courseSelect.options[courseSelect.selectedIndex].text;
            if (text && !text.includes('--')) {
                return text.trim();
            }
        }
        return '${not empty course ? course.title : ""}';
    }

    function quickRandomQuestions() {
        const input = document.getElementById('quickRandomCount');
        let count = parseInt(input ? input.value : 10, 10);
        if (isNaN(count) || count <= 0) count = 10;

        executeRandomSelection(count, 'course', true);
    }

    function executeRandomSelection(requestedCount, scope, replaceExisting) {
        const targetCourseId = getResolvedCourseId();
        const items = Array.from(document.querySelectorAll('.question-item'));

        if (items.length === 0) {
            showToast('Chưa có câu hỏi nào trong Question Bank của khóa học.', 'warning');
            return;
        }

        // Filter candidate questions by course scope
        let candidates = items.filter(item => {
            const itemCourse = (item.getAttribute('data-course') || '').trim();
            // If targetCourseId is known, verify question belongs to this course
            if (targetCourseId && itemCourse && itemCourse !== targetCourseId) {
                return false;
            }

            if (scope === 'module') {
                const currentMod = (document.getElementById('quizModuleSelect') ? document.getElementById('quizModuleSelect').value : '').trim();
                const itemMod = (item.getAttribute('data-module') || '').trim();
                if (currentMod && itemMod && itemMod !== currentMod) {
                    return false;
                }
            }
            return true;
        });

        if (candidates.length === 0) {
            showToast('Không tìm thấy câu hỏi nào phù hợp trong phạm vi đã chọn.', 'warning');
            return;
        }

        // If replacing existing, uncheck all first
        if (replaceExisting) {
            items.forEach(item => {
                const cb = item.querySelector('.question-check');
                if (cb && cb.checked) {
                    cb.checked = false;
                    onQuestionCheckChange(cb);
                }
            });
        }

        // Build pool: if append mode, choose only from unchecked candidates
        let pool = replaceExisting ? [...candidates] : candidates.filter(item => {
            const cb = item.querySelector('.question-check');
            return cb && !cb.checked;
        });

        if (pool.length === 0) {
            showToast('Tất cả câu hỏi trong phạm vi này đều đã được chọn.', 'info');
            return;
        }

        // Fisher-Yates shuffle
        for (let i = pool.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [pool[i], pool[j]] = [pool[j], pool[i]];
        }

        // Pick requested count (or pool size if requested is larger)
        const pickCount = Math.min(requestedCount, pool.length);
        const selectedSlice = pool.slice(0, pickCount);

        selectedSlice.forEach(item => {
            const cb = item.querySelector('.question-check');
            if (cb) {
                cb.checked = true;
                onQuestionCheckChange(cb);
            }
        });

        // Ensure display matches
        filterQuestions();
        updateSelectedCount();
        verifyQuiz();

        // Close modal if open
        closeRandomModal();

        // Feedback notification
        const courseTitle = getResolvedCourseTitle();
        const courseLabel = courseTitle ? ' (' + courseTitle + ')' : '';

        if (pickCount < requestedCount) {
            showToast('Đã chọn ngẫu nhiên toàn bộ ' + pickCount + ' câu hỏi có sẵn' + courseLabel + '!', 'success');
        } else {
            showToast('Đã chọn ngẫu nhiên thành công ' + pickCount + ' câu hỏi' + courseLabel + '!', 'success');
        }
    }

    // Modal controls
    function openRandomModal() {
        const modal = document.getElementById('randomModal');
        if (!modal) return;

        const targetCourseId = getResolvedCourseId();
        const courseTitle = getResolvedCourseTitle();
        const scopeNameElem = document.getElementById('modalCourseScopeName');
        const poolInfoElem = document.getElementById('modalPoolInfo');

        if (scopeNameElem) {
            scopeNameElem.textContent = courseTitle || 'Khóa học hiện tại';
        }

        const items = Array.from(document.querySelectorAll('.question-item'));
        const courseItems = items.filter(item => {
            const cId = (item.getAttribute('data-course') || '').trim();
            return !targetCourseId || !cId || cId === targetCourseId;
        });

        if (poolInfoElem) {
            poolInfoElem.textContent = 'Có ' + courseItems.length + ' câu hỏi trong ngân hàng của khóa học này.';
        }

        // Sync modal count from quick input
        const quickCount = document.getElementById('quickRandomCount');
        const modalCount = document.getElementById('modalRandomCount');
        if (quickCount && modalCount) {
            modalCount.value = quickCount.value || 10;
        }

        modal.classList.remove('hidden');
    }

    function closeRandomModal() {
        const modal = document.getElementById('randomModal');
        if (modal) modal.classList.add('hidden');
    }

    function setModalCount(val) {
        const input = document.getElementById('modalRandomCount');
        if (!input) return;

        if (val === 'all') {
            const targetCourseId = getResolvedCourseId();
            const items = Array.from(document.querySelectorAll('.question-item'));
            const courseItems = items.filter(item => {
                const cId = (item.getAttribute('data-course') || '').trim();
                return !targetCourseId || !cId || cId === targetCourseId;
            });
            input.value = courseItems.length || 10;
        } else {
            input.value = val;
        }
    }

    function applyModalRandom() {
        const countInput = document.getElementById('modalRandomCount');
        let count = parseInt(countInput ? countInput.value : 10, 10);
        if (isNaN(count) || count <= 0) count = 10;

        const scopeRadio = document.querySelector('input[name="modalScope"]:checked');
        const scope = scopeRadio ? scopeRadio.value : 'course';

        const modeRadio = document.querySelector('input[name="modalMode"]:checked');
        const replaceExisting = modeRadio ? modeRadio.value === 'replace' : true;

        // Also update quick input for convenience
        const quickInput = document.getElementById('quickRandomCount');
        if (quickInput) quickInput.value = count;

        executeRandomSelection(count, scope, replaceExisting);
    }

    // Toast helper
    function showToast(message, type = 'success') {
        const toast = document.getElementById('toastNotification');
        const content = document.getElementById('toastContent');
        const icon = document.getElementById('toastIcon');
        const msg = document.getElementById('toastMsg');
        if (!toast || !content || !icon || !msg) {
            alert(message);
            return;
        }

        msg.textContent = message;
        if (type === 'success') {
            content.className = 'flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl border bg-emerald-700 text-white border-emerald-600 text-sm font-semibold';
            icon.className = 'fa-solid fa-circle-check text-base text-white';
        } else if (type === 'warning') {
            content.className = 'flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl border bg-amber-600 text-white border-amber-500 text-sm font-semibold';
            icon.className = 'fa-solid fa-triangle-exclamation text-base text-white';
        } else {
            content.className = 'flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl border bg-slate-800 text-white border-slate-700 text-sm font-semibold';
            icon.className = 'fa-solid fa-circle-info text-base text-white';
        }

        toast.classList.remove('translate-y-10', 'opacity-0', 'pointer-events-none');
        toast.classList.add('translate-y-0', 'opacity-100');

        setTimeout(() => {
            toast.classList.remove('translate-y-0', 'opacity-100');
            toast.classList.add('translate-y-10', 'opacity-0', 'pointer-events-none');
        }, 3200);
    }

    // Form submit validation hook
    document.addEventListener('DOMContentLoaded', function() {
        filterQuestions();
        updateSelectedCount();
        verifyQuiz();

        const form = document.getElementById('quizForm');
        if (form) {
            form.addEventListener('submit', function(e) {
                if (!verifyQuiz()) {
                    const titleInput = document.getElementById('quizTitleInput');
                    if (!titleInput || !titleInput.value.trim()) {
                        alert('Vui lòng nhập tên bài kiểm tra.');
                        if (titleInput) titleInput.focus();
                        e.preventDefault();
                        return;
                    }

                    const moduleSelect = document.getElementById('quizModuleSelect');
                    if (!moduleSelect || !moduleSelect.value) {
                        alert('Vui lòng chọn Chương / Module áp dụng cho bài kiểm tra.');
                        if (moduleSelect) moduleSelect.focus();
                        e.preventDefault();
                        return;
                    }

                    const selectedCount = document.querySelectorAll('.question-check:checked').length;
                    if (selectedCount === 0) {
                        alert('Vui lòng chọn ít nhất 1 câu hỏi cho bài kiểm tra (bạn có thể bấm nút "Random câu hỏi" để chọn nhanh).');
                        e.preventDefault();
                        return;
                    }

                    if (!confirm('Một số điều kiện kiểm tra hợp lệ của Quiz chưa đạt chuẩn. Bạn có chắc chắn muốn tiếp tục lưu không?')) {
                        e.preventDefault();
                    }
                }
            });
        }
    });
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
