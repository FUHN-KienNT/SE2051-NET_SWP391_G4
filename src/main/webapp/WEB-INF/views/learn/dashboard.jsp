<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <!-- Header with Icon & Actions -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <div>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
                <i class="fa-solid fa-gauge-high text-emerald-600"></i>
                <span>Bảng Điều Khiển Học Tập</span>
            </h1>
            <p class="text-slate-500 text-xs sm:text-sm mt-1">Theo dõi tiến độ, hoàn thành bài giảng và thành tích học tập cá nhân</p>
        </div>
        <div class="flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/courses"
               class="inline-flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 active:bg-emerald-800 text-white font-bold rounded-xl text-xs transition shadow-sm shadow-emerald-600/20">
                <i class="fa-solid fa-compass text-xs"></i>
                <span>Khám phá khóa học</span>
            </a>
            <a href="${pageContext.request.contextPath}/enrollment?action=my-courses"
               class="inline-flex items-center gap-1.5 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl text-xs transition">
                <i class="fa-solid fa-book-bookmark text-xs"></i>
                <span>Khóa học của tôi</span>
            </a>
        </div>
    </div>

    <!-- Quick Stats Cards with Unified Icons -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-5 mb-8">
        <!-- Stat 1: Khóa học tham gia -->
        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-xl shrink-0">
                <i class="fa-solid fa-book-bookmark"></i>
            </div>
            <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1">
                    <i class="fa-solid fa-graduation-cap text-[10px]"></i>
                    <span>Khóa học tham gia</span>
                </p>
                <h3 class="text-2xl font-black text-slate-900 mt-0.5">
                    ${progressSummary.totalCourses != null ? progressSummary.totalCourses : 0}
                </h3>
            </div>
        </div>

        <!-- Stat 2: Bài học hoàn thành -->
        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl shrink-0">
                <i class="fa-solid fa-circle-check"></i>
            </div>
            <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1">
                    <i class="fa-solid fa-list-check text-[10px]"></i>
                    <span>Bài học đã hoàn thành</span>
                </p>
                <h3 class="text-2xl font-black text-slate-900 mt-0.5">
                    ${progressSummary.completedLessons != null ? progressSummary.completedLessons : 0}
                </h3>
            </div>
        </div>

        <!-- Stat 3: Điểm số trung bình -->
        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-xl shrink-0">
                <i class="fa-solid fa-trophy"></i>
            </div>
            <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1">
                    <i class="fa-solid fa-star text-[10px]"></i>
                    <span>Điểm kiểm tra trung bình</span>
                </p>
                <h3 class="text-2xl font-black text-slate-900 mt-0.5">
                    ${progressSummary.averageScore != null ? progressSummary.averageScore : 'N/A'}
                </h3>
            </div>
        </div>
    </div>

    <!-- Continue Learning Section -->
    <c:if test="${not empty continueLearning}">
        <div class="mb-10 bg-gradient-to-r from-emerald-50 via-teal-50 to-blue-50 border border-emerald-200/80 rounded-2xl p-6 shadow-xs">
            <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                <div class="flex items-center space-x-4">
                    <div class="w-16 h-16 rounded-xl bg-emerald-600 text-white flex items-center justify-center text-2xl shadow-md shadow-emerald-600/30 shrink-0">
                        <i class="fa-solid fa-play"></i>
                    </div>
                    <div>
                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-800 mb-1.5">
                            <i class="fa-solid fa-clock-rotate-left text-[10px]"></i>
                            <span>Tiếp tục bài học gần nhất</span>
                        </span>
                        <h2 class="text-lg font-black text-slate-900">${continueLearning.courseTitle}</h2>
                        <p class="text-xs text-slate-600 mt-0.5 flex items-center gap-2">
                            <span><i class="fa-regular fa-folder mr-1 text-slate-400"></i>${continueLearning.moduleTitle}</span>
                            <span>•</span>
                            <span><i class="fa-regular fa-circle-play mr-1 text-emerald-600"></i>${continueLearning.lessonTitle}</span>
                        </p>
                    </div>
                </div>

                <div class="w-full md:w-72 flex flex-col items-end gap-3 shrink-0">
                    <div class="w-full">
                        <div class="flex justify-between text-xs font-bold text-slate-700 mb-1">
                            <span>Tiến độ khóa học</span>
                            <span class="text-emerald-600 font-extrabold">${continueLearning.progressPercent}%</span>
                        </div>
                        <div class="w-full bg-slate-200 rounded-full h-2.5 overflow-hidden">
                            <div class="bg-emerald-600 h-2.5 rounded-full transition-all duration-500" style="width: ${continueLearning.progressPercent}%"></div>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/learn/lesson?courseId=${continueLearning.courseId}&lessonId=${continueLearning.lessonId}"
                       class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs transition shadow-md shadow-emerald-600/20">
                        <i class="fa-solid fa-play text-xs"></i>
                        <span>Vào học tiếp ngay</span>
                    </a>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Enrolled Courses Grid Section -->
    <div class="mb-8">
        <div class="flex items-center justify-between mb-5">
            <h2 class="text-lg font-black text-slate-900 flex items-center gap-2">
                <i class="fa-solid fa-book-open-reader text-emerald-600"></i>
                <span>Khóa Học Đang Theo Học</span>
            </h2>
            <a href="${pageContext.request.contextPath}/enrollment?action=my-courses"
               class="text-xs font-bold text-emerald-600 hover:text-emerald-700 flex items-center gap-1">
                <span>Xem tất cả</span>
                <i class="fa-solid fa-chevron-right text-[10px]"></i>
            </a>
        </div>

        <c:choose>
            <c:when test="${not empty registrations}">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <c:forEach var="reg" items="${registrations}">
                        <div class="bg-white rounded-2xl border border-slate-200/80 overflow-hidden shadow-xs hover:shadow-md transition-shadow flex flex-col justify-between">
                            <div>
                                <div class="relative h-44 bg-slate-100 overflow-hidden">
                                    <img src="${not empty reg.courseThumbnail ? reg.courseThumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}"
                                         alt="${reg.courseTitle}"
                                         class="w-full h-full object-cover">
                                    <div class="absolute top-3 right-3">
                                        <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold bg-white/90 backdrop-blur-sm text-emerald-700 shadow-xs">
                                            <i class="fa-solid fa-circle-check text-[10px]"></i>
                                            <span>${reg.status eq 'enrolled' or reg.status eq 'active' ? 'Đang học' : reg.status}</span>
                                        </span>
                                    </div>
                                </div>
                                <div class="p-5">
                                    <h3 class="font-bold text-sm text-slate-900 line-clamp-2 hover:text-emerald-600 transition-colors">
                                        ${reg.courseTitle}
                                    </h3>
                                    <div class="mt-4">
                                        <div class="flex justify-between text-[11px] font-semibold text-slate-500 mb-1">
                                            <span>Tiến độ</span>
                                            <span class="font-bold text-slate-800">${reg.progressPercent != null ? reg.progressPercent : 0}%</span>
                                        </div>
                                        <div class="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
                                            <div class="bg-emerald-500 h-2 rounded-full" style="width: ${reg.progressPercent != null ? reg.progressPercent : 0}%"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="px-5 pb-5 pt-2 border-t border-slate-100 flex items-center justify-between">
                                <a href="${pageContext.request.contextPath}/learning-process?courseId=${reg.courseId}"
                                   class="w-full inline-flex items-center justify-center gap-1.5 py-2 px-4 font-bold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl text-xs transition shadow-xs">
                                    <i class="fa-solid fa-arrow-right text-xs"></i>
                                    <span>Vào học tiếp</span>
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="text-center py-12 bg-white rounded-2xl border border-slate-200/80 shadow-xs">
                    <i class="fa-solid fa-graduation-cap text-4xl text-slate-300 mb-3 block"></i>
                    <p class="text-slate-600 font-bold text-sm">Bạn chưa đăng ký khóa học nào</p>
                    <p class="text-slate-400 text-xs mt-1">Khám phá hàng loạt khóa học chất lượng cao trên LearnHub ngay hôm nay.</p>
                    <a href="${pageContext.request.contextPath}/courses"
                       class="mt-4 inline-flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs transition shadow-sm">
                        <i class="fa-solid fa-compass text-xs"></i>
                        <span>Khám phá khóa học ngay</span>
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />