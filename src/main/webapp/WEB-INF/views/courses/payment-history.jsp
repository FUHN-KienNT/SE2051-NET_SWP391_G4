<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="min-h-[85vh] bg-surface py-10 px-4 sm:px-6 lg:px-8">
    <div class="max-w-6xl mx-auto">

        <!-- Breadcrumb & Header -->
        <div class="mb-8 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <nav class="flex text-xs text-text-secondary gap-2 mb-2">
                    <a href="${pageContext.request.contextPath}/home" class="hover:text-brand-700 transition">Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/my-enrollments" class="hover:text-brand-700 transition">Khóa học của tôi</a>
                    <span>/</span>
                    <span class="text-text-primary font-semibold">Lịch sử thanh toán</span>
                </nav>
                <h1 class="text-2xl sm:text-3xl font-black text-text-primary tracking-tight">Lịch Sử Giao Dịch & Đăng Ký</h1>
                <p class="text-text-secondary text-sm mt-1">Theo dõi các hóa đơn và trạng thái thanh toán khóa học của bạn</p>
            </div>

            <div class="flex items-center gap-3">
                <a href="${pageContext.request.contextPath}/my-enrollments" class="px-4 py-2 text-xs font-semibold rounded-xl bg-surface-card border border-border-default text-text-secondary hover:text-brand-700 transition shadow-sm">
                    <i class="fa-solid fa-graduation-cap mr-1"></i> Khóa học của tôi
                </a>
                <a href="${pageContext.request.contextPath}/courses" class="px-4 py-2 text-xs font-bold rounded-xl bg-brand-700 hover:bg-brand-800 text-white transition shadow-sm">
                    <i class="fa-solid fa-plus mr-1"></i> Khám phá khóa học
                </a>
            </div>
        </div>

        <!-- Bảng danh sách hóa đơn thanh toán -->
        <div class="bg-surface-card rounded-2xl border border-border-default shadow-sm overflow-hidden">
            <c:choose>
                <c:when test="${not empty payments}">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-surface border-b border-border-default text-[11px] uppercase tracking-wider text-text-secondary font-bold">
                                    <th class="py-4 px-6">Mã Giao Dịch</th>
                                    <th class="py-4 px-6">Khóa Học</th>
                                    <th class="py-4 px-6">Số Tiền</th>
                                    <th class="py-4 px-6">Cổng Thanh Toán</th>
                                    <th class="py-4 px-6">Thời Gian</th>
                                    <th class="py-4 px-6">Trạng Thái</th>
                                    <th class="py-4 px-6 text-center">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-border-default text-sm">
                                <c:forEach var="item" items="${payments}">
                                    <tr class="hover:bg-brand-50/20 transition">
                                        <!-- Mã GD -->
                                        <td class="py-4 px-6 font-mono text-xs text-text-primary font-medium">
                                            <c:choose>
                                                <c:when test="${not empty item.transactionId}">
                                                    <span class="bg-surface px-2 py-1 rounded border border-border-default">${item.transactionId}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-text-secondary italic text-xs">LH-${item.id.toString().substring(0, 8).toUpperCase()}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Khóa học -->
                                        <td class="py-4 px-6">
                                            <span class="font-bold text-text-primary line-clamp-1 max-w-xs">${item.courseTitle}</span>
                                        </td>

                                        <!-- Số tiền -->
                                        <td class="py-4 px-6 font-bold text-brand-700">
                                            <c:choose>
                                                <c:when test="${item.amount <= 0}">
                                                    <span class="text-emerald-600">Miễn Phí</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${item.amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Cổng TT -->
                                        <td class="py-4 px-6 text-xs text-text-secondary">
                                            <c:choose>
                                                <c:when test="${item.paymentMethodName != null}">
                                                    <span class="inline-flex items-center gap-1 font-medium text-text-primary">
                                                        <i class="fa-solid fa-credit-card text-brand-600"></i> ${item.paymentMethodName}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-text-secondary">Trực tuyến</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Ngày tạo -->
                                        <td class="py-4 px-6 text-xs text-text-secondary">
                                            <fmt:formatDate value="${item.enrolledAt}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>

                                        <!-- Trạng thái -->
                                        <td class="py-4 px-6">
                                            <c:choose>
                                                <c:when test="${item.paymentStatus eq 'paid'}">
                                                    <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                        <i class="fa-solid fa-circle-check text-[10px]"></i> Đã thanh toán
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200 animate-pulse">
                                                        <i class="fa-solid fa-clock text-[10px]"></i> Chờ thanh toán
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Nút thao tác -->
                                        <td class="py-4 px-6 text-center">
                                            <c:choose>
                                                <c:when test="${item.paymentStatus eq 'paid'}">
                                                    <a href="${pageContext.request.contextPath}/learn/course?id=${item.courseId}" class="inline-flex items-center gap-1 px-3 py-1.5 bg-brand-50 hover:bg-brand-100 text-brand-700 rounded-lg text-xs font-bold transition">
                                                        <i class="fa-solid fa-play text-[10px]"></i> Học ngay
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/enrollment?courseId=${item.courseId}" class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-brand-700 hover:bg-brand-800 text-white rounded-lg text-xs font-bold transition shadow-sm">
                                                        <i class="fa-solid fa-credit-card text-[10px]"></i> Thanh toán
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>

                <c:otherwise>
                    <!-- Empty State -->
                    <div class="py-16 px-6 text-center">
                        <div class="w-16 h-16 rounded-full bg-brand-50 text-brand-700 flex items-center justify-center mx-auto mb-4 text-2xl">
                            <i class="fa-regular fa-receipt"></i>
                        </div>
                        <h3 class="text-base font-bold text-text-primary mb-1">Bạn chưa có lịch sử giao dịch nào</h3>
                        <p class="text-xs text-text-secondary max-w-sm mx-auto mb-6">Khi bạn đăng ký và thanh toán các khóa học trên LearnHub, lịch sử và biên lai sẽ xuất hiện ở đây.</p>
                        <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-brand-700 hover:bg-brand-800 text-white text-xs font-bold transition shadow-md">
                            <i class="fa-solid fa-compass"></i> Khám phá khóa học ngay
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
