<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">

    <!-- Page Title & Header -->
    <div class="mb-8">
        <h1 class="text-3xl font-black text-slate-900 tracking-tight">Khám Phá Khóa Học</h1>
        <p class="text-slate-500 mt-1">Nâng cao kỹ năng với các khóa học chất lượng cao từ các chuyên gia hàng đầu</p>
    </div>

    <!-- Filter Bar -->
    <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm mb-8">
        <form action="${pageContext.request.contextPath}/courses" method="get" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
            
            <!-- Search Keyword Input -->
            <div class="md:col-span-6 relative">
                <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </div>
                <input type="text" name="search" value="${search}" placeholder="Tìm kiếm theo tên khóa học hoặc nội dung..." 
                       class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-300 rounded-xl focus:bg-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm transition">
            </div>

            <!-- Category Select Dropdown -->
            <div class="md:col-span-4">
                <select name="categoryId" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-xl focus:bg-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm transition cursor-pointer">
                    <option value="">Tất cả danh mục</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${categoryId eq cat.id.toString() ? 'selected' : ''}>${cat.name}</option>
                    </c:forEach>
                </select>
            </div>

            <!-- Actions -->
            <div class="md:col-span-2 flex space-x-2">
                <button type="submit" class="flex-1 py-2.5 px-4 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-sm shadow-sm transition flex items-center justify-center gap-1.5">
                    <i class="fa-solid fa-filter"></i> Tìm Kiếm
                </button>
                <c:if test="${not empty search || not empty categoryId}">
                    <a href="${pageContext.request.contextPath}/courses" title="Xóa bộ lọc" class="py-2.5 px-3.5 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-xl font-semibold text-sm transition flex items-center justify-center">
                        <i class="fa-solid fa-rotate-left"></i>
                    </a>
                </c:if>
            </div>
        </form>

        <!-- Active Filter Indicator -->
        <div class="mt-4 pt-4 border-t border-slate-100 flex flex-wrap items-center justify-between gap-2 text-xs text-slate-500">
            <div>
                <span>Tìm thấy <strong class="text-blue-600 text-sm">${totalCourses}</strong> khóa học</span>
                <c:if test="${not empty search}">
                    <span class="ml-2 px-2 py-0.5 rounded bg-blue-50 text-blue-700 border border-blue-200">
                        Từ khóa: "${search}"
                    </span>
                </c:if>
            </div>

            <c:if test="${not empty search || not empty categoryId}">
                <a href="${pageContext.request.contextPath}/courses" class="text-blue-600 hover:underline font-medium">
                    <i class="fa-solid fa-xmark mr-1"></i> Xóa tất cả bộ lọc
                </a>
            </c:if>
        </div>
    </div>

    <!-- Courses Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <c:choose>
            <c:when test="${not empty courses}">
                <c:forEach var="c" items="${courses}">
                    <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 flex flex-col group h-full">
                        <!-- Image & Category Badge -->
                        <div class="relative h-48 bg-slate-100 overflow-hidden">
                            <img src="${not empty c.thumbnailUrl ? c.thumbnailUrl : (not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800')}" 
                                 alt="${c.title}" 
                                 class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500">
                            <span class="absolute top-3 right-3 px-2.5 py-1 rounded-full text-xs font-bold bg-white/90 backdrop-blur-sm text-blue-700 shadow-sm border border-slate-100">
                                ${not empty c.categoryName ? c.categoryName : 'Khóa học'}
                            </span>
                        </div>

                        <!-- Card Body -->
                        <div class="p-6 flex-grow flex flex-col justify-between">
                            <div>
                                <!-- Expert / Instructor info -->
                                <c:if test="${not empty c.expertName}">
                                    <p class="text-xs text-slate-400 font-medium mb-1.5 flex items-center gap-1.5">
                                        <i class="fa-solid fa-user-tie text-blue-500"></i> ${c.expertName}
                                    </p>
                                </c:if>

                                <!-- Title -->
                                <h3 class="font-bold text-lg text-slate-900 group-hover:text-blue-600 transition-colors line-clamp-2 mb-2 leading-snug">
                                    <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}">
                                        ${c.title}
                                    </a>
                                </h3>

                                <!-- Description -->
                                <p class="text-sm text-slate-500 line-clamp-2 mb-4 leading-relaxed">${c.description}</p>
                            </div>

                            <!-- Footer: Price & CTA -->
                            <div class="pt-4 border-t border-slate-100 flex items-center justify-between mt-auto">
                                <div>
                                    <span class="text-xs text-slate-400 block">Học phí</span>
                                    <span class="text-lg font-black text-blue-600">
                                        <c:choose>
                                            <c:when test="${c.price <= 0}">Miễn phí</c:when>
                                            <c:otherwise><fmt:formatNumber value="${c.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" 
                                   class="inline-flex items-center gap-1.5 px-4 py-2 text-sm font-bold text-blue-600 bg-blue-50 hover:bg-blue-600 hover:text-white rounded-xl transition-all shadow-sm">
                                    <span>Xem chi tiết</span>
                                    <i class="fa-solid fa-arrow-right text-xs"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-span-full text-center py-20 bg-white rounded-2xl border border-slate-200">
                    <div class="w-16 h-16 bg-slate-100 text-slate-400 rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-800 mb-1">Không tìm thấy khóa học nào phù hợp</h3>
                    <p class="text-sm text-slate-500 max-w-md mx-auto mb-6">Hãy thử thay đổi từ khóa tìm kiếm hoặc chọn danh mục khác để xem kết quả.</p>
                    <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold rounded-xl transition shadow-sm">
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
                       class="px-4 py-2 bg-white border border-slate-300 rounded-xl text-sm font-semibold text-slate-700 hover:bg-slate-50 transition shadow-sm">
                        <i class="fa-solid fa-chevron-left mr-1"></i> Trước
                    </a>
                </c:when>
                <c:otherwise>
                    <span class="px-4 py-2 bg-slate-100 border border-slate-200 rounded-xl text-sm font-semibold text-slate-400 cursor-not-allowed">
                        <i class="fa-solid fa-chevron-left mr-1"></i> Trước
                    </span>
                </c:otherwise>
            </c:choose>

            <!-- Page Numbers -->
            <c:forEach begin="1" end="${totalPages}" var="i">
                <c:choose>
                    <c:when test="${i eq currentPage}">
                        <span class="w-10 h-10 flex items-center justify-center bg-blue-600 text-white rounded-xl text-sm font-bold shadow-sm">
                            ${i}
                        </span>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/courses?page=${i}&search=${search}&categoryId=${categoryId}" 
                           class="w-10 h-10 flex items-center justify-center bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 rounded-xl text-sm font-semibold transition shadow-sm">
                            ${i}
                        </a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>

            <!-- Next Button -->
            <c:choose>
                <c:when test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/courses?page=${currentPage + 1}&search=${search}&categoryId=${categoryId}" 
                       class="px-4 py-2 bg-white border border-slate-300 rounded-xl text-sm font-semibold text-slate-700 hover:bg-slate-50 transition shadow-sm">
                        Sau <i class="fa-solid fa-chevron-right ml-1"></i>
                    </a>
                </c:when>
                <c:otherwise>
                    <span class="px-4 py-2 bg-slate-100 border border-slate-200 rounded-xl text-sm font-semibold text-slate-400 cursor-not-allowed">
                        Sau <i class="fa-solid fa-chevron-right ml-1"></i>
                    </span>
                </c:otherwise>
            </c:choose>
        </div>
    </c:if>

</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />