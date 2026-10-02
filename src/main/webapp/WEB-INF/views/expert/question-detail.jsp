<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
    <div class="flex items-center justify-between mb-6">
        <div>
            <p class="text-xs font-bold uppercase tracking-wider text-blue-600">Question Bank</p>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900 mt-1">${empty question ? 'Question Detail - Create' : 'Question Detail - Edit'}</h1>
        </div>
        <div class="flex flex-wrap items-center gap-2">
            <a href="${pageContext.request.contextPath}/quiz/manage" class="px-4 py-2 rounded-xl border border-slate-200 bg-white text-sm font-bold text-slate-700 hover:bg-slate-50">
                <i class="fa-solid fa-clipboard-question mr-2"></i>Quiz Management
            </a>
            <a href="${pageContext.request.contextPath}/questions/manage" class="px-4 py-2 rounded-xl border border-slate-200 bg-white text-sm font-bold text-slate-700 hover:bg-slate-50">
                <i class="fa-solid fa-arrow-left mr-2"></i>Question List
            </a>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="mb-5 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/questions/detail" id="questionForm"
          class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-6">
        <input type="hidden" name="id" value="${question.id}">

        <div>
            <label class="block text-sm font-bold text-slate-800 mb-2">Question Content <span class="text-rose-500">*</span></label>
            <textarea name="content" rows="5" required
                      class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none text-sm">${question.content}</textarea>
        </div>

        <div class="max-w-sm">
            <label class="block text-sm font-bold text-slate-800 mb-2">Question Type <span class="text-rose-500">*</span></label>
            <select id="type" name="type" required onchange="toggleOptions()"
                    class="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none text-sm">
                <option value="single_choice" ${question.type == 'single_choice' ? 'selected' : ''}>Single Choice</option>
                <option value="multiple_choice" ${question.type == 'multiple_choice' ? 'selected' : ''}>Multiple Choice</option>
                <option value="text" ${question.type == 'text' ? 'selected' : ''}>Text</option>
            </select>
        </div>

        <div id="optionsBox" class="border border-slate-200 rounded-2xl p-5">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <h2 class="font-black text-slate-900">Answer Options</h2>
                    <p class="text-xs text-slate-500 mt-1">Tick the correct answer(s). Single Choice must have exactly one.</p>
                </div>
                <button type="button" onclick="addOption()" class="px-3 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-xs font-bold">
                    <i class="fa-solid fa-plus mr-1"></i>Add option
                </button>
            </div>
            <div id="optionRows" class="space-y-3">
                <c:choose>
                    <c:when test="${not empty question.options}">
                        <c:forEach var="o" items="${question.options}">
                            <div class="option-row flex gap-3 items-center">
                                <input type="checkbox" name="correctIndex" value="__INDEX__"
                                       class="correct-box w-4 h-4 accent-blue-600" ${o.correct ? 'checked' : ''}>
                                <input type="text" name="optionText" value="${o.optionText}" required
                                       class="flex-1 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-blue-500">
                                <button type="button" onclick="this.closest('.option-row').remove(); renumber()" class="w-9 h-9 rounded-lg text-rose-500 hover:bg-rose-50"><i class="fa-solid fa-trash"></i></button>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="option-row flex gap-3 items-center">
                            <input type="checkbox" name="correctIndex" value="0" class="correct-box w-4 h-4 accent-blue-600">
                            <input type="text" name="optionText" required placeholder="Option A"
                                   class="flex-1 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none">
                            <button type="button" onclick="this.closest('.option-row').remove(); renumber()" class="w-9 h-9 rounded-lg text-rose-500 hover:bg-rose-50"><i class="fa-solid fa-trash"></i></button>
                        </div>
                        <div class="option-row flex gap-3 items-center">
                            <input type="checkbox" name="correctIndex" value="1" class="correct-box w-4 h-4 accent-blue-600">
                            <input type="text" name="optionText" required placeholder="Option B"
                                   class="flex-1 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none">
                            <button type="button" onclick="this.closest('.option-row').remove(); renumber()" class="w-9 h-9 rounded-lg text-rose-500 hover:bg-rose-50"><i class="fa-solid fa-trash"></i></button>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="pt-4 border-t border-slate-100 flex gap-3">
            <button class="px-6 py-3 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-sm">Save Question</button>
            <a href="${pageContext.request.contextPath}/questions/manage" class="px-6 py-3 rounded-xl border border-slate-200 font-bold text-sm text-slate-700 hover:bg-slate-50">Cancel</a>
        </div>
    </form>
</main>

<script>
function renumber() {
    document.querySelectorAll('#optionRows .option-row').forEach(function(row,i) {
        const box=row.querySelector('.correct-box');
        if(box) box.value=i;
    });
}
function addOption() {
    const rows=document.getElementById('optionRows');
    const i=rows.querySelectorAll('.option-row').length;
    const row=document.createElement('div');
    row.className='option-row flex gap-3 items-center';
    row.innerHTML='<input type="checkbox" name="correctIndex" value="'+i+'" class="correct-box w-4 h-4 accent-blue-600">' +
        '<input type="text" name="optionText" required placeholder="Option '+String.fromCharCode(65+i)+'" class="flex-1 px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm outline-none">' +
        '<button type="button" onclick="this.closest(\'.option-row\').remove(); renumber()" class="w-9 h-9 rounded-lg text-rose-500 hover:bg-rose-50"><i class="fa-solid fa-trash"></i></button>';
    rows.appendChild(row);
}
function toggleOptions() {
    const type=document.getElementById('type').value;
    document.getElementById('optionsBox').style.display=(type==='text'?'none':'block');
    document.querySelectorAll('.correct-box').forEach(function(b){b.type=(type==='single_choice'?'radio':'checkbox');});
    document.querySelectorAll('input[name="optionText"]').forEach(function(i){i.disabled=(type==='text'); i.required=(type!=='text');});
    document.querySelectorAll('.correct-box').forEach(function(b){b.disabled=(type==='text');});
}
document.addEventListener('DOMContentLoaded', function(){renumber();toggleOptions();});
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
