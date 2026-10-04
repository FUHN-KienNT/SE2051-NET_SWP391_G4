<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-16 flex flex-col lg:flex-row gap-6">
    <aside class="w-full lg:w-52 shrink-0">
        <div class="bg-surface-card rounded-xl border border-border-default overflow-hidden shadow-sm">
            <nav class="flex flex-wrap lg:flex-col p-2 gap-1">
                <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${course.id}"
                   class="flex items-center space-x-2.5 rounded-lg px-4 py-3 text-sm font-bold bg-brand-50 text-brand-900 border-l-4 border-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-book-open text-brand-700 text-sm"></i>
                    <span>Lesson</span>
                </a>
                <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${course.id}"
                   class="flex items-center space-x-2.5 rounded-lg px-4 py-3 text-sm font-medium text-text-secondary hover:bg-surface hover:text-text-primary transition border-l-4 border-transparent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-clipboard-question text-text-secondary text-sm"></i>
                    <span>Quiz</span>
                </a>
                <a href="${pageContext.request.contextPath}/questions/manage?courseId=${course.id}"
                   class="flex items-center space-x-2.5 rounded-lg px-4 py-3 text-sm font-medium text-text-secondary hover:bg-surface hover:text-text-primary transition border-l-4 border-transparent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-list-check text-text-secondary text-sm"></i>
                    <span>Question Bank</span>
                </a>
            </nav>
        </div>
    </aside>

    <div class="flex-1 min-w-0">
        <div class="bg-surface-card rounded-xl border border-border-default shadow-sm p-6 sm:p-8">
            <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <a href="${pageContext.request.contextPath}/expert/dashboard"
                               class="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-lg border border-border-default bg-surface-card hover:bg-surface text-text-secondary hover:text-text-primary transition text-sm font-semibold shadow-sm group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                <i class="fa-solid fa-arrow-left text-xs transition-transform group-hover:-translate-x-1"></i>
                                <span>Quay lại</span>
                            </a>
                            <h1 class="text-xl sm:text-2xl font-bold text-text-primary">Lesson List</h1>
                            <div class="hidden sm:block w-24"></div>
                        </div>
            <div class="overflow-x-auto border border-border-default rounded-xl">
                <table class="w-full text-left text-sm text-text-secondary">
                    <thead class="bg-surface text-slate-700 text-xs font-bold border-b border-border-default">
                        <tr>
                            <th class="px-5 py-4 w-14 text-center">#</th>
                            <th class="px-5 py-4 font-bold text-text-primary">Module</th>
                            <th class="px-5 py-4 font-bold text-text-primary">Lesson Title</th>
                            <th class="px-5 py-4 text-center font-bold text-text-primary w-36">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-border-default">
                        <c:choose>
                            <c:when test="${not empty modules}">
                                <c:set var="globalIndex" value="1" />
                                <c:forEach var="module" items="${modules}">
                                    <c:choose>
                                        <c:when test="${not empty module.lessons}">
                                            <c:forEach var="les" items="${module.lessons}">
                                                <tr class="hover:bg-surface/80 transition-colors">
                                                    <td class="px-5 py-4 text-center font-bold text-text-secondary text-xs">
                                                        ${globalIndex}
                                                    </td>
                                                    <td class="px-5 py-4 font-semibold text-text-primary text-xs">
                                                        ${module.title}
                                                    </td>
                                                    <td class="px-5 py-4 font-medium text-text-primary">
                                                        <div class="flex items-center space-x-2.5">
                                                            <i class="fa-regular fa-circle-play text-brand-700 text-sm"></i>
                                                            <span>${les.title}</span>
                                                        </div>
                                                    </td>
                                                    <td class="px-5 py-4 text-center space-x-3 text-xs font-semibold whitespace-nowrap">
                                                        <a href="${pageContext.request.contextPath}/lessons/manage?action=edit&id=${les.id}&courseId=${course.id}"
                                                           class="inline-flex rounded-lg px-3 py-2 text-brand-700 hover:bg-brand-50 hover:text-brand-800 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Edit</a>
                                                        <a href="${pageContext.request.contextPath}/lessons/manage?action=delete&id=${les.id}&courseId=${course.id}"
                                                           class="inline-flex rounded-lg px-3 py-2 text-status-danger hover:bg-red-50 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2"
                                                           onclick="return confirm('Bạn có chắc chắn muốn xóa bài giảng này không?');">Delete</a>
                                                    </td>
                                                </tr>
                                                <c:set var="globalIndex" value="${globalIndex + 1}" />
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr class="bg-surface/40">
                                                <td class="px-5 py-3.5 text-center text-slate-300 text-xs">-</td>
                                                <td class="px-5 py-3.5 font-semibold text-text-secondary text-xs">${module.title}</td>
                                                <td colspan="2" class="px-5 py-3.5 text-xs text-text-secondary italic">
                                                    Chưa có bài học nào trong chương này
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="px-6 py-12 text-center text-text-secondary text-sm">
                                        <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300"></i>
                                        Khóa học này hiện chưa có module hoặc bài giảng nào.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <div class="mt-6 flex justify-end">
                <a href="${pageContext.request.contextPath}/lessons/manage?action=create&courseId=${course.id}"
                   class="inline-flex items-center px-5 py-2.5 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-lg text-sm transition shadow-sm space-x-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-plus text-xs"></i>
                    <span>Create Lesson</span>
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />