<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

    <nav aria-label="Breadcrumb"
         class="mb-6 flex flex-wrap items-center gap-2 text-sm text-text-secondary">
        <a href="${pageContext.request.contextPath}/my-enrollments"
           class="rounded font-semibold text-brand-700 hover:text-brand-800 focus-visible:ring-2 focus-visible:ring-brand-700">
            Khóa học của tôi
        </a>
        <span aria-hidden="true">/</span>
        <span class="break-words"><c:out value="${course.title}" /></span>
    </nav>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 items-start">

        <%-- Sidebar giống trang bài học --%>
        <jsp:include page="/WEB-INF/views/learn/sidebar.jsp" />

        <%-- Nội dung chính: giới thiệu quiz --%>
        <section aria-labelledby="quiz-heading" class="lg:col-span-3 min-w-0">
            <article class="rounded-xl border border-border-default bg-surface-card shadow-sm overflow-hidden">

                <header class="p-6 sm:p-8 border-b border-border-default">
                    <c:if test="${not empty quiz.imageUrl}">
                        <div class="w-full h-48 sm:h-64 rounded-xl overflow-hidden border border-border-default mb-6 bg-surface shadow-sm">
                            <img src="${fn:escapeXml(quiz.imageUrl)}" alt="${fn:escapeXml(quiz.title)}"
                                 class="w-full h-full object-cover"
                                 onerror="this.parentElement.style.display='none'">
                        </div>
                    </c:if>
                    <p class="text-sm font-semibold text-brand-700 mb-2">Quiz</p>
                    <h1 id="quiz-heading" class="text-2xl sm:text-3xl font-bold text-text-primary break-words">
                        <c:out value="${quiz.title}" />
                    </h1>
                    <p class="text-sm text-text-secondary mt-3">
                        <i class="fa-solid fa-book-bookmark text-brand-700 mr-1" aria-hidden="true"></i>
                        Module: <c:out value="${not empty quiz.moduleTitle ? quiz.moduleTitle : 'Bài kiểm tra'}" />
                    </p>
                </header>

                <div class="p-6 sm:p-8 space-y-6">

                    <%-- Thông tin bài thi --%>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <div class="bg-surface p-4 rounded-xl border border-border-default">
                            <p class="text-xs font-semibold text-text-secondary uppercase tracking-wider">
                                <i class="fa-solid fa-list-check text-brand-700 mr-1" aria-hidden="true"></i> Số câu hỏi
                            </p>
                            <p class="text-xl font-bold text-text-primary mt-1">${questionCount} câu</p>
                        </div>

                        <div class="bg-surface p-4 rounded-xl border border-border-default">
                            <p class="text-xs font-semibold text-text-secondary uppercase tracking-wider">
                                <i class="fa-regular fa-clock text-brand-700 mr-1" aria-hidden="true"></i> Thời gian
                            </p>
                            <p class="text-xl font-bold text-text-primary mt-1">
                                <c:choose>
                                    <c:when test="${not empty quiz.timeLimit && quiz.timeLimit > 0}">${quiz.timeLimit} phút</c:when>
                                    <c:otherwise>Không giới hạn</c:otherwise>
                                </c:choose>
                            </p>
                        </div>

                        <div class="bg-surface p-4 rounded-xl border border-border-default">
                            <p class="text-xs font-semibold text-text-secondary uppercase tracking-wider">
                                <i class="fa-solid fa-bullseye text-brand-700 mr-1" aria-hidden="true"></i> Điểm cần đạt
                            </p>
                            <p class="text-xl font-bold text-text-primary mt-1">
                                <fmt:formatNumber value="${quiz.passScore}" maxFractionDigits="1" /> / 10
                            </p>
                        </div>
                    </div>

                    <%-- Điểm cao nhất + lịch sử, hoặc thông báo chưa làm --%>
                    <c:choose>
                        <c:when test="${hasAttempted}">
                            <div class="rounded-xl border border-border-default bg-surface p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                                <div>
                                    <p class="text-xs uppercase font-bold tracking-wider text-text-secondary">
                                        <i class="fa-solid fa-trophy text-amber-500 mr-1" aria-hidden="true"></i> Điểm số cao nhất
                                    </p>
                                    <p class="mt-1">
                                        <span class="text-3xl sm:text-4xl font-extrabold ${passed ? 'text-status-success' : 'text-status-danger'}">
                                            <fmt:formatNumber value="${highestScore}" maxFractionDigits="1" />
                                        </span>
                                        <span class="text-sm font-medium text-text-secondary"> / 10 điểm</span>
                                    </p>
                                </div>

                                <c:choose>
                                    <c:when test="${passed}">
                                        <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-bold bg-brand-50 text-status-success border border-brand-100">
                                            <i class="fa-solid fa-circle-check mr-2" aria-hidden="true"></i> Đã Đạt
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-bold bg-rose-50 text-status-danger border border-rose-200">
                                            <i class="fa-solid fa-circle-xmark mr-2" aria-hidden="true"></i> Chưa Đạt
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div>
                                <h2 class="text-sm font-bold text-text-primary mb-3">
                                    <i class="fa-solid fa-clock-rotate-left text-brand-700 mr-1" aria-hidden="true"></i>
                                    Lịch sử làm bài (${fn:length(history)} lần)
                                </h2>
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
                                            <tr>
                                                <td class="py-3 px-4 font-semibold text-text-primary">Lần ${fn:length(history) - st.index}</td>
                                                <td class="py-3 px-4 text-text-secondary">
                                                    <fmt:formatDate value="${sub.submittedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                                <td class="py-3 px-4 font-bold ${sub.passStatus ? 'text-status-success' : 'text-status-danger'}">
                                                    <fmt:formatNumber value="${sub.score}" maxFractionDigits="1" /> / 10
                                                </td>
                                                <td class="py-3 px-4">
                                                    <c:choose>
                                                        <c:when test="${sub.passStatus}">
                                                            <span class="inline-flex items-center text-xs font-semibold text-status-success bg-brand-50 px-2.5 py-1 rounded-full border border-brand-100">Đạt</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="inline-flex items-center text-xs font-semibold text-status-danger bg-rose-50 px-2.5 py-1 rounded-full border border-rose-200">Chưa đạt</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="rounded-xl border border-border-default bg-surface p-5 flex items-start gap-4">
                                <i class="fa-solid fa-circle-info text-brand-700 text-xl mt-0.5" aria-hidden="true"></i>
                                <div>
                                    <h2 class="text-base font-bold text-text-primary">Bạn chưa làm bài thi này</h2>
                                    <p class="text-sm text-text-secondary mt-0.5">
                                        Hãy đọc kỹ hướng dẫn bên dưới trước khi nhấn nút <strong>"Bắt Đầu Làm Bài"</strong>.
                                    </p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <%-- Hướng dẫn --%>
                    <div>
                        <h2 class="text-base font-bold text-text-primary mb-3">
                            <i class="fa-solid fa-shield-halved text-brand-700 mr-1" aria-hidden="true"></i>
                            Hướng dẫn &amp; lưu ý khi làm bài
                        </h2>
                        <ul class="space-y-2 text-sm text-text-secondary list-disc pl-5">
                            <li>Thời gian bắt đầu tính ngay sau khi bạn nhấn nút <strong>Bắt đầu làm bài</strong>.</li>
                            <li>Bạn có thể theo dõi các câu đã làm ở bảng tổng quan câu hỏi trong màn hình làm bài.</li>
                            <li>Khi hết thời gian quy định, hệ thống sẽ tự động gửi bài thi của bạn.</li>
                            <li>Bạn được làm lại nhiều lần, điểm cao nhất sẽ được tính là điểm chính thức.</li>
                        </ul>
                    </div>
                </div>

                <%-- Nút vào làm bài (giống vị trí nút hoàn thành ở trang bài học) --%>
                <footer class="p-6 sm:px-8 border-t border-border-default bg-surface flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <p class="text-sm text-text-secondary">
                        ${hasAttempted ? 'Bạn có thể làm lại để cải thiện điểm số.' : 'Sẵn sàng thì bắt đầu làm bài nhé.'}
                    </p>

                    <form action="${pageContext.request.contextPath}/quiz/take" method="post">
                        <input type="hidden" name="quizId" value="${quiz.id}">
                        <button type="submit"
                                class="w-full inline-flex items-center justify-center gap-2 rounded-lg bg-brand-700 hover:bg-brand-800 text-white px-5 py-3 font-semibold focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            <i class="fa-solid fa-play" aria-hidden="true"></i>
                            ${hasAttempted ? 'Làm Lại Bài Thi' : 'Bắt Đầu Làm Bài'}
                        </button>
                    </form>
                </footer>
            </article>
        </section>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
