<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="LearnHub | Thanh Toán - ${course.title}" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow bg-surface py-10 sm:py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <%-- Breadcrumb --%>
        <nav class="text-sm text-text-secondary mb-6 flex items-center gap-2">
            <a href="${pageContext.request.contextPath}/" class="hover:text-brand-700 transition">Trang chủ</a>
            <i class="fa-solid fa-chevron-right text-xs text-slate-400"></i>
            <a href="${pageContext.request.contextPath}/courses" class="hover:text-brand-700 transition">Khóa học</a>
            <i class="fa-solid fa-chevron-right text-xs text-slate-400"></i>
            <a href="${pageContext.request.contextPath}/courses?action=detail&id=${course.id}" class="hover:text-brand-700 transition line-clamp-1 max-w-xs">${course.title}</a>
            <i class="fa-solid fa-chevron-right text-xs text-slate-400"></i>
            <span class="text-text-primary font-semibold">Thông tin thanh toán</span>
        </nav>

        <c:choose>
            <%-- TRƯỜNG HỢP: Tài khoản không phải là Student --%>
            <c:when test="${not empty roleError}">
                <div class="max-w-2xl mx-auto bg-surface-card rounded-2xl border border-rose-200 shadow-sm p-8 text-center my-8">
                    <div class="w-16 h-16 bg-rose-50 text-rose-600 rounded-full flex items-center justify-center text-2xl mx-auto mb-4 border border-rose-100">
                        <i class="fa-solid fa-user-shield"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-text-primary mb-3">Yêu Cầu Tài Khoản Học Viên</h2>
                    <p class="text-text-secondary mb-6 leading-relaxed">${roleError}</p>
                    
                    <div class="flex flex-col sm:flex-row gap-3 justify-center">
                        <a href="${pageContext.request.contextPath}/auth/logout" class="px-6 py-3 bg-brand-700 hover:bg-brand-800 text-white font-semibold rounded-xl transition shadow-sm">
                            <i class="fa-solid fa-arrow-right-from-bracket mr-2"></i> Đăng nhập tài khoản khác
                        </a>
                        <a href="${pageContext.request.contextPath}/courses?action=detail&id=${course.id}" class="px-6 py-3 bg-surface hover:bg-slate-200 text-text-primary font-semibold rounded-xl transition border border-border-default">
                            <i class="fa-solid fa-arrow-left mr-2"></i> Quay lại khóa học
                        </a>
                    </div>
                </div>
            </c:when>

            <%-- TRƯỜNG HỢP BÌNH THƯỜNG: Là Student -> Hiển thị form thông tin thanh toán --%>
            <c:otherwise>
                <div class="mb-8">
                    <p class="text-sm font-semibold uppercase tracking-wide text-brand-700 mb-1">Xác nhận đơn hàng</p>
                    <h1 class="text-3xl sm:text-4xl font-black text-text-primary tracking-tight">Thông Tin Thanh Toán & Đăng Ký</h1>
                    <p class="text-text-secondary mt-1 text-sm sm:text-base">Kiểm tra thông tin tài khoản học viên và lựa chọn hình thức thanh toán thuận tiện nhất</p>
                </div>

                <form id="paymentForm" action="${pageContext.request.contextPath}/enrollment" method="post">
                    <input type="hidden" name="courseId" value="${course.id}">

                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">

                        <%-- CỘT TRÁI: Thông tin học viên & Phương thức thanh toán --%>
                        <div class="lg:col-span-7 space-y-6">

                            <%-- Card 1: Thông tin học viên --%>
                            <div class="bg-surface-card rounded-2xl border border-border-default shadow-sm p-6">
                                <div class="flex items-center justify-between pb-4 border-b border-border-default mb-5">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-full bg-brand-100 text-brand-900 flex items-center justify-center font-bold text-base">
                                            <i class="fa-solid fa-id-card"></i>
                                        </div>
                                        <div>
                                            <h2 class="text-lg font-bold text-text-primary">Thông Tin Người Học</h2>
                                            <p class="text-xs text-text-secondary">Khóa học và chứng chỉ hoàn thành sẽ được cấp theo thông tin này</p>
                                        </div>
                                    </div>
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-brand-50 text-brand-700 border border-brand-100">
                                        <i class="fa-solid fa-check-circle mr-1 text-brand-600"></i> Học viên (Student)
                                    </span>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label class="block text-xs font-semibold text-text-secondary mb-1.5 uppercase tracking-wider">Họ và tên / Username</label>
                                        <div class="relative">
                                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-secondary">
                                                <i class="fa-regular fa-user"></i>
                                            </div>
                                            <input type="text" value="${student.username}" readonly class="w-full pl-10 pr-4 py-2.5 bg-surface border border-border-default rounded-xl text-text-primary text-sm font-medium focus:outline-none cursor-not-allowed">
                                        </div>
                                    </div>

                                    <div>
                                        <label class="block text-xs font-semibold text-text-secondary mb-1.5 uppercase tracking-wider">Email tài khoản</label>
                                        <div class="relative">
                                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-secondary">
                                                <i class="fa-regular fa-envelope"></i>
                                            </div>
                                            <input type="email" value="${student.email}" readonly class="w-full pl-10 pr-4 py-2.5 bg-surface border border-border-default rounded-xl text-text-primary text-sm font-medium focus:outline-none cursor-not-allowed">
                                        </div>
                                    </div>

                                    <div class="md:col-span-2">
                                        <label for="studentPhone" class="block text-xs font-semibold text-text-secondary mb-1.5 uppercase tracking-wider">
                                            Số điện thoại liên hệ <span class="text-red-500 font-bold">*</span>
                                        </label>
                                        <div class="relative">
                                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-secondary">
                                                <i class="fa-solid fa-phone"></i>
                                            </div>
                                            <input type="tel" id="studentPhone" name="phone" value="${student.phone != null ? student.phone : param.phone}" 
                                                   maxlength="10"
                                                   placeholder="Nhập số điện thoại 10 chữ số (VD: 0912345678)" 
                                                   class="w-full pl-10 pr-4 py-2.5 bg-white border <c:choose><c:when test="${not empty phoneError}">border-red-500 ring-1 ring-red-500</c:when><c:otherwise>border-border-default</c:otherwise></c:choose> rounded-xl text-text-primary text-sm focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition outline-none">
                                        </div>
                                        <p id="phoneErrorMsg" class="mt-1.5 text-xs text-red-600 flex items-center gap-1.5 <c:if test="${empty phoneError}">hidden</c:if>">
                                            <i class="fa-solid fa-circle-exclamation shrink-0"></i>
                                            <span id="phoneErrorText">${phoneError}</span>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <%-- Card 2: Chọn phương thức thanh toán --%>
                            <div class="bg-surface-card rounded-2xl border border-border-default shadow-sm p-6">
                                <div class="flex items-center gap-3 pb-4 border-b border-border-default mb-5">
                                    <div class="w-10 h-10 rounded-full bg-brand-100 text-brand-900 flex items-center justify-center font-bold text-base">
                                        <i class="fa-solid fa-wallet"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-lg font-bold text-text-primary">Phương Thức Thanh Toán</h2>
                                        <p class="text-xs text-text-secondary">Lựa chọn hình thức thanh toán thuận tiện nhất với bạn</p>
                                    </div>
                                </div>

                                <c:choose>
                                    <c:when test="${course.price <= 0}">
                                        <div class="p-4 rounded-xl bg-brand-50 border border-brand-100 text-brand-900 text-sm flex items-center gap-3">
                                            <i class="fa-solid fa-circle-check text-brand-600 text-xl shrink-0"></i>
                                            <div>
                                                <p class="font-bold">Khóa học này hoàn toàn Miễn Phí!</p>
                                                <p class="text-xs text-brand-700 mt-0.5">Bạn không cần thanh toán bất kỳ chi phí nào. Nhấn "Xác nhận đăng ký" để bắt đầu học ngay.</p>
                                            </div>
                                        </div>
                                    </c:when>

                                    <c:otherwise>
                                        <div class="space-y-3" id="paymentMethodList">
                                            <c:forEach var="pm" items="${paymentMethods}" varStatus="pmStatus">
                                                <label class="payment-method-card relative flex items-start gap-4 p-4 rounded-xl border border-border-default hover:border-brand-500 bg-surface hover:bg-brand-50/30 cursor-pointer transition">
                                                    <div class="pt-0.5">
                                                        <input type="radio" name="paymentMethodId" value="${pm.id}" class="w-4 h-4 text-brand-700 focus:ring-brand-700" <c:if test="${pmStatus.first}">checked</c:if>>
                                                    </div>

                                                    <div class="flex-1">
                                                        <div class="flex items-center justify-between">
                                                            <span class="font-bold text-text-primary text-sm">${pm.name}</span>
                                                            <div class="flex items-center gap-1.5 text-text-secondary text-base">
                                                                <c:choose>
                                                                    <c:when test="${pm.code eq 'vnpay'}">
                                                                        <span class="px-2.5 py-1 text-xs font-black rounded-lg bg-blue-100 text-blue-700 flex items-center gap-1">
                                                                            <i class="fa-solid fa-qrcode"></i> VNPAY-QR
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="px-2.5 py-1 text-xs font-black rounded-lg bg-brand-100 text-brand-800 flex items-center gap-1">
                                                                            <i class="fa-solid fa-building-columns"></i> SEPAY / VIETQR
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                        <p class="text-xs text-text-secondary mt-1">${pm.description}</p>
                                                    </div>
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <%-- Card 3: Cam kết từ LearnHub (Phong cách Dark inverse card đồng bộ với home.jsp) --%>
                            <div class="bg-surface-inverse rounded-2xl p-6 text-white shadow-sm relative overflow-hidden">
                                <div class="absolute -right-10 -bottom-10 w-40 h-40 bg-brand-900/40 rounded-full blur-2xl pointer-events-none"></div>
                                <h3 class="font-bold text-white text-sm mb-4 flex items-center gap-2 relative z-10">
                                    <i class="fa-solid fa-shield-halved text-brand-500"></i> Cam Kết Từ LearnHub
                                </h3>
                                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs text-slate-300 relative z-10">
                                    <div class="flex items-center gap-2">
                                        <i class="fa-solid fa-bolt text-brand-500"></i>
                                        <span>Kích hoạt tức thì 24/7</span>
                                    </div>
                                    <div class="flex items-center gap-2">
                                        <i class="fa-solid fa-infinity text-brand-500"></i>
                                        <span>Sở hữu bài giảng trọn đời</span>
                                    </div>
                                    <div class="flex items-center gap-2">
                                        <i class="fa-solid fa-headset text-brand-500"></i>
                                        <span>Hỗ trợ kỹ thuật chu đáo</span>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <%-- CỘT PHẢI: Tóm tắt đơn hàng & Nút Xác nhận thanh toán --%>
                        <div class="lg:col-span-5">
                            <div class="sticky top-24 bg-surface-card rounded-2xl border border-border-default shadow-xl overflow-hidden p-6">
                                <h2 class="text-lg font-bold text-text-primary pb-4 border-b border-border-default mb-5">
                                    Tóm Tắt Đơn Hàng
                                </h2>

                                <%-- Khóa học tóm tắt --%>
                                <div class="flex gap-4 mb-6">
                                    <div class="w-24 h-20 rounded-xl overflow-hidden bg-brand-50 shrink-0 relative flex items-center justify-center">
                                        <i class="fa-solid fa-book-open text-2xl text-brand-700" aria-hidden="true"></i>
                                        <c:choose>
                                            <c:when test="${not empty course.thumbnailUrl}">
                                                <img src="${course.thumbnailUrl}" alt="${course.title}" onerror="this.hidden=true" class="absolute inset-0 w-full h-full object-cover">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800" alt="${course.title}" onerror="this.hidden=true" class="absolute inset-0 w-full h-full object-cover">
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="flex-1 min-w-0">
                                        <c:if test="${not empty course.categoryName}">
                                            <span class="inline-block px-2 py-0.5 rounded text-[10px] font-semibold bg-brand-50 text-brand-700 border border-brand-100 mb-1">
                                                ${course.categoryName}
                                            </span>
                                        </c:if>
                                        <h3 class="font-bold text-text-primary text-sm leading-snug line-clamp-2">${course.title}</h3>
                                        <c:if test="${not empty course.expertName}">
                                            <p class="text-xs text-text-secondary mt-1 truncate">GV: ${course.expertName}</p>
                                        </c:if>
                                    </div>
                                </div>

                                <%-- Chi tiết tiền --%>
                                <div class="space-y-3 text-sm text-text-secondary border-t border-border-default pt-4 mb-6">
                                    <div class="flex justify-between items-center">
                                        <span>Học phí khóa học:</span>
                                        <span class="font-semibold text-text-primary">
                                            <c:choose>
                                                <c:when test="${course.price <= 0}"><span class="text-brand-700">Miễn Phí</span></c:when>
                                                <c:otherwise><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <div class="flex justify-between items-center text-brand-700">
                                        <span>Ưu đãi áp dụng:</span>
                                        <span class="font-semibold">0 ₫</span>
                                    </div>

                                    <div class="border-t border-border-default pt-3 flex justify-between items-baseline">
                                        <span class="text-base font-bold text-text-primary">Tổng thanh toán:</span>
                                        <span class="text-2xl font-black text-brand-700">
                                            <c:choose>
                                                <c:when test="${course.price <= 0}">Miễn Phí</c:when>
                                                <c:otherwise><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </div>

                                <%-- Nút Xác Nhận Thanh Toán --%>
                                <button type="submit" class="w-full py-3.5 px-6 font-bold text-white bg-brand-700 hover:bg-brand-800 rounded-xl shadow-md transition-all duration-200 flex items-center justify-center gap-2 text-base group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                    <i class="fa-solid fa-lock group-hover:scale-110 transition-transform"></i>
                                    <span>Xác Nhận Thanh Toán</span>
                                </button>

                                <a href="${pageContext.request.contextPath}/courses?action=detail&id=${course.id}" class="block text-center mt-3 text-xs text-text-secondary hover:text-brand-700 transition">
                                    <i class="fa-solid fa-arrow-left mr-1"></i> Quay lại chi tiết khóa học
                                </a>

                                <div class="mt-6 pt-5 border-t border-border-default text-center">
                                    <div class="flex items-center justify-center gap-2 text-xs text-text-secondary">
                                        <i class="fa-solid fa-shield-halved text-brand-600 text-sm"></i>
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
    document.addEventListener('DOMContentLoaded', function () {
        // 1. Highlight thẻ phương thức thanh toán khi được chọn
        const radios = document.querySelectorAll('input[name="paymentMethodId"]');
        function updateCardStyles() {
            radios.forEach(function (radio) {
                const card = radio.closest('.payment-method-card');
                if (card) {
                    if (radio.checked) {
                        card.classList.add('border-brand-700', 'bg-brand-50/40', 'ring-1', 'ring-brand-700');
                        card.classList.remove('border-border-default', 'bg-surface');
                    } else {
                        card.classList.remove('border-brand-700', 'bg-brand-50/40', 'ring-1', 'ring-brand-700');
                        card.classList.add('border-border-default', 'bg-surface');
                    }
                }
            });
        }

        radios.forEach(function (radio) {
            radio.addEventListener('change', updateCardStyles);
        });
        updateCardStyles();

        // 2. Validation số điện thoại liên hệ
        const phoneInput = document.getElementById('studentPhone');
        const phoneErrorMsg = document.getElementById('phoneErrorMsg');
        const phoneErrorText = document.getElementById('phoneErrorText');
        const paymentForm = document.getElementById('paymentForm');

        function showPhoneError(msg) {
            if (!phoneInput) return;
            phoneInput.classList.add('border-red-500', 'ring-1', 'ring-red-500');
            phoneInput.classList.remove('border-border-default', 'focus:ring-brand-700', 'focus:border-brand-700');
            if (phoneErrorText) phoneErrorText.textContent = msg;
            if (phoneErrorMsg) phoneErrorMsg.classList.remove('hidden');
        }

        function clearPhoneError() {
            if (!phoneInput) return;
            phoneInput.classList.remove('border-red-500', 'ring-1', 'ring-red-500');
            phoneInput.classList.add('border-border-default');
            if (phoneErrorMsg) phoneErrorMsg.classList.add('hidden');
        }

        function validatePhone(showMsg) {
            if (!phoneInput) return true;
            const val = phoneInput.value.trim();
            // Đầu số Việt Nam hợp lệ: 03, 05, 07, 08, 09 và đủ 10 số
            const vnPhoneRegex = /^(0[35789])[0-9]{8}$/;

            if (val === '') {
                if (showMsg) showPhoneError('Vui lòng nhập số điện thoại liên hệ.');
                return false;
            }

            if (!/^[0-9]+$/.test(val)) {
                if (showMsg) showPhoneError('Số điện thoại chỉ được chứa các chữ số.');
                return false;
            }

            if (val.length !== 10 || !vnPhoneRegex.test(val)) {
                if (showMsg) showPhoneError('Số điện thoại không hợp lệ (phải gồm 10 chữ số, bắt đầu bằng 03, 05, 07, 08, 09).');
                return false;
            }

            clearPhoneError();
            return true;
        }

        if (phoneInput) {
            // Tự động chặn và loại bỏ mọi ký tự không phải là số khi người dùng gõ hoặc paste
            phoneInput.addEventListener('input', function () {
                const cleaned = this.value.replace(/[^0-9]/g, '');
                if (this.value !== cleaned) {
                    this.value = cleaned;
                }
                if (phoneErrorMsg && !phoneErrorMsg.classList.contains('hidden')) {
                    validatePhone(true);
                }
            });

            phoneInput.addEventListener('blur', function () {
                if (this.value.trim() !== '') {
                    validatePhone(true);
                }
            });
        }

        if (paymentForm) {
            paymentForm.addEventListener('submit', function (e) {
                if (!validatePhone(true)) {
                    e.preventDefault();
                    if (phoneInput) {
                        phoneInput.focus();
                    }
                }
            });
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />