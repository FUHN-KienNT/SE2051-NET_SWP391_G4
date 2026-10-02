<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
    <div class="flex items-center justify-between mb-6">
        <div>
            <p class="text-xs font-bold uppercase tracking-wider text-blue-600">Quiz Management</p>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900 mt-1">${empty quiz ? 'Quiz Detail - Create' : 'Quiz Detail - Edit'}</h1>
        </div>
        <div class="flex flex-wrap items-center gap-2">
            <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}" class="px-4 py-2 rounded-xl border border-slate-200 bg-white text-sm font-bold text-slate-700 hover:bg-slate-50">
                <i class="fa-solid fa-list-check mr-2"></i>Question Bank
            </a>
            <a href="${pageContext.request.contextPath}/questions/detail?courseId=${courseId}" class="px-4 py-2 rounded-xl bg-blue-600 text-white text-sm font-bold hover:bg-blue-700">
                <i class="fa-solid fa-plus mr-2"></i>New Question
            </a>
            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}" class="px-4 py-2 rounded-xl border border-slate-200 bg-white text-sm font-bold text-slate-700 hover:bg-slate-50">Back to Quiz List</a>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="mb-5 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/quiz/detail" class="space-y-6">
                <input type="hidden" name="courseId" value="${courseId}">
        <input type="hidden" name="id" value="${quiz.id}">

        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="md:col-span-2">
                    <label class="block text-sm font-bold text-slate-800 mb-2">Quiz Name <span class="text-rose-500">*</span></label>
                    <input name="title" value="${quiz.title}" required maxlength="255" placeholder="e.g. Servlet Fundamentals Quiz"
                           class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block text-sm font-bold text-slate-800 mb-2">Module <span class="text-rose-500">*</span></label>
                    <select name="moduleId" required class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-blue-500">
                        <option value="">-- Select module --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${quiz.moduleId eq m.id ? 'selected' : ''}>${m.title}</option>
                        </c:forEach>
                    </select>
                    <p class="text-xs text-slate-400 mt-2">DB hiện liên kết Quiz với Module; đây là mapping theo schema hiện tại của project.</p>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-bold text-slate-800 mb-2">Time Limit (minutes)</label>
                        <input type="number" name="timeLimit" min="1" max="600" value="${quiz.timeLimit}" placeholder="30"
                               class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-slate-800 mb-2">Pass Score (0-10)</label>
                        <input type="number" name="passScore" min="0" max="10" step="0.01" value="${empty quiz.passScore ? '5.0' : quiz.passScore}" required
                               class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
            </div>
        </section>

        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <div class="p-6 border-b border-slate-100 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                <div>
                    <h2 class="text-lg font-black text-slate-900">Select Quiz Questions</h2>
                    <p class="text-xs text-slate-500 mt-1">Chọn câu hỏi từ Question Bank. Thứ tự trong form sẽ là thứ tự hiển thị trong Quiz.</p>
                </div>
                <input id="questionSearch" oninput="filterQuestions()" placeholder="Filter question bank..."
                       class="w-full md:w-80 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none">
            </div>
            <div class="p-5 max-h-[560px] overflow-y-auto space-y-3" id="questionList">
                <c:forEach var="q" items="${questions}" varStatus="s">
                    <c:set var="selected" value="${selectedQuestionIds.contains(q.id)}"/>
                    <label class="question-item flex items-start gap-3 p-4 rounded-xl border border-slate-200 hover:bg-slate-50 cursor-pointer ${selected ? 'bg-blue-50 border-blue-200' : ''}"
                           data-text="${q.content}">
                        <input type="checkbox" name="questionId" value="${q.id}" ${selected ? 'checked' : ''}
                               class="mt-1 question-check w-4 h-4 accent-blue-600">
                        <div class="min-w-0">
                            <div class="font-semibold text-sm text-slate-800">${q.content}</div>
                            <div class="text-xs text-slate-400 mt-1">${q.type} · ${q.id}</div>
                        </div>
                    </label>
                </c:forEach>
                <c:if test="${empty questions}">
                    <div class="text-center py-10 text-slate-400 text-sm">Question Bank is empty. <a class="text-blue-600 font-bold" href="${pageContext.request.contextPath}/questions/detail?courseId=${courseId}">Create a question</a>.</div>
                </c:if>
            </div>
        </section>

        <div class="flex gap-3">
            <button class="px-7 py-3 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-sm">Save Quiz</button>
            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}" class="px-7 py-3 rounded-xl border border-slate-200 text-slate-700 font-bold text-sm hover:bg-slate-50">Cancel</a>
        </div>
    </form>
</main>

<script>
function filterQuestions(){
    const keyword=document.getElementById('questionSearch').value.toLowerCase().trim();
    document.querySelectorAll('.question-item').forEach(function(row){
        row.style.display=row.dataset.text.toLowerCase().includes(keyword)?'flex':'none';
    });
}
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
