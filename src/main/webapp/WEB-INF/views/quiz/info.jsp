<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow bg-surface py-8 md:py-12">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <!-- Breadcrumb & Back navigation -->
        <nav aria-label="Breadcrumb" class="mb-6 flex flex-wrap items-center gap-2 text-sm text-text-secondary">
            <c:choose>
                <c:when test="${not empty courseId}">
                    <a href="${pageContext.request.contextPath}/learn/lesson?courseId=${courseId}" class="font-semibold text-brand-700 hover:text-brand-800 transition-colors">
                        <i class="fa-solid fa-arrow-left mr-1"></i> Quay lại khóa học
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/courses" class="font-semibold text-brand-700 hover:text-brand-800 transition-colors">
                        <i class="fa-solid fa-arrow-left mr-1"></i> Danh sách khóa học
                    </a>
                </c:otherwise>
            </c:choose>
            <span aria-hidden="true">•</span>
            <span class="break-words">Giới thiệu bài thi</span>
        </nav>

        <!-- Quiz Hero Info Card -->
        <div class="bg-surface-card rounded-2xl border border-border-default shadow-sm p-6 sm:p-8 mb-8">
            <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 pb-6 border-b border-border-default">
                <div>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-brand-50 text-brand-700 border border-brand-100 mb-3">
                        <i class="fa-solid fa-book-bookmark mr-1.5"></i> Module: ${not empty quiz.moduleTitle ? quiz.moduleTitle : 'Bài kiểm tra'}
                    </span>
                    <h1 class="text-2xl sm:text-3xl font-bold text-text-primary tracking-tight">${quiz.title}</h1>
                </div>
            </div>

            <!-- Quiz Metrics Grid -->
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-6">
                <!-- Metric 1: Questions Count -->
                <div class="bg-surface p-4 rounded-xl border border-border-default flex items-center gap-4">
                    <div class="w-12 h-12 rounded-lg bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center text-xl shrink-0">
                        <i class="fa-solid fa-list-check"></i>
                    </div>
                    <div>
                        <p class="text-xs font-semibold text-text-secondary uppercase tracking-wider">Số câu hỏi</p>
                        <p class="text-xl font-bold text-text-primary mt-0.5">${questionCount} câu</p>
                    </div>
                </div>

                <!-- Metric 2: Time Limit -->
                <div class="bg-surface p-4 rounded-xl border border-border-default flex items-center gap-4">
                    <div class="w-12 h-12 rounded-lg bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center text-xl shrink-0">
                        <i class="fa-regular fa-clock"></i>
                    </div>
                    <div>
                        <p class="text-xs font-semibold text-text-secondary uppercase tracking-wider">Thời gian</p>
                        <p class="text-xl font-bold text-text-primary mt-0.5">
                            <c:choose>
                                <c:when test="${not empty quiz.timeLimit && quiz.timeLimit > 0}">
                                    ${quiz.timeLimit} phút
                                </c:when>
                                <c:otherwise>
                                    Không giới hạn
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>

                <!-- Metric 3: Passing Score -->
                <div class="bg-surface p-4 rounded-xl border border-border-default flex items-center gap-4">
                    <div class="w-12 h-12 rounded-lg bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center text-xl shrink-0">
                        <i class="fa-solid fa-bullseye"></i>
                    </div>
                    <div>
                        <p class="text-xs font-semibold text-text-secondary uppercase tracking-wider">Điểm cần đạt</p>
                        <p class="text-xl font-bold text-text-primary mt-0.5">
                            <fmt:formatNumber value="${quiz.passScore}" maxFractionDigits="1"/> / 10
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Highest Score & Performance Section -->
        <c:choose>
            <c:when test="${hasAttempted}">
                <div class="bg-surface-card rounded-2xl border border-border-default p-6 sm:p-8 mb-8 shadow-sm">
                    <h3 class="text-lg font-bold text-text-primary mb-4 flex items-center">
                        <i class="fa-solid fa-trophy text-amber-500 mr-2"></i> Kết Quả Cao Nhất Của Bạn
                    </h3>

                    <div class="bg-surface rounded-xl p-6 border border-border-default flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                        <div class="flex items-center gap-5">
                            <div class="w-16 h-16 rounded-2xl ${passed ? 'bg-brand-50 text-status-success border border-brand-100' : 'bg-rose-50 text-status-danger border border-rose-200'} flex items-center justify-center text-3xl shrink-0">
                                <i class="fa-solid ${passed ? 'fa-award' : 'fa-chart-line'}"></i>
                            </div>
                            <div>
                                <p class="text-xs uppercase font-bold tracking-wider text-text-secondary">Điểm số cao nhất</p>
                                <div class="flex items-baseline gap-2 mt-1">
                                    <span class="text-3xl sm:text-4xl font-extrabold ${passed ? 'text-status-success' : 'text-status-danger'}">
                                        <fmt:formatNumber value="${highestScore}" maxFractionDigits="1"/>
                                    </span>
                                    <span class="text-sm font-medium text-text-secondary">/ 10 điểm</span>
                                </div>
                            </div>
                        </div>

                        <div>
                            <c:choose>
                                <c:when test="${passed}">
                                    <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-bold bg-brand-50 text-status-success border border-brand-100">
                                        <i class="fa-solid fa-circle-check mr-2"></i> Trạng thái: Đã Đạt
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-bold bg-rose-50 text-status-danger border border-rose-200">
                                        <i class="fa-solid fa-circle-xmark mr-2"></i> Trạng thái: Chưa Đạt
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- History Table -->
                    <c:if test="${not empty history}">
                        <div class="mt-6">
                            <h4 class="text-sm font-bold text-text-primary mb-3 flex items-center">
                                <i class="fa-solid fa-clock-rotate-left text-brand-700 mr-2"></i> Lịch sử làm bài (${history.size()} lần)
                            </h4>
                            <div class="overflow-x-auto rounded-xl border border-border-default">
                                <table class="w-full text-left text-sm">
                                    <thead class="bg-surface border-b border-border-default text-xs font-semibold text-text-secondary uppercase">
                                    <tr>
                                        <th class="py-3 px-4">Lần</th>
                                        <th class="py-3 px-4">Thời gian nộp</th>
                                        <th class="py-3 px-4">Điểm số</th>
                                        <th class="py-3 px-4">Kết quả</th>
                                    </tr>
                                    </thead>
                                    <tbody class="divide-y divide-border-default bg-surface-card">
                                    <c:forEach var="sub" items="${history}" varStatus="st">
                                        <tr class="hover:bg-surface/50 transition-colors">
                                            <td class="py-3 px-4 font-semibold text-text-primary">Lần ${history.size() - st.index}</td>
                                            <td class="py-3 px-4 text-text-secondary">
                                                <fmt:formatDate value="${sub.submittedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td class="py-3 px-4 font-bold ${sub.passStatus ? 'text-status-success' : 'text-status-danger'}">
                                                <fmt:formatNumber value="${sub.score}" maxFractionDigits="1"/> / 10
                                            </td>
                                            <td class="py-3 px-4">
                                                <c:choose>
                                                    <c:when test="${sub.passStatus}">
                                                            <span class="inline-flex items-center text-xs font-semibold text-status-success bg-brand-50 px-2.5 py-1 rounded-full border border-brand-100">
                                                                <i class="fa-solid fa-check text-[10px] mr-1"></i> Đạt
                                                            </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                            <span class="inline-flex items-center text-xs font-semibold text-status-danger bg-rose-50 px-2.5 py-1 rounded-full border border-rose-200">
                                                                <i class="fa-solid fa-xmark text-[10px] mr-1"></i> Chưa đạt
                                                            </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <div class="bg-surface-card rounded-2xl border border-border-default p-6 sm:p-8 mb-8 shadow-sm flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center text-xl shrink-0">
                        <i class="fa-solid fa-circle-info"></i>
                    </div>
                    <div>
                        <h4 class="text-base font-bold text-text-primary">Bạn chưa làm bài thi này</h4>
                        <p class="text-sm text-text-secondary mt-0.5">Hãy đọc kỹ hướng dẫn và nhấn nút <strong>"Bắt Đầu Làm Bài"</strong> để thực hiện bài test.</p>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Instructions Card -->
        <div class="bg-surface-card rounded-2xl border border-border-default p-6 sm:p-8 mb-8 shadow-sm">
            <h3 class="text-base font-bold text-text-primary mb-3 flex items-center">
                <i class="fa-solid fa-shield-halved text-brand-700 mr-2"></i> Hướng Dẫn & Lưu Ý Khi Làm Bài
            </h3>
            <ul class="space-y-2 text-sm text-text-secondary">
                <li class="flex items-start gap-2">
                    <i class="fa-solid fa-check text-brand-700 mt-1 shrink-0"></i>
                    <span>Thời gian bắt đầu tính ngay sau khi bạn nhấn nút <strong>Bắt đầu làm bài</strong>.</span>
                </li>
                <li class="flex items-start gap-2">
                    <i class="fa-solid fa-check text-brand-700 mt-1 shrink-0"></i>
                    <span>Bạn có thể theo dõi danh sách các câu đã làm ở bảng tổng quan câu hỏi bên phải màn hình.</span>
                </li>
                <li class="flex items-start gap-2">
                    <i class="fa-solid fa-check text-brand-700 mt-1 shrink-0"></i>
                    <span>Khi hết thời gian quy định, hệ thống sẽ tự động gửi bài thi của bạn.</span>
                </li>
            </ul>
        </div>

        <!-- Action Button (CTA) -->
        <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
            <form action="${pageContext.request.contextPath}/quiz/take" method="post" class="w-full sm:w-auto">
                <input type="hidden" name="quizId" value="${quiz.id}">
                <button type="submit"
                        class="w-full sm:w-auto px-10 py-4 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-xl shadow-md transition-all transform hover:-translate-y-0.5 flex items-center justify-center text-base">
                    <i class="fa-solid fa-play mr-2"></i> ${hasAttempted ? 'Làm Lại Bài Thi' : 'Bắt Đầu Làm Bài'}
                </button>
            </form>
            <c:if test="${not empty courseId}">
                <a href="${pageContext.request.contextPath}/learn/lesson?courseId=${courseId}"
                   class="w-full sm:w-auto px-8 py-4 bg-surface hover:bg-slate-100 text-text-primary font-semibold border border-border-default rounded-xl transition-colors flex items-center justify-center text-base">
                    <i class="fa-solid fa-arrow-left mr-2"></i> Quay Lại Khóa Học
                </a>
            </c:if>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
