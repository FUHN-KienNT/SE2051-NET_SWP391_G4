<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-12 max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-xl p-8">
        <h1 class="text-2xl font-black text-slate-900 mb-6">Xác Nhận Đăng Ký Khóa Học</h1>
        
        <div class="flex items-center space-x-4 p-4 rounded-xl bg-slate-50 border border-slate-200 mb-6">
            <img src="${not empty course.thumbnail ? course.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" alt="${course.title}" class="w-24 h-24 rounded-lg object-cover">
            <div>
                <h3 class="font-bold text-lg text-slate-900">${course.title}</h3>
                <div class="mt-2 text-base font-bold text-blue-600">
                    <c:choose>
                        <c:when test="${course.price <= 0}">Miễn Phí</c:when>
                        <c:otherwise><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/enrollment" method="post" class="space-y-6">
            <input type="hidden" name="courseId" value="${course.id}">
            
            <button type="submit" class="w-full py-3.5 px-4 font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-md transition">
                Xác Nhận Đăng Ký Khóa Học
            </button>
        </form>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />