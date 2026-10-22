<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="quiz" />
    </jsp:include>

    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-7xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
                <!-- Header bar with Create Quiz at TOP -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-slate-100">
                    <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-700">
                        <a href="${pageContext.request.contextPath}/expert/dashboard"
                           class="hover:underline">
                            <i class="fa-solid fa-arrow-left text-xs transition-transform group-hover:-translate-x-1"></i>
                            <span>Dashboard</span>
                        </a>
                        <h1 class="text-2xl sm:text-3xl font-black text-slate-900">Quiz List</h1>
                    </div>

                    <!-- Create Quiz Button at Top -->
                    <a href="${pageContext.request.contextPath}/quiz/detail?courseId=${courseId}"
                       class="inline-flex items-center px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-sm shadow-sm transition">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>Create Quiz</span>
                    </a>
                </div>

                <!-- Feedback Alerts -->
                <c:if test="${param.saved == 'true'}">
                    <div class="mb-5 p-3.5 rounded-lg bg-emerald-50 border border-emerald-200 text-status-success text-sm font-semibold flex items-center gap-2">
                        <i class="fa-solid fa-circle-check"></i>
                        <span>Đã lưu Quiz thành công.</span>
                    </div>
                </c:if>
                <c:if test="${param.hidden == 'true'}">
                    <div class="mb-5 p-3.5 rounded-lg bg-slate-100 border border-slate-300 text-slate-700 text-sm font-semibold flex items-center gap-2">
                        <i class="fa-solid fa-eye-slash"></i>
                        <span>Đã ẩn Quiz thành công. Dữ liệu làm bài cũ của học viên được giữ an toàn.</span>
                    </div>
                </c:if>
                <c:if test="${param.unhidden == 'true'}">
                    <div class="mb-5 p-3.5 rounded-lg bg-emerald-50 border border-emerald-200 text-status-success text-sm font-semibold flex items-center gap-2">
                        <i class="fa-solid fa-eye"></i>
                        <span>Đã hiển thị lại Quiz thành công.</span>
                    </div>
                </c:if>

                <!-- Filter Toolbar: aligned with Question Bank -->
                <form method="get" action="${pageContext.request.contextPath}/quiz/manage" class="mt-6 mb-6 p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-3">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Chương / Module</label>
                            <select name="moduleId" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                                <option value="">-- Tất cả Module --</option>
                                <c:forEach var="m" items="${modules}">
                                    <option value="${m.id}" ${moduleId eq m.id ? 'selected' : ''}><c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Trạng thái</label>
                            <select name="status" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                                <option value="">-- Tất cả trạng thái --</option>
                                <option value="published" ${status eq 'published' ? 'selected' : ''}>Công khai (Published)</option>
                                <option value="draft" ${status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft)</option>
                                <option value="hidden" ${status eq 'hidden' ? 'selected' : ''}>Đã ẩn (Hidden)</option>
                            </select>
                        </div>
                    </div>
                    <div class="flex flex-col sm:flex-row gap-3 pt-1 items-center">
                        <div class="relative flex-1 w-full">
                            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-slate-400 text-xs"></i>
                            <input name="keyword" value="${keyword}" placeholder="Tìm kiếm tên quiz..." class="w-full pl-9 pr-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500 transition">
                        </div>
                        <div class="flex items-center gap-2 shrink-0 w-full sm:w-auto">
                            <button type="submit" class="flex-1 sm:flex-none px-5 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs shadow-sm transition"><i class="fa-solid fa-filter mr-1.5"></i>Lọc Quiz</button>
                            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}" class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 font-bold text-xs transition">Đặt lại</a>
                        </div>
                    </div>
                </form>

                <!-- Quiz Table -->
                <div class="overflow-x-auto border border-slate-200 rounded-2xl">
                    <table class="w-full text-left text-sm text-slate-600">
                        <thead class="bg-slate-50 text-slate-700 text-xs font-bold border-b border-slate-200">
                        <tr>
                            <th class="px-4 py-3.5 w-12 text-center">#</th>
                            <th class="px-4 py-3.5 w-16 text-center">Ảnh</th>
                            <th class="px-4 py-3.5 font-bold text-slate-900">Khóa &amp; Module</th>
                            <th class="px-4 py-3.5 font-bold text-slate-900">Tên Quiz</th>
                            <th class="px-4 py-3.5 text-center font-bold text-text-primary">Số câu</th>
                            <th class="px-4 py-3.5 text-center font-bold text-text-primary">Thời gian</th>
                            <th class="px-4 py-3.5 text-center font-bold text-text-primary">Điểm đạt</th>
                            <th class="px-4 py-3.5 text-center font-bold text-text-primary">Trạng thái</th>
                            <th class="px-4 py-3.5 text-center font-bold text-text-primary w-36">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-border-default">
                        <c:choose>
                            <c:when test="${not empty quizzes}">
                                <c:forEach var="q" items="${quizzes}" varStatus="st">
                                    <tr class="hover:bg-surface/80 transition-colors ${q.hidden ? 'opacity-60 bg-slate-50' : ''}">
                                        <td class="px-4 py-3.5 text-center font-bold text-text-secondary text-xs">${st.index + 1}</td>

                                        <!-- Quiz Thumbnail -->
                                        <td class="px-4 py-3.5 text-center">
                                            <c:choose>
                                                <c:when test="${not empty q.imageUrl}">
                                                    <img src="${q.imageUrl}" alt="Quiz Image"
                                                         class="w-10 h-10 object-cover rounded-lg border border-border-default mx-auto shadow-xs"
                                                         onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100';">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="w-10 h-10 rounded-lg bg-brand-50 border border-brand-100 flex items-center justify-center text-brand-700 mx-auto">
                                                        <i class="fa-solid fa-file-lines text-sm"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Course & Module -->
                                        <td class="px-4 py-3.5">
                                            <div class="text-xs font-bold text-text-primary line-clamp-1">${q.courseTitle}</div>
                                            <div class="text-xs text-text-secondary line-clamp-1">${q.moduleTitle}</div>
                                        </td>

                                        <!-- Quiz Title -->
                                        <td class="px-4 py-3.5 font-semibold text-text-primary">
                                            <div class="flex items-center space-x-2">
                                                <i class="fa-regular fa-circle-question text-brand-700 text-sm"></i>
                                                <span>${q.title}</span>
                                            </div>
                                        </td>

                                        <!-- Question count -->
                                        <td class="px-4 py-3.5 text-center font-semibold text-text-primary">${q.questionCount}</td>

                                        <!-- Time limit -->
                                        <td class="px-4 py-3.5 text-center">${empty q.timeLimit ? 'Không giới hạn' : q.timeLimit} <c:if test="${not empty q.timeLimit}">phút</c:if></td>

                                        <!-- Pass score -->
                                        <td class="px-4 py-3.5 text-center font-bold text-text-primary">${q.passScore}</td>

                                        <!-- Status Badge -->
                                        <td class="px-4 py-3.5 text-center whitespace-nowrap">
                                            <c:choose>
                                                <c:when test="${q.status eq 'published'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-brand-50 text-status-success border border-brand-100">
                                                        <span class="w-1.5 h-1.5 rounded-full bg-status-success mr-1.5"></span>Công khai
                                                    </span>
                                                </c:when>
                                                <c:when test="${q.status eq 'draft'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-amber-50 text-status-warning border border-amber-200">
                                                        <span class="w-1.5 h-1.5 rounded-full bg-status-warning mr-1.5"></span>Bản nháp
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-600 border border-slate-300">
                                                        <span class="w-1.5 h-1.5 rounded-full bg-slate-400 mr-1.5"></span>Đã ẩn
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Action -->
                                        <td class="px-4 py-3.5 text-center space-x-2 text-xs font-semibold whitespace-nowrap">
                                            <a href="${pageContext.request.contextPath}/quiz/detail?id=${q.id}&courseId=${courseId}"
                                               class="inline-flex items-center px-2.5 py-1.5 rounded-lg bg-surface border border-border-default text-brand-700 hover:bg-brand-50 transition">
                                                <i class="fa-solid fa-pen-to-square mr-1"></i>Sửa
                                            </a>

                                            <c:choose>
                                                <c:when test="${q.hidden}">
                                                    <a href="${pageContext.request.contextPath}/quiz/manage?action=unhide&id=${q.id}&courseId=${courseId}"
                                                       class="inline-flex items-center px-2.5 py-1.5 rounded-lg bg-emerald-50 text-status-success border border-emerald-200 hover:bg-emerald-100 transition"
                                                       title="Bỏ ẩn để hiển thị lại quiz">
                                                        <i class="fa-solid fa-eye mr-1"></i>Hiện
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/quiz/manage?action=hide&id=${q.id}&courseId=${courseId}"
                                                       class="inline-flex items-center px-2.5 py-1.5 rounded-lg bg-slate-100 text-slate-700 border border-slate-300 hover:bg-slate-200 transition"
                                                       data-confirm="Bạn có chắc chắn muốn ẩn quiz này không? Học viên sẽ không thấy bài thi này nữa, nhưng bài nộp cũ sẽ được bảo toàn."
                                                       data-confirm-title="Ẩn Quiz"
                                                       data-confirm-btn="Ẩn Quiz"
                                                       data-confirm-type="warning"
                                                       title="Ẩn bài quiz để bảo toàn kết quả cũ">
                                                        <i class="fa-solid fa-eye-slash mr-1"></i>Ẩn
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" class="px-6 py-12 text-center text-text-secondary text-sm">
                                        <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300"></i>
                                        Chưa tìm thấy bài Quiz nào phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
