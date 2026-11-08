<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<%-- 
=============================================================================
MÀN HÌNH CHI TIẾT ĐƠN ĐĂNG KÝ KHÓA HỌC (REGISTRATION DETAIL)
Dành cho Quản trị viên (Admin) / Quản lý (Manager):
- Bố cục 2 cột (12 cột lưới Tailwind):
  + Cột trái (8 cột):
    * Khối 1: Thông tin học viên (Họ tên, email, SĐT, trạng thái tài khoản).
    * Khối 2: Thông tin khóa học (Tên, danh mục, học phí niêm yết, link xem khóa học).
    * Khối 3: Chi tiết thanh toán & giao dịch (Số tiền, phương thức, mã Txn, ngày giờ).
    * Khối 4: Tiến độ học tập thực tế của học viên trong khóa học.
  + Cột phải (4 cột, Ghim sticky khi cuộn):
    * Form cập nhật trạng thái học (enrolled / completed / cancelled).
    * Form cập nhật tình trạng thanh toán (paid / pending / refunded).
    * Bảng hướng dẫn & chính sách quyền truy cập của học viên.
=============================================================================
--%>

<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <!-- Sidebar điều hướng quản lý -->
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="registrations" />
    </jsp:include>

    <!-- Khu vực nội dung chính -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-7xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">

            <!-- ============================================================= -->
            <!-- PHẦN 1: THÔNG BÁO PHẢN HỒI (ALERTS)                           -->
            <!-- ============================================================= -->
            <c:if test="${param.success eq 'updated'}">
                <div class="mb-6 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm flex items-center justify-between shadow-xs animate-fade-in">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-check text-status-success text-base" aria-hidden="true"></i>
                        <span class="font-medium">Cập nhật thông tin đăng ký thành công!</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" aria-label="Đóng thông báo" class="rounded-lg p-1.5 text-status-success hover:bg-emerald-100">
                        <i class="fa-solid fa-xmark text-xs" aria-hidden="true"></i>
                    </button>
                </div>
            </c:if>
            <c:if test="${param.error eq 'update_failed'}">
                <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-status-danger text-sm flex items-center justify-between shadow-xs">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base" aria-hidden="true"></i>
                        <span class="font-medium">Không thể cập nhật trạng thái đơn đăng ký. Vui lòng thử lại!</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" aria-label="Đóng thông báo" class="rounded-lg p-1.5 text-status-danger hover:bg-rose-100">
                        <i class="fa-solid fa-xmark text-xs" aria-hidden="true"></i>
                    </button>
                </div>
            </c:if>

            <!-- ============================================================= -->
            <!-- PHẦN 2: BREADCRUMB & TIÊU ĐỀ TRANG                             -->
            <!-- ============================================================= -->
            <div class="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <nav class="mb-1 text-xs font-semibold text-brand-700 tracking-wide uppercase flex items-center gap-1.5">
                        <a href="${pageContext.request.contextPath}${pageContext.request.servletPath}" class="hover:underline">Quản lý đăng ký</a>
                        <span class="text-text-secondary">/</span>
                        <span class="text-text-secondary">Chi tiết đơn</span>
                    </nav>
                    <div class="flex flex-wrap items-center gap-3">
                        <h1 class="text-2xl sm:text-3xl font-extrabold tracking-tight text-text-primary">
                            Chi Tiết Đơn Đăng Ký
                        </h1>
                        <span class="font-mono text-xs font-bold px-2.5 py-1 rounded-lg bg-surface border border-border-default text-text-secondary">
                            #${registration.id}
                        </span>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}${pageContext.request.servletPath}" class="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-border-default hover:bg-slate-100 text-xs sm:text-sm font-semibold text-text-secondary hover:text-text-primary transition self-start sm:self-auto">
                    <i class="fa-solid fa-arrow-left text-xs" aria-hidden="true"></i>
                    <span>Quay lại danh sách</span>
                </a>
            </div>

            <!-- ============================================================= -->
            <!-- PHẦN 3: BỐ CỤC NỘI DUNG 2 CỘT (MAIN LAYOUT GRID)              -->
            <!-- ============================================================= -->
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8 items-start">

                <!-- --------------------------------------------------------- -->
                <!-- CỘT TRÁI (8 CỘT): CHI TIẾT DỮ LIỆU ĐĂNG KÝ                 -->
                <!-- --------------------------------------------------------- -->
                <div class="lg:col-span-8 space-y-6">

                    <!-- KHỐI 1: THÔNG TIN HỌC VIÊN -->
                    <div class="bg-surface-card p-6 rounded-2xl border border-border-default shadow-xs">
                        <div class="flex items-center justify-between pb-4 mb-5 border-b border-border-default">
                            <h2 class="text-base font-bold text-text-primary flex items-center gap-2">
                                <i class="fa-solid fa-user-graduate text-brand-700" aria-hidden="true"></i>
                                <span>Thông Tin Học Viên</span>
                            </h2>
                            <c:if test="${not empty student}">
                                <span class="text-xs px-2.5 py-0.5 rounded-full font-medium ${student.status eq 'active' ? 'bg-emerald-50 text-status-success border border-emerald-200' : 'bg-slate-100 text-slate-600'}">
                                    ${student.status}
                                </span>
                            </c:if>
                        </div>

                        <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4 sm:gap-6">
                            <!-- Avatar chữ cái đầu -->
                            <div class="w-16 h-16 rounded-2xl bg-brand-50 border border-brand-100 text-brand-700 font-bold flex items-center justify-center text-2xl shrink-0 shadow-xs">
                                <c:choose>
                                    <c:when test="${not empty registration.userName}">
                                        ${fn:toUpperCase(fn:substring(registration.userName, 0, 1))}
                                    </c:when>
                                    <c:otherwise>U</c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Lưới thông tin liên hệ -->
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 flex-1 text-xs sm:text-sm">
                                <div>
                                    <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Họ và tên</p>
                                    <p class="font-bold text-text-primary mt-0.5">
                                        <c:choose>
                                            <c:when test="${not empty student.fullName}">${student.fullName}</c:when>
                                            <c:otherwise>${registration.userName}</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                                <div>
                                    <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Tên đăng nhập</p>
                                    <p class="font-semibold text-text-primary mt-0.5">${registration.userName}</p>
                                </div>
                                <div>
                                    <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Email liên hệ</p>
                                    <p class="font-semibold text-text-primary mt-0.5 break-all">${registration.userEmail}</p>
                                </div>
                                <div>
                                    <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Số điện thoại</p>
                                    <p class="font-semibold text-text-primary mt-0.5">
                                        <c:choose>
                                            <c:when test="${not empty student.phone}">${student.phone}</c:when>
                                            <c:otherwise><span class="text-text-secondary italic">Chưa cập nhật</span></c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- KHỐI 2: THÔNG TIN KHÓA HỌC -->
                    <div class="bg-surface-card p-6 rounded-2xl border border-border-default shadow-xs">
                        <div class="flex items-center justify-between pb-4 mb-5 border-b border-border-default">
                            <h2 class="text-base font-bold text-text-primary flex items-center gap-2">
                                <i class="fa-solid fa-book-open text-brand-700" aria-hidden="true"></i>
                                <span>Thông Tin Khóa Học</span>
                            </h2>
                            <c:if test="${not empty course}">
                                <a href="${pageContext.request.contextPath}/course-detail?id=${course.id}" target="_blank" class="text-xs font-semibold text-brand-700 hover:underline flex items-center gap-1">
                                    <span>Xem khóa học</span>
                                    <i class="fa-solid fa-arrow-up-right-from-square text-[10px]" aria-hidden="true"></i>
                                </a>
                            </c:if>
                        </div>

                        <div class="space-y-4 text-xs sm:text-sm">
                            <div>
                                <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Tên khóa học</p>
                                <h3 class="text-lg font-bold text-text-primary mt-0.5">${registration.courseTitle}</h3>
                            </div>

                            <c:if test="${not empty course}">
                                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2 border-t border-border-default/60">
                                    <div>
                                        <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Danh mục</p>
                                        <p class="font-semibold text-text-primary mt-0.5">${not empty course.categoryName ? course.categoryName : 'Chung'}</p>
                                    </div>
                                    <div>
                                        <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Học phí niêm yết</p>
                                        <p class="font-bold text-text-primary mt-0.5">
                                            <c:choose>
                                                <c:when test="${not empty course.price && course.price > 0}">
                                                    <fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </c:when>
                                                <c:otherwise><span class="text-status-success">Miễn phí</span></c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                    <div>
                                        <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Trạng thái khóa học</p>
                                        <p class="font-semibold text-text-primary mt-0.5 uppercase text-xs">${course.status}</p>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- KHỐI 3: CHI TIẾT THANH TOÁN & GIAO DỊCH -->
                    <div class="bg-surface-card p-6 rounded-2xl border border-border-default shadow-xs">
                        <div class="flex items-center justify-between pb-4 mb-5 border-b border-border-default">
                            <h2 class="text-base font-bold text-text-primary flex items-center gap-2">
                                <i class="fa-solid fa-receipt text-brand-700" aria-hidden="true"></i>
                                <span>Chi Tiết Thanh Toán &amp; Giao Dịch</span>
                            </h2>
                            <div>
                                <c:choose>
                                    <c:when test="${registration.paymentStatus eq 'paid'}">
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-emerald-50 text-status-success border border-emerald-200 uppercase">
                                            <i class="fa-solid fa-circle-check text-xs" aria-hidden="true"></i> Đã thanh toán
                                        </span>
                                    </c:when>
                                    <c:when test="${registration.paymentStatus eq 'refunded'}">
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-rose-50 text-status-danger border border-rose-200 uppercase">
                                            <i class="fa-solid fa-rotate-left text-xs" aria-hidden="true"></i> Đã hoàn tiền
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-amber-50 text-status-warning border border-amber-200 uppercase">
                                            <i class="fa-solid fa-clock text-xs" aria-hidden="true"></i> Chờ thanh toán
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 text-xs sm:text-sm">
                            <!-- Số tiền đăng ký -->
                            <div>
                                <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Số tiền đăng ký</p>
                                <p class="text-xl font-black text-brand-700 mt-0.5">
                                    <c:choose>
                                        <c:when test="${not empty registration.amount && registration.amount > 0}">
                                            <fmt:formatNumber value="${registration.amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                        </c:when>
                                        <c:otherwise>0 ₫ (Miễn phí)</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>

                            <!-- Phương thức thanh toán -->
                            <div>
                                <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Phương thức thanh toán</p>
                                <p class="font-bold text-text-primary mt-0.5">
                                    <c:choose>
                                        <c:when test="${not empty registration.paymentMethodName}">${registration.paymentMethodName}</c:when>
                                        <c:otherwise>Mặc định (Trực tuyến / Miễn phí)</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>

                            <!-- Mã giao dịch -->
                            <div>
                                <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Mã giao dịch (Txn ID)</p>
                                <p class="font-mono font-semibold text-text-primary mt-0.5 break-all">
                                    <c:choose>
                                        <c:when test="${not empty registration.transactionId}">${registration.transactionId}</c:when>
                                        <c:otherwise>--</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>

                            <!-- Thời điểm đăng ký -->
                            <div>
                                <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Thời điểm đăng ký</p>
                                <p class="font-semibold text-text-primary mt-0.5">
                                    <c:choose>
                                        <c:when test="${not empty registration.enrolledAt}">
                                            <fmt:formatDate value="${registration.enrolledAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                        </c:when>
                                        <c:otherwise>--</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>

                            <!-- Thời điểm thanh toán -->
                            <div>
                                <p class="text-text-secondary text-[11px] uppercase tracking-wider font-semibold">Thời điểm thanh toán</p>
                                <p class="font-semibold text-text-primary mt-0.5">
                                    <c:choose>
                                        <c:when test="${not empty registration.paidAt}">
                                            <fmt:formatDate value="${registration.paidAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                        </c:when>
                                        <c:otherwise>--</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- KHỐI 4: TIẾN ĐỘ HỌC TẬP -->
                    <div class="bg-surface-card p-6 rounded-2xl border border-border-default shadow-xs">
                        <div class="flex items-center justify-between pb-4 mb-4 border-b border-border-default">
                            <h2 class="text-base font-bold text-text-primary flex items-center gap-2">
                                <i class="fa-solid fa-chart-line text-brand-700" aria-hidden="true"></i>
                                <span>Tiến Độ Học Tập Của Học Viên</span>
                            </h2>
                            <span class="text-xs font-bold text-brand-700">${registration.progressPercent}% Hoàn thành</span>
                        </div>

                        <div class="space-y-3">
                            <div class="w-full bg-slate-100 rounded-full h-3 overflow-hidden">
                                <div class="bg-brand-600 h-3 rounded-full transition-all duration-300" style="width: ${registration.progressPercent}%"></div>
                            </div>
                            <div class="flex items-center justify-between text-xs text-text-secondary font-medium">
                                <span>Bắt đầu học</span>
                                <span>
                                    Trạng thái học: 
                                    <strong class="text-text-primary uppercase font-bold ml-1">${registration.status}</strong>
                                </span>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- --------------------------------------------------------- -->
                <!-- CỘT PHẢI (4 CỘT): FORM CẬP NHẬT TRẠNG THÁI & CHÍNH SÁCH    -->
                <!-- --------------------------------------------------------- -->
                <div class="lg:col-span-4 space-y-6 lg:sticky lg:top-24">

                    <!-- KHỐI 5: FORM CẬP NHẬT ĐƠN ĐĂNG KÝ -->
                    <div class="bg-surface-card p-6 rounded-2xl border border-border-default shadow-xs">
                        <div class="pb-4 mb-5 border-b border-border-default">
                            <h2 class="text-base font-bold text-text-primary flex items-center gap-2">
                                <i class="fa-solid fa-sliders text-brand-700" aria-hidden="true"></i>
                                <span>Cập Nhật Đơn Đăng Ký</span>
                            </h2>
                            <p class="text-xs text-text-secondary mt-1">
                                Điều chỉnh trạng thái học và tình trạng thanh toán của học viên.
                            </p>
                        </div>

                        <form action="${pageContext.request.contextPath}${pageContext.request.servletPath}" method="post" class="space-y-4">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="id" value="${registration.id}">

                            <!-- Lựa chọn trạng thái học -->
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-text-secondary mb-1.5">
                                    Trạng thái học (Course Status)
                                </label>
                                <select name="status" class="w-full px-3.5 py-2.5 border border-border-default rounded-xl text-xs sm:text-sm font-semibold text-text-primary bg-surface focus:outline-none focus:ring-2 focus:ring-brand-700 cursor-pointer">
                                    <option value="enrolled" ${registration.status eq 'enrolled' ? 'selected' : ''}>Đang học (Enrolled)</option>
                                    <option value="completed" ${registration.status eq 'completed' ? 'selected' : ''}>Hoàn thành (Completed)</option>
                                    <option value="cancelled" ${registration.status eq 'cancelled' ? 'selected' : ''}>Hủy bỏ (Cancelled)</option>
                                </select>
                            </div>

                            <!-- Lựa chọn tình trạng thanh toán -->
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-text-secondary mb-1.5">
                                    Tình trạng thanh toán (Payment Status)
                                </label>
                                <select name="paymentStatus" class="w-full px-3.5 py-2.5 border border-border-default rounded-xl text-xs sm:text-sm font-semibold text-text-primary bg-surface focus:outline-none focus:ring-2 focus:ring-brand-700 cursor-pointer">
                                    <option value="paid" ${registration.paymentStatus eq 'paid' ? 'selected' : ''}>Đã thanh toán (Paid)</option>
                                    <option value="pending" ${registration.paymentStatus eq 'pending' ? 'selected' : ''}>Chờ thanh toán (Pending)</option>
                                    <option value="refunded" ${registration.paymentStatus eq 'refunded' ? 'selected' : ''}>Hoàn tiền (Refunded)</option>
                                </select>
                            </div>

                            <!-- Nút Lưu thay đổi -->
                            <div class="pt-3">
                                <button type="submit" class="w-full py-3 bg-brand-700 hover:bg-brand-800 active:bg-brand-900 text-white font-bold rounded-xl text-sm transition shadow-sm flex items-center justify-center gap-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                    <i class="fa-solid fa-floppy-disk" aria-hidden="true"></i>
                                    <span>Lưu Thay Đổi</span>
                                </button>
                            </div>
                        </form>
                    </div>

                    <!-- KHỐI 6: LƯU Ý VỀ CHÍNH SÁCH QUYỀN TRUY CẬP -->
                    <div class="bg-surface p-5 rounded-2xl border border-border-default text-xs text-text-secondary space-y-2.5">
                        <div class="flex items-center gap-2 font-bold text-text-primary">
                            <i class="fa-solid fa-circle-info text-brand-700" aria-hidden="true"></i>
                            <span>Lưu ý về quyền truy cập:</span>
                        </div>
                        <ul class="space-y-1.5 pl-4 list-disc leading-relaxed">
                            <li>Trạng thái thanh toán <strong>Đã thanh toán (Paid)</strong> cho phép học viên truy cập toàn bộ bài học và làm bài thi.</li>
                            <li>Trạng thái <strong>Chờ thanh toán (Pending)</strong> sẽ chuyển hướng học viên đến trang thanh toán checkout.</li>
                            <li>Khi chọn <strong>Đã thanh toán</strong>, thời gian thanh toán sẽ được hệ thống tự động ghi nhận nếu trước đó chưa có.</li>
                        </ul>
                    </div>

                </div>

            </div>

        </main>
        <jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
    </div>
</div>
