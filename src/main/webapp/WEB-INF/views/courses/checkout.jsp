<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="min-h-[85vh] bg-surface py-10 px-4 sm:px-6 lg:px-8">
    <div class="max-w-4xl mx-auto">

        <!-- Header -->
        <div class="text-center mb-8">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-brand-50 text-brand-700 border border-brand-100 mb-3">
                <i class="fa-solid fa-qrcode text-brand-600"></i> Thanh Toán Tự Động 24/7 Qua VietQR SePay
            </span>
            <h1 class="text-2xl sm:text-3xl font-black text-text-primary tracking-tight">Quét Mã QR Để Hoàn Tất Thanh Toán</h1>
            <p class="text-text-secondary text-sm mt-1">Mở ứng dụng ngân hàng bất kỳ để quét mã QR và chuyển khoản chính xác nội dung bên dưới</p>
        </div>

        <c:choose>
            <%-- ĐÃ THANH TOÁN THÀNH CÔNG --%>
            <c:when test="${registration.paymentStatus eq 'paid'}">
                <div class="bg-surface-card rounded-3xl border border-border-default shadow-xl p-8 sm:p-12 text-center max-w-lg mx-auto">
                    <div class="w-20 h-20 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-6 text-3xl shadow-inner animate-bounce">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <h2 class="text-2xl font-black text-text-primary mb-2">Đã Nhận Thanh Toán Thành Công!</h2>
                    <p class="text-text-secondary text-sm mb-6">Khóa học <strong class="text-text-primary">${registration.courseTitle}</strong> của bạn đã được kích hoạt ngay lập tức.</p>

                    <div class="space-y-3">
                        <a href="${pageContext.request.contextPath}/learn/course?id=${registration.courseId}" class="w-full flex items-center justify-center gap-2 py-3.5 px-6 font-bold text-white bg-brand-700 hover:bg-brand-800 rounded-xl shadow-md transition text-base">
                            <i class="fa-solid fa-play"></i> Bắt Đầu Học Ngay
                        </a>
                        <a href="${pageContext.request.contextPath}/my-enrollments" class="block w-full py-2.5 px-4 text-xs font-semibold text-text-secondary hover:text-brand-700 transition">
                            Vào trang Khóa học của tôi
                        </a>
                    </div>
                </div>
            </c:when>

            <%-- ĐANG CHỜ THANH TOÁN (PENDING) --%>
            <c:otherwise>
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">

                    <!-- CỘT TRÁI: Mã VietQR & Đồng hồ đếm ngược -->
                    <div class="lg:col-span-5 bg-surface-card rounded-3xl border border-border-default shadow-xl p-6 text-center">
                        <div class="flex items-center justify-between pb-4 border-b border-border-default mb-4 text-xs">
                            <span class="text-text-secondary">Thời gian giữ mã:</span>
                            <span id="countdown" class="font-mono font-bold text-rose-600 bg-rose-50 px-2.5 py-1 rounded-lg border border-rose-100 flex items-center gap-1">
                                <i class="fa-regular fa-clock"></i> 14:59
                            </span>
                        </div>

                        <!-- Khung ảnh QR VietQR SePay -->
                        <div class="p-3 bg-white rounded-2xl border-2 border-brand-200 inline-block shadow-sm relative group">
                            <img src="${qrImageUrl}" alt="Mã VietQR Thanh Toán" class="w-56 h-56 sm:w-64 sm:h-64 object-contain mx-auto rounded-lg">
                            <div class="absolute inset-0 bg-brand-900/10 rounded-2xl pointer-events-none"></div>
                        </div>

                        <p class="text-[11px] text-text-secondary mt-3 flex items-center justify-center gap-1">
                            <i class="fa-solid fa-rotate fa-spin text-brand-600"></i>
                            <span>Hệ thống đang tự động kiểm tra giao dịch...</span>
                        </p>

                        <!-- Box Demo Review Cho Giảng Viên (Giả lập thanh toán thành công) -->
                        <div class="mt-6 pt-5 border-t border-dashed border-border-default">
                            <div class="bg-amber-50 rounded-xl p-3 border border-amber-200 text-left mb-3">
                                <p class="text-xs font-bold text-amber-900 flex items-center gap-1.5 mb-1">
                                    <i class="fa-solid fa-flask text-amber-600"></i> Dành Cho Review & Demo:
                                </p>
                                <p class="text-[11px] text-amber-800 leading-relaxed">
                                    Khi review đồ án hoặc không có app ngân hàng, bấm nút bên dưới để mô phỏng sự kiện SePay Webhook nhận tiền thành công.
                                </p>
                            </div>
                            <form action="${pageContext.request.contextPath}/payment/checkout" method="post">
                                <input type="hidden" name="action" value="mock-pay">
                                <input type="hidden" name="regId" value="${registration.id}">
                                <button type="submit" class="w-full py-2.5 px-4 text-xs font-bold text-amber-900 bg-amber-200 hover:bg-amber-300 rounded-xl transition flex items-center justify-center gap-1.5 shadow-sm">
                                    <i class="fa-solid fa-bolt"></i> Giả Lập Đã Nhận Tiền Thành Công (Mock Pay)
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: Thông tin chuyển khoản & Hướng dẫn -->
                    <div class="lg:col-span-7 space-y-6">

                        <!-- Chi tiết chuyển khoản -->
                        <div class="bg-surface-card rounded-3xl border border-border-default shadow-xl p-6 sm:p-8">
                            <h2 class="text-lg font-bold text-text-primary pb-4 border-b border-border-default mb-5 flex items-center justify-between">
                                <span>Thông Tin Chuyển Khoản</span>
                                <span class="text-xs font-normal text-text-secondary">Ngân hàng 24/7</span>
                            </h2>

                            <div class="space-y-4 text-sm">
                                <!-- Ngân hàng -->
                                <div class="flex flex-col sm:flex-row sm:items-center justify-between p-3.5 bg-surface rounded-xl border border-border-default gap-1">
                                    <span class="text-text-secondary text-xs">Ngân hàng thụ hưởng:</span>
                                    <span class="font-bold text-text-primary">${bankName} (${bankCode})</span>
                                </div>

                                <!-- Chủ tài khoản -->
                                <div class="flex flex-col sm:flex-row sm:items-center justify-between p-3.5 bg-surface rounded-xl border border-border-default gap-1">
                                    <span class="text-text-secondary text-xs">Tên chủ tài khoản:</span>
                                    <span class="font-mono font-bold text-text-primary uppercase">${accountName}</span>
                                </div>

                                <!-- Số tài khoản -->
                                <div class="flex flex-col sm:flex-row sm:items-center justify-between p-3.5 bg-surface rounded-xl border border-border-default gap-1">
                                    <span class="text-text-secondary text-xs">Số tài khoản:</span>
                                    <div class="flex items-center gap-2">
                                        <span id="bankAccountText" class="font-mono font-black text-brand-700 text-base">${bankAccount}</span>
                                        <button type="button" onclick="copyToClipboard('${bankAccount}', this)" class="text-xs px-2.5 py-1 bg-brand-50 hover:bg-brand-100 text-brand-700 rounded-lg transition font-semibold">
                                            Sao chép
                                        </button>
                                    </div>
                                </div>

                                <!-- Số tiền -->
                                <div class="flex flex-col sm:flex-row sm:items-center justify-between p-3.5 bg-surface rounded-xl border border-border-default gap-1">
                                    <span class="text-text-secondary text-xs">Số tiền cần chuyển:</span>
                                    <div class="flex items-center gap-2">
                                        <span class="font-black text-emerald-600 text-lg">
                                            <fmt:formatNumber value="${amountVnd}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                        </span>
                                        <button type="button" onclick="copyToClipboard('${amountVnd}', this)" class="text-xs px-2.5 py-1 bg-brand-50 hover:bg-brand-100 text-brand-700 rounded-lg transition font-semibold">
                                            Sao chép
                                        </button>
                                    </div>
                                </div>

                                <!-- Nội dung chuyển khoản (QUAN TRỌNG NHẤT) -->
                                <div class="p-4 bg-brand-50/60 rounded-xl border-2 border-brand-200">
                                    <div class="flex items-center justify-between mb-1.5">
                                        <span class="text-xs font-bold text-brand-900 uppercase tracking-wider flex items-center gap-1">
                                            <i class="fa-solid fa-triangle-exclamation text-brand-600"></i> Nội dung chuyển khoản (Bắt buộc)
                                        </span>
                                        <button type="button" onclick="copyToClipboard('${transferCode}', this)" class="text-xs px-3 py-1 bg-brand-700 hover:bg-brand-800 text-white rounded-lg transition font-bold shadow-sm">
                                            Sao chép mã
                                        </button>
                                    </div>
                                    <div class="font-mono font-black text-brand-700 text-xl tracking-wider py-1 select-all" id="transferCodeText">
                                        ${transferCode}
                                    </div>
                                    <p class="text-[11px] text-brand-800 mt-1">
                                        Vui lòng giữ nguyên nội dung trên để SePay nhận diện đơn hàng và tự động kích hoạt khóa học trong 3 giây.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- Nút quay lại -->
                        <div class="flex items-center justify-between text-xs text-text-secondary px-2">
                            <a href="${pageContext.request.contextPath}/enrollment?courseId=${registration.courseId}" class="hover:text-brand-700 transition flex items-center gap-1">
                                <i class="fa-solid fa-arrow-left"></i> Chọn phương thức khác
                            </a>
                            <a href="${pageContext.request.contextPath}/my-enrollments" class="hover:text-brand-700 transition">
                                Để sau, về trang khóa học của tôi
                            </a>
                        </div>

                    </div>

                </div>
            </c:otherwise>
        </c:choose>

    </div>
</main>

<script>
    // Copy to clipboard
    function copyToClipboard(text, btn) {
        navigator.clipboard.writeText(text).then(function() {
            const originalText = btn.innerText;
            btn.innerText = 'Đã chép!';
            btn.classList.add('bg-emerald-600', 'text-white');
            setTimeout(function() {
                btn.innerText = originalText;
                btn.classList.remove('bg-emerald-600', 'text-white');
            }, 2000);
        });
    }

    // Countdown Timer (15 phút)
    let timeLeft = 15 * 60;
    const countdownEl = document.getElementById('countdown');
    if (countdownEl) {
        const timer = setInterval(function() {
            timeLeft--;
            if (timeLeft <= 0) {
                clearInterval(timer);
                countdownEl.innerText = 'Hết hạn';
                return;
            }
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            countdownEl.innerHTML = '<i class="fa-regular fa-clock"></i> ' +
                (minutes < 10 ? '0' : '') + minutes + ':' +
                (seconds < 10 ? '0' : '') + seconds;
        }, 1000);
    }

    // Polling tự động kiểm tra trạng thái thanh toán (mỗi 3 giây 1 lần)
    const regId = '${registration.id}';
    const isPaid = ${registration.paymentStatus eq 'paid'};
    if (regId && !isPaid) {
        const pollInterval = setInterval(function() {
            fetch('${pageContext.request.contextPath}/payment/checkout?action=check-status&regId=' + regId)
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    if (data && data.paid) {
                        clearInterval(pollInterval);
                        // Tự động reload để hiển thị giao diện thành công
                        window.location.reload();
                    }
                })
                .catch(function(err) {
                    console.log('Polling check error:', err);
                });
        }, 3000);
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
