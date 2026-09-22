<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-12 max-w-xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="bg-white p-8 rounded-2xl border border-slate-200 shadow-xl text-center">
        <c:choose>
            <c:when test="${paymentStatus eq 'success'}">
                <div class="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 mx-auto flex items-center justify-center text-3xl mb-4">
                    <i class="fa-solid fa-check"></i>
                </div>
                <h1 class="text-2xl font-black text-slate-900 mb-2">Thanh Toán Thành Công!</h1>
                <p class="text-sm text-slate-500 mb-6">Đơn hàng của bạn đã được thanh toán và khóa học đã được kích hoạt.</p>
            </c:when>
            <c:otherwise>
                <div class="w-16 h-16 rounded-full bg-rose-100 text-rose-600 mx-auto flex items-center justify-center text-3xl mb-4">
                    <i class="fa-solid fa-xmark"></i>
                </div>
                <h1 class="text-2xl font-black text-slate-900 mb-2">Thanh Toán Thất Bại!</h1>
                <p class="text-sm text-slate-500 mb-6">Giao dịch chưa hoàn tất hoặc đã bị hủy bởi người dùng.</p>
            </c:otherwise>
        </c:choose>

        <div class="bg-slate-50 p-6 rounded-xl border border-slate-200 mb-6 text-left space-y-2 text-sm">
            <div class="flex justify-between">
                <span class="text-slate-500">Mã đơn hàng:</span>
                <span class="font-mono font-bold text-slate-800">${orderId}</span>
            </div>
            <c:if test="${not empty transactionId}">
                <div class="flex justify-between">
                    <span class="text-slate-500">Mã giao dịch VNPay:</span>
                    <span class="font-mono font-bold text-slate-800">${transactionId}</span>
                </div>
            </c:if>
            <c:if test="${not empty bankCode}">
                <div class="flex justify-between">
                    <span class="text-slate-500">Ngân hàng:</span>
                    <span class="font-bold text-slate-800">${bankCode}</span>
                </div>
            </c:if>
        </div>

        <div class="flex justify-center space-x-4">
            <a href="${pageContext.request.contextPath}/enrollment?action=my-courses" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-sm transition">
                Vào khóa học của tôi
            </a>
            <a href="${pageContext.request.contextPath}/home" class="px-6 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl text-sm transition">
                Về trang chủ
            </a>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />