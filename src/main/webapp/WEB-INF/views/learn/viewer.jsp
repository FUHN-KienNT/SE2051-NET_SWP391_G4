<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow py-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <!-- Lesson Content Area -->
        <div class="lg:col-span-3 space-y-6">
            <div class="bg-black rounded-2xl overflow-hidden aspect-video flex items-center justify-center shadow-lg">
                <c:choose>
                    <c:when test="${not empty lesson.videoUrl}">
                        <iframe class="w-full h-full" src="${lesson.videoUrl}" title="${lesson.name}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center text-slate-400 p-8">
                            <i class="fa-regular fa-file-lines text-5xl mb-3"></i>
                            <p class="text-lg font-semibold text-white">${lesson.name}</p>
                            <p class="text-sm">Bài học dạng tài liệu và bài tập đọc hiểu</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Lesson Info & Actions -->
            <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-center justify-between">
                <div>
                    <h1 class="text-2xl font-bold text-slate-900">${lesson.name}</h1>
                    <p class="text-sm text-slate-500 mt-1">Thời lượng ước tính: ${lesson.duration} phút</p>
                </div>
                <form action="${pageContext.request.contextPath}/learning-process" method="post">
                    <input type="hidden" name="action" value="complete">
                    <input type="hidden" name="lessonId" value="${lesson.id}">
                    <button type="submit" class="px-5 py-2.5 rounded-xl font-bold text-white ${process != null && process.isCompleted ? 'bg-emerald-600 hover:bg-emerald-700' : 'bg-blue-600 hover:bg-blue-700'} shadow-sm transition text-sm">
                        <i class="fa-solid fa-check mr-2"></i> ${process != null && process.isCompleted ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành'}
                    </button>
                </form>
            </div>

            <!-- Lesson Description -->
            <c:if test="${not empty lesson.content}">
                <div class="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                    <h2 class="text-lg font-bold text-slate-900 mb-3">Nội dung bài học</h2>
                    <div class="prose max-w-none text-slate-700 text-sm leading-relaxed whitespace-pre-wrap">${lesson.content}</div>
                </div>
            </c:if>
        </div>

        <!-- Sidebar Navigation -->
        <div class="lg:col-span-1 space-y-4">
            <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
                <h3 class="font-bold text-slate-900 mb-4">Điều hướng bài học</h3>
                <div class="space-y-3">
                    <c:if test="${not empty prevLesson}">
                        <a href="${pageContext.request.contextPath}/learning-process?lessonId=${prevLesson.id}" class="block w-full py-2.5 px-4 text-center rounded-xl font-semibold text-sm border border-slate-300 text-slate-700 hover:bg-slate-50 transition">
                            &larr; Bài trước
                        </a>
                    </c:if>
                    <c:if test="${not empty nextLesson}">
                        <a href="${pageContext.request.contextPath}/learning-process?lessonId=${nextLesson.id}" class="block w-full py-2.5 px-4 text-center rounded-xl font-semibold text-sm bg-blue-600 text-white hover:bg-blue-700 transition">
                            Bài kế tiếp &rarr;
                        </a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />