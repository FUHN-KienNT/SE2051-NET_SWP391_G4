<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="min-h-[80vh] bg-surface flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full bg-surface-card rounded-3xl border border-border-default shadow-xl p-8 text-center">
        <c:choose>
            <c:when test="${paymentSuccess}">
                <div class="w-20 h-20 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-6 text-3xl shadow-inner animate-bounce">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
                <h1 class="text-2xl font-black text-text-primary mb-2">Thanh Toán Thành Công!</h1>
                <p class="text-text-secondary text-sm mb-6">${message}</p>

                <div class="bg-surface rounded-2xl p-4 text-left text-xs space-y-2.5 mb-6 border border-border-default">
                    <div class="flex justify-between">
                        <span class="text-text-secondary">Khóa học:</span>
                        <span class="font-bold text-text-primary text-right max-w-[200px] truncate">${registration.courseTitle}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-text-secondary">Số tiền thanh toán:</span>
                        <span class="font-bold text-brand-700">
                            <fmt:formatNumber value="${registration.amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                    <c:if test="${not empty vnp_TransactionNo}">
                        <div class="flex justify-between">
                            <span class="text-text-secondary">Mã giao dịch VNPAY:</span>
                            <span class="font-mono font-medium text-text-primary">${vnp_TransactionNo}</span>
                        </div>
                    </c:if>
                    <div class="flex justify-between">
                        <span class="text-text-secondary">Trạng thái:</span>
                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold bg-emerald-100 text-emerald-700">
                            Đã kích hoạt
                        </span>
                    </div>
                </div>

                <div class="space-y-3">
                    <a href="${pageContext.request.contextPath}/learn/course?id=${registration.courseId}" class="w-full flex items-center justify-center gap-2 py-3 px-4 font-bold text-white bg-brand-700 hover:bg-brand-800 rounded-xl shadow-md transition text-sm">
                        <i class="fa-solid fa-play"></i> Vào Học Ngay
                    </a>
                    <a href="${pageContext.request.contextPath}/my-enrollments" class="block w-full py-2.5 px-4 text-xs font-semibold text-text-secondary hover:text-brand-700 transition">
                        Xem danh sách khóa học của tôi
                    </a>
                </div>
            </c:when>

            <c:otherwise>
                <div class="w-20 h-20 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center mx-auto mb-6 text-3xl shadow-inner">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                <h1 class="text-2xl font-black text-text-primary mb-2">Thanh Toán Chưa Hoàn Tất</h1>
                <p class="text-text-secondary text-sm mb-6">${message}</p>

                <div class="space-y-3">
                    <c:if test="${not empty registration}">
                        <a href="${pageContext.request.contextPath}/enrollment?courseId=${registration.courseId}" class="w-full flex items-center justify-center gap-2 py-3 px-4 font-bold text-white bg-brand-700 hover:bg-brand-800 rounded-xl shadow-md transition text-sm">
                            <i class="fa-solid fa-rotate-right"></i> Thử Lại Thanh Toán
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/courses" class="block w-full py-2.5 px-4 text-xs font-semibold text-text-secondary hover:text-brand-700 transition">
                        Quay lại danh sách khóa học
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
