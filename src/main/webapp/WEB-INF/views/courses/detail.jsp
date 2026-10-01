<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow bg-slate-50">
    <div class="bg-gradient-to-r from-slate-900 to-blue-900 text-white py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="max-w-3xl">
                <nav class="text-sm text-blue-300 mb-4 flex items-center gap-2">
                    <a href="${pageContext.request.contextPath}/" class="hover:text-white transition">Trang chu</a>
                    <i class="fa-solid fa-chevron-right text-xs"></i>
                    <a href="${pageContext.request.contextPath}/courses" class="hover:text-white transition">Khoa hoc</a>
                    <i class="fa-solid fa-chevron-right text-xs"></i>
                    <span class="text-white">${course.title}</span>
                </nav>
                <c:if test="${not empty course.categoryName}">
                    <span class="inline-block px-3 py-1 bg-blue-500 bg-opacity-30 text-blue-200 text-xs font-semibold rounded-full mb-4">${course.categoryName}</span>
                </c:if>
                <h1 class="text-3xl md:text-4xl font-black leading-tight mb-4">${course.title}</h1>
                <p class="text-blue-100 text-base leading-relaxed mb-6 max-w-2xl">${course.description}</p>
                <div class="flex flex-wrap items-center gap-6 text-sm text-blue-200">
                    <c:if test="${not empty course.expertName}">
                        <span><i class="fa-solid fa-user-tie text-blue-400 mr-1"></i>Giang vien: <strong class="text-white">${course.expertName}</strong></span>
                    </c:if>
                    <span><i class="fa-solid fa-layer-group text-blue-400 mr-1"></i><strong class="text-white">${course.moduleCount}</strong> chuong</span>
                    <span><i class="fa-solid fa-play-circle text-blue-400 mr-1"></i><strong class="text-white">${course.lessonCount}</strong> bai hoc</span>
                </div>
            </div>
        </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
            <div class="lg:col-span-2 space-y-6">
                <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                    <div class="px-6 py-5 border-b border-slate-100">
                        <h2 class="text-xl font-bold text-slate-900"><i class="fa-solid fa-list-check text-blue-600 mr-2"></i>Noi dung khoa hoc</h2>
                        <p class="text-sm text-slate-500 mt-1">${course.moduleCount} chuong &bull; ${course.lessonCount} bai hoc</p>
                    </div>
                    <div class="divide-y divide-slate-100">
                        <c:choose>
                            <c:when test="${not empty course.modules}">
                                <c:forEach var="currentModule" items="${course.modules}" varStatus="modStatus">
                                    <div class="module-block">
                                        <button type="button" onclick="toggleModule(this)" class="w-full flex items-center justify-between px-6 py-4 bg-slate-50 hover:bg-slate-100 transition text-left">
                                            <div class="flex items-center gap-3">
                                                <span class="w-7 h-7 rounded-full bg-blue-100 text-blue-700 text-xs font-bold flex items-center justify-center shrink-0">${modStatus.count}</span>
                                                <span class="font-semibold text-slate-800">${currentModule.title}</span>
                                            </div>
                                            <i class="fa-solid fa-chevron-down text-slate-400 toggle-icon"></i>
                                        </button>
                                        <div class="lesson-list px-6 py-2 space-y-1" style="display:none;">
                                            <c:choose>
                                                <c:when test="${not empty currentModule.lessons}">
                                                    <c:forEach var="currentLesson" items="${currentModule.lessons}" varStatus="lesStatus">
                                                        <div class="flex items-center gap-3 py-2 px-3 rounded-lg hover:bg-blue-50 transition">
                                                            <span class="text-xs text-slate-400 w-5 text-right shrink-0">${lesStatus.count}</span>
                                                            <i class="fa-regular fa-circle-play text-slate-400 shrink-0"></i>
                                                            <span class="text-sm text-slate-700">${currentLesson.title}</span>
                                                        </div>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <p class="text-sm text-slate-400 italic py-3">Chua co bai hoc.</p>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="px-6 py-12 text-center text-slate-400">
                                    <i class="fa-solid fa-book-open text-4xl mb-3 block"></i>
                                    <p>Noi dung dang cap nhat.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
                    <h2 class="text-xl font-bold text-slate-900 mb-4"><i class="fa-solid fa-circle-info text-blue-600 mr-2"></i>Gioi thieu khoa hoc</h2>
                    <p class="text-slate-600 leading-relaxed">${course.description}</p>
                </div>
            </div>

            <div class="lg:col-span-1">
                <div class="sticky top-24 bg-white rounded-2xl border border-slate-200 shadow-xl overflow-hidden">
                    <div class="h-52 bg-slate-100 overflow-hidden">
                        <c:choose>
                            <c:when test="${not empty course.thumbnailUrl}">
                                <img src="${course.thumbnailUrl}" alt="${course.title}" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800" alt="${course.title}" class="w-full h-full object-cover">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="p-6">
                        <div class="mb-5">
                            <c:choose>
                                <c:when test="${course.price <= 0}">
                                    <div class="text-3xl font-black text-emerald-600">Mien Phi</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-3xl font-black text-slate-900">
                                        <fmt:formatNumber value="${course.price}" type="currency" currencySymbol="d" maxFractionDigits="0"/>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <c:choose>
                            <c:when test="${isEnrolled}">
                                <a href="${pageContext.request.contextPath}/learning-process?courseId=${course.id}" class="w-full flex items-center justify-center gap-2 py-3 px-4 font-bold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl transition">
                                    <i class="fa-solid fa-play"></i> Vao Hoc Ngay
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/enrollment?courseId=${course.id}" class="w-full flex items-center justify-center gap-2 py-3 px-4 font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl transition">
                                    <i class="fa-solid fa-user-plus"></i> Dang Ky Khoa Hoc
                                </a>
                            </c:otherwise>
                        </c:choose>
                        <ul class="mt-6 space-y-3 text-sm text-slate-600 border-t border-slate-100 pt-5">
                            <li class="flex items-center gap-3"><i class="fa-solid fa-layer-group text-blue-500 w-4 text-center"></i><span><strong>${course.moduleCount}</strong> chuong hoc</span></li>
                            <li class="flex items-center gap-3"><i class="fa-solid fa-film text-blue-500 w-4 text-center"></i><span><strong>${course.lessonCount}</strong> bai giang</span></li>
                            <c:if test="${not empty course.expertName}">
                                <li class="flex items-center gap-3"><i class="fa-solid fa-chalkboard-user text-blue-500 w-4 text-center"></i><span>Giang vien: <strong>${course.expertName}</strong></span></li>
                            </c:if>
                            <c:if test="${not empty course.categoryName}">
                                <li class="flex items-center gap-3"><i class="fa-solid fa-tag text-blue-500 w-4 text-center"></i><span>Danh muc: <strong>${course.categoryName}</strong></span></li>
                            </c:if>
                            <li class="flex items-center gap-3"><i class="fa-solid fa-infinity text-blue-500 w-4 text-center"></i><span>Truy cap tron doi</span></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
function toggleModule(btn) {
    var list = btn.nextElementSibling;
    var icon = btn.querySelector('.toggle-icon');
    if (list.style.display === 'none' || list.style.display === '') {
        list.style.display = 'block';
        icon.style.transform = 'rotate(180deg)';
    } else {
        list.style.display = 'none';
        icon.style.transform = '';
    }
}
document.addEventListener('DOMContentLoaded', function() {
    var first = document.querySelector('.module-block button');
    if (first) first.click();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />