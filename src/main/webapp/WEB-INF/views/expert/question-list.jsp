<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="questions" />
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
                            <span class="text-slate-500">Question Bank</span>
                        </div>
                        <h1 class="text-2xl sm:text-3xl font-black text-slate-900">Ngân hàng câu hỏi</h1>
                        <p class="text-xs text-slate-500 mt-1">Quản lý câu hỏi trắc nghiệm và điền vào chỗ trống cho các kỳ kiểm tra.</p>
                    </div>

                    <!-- TOP ACTIONS -->
                    <div class="flex flex-wrap items-center gap-2.5">
                        <button type="button" onclick="openImportModal()"
                                class="inline-flex items-center px-4 py-2.5 bg-white border border-border-default hover:bg-surface text-text-primary font-semibold rounded-lg text-sm focus-visible:ring-2 focus-visible:ring-brand-700 transition shadow-sm">
                            <i class="fa-solid fa-file-import mr-2 text-emerald-600" aria-hidden="true"></i>Import từ Excel
                        </button>
                        <!-- Create Question Button -->
                        <a href="${pageContext.request.contextPath}/expert/questions/detail?courseId=${courseId}"
                           class="inline-flex items-center px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-sm shadow-sm transition">
                            <i class="fa-solid fa-plus mr-2 text-xs"></i>
                            <span>Tạo câu hỏi mới</span>
                        </a>
                    </div>
                </div>

                <!-- Feedback Alerts -->
                <c:if test="${param.saved == 'true'}">
                <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                    <i class="fa-solid fa-circle-check text-emerald-600"></i>
                    <span>Lưu câu hỏi thành công!</span>
                </div>
                </c:if>
                <c:if test="${param.deleted == 'true'}">
                <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                    <i class="fa-solid fa-circle-check text-emerald-600"></i>
                    <span>Đã xóa vĩnh viễn câu hỏi thành công!</span>
                </div>
                </c:if>
                <c:if test="${param.cannotDelete == 'true'}">
                <div class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm font-semibold flex items-center gap-2.5">
                    <i class="fa-solid fa-triangle-exclamation text-amber-600"></i>
                    <span>Câu hỏi này đã được sử dụng trong bài thi nên không thể xóa vĩnh viễn. Bạn chỉ có thể ẩn câu hỏi để bảo vệ dữ liệu.</span>
                </div>
                </c:if>
                <c:if test="${param.hidden == 'true'}">
                <div class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm font-semibold flex items-center gap-2.5">
                    <i class="fa-solid fa-eye-slash text-amber-600"></i>
                    <span>Đã ẩn câu hỏi. Lịch sử làm bài thi của học viên được bảo toàn an toàn.</span>
                </div>
                </c:if>
                <c:if test="${param.unhidden == 'true'}">
                <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                    <i class="fa-solid fa-eye text-emerald-600"></i>
                    <span>Đã khôi phục hiển thị câu hỏi thành công.</span>
                </div>
                </c:if>
                <c:if test="${param.deleted == 'false'}">
                <div class="mt-4 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm font-semibold flex items-center gap-2.5">
                    <i class="fa-solid fa-circle-xmark text-rose-600"></i>
                    <span>Không thể xóa câu hỏi. Vui lòng kiểm tra lại.</span>
                </div>
                </c:if>

                <!-- Import result: success summary or the full list of file errors -->
                <c:if test="${not empty importResult}">
                <c:choose>
                <c:when test="${importResult.success}">
                <div role="status" class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm">
                    <div class="font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-check text-emerald-600" aria-hidden="true"></i>
                        <span>Import thành công ${importResult.importedCount} câu hỏi<c:if test="${not empty importResult.moduleTitle}"> vào module "<c:out value="${importResult.moduleTitle}"/>"</c:if>.</span>
                    </div>
                    <ul class="mt-2 ml-7 list-disc text-xs space-y-0.5">
                        <c:if test="${importResult.singleCount > 0}"><li>${importResult.singleCount} câu một đáp án (single choice)</li></c:if>
                        <c:if test="${importResult.multipleCount > 0}"><li>${importResult.multipleCount} câu nhiều đáp án (multiple choice)</li></c:if>
                        <c:if test="${importResult.fillCount > 0}"><li>${importResult.fillCount} câu điền vào chỗ trống</li></c:if>
                        <c:if test="${not empty importResult.fileName}"><li>File: <c:out value="${importResult.fileName}"/></li></c:if>
                    </ul>
                </div>
                </c:when>
                <c:otherwise>
                <div role="alert" class="mt-4 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm">
                    <div class="font-semibold flex items-start gap-2.5">
                        <i class="fa-solid fa-circle-xmark text-rose-600 mt-0.5" aria-hidden="true"></i>
                        <span>Import không thành công, chưa có câu hỏi nào được lưu. Vui lòng sửa ${importResult.errorCount} lỗi dưới đây rồi tải lại file<c:if test="${not empty importResult.fileName}"> (<c:out value="${importResult.fileName}"/>)</c:if>:</span>
                    </div>
                    <ul class="mt-3 ml-7 list-disc space-y-1 text-xs max-h-64 overflow-y-auto pr-2">
                        <c:forEach var="err" items="${importResult.errors}"><li><c:out value="${err}"/></li></c:forEach>
                    </ul>
                    <c:if test="${importResult.hiddenErrorCount > 0}">
                        <p class="mt-2 ml-7 text-xs font-semibold">... và ${importResult.hiddenErrorCount} lỗi khác. Hãy sửa các lỗi trên rồi import lại để xem tiếp.</p>
                    </c:if>
                </div>
                </c:otherwise>
                </c:choose>
                </c:if>
                <!-- Filter Toolbar: Course, Module, Type, Status, Keyword -->
                <form method="get" action="${pageContext.request.contextPath}/expert/questions" class="mt-6 p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-3">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                        <input type="hidden" name="courseId" value="${courseId}">

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

                        <!-- Question Type Filter -->
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Loại câu hỏi</label>
                            <select name="type" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                                <option value="">-- Tất cả loại câu hỏi --</option>
                                <option value="fill_in_blank" ${type eq 'fill_in_blank' or type eq 'text' ? 'selected' : ''}>Điền vào chỗ trống</option>
                                <option value="single_choice" ${type eq 'single_choice' ? 'selected' : ''}>Một đáp án (Single choice)</option>
                                <option value="multiple_choice" ${type eq 'multiple_choice' ? 'selected' : ''}>Nhiều đáp án (Multiple choice)</option>
                            </select>
                        </div>

                        <!-- Status Filter -->
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Trạng thái</label>
                            <select name="status" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                                <option value="">-- Tất cả trạng thái --</option>
                                <option value="public" ${status eq 'public' ? 'selected' : ''}>Công khai (Public)</option>
                                <option value="draft" ${status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft)</option>
                                <option value="hidden" ${status eq 'hidden' ? 'selected' : ''}>Đã ẩn (Hidden)</option>
                            </select>
                        </div>
                    </div>

                    <div class="flex flex-col sm:flex-row gap-3 pt-1 items-center">
                        <div class="relative flex-1 w-full">
                            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-slate-400 text-xs"></i>
                            <input name="keyword" value="${keyword}" placeholder="Tìm kiếm nội dung câu hỏi..."
                                   class="w-full pl-9 pr-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500 transition">
                        </div>
                        <div class="flex items-center gap-2 shrink-0 w-full sm:w-auto">
                            <button type="submit" class="flex-1 sm:flex-none px-5 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs shadow-sm transition">
                                <i class="fa-solid fa-filter mr-1.5"></i>Lọc câu hỏi
                            </button>
                            <a href="${pageContext.request.contextPath}/expert/questions?courseId=${courseId}"
                               class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 font-bold text-xs transition">
                                Đặt lại
                            </a>
                        </div>
                    </div>
                </form>

                <!-- Question Data Table -->
                <div class="mt-6 overflow-x-auto border border-slate-200 rounded-2xl">
                    <table class="w-full text-left text-sm text-slate-600">
                        <thead class="bg-slate-50 text-slate-700 text-xs font-bold border-b border-slate-200">
                        <tr>
                            <th class="px-5 py-4 w-12 text-center">#</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Nội dung câu hỏi</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Module & Khóa học</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Loại câu hỏi</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Trạng thái</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Đáp án</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800 w-36">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                        <c:choose>
                            <c:when test="${not empty questions}">
                                <c:forEach var="q" items="${questions}" varStatus="s">
                                    <tr class="hover:bg-slate-50/80 transition-colors ${q.status eq 'hidden' ? 'bg-slate-50/50 opacity-75' : ''}">
                                        <td class="px-5 py-4 text-center font-bold text-slate-400 text-xs">${s.count}</td>
                                        <td class="px-5 py-4 max-w-md">
                                            <div class="font-semibold text-slate-900 leading-snug line-clamp-2">
                                                    ${q.content}
                                            </div>
                                        </td>
                                        <td class="px-5 py-4">
                                            <c:choose>
                                                <c:when test="${not empty q.moduleTitle}">
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-slate-100 text-slate-700 border border-slate-200">
                                                        <i class="fa-solid fa-folder text-slate-400 mr-1 text-[10px]"></i>${q.moduleTitle}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-xs text-slate-400 italic">Chưa gán module</span>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty q.courseTitle}">
                                                <div class="text-[11px] text-slate-400 mt-1 line-clamp-1">${q.courseTitle}</div>
                                            </c:if>
                                        </td>
                                        <td class="px-5 py-4">
                                            <c:choose>
                                                <c:when test="${q.type eq 'fill_in_blank' or q.type eq 'text'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-purple-50 text-purple-700 text-xs font-bold border border-purple-200 whitespace-nowrap">
                                                        <i class="fa-solid fa-pen-nib mr-1.5 text-[10px]"></i>Điền chỗ trống
                                                    </span>
                                                </c:when>
                                                <c:when test="${q.type eq 'multiple_choice'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-indigo-50 text-indigo-700 text-xs font-bold border border-indigo-200 whitespace-nowrap">
                                                        <i class="fa-solid fa-list-check mr-1.5 text-[10px]"></i>Nhiều đáp án
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-blue-50 text-blue-700 text-xs font-bold border border-blue-200 whitespace-nowrap">
                                                        <i class="fa-solid fa-circle-dot mr-1.5 text-[10px]"></i>1 đáp án
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="px-5 py-4 text-center">
                                            <c:choose>
                                                <c:when test="${q.status eq 'hidden'}">
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-bold bg-slate-100 text-slate-600 border border-slate-300">
                                                        <i class="fa-solid fa-eye-slash mr-1 text-[10px]"></i>Đã ẩn
                                                    </span>
                                                </c:when>
                                                <c:when test="${q.status eq 'draft'}">
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                                        <i class="fa-solid fa-pen-ruler mr-1 text-[10px]"></i>Bản nháp
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                        <i class="fa-solid fa-circle-check mr-1 text-[10px]"></i>Công khai
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${q.quizCount > 0}">
                                                    <div class="mt-1">
                                                        <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200" title="Đã được sử dụng trong ${q.quizCount} đề thi (chỉ có thể ẩn)">
                                                            <i class="fa-solid fa-link mr-1 text-[8px]"></i>Đã dùng (${q.quizCount})
                                                        </span>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="mt-1">
                                                        <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-slate-100 text-slate-500" title="Chưa gán vào đề thi nào (có thể xóa)">
                                                            Chưa dùng
                                                        </span>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="px-5 py-4 text-center font-bold text-slate-700 text-xs">
                                            <span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-slate-100 text-slate-700 font-bold">
                                                    ${q.options.size()}
                                            </span>
                                        </td>
                                        <td class="px-5 py-4 text-center space-x-2 text-xs font-semibold whitespace-nowrap">
                                            <a href="${pageContext.request.contextPath}/expert/questions/detail?id=${q.id}&courseId=${courseId}"
                                               class="inline-flex items-center px-2.5 py-1 rounded-lg border border-slate-200 text-emerald-700 hover:bg-emerald-50 font-bold transition">
                                                <i class="fa-solid fa-pen mr-1 text-[10px]"></i>Sửa
                                            </a>

                                            <!-- Thao tác Ẩn / Hiện / Xóa -->
                                            <c:choose>
                                                <%-- Câu hỏi ĐÃ ĐƯỢC DÙNG (q.quizCount > 0): Chỉ có thể Ẩn hoặc Hiện --%>
                                                <c:when test="${q.quizCount > 0}">
                                                    <c:choose>
                                                        <c:when test="${q.status eq 'hidden'}">
                                                            <a href="${pageContext.request.contextPath}/expert/questions?action=unhide&id=${q.id}&courseId=${courseId}"
                                                               class="inline-flex items-center px-2.5 py-1 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 font-bold transition"
                                                               title="Khôi phục hiển thị câu hỏi">
                                                                <i class="fa-solid fa-eye mr-1 text-[10px]"></i>Hiện
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button"
                                                                    onclick="confirmHideQuestion('${q.id}', '${courseId}')"
                                                                    class="inline-flex items-center px-2.5 py-1 rounded-lg border border-amber-200 bg-amber-50 text-amber-700 hover:bg-amber-100 font-bold transition"
                                                                    title="Câu hỏi đã được dùng trong đề thi: Chỉ có thể ẩn để bảo toàn dữ liệu bài thi">
                                                                <i class="fa-solid fa-eye-slash mr-1 text-[10px]"></i>Ẩn
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>

                                                <%-- Câu hỏi CHƯA ĐƯỢC DÙNG (q.quizCount == 0): Có thể XÓA VĨNH VIỄN --%>
                                                <c:otherwise>
                                                    <button type="button"
                                                            onclick="confirmDeleteQuestion('${q.id}', '${courseId}')"
                                                            class="inline-flex items-center px-2.5 py-1 rounded-lg border border-rose-200 text-rose-600 hover:bg-rose-50 font-bold transition"
                                                            title="Xóa vĩnh viễn câu hỏi chưa được dùng">
                                                        <i class="fa-solid fa-trash mr-1 text-[10px]"></i>Xóa
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="px-6 py-16 text-center text-slate-400 text-sm">
                                        <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300"></i>
                                        Không tìm thấy câu hỏi nào.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
        </main>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: CONFIRM DELETE QUESTION             -->
<!-- ========================================== -->
<div id="deleteConfirmModal" onclick="if(event.target === this) closeDeleteModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-md p-6 animate-in fade-in zoom-in-95 duration-150">
        <div class="w-12 h-12 rounded-2xl bg-rose-100 text-rose-700 flex items-center justify-center text-xl mb-4">
            <i class="fa-solid fa-trash"></i>
        </div>
        <h3 class="font-black text-lg text-slate-900 mb-2">Xóa vĩnh viễn câu hỏi?</h3>
        <p class="text-xs text-slate-600 leading-relaxed mb-6">
            Câu hỏi này <strong>chưa từng được sử dụng</strong> trong bất kỳ bài thi nào. Câu hỏi và toàn bộ các đáp án sẽ bị xóa hoàn toàn khỏi hệ thống. Thao tác này <strong>không thể hoàn tác</strong>.
        </p>
        <div class="flex items-center justify-end gap-3">
            <button type="button" onclick="closeDeleteModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-xs hover:bg-slate-50 transition">Hủy bỏ</button>
            <a id="confirmDeleteLink" href="#" class="px-5 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-bold text-xs shadow-sm transition">
                Xác nhận Xóa
            </a>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: CONFIRM HIDE QUESTION               -->
<!-- ========================================== -->
<div id="hideConfirmModal" onclick="if(event.target === this) closeHideModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-md p-6 animate-in fade-in zoom-in-95 duration-150">
        <div class="w-12 h-12 rounded-2xl bg-amber-100 text-amber-700 flex items-center justify-center text-xl mb-4">
            <i class="fa-solid fa-eye-slash"></i>
        </div>
        <h3 class="font-black text-lg text-slate-900 mb-2">Ẩn câu hỏi này?</h3>
        <p class="text-xs text-slate-600 leading-relaxed mb-6">
            Học viên đã làm bài thi có câu hỏi này sẽ <strong>không bị mất lịch sử hay bị lỗi điểm</strong>. Câu hỏi sẽ được ẩn khỏi danh sách lựa chọn tạo đề thi mới và bạn có thể khôi phục lại bất kỳ lúc nào.
        </p>
        <div class="flex items-center justify-end gap-3">
            <button type="button" onclick="closeHideModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-xs hover:bg-slate-50 transition">Hủy bỏ</button>
            <a id="confirmHideLink" href="#" class="px-5 py-2.5 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-sm transition">
                Xác nhận Ẩn
            </a>
        </div>
    </div>
</div>

<div id="importModal" onclick="if(event.target === this) closeImportModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div class="p-6 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
                <div class="w-9 h-9 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
                    <i class="fa-solid fa-file-import"></i>
                </div>
                <div>
                    <h3 class="font-black text-lg text-slate-900">Import câu hỏi từ file Excel</h3>
                    <p class="text-xs text-slate-500">Tạo hàng loạt câu hỏi trắc nghiệm hoặc điền vào chỗ trống từ file .xlsx.</p>
                </div>
            </div>
            <button type="button" onclick="closeImportModal()" class="text-slate-400 hover:text-slate-600 text-lg w-8 h-8 rounded-lg flex items-center justify-center hover:bg-slate-100 transition">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <form id="importForm" method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}/expert/questions" class="p-6 space-y-4">
            <input type="hidden" name="action" value="import_excel">
            <input type="hidden" name="courseId" value="${courseId}">

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Chương / Module áp dụng <span class="text-rose-500">*</span></label>
                    <select name="moduleId" required class="w-full px-3 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500">
                        <option value="">-- Chọn module --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${moduleId eq m.id ? 'selected' : ''}><c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Trạng thái tạo</label>
                    <select name="status" class="w-full px-3 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500">
                        <option value="public">Công khai (Public)</option>
                        <option value="draft">Bản nháp (Draft)</option>
                    </select>
                </div>
            </div>

            <!-- Excel file upload -->
            <div>
                <div class="flex items-center justify-between mb-1.5">
                    <label for="excelFileInput" class="block text-xs font-bold text-slate-700">File Excel (.xlsx) <span class="text-rose-500">*</span></label>
                    <a href="${pageContext.request.contextPath}/expert/questions?action=template" class="text-xs font-bold text-emerald-700 hover:underline">
                        <i class="fa-solid fa-download mr-1" aria-hidden="true"></i>Tải file mẫu
                    </a>
                </div>
                <input type="file" id="excelFileInput" name="excelFile" required accept=".xlsx,.xls" onchange="onExcelFileChange(this)"
                       class="block w-full text-xs text-slate-600 border border-slate-200 rounded-xl bg-slate-50 file:mr-3 file:px-4 file:py-2.5 file:border-0 file:bg-emerald-600 file:text-white file:font-bold file:text-xs hover:file:bg-emerald-700">
                <p id="excelFileError" role="alert" class="hidden mt-1.5 text-[11px] font-semibold text-rose-600"></p>
            </div>

            <!-- Formatting hint -->
            <div class="p-3 bg-emerald-50/70 border border-emerald-200 rounded-xl text-[11px] text-emerald-900 space-y-1">
                <div class="font-bold flex items-center gap-1.5">
                    <i class="fa-solid fa-lightbulb text-emerald-600" aria-hidden="true"></i>Quy tắc định dạng:
                </div>
                <p>• Dùng đúng file mẫu: hàng 1 là tiêu đề (không sửa), câu hỏi nhập từ hàng 2, tối đa 500 câu mỗi lần.</p>
                <p>• Trắc nghiệm: điền Đáp án A, B, C, D (ít nhất A và B). Cột <code>Đáp án đúng</code> chỉ nhận <code>A</code>, <code>B</code>, <code>C</code>, <code>D</code>; nhiều đáp án đúng cách nhau bằng dấu phẩy (ví dụ <code>A,C</code>).</p>
                <p>• Điền vào chỗ trống: cột <code>Loại câu hỏi</code> = <code>fill_in_blank</code>, để trống Đáp án A-D, từ khóa đúng nhập ở cột <code>Đáp án đúng</code> cách nhau bằng dấu phẩy.</p>
                <p>• Nếu file có lỗi, hệ thống báo rõ dòng nào lỗi gì và không lưu câu nào cho đến khi bạn sửa xong.</p>
            </div>

            <div class="flex items-center justify-end gap-3 pt-2">
                <button type="button" onclick="closeImportModal()" class="px-5 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-xs hover:bg-slate-50 transition">Hủy bỏ</button>
                <button type="submit" id="importSubmit" class="px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs shadow-md transition disabled:opacity-60 disabled:cursor-not-allowed">
                    <i class="fa-solid fa-check mr-1.5" aria-hidden="true"></i>Bắt đầu Import
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function onExcelFileChange(input) {
        const error = document.getElementById('excelFileError');
        error.classList.add('hidden');
        const file = input.files[0];
        if (!file) return;
        const name = file.name.toLowerCase();
        let message = '';
        if (!name.endsWith('.xlsx') && !name.endsWith('.xls')) {
            message = 'Chỉ chấp nhận file Excel (.xlsx hoặc .xls).';
        } else if (file.size > 5 * 1024 * 1024) {
            message = 'File quá lớn. Dung lượng tối đa là 5MB.';
        }
        if (message) {
            error.textContent = message;
            error.classList.remove('hidden');
            input.value = '';
        }
    }
    document.getElementById('importForm').addEventListener('submit', function() {
        const button = document.getElementById('importSubmit');
        button.disabled = true;
        button.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1.5" aria-hidden="true"></i>Đang import...';
    });

    function openImportModal() {
        const err = document.getElementById('excelFileError');
        if (err) err.classList.add('hidden');
        const submitBtn = document.getElementById('importSubmit');
        if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fa-solid fa-check mr-1.5" aria-hidden="true"></i>Bắt đầu Import';
        }
        document.getElementById("importModal").classList.remove("hidden");
    }

    function closeImportModal() {
        document.getElementById("importModal").classList.add("hidden");
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeImportModal();
            closeHideModal();
            closeDeleteModal();
        }
    });

    function confirmDeleteQuestion(questionId, courseId) {
        let url = '${pageContext.request.contextPath}/expert/questions?action=delete&id=' + questionId;
        if (courseId) {
            url += '&courseId=' + courseId;
        }
        document.getElementById('confirmDeleteLink').href = url;
        document.getElementById('deleteConfirmModal').classList.remove('hidden');
    }

    function closeDeleteModal() {
        document.getElementById('deleteConfirmModal').classList.add('hidden');
    }

    function confirmHideQuestion(questionId, courseId) {
        let url = '${pageContext.request.contextPath}/expert/questions?action=hide&id=' + questionId;
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
