<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<c:set var="registrationPath" value="${not empty registrationPath ? registrationPath : (not empty requestScope['jakarta.servlet.forward.servlet_path'] ? requestScope['jakarta.servlet.forward.servlet_path'] : ((sessionScope.currentUser.roleCode eq 'ROLE_MANAGER' or sessionScope.currentUser.roleCode eq 'manager') ? '/manager/registrations' : '/admin/registrations'))}" />

<%-- 
=============================================================================
MÀN HÌNH QUẢN LÝ DANH SÁCH ĐĂNG KÝ KHÓA HỌC (REGISTRATION LIST)
Dành cho Quản trị viên (Admin) / Quản lý (Manager):
- Thống kê tổng quan: Tổng đơn đăng ký, Đã thanh toán, Chờ duyệt, Tổng doanh thu.
- Bộ lọc và Tìm kiếm: Theo tên/email học viên, khóa học, trạng thái học, tình trạng thanh toán.
- Bảng danh sách chi tiết: Hiển thị học phí, tình trạng thanh toán, trạng thái học, thanh tiến độ.
- Phân trang dữ liệu (Pagination).
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
                        <span class="font-medium">Cập nhật trạng thái đăng ký thành công!</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" aria-label="Đóng thông báo" class="rounded-lg p-1.5 text-status-success hover:bg-emerald-100">
                        <i class="fa-solid fa-xmark text-xs" aria-hidden="true"></i>
                    </button>
                </div>
            </c:if>
            <c:if test="${param.error eq 'not_found'}">
                <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-status-danger text-sm flex items-center justify-between shadow-xs">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base" aria-hidden="true"></i>
                        <span class="font-medium">Không tìm thấy thông tin đăng ký yêu cầu!</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" aria-label="Đóng thông báo" class="rounded-lg p-1.5 text-status-danger hover:bg-rose-100">
                        <i class="fa-solid fa-xmark text-xs" aria-hidden="true"></i>
                    </button>
                </div>
            </c:if>

            <!-- ============================================================= -->
            <!-- PHẦN 2: TIÊU ĐỀ TRANG & BREADCRUMB                            -->
            <!-- ============================================================= -->
            <div class="mb-8 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
                <div>
                    <nav class="mb-2 text-xs font-semibold text-brand-700 tracking-wide uppercase flex items-center gap-1.5">
                        <span>Quản lý</span>
                        <span class="text-text-secondary">/</span>
                        <span>Đăng ký khóa học</span>
                    </nav>
                    <h1 class="text-2xl sm:text-3xl font-extrabold tracking-tight text-text-primary">Danh Sách Đăng Ký Khóa Học</h1>
                    <p class="mt-1 text-xs sm:text-sm text-text-secondary">Quản lý, tìm kiếm và giám sát các đơn đăng ký khóa học của học viên.</p>
                </div>
                <div class="text-xs text-text-secondary">
                    Tổng cộng: <strong class="text-text-primary font-bold text-sm">${totalCount}</strong> bản ghi
                </div>
            </div>

            <!-- ============================================================= -->
            <!-- PHẦN 3: LƯỚI 4 THẺ THỐNG KÊ TỔNG QUAN (STATS CARDS)           -->
            <!-- ============================================================= -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                <!-- Thẻ 1: Tổng số đơn đăng ký -->
                <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center text-xl shrink-0">
                        <i class="fa-solid fa-address-card" aria-hidden="true"></i>
                    </div>
                    <div class="min-w-0">
                        <p class="text-xs font-medium text-text-secondary uppercase tracking-wider">Tổng Đăng Ký</p>
                        <p class="text-2xl font-bold text-text-primary truncate">${stats.total != null ? stats.total : totalCount}</p>
                    </div>
                </div>

                <!-- Thẻ 2: Đã thanh toán -->
                <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-emerald-50 border border-emerald-200 text-status-success flex items-center justify-center text-xl shrink-0">
                        <i class="fa-solid fa-circle-check" aria-hidden="true"></i>
                    </div>
                    <div class="min-w-0">
                        <p class="text-xs font-medium text-text-secondary uppercase tracking-wider">Đã Thanh Toán</p>
                        <p class="text-2xl font-bold text-text-primary truncate">${stats.paidCount != null ? stats.paidCount : 0}</p>
                    </div>
                </div>

                <!-- Thẻ 3: Chờ thanh toán / duyệt -->
                <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-amber-50 border border-amber-200 text-status-warning flex items-center justify-center text-xl shrink-0">
                        <i class="fa-solid fa-clock" aria-hidden="true"></i>
                    </div>
                    <div class="min-w-0">
                        <p class="text-xs font-medium text-text-secondary uppercase tracking-wider">Chờ Thanh Toán</p>
                        <p class="text-2xl font-bold text-text-primary truncate">${stats.pendingCount != null ? stats.pendingCount : 0}</p>
                    </div>
                </div>

                <!-- Thẻ 4: Tổng doanh thu -->
                <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center text-xl shrink-0">
                        <i class="fa-solid fa-sack-dollar" aria-hidden="true"></i>
                    </div>
                    <div class="min-w-0">
                        <p class="text-xs font-medium text-text-secondary uppercase tracking-wider">Doanh Thu</p>
                        <p class="text-2xl font-bold text-brand-700 truncate">
                            <fmt:formatNumber value="${stats.totalRevenue != null ? stats.totalRevenue : 0}" type="number" maxFractionDigits="0"/> ₫
                        </p>
                    </div>
                </div>
            </div>

            <!-- ============================================================= -->
            <!-- PHẦN 4: THANH TÌM KIẾM VÀ BỘ LỌC (SEARCH & FILTER TOOLBAR)    -->
            <!-- ============================================================= -->
            <div class="bg-surface-card p-5 rounded-2xl border border-border-default shadow-xs mb-6">
                <form action="${pageContext.request.contextPath}${registrationPath}" method="get" class="grid grid-cols-1 md:grid-cols-12 gap-3">
                    <input type="hidden" name="pageSize" value="${pageSize}">

                    <!-- Ô tìm kiếm từ khóa -->
                    <div class="md:col-span-5 relative">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none" aria-hidden="true"></i>
                        <input type="text"
                               name="search"
                               value="${search}"
                               placeholder="Tìm theo học viên, email hoặc khóa học..."
                               class="w-full pl-9 pr-4 py-2.5 border border-border-default rounded-xl text-xs sm:text-sm font-medium text-text-primary placeholder-text-secondary focus:outline-none focus:ring-2 focus:ring-brand-700 bg-surface">
                    </div>

                    <!-- Lọc Trạng thái học -->
                    <div class="md:col-span-3 relative">
                        <select name="status" class="w-full px-3.5 py-2.5 border border-border-default rounded-xl text-xs sm:text-sm font-medium text-text-primary bg-surface focus:outline-none focus:ring-2 focus:ring-brand-700 cursor-pointer">
                            <option value="all" ${status eq 'all' or empty status ? 'selected' : ''}>Tất cả trạng thái học</option>
                            <option value="enrolled" ${status eq 'enrolled' ? 'selected' : ''}>Đang học (Enrolled)</option>
                            <option value="completed" ${status eq 'completed' ? 'selected' : ''}>Hoàn thành (Completed)</option>
                            <option value="cancelled" ${status eq 'cancelled' ? 'selected' : ''}>Đã hủy (Cancelled)</option>
                        </select>
                    </div>

                    <!-- Lọc Tình trạng thanh toán -->
                    <div class="md:col-span-2 relative">
                        <select name="paymentStatus" class="w-full px-3.5 py-2.5 border border-border-default rounded-xl text-xs sm:text-sm font-medium text-text-primary bg-surface focus:outline-none focus:ring-2 focus:ring-brand-700 cursor-pointer">
                            <option value="all" ${paymentStatus eq 'all' or empty paymentStatus ? 'selected' : ''}>Tất cả thanh toán</option>
                            <option value="paid" ${paymentStatus eq 'paid' ? 'selected' : ''}>Đã trả (Paid)</option>
                            <option value="pending" ${paymentStatus eq 'pending' ? 'selected' : ''}>Chờ duyệt (Pending)</option>
                            <option value="refunded" ${paymentStatus eq 'refunded' ? 'selected' : ''}>Hoàn tiền (Refunded)</option>
                        </select>
                    </div>

                    <!-- Nút Lọc và Đặt lại -->
                    <div class="md:col-span-2 flex items-center gap-2">
                        <button type="submit" class="flex-1 inline-flex items-center justify-center gap-1.5 px-4 py-2.5 bg-brand-700 hover:bg-brand-800 text-white rounded-xl font-bold text-xs sm:text-sm transition shadow-xs focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                            <i class="fa-solid fa-filter text-xs" aria-hidden="true"></i>
                            <span>Lọc</span>
                        </button>
                        <a href="${pageContext.request.contextPath}${registrationPath}" class="inline-flex items-center justify-center px-3 py-2.5 bg-surface hover:bg-slate-200 border border-border-default text-text-secondary hover:text-text-primary rounded-xl font-medium text-xs sm:text-sm transition" title="Đặt lại bộ lọc">
                            <i class="fa-solid fa-rotate-left" aria-hidden="true"></i>
                        </a>
                    </div>
                </form>
            </div>

            <!-- ============================================================= -->
            <!-- PHẦN 5: BẢNG DỮ LIỆU ĐĂNG KÝ (REGISTRATIONS TABLE)            -->
            <!-- ============================================================= -->
            <div class="bg-surface-card rounded-2xl border border-border-default shadow-xs overflow-hidden mb-6">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs sm:text-sm text-text-secondary divide-y divide-border-default">
                        <thead class="bg-surface text-text-primary uppercase text-[11px] font-bold tracking-wider select-none">
                            <tr>
                                <th class="px-5 py-3.5">Mã ĐK</th>
                                <th class="px-5 py-3.5">Học Viên</th>
                                <th class="px-5 py-3.5">Khóa Học</th>
                                <th class="px-5 py-3.5">Ngày Đăng Ký</th>
                                <th class="px-5 py-3.5">Học Phí</th>
                                <th class="px-5 py-3.5">Thanh Toán</th>
                                <th class="px-5 py-3.5">Trạng Thái Học</th>
                                <th class="px-5 py-3.5">Tiến Độ</th>
                                <th class="px-5 py-3.5 text-right">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-border-default bg-surface-card">
                            <c:choose>
                                <c:when test="${not empty registrations}">
                                    <c:forEach var="reg" items="${registrations}">
                                        <tr class="hover:bg-brand-50/20 transition-colors">
                                            <!-- Mã đăng ký -->
                                            <td class="px-5 py-4 whitespace-nowrap font-mono text-xs font-semibold text-text-primary">
                                                <a href="${pageContext.request.contextPath}${registrationPath}?action=detail&id=${reg.id}" class="text-brand-700 hover:underline inline-flex items-center gap-1" title="${reg.id}">
                                                    <i class="fa-solid fa-hashtag text-[10px]" aria-hidden="true"></i>
                                                    ${fn:substring(reg.id, 0, 8)}
                                                </a>
                                            </td>

                                            <!-- Thông tin học viên -->
                                            <td class="px-5 py-4 whitespace-nowrap">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-8 h-8 rounded-full bg-brand-50 border border-brand-100 text-brand-700 font-bold flex items-center justify-center text-xs shrink-0">
                                                        <c:choose>
                                                            <c:when test="${not empty reg.userName}">
                                                                ${fn:toUpperCase(fn:substring(reg.userName, 0, 1))}
                                                            </c:when>
                                                            <c:otherwise>HV</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="min-w-0">
                                                        <p class="font-semibold text-text-primary text-xs sm:text-sm truncate max-w-[160px]">${reg.userName}</p>
                                                        <p class="text-[11px] text-text-secondary truncate max-w-[160px]">${reg.userEmail}</p>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- Tên khóa học -->
                                            <td class="px-5 py-4">
                                                <p class="font-medium text-text-primary text-xs sm:text-sm line-clamp-2 max-w-[220px]" title="${reg.courseTitle}">
                                                    ${reg.courseTitle}
                                                </p>
                                            </td>

                                            <!-- Ngày đăng ký -->
                                            <td class="px-5 py-4 whitespace-nowrap text-xs text-text-secondary">
                                                <c:choose>
                                                    <c:when test="${not empty reg.enrolledAt}">
                                                        <fmt:formatDate value="${reg.enrolledAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </c:when>
                                                    <c:otherwise>--</c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Số tiền / Học phí -->
                                            <td class="px-5 py-4 whitespace-nowrap font-semibold text-text-primary">
                                                <c:choose>
                                                    <c:when test="${not empty reg.amount && reg.amount > 0}">
                                                        <fmt:formatNumber value="${reg.amount}" type="number" maxFractionDigits="0"/> ₫
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-status-success font-medium">Miễn phí</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Trạng thái thanh toán -->
                                            <td class="px-5 py-4 whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${reg.paymentStatus eq 'paid'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-status-success border border-emerald-200">
                                                            <i class="fa-solid fa-check text-[10px]" aria-hidden="true"></i> Đã trả
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${reg.paymentStatus eq 'refunded'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-50 text-status-danger border border-rose-200">
                                                            <i class="fa-solid fa-rotate-left text-[10px]" aria-hidden="true"></i> Hoàn tiền
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-status-warning border border-amber-200">
                                                            <i class="fa-solid fa-clock text-[10px]" aria-hidden="true"></i> Chờ duyệt
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Trạng thái học -->
                                            <td class="px-5 py-4 whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${reg.status eq 'completed'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-brand-50 text-brand-700 border border-brand-100">
                                                            <i class="fa-solid fa-flag-checkered text-[10px]" aria-hidden="true"></i> Hoàn thành
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${reg.status eq 'cancelled'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                                                            <i class="fa-solid fa-ban text-[10px]" aria-hidden="true"></i> Đã hủy
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${reg.paymentStatus eq 'pending' && not empty reg.amount && reg.amount > 0}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-status-warning border border-amber-200">
                                                            <i class="fa-solid fa-hourglass-half text-[10px]" aria-hidden="true"></i> Chờ kích hoạt
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-blue-50 text-blue-700 border border-blue-200">
                                                            <i class="fa-solid fa-book-open-reader text-[10px]" aria-hidden="true"></i> Đang học
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Thanh tiến độ học tập (%) -->
                                            <td class="px-5 py-4 whitespace-nowrap">
                                                <div class="flex items-center gap-2">
                                                    <div class="w-16 bg-slate-100 rounded-full h-1.5 overflow-hidden">
                                                        <div class="bg-brand-600 h-1.5 rounded-full" style="width: ${reg.progressPercent}%"></div>
                                                    </div>
                                                    <span class="text-xs font-semibold text-text-primary">${reg.progressPercent}%</span>
                                                </div>
                                            </td>

                                            <!-- Nút Xem chi tiết -->
                                            <td class="px-5 py-4 whitespace-nowrap text-right">
                                                <a href="${pageContext.request.contextPath}${registrationPath}?action=detail&id=${reg.id}" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-border-default hover:border-brand-700 hover:text-brand-700 font-semibold text-xs transition bg-surface hover:bg-brand-50">
                                                    <i class="fa-regular fa-eye text-xs" aria-hidden="true"></i>
                                                    <span>Chi tiết</span>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" class="px-6 py-16 text-center">
                                            <div class="w-16 h-16 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center text-2xl mx-auto mb-3">
                                                <i class="fa-solid fa-folder-open" aria-hidden="true"></i>
                                            </div>
                                            <p class="text-base font-bold text-text-primary">Không có dữ liệu đăng ký</p>
                                            <p class="text-xs text-text-secondary mt-1">Không tìm thấy bản ghi đăng ký nào phù hợp với bộ lọc hiện tại.</p>
                                            <a href="${pageContext.request.contextPath}${registrationPath}" class="inline-flex items-center gap-1.5 mt-4 px-4 py-2 bg-brand-700 hover:bg-brand-800 text-white rounded-xl text-xs font-semibold transition">
                                                <i class="fa-solid fa-rotate-left" aria-hidden="true"></i> Xóa bộ lọc
                                            </a>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- ========================================================= -->
                <!-- PHẦN 6: THANH PHÂN TRANG (PAGINATION)                     -->
                <!-- ========================================================= -->
                <c:if test="${totalPages > 1}">
                    <div class="px-5 py-4 border-t border-border-default bg-surface flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-text-secondary">
                        <div>
                            Trang <strong class="text-text-primary font-bold">${currentPage}</strong> / ${totalPages} (Tổng số ${totalCount} bản ghi)
                        </div>

                        <div class="flex items-center gap-1">
                            <!-- Nút trang trước -->
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}${registrationPath}?page=${currentPage - 1}&search=${search}&status=${status}&paymentStatus=${paymentStatus}&pageSize=${pageSize}" class="px-3 py-1.5 rounded-lg border border-border-default hover:bg-slate-200 transition font-medium">
                                    <i class="fa-solid fa-chevron-left text-[10px]" aria-hidden="true"></i> Trước
                                </a>
                            </c:if>

                            <!-- Các số trang lân cận -->
                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <c:if test="${p >= currentPage - 2 and p <= currentPage + 2}">
                                    <a href="${pageContext.request.contextPath}${registrationPath}?page=${p}&search=${search}&status=${status}&paymentStatus=${paymentStatus}&pageSize=${pageSize}" class="px-3 py-1.5 rounded-lg border text-xs font-semibold transition ${p eq currentPage ? 'bg-brand-700 text-white border-brand-700 shadow-xs' : 'border-border-default hover:bg-slate-200 text-text-primary'}">
                                        ${p}
                                    </a>
                                </c:if>
                            </c:forEach>

                            <!-- Nút trang sau -->
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}${registrationPath}?page=${currentPage + 1}&search=${search}&status=${status}&paymentStatus=${paymentStatus}&pageSize=${pageSize}" class="px-3 py-1.5 rounded-lg border border-border-default hover:bg-slate-200 transition font-medium">
                                    Sau <i class="fa-solid fa-chevron-right text-[10px]" aria-hidden="true"></i>
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>

        </main>
        <jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
    </div>
</div>
