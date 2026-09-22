<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="mb-8">
        <h1 class="text-3xl font-black text-slate-900">Bảng Điều Khiển Học Tập</h1>
        <p class="text-slate-500 mt-1">Theo dõi tiến độ và thành tích học tập cá nhân</p>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
        <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-xl">
                <i class="fa-solid fa-book-bookmark"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-slate-400">Khóa học tham gia</p>
                <h3 class="text-2xl font-black text-slate-900">${progressSummary.totalCourses != null ? progressSummary.totalCourses : 0}</h3>
            </div>
        </div>
        <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl">
                <i class="fa-solid fa-circle-check"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-slate-400">Bài học đã hoàn thành</p>
                <h3 class="text-2xl font-black text-slate-900">${progressSummary.completedLessons != null ? progressSummary.completedLessons : 0}</h3>
            </div>
        </div>
        <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-xl">
                <i class="fa-solid fa-trophy"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-slate-400">Điểm số trung bình</p>
                <h3 class="text-2xl font-black text-slate-900">${progressSummary.averageScore != null ? progressSummary.averageScore : 'N/A'}</h3>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />