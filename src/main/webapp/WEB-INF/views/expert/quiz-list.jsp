<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="quiz" />
    </jsp:include>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-7xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">
                <!-- Header with Top Actions -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-slate-100">
                    <div>
                        <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-700 mb-1">
                            <a href="${pageContext.request.contextPath}/expert/dashboard" class="hover:underline">Dashboard</a>
                            <span>/</span>
                            <span class="text-slate-500">Quiz Management</span>
                        </div>
                        <h1 class="text-2xl sm:text-3xl font-black text-slate-900">Quản lý bài kiểm tra (Quiz)</h1>
                        <p class="text-xs text-slate-500 mt-1">Quản lý danh sách bài kiểm tra, cấu hình thời gian làm bài, điểm đạt và số lượng câu hỏi.</p>
                    </div>

                    <!-- TOP ACTIONS -->
                    <div class="flex flex-wrap items-center gap-2.5">
                        <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
                           class="inline-flex items-center px-4 py-2.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold rounded-xl text-sm shadow-sm transition">
                            <i class="fa-solid fa-list-check text-slate-500 mr-2 text-xs"></i>
                            <span>Ngân hàng câu hỏi</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/quiz/detail?courseId=${courseId}"
                           class="inline-flex items-center px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-sm shadow-sm transition">
                            <i class="fa-solid fa-plus mr-2 text-xs"></i>
                            <span>Tạo bài kiểm tra mới</span>
                        </a>
                    </div>
                </div>

                <!-- Feedback Alerts -->
                <c:if test="${param.saved == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-check text-emerald-600"></i>
                        <span>Lưu bài kiểm tra thành công!</span>
                    </div>
                </c:if>
                <c:if test="${param.hidden == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-eye-slash text-amber-600"></i>
                        <span>Đã ẩn bài kiểm tra. Dữ liệu và lịch sử làm bài thi của học viên được bảo toàn an toàn.</span>
                    </div>
                </c:if>
                <c:if test="${param.unhidden == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-eye text-emerald-600"></i>
                        <span>Đã khôi phục hiển thị bài kiểm tra thành công.</span>
                    </div>
                </c:if>
                <c:if test="${param.deleted == 'false'}">
                    <div class="mt-4 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-xmark text-rose-600"></i>
                        <span>Không thể thực hiện thao tác. Vui lòng kiểm tra lại.</span>
                    </div>
                </c:if>

                <!-- Filter Toolbar: Module, Status, Keyword -->
                <form method="get" action="${pageContext.request.contextPath}/quiz/manage" class="mt-6 p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-3">
                    <input type="hidden" name="courseId" value="${courseId}">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                        <!-- Module Filter -->
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Chương / Module</label>
                            <select name="moduleId" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                                <option value="">-- Tất cả Module --</option>
                                <c:forEach var="m" items="${modules}">
                                    <option value="${m.id}" ${moduleId eq m.id ? 'selected' : ''}><c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Status Filter -->
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
                            <input name="keyword" value="${keyword}" placeholder="Tìm kiếm tên bài kiểm tra..."
                                   class="w-full pl-9 pr-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500 transition">
                        </div>
                        <div class="flex items-center gap-2 shrink-0 w-full sm:w-auto">
                            <button type="submit" class="flex-1 sm:flex-none px-5 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs shadow-sm transition">
                                <i class="fa-solid fa-filter mr-1.5"></i>Lọc Quiz
                            </button>
                            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}"
                               class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 font-bold text-xs transition">
                                Đặt lại
                            </a>
                        </div>
                    </div>
                </form>

                <!-- Quiz Data Table -->
                <div class="mt-6 overflow-x-auto border border-slate-200 rounded-2xl">
                    <table class="w-full text-left text-sm text-slate-600">
                        <thead class="bg-slate-50 text-slate-700 text-xs font-bold border-b border-slate-200">
                        <tr>
                            <th class="px-5 py-4 w-12 text-center">#</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Bài kiểm tra</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Chương &amp; Khóa học</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Thông số bài thi</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Trạng thái</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800 w-36">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                        <c:choose>
                            <c:when test="${not empty quizzes}">
                                <c:forEach var="q" items="${quizzes}" varStatus="st">
                                    <tr class="hover:bg-slate-50/80 transition-colors ${q.hidden ? 'bg-slate-50/50 opacity-75' : ''}">
                                        <td class="px-5 py-4 text-center font-bold text-slate-400 text-xs">${st.count}</td>

                                        <!-- Quiz Info (Thumbnail + Title) -->
                                        <td class="px-5 py-4 max-w-xs sm:max-w-md">
                                            <div class="flex items-center gap-3.5">
                                                <div class="w-12 h-12 rounded-xl border border-slate-200 bg-slate-100 flex items-center justify-center overflow-hidden shrink-0 shadow-xs">
                                                    <c:choose>
                                                        <c:when test="${not empty q.imageUrl}">
                                                            <img src="${q.imageUrl}" alt="${q.title}" referrerpolicy="no-referrer"
                                                                 class="w-full h-full object-cover"
                                                                 onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=100&auto=format&fit=crop&q=80';">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="w-full h-full bg-emerald-50 text-emerald-700 flex items-center justify-center font-bold">
                                                                <i class="fa-solid fa-clipboard-question text-base"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="min-w-0 flex-1">
                                                    <a href="${pageContext.request.contextPath}/quiz/detail?id=${q.id}&courseId=${courseId}"
                                                       class="font-bold text-slate-900 hover:text-emerald-700 transition leading-snug line-clamp-2 text-sm">
                                                        ${q.title}
                                                    </a>
                                                </div>
                                            </div>
                                        </td>

                                        <!-- Module & Course badges -->
                                        <td class="px-5 py-4">
                                            <div class="space-y-1">
                                                <c:choose>
                                                    <c:when test="${not empty q.moduleTitle}">
                                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-slate-100 text-slate-700 border border-slate-200">
                                                            <i class="fa-solid fa-folder text-slate-400 mr-1 text-[10px]"></i>${q.moduleTitle}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-xs text-slate-400 italic">Chưa chọn module</span>
                                                    </c:otherwise>
                                                </c:choose>
                                                <c:if test="${not empty q.courseTitle}">
                                                    <div class="text-[11px] text-slate-400 flex items-center gap-1 font-medium">
                                                        <i class="fa-solid fa-book-open text-[10px]"></i>
                                                        <span class="line-clamp-1">${q.courseTitle}</span>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </td>

                                        <!-- Stats: Question Count, Time Limit, Pass Score -->
                                        <td class="px-5 py-4 text-center">
                                            <div class="inline-flex flex-col items-center gap-1">
                                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-indigo-50 text-indigo-700 border border-indigo-200">
                                                    <i class="fa-solid fa-list-ol mr-1 text-[10px]"></i>${q.questionCount} câu
                                                </span>
                                                <div class="flex items-center justify-center gap-2 text-[11px] text-slate-500 font-medium">
                                                    <span title="Thời gian làm bài">
                                                        <i class="fa-regular fa-clock text-slate-400 mr-0.5"></i>
                                                        ${empty q.timeLimit ? 'Không giới hạn' : q.timeLimit += 'p'}
                                                    </span>
                                                    <span class="text-slate-300">•</span>
                                                    <span title="Điểm đạt qua môn">
                                                        <i class="fa-solid fa-award text-amber-500 mr-0.5"></i>
                                                        Đạt: <strong class="text-slate-700 font-bold">${q.passScore}</strong>/10
                                                    </span>
                                                </div>
                                            </div>
                                        </td>

                                        <!-- Status -->
                                        <td class="px-5 py-4 text-center whitespace-nowrap">
                                            <c:choose>
                                                <c:when test="${q.status eq 'published'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-1.5"></span>Công khai
                                                    </span>
                                                </c:when>
                                                <c:when test="${q.status eq 'draft'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500 mr-1.5"></span>Bản nháp
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-600 border border-slate-300">
                                                        <span class="w-1.5 h-1.5 rounded-full bg-slate-400 mr-1.5"></span>Đã ẩn
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Actions -->
                                        <td class="px-5 py-4 text-center whitespace-nowrap">
                                            <div class="flex items-center justify-center gap-1.5">
                                                <a href="${pageContext.request.contextPath}/quiz/detail?id=${q.id}&courseId=${courseId}"
                                                   class="inline-flex items-center px-3 py-1.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-bold text-xs shadow-xs transition">
                                                    <i class="fa-solid fa-pen-to-square mr-1 text-slate-400"></i>Sửa
                                                </a>

                                                <c:choose>
                                                    <c:when test="${q.hidden}">
                                                        <a href="${pageContext.request.contextPath}/quiz/manage?action=unhide&id=${q.id}&courseId=${courseId}"
                                                           class="inline-flex items-center px-3 py-1.5 rounded-xl bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100 font-bold text-xs transition"
                                                           title="Bỏ ẩn để hiển thị lại quiz">
                                                            <i class="fa-solid fa-eye mr-1 text-emerald-600"></i>Hiện
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button" onclick="confirmHideQuiz('${q.id}', '${courseId}')"
                                                                class="inline-flex items-center px-3 py-1.5 rounded-xl border border-amber-200 bg-amber-50 text-amber-700 hover:bg-amber-100 font-bold text-xs transition"
                                                                title="Ẩn bài quiz để bảo toàn kết quả cũ">
                                                            <i class="fa-solid fa-eye-slash mr-1 text-amber-500"></i>Ẩn
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="px-6 py-16 text-center text-slate-400 text-sm">
                                        <div class="flex flex-col items-center justify-center">
                                            <div class="w-14 h-14 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center text-2xl mb-3">
                                                <i class="fa-regular fa-folder-open"></i>
                                            </div>
                                            <span class="font-bold text-slate-700 text-base mb-1">Chưa tìm thấy bài kiểm tra nào</span>
                                            <span class="text-xs text-slate-500 mb-4 max-w-sm">Không có bài kiểm tra nào phù hợp với bộ lọc hiện tại của bạn.</span>
                                            <a href="${pageContext.request.contextPath}/quiz/detail?courseId=${courseId}"
                                               class="inline-flex items-center px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs shadow-sm transition">
                                                <i class="fa-solid fa-plus mr-1.5"></i>Tạo bài kiểm tra đầu tiên
                                            </a>
                                        </div>
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

<!-- ========================================== -->
<!-- MODAL: CONFIRM HIDE QUIZ                   -->
<!-- ========================================== -->
<div id="hideConfirmModal" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-md p-6 animate-in fade-in zoom-in-95 duration-150">
        <div class="w-12 h-12 rounded-2xl bg-amber-100 text-amber-700 flex items-center justify-center text-xl mb-4">
            <i class="fa-solid fa-eye-slash"></i>
        </div>
        <h3 class="font-black text-lg text-slate-900 mb-2">Ẩn bài kiểm tra này?</h3>
        <p class="text-xs text-slate-600 leading-relaxed mb-6">
            Học viên sẽ không thấy bài kiểm tra này trong danh sách bài thi nữa. <strong>Lịch sử làm bài và điểm số của học viên đã thi trước đó được bảo toàn an toàn</strong> và bạn có thể khôi phục lại bất kỳ lúc nào.
        </p>
        <div class="flex items-center justify-end gap-3">
            <button type="button" onclick="closeHideModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-xs hover:bg-slate-50 transition">Hủy bỏ</button>
            <a id="confirmHideLink" href="#" class="px-5 py-2.5 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-sm transition">
                Xác nhận Ẩn
            </a>
        </div>
    </div>
</div>

<script>
    function confirmHideQuiz(quizId, courseId) {
        let url = '${pageContext.request.contextPath}/quiz/manage?action=hide&id=' + quizId;
        if (courseId) {
            url += '&courseId=' + courseId;
        }
        document.getElementById('confirmHideLink').href = url;
        document.getElementById('hideConfirmModal').classList.remove('hidden');
    }

    function closeHideModal() {
        document.getElementById('hideConfirmModal').classList.add('hidden');
    }
</script>

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
