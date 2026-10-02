<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-10 max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <!-- Quiz Header -->
    <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm mb-8 flex items-center justify-between">
        <div>
            <h1 class="text-2xl font-black text-slate-900">${quiz.name}</h1>
            <p class="text-sm text-slate-500 mt-1">Thời gian làm bài: ${quiz.duration} phút | Điểm đạt: ${quiz.passRate}%</p>
        </div>
        <div class="px-4 py-2 bg-amber-50 border border-amber-200 rounded-xl text-amber-700 font-bold text-sm flex items-center">
            <i class="fa-regular fa-clock mr-2"></i> ${quiz.duration}:00
        </div>
    </div>

    <!-- Quiz Form -->
    <form action="${pageContext.request.contextPath}/quiz" method="post" class="space-y-6">
        <input type="hidden" name="action" value="submit">
        <input type="hidden" name="quizId" value="${quiz.id}">
        <input type="hidden" name="submissionId" value="${submission.id}">

        <c:forEach var="q" items="${questions}" varStatus="status">
            <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                <div class="flex items-start space-x-3 mb-4">
                    <span class="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 font-bold flex items-center justify-center text-sm shrink-0">
                        ${status.count}
                    </span>
                    <h3 class="text-base font-bold text-slate-900 pt-1">${q.content}</h3>
                </div>

                <div class="space-y-3 pl-11">
                    <c:forEach var="opt" items="${q.options}">
                        <label class="flex items-center space-x-3 p-3 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer transition">
                            <input type="radio" name="question_${q.id}" value="${opt.id}" class="text-blue-600 focus:ring-blue-500">
                            <span class="text-sm text-slate-700 font-medium">${opt.content}</span>
                        </label>
                    </c:forEach>
                </div>
            </div>
        </c:forEach>

        <div class="flex justify-end pt-4">
            <button type="submit" class="px-8 py-3.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-md transition">
                Nộp Bài Thi
            </button>
        </div>
    </form>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />