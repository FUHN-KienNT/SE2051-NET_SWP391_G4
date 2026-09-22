<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-12 max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="bg-white p-8 rounded-2xl border border-slate-200 shadow-xl text-center">
        <div class="w-20 h-20 rounded-full mx-auto mb-4 flex items-center justify-center ${isPassed ? 'bg-emerald-100 text-emerald-600' : 'bg-rose-100 text-rose-600'} text-4xl">
            <i class="fa-solid ${isPassed ? 'fa-check' : 'fa-xmark'}"></i>
        </div>
        <h1 class="text-2xl font-black text-slate-900 mb-2">${isPassed ? 'Chúc Mừng! Bạn Đã Đạt' : 'Rất Tiếc! Chưa Đạt Yêu Cầu'}</h1>
        <p class="text-slate-500 text-sm mb-6">${quiz.name}</p>

        <div class="bg-slate-50 rounded-xl p-6 mb-8 grid grid-cols-2 gap-4 border border-slate-200">
            <div>
                <p class="text-xs uppercase text-slate-400 font-bold">Điểm số</p>
                <p class="text-3xl font-black ${isPassed ? 'text-emerald-600' : 'text-rose-600'} mt-1">
                    <fmt:formatNumber value="${score}" maxFractionDigits="1"/>%
                </p>
            </div>
            <div>
                <p class="text-xs uppercase text-slate-400 font-bold">Điểm yêu cầu</p>
                <p class="text-3xl font-black text-slate-800 mt-1">${quiz.passRate}%</p>
            </div>
        </div>

        <div class="flex justify-center space-x-4">
            <a href="${pageContext.request.contextPath}/quiz?action=take&quizId=${quiz.id}" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-sm transition">
                Làm lại bài thi
            </a>
            <a href="${pageContext.request.contextPath}/learning-process?action=dashboard" class="px-6 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl text-sm transition">
                Về bảng điều khiển
            </a>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />