<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="mb-8">
        <h1 class="text-3xl font-black text-slate-900">Khóa Học Của Tôi</h1>
        <p class="text-slate-500 mt-1">Danh sách các khóa học bạn đã đăng ký</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <c:choose>
            <c:when test="${not empty registrations}">
                <c:forEach var="reg" items="${registrations}">
                    <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-lg transition duration-300 flex flex-col">
                        <img src="${not empty reg.courseThumbnail ? reg.courseThumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" alt="${reg.courseTitle}" class="w-full h-44 object-cover">
                        <div class="p-6 flex-grow flex flex-col justify-between">
                            <div>
                                <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold ${reg.status eq 'active' ? 'bg-emerald-50 text-emerald-700' : 'bg-amber-50 text-amber-700'}">
                                    ${reg.status eq 'active' ? 'Đang học' : 'Chờ kích hoạt'}
                                </span>
                                <h3 class="font-bold text-lg text-slate-900 line-clamp-1 mt-2 mb-4">${reg.courseTitle}</h3>
                            </div>
                            <div class="pt-4 border-t border-slate-100">
                                <a href="${pageContext.request.contextPath}/learning-process?courseId=${reg.courseId}" class="w-full block text-center py-2.5 px-4 font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-sm transition text-sm">
                                    Tiếp Tục Học Tập
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-span-3 text-center py-16 bg-white rounded-2xl border border-slate-200">
                    <i class="fa-solid fa-graduation-cap text-5xl text-slate-300 mb-3"></i>
                    <p class="text-slate-600 font-medium">Bạn chưa đăng ký khóa học nào.</p>
                    <a href="${pageContext.request.contextPath}/courses" class="mt-4 inline-flex items-center px-4 py-2 text-sm font-semibold text-white bg-blue-600 rounded-xl hover:bg-blue-700 transition">
                        Khám phá khóa học ngay
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />