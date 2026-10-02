<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="LearnHub | Danh Sách Khóa Học" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow bg-surface py-10 sm:py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">

        <!-- Page Header -->
        <div class="mb-8">
            <p class="text-sm font-semibold uppercase tracking-wide text-brand-700 mb-2">Khám phá tri thức</p>
            <h1 class="text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-text-primary">Tất Cả Khóa Học</h1>
            <p class="text-text-secondary mt-3 max-w-2xl text-base">Nâng cao kỹ năng chuyên môn với các khóa học thực chiến được xây dựng bởi đội ngũ giảng viên giàu kinh nghiệm.</p>
        </div>

        <!-- Filter Bar -->
        <div class="bg-surface-card p-5 sm:p-6 rounded-2xl border border-border-default shadow-sm mb-10">
            <form action="${pageContext.request.contextPath}/courses" method="get" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
                
                <!-- Search Keyword Input -->
                <div class="md:col-span-6 relative">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-secondary">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </div>
                    <input type="text" name="search" value="${search}" placeholder="Tìm kiếm theo tên khóa học hoặc nội dung..." 
                           class="w-full pl-10 pr-4 py-2.5 bg-surface border border-border-default rounded-xl focus:bg-surface-card focus:ring-2 focus:ring-brand-700 focus:border-brand-700 text-sm text-text-primary transition outline-none">
                </div>

                <!-- Category Select Dropdown -->
                <div class="md:col-span-4">
                    <select name="categoryId" class="w-full px-3.5 py-2.5 bg-surface border border-border-default rounded-xl focus:bg-surface-card focus:ring-2 focus:ring-brand-700 focus:border-brand-700 text-sm text-text-primary transition cursor-pointer outline-none">
                        <option value="">Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}" ${categoryId eq cat.id.toString() ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Action Buttons -->
                <div class="md:col-span-2 flex space-x-2">
                    <button type="submit" class="flex-1 py-2.5 px-4 bg-brand-700 hover:bg-brand-800 text-white rounded-xl font-semibold text-sm shadow-sm transition flex items-center justify-center gap-1.5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                        <i class="fa-solid fa-filter"></i> Tìm kiếm
                    </button>
                    <c:if test="${not empty search || not empty categoryId}">
                        <a href="${pageContext.request.contextPath}/courses" title="Xóa bộ lọc" class="py-2.5 px-3.5 bg-surface hover:bg-slate-200 text-text-secondary rounded-xl font-semibold text-sm transition flex items-center justify-center border border-border-default">
                            <i class="fa-solid fa-rotate-left"></i>
                        </a>
                    </c:if>
                </div>
            </form>

            <!-- Active Filter Status -->
            <div class="mt-4 pt-4 border-t border-border-default flex flex-wrap items-center justify-between gap-3 text-xs text-text-secondary">
                <div class="flex items-center gap-2">
                    <span>Tìm thấy <strong class="text-brand-700 font-bold text-sm">${totalCourses}</strong> khóa học</span>
                    <c:if test="${not empty search}">
                        <span class="px-2.5 py-0.5 rounded-full bg-brand-50 text-brand-700 border border-brand-100 font-medium">
                            Từ khóa: "${search}"
                        </span>
                    </c:if>
                </div>

                <c:if test="${not empty search || not empty categoryId}">
                    <a href="${pageContext.request.contextPath}/courses" class="text-brand-700 hover:text-brand-800 hover:underline font-semibold flex items-center gap-1">
                        <i class="fa-solid fa-xmark"></i> Xóa tất cả bộ lọc
                    </a>
                </c:if>
            </div>
        </div>

        <!-- Courses Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
            <c:choose>
                <c:when test="${not empty courses}">
                    <c:forEach var="c" items="${courses}">
                        <div class="bg-surface-card rounded-2xl border border-border-default overflow-hidden shadow-sm hover:shadow-md hover:border-brand-100 transition-all duration-300 flex flex-col group h-full">
                            <!-- Thumbnail & Category Tag -->
                            <div class="relative h-48 bg-brand-50 overflow-hidden flex items-center justify-center">
                                <i class="fa-solid fa-book-open text-4xl text-brand-700" aria-hidden="true"></i>
                                <img src="${not empty c.thumbnailUrl ? c.thumbnailUrl : (not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800')}" 
                                     alt="${c.title}" 
                                     loading="lazy"
                                     onerror="this.hidden=true"
                                     class="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                <span class="absolute top-3 right-3 px-3 py-1 rounded-full text-xs font-bold bg-white/95 backdrop-blur-sm text-brand-700 shadow-sm border border-brand-100">
                                    ${not empty c.categoryName ? c.categoryName : 'Khóa học'}
                                </span>
                            </div>

                            <!-- Card Content -->
                            <div class="p-5 sm:p-6 flex-grow flex flex-col justify-between">
                                <div>
                                    <!-- Instructor -->
                                    <c:if test="${not empty c.expertName}">
                                        <p class="text-xs text-brand-700 font-semibold uppercase tracking-wider mb-2 flex items-center gap-1.5">
                                            <i class="fa-solid fa-user-tie"></i> ${c.expertName}
                                        </p>
                                    </c:if>

                                    <!-- Course Title -->
                                    <h3 class="font-bold text-lg text-text-primary group-hover:text-brand-700 transition-colors line-clamp-2 mb-2 leading-snug">
                                        <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}">
                                            ${c.title}
                                        </a>
                                    </h3>

                                    <!-- Description -->
                                    <p class="text-sm text-text-secondary line-clamp-2 mb-4 leading-relaxed">${c.description}</p>

                                    <!-- Module & Lesson info -->
                                    <p class="text-xs text-text-secondary font-medium mb-4 flex items-center gap-1.5">
                                        <i class="fa-solid fa-layer-group text-brand-600"></i> ${c.moduleCount} chương <span class="text-slate-300">·</span> ${c.lessonCount} bài học
                                    </p>
                                </div>

                                <!-- Card Footer: Price & CTA -->
                                <div class="pt-4 border-t border-border-default flex items-center justify-between mt-auto">
                                    <div>
                                        <span class="text-[11px] text-text-secondary uppercase tracking-wider block font-semibold">Học phí</span>
                                        <span class="text-lg font-bold text-text-primary">
                                            <c:choose>
                                                <c:when test="${c.price <= 0}"><span class="text-brand-700">Miễn phí</span></c:when>
                                                <c:otherwise><fmt:formatNumber value="${c.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" 
                                       class="inline-flex items-center gap-1.5 px-4 py-2 text-sm font-semibold text-brand-700 bg-brand-50 hover:bg-brand-700 hover:text-white rounded-xl transition-all">
                                        <span>Xem chi tiết</span>
                                        <i class="fa-solid fa-arrow-right text-xs"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="col-span-full text-center py-20 bg-surface-card rounded-2xl border border-border-default">
                        <div class="w-16 h-16 bg-brand-50 text-brand-700 rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                            <i class="fa-solid fa-book-open"></i>
                        </div>
                        <h3 class="text-lg font-bold text-text-primary mb-1">Không tìm thấy khóa học nào phù hợp</h3>
                        <p class="text-sm text-text-secondary max-w-md mx-auto mb-6">Hãy thử thay đổi từ khóa tìm kiếm hoặc chọn danh mục khác để xem kết quả.</p>
                        <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center gap-2 px-5 py-2.5 bg-brand-700 hover:bg-brand-800 text-white text-sm font-semibold rounded-xl transition shadow-sm">
                            <i class="fa-solid fa-rotate-left"></i> Xem tất cả khóa học
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="mt-12 flex justify-center items-center gap-2">
                <!-- Prev Button -->
                <c:choose>
                    <c:when test="${currentPage > 1}">
                        <a href="${pageContext.request.contextPath}/courses?page=${currentPage - 1}&search=${search}&categoryId=${categoryId}" 
                           class="px-4 py-2 bg-surface-card border border-border-default rounded-xl text-sm font-semibold text-text-primary hover:bg-brand-50 hover:text-brand-700 transition shadow-sm">
                            <i class="fa-solid fa-chevron-left mr-1"></i> Trước
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="px-4 py-2 bg-surface border border-border-default rounded-xl text-sm font-semibold text-slate-300 cursor-not-allowed">
                            <i class="fa-solid fa-chevron-left mr-1"></i> Trước
                        </span>
                    </c:otherwise>
                </c:choose>

                <!-- Page Numbers -->
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:choose>
                        <c:when test="${i eq currentPage}">
                            <span class="w-10 h-10 flex items-center justify-center bg-brand-700 text-white rounded-xl text-sm font-bold shadow-sm">
                                ${i}
                            </span>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/courses?page=${i}&search=${search}&categoryId=${categoryId}" 
                               class="w-10 h-10 flex items-center justify-center bg-surface-card border border-border-default hover:bg-brand-50 text-text-primary hover:text-brand-700 rounded-xl text-sm font-semibold transition shadow-sm">
                                ${i}
                            </a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <!-- Next Button -->
                <c:choose>
                    <c:when test="${currentPage < totalPages}">
                        <a href="${pageContext.request.contextPath}/courses?page=${currentPage + 1}&search=${search}&categoryId=${categoryId}" 
                           class="px-4 py-2 bg-surface-card border border-border-default rounded-xl text-sm font-semibold text-text-primary hover:bg-brand-50 hover:text-brand-700 transition shadow-sm">
                            Sau <i class="fa-solid fa-chevron-right ml-1"></i>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="px-4 py-2 bg-surface border border-border-default rounded-xl text-sm font-semibold text-slate-300 cursor-not-allowed">
                            Sau <i class="fa-solid fa-chevron-right ml-1"></i>
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />