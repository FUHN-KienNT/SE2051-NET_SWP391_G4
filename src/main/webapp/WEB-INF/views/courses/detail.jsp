<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Main Details -->
        <div class="lg:col-span-2 space-y-8">
            <div class="bg-white p-8 rounded-2xl border border-slate-200 shadow-sm">
                <span class="inline-block px-3 py-1 rounded-full text-xs font-bold bg-blue-50 text-blue-700 mb-4">
                    ${course.categoryName != null ? course.categoryName : 'Khóa học'}
                </span>
                <h1 class="text-3xl font-black text-slate-900 mb-4">${course.title}</h1>
                <p class="text-slate-600 text-base leading-relaxed mb-6">${course.description}</p>
                <div class="flex items-center space-x-6 text-sm text-slate-500 border-t border-slate-100 pt-4">
                    <span><i class="fa-solid fa-layer-group mr-2 text-blue-600"></i>${modules != null ? modules.size() : 0} Chương học</span>
                    <span><i class="fa-solid fa-play-circle mr-2 text-blue-600"></i>${lessons != null ? lessons.size() : 0} Bài giảng</span>
                </div>
            </div>

            <!-- Curriculum Modules -->
            <div class="bg-white p-8 rounded-2xl border border-slate-200 shadow-sm">
                <h2 class="text-xl font-bold text-slate-900 mb-6">Nội Dung Khóa Học</h2>
                <div class="space-y-4">
                    <c:forEach var="mod" items="${modules}" varStatus="loop">
                        <div class="border border-slate-200 rounded-xl overflow-hidden">
                            <div class="bg-slate-50 px-5 py-4 font-bold text-slate-800">
                                Chương ${loop.count}: ${mod.name}
                            </div>
                            <div class="p-4 space-y-2 bg-white">
                                <c:forEach var="les" items="${lessons}">
                                    <c:if test="${les.moduleId eq mod.id}">
                                        <div class="flex items-center justify-between py-2 px-3 rounded-lg hover:bg-slate-50 text-sm text-slate-700">
                                            <div class="flex items-center space-x-3">
                                                <i class="fa-regular fa-circle-play text-blue-600"></i>
                                                <span>${les.name}</span>
                                            </div>
                                            <span class="text-xs text-slate-400 font-mono">${les.duration} phút</span>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- Sidebar Action Card -->
        <div class="lg:col-span-1">
            <div class="sticky top-24 bg-white rounded-2xl border border-slate-200 shadow-lg overflow-hidden p-6">
                <img src="${not empty course.thumbnail ? course.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" alt="${course.title}" class="w-full h-48 object-cover rounded-xl mb-6">
                <div class="mb-6">
                    <span class="text-sm text-slate-400 block mb-1">Học phí</span>
                    <c:choose>
                        <c:when test="${course.price <= 0}">
                            <div class="text-3xl font-black text-emerald-600">Miễn Phí</div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-3xl font-black text-slate-900"><fmt:formatNumber value="${course.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <c:choose>
                    <c:when test="${isEnrolled}">
                        <a href="${pageContext.request.contextPath}/learning-process?courseId=${course.id}" class="w-full block text-center py-3.5 px-4 font-bold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl shadow-md transition">
                            <i class="fa-solid fa-play mr-2"></i> Vào Học Ngay
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/enrollment?action=enroll&courseId=${course.id}" class="w-full block text-center py-3.5 px-4 font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-md transition">
                            <i class="fa-solid fa-user-plus mr-2"></i> Đăng Ký Khóa Học
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />