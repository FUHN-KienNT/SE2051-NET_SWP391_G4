<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<%-- ===========================================================================
     MÀN HÌNH: TẠO MỚI / CHỈNH SỬA BÀI KIỂM TRA (QUIZ DETAIL)
     Mục đích: Cấu hình thông tin bài thi, chọn Khóa học & Chương (Module),
     điểm đạt, thời gian và chọn câu hỏi vào đề thi (thủ công hoặc random).
     =========================================================================== --%>

<main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">

    <!-- 1. BREADCRUMB & CÁC NÚT ĐIỀU HƯỚNG ĐẦU TRANG -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
            <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-brand-700 mb-1">
                <a href="${pageContext.request.contextPath}/expert/quizzes" class="hover:underline">Quiz Management</a>
                <span class="text-text-secondary">/</span>
                <span class="text-text-secondary">${empty quiz ? 'Create Quiz' : (isUsed ? 'Quiz Details' : 'Edit Quiz')}</span>
            </div>
            <h1 class="text-2xl sm:text-3xl font-extrabold text-text-primary tracking-tight">
                ${empty quiz ? 'Tạo bài kiểm tra mới' : (isUsed ? 'Chi tiết bài kiểm tra (Chỉ đọc)' : 'Chỉnh sửa bài kiểm tra')}
            </h1>
            <c:if test="${not empty course}">
                <p class="text-xs text-text-secondary mt-1">
                    <i class="fa-solid fa-book-open mr-1 text-brand-700" aria-hidden="true"></i>Khóa học: <span class="font-semibold text-text-primary">${course.title}</span>
                </p>
            </c:if>
        </div>

        <div class="flex flex-wrap items-center gap-2">
            <a id="linkToQuestionBank" href="${pageContext.request.contextPath}/expert/questions?courseId=${courseId}&moduleId=${not empty quiz.moduleId ? quiz.moduleId : defaultFilterModuleId}" class="inline-flex items-center px-4 py-2.5 rounded-xl border border-border-default bg-surface-card text-xs sm:text-sm font-semibold text-text-primary hover:bg-slate-100 shadow-xs transition">
                <i class="fa-solid fa-list-check mr-2 text-brand-700" aria-hidden="true"></i>Ngân hàng câu hỏi
            </a>
            <a id="linkToNewQuestion" href="${pageContext.request.contextPath}/expert/questions/detail?courseId=${courseId}&moduleId=${not empty quiz.moduleId ? quiz.moduleId : defaultFilterModuleId}" class="inline-flex items-center px-4 py-2.5 rounded-xl bg-brand-700 hover:bg-brand-800 text-white text-xs sm:text-sm font-bold shadow-sm transition">
                <i class="fa-solid fa-plus mr-2 text-xs" aria-hidden="true"></i>Tạo câu hỏi mới
            </a>
            <a id="linkToQuizListTop" href="${pageContext.request.contextPath}/expert/quizzes?courseId=${courseId}&moduleId=${not empty quiz.moduleId ? quiz.moduleId : defaultFilterModuleId}" class="inline-flex items-center px-4 py-2.5 rounded-xl border border-border-default bg-surface-card text-xs sm:text-sm font-semibold text-text-secondary hover:text-text-primary hover:bg-slate-100 transition">
                <i class="fa-solid fa-arrow-left mr-2 text-xs" aria-hidden="true"></i>Danh sách Quiz
            </a>
        </div>
    </div>

    <!-- 1B. THÔNG BÁO BÀI KIỂM TRA ĐANG Ở CHẾ ĐỘ CHỈ ĐỌC (NẾU ĐÃ ĐƯỢC DÙNG) -->
    <c:if test="${isUsed}">
        <div class="mb-5 p-4 rounded-xl bg-blue-50 border border-blue-200 text-blue-900 text-xs sm:text-sm font-semibold flex items-start gap-3 shadow-xs">
            <i class="fa-solid fa-circle-info text-blue-600 text-base mt-0.5 shrink-0" aria-hidden="true"></i>
            <div>
                <p class="font-bold text-blue-900">Bài kiểm tra đang ở chế độ Chỉ đọc (Read-only)</p>
                <p class="text-xs text-blue-800 font-normal mt-0.5">
                    Bài kiểm tra này đã được sử dụng trong khóa học hoặc đã có học viên làm bài. Để bảo đảm tính công bằng và toàn vẹn lịch sử kết quả thi của học viên, nội dung câu hỏi và thông số bài kiểm tra không thể chỉnh sửa.
                </p>
            </div>
        </div>
    </c:if>

    <!-- 2. THÔNG BÁO LỖI (NẾU CÓ) -->
    <c:if test="${not empty error}">
        <div class="mb-5 p-4 rounded-xl bg-rose-50 border border-rose-200 text-status-danger text-xs sm:text-sm font-semibold flex items-center gap-3">
            <i class="fa-solid fa-circle-exclamation text-rose-500 text-base" aria-hidden="true"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <!-- 3. FORM CHÍNH: CẤU HÌNH VÀ CHỌN CÂU HỎI QUIZ -->
    <form method="post" action="${pageContext.request.contextPath}/expert/quizzes/detail" id="quizForm" class="space-y-6">
        <input type="hidden" name="id" value="${quiz.id}">
        <input type="hidden" name="courseId" id="courseIdInput" value="${courseId}">

        <!-- ========================================== -->
        <!-- PHẦN 1: THÔNG TIN CƠ BẢN CỦA QUIZ          -->
        <!-- ========================================== -->
        <section class="bg-surface-card rounded-2xl border border-border-default shadow-xs p-6 sm:p-8">
            <div class="flex items-center justify-between pb-4 mb-6 border-b border-border-default">
                <div class="flex items-center gap-2">
                    <span class="w-2.5 h-6 bg-brand-700 rounded-full inline-block"></span>
                    <h2 class="text-base sm:text-lg font-bold text-text-primary">Thông tin cơ bản</h2>
                </div>
                <c:choose>
                    <c:when test="${isUsed}">
                        <span class="inline-flex items-center px-3.5 py-1.5 rounded-xl bg-blue-50 text-blue-700 border border-blue-200 font-bold text-xs shadow-xs">
                            <i class="fa-solid fa-lock mr-1.5 text-xs text-blue-600" aria-hidden="true"></i>Chỉ đọc
                        </span>
                    </c:when>
                    <c:otherwise>
                        <button type="submit" class="inline-flex items-center px-5 py-2 rounded-xl bg-brand-700 hover:bg-brand-800 text-white font-bold text-xs sm:text-sm shadow-sm transition">
                            <i class="fa-solid fa-floppy-disk mr-2 text-xs" aria-hidden="true"></i>Lưu bài kiểm tra
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <!-- Tên bài kiểm tra -->
                <div class="md:col-span-2">
                    <div class="flex items-center justify-between mb-2">
                        <label class="block text-xs sm:text-sm font-bold text-text-primary">
                            Tên bài kiểm tra <span class="text-status-danger">*</span>
                        </label>
                        <span id="quizTitleWordCountBadge" class="text-xs font-semibold px-2.5 py-0.5 rounded-full border bg-surface text-text-secondary border-border-default">
                            <span id="quizTitleWordCount">0</span>/120 từ
                        </span>
                    </div>
                    <input name="title" id="quizTitleInput" value="${quiz.title}" required maxlength="255"
                           ${isUsed ? 'readonly' : ''}
                           oninput="onQuizTitleChange(); verifyQuiz();"
                           placeholder="ví dụ: Kiểm tra tổng kết Chương 1 - Lập trình Servlet & JSP"
                           class="w-full px-4 py-3 rounded-xl border border-border-default text-xs sm:text-sm outline-none transition ${isUsed ? 'bg-slate-100 text-text-secondary cursor-not-allowed' : 'bg-surface focus:bg-surface-card focus:ring-2 focus:ring-brand-700 focus:border-brand-700'}">
                    <p id="quizTitleWordAlert" class="hidden text-xs text-status-danger font-semibold mt-1.5 flex items-center gap-1.5">
                        <i class="fa-solid fa-circle-exclamation" aria-hidden="true"></i>
                        <span>Tên bài kiểm tra không được vượt quá 120 từ.</span>
                    </p>
                </div>

                <!-- Chọn Khóa học (để lọc nhanh danh sách Chương / Module bên cạnh) -->
                <div>
                    <label class="block text-xs sm:text-sm font-bold text-text-primary mb-2">
                        Khóa học
                    </label>
                    <select id="courseSelect" onchange="onCourseChange(this.value, false)" ${isUsed ? 'disabled' : ''}
                            class="w-full px-4 py-3 rounded-xl border border-border-default text-xs sm:text-sm font-semibold outline-none transition ${isUsed ? 'bg-slate-100 text-text-secondary cursor-not-allowed' : 'bg-surface text-text-primary focus:bg-surface-card focus:ring-2 focus:ring-brand-700 cursor-pointer'}">
                        <option value="">-- Tất cả khóa học --</option>
                        <c:forEach var="c" items="${courses}">
                            <option value="${c.id}" ${courseId eq c.id ? 'selected' : ''}>
                                ${c.title} (${c.moduleCount} chương)
                            </option>
                        </c:forEach>
                    </select>
                    <p class="text-[11px] text-text-secondary mt-1">Chọn khóa học để lọc các chương (module) thuộc khóa học đó.</p>
                </div>

                <!-- Chương / Module áp dụng -->
                <div>
                    <label class="block text-xs sm:text-sm font-bold text-text-primary mb-2">
                        Chương / Module <span class="text-status-danger">*</span>
                    </label>
                    <select name="moduleId" id="quizModuleSelect" required onchange="onQuizModuleChange(this.value); verifyQuiz();" ${isUsed ? 'disabled' : ''}
                            class="w-full px-4 py-3 rounded-xl border border-border-default text-xs sm:text-sm font-semibold outline-none transition ${isUsed ? 'bg-slate-100 text-text-secondary cursor-not-allowed' : 'bg-surface text-text-primary focus:bg-surface-card focus:ring-2 focus:ring-brand-700 cursor-pointer'}">
                        <option value="">-- Chọn module áp dụng --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${(quiz.moduleId eq m.id or defaultFilterModuleId eq m.id) ? 'selected' : ''} data-course="${m.courseId}">
                                <c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}
                            </option>
                        </c:forEach>
                    </select>
                    <p id="quizModuleEmptyNotice" class="hidden text-[11px] text-amber-700 bg-amber-50 border border-amber-200 rounded-lg px-2.5 py-1.5 font-semibold mt-1.5">
                        <i class="fa-solid fa-triangle-exclamation mr-1 text-status-warning" aria-hidden="true"></i>
                        Khóa học đang chọn chưa có chương (module) nào. Hệ thống đang hiển thị tất cả module từ các khóa học khác để bạn chọn.
                    </p>
                    <p class="text-[11px] text-text-secondary mt-1">Khi chọn module, danh sách câu hỏi bên dưới sẽ được tự động lọc theo module tương ứng.</p>
                </div>

                <!-- Trạng thái hiển thị -->
                <div>
                    <label class="block text-xs sm:text-sm font-bold text-text-primary mb-2">
                        Trạng thái hiển thị <span class="text-status-danger">*</span>
                    </label>
                    <select name="status" ${isUsed ? 'disabled' : ''}
                            class="w-full px-4 py-3 rounded-xl border border-border-default text-xs sm:text-sm font-semibold outline-none transition ${isUsed ? 'bg-slate-100 text-text-secondary cursor-not-allowed' : 'bg-surface text-text-primary focus:bg-surface-card focus:ring-2 focus:ring-brand-700 cursor-pointer'}">
                        <option value="published" ${empty quiz or quiz.status eq 'published' ? 'selected' : ''}>Công khai (Published - Học viên có thể làm bài)</option>
                        <option value="draft" ${quiz.status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft - Chỉ Expert thấy)</option>
                        <option value="hidden" ${quiz.status eq 'hidden' ? 'selected' : ''}>Ẩn (Hidden - Giữ lịch sử làm bài, học viên không thể thi mới)</option>
                    </select>
                </div>

                <!-- Thời gian làm bài & Điểm chuẩn đạt (cùng hàng với trạng thái trên màn hình lớn) -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs sm:text-sm font-bold text-text-primary mb-2">
                            Thời gian làm bài (Phút) <span class="text-status-danger">*</span>
                        </label>
                        <div class="relative">
                            <input type="number" name="timeLimit" id="timeLimitInput" value="${empty quiz.timeLimit ? 15 : quiz.timeLimit}" min="1" max="600" required
                                   ${isUsed ? 'readonly' : ''}
                                   oninput="verifyQuiz()"
                                   placeholder="Từ 1 đến 600 phút"
                                   class="w-full pl-4 pr-14 py-3 rounded-xl border border-border-default text-xs sm:text-sm outline-none transition ${isUsed ? 'bg-slate-100 text-text-secondary cursor-not-allowed' : 'bg-surface focus:bg-surface-card focus:ring-2 focus:ring-brand-700'}">
                            <span class="absolute right-3.5 top-3.5 text-xs text-text-secondary font-semibold">Phút</span>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs sm:text-sm font-bold text-text-primary mb-2">
                            Điểm chuẩn đạt <span class="text-status-danger">*</span>
                        </label>
                        <div class="relative">
                            <input type="number" step="0.5" name="passScore" id="passScoreInput" value="${empty quiz.passScore ? 5.0 : quiz.passScore}" min="0" max="10" required
                                   ${isUsed ? 'readonly' : ''}
                                   oninput="verifyQuiz()"
                                   class="w-full pl-4 pr-12 py-3 rounded-xl border border-border-default text-xs sm:text-sm font-bold outline-none transition ${isUsed ? 'bg-slate-100 text-text-secondary cursor-not-allowed' : 'bg-surface text-text-primary focus:bg-surface-card focus:ring-2 focus:ring-brand-700'}">
                            <span class="absolute right-3.5 top-3.5 text-xs text-text-secondary font-semibold">/ 10</span>
                        </div>
                    </div>
                </div>

                <!-- Link ảnh đại diện Quiz -->
                <div class="md:col-span-2">
                    <label class="block text-xs sm:text-sm font-bold text-text-primary mb-2">
                        Ảnh đại diện bài kiểm tra (Image URL)
                    </label>
                    <div class="flex flex-col sm:flex-row items-start gap-4">
                        <div class="w-20 h-20 rounded-2xl border border-border-default bg-surface flex items-center justify-center overflow-hidden shrink-0 shadow-xs relative">
                            <img id="imagePreview" src="${empty quiz.imageUrl ? 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100&auto=format&fit=crop&q=80' : quiz.imageUrl}"
                                  alt="Preview" referrerpolicy="no-referrer" class="w-full h-full object-cover"
                                  onerror="this.src='https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100&auto=format&fit=crop&q=80'">
                        </div>
                        <div class="flex-1 w-full space-y-2">
                            <div class="relative">
                                <input name="imageUrl" id="imageUrlInput" value="${quiz.imageUrl}"
                                       ${isUsed ? 'readonly' : ''}
                                       placeholder="Dán link ảnh trực tiếp (https://...) hoặc link Google Images..."
                                       oninput="onImageUrlInput(this.value)"
                                       class="w-full pl-4 pr-10 py-3 rounded-xl border border-border-default text-xs sm:text-sm outline-none transition ${isUsed ? 'bg-slate-100 text-text-secondary cursor-not-allowed' : 'bg-surface focus:bg-surface-card focus:ring-2 focus:ring-brand-700'}">
                                <span class="absolute right-3.5 top-3.5 flex items-center">
                                    <i id="imageStatusIcon" class="fa-solid fa-image text-slate-400 text-sm" aria-hidden="true"></i>
                                </span>
                            </div>
                            <span id="imageStatusText" class="text-text-secondary text-[11px] block">Chưa chọn ảnh (dùng ảnh mặc định)</span>
                            <div id="googleExtractedNotice" class="hidden text-[11px] font-semibold text-brand-700 bg-brand-50 border border-brand-200 px-3 py-1.5 rounded-lg flex items-center gap-1.5">
                                <i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>
                                <span>Đã tự động trích xuất link ảnh gốc từ đường dẫn Google Images!</span>
                            </div>

                            <!-- Gợi ý ảnh mẫu nhanh -->
                            <c:if test="${not isUsed}">
                                <div class="pt-1 flex flex-wrap items-center gap-1.5">
                                    <span class="text-[11px] font-bold text-text-secondary mr-1">Gợi ý ảnh mẫu:</span>
                                    <button type="button" onclick="selectPresetImage('https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600&auto=format&fit=crop&q=80')"
                                            class="px-2.5 py-1 rounded-lg bg-surface hover:bg-brand-50 hover:text-brand-700 text-text-secondary text-xs font-semibold border border-border-default transition">
                                        💻 Công nghệ
                                    </button>
                                    <button type="button" onclick="selectPresetImage('https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop&q=80')"
                                            class="px-2.5 py-1 rounded-lg bg-surface hover:bg-brand-50 hover:text-brand-700 text-text-secondary text-xs font-semibold border border-border-default transition">
                                        📐 Toán học
                                    </button>
                                    <button type="button" onclick="selectPresetImage('https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=600&auto=format&fit=crop&q=80')"
                                            class="px-2.5 py-1 rounded-lg bg-surface hover:bg-brand-50 hover:text-brand-700 text-text-secondary text-xs font-semibold border border-border-default transition">
                                        📚 Tổng quan
                                    </button>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ========================================== -->
        <!-- PHẦN 2: CHỌN CÂU HỎI VÀO BÀI KIỂM TRA     -->
        <!-- ========================================== -->
        <section class="bg-surface-card rounded-2xl border border-border-default shadow-xs overflow-hidden">
            <div class="p-6 border-b border-border-default flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                <div>
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-6 bg-brand-700 rounded-full inline-block"></span>
                        <h2 class="text-base sm:text-lg font-bold text-text-primary">Chọn câu hỏi vào bài kiểm tra</h2>
                    </div>
                    <p class="text-xs text-text-secondary mt-1">
                        Chọn câu hỏi trong phạm vi chương / khóa học. Bạn có thể chọn thủ công hoặc bấm nút tạo random tự động.
                    </p>
                </div>
                <div class="flex flex-wrap items-center gap-2.5">
                    <span class="inline-flex items-center px-3 py-1.5 rounded-full text-xs font-bold bg-brand-50 text-brand-700 border border-brand-100">
                        <i class="fa-solid fa-circle-check mr-1.5 text-brand-600" aria-hidden="true"></i>
                        Đã chọn: <strong id="selectedCountBadge" class="ml-1 text-sm">${empty selectedQuestionIds ? 0 : selectedQuestionIds.size()}</strong> câu
                    </span>

                    <c:if test="${not isUsed}">
                        <!-- Công cụ Random nhanh câu hỏi -->
                        <div class="inline-flex items-center bg-indigo-50 border border-indigo-200 rounded-xl p-1 gap-1.5 shadow-xs">
                            <span class="text-xs font-bold text-indigo-900 pl-2 hidden sm:inline">Số câu:</span>
                            <input type="number" id="quickRandomCount" min="1" max="10" value="10"
                                   oninput="validateRandomInput(this)" onchange="validateRandomInput(this)"
                                   class="w-14 text-center py-1 text-xs font-bold bg-white border border-indigo-200 rounded-lg text-indigo-900 outline-none focus:ring-1 focus:ring-indigo-500">
                            <span id="quickRandomMaxHint" class="text-[11px] font-semibold text-indigo-700 pr-1 hidden sm:inline"></span>
                            <button type="button" onclick="quickRandomQuestions()" id="btnQuickRandom"
                                    class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold rounded-lg transition shadow-xs"
                                    title="Tự động chọn ngẫu nhiên câu hỏi trong chương này">
                                <i class="fa-solid fa-dice text-xs" aria-hidden="true"></i>
                                <span>Random câu hỏi</span>
                            </button>
                            <button type="button" onclick="openRandomModal()"
                                    class="px-2 py-1.5 text-indigo-600 hover:bg-indigo-100 rounded-lg transition text-xs"
                                    title="Tùy chọn nâng cao">
                                <i class="fa-solid fa-sliders" aria-hidden="true"></i>
                            </button>
                        </div>

                        <button type="button" onclick="toggleSelectAllVisible()" class="text-xs text-text-secondary font-semibold hover:text-brand-700 border border-border-default px-3 py-2 rounded-xl bg-surface hover:bg-slate-100 transition">
                            Chọn/Bỏ chọn tất cả
                        </button>
                    </c:if>
                </div>
            </div>

            <!-- Bộ lọc câu hỏi tại chỗ -->
            <div class="p-4 bg-surface border-b border-border-default grid grid-cols-1 sm:grid-cols-12 gap-3 items-center">
                <div class="sm:col-span-5 relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-slate-400 text-xs pointer-events-none" aria-hidden="true"></i>
                    <input id="questionSearch" oninput="filterQuestions()" placeholder="Tìm nội dung câu hỏi..."
                           class="w-full pl-9 pr-4 py-2 rounded-xl bg-surface-card border border-border-default text-xs outline-none focus:ring-2 focus:ring-brand-700 transition">
                </div>

                <div class="sm:col-span-4">
                    <select id="questionModuleFilter" onchange="filterQuestions()" class="w-full px-3 py-2 rounded-xl bg-surface-card border border-border-default text-xs font-semibold outline-none focus:ring-2 focus:ring-brand-700 transition cursor-pointer">
                        <option value="">-- Tất cả Module --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" data-course="${m.courseId}" ${(not empty defaultFilterModuleId and defaultFilterModuleId eq m.id) or (not empty quiz and quiz.moduleId eq m.id) ? 'selected' : ''}>
                                Module: <c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="sm:col-span-3 flex items-center gap-2">
                    <label class="flex items-center gap-2 text-xs font-semibold text-text-secondary cursor-pointer select-none">
                        <input type="checkbox" id="onlySelectedFilter" onchange="filterQuestions()" class="w-3.5 h-3.5 rounded accent-brand-700">
                        <span>Chỉ hiện câu đã chọn</span>
                    </label>
                </div>
            </div>

            <!-- Danh sách câu hỏi có checkbox -->
            <div class="p-5 max-h-[560px] overflow-y-auto space-y-3" id="questionList">
                <c:forEach var="q" items="${questions}" varStatus="s">
                    <c:set var="selected" value="${not empty selectedQuestionIds and selectedQuestionIds.contains(q.id)}"/>
                    <label class="question-item flex items-start gap-3.5 p-4 rounded-xl border border-border-default transition ${isUsed ? 'cursor-default' : 'hover:bg-slate-50 cursor-pointer'} ${selected ? 'bg-brand-50/30 border-brand-500 ring-1 ring-brand-300' : 'bg-surface-card'}"
                           data-text="${q.content}"
                           data-module="${q.moduleId}"
                           data-course="${q.courseId}"
                           data-type="${q.type}"
                           data-selected="${selected ? 'true' : 'false'}">
                        <input type="checkbox" name="questionId" value="${q.id}" ${selected ? 'checked' : ''} ${isUsed ? 'disabled' : ''}
                               onchange="onQuestionCheckChange(this)"
                               class="mt-1 question-check w-4 h-4 accent-brand-700 rounded ${isUsed ? 'cursor-default opacity-80' : 'cursor-pointer'}">
                        <div class="min-w-0 flex-1">
                            <div class="flex flex-wrap items-center gap-2 mb-1.5">
                                <c:choose>
                                    <c:when test="${q.type eq 'fill_in_blank' or q.type eq 'text'}">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold bg-amber-50 text-status-warning border border-amber-200">
                                            <i class="fa-solid fa-pen-nib mr-1 text-[10px]" aria-hidden="true"></i>Điền chỗ trống
                                        </span>
                                    </c:when>
                                    <c:when test="${q.type eq 'multiple_choice'}">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold bg-purple-50 text-purple-700 border border-purple-200">
                                            <i class="fa-solid fa-list-check mr-1 text-[10px]" aria-hidden="true"></i>Nhiều đáp án
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold bg-brand-50 text-brand-700 border border-brand-100">
                                            <i class="fa-solid fa-circle-dot mr-1 text-[10px]" aria-hidden="true"></i>1 đáp án
                                        </span>
                                    </c:otherwise>
                                </c:choose>

                                <c:if test="${not empty q.moduleTitle}">
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-medium bg-surface text-text-primary border border-border-default">
                                        <i class="fa-solid fa-folder mr-1 text-slate-400 text-[10px]" aria-hidden="true"></i>
                                        <c:if test="${not empty q.courseTitle}">[${q.courseTitle}] </c:if>${q.moduleTitle}
                                    </span>
                                </c:if>

                                <c:if test="${q.status eq 'hidden'}">
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-semibold bg-rose-50 text-status-danger border border-rose-200">
                                        <i class="fa-solid fa-eye-slash mr-1 text-[10px]" aria-hidden="true"></i>Đã ẩn
                                    </span>
                                </c:if>
                            </div>

                            <div class="font-semibold text-xs sm:text-sm text-text-primary leading-relaxed">${q.content}</div>

                            <c:if test="${not empty q.options}">
                                <div class="mt-2.5 pt-2 border-t border-border-default/60 flex flex-wrap gap-2 text-xs text-text-secondary">
                                    <c:forEach var="opt" items="${q.options}">
                                        <span class="px-2 py-0.5 rounded bg-surface border ${opt.correct ? 'border-emerald-300 text-status-success font-semibold bg-emerald-50/50' : 'border-border-default'}">
                                            <c:if test="${opt.correct}"><i class="fa-solid fa-check text-status-success mr-1" aria-hidden="true"></i></c:if>
                                            ${opt.optionText}
                                        </span>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </label>
                </c:forEach>

                <c:if test="${empty questions}">
                    <div class="text-center py-12 text-text-secondary text-xs sm:text-sm">
                        <i class="fa-solid fa-folder-open text-3xl mb-2 text-slate-300 block" aria-hidden="true"></i>
                        Chưa có câu hỏi nào trong Question Bank.
                        <a class="text-brand-700 font-bold hover:underline" href="${pageContext.request.contextPath}/expert/questions/detail?courseId=${courseId}">
                            Tạo câu hỏi đầu tiên
                        </a>.
                    </div>
                </c:if>
            </div>

            <div id="noQuestionMatch" class="hidden p-8 text-center text-text-secondary text-xs sm:text-sm">
                <i class="fa-solid fa-filter-circle-xmark text-2xl text-slate-300 mb-2 block" aria-hidden="true"></i>
                Không có câu hỏi nào khớp với bộ lọc module hoặc từ khóa tìm kiếm.
            </div>
        </section>

        <c:if test="${not isUsed}">
            <!-- ========================================== -->
            <!-- PHẦN 3: BẢNG KIỂM TRA HỢP LỆ (VERIFY)     -->
            <!-- ========================================== -->
            <section class="bg-surface rounded-2xl border border-border-default p-5 shadow-xs">
                <div class="flex items-center justify-between mb-3">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-shield-halved text-brand-700 text-sm" aria-hidden="true"></i>
                        <h3 class="font-bold text-xs uppercase tracking-wider text-text-primary">Kiểm tra tính hợp lệ của bài kiểm tra (Verification)</h3>
                    </div>
                    <button type="button" onclick="verifyQuiz()" class="text-xs font-bold text-brand-700 hover:underline">
                        <i class="fa-solid fa-rotate mr-1" aria-hidden="true"></i>Kiểm tra lại
                    </button>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs" id="verifyChecklist">
                    <div class="flex items-center gap-2" id="chkQuizTitle">
                        <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                        <span class="text-text-secondary">Tên bài kiểm tra không rỗng và &le; 120 từ</span>
                    </div>
                    <div class="flex items-center gap-2" id="chkQuizScore">
                        <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                        <span class="text-text-secondary">Điểm qua môn hợp lệ (0 &le; Điểm &le; 10)</span>
                    </div>
                    <div class="flex items-center gap-2" id="chkQuizModule">
                        <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                        <span class="text-text-secondary">Đã chọn Chương / Module</span>
                    </div>
                    <div class="flex items-center gap-2" id="chkQuizTime">
                        <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                        <span class="text-text-secondary">Thời gian làm bài hợp lệ (1 - 600 phút)</span>
                    </div>
                    <div class="flex items-center gap-2 sm:col-span-2" id="chkQuizQuestions">
                        <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                        <span class="text-text-secondary">Đã chọn ít nhất 1 câu hỏi vào bài kiểm tra</span>
                    </div>
                </div>
            </section>
        </c:if>

        <!-- ========================================== -->
        <!-- PHẦN 4: CÁC NÚT HÀNH ĐỘNG DƯỚI ĐÁY TRANG  -->
        <!-- ========================================== -->
        <div class="flex items-center justify-between pt-2">
            <a href="${pageContext.request.contextPath}/expert/quizzes?courseId=${courseId}" class="px-6 py-3 rounded-xl border border-border-default text-text-secondary hover:text-text-primary font-semibold text-xs sm:text-sm bg-surface-card hover:bg-slate-100 shadow-xs transition">
                <i class="fa-solid fa-arrow-left mr-2 text-xs" aria-hidden="true"></i>Quay lại danh sách
            </a>
            <c:choose>
                <c:when test="${isUsed}">
                    <span class="inline-flex items-center px-6 py-3 rounded-xl bg-blue-50 text-blue-700 border border-blue-200 font-bold text-xs sm:text-sm shadow-xs">
                        <i class="fa-solid fa-lock mr-2 text-xs text-blue-600" aria-hidden="true"></i>Bài kiểm tra chỉ đọc (Đã sử dụng)
                    </span>
                </c:when>
                <c:otherwise>
                    <button type="submit" class="px-8 py-3 rounded-xl bg-brand-700 hover:bg-brand-800 text-white font-bold text-xs sm:text-sm shadow-sm transition">
                        <i class="fa-solid fa-floppy-disk mr-2 text-xs" aria-hidden="true"></i>Lưu bài kiểm tra
                    </button>
                </c:otherwise>
            </c:choose>
        </div>
    </form>
</main>

<!-- ========================================== -->
<!-- MODAL: CẤU HÌNH RANDOM CÂU HỎI             -->
<!-- ========================================== -->
<div id="randomModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="relative w-full max-w-lg bg-surface-card rounded-2xl shadow-xl border border-border-default overflow-hidden animate-fade-in">
        <div class="p-5 border-b border-border-default flex items-center justify-between bg-surface">
            <div class="flex items-center gap-2.5">
                <div class="w-9 h-9 rounded-xl bg-indigo-50 text-indigo-700 flex items-center justify-center font-bold">
                    <i class="fa-solid fa-dice text-base" aria-hidden="true"></i>
                </div>
                <div>
                    <h3 class="text-sm sm:text-base font-bold text-text-primary">Tự động chọn ngẫu nhiên câu hỏi</h3>
                    <p class="text-xs text-text-secondary">Chọn ngẫu nhiên câu hỏi thuộc chương / module đã chọn</p>
                </div>
            </div>
            <button type="button" onclick="closeRandomModal()" class="w-8 h-8 rounded-xl text-slate-400 hover:text-text-primary hover:bg-slate-200 flex items-center justify-center transition">
                <i class="fa-solid fa-xmark text-sm" aria-hidden="true"></i>
            </button>
        </div>

        <div class="p-6 space-y-4">
            <!-- Thẻ thông tin module đang chọn -->
            <div class="p-3.5 rounded-xl bg-indigo-50/70 border border-indigo-100 flex items-start gap-3 text-xs text-indigo-900">
                <i class="fa-solid fa-circle-info text-indigo-600 mt-0.5 text-sm" aria-hidden="true"></i>
                <div>
                    <span class="font-bold">Chương / Module áp dụng: </span>
                    <span id="modalModuleScopeName" class="font-semibold text-indigo-800">Đang tải...</span>
                    <div class="text-[11px] text-indigo-700/80 mt-0.5" id="modalPoolInfo">Đang tính toán số lượng câu hỏi khả dụng...</div>
                </div>
            </div>

            <!-- Ô nhập số câu -->
            <div>
                <label class="block text-xs font-bold text-text-primary mb-1.5">
                    Số lượng câu hỏi muốn chọn <span class="text-status-danger">*</span>
                </label>
                <div class="flex items-center gap-2">
                    <input type="number" id="modalRandomCount" min="1" max="10" value="10"
                           oninput="validateRandomInput(this)" onchange="validateRandomInput(this)"
                           class="flex-1 px-4 py-2.5 rounded-xl bg-surface border border-border-default font-bold text-xs sm:text-sm text-text-primary outline-none focus:bg-surface-card focus:ring-2 focus:ring-indigo-500 transition">
                    <span id="modalMaxHint" class="text-xs font-bold text-text-secondary">câu</span>
                </div>
                <!-- Chọn nhanh số lượng -->
                <div class="flex flex-wrap items-center gap-1.5 mt-2">
                    <span class="text-[11px] font-bold text-text-secondary mr-1">Chọn nhanh:</span>
                    <button type="button" onclick="setModalCount(5)" class="px-2.5 py-1 rounded-lg bg-surface hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-text-secondary transition">5</button>
                    <button type="button" onclick="setModalCount(10)" class="px-2.5 py-1 rounded-lg bg-surface hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-text-secondary transition">10</button>
                    <button type="button" onclick="setModalCount(15)" class="px-2.5 py-1 rounded-lg bg-surface hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-text-secondary transition">15</button>
                    <button type="button" onclick="setModalCount(20)" class="px-2.5 py-1 rounded-lg bg-surface hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-text-secondary transition">20</button>
                    <button type="button" onclick="setModalCount('all')" class="px-2.5 py-1 rounded-lg bg-surface hover:bg-indigo-50 hover:text-indigo-700 text-xs font-bold text-text-secondary transition">Toàn bộ chương</button>
                </div>
            </div>

            <!-- Chế độ chọn (chọn mới hay chọn thêm) -->
            <div>
                <label class="block text-xs font-bold text-text-primary mb-1.5">Chế độ chọn</label>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                    <label class="flex items-start gap-2.5 p-3 rounded-xl border border-border-default bg-surface hover:bg-indigo-50/40 cursor-pointer transition">
                        <input type="radio" name="modalMode" value="replace" checked class="mt-0.5 accent-indigo-600">
                        <div>
                            <div class="font-bold text-text-primary">Chọn mới hoàn toàn</div>
                            <div class="text-[11px] text-text-secondary">Bỏ chọn các câu cũ và chọn lại</div>
                        </div>
                    </label>
                    <label class="flex items-start gap-2.5 p-3 rounded-xl border border-border-default bg-surface hover:bg-indigo-50/40 cursor-pointer transition">
                        <input type="radio" name="modalMode" value="append" class="mt-0.5 accent-indigo-600">
                        <div>
                            <div class="font-bold text-text-primary">Chọn thêm câu hỏi mới</div>
                            <div class="text-[11px] text-text-secondary">Giữ nguyên các câu đã chọn trước đó</div>
                        </div>
                    </label>
                </div>
            </div>
        </div>

        <div class="p-4 bg-surface border-t border-border-default flex items-center justify-end gap-2.5">
            <button type="button" onclick="closeRandomModal()" class="px-4 py-2.5 rounded-xl border border-border-default bg-surface-card hover:bg-slate-100 text-text-secondary font-semibold text-xs transition">
                Đóng
            </button>
            <button type="button" onclick="applyModalRandom()" class="px-5 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold shadow-xs transition flex items-center gap-1.5">
                <i class="fa-solid fa-dice" aria-hidden="true"></i>
                <span>Tạo ngẫu nhiên ngay</span>
            </button>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- TOAST THÔNG BÁO NỔI                       -->
<!-- ========================================== -->
<div id="toastNotification" class="fixed bottom-6 right-6 z-50 transform translate-y-10 opacity-0 pointer-events-none transition-all duration-300">
    <div class="flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl border text-sm font-semibold" id="toastContent">
        <i id="toastIcon" class="fa-solid fa-circle-check text-base" aria-hidden="true"></i>
        <span id="toastMsg">Thông báo</span>
    </div>
</div>

<!-- ===========================================================================
     JAVASCRIPT: HỖ TRỢ SINH VIÊN DỄ HỌC & THEO DÕI
     =========================================================================== -->
<script>
    const MAX_QUIZ_TITLE_WORDS = 120;
    let activeCourseFilterId = '';

    // 1. Đếm số từ trong chuỗi
    function countWords(str) {
        if (!str) return 0;
        const trimmed = str.trim();
        return trimmed ? trimmed.split(/\s+/).length : 0;
    }

    // 2. Lắng nghe thay đổi tên Quiz để cập nhật bộ đếm từ
    function onQuizTitleChange() {
        const titleInput = document.getElementById('quizTitleInput');
        const title = (titleInput ? titleInput.value : '').trim();
        const words = countWords(title);
        const wordCountSpan = document.getElementById('quizTitleWordCount');
        const badge = document.getElementById('quizTitleWordCountBadge');
        const alertBox = document.getElementById('quizTitleWordAlert');

        if (wordCountSpan) wordCountSpan.textContent = words;

        if (words > MAX_QUIZ_TITLE_WORDS) {
            if (badge) badge.className = 'text-xs font-bold px-2.5 py-0.5 rounded-full border bg-rose-50 text-status-danger border-rose-300';
            if (alertBox) alertBox.classList.remove('hidden');
        } else {
            if (badge) badge.className = 'text-xs font-semibold px-2.5 py-0.5 rounded-full border bg-surface text-text-secondary border-border-default';
            if (alertBox) alertBox.classList.add('hidden');
        }
    }

    // 3A. Xử lý khi chọn Khóa học -> lọc danh sách Module tương ứng (an toàn cả khi khóa học chưa có module)
    function onCourseChange(selectedCourseId, isInitialLoad) {
        const courseInput = document.getElementById('courseIdInput');
        if (courseInput) courseInput.value = selectedCourseId || '';

        const modSelect = document.getElementById('quizModuleSelect');
        const qModFilter = document.getElementById('questionModuleFilter');
        const emptyNotice = document.getElementById('quizModuleEmptyNotice');

        if (!modSelect) return;

        // Đếm xem khóa học được chọn có bao nhiêu module
        let matchingModules = 0;
        if (selectedCourseId) {
            Array.from(modSelect.options).forEach(function(opt) {
                if (opt.value && (opt.dataset.course || '') === selectedCourseId) {
                    matchingModules++;
                }
            });
        }

        // Nếu khóa học đang chọn chưa có module nào, hiển thị thông báo và mở toàn bộ module để người dùng vẫn chọn được
        const shouldShowAll = !selectedCourseId || matchingModules === 0;
        activeCourseFilterId = shouldShowAll ? '' : selectedCourseId;

        if (emptyNotice) {
            emptyNotice.classList.toggle('hidden', !selectedCourseId || matchingModules > 0);
        }

        // Lọc các option trong dropdown Chương / Module chính
        Array.from(modSelect.options).forEach(function(opt) {
            if (!opt.value) return;
            const visible = shouldShowAll || (opt.dataset.course || '') === selectedCourseId;
            opt.hidden = !visible;
            opt.disabled = !visible;
        });

        // Nếu module đang chọn không thuộc khóa học mới, đặt lại về rỗng
        if (!isInitialLoad && modSelect.value) {
            const currentOpt = modSelect.options[modSelect.selectedIndex];
            if (currentOpt && currentOpt.disabled) {
                modSelect.value = '';
            }
        }

        // Nếu đã chọn khóa học nhưng chưa chọn module nào, tự động chọn sẵn module đầu tiên của khóa học đó
        if (selectedCourseId && !modSelect.value) {
            const firstVisible = Array.from(modSelect.options).find(opt => opt.value && !opt.disabled && (opt.dataset.course || '') === selectedCourseId);
            if (firstVisible) {
                modSelect.value = firstVisible.value;
            }
        }

        // Đồng bộ bộ lọc module ở phần danh sách câu hỏi
        if (qModFilter) {
            Array.from(qModFilter.options).forEach(function(opt) {
                if (!opt.value) return;
                const visible = shouldShowAll || (opt.dataset.course || '') === selectedCourseId;
                opt.hidden = !visible;
                opt.disabled = !visible;
            });
            qModFilter.value = modSelect.value || '';
        }

        syncNavigationLinks();
        filterQuestions();
        syncRandomCountsWithModule();
        verifyQuiz();
    }

    // 3B. Xử lý khi đổi Module (đồng bộ ngược lại Khóa học, lọc câu hỏi và số lượng random)
    function onQuizModuleChange(selectedModuleId) {
        const modSelect = document.getElementById('quizModuleSelect');
        if (modSelect && selectedModuleId) {
            const selectedOpt = modSelect.options[modSelect.selectedIndex];
            const modCourseId = selectedOpt ? (selectedOpt.dataset.course || '') : '';
            if (modCourseId) {
                const courseInput = document.getElementById('courseIdInput');
                const courseSelect = document.getElementById('courseSelect');
                if (courseInput) courseInput.value = modCourseId;
                if (courseSelect && courseSelect.value !== modCourseId) {
                    courseSelect.value = modCourseId;
                    activeCourseFilterId = modCourseId;
                    const emptyNotice = document.getElementById('quizModuleEmptyNotice');
                    if (emptyNotice) emptyNotice.classList.add('hidden');
                }
            }
        }

        const moduleFilter = document.getElementById('questionModuleFilter');
        if (moduleFilter) {
            moduleFilter.value = selectedModuleId || '';
        }
        syncNavigationLinks();
        filterQuestions();
        syncRandomCountsWithModule();
        verifyQuiz();
    }

    function syncNavigationLinks() {
        const cId = (document.getElementById('courseIdInput')?.value || '').trim();
        const mId = (document.getElementById('quizModuleSelect')?.value || '').trim();
        const ctx = '${pageContext.request.contextPath}';
        const query = '?courseId=' + encodeURIComponent(cId) + '&moduleId=' + encodeURIComponent(mId);

        const qBank = document.getElementById('linkToQuestionBank');
        if (qBank) qBank.href = ctx + '/expert/questions' + query;

        const qNew = document.getElementById('linkToNewQuestion');
        if (qNew) qNew.href = ctx + '/expert/questions/detail' + query;

        const qListTop = document.getElementById('linkToQuizListTop');
        if (qListTop) qListTop.href = ctx + '/expert/quizzes' + query;
    }

    // 4. Xử lý tích chọn câu hỏi
    function onQuestionCheckChange(checkbox) {
        if (${isUsed ? 'true' : 'false'}) return;
        const item = checkbox.closest('.question-item');
        if (checkbox.checked) {
            item.classList.add('bg-brand-50/30', 'border-brand-500', 'ring-1', 'ring-brand-300');
            item.classList.remove('bg-surface-card');
            item.dataset.selected = 'true';
        } else {
            item.classList.remove('bg-brand-50/30', 'border-brand-500', 'ring-1', 'ring-brand-300');
            item.classList.add('bg-surface-card');
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

    // 5. Lọc danh sách câu hỏi theo từ khóa, khóa học và module
    function filterQuestions() {
        const keyword = (document.getElementById('questionSearch')?.value || '').toLowerCase().trim();
        const targetModule = (document.getElementById('questionModuleFilter')?.value || '').trim();
        const onlySelected = document.getElementById('onlySelectedFilter') ? document.getElementById('onlySelectedFilter').checked : false;

        let visibleCount = 0;
        const items = document.querySelectorAll('.question-item');
        items.forEach(function(row) {
            const text = (row.dataset.text || '').toLowerCase();
            const mod = (row.dataset.module || '').trim();
            const course = (row.dataset.course || '').trim();
            const isSelected = row.dataset.selected === 'true';

            const matchesKeyword = keyword === '' || text.includes(keyword);
            const matchesModule = targetModule === '' || mod === targetModule;
            const matchesCourse = targetModule !== '' || activeCourseFilterId === '' || course === activeCourseFilterId || isSelected;
            const matchesSelected = !onlySelected || isSelected;

            if (matchesKeyword && matchesModule && matchesCourse && matchesSelected) {
                row.style.display = 'flex';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        const noMatchMsg = document.getElementById('noQuestionMatch');
        if (noMatchMsg) {
            noMatchMsg.classList.toggle('hidden', visibleCount > 0 || items.length === 0);
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

    // 6. Kiểm tra tính hợp lệ bài thi (Verification Checklist)
    function setCheckStatus(elemId, isValid, detailText) {
        const el = document.getElementById(elemId);
        if (!el) return;
        const icon = el.querySelector('i');
        const span = el.querySelector('span');

        if (isValid) {
            icon.className = 'fa-solid fa-circle-check text-status-success';
            if (span) span.className = 'text-text-primary font-semibold';
        } else {
            icon.className = 'fa-solid fa-circle-xmark text-status-danger';
            if (span) span.className = 'text-status-danger font-semibold';
        }

        if (detailText && span) {
            if (!span.dataset.baseText) span.dataset.baseText = span.textContent;
            span.textContent = span.dataset.baseText + ' (' + detailText + ')';
        }
    }

    function verifyQuiz() {
        const title = (document.getElementById('quizTitleInput')?.value || '').trim();
        const titleWords = countWords(title);
        const isTitleValid = title.length > 0 && title.length <= 255 && titleWords <= MAX_QUIZ_TITLE_WORDS;

        const moduleId = (document.getElementById('quizModuleSelect')?.value || '').trim();
        const isModuleValid = moduleId.length > 0;

        const passScoreVal = document.getElementById('passScoreInput')?.value.trim() || '';
        const passScoreNum = parseFloat(passScoreVal);
        const isPassScoreValid = passScoreVal !== '' && !isNaN(passScoreNum) && passScoreNum >= 0 && passScoreNum <= 10;

        const timeLimitVal = document.getElementById('timeLimitInput')?.value.trim() || '';
        const timeLimitNum = Number(timeLimitVal);
        const isTimeLimitValid = timeLimitVal !== '' && Number.isInteger(timeLimitNum) && timeLimitNum >= 1 && timeLimitNum <= 600;

        const selectedCount = document.querySelectorAll('.question-check:checked').length;
        const isQuestionsValid = selectedCount >= 1;

        setCheckStatus('chkQuizTitle', isTitleValid);
        setCheckStatus('chkQuizModule', isModuleValid);
        setCheckStatus('chkQuizScore', isPassScoreValid);
        setCheckStatus('chkQuizTime', isTimeLimitValid);
        setCheckStatus('chkQuizQuestions', isQuestionsValid, selectedCount + ' câu đã chọn');

        return isTitleValid && isModuleValid && isQuestionsValid && isPassScoreValid && isTimeLimitValid;
    }

    // 7. Xử lý ảnh đại diện, tự động tách link ảnh gốc từ Google Images & Preset
    function extractCleanImageUrl(rawUrl) {
        if (!rawUrl) return { url: '', extracted: false };
        const trimmed = rawUrl.trim();
        try {
            if (trimmed.includes('google.') && (trimmed.includes('imgurl=') || trimmed.includes('/imgres'))) {
                const parsed = new URL(trimmed);
                const imgurl = parsed.searchParams.get('imgurl');
                if (imgurl) return { url: decodeURIComponent(imgurl), extracted: true };
            }
        } catch (e) {
            const match = trimmed.match(/[?&]imgurl=([^&]+)/);
            if (match && match[1]) {
                try { return { url: decodeURIComponent(match[1]), extracted: true }; } catch (err) {}
            }
        }
        return { url: trimmed, extracted: false };
    }

    function selectPresetImage(url) {
        const input = document.getElementById('imageUrlInput');
        if (input) {
            input.value = url;
            onImageUrlInput(url);
        }
    }

    function onImageUrlInput(val) {
        const preview = document.getElementById('imagePreview');
        const statusText = document.getElementById('imageStatusText');
        const extractedNotice = document.getElementById('googleExtractedNotice');
        const input = document.getElementById('imageUrlInput');

        const result = extractCleanImageUrl(val);
        if (result.extracted && input) {
            input.value = result.url;
            if (extractedNotice) extractedNotice.classList.remove('hidden');
        } else if (extractedNotice) {
            extractedNotice.classList.add('hidden');
        }

        const trimmed = result.url;
        if (!trimmed) {
            if (preview) preview.src = 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100&auto=format&fit=crop&q=80';
            if (statusText) statusText.textContent = 'Chưa chọn ảnh (dùng ảnh mặc định)';
            return;
        }
        if (preview) preview.src = trimmed;
        if (statusText) statusText.textContent = 'Đã áp dụng đường dẫn ảnh.';
    }

    // 8. Tự động chọn ngẫu nhiên câu hỏi (Fisher-Yates Shuffle)
    function getAvailableQuestionsCountInModule(moduleId) {
        if (!moduleId) return 0;
        let count = 0;
        document.querySelectorAll('.question-item').forEach(function(item) {
            if ((item.getAttribute('data-module') || '').trim() === moduleId) count++;
        });
        return count;
    }

    function syncRandomCountsWithModule() {
        const modSelect = document.getElementById('quizModuleSelect');
        const selectedMod = modSelect ? modSelect.value.trim() : '';
        const count = getAvailableQuestionsCountInModule(selectedMod);
        const quickInput = document.getElementById('quickRandomCount');
        const modalInput = document.getElementById('modalRandomCount');
        const maxBadge = document.getElementById('quickRandomMaxHint');

        if (maxBadge) {
            maxBadge.textContent = selectedMod ? '(Tối đa: ' + count + ')' : '(Chưa chọn chương)';
        }

        const modalScopeElem = document.getElementById('modalModuleScopeName');
        if (modalScopeElem) {
            modalScopeElem.textContent = (modSelect && modSelect.selectedIndex > 0) ? modSelect.options[modSelect.selectedIndex].text : 'Chưa chọn chương';
        }

        const modalPoolInfo = document.getElementById('modalPoolInfo');
        if (modalPoolInfo) {
            modalPoolInfo.textContent = selectedMod ? 'Có ' + count + ' câu hỏi trong chương này.' : 'Vui lòng chọn chương.';
        }

        if (count > 0) {
            if (quickInput) { quickInput.max = count; if (quickInput.value > count) quickInput.value = count; }
            if (modalInput) { modalInput.max = count; if (modalInput.value > count) modalInput.value = count; }
        }
    }

    function validateRandomInput(input) {
        const modSelect = document.getElementById('quizModuleSelect');
        const count = getAvailableQuestionsCountInModule(modSelect ? modSelect.value.trim() : '');
        let val = parseInt(input.value, 10);
        if (isNaN(val) || val < 1) input.value = count > 0 ? 1 : 0;
        else if (val > count) input.value = count;
    }

    function quickRandomQuestions() {
        const modSelect = document.getElementById('quizModuleSelect');
        const selectedModuleId = modSelect ? modSelect.value.trim() : '';
        if (!selectedModuleId) {
            alert('Vui lòng chọn Chương / Module trước khi tạo câu hỏi ngẫu nhiên.');
            modSelect?.focus();
            return;
        }

        const maxCount = getAvailableQuestionsCountInModule(selectedModuleId);
        if (maxCount === 0) {
            showToast('Chương này hiện chưa có câu hỏi nào.', 'warning');
            return;
        }

        const input = document.getElementById('quickRandomCount');
        let count = parseInt(input?.value || maxCount, 10);
        executeRandomSelection(Math.min(count, maxCount), true);
    }

    function executeRandomSelection(requestedCount, replaceExisting) {
        const currentMod = document.getElementById('quizModuleSelect')?.value.trim() || '';
        const items = Array.from(document.querySelectorAll('.question-item'));

        let candidates = items.filter(item => {
            const itemMod = (item.getAttribute('data-module') || '').trim();
            return currentMod === '' || itemMod === currentMod;
        });

        if (candidates.length === 0) {
            showToast('Không tìm thấy câu hỏi phù hợp trong chương.', 'warning');
            return;
        }

        if (replaceExisting) {
            items.forEach(item => {
                const cb = item.querySelector('.question-check');
                if (cb && cb.checked) { cb.checked = false; onQuestionCheckChange(cb); }
            });
        }

        let pool = replaceExisting ? [...candidates] : candidates.filter(item => !item.querySelector('.question-check')?.checked);

        // Thuật toán xáo trộn Fisher-Yates
        for (let i = pool.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [pool[i], pool[j]] = [pool[j], pool[i]];
        }

        const pickCount = Math.min(requestedCount, pool.length);
        pool.slice(0, pickCount).forEach(item => {
            const cb = item.querySelector('.question-check');
            if (cb) { cb.checked = true; onQuestionCheckChange(cb); }
        });

        filterQuestions();
        updateSelectedCount();
        verifyQuiz();
        closeRandomModal();
        showToast('Đã chọn ngẫu nhiên ' + pickCount + ' câu hỏi!', 'success');
    }

    function openRandomModal() {
        syncRandomCountsWithModule();
        document.getElementById('randomModal')?.classList.remove('hidden');
    }

    function closeRandomModal() {
        document.getElementById('randomModal')?.classList.add('hidden');
    }

    function setModalCount(val) {
        const modSelect = document.getElementById('quizModuleSelect');
        const maxCount = getAvailableQuestionsCountInModule(modSelect ? modSelect.value.trim() : '');
        const input = document.getElementById('modalRandomCount');
        if (!input) return;
        input.value = (val === 'all') ? maxCount : Math.min(parseInt(val, 10) || 1, maxCount);
    }

    function applyModalRandom() {
        const modSelect = document.getElementById('quizModuleSelect');
        if (!modSelect || !modSelect.value) {
            alert('Vui lòng chọn Chương / Module trước.');
            modSelect?.focus();
            return;
        }
        const count = parseInt(document.getElementById('modalRandomCount')?.value || 10, 10);
        const modeRadio = document.querySelector('input[name="modalMode"]:checked');
        executeRandomSelection(count, modeRadio ? modeRadio.value === 'replace' : true);
    }

    function showToast(message, type = 'success') {
        const toast = document.getElementById('toastNotification');
        const content = document.getElementById('toastContent');
        const msg = document.getElementById('toastMsg');
        if (!toast || !content || !msg) { alert(message); return; }

        msg.textContent = message;
        content.className = (type === 'success') 
            ? 'flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl border bg-brand-700 text-white border-brand-600 text-xs sm:text-sm font-semibold'
            : 'flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl border bg-amber-600 text-white border-amber-500 text-xs sm:text-sm font-semibold';

        toast.classList.remove('translate-y-10', 'opacity-0', 'pointer-events-none');
        toast.classList.add('translate-y-0', 'opacity-100');
        setTimeout(() => {
            toast.classList.remove('translate-y-0', 'opacity-100');
            toast.classList.add('translate-y-10', 'opacity-0', 'pointer-events-none');
        }, 3000);
    }

    // Khởi tạo trạng thái ban đầu khi tải trang
    document.addEventListener('DOMContentLoaded', function() {
        const isQuizReadOnly = ${isUsed ? 'true' : 'false'};
        if (isQuizReadOnly) {
            document.getElementById('quizForm')?.addEventListener('submit', function(e) {
                e.preventDefault();
                alert('Bài kiểm tra này đã được sử dụng trong khóa học hoặc đã có học viên làm bài nên không thể chỉnh sửa.');
                return false;
            });
        }

        const modSelect = document.getElementById('quizModuleSelect');
        const courseSelect = document.getElementById('courseSelect');
        // Nếu đã có module được chọn sẵn, đồng bộ ngược lại khóa học của module đó trước
        if (modSelect && modSelect.value && courseSelect) {
            const selectedOpt = modSelect.options[modSelect.selectedIndex];
            const modCourse = selectedOpt ? (selectedOpt.dataset.course || '') : '';
            if (modCourse) {
                courseSelect.value = modCourse;
            }
        }
        if (courseSelect) {
            onCourseChange(courseSelect.value, true);
        } else {
            filterQuestions();
            syncRandomCountsWithModule();
        }
        updateSelectedCount();
        onQuizTitleChange();
        verifyQuiz();

        document.getElementById('quizForm')?.addEventListener('submit', function(e) {
            if (!verifyQuiz()) {
                const title = document.getElementById('quizTitleInput')?.value.trim();
                if (!title) { alert('Vui lòng nhập tên bài kiểm tra.'); e.preventDefault(); return; }
                const moduleId = document.getElementById('quizModuleSelect')?.value.trim();
                if (!moduleId) { alert('Vui lòng chọn Chương / Module áp dụng cho bài kiểm tra.'); e.preventDefault(); return; }
                const timeLimitVal = document.getElementById('timeLimitInput')?.value.trim() || '';
                const timeLimitNum = Number(timeLimitVal);
                if (timeLimitVal === '' || !Number.isInteger(timeLimitNum) || timeLimitNum < 1 || timeLimitNum > 600) {
                    alert('Thời gian làm bài phải từ 1 đến 600 phút (không để trống).');
                    document.getElementById('timeLimitInput')?.focus();
                    e.preventDefault();
                    return;
                }
                const selectedCount = document.querySelectorAll('.question-check:checked').length;
                if (selectedCount === 0) { alert('Vui lòng chọn ít nhất 1 câu hỏi vào bài kiểm tra.'); e.preventDefault(); return; }
                if (!confirm('Một số điều kiện kiểm tra hợp lệ của Quiz chưa đạt chuẩn. Bạn có chắc chắn muốn lưu tiếp không?')) {
                    e.preventDefault();
                }
            }
        });
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
