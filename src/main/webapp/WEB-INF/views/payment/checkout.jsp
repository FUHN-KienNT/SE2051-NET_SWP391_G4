<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-12 max-w-xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="bg-white p-8 rounded-2xl border border-slate-200 shadow-xl">
        <h1 class="text-2xl font-black text-slate-900 mb-6 text-center">Thanh Toán Đơn Hàng</h1>
        
        <div class="bg-slate-50 p-6 rounded-xl border border-slate-200 mb-6 space-y-3">
            <div class="flex justify-between text-sm">
                <span class="text-slate-500">Khóa học:</span>
                <span class="font-bold text-slate-800">${course.title}</span>
            </div>
            <div class="flex justify-between text-sm">
                <span class="text-slate-500">Số tiền:</span>
                <span class="font-bold text-blue-600"><fmt:formatNumber value="${amount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
            </div>
            <div class="flex justify-between text-sm border-t border-slate-200 pt-3">
                <span class="text-slate-500">Cổng thanh toán:</span>
                <span class="font-bold text-slate-800">VNPay Gateway</span>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/payment" method="post">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="courseId" value="${course.id}">
            <input type="hidden" name="amount" value="${amount}">
            <button type="submit" class="w-full py-3.5 px-4 font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-md transition">
                Chuyển Đến VNPay Để Thanh Toán
            </button>
        </form>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />