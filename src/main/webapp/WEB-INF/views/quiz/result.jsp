<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<%-- 
=============================================================================
MÀN HÌNH KẾT QUẢ BÀI THI & ĐỐI CHIẾU ĐÁP ÁN (QUIZ RESULT)
Dành cho Học viên (Student / Learner):
- Thanh điều hướng & thời gian hoàn thành bài nộp.
- Thẻ Hero Kết quả:
  + Trạng thái ĐẠT (Passed) / CHƯA ĐẠT (Failed) với hiệu ứng thị giác tương ứng.
  + Thẻ so sánh điểm số thực tế vs Điểm chuẩn đạt yêu cầu (Thang điểm 10).
  + Các nút hành động chính: Làm lại, Xem lịch sử thi, Về nội dung khóa học.
- Lưới 4 Thẻ chỉ số hiệu suất: Số câu đúng, Số câu sai, Tỷ lệ chính xác (%), Kết luận.
- Khu vực xem lại câu hỏi: Đối chiếu toàn bộ câu hỏi và đáp án đúng chuẩn của hệ thống.
=============================================================================
--%>

<main class="flex-grow bg-surface py-8 md:py-12">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 w-full space-y-8">

        <!-- ================================================================= -->
        <!-- PHẦN 1: ĐIỀU HƯỚNG ĐẦU TRANG & THỜI ĐIỂM HOÀN THÀNH               -->
        <!-- ================================================================= -->
        <div class="flex items-center justify-between">
            <a href="${pageContext.request.contextPath}/quiz?quizId=${quiz.id}" class="inline-flex items-center gap-2 text-xs sm:text-sm font-semibold text-text-secondary hover:text-brand-700 transition">
                <i class="fa-solid fa-arrow-left text-xs" aria-hidden="true"></i>
                <span>Quay lại trang tổng quan quiz</span>
            </a>
            <span class="text-xs text-text-secondary">
                <i class="fa-regular fa-clock mr-1" aria-hidden="true"></i>
                <c:choose>
                    <c:when test="${not empty result.submittedAt}">
                        <fmt:formatDate value="${result.submittedAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </c:when>
                    <c:otherwise>Vừa hoàn thành</c:otherwise>
                </c:choose>
            </span>
        </div>

        <!-- ================================================================= -->
        <!-- PHẦN 2: THẺ HERO KẾT QUẢ TỔNG QUAN (ĐẠT / CHƯA ĐẠT) & ĐIỂM SỐ     -->
        <!-- ================================================================= -->
        <div class="bg-surface-card p-6 sm:p-10 rounded-3xl border border-border-default shadow-sm text-center relative overflow-hidden">
            <!-- Hiệu ứng quầng sáng nền (Màu xanh khi Đạt, Màu đỏ khi Chưa đạt) -->
            <c:choose>
                <c:when test="${result.passed}">
                    <div class="absolute -top-24 left-1/2 -translate-x-1/2 w-96 h-96 bg-brand-100/50 rounded-full blur-3xl pointer-events-none -z-0"></div>
                </c:when>
                <c:otherwise>
                    <div class="absolute -top-24 left-1/2 -translate-x-1/2 w-96 h-96 bg-rose-100/40 rounded-full blur-3xl pointer-events-none -z-0"></div>
                </c:otherwise>
            </c:choose>

            <div class="relative z-10">
                <!-- Biểu tượng và Thông điệp kết quả -->
                <c:choose>
                    <%-- TRƯỜNG HỢP: ĐẠT YÊU CẦU (PASSED) --%>
                    <c:when test="${result.passed}">
                        <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-full mx-auto mb-5 bg-brand-50 border-2 border-brand-100 text-status-success flex items-center justify-center text-4xl sm:text-5xl shadow-sm">
                            <i class="fa-solid fa-award" aria-hidden="true"></i>
                        </div>
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-brand-50 text-status-success border border-brand-100 uppercase tracking-wider mb-2">
                            <i class="fa-solid fa-circle-check text-xs" aria-hidden="true"></i> Đạt Yêu Cầu (Passed)
                        </span>
                        <h1 class="text-2xl sm:text-4xl font-extrabold text-text-primary tracking-tight mb-2">
                            Chúc Mừng! Bạn Đã Hoàn Thành
                        </h1>
                        <p class="text-text-secondary text-sm sm:text-base max-w-lg mx-auto mb-6">
                            Bạn đã xuất sắc vượt qua bài thi <strong class="text-text-primary font-semibold">${quiz.title}</strong> với kết quả đạt chuẩn.
                        </p>
                    </c:when>

                    <%-- TRƯỜNG HỢP: CHƯA ĐẠT (FAILED) --%>
                    <c:otherwise>
                        <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-full mx-auto mb-5 bg-rose-50 border-2 border-rose-200 text-status-danger flex items-center justify-center text-4xl sm:text-5xl shadow-sm">
                            <i class="fa-solid fa-circle-exclamation" aria-hidden="true"></i>
                        </div>
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-rose-50 text-status-danger border border-rose-200 uppercase tracking-wider mb-2">
                            <i class="fa-solid fa-circle-xmark text-xs" aria-hidden="true"></i> Chưa Đạt (Failed)
                        </span>
                        <h1 class="text-2xl sm:text-4xl font-extrabold text-text-primary tracking-tight mb-2">
                            Chưa Đạt Yêu Cầu Lần Này
                        </h1>
                        <p class="text-text-secondary text-sm sm:text-base max-w-lg mx-auto mb-6">
                            Bài thi <strong class="text-text-primary font-semibold">${quiz.title}</strong> yêu cầu điểm tối thiểu là <strong class="text-text-primary font-semibold">${quiz.passScore != null ? quiz.passScore : 5.0}</strong>. Hãy ôn tập lại kiến thức và thử sức ở lần tới nhé!
                        </p>
                    </c:otherwise>
                </c:choose>

                <!-- Thẻ so sánh Điểm của bạn vs Điểm chuẩn đạt -->
                <div class="max-w-md mx-auto bg-surface rounded-2xl p-5 sm:p-6 border border-border-default shadow-xs mb-8">
                    <div class="flex items-center justify-around divide-x divide-border-default">
                        <div class="px-3 text-center flex-1">
                            <p class="text-xs uppercase tracking-wider text-text-secondary font-semibold mb-1">Điểm của bạn</p>
                            <p class="text-4xl sm:text-5xl font-black ${result.passed ? 'text-status-success' : 'text-status-danger'} tracking-tight">
                                <fmt:formatNumber value="${result.score}" maxFractionDigits="1"/>
                            </p>
                            <p class="text-[11px] text-text-secondary mt-1 font-medium">Thang điểm 10</p>
                        </div>
                        <div class="px-3 text-center flex-1">
                            <p class="text-xs uppercase tracking-wider text-text-secondary font-semibold mb-1">Điểm chuẩn đạt</p>
                            <p class="text-4xl sm:text-5xl font-black text-text-primary tracking-tight">
                                <fmt:formatNumber value="${quiz.passScore != null ? quiz.passScore : 5.0}" maxFractionDigits="1"/>
                            </p>
                            <p class="text-[11px] text-text-secondary mt-1 font-medium">Thang điểm 10</p>
                        </div>
                    </div>
                </div>

                <!-- Các nút hành động chính -->
                <div class="flex flex-col sm:flex-row items-center justify-center gap-3 max-w-xl mx-auto">
                    <!-- Nút về nội dung khóa học -->
                    <c:if test="${not empty resultCourseId}">
                        <a href="${pageContext.request.contextPath}/learn/course?id=${resultCourseId}"
                           class="w-full sm:w-auto px-5 py-3 bg-brand-50 hover:bg-brand-100 text-brand-700 font-semibold border border-brand-200 rounded-xl text-sm transition flex items-center justify-center gap-1.5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                            <i class="fa-solid fa-graduation-cap text-xs" aria-hidden="true"></i> Về nội dung khóa học
                        </a>
                    </c:if>

                    <!-- Nút Làm lại bài thi -->
                    <a href="${pageContext.request.contextPath}/quiz?quizId=${quiz.id}" class="w-full sm:w-auto px-6 py-3 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-xl text-sm transition shadow-sm flex items-center justify-center gap-2">
                        <i class="fa-solid fa-rotate-right" aria-hidden="true"></i> Làm Lại Bài Thi
                    </a>

                    <!-- Nút Xem lịch sử thi -->
                    <a href="${pageContext.request.contextPath}/quiz/history?quizId=${quiz.id}" class="w-full sm:w-auto px-6 py-3 bg-surface hover:bg-slate-100 text-text-primary font-semibold border border-border-default rounded-xl text-sm transition flex items-center justify-center gap-2">
                        <i class="fa-solid fa-clock-rotate-left text-brand-700" aria-hidden="true"></i> Xem Lịch Sử Thi
                    </a>

                    <!-- Nút Danh sách khóa học -->
                    <a href="${pageContext.request.contextPath}/courses" class="w-full sm:w-auto px-5 py-3 text-text-secondary hover:text-text-primary font-medium text-sm transition flex items-center justify-center gap-1.5">
                        <i class="fa-solid fa-house text-xs" aria-hidden="true"></i> Khóa học
                    </a>
                </div>
            </div>
        </div>

        <!-- ================================================================= -->
        <!-- PHẦN 3: LƯỚI 4 THẺ CHỈ SỐ CHI TIẾT (METRICS GRID)                 -->
        <!-- ================================================================= -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-5">
            <!-- Chỉ số 1: Số câu đúng -->
            <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex flex-col justify-between">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-text-secondary">Số câu đúng</span>
                    <span class="w-7 h-7 rounded-lg bg-emerald-50 text-status-success flex items-center justify-center text-xs">
                        <i class="fa-solid fa-check" aria-hidden="true"></i>
                    </span>
                </div>
                <div>
                    <p class="text-2xl font-bold text-text-primary">
                        ${result.correctAnswers != null ? result.correctAnswers : 0}
                        <span class="text-sm font-normal text-text-secondary">/ ${result.totalQuestions} câu</span>
                    </p>
                </div>
            </div>

            <!-- Chỉ số 2: Số câu sai / bỏ qua -->
            <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex flex-col justify-between">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-text-secondary">Số câu sai</span>
                    <span class="w-7 h-7 rounded-lg bg-rose-50 text-status-danger flex items-center justify-center text-xs">
                        <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                    </span>
                </div>
                <div>
                    <p class="text-2xl font-bold text-text-primary">
                        <c:choose>
                            <c:when test="${result.correctAnswers != null}">
                                ${result.totalQuestions - result.correctAnswers}
                            </c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                        <span class="text-sm font-normal text-text-secondary">/ ${result.totalQuestions} câu</span>
                    </p>
                </div>
            </div>

            <!-- Chỉ số 3: Tỷ lệ chính xác (%) -->
            <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex flex-col justify-between">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-text-secondary">Độ chính xác</span>
                    <span class="w-7 h-7 rounded-lg bg-brand-50 text-brand-700 flex items-center justify-center text-xs">
                        <i class="fa-solid fa-percent" aria-hidden="true"></i>
                    </span>
                </div>
                <div>
                    <p class="text-2xl font-bold text-text-primary">
                        <c:choose>
                            <c:when test="${result.totalQuestions > 0 && result.correctAnswers != null}">
                                <fmt:formatNumber value="${(result.correctAnswers / result.totalQuestions) * 100}" maxFractionDigits="0"/>%
                            </c:when>
                            <c:otherwise>
                                <fmt:formatNumber value="${(result.score / 10.0) * 100}" maxFractionDigits="0"/>%
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>

            <!-- Chỉ số 4: Kết luận cuối cùng -->
            <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex flex-col justify-between">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-text-secondary">Kết quả</span>
                    <span class="w-7 h-7 rounded-lg ${result.passed ? 'bg-brand-50 text-brand-700' : 'bg-rose-50 text-rose-700'} flex items-center justify-center text-xs">
                        <i class="fa-solid ${result.passed ? 'fa-flag-checkered' : 'fa-rotate-right'}" aria-hidden="true"></i>
                    </span>
                </div>
                <div>
                    <p class="text-xl font-bold ${result.passed ? 'text-status-success' : 'text-status-danger'}">
                        ${result.passed ? 'ĐẠT' : 'CHƯA ĐẠT'}
                    </p>
                </div>
            </div>
        </div>

        <!-- ================================================================= -->
        <!-- PHẦN 4: KHU VỰC ĐỐI CHIẾU CÂU HỎI & ĐÁP ÁN ĐÚNG CỦA HỆ THỐNG      -->
        <!-- ================================================================= -->
        <c:if test="${not empty questions}">
            <div class="bg-surface-card p-6 sm:p-8 rounded-3xl border border-border-default shadow-sm">
                <!-- Tiêu đề khu vực xem lại -->
                <div class="flex items-center justify-between mb-6 pb-4 border-b border-border-default">
                    <div>
                        <h2 class="text-lg sm:text-xl font-bold text-text-primary flex items-center gap-2">
                            <i class="fa-solid fa-clipboard-question text-brand-700" aria-hidden="true"></i>
                            <span>Xem Lại Danh Sách Câu Hỏi &amp; Đáp Án Chuẩn</span>
                        </h2>
                        <p class="text-xs text-text-secondary mt-1">
                            Đối chiếu câu trả lời của bạn với đáp án chính xác của đề thi
                        </p>
                    </div>
                    <span class="text-xs font-semibold px-3 py-1 bg-surface border border-border-default rounded-full text-text-secondary">
                        ${questions.size()} câu hỏi
                    </span>
                </div>

                <!-- Danh sách các câu hỏi -->
                <div class="space-y-6">
                    <c:forEach var="q" items="${questions}" varStatus="status">
                        <div class="p-5 rounded-2xl border border-border-default bg-surface/60">
                            <!-- Tiêu đề câu hỏi & Badge phân loại -->
                            <div class="flex items-start gap-3 mb-3">
                                <span class="w-7 h-7 rounded-lg bg-surface-card border border-border-default text-text-primary font-bold flex items-center justify-center text-xs shrink-0 shadow-xs">
                                    ${status.count}
                                </span>
                                <div class="flex-1">
                                    <div class="flex items-center gap-2 mb-1">
                                        <c:choose>
                                            <c:when test="${q.fillInBlank}">
                                                <span class="text-[10px] font-semibold uppercase px-2 py-0.5 rounded bg-amber-50 text-status-warning border border-amber-200">Điền từ</span>
                                            </c:when>
                                            <c:when test="${q.multipleChoice}">
                                                <span class="text-[10px] font-semibold uppercase px-2 py-0.5 rounded bg-purple-50 text-purple-700 border border-purple-200">Chọn nhiều</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-[10px] font-semibold uppercase px-2 py-0.5 rounded bg-brand-50 text-brand-700 border border-brand-100">Trắc nghiệm</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <h3 class="text-sm sm:text-base font-semibold text-text-primary leading-relaxed">${q.content}</h3>
                                </div>
                            </div>

                            <!-- Phương án đáp án: Đánh dấu nổi bật đáp án chính xác -->
                            <div class="pl-0 sm:pl-10 space-y-2 pt-2">
                                <c:choose>
                                    <%-- LOẠI ĐIỀN CHỖ TRỐNG: Hiển thị các từ khóa được chấp nhận --%>
                                    <c:when test="${q.fillInBlank}">
                                        <div class="p-3.5 rounded-xl border border-emerald-200 bg-emerald-50/70 text-xs sm:text-sm">
                                            <div class="flex items-center gap-2 font-bold text-status-success mb-1">
                                                <i class="fa-solid fa-circle-check text-xs" aria-hidden="true"></i>
                                                <span>Từ khóa đáp án chuẩn:</span>
                                            </div>
                                            <div class="flex flex-wrap gap-1.5 mt-1">
                                                <c:forEach var="opt" items="${q.options}">
                                                    <span class="px-2.5 py-1 rounded-lg bg-white border border-emerald-300 font-semibold text-text-primary shadow-xs">
                                                        ${opt.optionText}
                                                    </span>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:when>

                                    <%-- LOẠI TRẮC NGHIỆM: Đánh dấu phương án đúng bằng viền xanh và huy hiệu "Đáp án đúng" --%>
                                    <c:otherwise>
                                        <c:forEach var="opt" items="${q.options}">
                                            <div class="flex items-start gap-3 p-3 rounded-xl border text-xs sm:text-sm font-medium transition ${opt.correct ? 'border-emerald-300 bg-emerald-50/80 text-emerald-900 font-semibold' : 'border-border-default bg-surface-card text-text-secondary'}">
                                                <div class="mt-0.5 shrink-0">
                                                    <c:choose>
                                                        <c:when test="${opt.correct}">
                                                            <span class="w-4 h-4 rounded-full bg-status-success text-white flex items-center justify-center text-[10px]">
                                                                <i class="fa-solid fa-check" aria-hidden="true"></i>
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="w-4 h-4 rounded-full border border-slate-300 inline-block bg-white"></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="flex-1 flex items-center justify-between gap-2">
                                                    <span>${opt.optionText}</span>
                                                    <c:if test="${opt.correct}">
                                                        <span class="text-[10px] uppercase font-bold text-status-success px-2 py-0.5 rounded bg-emerald-100 border border-emerald-200 shrink-0">
                                                            Đáp án đúng
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
