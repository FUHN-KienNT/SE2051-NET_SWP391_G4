<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<%-- 
=============================================================================
MÀN HÌNH TẠO MỚI & CHỈNH SỬA CHI TIẾT CÂU HỎI (QUESTION DETAIL)
Dành cho Chuyên gia nội dung (Expert) / Giảng viên:
- Thiết lập thông tin phân loại: Khóa học, Module / Chương, Trạng thái.
- Soạn thảo nội dung câu hỏi với bộ đếm từ tự động (tối đa 120 từ).
- 3 loại câu hỏi hỗ trợ:
  + Trắc nghiệm 1 đáp án (Single choice: radio)
  + Trắc nghiệm nhiều đáp án (Multiple choice: checkbox)
  + Điền vào chỗ trống (Fill in the blank: từ khóa đáp án chấp nhận)
- Bảng kiểm tra hợp lệ thời gian thực (Live Verification Checklist).
=============================================================================
--%>

<main class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">

    <!-- ===================================================================== -->
    <!-- PHẦN 1: BREADCRUMB & THANH ĐIỀU HƯỚNG ĐẦU TRANG                       -->
    <!-- ===================================================================== -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
            <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-700 mb-1">
                <a href="${pageContext.request.contextPath}/expert/questions?courseId=${courseId}" class="hover:underline">Question Bank</a>
                <span>/</span>
                <span class="text-slate-500">${empty question ? 'Create Question' : 'Edit Question'}</span>
            </div>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900">
                ${empty question ? 'Tạo câu hỏi mới' : 'Chỉnh sửa câu hỏi'}
            </h1>
        </div>

        <!-- Các nút điều hướng nhanh -->
        <div class="flex flex-wrap items-center gap-2.5">
            <a href="${pageContext.request.contextPath}/expert/quizzes?courseId=${courseId}&moduleId=${not empty question.moduleId ? question.moduleId : moduleId}"
               class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-50 transition shadow-sm">
                <i class="fa-solid fa-clipboard-question mr-1.5 text-slate-500" aria-hidden="true"></i>Quản lý Quiz
            </a>
            <a href="${pageContext.request.contextPath}/expert/questions?courseId=${courseId}&moduleId=${not empty question.moduleId ? question.moduleId : moduleId}"
               class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-xs font-bold text-slate-700 hover:bg-slate-50 transition shadow-sm">
                <i class="fa-solid fa-arrow-left mr-1.5 text-slate-500" aria-hidden="true"></i>Danh sách câu hỏi
            </a>
        </div>
    </div>

    <!-- ===================================================================== -->
    <!-- PHẦN 2: THÔNG BÁO LỖI NẾU CÓ (SERVER-SIDE ERROR ALERT)                -->
    <!-- ===================================================================== -->
    <c:if test="${not empty error}">
        <div class="mb-5 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold flex items-center gap-3">
            <i class="fa-solid fa-circle-exclamation text-rose-500 text-base" aria-hidden="true"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <!-- FORM SOẠN THẢO CÂU HỎI -->
    <form method="post" action="${pageContext.request.contextPath}/expert/questions/detail" id="questionForm" class="space-y-6">
        <input type="hidden" name="id" value="${question.id}">
        <input type="hidden" name="courseId" id="courseIdInput" value="${courseId}">

        <!-- ================================================================= -->
        <!-- PHẦN 3: KHỐI 1 - THÔNG TIN PHÂN LOẠI & TRẠNG THÁI                 -->
        <!-- ================================================================= -->
        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="flex items-center justify-between pb-4 mb-6 border-b border-slate-100">
                <div class="flex items-center gap-2">
                    <span class="w-2.5 h-6 bg-emerald-600 rounded-full inline-block"></span>
                    <h2 class="text-lg font-black text-slate-900">Thông tin phân loại &amp; Trạng thái</h2>
                </div>
                <!-- Nút lưu nhanh đầu form -->
                <button type="submit" class="inline-flex items-center px-5 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs shadow-sm transition">
                    <i class="fa-solid fa-floppy-disk mr-2" aria-hidden="true"></i>Lưu câu hỏi
                </button>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <!-- Chọn Khóa học (để lọc nhanh danh sách Chương / Module bên cạnh) -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">
                        Khóa học
                    </label>
                    <select id="courseSelect" onchange="onCourseChange(this.value, false)"
                            class="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 transition cursor-pointer">
                        <option value="">-- Tất cả khóa học --</option>
                        <c:forEach var="c" items="${courses}">
                            <option value="${c.id}" ${courseId eq c.id ? 'selected' : ''}>
                                ${c.title} (${c.moduleCount} chương)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Chọn Chương / Module -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">
                        Chương / Module <span class="text-rose-500">*</span>
                    </label>
                    <select name="moduleId" id="moduleSelect" required onchange="onModuleChange(this.value)"
                            class="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 transition cursor-pointer">
                        <option value="">-- Chọn module --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" data-course="${m.courseId}" ${(question.moduleId eq m.id or moduleId eq m.id) ? 'selected' : ''}><c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Chọn Trạng thái hiển thị -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">
                        Trạng thái câu hỏi <span class="text-rose-500">*</span>
                    </label>
                    <select name="status" class="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 transition cursor-pointer">
                        <option value="public" ${empty question.status or question.status eq 'public' ? 'selected' : ''}>Công khai (Public)</option>
                        <option value="draft" ${question.status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft)</option>
                        <option value="hidden" ${question.status eq 'hidden' ? 'selected' : ''}>Đã ẩn (Hidden)</option>
                    </select>
                </div>
            </div>

            <!-- Thông báo khi khóa học đang chọn chưa có module nào -->
            <p id="moduleEmptyNotice" class="hidden text-xs text-amber-800 bg-amber-50 border border-amber-200 rounded-xl px-3.5 py-2 font-semibold mt-3">
                <i class="fa-solid fa-triangle-exclamation mr-1.5 text-amber-600" aria-hidden="true"></i>
                Khóa học đang chọn chưa có chương (module) nào. Hệ thống đang hiển thị tất cả module từ các khóa học khác để bạn chọn.
            </p>
        </section>

        <!-- ================================================================= -->
        <!-- PHẦN 4: KHỐI 2 - NỘI DUNG CÂU HỎI & LOẠI CÂU HỎI                  -->
        <!-- ================================================================= -->
        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-5">
            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                <div class="flex items-center gap-2">
                    <span class="w-2.5 h-6 bg-emerald-600 rounded-full inline-block"></span>
                    <h2 class="text-lg font-black text-slate-900">Nội dung câu hỏi</h2>
                </div>
                <!-- Huy hiệu đếm số từ theo thời gian thực (giới hạn 120 từ) -->
                <div id="wordCountBadge" class="inline-flex items-center px-3 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-700 border border-slate-200 transition-colors">
                    <i class="fa-solid fa-pen-nib mr-1.5 text-slate-400" aria-hidden="true"></i>
                    Số từ: <span id="wordCountNum" class="mx-1">0</span> / 120 từ
                </div>
            </div>

            <!-- Vùng nhập văn bản câu hỏi -->
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1.5">
                    Nội dung chi tiết / Tiêu đề câu hỏi <span class="text-rose-500">*</span>
                </label>
                <textarea name="content" id="questionContent" rows="4" required
                          oninput="onContentChange()"
                          placeholder="Nhập nội dung câu hỏi tại đây... (Ví dụ: Trong Java Servlet, phương thức nào được gọi khi có yêu cầu HTTP GET?)"
                          class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none text-sm transition leading-relaxed">${question.content}</textarea>

                <!-- Cảnh báo khi vượt quá 120 từ -->
                <div id="wordCountAlert" class="hidden mt-1.5 text-xs font-bold text-rose-600 flex items-center gap-1.5">
                    <i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i>
                    <span>Nội dung đã vượt quá giới hạn 120 từ! Vui lòng rút gọn nội dung câu hỏi.</span>
                </div>
            </div>

            <!-- Lựa chọn loại câu hỏi -->
            <div class="pt-2">
                <label class="block text-xs font-bold text-slate-700 mb-2">
                    Loại câu hỏi <span class="text-rose-500">*</span>
                </label>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <!-- Trắc nghiệm 1 đáp án -->
                    <label class="type-card flex items-start gap-3 p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition">
                        <input type="radio" name="type" value="single_choice"
                        ${empty question.type or question.type eq 'single_choice' ? 'checked' : ''}
                               onchange="onTypeChanged('single_choice')" class="mt-1 accent-emerald-600">
                        <div>
                            <div class="font-bold text-xs text-slate-800">Một đáp án đúng (Single)</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Chọn duy nhất 1 phương án chính xác trong danh sách lựa chọn.</div>
                        </div>
                    </label>

                    <!-- Trắc nghiệm nhiều đáp án -->
                    <label class="type-card flex items-start gap-3 p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition">
                        <input type="radio" name="type" value="multiple_choice"
                        ${question.type eq 'multiple_choice' ? 'checked' : ''}
                               onchange="onTypeChanged('multiple_choice')" class="mt-1 accent-emerald-600">
                        <div>
                            <div class="font-bold text-xs text-slate-800">Nhiều đáp án đúng (Multiple)</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Học viên cần chọn đủ các phương án đúng.</div>
                        </div>
                    </label>

                    <!-- Điền vào chỗ trống -->
                    <label class="type-card flex items-start gap-3 p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition">
                        <input type="radio" name="type" value="fill_in_blank"
                        ${question.type eq 'fill_in_blank' ? 'checked' : ''}
                               onchange="onTypeChanged('fill_in_blank')" class="mt-1 accent-emerald-600">
                        <div>
                            <div class="font-bold text-xs text-slate-800">Điền vào chỗ trống (Fill in blank)</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Nhập các từ khóa chuẩn. Học viên điền khớp sẽ có điểm.</div>
                        </div>
                    </label>
                </div>
            </div>
        </section>

        <!-- ================================================================= -->
        <!-- PHẦN 5A: KHỐI 3A - DANH SÁCH PHƯƠNG ÁN TRẮC NGHIỆM               -->
        <!-- ================================================================= -->
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
                    <i class="fa-solid fa-plus mr-1.5" aria-hidden="true"></i>Thêm lựa chọn
                </button>
            </div>

            <div id="choiceRows" class="space-y-3">
                <c:choose>
                    <c:when test="${not empty question.options and question.type ne 'fill_in_blank'}">
                        <c:forEach var="o" items="${question.options}" varStatus="status">
                            <div class="choice-row flex items-center gap-3 p-2.5 rounded-xl border border-slate-200 bg-slate-50/50">
                                <input type="hidden" name="optionId" value="${o.id}">
                                <div class="flex items-center justify-center w-8">
                                    <input type="${question.type eq 'single_choice' ? 'radio' : 'checkbox'}"
                                           name="correctIndex" value="${status.index}"
                                        ${o.correct ? 'checked' : ''}
                                           class="correct-box w-4 h-4 accent-emerald-600 cursor-pointer"
                                           onchange="verifyQuestion()">
                                </div>
                                <input type="text" name="optionText" value="${o.optionText}" required
                                       oninput="verifyQuestion()"
                                       placeholder="Nhập nội dung lựa chọn..."
                                       class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500">
                                <button type="button" onclick="removeOptionRow(this)" aria-label="Xóa phương án"
                                        class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                    <i class="fa-solid fa-trash-can text-xs" aria-hidden="true"></i>
                                </button>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <!-- 4 lựa chọn mặc định ban đầu: A, B, C, D -->
                        <c:forEach var="label" items="${['A', 'B', 'C', 'D']}" varStatus="st">
                            <div class="choice-row flex items-center gap-3 p-2.5 rounded-xl border border-slate-200 bg-slate-50/50">
                                <input type="hidden" name="optionId" value="">
                                <div class="flex items-center justify-center w-8">
                                    <input type="radio" name="correctIndex" value="${st.index}" ${st.index == 0 ? 'checked' : ''}
                                           class="correct-box w-4 h-4 accent-emerald-600 cursor-pointer"
                                           onchange="verifyQuestion()">
                                </div>
                                <input type="text" name="optionText" required
                                       oninput="verifyQuestion()"
                                       placeholder="Phương án ${label}..."
                                       class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500">
                                <button type="button" onclick="removeOptionRow(this)" aria-label="Xóa phương án"
                                        class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                    <i class="fa-solid fa-trash-can text-xs" aria-hidden="true"></i>
                                </button>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <!-- ================================================================= -->
        <!-- PHẦN 5B: KHỐI 3B - TỪ KHÓA ĐÁP ÁN CHO ĐIỀN VÀO CHỖ TRỐNG          -->
        <!-- ================================================================= -->
        <section id="fillBlankBox" class="hidden bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="flex items-center justify-between pb-4 mb-4 border-b border-slate-100">
                <div>
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-6 bg-purple-600 rounded-full inline-block"></span>
                        <h2 class="text-lg font-black text-slate-900">Từ khóa đáp án chấp nhận (Điền vào chỗ trống)</h2>
                    </div>
                    <p class="text-xs text-slate-500 mt-1">
                        Nhập từ khóa đáp án chuẩn (có thể thêm từ đồng nghĩa/viết tắt). Học viên điền trùng 1 trong các từ khóa này (không phân biệt hoa thường) sẽ được tính điểm.
                    </p>
                </div>
                <button type="button" onclick="addKeywordRow()"
                        class="px-3.5 py-2 rounded-xl bg-purple-50 hover:bg-purple-100 text-purple-800 text-xs font-bold transition">
                    <i class="fa-solid fa-plus mr-1.5" aria-hidden="true"></i>Thêm từ khóa khác
                </button>
            </div>

            <div id="keywordRows" class="space-y-3">
                <c:choose>
                    <c:when test="${not empty question.options and (question.type eq 'fill_in_blank')}">
                        <c:forEach var="o" items="${question.options}" varStatus="status">
                            <div class="keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20">
                                <input type="hidden" name="optionId" value="${o.id}">
                                <span class="w-8 text-center text-xs font-bold text-purple-700">#${status.count}</span>
                                <input type="text" name="optionText" value="${o.optionText}" required
                                       oninput="verifyQuestion()"
                                       placeholder="Nhập từ khóa đáp án (ví dụ: HttpServlet hoặc doGet)..."
                                       class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
                                <button type="button" onclick="removeKeywordRow(this)" aria-label="Xóa từ khóa"
                                        class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                    <i class="fa-solid fa-trash-can text-xs" aria-hidden="true"></i>
                                </button>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <!-- 2 từ khóa mặc định -->
                        <div class="keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20">
                            <input type="hidden" name="optionId" value="">
                            <span class="w-8 text-center text-xs font-bold text-purple-700">#1</span>
                            <input type="text" name="optionText" required
                                   oninput="verifyQuestion()"
                                   placeholder="Từ khóa chính (Ví dụ: doGet)..."
                                   class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
                            <button type="button" onclick="removeKeywordRow(this)" aria-label="Xóa từ khóa"
                                    class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                <i class="fa-solid fa-trash-can text-xs" aria-hidden="true"></i>
                            </button>
                        </div>
                        <div class="keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20">
                            <input type="hidden" name="optionId" value="">
                            <span class="w-8 text-center text-xs font-bold text-purple-700">#2</span>
                            <input type="text" name="optionText"
                                   oninput="verifyQuestion()"
                                   placeholder="Từ khóa phụ / viết tắt thay thế (Tùy chọn)..."
                                   class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
                            <button type="button" onclick="removeKeywordRow(this)" aria-label="Xóa từ khóa"
                                    class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                                <i class="fa-solid fa-trash-can text-xs" aria-hidden="true"></i>
                            </button>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <!-- ================================================================= -->
        <!-- PHẦN 6: KHỐI 4 - BẢNG KIỂM TRA HỢP LỆ (VERIFICATION CHECKLIST)    -->
        <!-- ================================================================= -->
        <section class="bg-slate-50 rounded-2xl border border-slate-200 p-5">
            <div class="flex items-center justify-between mb-3">
                <div class="flex items-center gap-2">
                    <i class="fa-solid fa-shield-halved text-emerald-600 text-sm" aria-hidden="true"></i>
                    <h3 class="font-bold text-xs uppercase tracking-wider text-slate-700">Kiểm tra tính hợp lệ của câu hỏi (Verification)</h3>
                </div>
                <button type="button" onclick="verifyQuestion()" class="text-xs font-bold text-emerald-700 hover:underline">
                    <i class="fa-solid fa-rotate mr-1" aria-hidden="true"></i>Kiểm tra lại
                </button>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs" id="verifyChecklist">
                <div class="flex items-center gap-2" id="chkContent">
                    <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                    <span class="text-slate-600">Nội dung câu hỏi không rỗng</span>
                </div>
                <div class="flex items-center gap-2" id="chkWords">
                    <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                    <span class="text-slate-600">Độ dài câu hỏi &le; 120 từ</span>
                </div>
                <div class="flex items-center gap-2" id="chkModule">
                    <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                    <span class="text-slate-600">Đã chọn Chương / Module</span>
                </div>
                <div class="flex items-center gap-2" id="chkAnswers">
                    <i class="fa-solid fa-circle-check text-slate-300" aria-hidden="true"></i>
                    <span class="text-slate-600">Phương án &amp; đáp án đúng hợp lệ</span>
                </div>
            </div>
        </section>

        <!-- ================================================================= -->
        <!-- PHẦN 7: CÁC NÚT ĐIỀU HƯỚNG & LƯU CÂU HỎI CUỐI TRANG               -->
        <!-- ================================================================= -->
        <div class="flex items-center justify-between pt-2">
            <a href="${pageContext.request.contextPath}/expert/questions?courseId=${courseId}"
               class="px-6 py-3 rounded-xl border border-slate-200 text-slate-700 font-bold text-sm bg-white hover:bg-slate-50 transition shadow-sm">
                <i class="fa-solid fa-arrow-left mr-2 text-slate-400" aria-hidden="true"></i>Quay lại danh sách
            </a>
            <button type="submit" id="saveQuestionBtn" class="px-8 py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm shadow-md transition">
                <i class="fa-solid fa-floppy-disk mr-2" aria-hidden="true"></i>Lưu câu hỏi
            </button>
        </div>
    </form>
</main>

<!-- ========================================================================= -->
<!-- PHẦN 8: JAVASCRIPT HỖ TRỢ XỬ LÝ GIAO DIỆN & TÍNH TOÁN DỮ LIỆU             -->
<!-- ========================================================================= -->
<script>
    const MAX_WORDS = 120;

    // 1. Lọc danh sách Module khi chọn Khóa học (an toàn cả khi khóa học chưa có module)
    function onCourseChange(selectedCourseId, isInitialLoad) {
        const courseInput = document.getElementById('courseIdInput');
        if (courseInput) courseInput.value = selectedCourseId || '';

        const modSelect = document.getElementById('moduleSelect');
        const emptyNotice = document.getElementById('moduleEmptyNotice');
        if (!modSelect) return;

        let matchingModules = 0;
        if (selectedCourseId) {
            Array.from(modSelect.options).forEach(function(opt) {
                if (opt.value && (opt.dataset.course || '') === selectedCourseId) {
                    matchingModules++;
                }
            });
        }

        const shouldShowAll = !selectedCourseId || matchingModules === 0;
        if (emptyNotice) {
            emptyNotice.classList.toggle('hidden', !selectedCourseId || matchingModules > 0);
        }

        Array.from(modSelect.options).forEach(function(opt) {
            if (!opt.value) return;
            const visible = shouldShowAll || (opt.dataset.course || '') === selectedCourseId;
            opt.hidden = !visible;
            opt.disabled = !visible;
        });

        if (!isInitialLoad && modSelect.value) {
            const currentOpt = modSelect.options[modSelect.selectedIndex];
            if (currentOpt && currentOpt.disabled) {
                modSelect.value = '';
            }
        }

        // Nếu đã chọn khóa học nhưng chưa chọn module, tự động chọn sẵn module đầu tiên của khóa học đó
        if (selectedCourseId && !modSelect.value) {
            const firstVisible = Array.from(modSelect.options).find(opt => opt.value && !opt.disabled && (opt.dataset.course || '') === selectedCourseId);
            if (firstVisible) {
                modSelect.value = firstVisible.value;
            }
        }

        verifyQuestion();
    }

    // 2. Đồng bộ ngược Khóa học khi người dùng chọn Module
    function onModuleChange(selectedModuleId) {
        const modSelect = document.getElementById('moduleSelect');
        if (modSelect && selectedModuleId) {
            const selectedOpt = modSelect.options[modSelect.selectedIndex];
            const modCourseId = selectedOpt ? (selectedOpt.dataset.course || '') : '';
            if (modCourseId) {
                const courseInput = document.getElementById('courseIdInput');
                const courseSelect = document.getElementById('courseSelect');
                if (courseInput) courseInput.value = modCourseId;
                if (courseSelect && courseSelect.value !== modCourseId) {
                    courseSelect.value = modCourseId;
                    const emptyNotice = document.getElementById('moduleEmptyNotice');
                    if (emptyNotice) emptyNotice.classList.add('hidden');
                }
            }
        }
        verifyQuestion();
    }

    // 3. Đếm số từ trong đoạn văn bản
    function countWords(str) {
        if (!str) return 0;
        const trimmed = str.trim();
        if (!trimmed) return 0;
        return trimmed.split(/\s+/).length;
    }

    // 4. Xử lý sự kiện khi gõ nội dung câu hỏi: cập nhật đếm từ và cảnh báo
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

    // 5. Lấy loại câu hỏi hiện tại đang chọn (single_choice, multiple_choice, fill_in_blank)
    function getCurrentType() {
        const selectedRadio = document.querySelector('input[name="type"]:checked');
        return selectedRadio ? selectedRadio.value : 'single_choice';
    }

    // 6. Chuyển đổi giao diện khi thay đổi loại câu hỏi
    function onTypeChanged(type) {
        const choiceBox = document.getElementById('choiceOptionsBox');
        const fillBlankBox = document.getElementById('fillBlankBox');

        if (type === 'fill_in_blank') {
            choiceBox.classList.add('hidden');
            fillBlankBox.classList.remove('hidden');

            // Disable input phương án trắc nghiệm để không gửi lên server
            choiceBox.querySelectorAll('input').forEach(input => input.disabled = true);
            fillBlankBox.querySelectorAll('input').forEach(input => input.disabled = false);
        } else {
            choiceBox.classList.remove('hidden');
            fillBlankBox.classList.add('hidden');

            choiceBox.querySelectorAll('input').forEach(input => input.disabled = false);
            fillBlankBox.querySelectorAll('input').forEach(input => input.disabled = true);

            // Chuyển giữa Radio (1 đáp án) và Checkbox (nhiều đáp án)
            const wantedInputType = (type === 'single_choice') ? 'radio' : 'checkbox';
            const correctBoxes = Array.from(document.querySelectorAll('#choiceRows .correct-box'));
            let keptSingleAnswer = false;
            correctBoxes.forEach(box => {
                box.type = wantedInputType;
                box.name = 'correctIndex';
                if (wantedInputType === 'radio' && box.checked) {
                    if (keptSingleAnswer) box.checked = false;
                    else keptSingleAnswer = true;
                }
            });
            renumberChoices();
        }

        verifyQuestion();
    }

    // 7. Đồng bộ lại chỉ số correctIndex theo đúng thứ tự hiển thị của các hàng
    function renumberChoices() {
        document.querySelectorAll('#choiceRows .choice-row').forEach((row, idx) => {
            const box = row.querySelector('.correct-box');
            if (box) {
                box.name = 'correctIndex';
                box.value = String(idx);
            }
        });
    }

    // 8. Thêm một hàng phương án trắc nghiệm mới
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
                <input type="` + inputType + `" name="correctIndex" value="` + index + `" onchange="verifyQuestion()" class="correct-box w-4 h-4 accent-emerald-600 cursor-pointer">
            </div>
            <input type="text" name="optionText" required oninput="verifyQuestion()" placeholder="Nội dung phương án..."
                   class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500">
            <button type="button" onclick="removeOptionRow(this)" aria-label="Xóa"
                    class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                <i class="fa-solid fa-trash-can text-xs" aria-hidden="true"></i>
            </button>
        `;
        rowsContainer.appendChild(row);
        renumberChoices();
        verifyQuestion();
    }

    // 9. Xóa một hàng phương án trắc nghiệm
    function removeOptionRow(btn) {
        const row = btn.closest('.choice-row');
        if (row) row.remove();
        renumberChoices();
        verifyQuestion();
    }

    // 10. Thêm một hàng từ khóa đáp án cho câu hỏi điền chỗ trống
    function addKeywordRow() {
        const container = document.getElementById('keywordRows');
        const count = container.querySelectorAll('.keyword-row').length + 1;
        const row = document.createElement('div');
        row.className = 'keyword-row flex items-center gap-3 p-2.5 rounded-xl border border-purple-200 bg-purple-50/20';
        row.innerHTML = `
            <input type="hidden" name="optionId" value="">
            <span class="w-8 text-center text-xs font-bold text-purple-700">#` + count + `</span>
            <input type="text" name="optionText" required oninput="verifyQuestion()" placeholder="Từ khóa đáp án bổ sung..."
                   class="flex-1 px-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-purple-500">
            <button type="button" onclick="removeKeywordRow(this)" aria-label="Xóa"
                    class="w-9 h-9 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition">
                <i class="fa-solid fa-trash-can text-xs" aria-hidden="true"></i>
            </button>
        `;
        container.appendChild(row);
        verifyQuestion();
    }

    // 11. Xóa một hàng từ khóa
    function removeKeywordRow(btn) {
        const row = btn.closest('.keyword-row');
        if (row) row.remove();
        document.querySelectorAll('#keywordRows .keyword-row').forEach((r, idx) => {
            const badge = r.querySelector('span');
            if (badge) badge.textContent = '#' + (idx + 1);
        });
        verifyQuestion();
    }

    // 12. Cập nhật trạng thái icon trong bảng kiểm tra hợp lệ
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

    // 13. Kiểm tra tính hợp lệ toàn diện của câu hỏi
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

    // Khởi tạo trạng thái ban đầu khi tải xong trang
    document.addEventListener('DOMContentLoaded', function() {
        const modSelect = document.getElementById('moduleSelect');
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
        }
        const type = getCurrentType();
        onTypeChanged(type);
        onContentChange();
        verifyQuestion();

        // Đảm bảo chỉ số đáp án được đánh số lại trước khi submit form
        const form = document.getElementById('questionForm');
        if (form) {
            form.addEventListener('submit', function(e) {
                renumberChoices();
                if (!verifyQuestion()) {
                    const moduleId = document.getElementById('moduleSelect')?.value.trim();
                    if (!moduleId) {
                        alert('Vui lòng chọn Chương / Module áp dụng cho câu hỏi.');
                        e.preventDefault();
                        return;
                    }
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
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
