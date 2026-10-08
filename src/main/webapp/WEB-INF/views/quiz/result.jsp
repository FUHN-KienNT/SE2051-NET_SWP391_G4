<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow bg-surface py-12 md:py-16 flex items-center justify-center">
    <div class="max-w-xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div class="bg-surface-card p-8 sm:p-10 rounded-2xl border border-border-default shadow-sm text-center">
            
            <!-- Result Icon Badge -->
            <c:choose>
                <c:when test="${result.passed}">
                    <div class="w-20 h-20 rounded-full mx-auto mb-6 bg-brand-50 border border-brand-100 text-status-success flex items-center justify-center text-4xl">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <h1 class="text-2xl sm:text-3xl font-bold text-text-primary mb-2">Chúc Mừng! Bạn Đã Đạt</h1>
                </c:when>
                <c:otherwise>
                    <div class="w-20 h-20 rounded-full mx-auto mb-6 bg-rose-50 border border-rose-200 text-status-danger flex items-center justify-center text-4xl">
                        <i class="fa-solid fa-circle-xmark"></i>
                    </div>
                    <h1 class="text-2xl sm:text-3xl font-bold text-text-primary mb-2">Tiếc Quá! Bạn Chưa Đạt</h1>
                </c:otherwise>
            </c:choose>

            <p class="text-text-secondary text-base mb-8">${quiz.title}</p>

            <!-- Score Summary Card -->
            <div class="bg-surface rounded-xl p-6 mb-8 grid grid-cols-2 gap-4 border border-border-default">
                <div class="border-r border-border-default pr-2">
                    <p class="text-xs uppercase tracking-wider text-text-secondary font-semibold mb-1">Điểm Số Đạt Được</p>
                    <p class="text-4xl font-extrabold ${result.passed ? 'text-status-success' : 'text-status-danger'}">
                        <fmt:formatNumber value="${result.score}" maxFractionDigits="1"/>
                    </p>
                    <p class="text-xs text-text-secondary mt-1">thang điểm 10</p>
                </div>
                <div class="pl-2">
                    <p class="text-xs uppercase tracking-wider text-text-secondary font-semibold mb-1">Điểm Yêu Cầu</p>
                    <p class="text-4xl font-extrabold text-text-primary">
                        <fmt:formatNumber value="${quiz.passScore}" maxFractionDigits="1"/>
                    </p>
                    <p class="text-xs text-text-secondary mt-1">thang điểm 10</p>
                </div>
            </div>

            <!-- Actions -->
            <div class="flex flex-col sm:flex-row justify-center gap-3">
                <a href="${pageContext.request.contextPath}/quiz?quizId=${quiz.id}" class="px-6 py-3 bg-brand-700 hover:bg-brand-800 text-white font-semibold rounded-lg text-sm transition-colors flex items-center justify-center">
                    <i class="fa-solid fa-rotate-right mr-2"></i> Xem Tổng Quan & Làm Lại
                </a>
                <a href="${pageContext.request.contextPath}/courses" class="px-6 py-3 bg-surface hover:bg-slate-100 text-text-primary font-semibold border border-border-default rounded-lg text-sm transition-colors flex items-center justify-center">
                    <i class="fa-solid fa-arrow-left mr-2"></i> Về Danh Sách Khóa Học
                </a>
            </div>

        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
