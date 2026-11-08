<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<c:set var="regBasePath" value="${not empty basePath ? basePath : (not empty registrationPath ? registrationPath : '/manager/registrations')}" />

<%-- 
=============================================================================
MÀN HÌNH CHI TIẾT ĐƠN ĐĂNG KÝ KHÓA HỌC (REGISTRATION DETAIL)
Dành cho Quản trị viên (Admin) / Quản lý (Manager):
- Bố cục:
  + Hàng 1 (2 cột):
    * Khối 1: Thông tin học viên (Họ tên, email, SĐT, trạng thái tài khoản).
    * Khối 2: Thông tin khóa học (Tên, danh mục, học phí niêm yết, link xem khóa học).
  + Hàng 2:
    * Khối 3: Chi tiết thanh toán & giao dịch (Số tiền, phương thức, mã Txn, ngày giờ).
  + Hàng 3:
    * Khối 4: Tiến độ học tập thực tế của học viên trong khóa học.
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
            <!-- PHẦN 1: BREADCRUMB & TIÊU ĐỀ TRANG                            -->
            <!-- ============================================================= -->
            <div class="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <nav class="mb-1 text-xs font-semibold text-brand-700 tracking-wide uppercase flex items-center gap-1.5">
                        <a href="${pageContext.request.contextPath}${regBasePath}" class="hover:underline">Quản lý đăng ký</a>
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

                <a href="${pageContext.request.contextPath}${regBasePath}" class="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-border-default hover:bg-slate-100 text-xs sm:text-sm font-semibold text-text-secondary hover:text-text-primary transition self-start sm:self-auto">
                    <i class="fa-solid fa-arrow-left text-xs" aria-hidden="true"></i>
                    <span>Quay lại danh sách</span>
                </a>
            </div>

            <!-- ============================================================= -->
            <!-- PHẦN 2: BỐ CỤC NỘI DUNG CHI TIẾT ĐƠN ĐĂNG KÝ                  -->
            <!-- ============================================================= -->
            <div class="space-y-6">

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

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
                                <a href="${pageContext.request.contextPath}/courses?action=detail&id=${course.id}" target="_blank" class="text-xs font-semibold text-brand-700 hover:underline flex items-center gap-1">
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
                                                    <fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> ₫
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
                                <c:when test="${registration.paymentStatus eq 'failed' or registration.paymentStatus eq 'refunded'}">
                                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-rose-50 text-status-danger border border-rose-200 uppercase">
                                        <i class="fa-solid fa-ban text-xs" aria-hidden="true"></i> Đã hủy / Lỗi
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
                                        <fmt:formatNumber value="${registration.amount}" type="number" maxFractionDigits="0"/> ₫
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
                                <c:choose>
                                    <c:when test="${registration.status eq 'completed'}">
                                        <strong class="text-brand-700 font-bold ml-1">Hoàn thành</strong>
                                    </c:when>
                                    <c:when test="${registration.status eq 'cancelled'}">
                                        <strong class="text-slate-600 font-bold ml-1">Đã hủy</strong>
                                    </c:when>
                                    <c:when test="${registration.paymentStatus eq 'pending' && not empty registration.amount && registration.amount > 0}">
                                        <strong class="text-status-warning font-bold ml-1">Chờ kích hoạt (Chưa thanh toán)</strong>
                                    </c:when>
                                    <c:when test="${registration.paymentStatus eq 'refunded'}">
                                        <strong class="text-status-danger font-bold ml-1">Đã hoàn tiền</strong>
                                    </c:when>
                                    <c:otherwise>
                                        <strong class="text-text-primary font-bold ml-1">Đang học</strong>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

            </div>

        </main>
        <jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
    </div>
</div>
