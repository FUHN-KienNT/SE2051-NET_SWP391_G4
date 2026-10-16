<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="w-full px-4 sm:px-6 lg:px-8 pt-6 pb-16 flex flex-col md:flex-row gap-6">
    <!-- Sidebar Navigation -->
    <aside class="w-full md:w-52 shrink-0">
        <div class="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm p-2 space-y-1">
            <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${courseId}"
               class="flex items-center space-x-3 px-3.5 py-3 text-sm font-semibold text-slate-600 hover:bg-slate-50 hover:text-slate-900 rounded-xl transition">
                <i class="fa-solid fa-book-open text-slate-400 w-4 text-center"></i>
                <span>Bài học (Lesson)</span>
            </a>
            <a href="${pageContext.request.contextPath}/quiz/manage?courseId=${courseId}"
               class="flex items-center space-x-3 px-3.5 py-3 text-sm font-semibold text-slate-600 hover:bg-slate-50 hover:text-slate-900 rounded-xl transition">
                <i class="fa-solid fa-clipboard-question text-slate-400 w-4 text-center"></i>
                <span>Bài thi (Quiz)</span>
            </a>
            <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
               class="flex items-center space-x-3 px-3.5 py-3 text-sm font-bold bg-emerald-50 text-emerald-800 rounded-xl transition">
                <i class="fa-solid fa-list-check text-emerald-600 w-4 text-center"></i>
                <span>Ngân hàng câu hỏi</span>
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <div class="flex-1 min-w-0">
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
                    <!-- Import Docs Button -->
                    <button type="button" onclick="openImportModal()"
                            class="inline-flex items-center px-4 py-2.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 text-sm font-bold rounded-xl shadow-sm transition">
                        <i class="fa-solid fa-file-import text-emerald-600 mr-2"></i>
                        <span>Import từ Docs / File</span>
                    </button>

                    <!-- Create Question Button -->
                    <a href="${pageContext.request.contextPath}/questions/detail?courseId=${courseId}"
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
            <c:if test="${param.imported != null}">
                <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                    <i class="fa-solid fa-circle-check text-emerald-600"></i>
                    <span>Đã import thành công <strong>${param.imported}</strong> câu hỏi vào ngân hàng câu hỏi!</span>
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
                    <span>Không thể thực hiện thao tác. Vui lòng kiểm tra lại.</span>
                </div>
            </c:if>

            <!-- Filter Toolbar: Course, Module, Type, Status, Keyword -->
            <form method="get" action="${pageContext.request.contextPath}/questions/manage" class="mt-6 p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-3">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                    <!-- Course Filter -->
                    <div>
                        <label class="block text-xs font-bold text-slate-600 mb-1">Khóa học</label>
                        <select name="courseId" id="filterCourseSelect" onchange="onFilterCourseChange(this.value)" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                            <option value="">-- Tất cả khóa học --</option>
                            <c:forEach var="c" items="${courses}">
                                <option value="${c.id}" ${courseId eq c.id.toString() ? 'selected' : ''}>${c.title}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Module Filter -->
                    <div>
                        <label class="block text-xs font-bold text-slate-600 mb-1">Chương / Module</label>
                        <select name="moduleId" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition">
                            <option value="">-- Tất cả Module --</option>
                            <c:forEach var="m" items="${modules}">
                                <option value="${m.id}" ${moduleId eq m.id ? 'selected' : ''}>${m.title}</option>
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
                        <a href="${pageContext.request.contextPath}/questions/manage?courseId=${courseId}"
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
                                        </td>
                                        <td class="px-5 py-4 text-center font-bold text-slate-700 text-xs">
                                            <span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-slate-100 text-slate-700 font-bold">
                                                ${q.options.size()}
                                            </span>
                                        </td>
                                        <td class="px-5 py-4 text-center space-x-2 text-xs font-semibold whitespace-nowrap">
                                            <a href="${pageContext.request.contextPath}/questions/detail?id=${q.id}&courseId=${courseId}"
                                               class="inline-flex items-center px-2.5 py-1 rounded-lg border border-slate-200 text-emerald-700 hover:bg-emerald-50 font-bold transition">
                                                <i class="fa-solid fa-pen mr-1 text-[10px]"></i>Sửa
                                            </a>

                                            <!-- Soft Hide / Unhide Action -->
                                            <c:choose>
                                                <c:when test="${q.status eq 'hidden'}">
                                                    <a href="${pageContext.request.contextPath}/questions/manage?action=unhide&id=${q.id}&courseId=${courseId}"
                                                       class="inline-flex items-center px-2.5 py-1 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 font-bold transition"
                                                       title="Khôi phục hiển thị câu hỏi">
                                                        <i class="fa-solid fa-eye mr-1 text-[10px]"></i>Hiện
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button"
                                                            onclick="confirmHideQuestion('${q.id}', '${courseId}')"
                                                            class="inline-flex items-center px-2.5 py-1 rounded-lg border border-slate-200 text-slate-500 hover:text-rose-600 hover:border-rose-200 hover:bg-rose-50 font-bold transition"
                                                            title="Ẩn câu hỏi để bảo vệ dữ liệu học viên đã thi">
                                                        <i class="fa-solid fa-eye-slash mr-1 text-[10px]"></i>Ẩn
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
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: IMPORT QUESTIONS FROM DOCS / FILE   -->
<!-- ========================================== -->
<div id="importModal" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div class="p-6 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
                <div class="w-9 h-9 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
                    <i class="fa-solid fa-file-import"></i>
                </div>
                <div>
                    <h3 class="font-black text-lg text-slate-900">Import câu hỏi từ Docs / File văn bản</h3>
                    <p class="text-xs text-slate-500">Tạo hàng loạt câu hỏi trắc nghiệm hoặc điền vào chỗ trống nhanh chóng.</p>
                </div>
            </div>
            <button type="button" onclick="closeImportModal()" class="text-slate-400 hover:text-slate-600 text-lg w-8 h-8 rounded-lg flex items-center justify-center hover:bg-slate-100 transition">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/questions/manage" class="p-6 space-y-4">
            <input type="hidden" name="action" value="import_docs">
            <input type="hidden" name="courseId" value="${courseId}">

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Chương / Module áp dụng <span class="text-rose-500">*</span></label>
                    <select name="moduleId" required class="w-full px-3 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500">
                        <option value="">-- Chọn module --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${moduleId eq m.id ? 'selected' : ''}>${m.title}</option>
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

            <!-- File Upload / Paste Helper -->
            <div>
                <div class="flex items-center justify-between mb-1.5">
                    <label class="block text-xs font-bold text-slate-700">Tải file văn bản (.txt, .docx dạng text) hoặc dán trực tiếp bên dưới</label>
                    <label class="text-xs font-bold text-emerald-700 hover:underline cursor-pointer">
                        <i class="fa-solid fa-upload mr-1"></i>Chọn file
                        <input type="file" id="docFileInput" accept=".txt,.text,.md,.doc" class="hidden" onchange="handleFileUpload(event)">
                    </label>
                </div>
                <textarea id="docTextInput" name="docText" rows="9" required
                          placeholder="Dán nội dung câu hỏi vào đây theo mẫu:

Câu 1: Servlet trong Java là gì?
A. Một class Java mở rộng chức năng của máy chủ
*B. Một giao diện lập trình
C. Một giao thức mạng
D. Một cơ sở dữ liệu

Câu 2: Điền vào chỗ trống: HTML viết tắt của từ gì?
Đáp án: HyperText Markup Language, HTML"
                          class="w-full p-3.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-mono outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition leading-relaxed"></textarea>
            </div>

            <!-- Formatting hint -->
            <div class="p-3 bg-emerald-50/70 border border-emerald-200 rounded-xl text-[11px] text-emerald-900 space-y-1">
                <div class="font-bold flex items-center gap-1.5">
                    <i class="fa-solid fa-lightbulb text-emerald-600"></i>Quy tắc định dạng:
                </div>
                <p>• Bắt đầu câu hỏi bằng <code>Câu 1:</code>, <code>Question 1:</code> hoặc <code>1.</code></p>
                <p>• Trắc nghiệm: Bắt đầu đáp án bằng <code>A.</code>, <code>B.</code>, <code>C.</code>, <code>D.</code> Thêm dấu <code>*</code> trước đáp án đúng (ví dụ: <code>*B. Đáp án đúng</code>).</p>
                <p>• Điền vào chỗ trống: Thêm dòng <code>Đáp án: từ_khóa_1, từ_khóa_2</code></p>
            </div>

            <div class="flex items-center justify-end gap-3 pt-2">
                <button type="button" onclick="closeImportModal()" class="px-5 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-xs hover:bg-slate-50 transition">Hủy bỏ</button>
                <button type="submit" class="px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs shadow-md transition">
                    <i class="fa-solid fa-check mr-1.5"></i>Bắt đầu Import
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: CONFIRM HIDE QUESTION               -->
<!-- ========================================== -->
<div id="hideConfirmModal" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
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

<script>
function onFilterCourseChange(courseId) {
    const currentUrl = new URL(window.location.href);
    if (courseId) {
        currentUrl.searchParams.set('courseId', courseId);
    } else {
        currentUrl.searchParams.delete('courseId');
    }
    currentUrl.searchParams.delete('moduleId'); // reset module when course changes
    window.location.href = currentUrl.toString();
}

function openImportModal() {
    document.getElementById('importModal').classList.remove('hidden');
}

function closeImportModal() {
    document.getElementById('importModal').classList.add('hidden');
}

function handleFileUpload(event) {
    const file = event.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('docTextInput').value = e.target.result;
    };
    reader.readAsText(file);
}

function confirmHideQuestion(questionId, courseId) {
    let url = '${pageContext.request.contextPath}/questions/manage?action=hide&id=' + questionId;
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

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
