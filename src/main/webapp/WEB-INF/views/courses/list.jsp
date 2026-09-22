<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <!-- Filter Bar -->
    <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm mb-8">
        <form action="${pageContext.request.contextPath}/courses" method="get" class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div class="md:col-span-2 relative">
                <input type="text" name="search" value="${search}" placeholder="Tìm kiếm khóa học..." class="w-full pl-10 pr-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </div>
            </div>
            <div>
                <select name="categoryId" class="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-500 text-sm">
                    <option value="">Tất cả danh mục</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${categoryId eq cat.id.toString() ? 'selected' : ''}>${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="flex space-x-2">
                <button type="submit" class="flex-1 py-2.5 px-4 bg-blue-600 text-white rounded-xl font-semibold text-sm hover:bg-blue-700 transition">
                    Tìm Kiếm
                </button>
                <a href="${pageContext.request.contextPath}/courses" class="py-2.5 px-4 bg-slate-100 text-slate-600 rounded-xl font-semibold text-sm hover:bg-slate-200 transition">
                    Xóa lọc
                </a>
            </div>
        </form>
    </div>

    <!-- Courses Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <c:choose>
            <c:when test="${not empty pageResult.items}">
                <c:forEach var="c" items="${pageResult.items}">
                    <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-xl transition duration-300 flex flex-col group">
                        <div class="relative h-48 bg-slate-100 overflow-hidden">
                            <img src="${not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" alt="${c.title}" class="w-full h-full object-cover group-hover:scale-105 transition duration-500">
                            <span class="absolute top-3 right-3 px-2.5 py-1 rounded-full text-xs font-bold bg-white/90 text-blue-700 shadow-sm">
                                ${c.categoryName != null ? c.categoryName : 'Khóa học'}
                            </span>
                        </div>
                        <div class="p-6 flex-grow flex flex-col justify-between">
                            <div>
                                <h3 class="font-bold text-lg text-slate-900 group-hover:text-blue-600 transition line-clamp-1 mb-2">
                                    <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}">${c.title}</a>
                                </h3>
                                <p class="text-sm text-slate-600 line-clamp-2 mb-4">${c.description}</p>
                            </div>
                            <div class="pt-4 border-t border-slate-100 flex items-center justify-between">
                                <span class="text-lg font-bold text-blue-600">
                                    <c:choose>
                                        <c:when test="${c.price <= 0}">Miễn phí</c:when>
                                        <c:otherwise><fmt:formatNumber value="${c.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></c:otherwise>
                                    </c:choose>
                                </span>
                                <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" class="inline-flex items-center px-4 py-2 text-sm font-semibold text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-600 hover:text-white transition">
                                    Xem chi tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-span-3 text-center py-16 bg-white rounded-2xl border border-slate-200">
                    <i class="fa-solid fa-box-open text-5xl text-slate-300 mb-3"></i>
                    <p class="text-slate-600 font-medium">Không tìm thấy khóa học nào phù hợp.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Pagination -->
    <c:if test="${pageResult.totalPages > 1}">
        <div class="mt-10 flex justify-center space-x-2">
            <c:forEach begin="1" end="${pageResult.totalPages}" var="i">
                <a href="${pageContext.request.contextPath}/courses?page=${i}&search=${search}&categoryId=${categoryId}" class="px-4 py-2 text-sm font-semibold rounded-xl border ${pageResult.page == i ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-50'}">
                    ${i}
                </a>
            </c:forEach>
        </div>
    </c:if>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />