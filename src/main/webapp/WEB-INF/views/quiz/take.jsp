<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<%-- 
=============================================================================
MÀN HÌNH LÀM BÀI THI TRẮC NGHIỆM TRỰC TUYẾN (QUIZ TAKING)
Dành cho Học viên (Student / Learner):
- Thanh tiêu đề ghim trên cùng (Sticky Header): Đồng hồ đếm ngược, điểm chuẩn đạt.
- Cột bên trái: Danh sách câu hỏi chi tiết (Hỗ trợ 1 đáp án, nhiều đáp án, điền chỗ trống).
  + Nút đánh dấu xem lại câu hỏi (Flag for review).
  + Điều hướng nhanh câu trước / câu sau.
- Cột bên phải: Ma trận bảng câu hỏi (Question Matrix Navigation) & Thanh tiến độ làm bài.
- Hộp thoại Modal xác nhận nộp bài kèm cảnh báo nếu còn câu hỏi chưa làm.
=============================================================================
--%>

<main class="flex-grow bg-surface py-6 md:py-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">

        <!-- ================================================================= -->
        <!-- PHẦN 1: THANH TIÊU ĐỀ BÀI THI & ĐỒNG HỒ ĐẾM NGƯỢC (STICKY TOP)     -->
        <!-- ================================================================= -->
        <header class="sticky top-16 z-30 bg-surface-card/95 backdrop-blur-md p-4 sm:p-6 rounded-2xl border border-border-default shadow-sm mb-6 transition-all duration-200">
            <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                <!-- Thông tin tiêu đề bài thi và module -->
                <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-center gap-2 mb-1.5">
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-brand-50 text-brand-700 border border-brand-100">
                            <i class="fa-solid fa-graduation-cap mr-1 text-[11px]" aria-hidden="true"></i> Bài thi trắc nghiệm
                        </span>
                        <c:if test="${not empty quiz.moduleTitle}">
                            <span class="text-xs text-text-secondary flex items-center gap-1 truncate max-w-xs sm:max-w-md">
                                <i class="fa-solid fa-book-bookmark text-brand-700 text-xs" aria-hidden="true"></i>
                                Module: ${quiz.moduleTitle}
                            </span>
                        </c:if>
                    </div>
                    <h1 class="text-xl sm:text-2xl font-bold text-text-primary tracking-tight truncate">${quiz.title}</h1>
                    <div class="flex flex-wrap items-center gap-3 text-xs sm:text-sm text-text-secondary mt-1">
                        <span class="inline-flex items-center">
                            <i class="fa-solid fa-bullseye text-brand-700 mr-1.5" aria-hidden="true"></i>
                            Điểm đạt: <strong class="ml-1 text-text-primary font-semibold">${quiz.passScore != null ? quiz.passScore : 5.0} / 10</strong>
                        </span>
                        <span class="text-border-default">•</span>
                        <span class="inline-flex items-center">
                            <i class="fa-solid fa-list-check text-brand-700 mr-1.5" aria-hidden="true"></i>
                            Tổng số: <strong class="ml-1 text-text-primary font-semibold">${questions.size()} câu</strong>
                        </span>
                    </div>
                </div>

                <!-- Đồng hồ đếm ngược thời gian và nút nộp bài nhanh trên Mobile -->
                <div class="flex items-center gap-3 shrink-0 self-stretch md:self-auto justify-between md:justify-end">
                    <c:if test="${not empty quiz.timeLimit && quiz.timeLimit > 0}">
                        <div id="timer-container" class="px-3.5 py-2 sm:px-4 sm:py-2.5 bg-brand-50 border border-brand-100 rounded-xl text-brand-700 font-semibold text-sm sm:text-base flex items-center shadow-xs transition-colors" role="timer" aria-live="polite">
                            <i class="fa-regular fa-clock mr-2 text-brand-600 text-base" aria-hidden="true"></i>
                            <span class="text-xs uppercase font-medium mr-2 text-text-secondary hidden sm:inline">Còn lại:</span>
                            <span id="countdown-timer" class="font-bold font-mono text-base tracking-wider">--:--</span>
                        </div>
                    </c:if>

                    <button type="button" onclick="openSubmitModal()" class="md:hidden px-4 py-2 bg-brand-700 hover:bg-brand-800 text-white font-semibold rounded-xl text-xs transition flex items-center shadow-sm">
                        <i class="fa-solid fa-paper-plane mr-1.5" aria-hidden="true"></i> Nộp bài
                    </button>
                </div>
            </div>
        </header>

        <!-- ================================================================= -->
        <!-- FORM BÀI LÀM QUIZ                                                 -->
        <!-- ================================================================= -->
        <form id="quiz-form" action="${pageContext.request.contextPath}/quiz" method="post" class="pb-8">
            <input type="hidden" name="action" value="submit">
            <input type="hidden" name="quizId" value="${quiz.id}">
            <input type="hidden" name="attemptId" value="${attempt.id}">

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8 items-start">

                <!-- ============================================================= -->
                <!-- PHẦN 2: CỘT TRÁI - DANH SÁCH THẺ CÂU HỎI & CÁC LỰA CHỌN       -->
                <!-- ============================================================= -->
                <div class="lg:col-span-8 space-y-6">
                    <c:forEach var="q" items="${questions}" varStatus="status">
                        <article id="question-card-${status.count}"
                                 data-q-card="${q.id}"
                                 data-q-index="${status.count}"
                                 class="bg-surface-card p-5 sm:p-7 rounded-2xl border border-border-default shadow-xs scroll-mt-36 transition-all duration-200 hover:border-slate-300">
                            
                            <!-- Tiêu đề thẻ câu hỏi & Nút đánh dấu xem lại (Bookmark) -->
                            <div class="flex items-start justify-between gap-3 mb-4 pb-3 border-b border-border-default/70">
                                <div class="flex items-center gap-2.5">
                                    <span id="q-badge-${q.id}" class="w-8 h-8 rounded-xl bg-brand-50 border border-brand-100 text-brand-700 font-bold flex items-center justify-center text-xs shrink-0 transition-colors">
                                        ${status.count}
                                    </span>
                                    <div>
                                        <span class="text-xs font-semibold text-text-primary">Câu hỏi ${status.count}</span>
                                        <span class="text-text-secondary text-xs ml-1">/ ${questions.size()}</span>
                                    </div>

                                    <!-- Huy hiệu phân loại câu hỏi -->
                                    <c:choose>
                                        <c:when test="${q.fillInBlank}">
                                            <span class="px-2 py-0.5 rounded-md text-[11px] font-medium bg-amber-50 text-status-warning border border-amber-200">
                                                Điền câu trả lời
                                            </span>
                                        </c:when>
                                        <c:when test="${q.multipleChoice}">
                                            <span class="px-2 py-0.5 rounded-md text-[11px] font-medium bg-purple-50 text-purple-700 border border-purple-200">
                                                Chọn nhiều đáp án
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="px-2 py-0.5 rounded-md text-[11px] font-medium bg-brand-50 text-brand-700 border border-brand-100">
                                                Chọn một đáp án
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Nút đánh dấu xem lại sau -->
                                <button type="button"
                                        onclick="toggleFlag('${q.id}')"
                                        id="flag-btn-${q.id}"
                                        class="flag-btn inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium text-text-secondary hover:text-amber-700 hover:bg-amber-50 border border-transparent hover:border-amber-200 transition"
                                        title="Đánh dấu câu hỏi này để xem lại sau">
                                    <i class="fa-regular fa-bookmark text-xs" aria-hidden="true"></i>
                                    <span class="hidden sm:inline">Xem lại</span>
                                </button>
                            </div>

                            <!-- Nội dung câu hỏi -->
                            <div class="mb-5">
                                <p class="text-base sm:text-lg font-semibold text-text-primary leading-relaxed">${q.content}</p>
                            </div>

                            <!-- Vùng trả lời của học viên (Tùy theo loại câu hỏi) -->
                            <div class="space-y-3">
                                <c:choose>
                                    <%-- LOẠI 1: ĐIỀN VÀO CHỖ TRỐNG --%>
                                    <c:when test="${q.fillInBlank}">
                                        <div class="space-y-2">
                                            <label class="block text-xs font-bold text-text-secondary uppercase tracking-wider">
                                                <i class="fa-solid fa-pen-to-square mr-1 text-brand-700" aria-hidden="true"></i>Nhập câu trả lời của bạn:
                                            </label>
                                            <div class="relative">
                                                <input type="text"
                                                       name="question_${q.id}_text"
                                                       autocomplete="off"
                                                       placeholder="Nhập từ khóa hoặc câu trả lời vào đây..."
                                                       class="w-full px-4 py-3 rounded-xl bg-surface border border-border-default text-base font-semibold text-text-primary outline-none focus:bg-surface-card focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition shadow-xs">
                                            </div>
                                            <p class="text-xs text-text-secondary flex items-center gap-1.5 pt-1">
                                                <i class="fa-solid fa-circle-info text-brand-700 text-xs" aria-hidden="true"></i>
                                                <span>Hệ thống đối chiếu với từ khóa đáp án chuẩn (không phân biệt chữ hoa, chữ thường).</span>
                                            </p>
                                        </div>
                                    </c:when>

                                    <%-- LOẠI 2: CHỌN NHIỀU ĐÁP ÁN (CHECKBOX) --%>
                                    <c:when test="${q.multipleChoice}">
                                        <c:forEach var="opt" items="${q.options}">
                                            <label class="option-card flex items-start p-3.5 sm:p-4 rounded-xl border border-border-default bg-surface hover:bg-brand-50/40 hover:border-brand-500 cursor-pointer transition-all duration-150 group">
                                                <div class="relative flex items-center justify-center mt-0.5 shrink-0">
                                                    <input type="checkbox" name="question_${q.id}" value="${opt.id}" class="peer sr-only">
                                                    <div class="w-5 h-5 border-2 border-slate-300 rounded-md bg-white peer-checked:bg-brand-700 peer-checked:border-brand-700 transition-colors shadow-xs"></div>
                                                    <i class="fa-solid fa-check text-white text-xs absolute opacity-0 peer-checked:opacity-100 transition-opacity" aria-hidden="true"></i>
                                                </div>
                                                <span class="ml-3 text-sm sm:text-base font-medium text-text-primary group-hover:text-text-primary leading-normal">${opt.optionText}</span>
                                            </label>
                                        </c:forEach>
                                    </c:when>

                                    <%-- LOẠI 3: CHỌN MỘT ĐÁP ÁN DUY NHẤT (RADIO) --%>
                                    <c:otherwise>
                                        <c:forEach var="opt" items="${q.options}">
                                            <label class="option-card flex items-start p-3.5 sm:p-4 rounded-xl border border-border-default bg-surface hover:bg-brand-50/40 hover:border-brand-500 cursor-pointer transition-all duration-150 group">
                                                <div class="relative flex items-center justify-center mt-0.5 shrink-0">
                                                    <input type="radio" name="question_${q.id}" value="${opt.id}" class="peer sr-only">
                                                    <div class="w-5 h-5 border-2 border-slate-300 rounded-full bg-white peer-checked:border-brand-700 transition-colors shadow-xs"></div>
                                                    <div class="w-2.5 h-2.5 bg-brand-700 rounded-full absolute opacity-0 peer-checked:opacity-100 transition-opacity"></div>
                                                </div>
                                                <span class="ml-3 text-sm sm:text-base font-medium text-text-primary group-hover:text-text-primary leading-normal">${opt.optionText}</span>
                                            </label>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                        </article>
                    </c:forEach>
                </div>

                <!-- ============================================================= -->
                <!-- PHẦN 3: CỘT PHẢI - MA TRẬN BẢNG CÂU HỎI & TIẾN ĐỘ LÀM BÀI    -->
                <!-- ============================================================= -->
                <aside class="lg:col-span-4 space-y-5 lg:sticky lg:top-36 z-20">
                    <div class="bg-surface-card p-5 sm:p-6 rounded-2xl border border-border-default shadow-xs">
                        <!-- Tiêu đề cột điều hướng -->
                        <div class="flex items-center justify-between mb-4 pb-3 border-b border-border-default">
                            <h2 class="text-sm font-bold text-text-primary flex items-center tracking-tight">
                                <i class="fa-solid fa-list-check text-brand-700 mr-2" aria-hidden="true"></i> Bảng câu hỏi
                            </h2>
                            <span class="text-xs font-semibold px-2.5 py-1 bg-brand-50 text-brand-700 border border-brand-100 rounded-full">
                                ${questions.size()} câu
                            </span>
                        </div>

                        <!-- Thanh hiển thị tiến độ làm bài -->
                        <div class="mb-5">
                            <div class="flex justify-between items-center text-xs text-text-secondary font-medium mb-1.5">
                                <span>Tiến độ hoàn thành</span>
                                <span id="sidebar-progress-text" class="font-bold text-brand-700">0 / ${questions.size()} câu</span>
                            </div>
                            <div class="w-full bg-slate-100 rounded-full h-2.5 overflow-hidden">
                                <div id="sidebar-progress-bar" class="bg-brand-600 h-2.5 rounded-full transition-all duration-300" style="width: 0%"></div>
                            </div>
                        </div>

                        <!-- Lưới nút số câu hỏi (Nhấn để cuộn nhanh đến câu tương ứng) -->
                        <div class="grid grid-cols-5 gap-2 max-h-[45vh] overflow-y-auto p-1 custom-scrollbar">
                            <c:forEach var="q" items="${questions}" varStatus="status">
                                <button type="button"
                                        id="nav-btn-${q.id}"
                                        data-q-nav="${q.id}"
                                        onclick="scrollToQuestion(${status.count})"
                                        class="q-nav-btn relative w-full aspect-square flex items-center justify-center font-bold text-xs rounded-xl border transition-all duration-150 bg-slate-100 text-slate-700 border-slate-200 hover:bg-slate-200 hover:border-slate-300 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700"
                                        title="Chuyển đến câu ${status.count}">
                                    ${status.count}
                                    <span id="nav-flag-${q.id}" class="hidden absolute -top-1 -right-1 w-3 h-3 bg-amber-500 rounded-full border-2 border-white"></span>
                                </button>
                            </c:forEach>
                        </div>

                        <!-- Chú thích màu sắc trạng thái câu hỏi -->
                        <div class="mt-5 pt-4 border-t border-border-default grid grid-cols-3 gap-2 text-center text-[11px] text-text-secondary font-medium">
                            <div class="flex items-center justify-center gap-1.5">
                                <span class="w-3 h-3 rounded-md bg-brand-600 inline-block shadow-xs"></span>
                                <span>Đã làm</span>
                            </div>
                            <div class="flex items-center justify-center gap-1.5">
                                <span class="w-3 h-3 rounded-md bg-slate-100 border border-slate-300 inline-block"></span>
                                <span>Chưa làm</span>
                            </div>
                            <div class="flex items-center justify-center gap-1.5">
                                <span class="w-3 h-3 rounded-md bg-amber-50 border border-amber-400 inline-block relative"><span class="w-1.5 h-1.5 bg-amber-500 rounded-full absolute top-0.5 right-0.5"></span></span>
                                <span>Xem lại</span>
                            </div>
                        </div>

                        <!-- Nút nộp bài thi ở cột phải -->
                        <div class="mt-5 pt-4 border-t border-border-default">
                            <button type="button" onclick="openSubmitModal()" class="w-full py-3 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-xl shadow-sm transition flex items-center justify-center text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                <i class="fa-solid fa-paper-plane mr-2" aria-hidden="true"></i> Nộp Bài Thi
                            </button>
                        </div>
                    </div>
                </aside>
            </div>
        </form>
    </div>
</main>

<!-- ========================================================================= -->
<!-- PHẦN 5: MODAL XÁC NHẬN NỘP BÀI THI KÈM THỐNG KÊ CHI TIẾT                  -->
<!-- ========================================================================= -->
<div id="submit-confirm-modal" class="fixed inset-0 z-50 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-surface-card rounded-2xl border border-border-default shadow-xl max-w-md w-full p-6 text-center transform transition-all">
        <div class="w-14 h-14 rounded-full bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center text-2xl mx-auto mb-4 shadow-xs">
            <i class="fa-solid fa-paper-plane" aria-hidden="true"></i>
        </div>
        
        <h3 class="text-xl font-bold text-text-primary mb-2">Xác nhận nộp bài thi?</h3>
        <p class="text-xs sm:text-sm text-text-secondary mb-5">
            Khi nộp bài, hệ thống sẽ tự động chấm điểm và bạn không thể chỉnh sửa đáp án đã chọn.
        </p>

        <!-- Thống kê trạng thái làm bài trước khi nộp -->
        <div class="bg-surface rounded-xl p-4 border border-border-default mb-5 grid grid-cols-3 gap-2 text-center">
            <div>
                <p class="text-[11px] text-text-secondary font-medium">Đã trả lời</p>
                <p id="modal-answered-count" class="text-lg font-bold text-brand-700">0</p>
            </div>
            <div>
                <p class="text-[11px] text-text-secondary font-medium">Chưa làm</p>
                <p id="modal-unanswered-count" class="text-lg font-bold text-status-danger">0</p>
            </div>
            <div>
                <p class="text-[11px] text-text-secondary font-medium">Đánh dấu</p>
                <p id="modal-flagged-count" class="text-lg font-bold text-status-warning">0</p>
            </div>
        </div>

        <!-- Cảnh báo nếu vẫn còn câu chưa hoàn thành -->
        <div id="modal-unanswered-alert" class="hidden mb-5 p-3 rounded-xl bg-amber-50 border border-amber-200 text-status-warning text-xs text-left flex items-start gap-2">
            <i class="fa-solid fa-triangle-exclamation text-amber-600 mt-0.5" aria-hidden="true"></i>
            <span>Bạn vẫn còn câu hỏi chưa hoàn thành. Bạn có chắc chắn muốn nộp bài ngay bây giờ?</span>
        </div>

        <!-- Các nút hành động trong Modal -->
        <div class="flex items-center gap-3">
            <button type="button" onclick="closeSubmitModal()" class="flex-1 py-2.5 px-4 rounded-xl border border-border-default font-semibold text-text-secondary hover:bg-slate-100 transition text-sm">
                Xem lại bài
            </button>
            <button type="button" id="modal-confirm-submit-btn" onclick="confirmAndSubmitQuiz()" class="flex-1 py-2.5 px-4 rounded-xl bg-brand-700 hover:bg-brand-800 text-white font-bold transition text-sm shadow-sm">
                Nộp bài ngay
            </button>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- PHẦN 6: JAVASCRIPT ĐIỀU KHIỂN: CUỘN CÂU HỎI, ĐẾM NGƯỢC, TIẾN ĐỘ, NỘP BÀI -->
<!-- ========================================================================= -->
<script>
    var flaggedQuestions = new Set();

    // Cuộn mượt màn hình đến câu hỏi tương ứng và hiệu ứng viền sáng nổi bật
    function scrollToQuestion(index) {
        var card = document.getElementById("question-card-" + index);
        if (card) {
            card.scrollIntoView({ behavior: "smooth", block: "start" });
            card.classList.add("ring-2", "ring-brand-500");
            setTimeout(function() {
                card.classList.remove("ring-2", "ring-brand-500");
            }, 1200);
        }
    }

    // Đánh dấu hoặc bỏ đánh dấu câu hỏi cần xem lại
    function toggleFlag(qId) {
        var flagBtn = document.getElementById("flag-btn-" + qId);
        var navFlag = document.getElementById("nav-flag-" + qId);
        var navBtn = document.getElementById("nav-btn-" + qId);

        if (flaggedQuestions.has(qId)) {
            flaggedQuestions.delete(qId);
            if (flagBtn) {
                flagBtn.className = "flag-btn inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium text-text-secondary hover:text-amber-700 hover:bg-amber-50 border border-transparent hover:border-amber-200 transition";
                flagBtn.innerHTML = '<i class="fa-regular fa-bookmark text-xs" aria-hidden="true"></i> <span class="hidden sm:inline">Xem lại</span>';
            }
            if (navFlag) navFlag.classList.add("hidden");
            if (navBtn) navBtn.classList.remove("ring-2", "ring-amber-400", "border-amber-400");
        } else {
            flaggedQuestions.add(qId);
            if (flagBtn) {
                flagBtn.className = "flag-btn inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium text-amber-800 bg-amber-50 border border-amber-300 transition";
                flagBtn.innerHTML = '<i class="fa-solid fa-bookmark text-amber-600 text-xs" aria-hidden="true"></i> <span class="hidden sm:inline">Đã đánh dấu</span>';
            }
            if (navFlag) navFlag.classList.remove("hidden");
            if (navBtn) navBtn.classList.add("ring-2", "ring-amber-400", "border-amber-400");
        }
    }

    // Mở hộp thoại Modal xác nhận nộp bài và tính toán thống kê
    function openSubmitModal() {
        var total = ${empty questions ? 0 : questions.size()};
        var answered = 0;
        var navButtons = document.querySelectorAll(".q-nav-btn");

        navButtons.forEach(function(btn) {
            var qId = btn.getAttribute("data-q-nav");
            var inputs = document.querySelectorAll("input[name='question_" + qId + "']");
            var textInput = document.querySelector("input[name='question_" + qId + "_text']");
            var isAnswered = false;

            if (textInput && textInput.value.trim().length > 0) {
                isAnswered = true;
            }
            inputs.forEach(function(inp) {
                if ((inp.type === 'radio' || inp.type === 'checkbox') && inp.checked) {
                    isAnswered = true;
                }
            });
            if (isAnswered) answered++;
        });

        var unanswered = total - answered;
        var modalAnswered = document.getElementById("modal-answered-count");
        var modalUnanswered = document.getElementById("modal-unanswered-count");
        var modalFlagged = document.getElementById("modal-flagged-count");
        var modalAlert = document.getElementById("modal-unanswered-alert");

        if (modalAnswered) modalAnswered.textContent = answered;
        if (modalUnanswered) modalUnanswered.textContent = unanswered;
        if (modalFlagged) modalFlagged.textContent = flaggedQuestions.size;

        if (modalAlert) {
            if (unanswered > 0) {
                modalAlert.classList.remove("hidden");
            } else {
                modalAlert.classList.add("hidden");
            }
        }

        var modal = document.getElementById("submit-confirm-modal");
        if (modal) modal.classList.remove("hidden");
    }

    // Đóng hộp thoại Modal
    function closeSubmitModal() {
        var modal = document.getElementById("submit-confirm-modal");
        if (modal) modal.classList.add("hidden");
    }

    // Thực hiện nộp bài thi
    function confirmAndSubmitQuiz() {
        var quizForm = document.getElementById("quiz-form");
        if (quizForm) {
            var submitBtns = document.querySelectorAll("button[type='button'], button[type='submit']");
            submitBtns.forEach(function(b) { b.disabled = true; });
            var confirmBtn = document.getElementById("modal-confirm-submit-btn");
            if (confirmBtn) {
                confirmBtn.innerHTML = "<i class='fa-solid fa-spinner fa-spin mr-2'></i> Đang nộp bài...";
            }
            quizForm.submit();
        }
    }

    // Khởi tạo các sự kiện khi trang đã tải xong
    document.addEventListener("DOMContentLoaded", function() {
        var quizForm = document.getElementById("quiz-form");
        var totalQuestions = ${empty questions ? 0 : questions.size()};

        // Hàm cập nhật tiến độ làm bài khi học viên chọn hoặc nhập đáp án
        function updateProgress() {
            var answeredCount = 0;
            var navButtons = document.querySelectorAll(".q-nav-btn");

            navButtons.forEach(function(btn) {
                var qId = btn.getAttribute("data-q-nav");
                var inputs = document.querySelectorAll("input[name='question_" + qId + "']");
                var textInput = document.querySelector("input[name='question_" + qId + "_text']");
                var isAnswered = false;

                if (textInput && textInput.value.trim().length > 0) {
                    isAnswered = true;
                }

                inputs.forEach(function(input) {
                    if (input.type === 'radio' || input.type === 'checkbox') {
                        if (input.checked) isAnswered = true;
                    } else if (input.value.trim().length > 0) {
                        isAnswered = true;
                    }
                });

                var qBadge = document.getElementById("q-badge-" + qId);

                if (isAnswered) {
                    answeredCount++;
                    btn.classList.add("bg-brand-600", "text-white", "border-brand-600", "shadow-xs");
                    btn.classList.remove("bg-slate-100", "text-slate-700", "border-slate-200");
                    if (qBadge) {
                        qBadge.className = "w-8 h-8 rounded-xl bg-brand-600 text-white font-bold flex items-center justify-center text-xs shrink-0 transition-colors shadow-xs";
                    }
                } else {
                    btn.classList.remove("bg-brand-600", "text-white", "border-brand-600", "shadow-xs");
                    btn.classList.add("bg-slate-100", "text-slate-700", "border-slate-200");
                    if (qBadge) {
                        qBadge.className = "w-8 h-8 rounded-xl bg-brand-50 border border-brand-100 text-brand-700 font-bold flex items-center justify-center text-xs shrink-0 transition-colors";
                    }
                }
            });

            var progressPercent = totalQuestions > 0 ? Math.round((answeredCount / totalQuestions) * 100) : 0;
            var sidebarProgressText = document.getElementById("sidebar-progress-text");
            var sidebarProgressBar = document.getElementById("sidebar-progress-bar");

            if (sidebarProgressText) sidebarProgressText.textContent = answeredCount + " / " + totalQuestions + " câu (" + progressPercent + "%)";
            if (sidebarProgressBar) sidebarProgressBar.style.width = progressPercent + "%";
        }

        if (quizForm) {
            quizForm.addEventListener("change", updateProgress);
            quizForm.addEventListener("input", updateProgress);
            updateProgress();
        }

        // Xử lý bộ đếm ngược thời gian làm bài (Countdown Timer)
        var timeLimitMinutes = parseInt("${quiz.timeLimit}");
        if (!isNaN(timeLimitMinutes) && timeLimitMinutes > 0) {
            var now = new Date().getTime();
            var endTime = now + (timeLimitMinutes * 60 * 1000);
            
            var timerDisplay = document.getElementById("countdown-timer");
            var timerContainer = document.getElementById("timer-container");

            var updateTimer = setInterval(function() {
                var currentTime = new Date().getTime();
                var distance = endTime - currentTime;

                // Tự động nộp bài khi hết giờ
                if (distance <= 0) {
                    clearInterval(updateTimer);
                    if (timerDisplay) timerDisplay.textContent = "00:00";
                    if (timerContainer) {
                        timerContainer.className = "px-3.5 py-2 sm:px-4 sm:py-2.5 bg-rose-50 border border-rose-200 rounded-xl text-status-danger font-semibold text-sm sm:text-base flex items-center shrink-0 animate-pulse";
                    }
                    if (quizForm) {
                        var submitBtns = quizForm.querySelectorAll("button");
                        submitBtns.forEach(function(btn) {
                            btn.disabled = true;
                        });
                        quizForm.submit();
                    }
                    return;
                }

                var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);

                var minsStr = minutes < 10 ? "0" + minutes : minutes;
                var secsStr = seconds < 10 ? "0" + seconds : seconds;

                if (timerDisplay) timerDisplay.textContent = minsStr + ":" + secsStr;
                
                // Đổi màu cảnh báo đỏ khi còn dưới 30 giây, màu vàng khi còn dưới 60 giây
                if (minutes === 0 && seconds <= 30 && timerContainer) {
                    timerContainer.className = "px-3.5 py-2 sm:px-4 sm:py-2.5 bg-rose-50 border border-rose-200 rounded-xl text-status-danger font-semibold text-sm sm:text-base flex items-center shrink-0 animate-pulse";
                } else if (minutes === 0 && seconds <= 60 && timerContainer) {
                    timerContainer.className = "px-3.5 py-2 sm:px-4 sm:py-2.5 bg-amber-50 border border-amber-200 rounded-xl text-status-warning font-semibold text-sm sm:text-base flex items-center shrink-0 animate-pulse";
                }
            }, 1000);
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
