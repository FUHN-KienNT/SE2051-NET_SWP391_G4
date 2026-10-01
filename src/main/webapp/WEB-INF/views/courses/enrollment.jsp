<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow bg-slate-50 py-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <%-- Breadcrumb --%>
        <nav class="text-sm text-slate-500 mb-6 flex items-center gap-2">
            <a href="${pageContext.request.contextPath}/" class="hover:text-blue-600 transition">Trang chủ</a>
            <i class="fa-solid fa-chevron-right text-xs text-slate-400"></i>
            <a href="${pageContext.request.contextPath}/courses" class="hover:text-blue-600 transition">Khóa học</a>
            <i class="fa-solid fa-chevron-right text-xs text-slate-400"></i>
            <a href="${pageContext.request.contextPath}/courses?action=detail&id=${course.id}" class="hover:text-blue-600 transition line-clamp-1">${course.title}</a>
            <i class="fa-solid fa-chevron-right text-xs text-slate-400"></i>
            <span class="text-slate-800 font-semibold">Thông tin thanh toán</span>
        </nav>

        <c:choose>
            <%-- TRƯỜNG HỢP: Tài khoản không phải là Student --%>
            <c:when test="${not empty roleError}">
                <div class="max-w-2xl mx-auto bg-white rounded-2xl border border-rose-200 shadow-sm p-8 text-center my-8">
                    <div class="w-16 h-16 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center text-2xl mx-auto mb-4">
                        <i class="fa-solid fa-user-shield"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-slate-900 mb-3">Yêu Cầu Tài Khoản Học Viên</h2>
                    <p class="text-slate-600 mb-6 leading-relaxed">${roleError}</p>
                    
                    <div class="flex flex-col sm:flex-row gap-3 justify-center">
                        <a href="${pageContext.request.contextPath}/auth/logout" class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition shadow-sm">
                            <i class="fa-solid fa-arrow-right-from-bracket mr-2"></i> Đăng nhập tài khoản khác
                        </a>
                        <a href="${pageContext.request.contextPath}/courses?action=detail&id=${course.id}" class="px-6 py-3 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-xl transition">
                            <i class="fa-solid fa-arrow-left mr-2"></i> Quay lại khóa học
                        </a>
                    </div>
                </div>
            </c:when>

            <%-- TRƯỜNG HỢP BÌNH THƯỜNG: Là Student -> Hiển thị form thông tin thanh toán --%>
            <c:otherwise>
                <div class="mb-8">
                    <h1 class="text-3xl font-black text-slate-900 tracking-tight">Thông Tin Thanh Toán & Đăng Ký</h1>
                    <p class="text-slate-500 mt-1">Kiểm tra thông tin tài khoản học viên và lựa chọn hình thức thanh toán phù hợp</p>
                </div>

                <form id="paymentForm" action="${pageContext.request.contextPath}/enrollment" method="post">
                    <input type="hidden" name="courseId" value="${course.id}">

                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">

                        <%-- CỘT TRÁI: Thông tin học viên & Phương thức thanh toán --%>
                        <div class="lg:col-span-7 space-y-6">

                            <%-- Card 1: Thông tin học viên --%>
                            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
                                <div class="flex items-center justify-between pb-4 border-b border-slate-100 mb-5">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-base">
                                            <i class="fa-solid fa-id-card"></i>
                                        </div>
                                        <div>
                                            <h2 class="text-lg font-bold text-slate-900">Thông Tin Người Học</h2>
                                            <p class="text-xs text-slate-400">Khóa học và chứng chỉ sẽ được cấp theo thông tin này</p>
                                        </div>
                                    </div>
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                        <i class="fa-solid fa-check-circle mr-1 text-emerald-500"></i> Học viên (Student)
                                    </span>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label class="block text-xs font-semibold text-slate-500 mb-1.5 uppercase tracking-wider">Họ và tên / Username</label>
                                        <div class="relative">
                                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                                <i class="fa-regular fa-user"></i>
                                            </div>
                                            <input type="text" value="${student.username}" readonly class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 text-sm font-medium focus:outline-none cursor-not-allowed">
                                        </div>
                                    </div>

                                    <div>
                                        <label class="block text-xs font-semibold text-slate-500 mb-1.5 uppercase tracking-wider">Email tài khoản</label>
                                        <div class="relative">
                                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                                <i class="fa-regular fa-envelope"></i>
                                            </div>
                                            <input type="email" value="${student.email}" readonly class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 text-sm font-medium focus:outline-none cursor-not-allowed">
                                        </div>
                                    </div>

                                    <div class="md:col-span-2">
                                        <label for="studentPhone" class="block text-xs font-semibold text-slate-500 mb-1.5 uppercase tracking-wider">Số điện thoại liên hệ</label>
                                        <div class="relative">
                                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                                <i class="fa-solid fa-phone"></i>
                                            </div>
                                            <input type="tel" id="studentPhone" name="phone" value="${student.phone}" placeholder="Nhập số điện thoại để nhận thông báo kích hoạt" class="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-300 rounded-xl text-slate-800 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <%-- Card 2: Chọn phương thức thanh toán --%>
                            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
                                <div class="flex items-center gap-3 pb-4 border-b border-slate-100 mb-5">
                                    <div class="w-10 h-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-base">
                                        <i class="fa-solid fa-wallet"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-lg font-bold text-slate-900">Phương Thức Thanh Toán</h2>
                                        <p class="text-xs text-slate-400">Vui lòng chọn 1 hình thức thanh toán thuận tiện nhất</p>
                                    </div>
                                </div>

                                <c:choose>
                                    <c:when test="${course.price <= 0}">
                                        <div class="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm flex items-center gap-3">
                                            <i class="fa-solid fa-circle-check text-emerald-500 text-xl shrink-0"></i>
                                            <div>
                                                <p class="font-bold">Khóa học hoàn toàn Miễn Phí!</p>
                                                <p class="text-xs text-emerald-700 mt-0.5">Bạn không cần chọn phương thức thanh toán. Nhấn "Xác nhận đăng ký" để bắt đầu học ngay.</p>
                                            </div>
                                        </div>
                                    </c:when>

                                    <c:otherwise>
                                        <div class="space-y-3" id="paymentMethodList">
                                            <c:forEach var="pm" items="${paymentMethods}" varStatus="pmStatus">
                                                <label class="payment-method-card relative flex items-start gap-4 p-4 rounded-xl border border-slate-200 hover:border-blue-400 bg-white hover:bg-blue-50/30 cursor-pointer transition">
                                                    <div class="pt-0.5">
                                                        <input type="radio" name="paymentMethodId" value="${pm.id}" class="w-4 h-4 text-blue-600 focus:ring-blue-500" <c:if test="${pmStatus.first}">checked</c:if>>
                                                    </div>

                                                    <div class="flex-1">
                                                        <div class="flex items-center justify-between">
                                                            <span class="font-bold text-slate-800 text-sm">${pm.name}</span>
                                                            <div class="flex items-center gap-1.5 text-slate-400 text-base">
                                                                <c:choose>
                                                                    <c:when test="${pm.code eq 'vnpay'}">
                                                                        <span class="px-2 py-0.5 text-[11px] font-black rounded bg-blue-100 text-blue-700">VNPAY-QR</span>
                                                                    </c:when>
                                                                    <c:when test="${pm.code eq 'momo'}">
                                                                        <span class="px-2 py-0.5 text-[11px] font-black rounded bg-pink-100 text-pink-700">MOMO</span>
                                                                    </c:when>
                                                                    <c:when test="${pm.code eq 'banking'}">
                                                                        <span class="px-2 py-0.5 text-[11px] font-black rounded bg-emerald-100 text-emerald-700">VIETQR</span>
                                                                    </c:when>
                                                                    <c:when test="${pm.code eq 'credit_card'}">
                                                                        <span class="px-2 py-0.5 text-[11px] font-black rounded bg-purple-100 text-purple-700">VISA / MASTER</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <i class="fa-solid fa-credit-card"></i>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                        <p class="text-xs text-slate-500 mt-1">${pm.description}</p>
                                                    </div>
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <%-- Card 3: Cam kết & Quyền lợi --%>
                            <div class="bg-gradient-to-br from-blue-50 to-indigo-50/50 rounded-2xl border border-blue-100 p-6">
                                <h3 class="font-bold text-slate-900 text-sm mb-3 flex items-center gap-2">
                                    <i class="fa-solid fa-shield-halved text-blue-600"></i> Cam Kết Từ LearnHub
                                </h3>
                                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs text-slate-600">
                                    <div class="flex items-center gap-2">
                                        <i class="fa-solid fa-bolt text-amber-500"></i>
                                        <span>Kích hoạt khóa học tức thì</span>
                                    </div>
                                    <div class="flex items-center gap-2">
                                        <i class="fa-solid fa-infinity text-blue-500"></i>
                                        <span>Sở hữu bài giảng trọn đời</span>
                                    </div>
                                    <div class="flex items-center gap-2">
                                        <i class="fa-solid fa-headset text-emerald-500"></i>
                                        <span>Hỗ trợ kỹ thuật 24/7</span>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <%-- CỘT PHẢI: Tóm tắt đơn hàng & Nút Xác nhận thanh toán --%>
                        <div class="lg:col-span-5">
                            <div class="sticky top-24 bg-white rounded-2xl border border-slate-200 shadow-xl overflow-hidden p-6">
                                <h2 class="text-lg font-bold text-slate-900 pb-4 border-b border-slate-100 mb-5">
                                    Tóm Tắt Đơn Hàng
                                </h2>

                                <%-- Khóa học tóm tắt --%>
                                <div class="flex gap-4 mb-6">
                                    <div class="w-24 h-20 rounded-xl overflow-hidden bg-slate-100 shrink-0">
                                        <c:choose>
                                            <c:when test="${not empty course.thumbnailUrl}">
                                                <img src="${course.thumbnailUrl}" alt="${course.title}" class="w-full h-full object-cover">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800" alt="${course.title}" class="w-full h-full object-cover">
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="flex-1 min-w-0">
                                        <c:if test="${not empty course.categoryName}">
                                            <span class="inline-block px-2 py-0.5 rounded text-[10px] font-semibold bg-blue-50 text-blue-700 mb-1">
                                                ${course.categoryName}
                                            </span>
                                        </c:if>
                                        <h3 class="font-bold text-slate-900 text-sm leading-snug line-clamp-2">${course.title}</h3>
                                        <c:if test="${not empty course.expertName}">
                                            <p class="text-xs text-slate-400 mt-1 truncate">GV: ${course.expertName}</p>
                                        </c:if>
                                    </div>
                                </div>

                                <%-- Chi tiết tiền --%>
                                <div class="space-y-3 text-sm text-slate-600 border-t border-slate-100 pt-4 mb-6">
                                    <div class="flex justify-between items-center">
                                        <span>Học phí khóa học:</span>
                                        <span class="font-semibold text-slate-800">
                                            <c:choose>
                                                <c:when test="${course.price <= 0}">Miễn Phí</c:when>
                                                <c:otherwise><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <div class="flex justify-between items-center text-emerald-600">
                                        <span>Ưu đãi áp dụng:</span>
                                        <span class="font-semibold">0 ₫</span>
                                    </div>

                                    <div class="border-t border-slate-100 pt-3 flex justify-between items-baseline">
                                        <span class="text-base font-bold text-slate-900">Tổng thanh toán:</span>
                                        <span class="text-2xl font-black text-blue-600">
                                            <c:choose>
                                                <c:when test="${course.price <= 0}">Miễn Phí</c:when>
                                                <c:otherwise><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </div>

                                <%-- Nút Xác Nhận Thanh Toán --%>
                                <button type="submit" class="w-full py-4 px-6 font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-lg transition-all duration-200 flex items-center justify-center gap-2 text-base group">
                                    <i class="fa-solid fa-lock group-hover:scale-110 transition-transform"></i>
                                    <span>Xác Nhận Thanh Toán</span>
                                </button>

                                <a href="${pageContext.request.contextPath}/courses?action=detail&id=${course.id}" class="block text-center mt-3 text-xs text-slate-400 hover:text-slate-600 transition">
                                    <i class="fa-solid fa-arrow-left mr-1"></i> Quay lại chi tiết khóa học
                                </a>

                                <div class="mt-6 pt-5 border-t border-slate-100 text-center">
                                    <div class="flex items-center justify-center gap-2 text-xs text-slate-400">
                                        <i class="fa-solid fa-shield-halved text-emerald-500 text-sm"></i>
                                        <span>Giao dịch an toàn & mã hóa bảo mật 256-bit</span>
                                    </div>
                                </div>

                            </div>
                        </div>

                    </div>
                </form>
            </c:otherwise>
        </c:choose>

    </div>
</main>

<script>
    // Highlight thẻ phương thức thanh toán khi được chọn
    document.addEventListener('DOMContentLoaded', function () {
        const radios = document.querySelectorAll('input[name="paymentMethodId"]');
        function updateCardStyles() {
            radios.forEach(function (radio) {
                const card = radio.closest('.payment-method-card');
                if (card) {
                    if (radio.checked) {
                        card.classList.add('border-blue-600', 'bg-blue-50/40', 'ring-1', 'ring-blue-600');
                        card.classList.remove('border-slate-200', 'bg-white');
                    } else {
                        card.classList.remove('border-blue-600', 'bg-blue-50/40', 'ring-1', 'ring-blue-600');
                        card.classList.add('border-slate-200', 'bg-white');
                    }
                }
            });
        }

        radios.forEach(function (radio) {
            radio.addEventListener('change', updateCardStyles);
        });
        updateCardStyles();
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />