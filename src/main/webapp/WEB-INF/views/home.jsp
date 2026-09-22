<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow">
    <!-- Hero Section -->
    <section class="relative bg-gradient-to-br from-blue-900 via-indigo-900 to-slate-900 text-white py-20 lg:py-24 overflow-hidden">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
                <div>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-blue-500/20 text-blue-300 border border-blue-500/30 mb-6">
                        <i class="fa-solid fa-sparkles mr-2 text-amber-400"></i> Nền Tảng E-Learning Hiện Đại
                    </span>
                    <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight leading-tight mb-6">
                        Nâng Tầm Tri Thức Cùng <span class="text-blue-400">LearnHub</span>
                    </h1>
                    <p class="text-lg text-slate-300 mb-8 max-w-xl">
                        Khoá học chất lượng cao từ các chuyên gia giảng dạy hàng đầu. Theo dõi lộ trình học tập, thi trắc nghiệm trực tuyến và nhận chứng chỉ hoàn thành.
                    </p>
                    <div class="flex space-x-4">
                        <a href="${pageContext.request.contextPath}/courses" class="px-8 py-3.5 rounded-xl font-bold text-white bg-blue-600 hover:bg-blue-500 shadow-lg shadow-blue-500/30 transition">
                            <i class="fa-solid fa-compass mr-2"></i> Khám Phá Khóa Học
                        </a>
                        <c:if test="${empty sessionScope.user}">
                            <a href="${pageContext.request.contextPath}/auth?action=register" class="px-8 py-3.5 rounded-xl font-bold text-slate-200 bg-white/10 hover:bg-white/20 border border-white/20 transition">
                                Đăng Ký Miễn Phí
                            </a>
                        </c:if>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div class="bg-white/10 backdrop-blur-md rounded-2xl p-6 text-center border border-white/10">
                        <i class="fa-solid fa-book-open text-3xl text-blue-400 mb-2"></i>
                        <h3 class="text-3xl font-black text-white">100+</h3>
                        <p class="text-sm text-slate-300">Khóa học</p>
                    </div>
                    <div class="bg-white/10 backdrop-blur-md rounded-2xl p-6 text-center border border-white/10">
                        <i class="fa-solid fa-users text-3xl text-emerald-400 mb-2"></i>
                        <h3 class="text-3xl font-black text-white">10,000+</h3>
                        <p class="text-sm text-slate-300">Học viên</p>
                    </div>
                    <div class="bg-white/10 backdrop-blur-md rounded-2xl p-6 text-center border border-white/10">
                        <i class="fa-solid fa-circle-question text-3xl text-amber-400 mb-2"></i>
                        <h3 class="text-3xl font-black text-white">5,000+</h3>
                        <p class="text-sm text-slate-300">Câu hỏi Quiz</p>
                    </div>
                    <div class="bg-white/10 backdrop-blur-md rounded-2xl p-6 text-center border border-white/10">
                        <i class="fa-solid fa-award text-3xl text-purple-400 mb-2"></i>
                        <h3 class="text-3xl font-black text-white">99%</h3>
                        <p class="text-sm text-slate-300">Hài lòng</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Featured Courses Section -->
    <section class="py-16 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between mb-8">
            <div>
                <h2 class="text-2xl font-extrabold text-slate-900">Khóa Học Tiêu Biểu</h2>
                <p class="text-slate-500 mt-1">Các khóa học được học viên lựa chọn học nhiều nhất</p>
            </div>
            <a href="${pageContext.request.contextPath}/courses" class="text-sm font-semibold text-blue-600 hover:text-blue-700">Xem tất cả khóa học &rarr;</a>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <c:forEach var="c" items="${featuredCourses}">
                <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-xl transition duration-300 flex flex-col">
                    <img src="${not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" alt="${c.title}" class="w-full h-48 object-cover">
                    <div class="p-6 flex-grow flex flex-col justify-between">
                        <div>
                            <h3 class="font-bold text-lg text-slate-900 line-clamp-1 mb-2">
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
                            <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" class="px-4 py-2 text-sm font-semibold text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-600 hover:text-white transition">
                                Chi tiết
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />