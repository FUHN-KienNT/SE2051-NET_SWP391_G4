<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<%-- 
=============================================================================
HỆ THỐNG QUẢN LÝ NGÂN HÀNG CÂU HỎI (QUESTION BANK)
Dành cho Chuyên gia nội dung (Expert) / Giảng viên quản lý kho đề thi:
- Sidebar & Course Picker đồng bộ chuẩn hóa theo phong cách Lesson List.
- Quản lý danh sách câu hỏi: Trắc nghiệm 1 đáp án, nhiều đáp án, điền chỗ trống.
- Lọc theo Khóa học, Module, Loại câu hỏi, Trạng thái (Public/Draft/Hidden) và từ khóa.
- Thao tác: Tạo mới, Sửa, Ẩn/Hiện (bảo toàn lịch sử thi), Xóa vĩnh viễn (nếu chưa dùng).
- Hỗ trợ Import hàng loạt từ file Excel chuẩn (.xlsx).
=============================================================================
--%>

<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <!-- Sidebar điều hướng dành riêng cho Expert (đồng bộ giống Lesson List) -->
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="questions" />
    </jsp:include>

    <!-- Khu vực nội dung chính -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-7xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">

                <!-- ========================================================= -->
                <!-- PHẦN 1: TIÊU ĐỀ TRANG & CÁC NÚT THAO TÁC ĐẦU TRANG        -->
                <!-- ========================================================= -->
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

                    <!-- Nút Thao tác: Import Excel và Tạo câu hỏi mới -->
                    <div class="flex flex-wrap items-center gap-2.5">
                        <button type="button" onclick="openImportModal()"
                                class="inline-flex items-center px-4 py-2.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold rounded-xl text-xs sm:text-sm focus-visible:ring-2 focus-visible:ring-emerald-600 transition shadow-sm">
                            <i class="fa-solid fa-file-import mr-2 text-emerald-600" aria-hidden="true"></i>Import từ Excel
                        </button>
                        <a href="${pageContext.request.contextPath}/expert/questions/detail?courseId=${courseId}&moduleId=${moduleId}"
                           class="inline-flex items-center px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs sm:text-sm shadow-sm transition">
                            <i class="fa-solid fa-plus mr-2 text-xs" aria-hidden="true"></i>
                            <span>Tạo câu hỏi mới</span>
                        </a>
                    </div>
                </div>

                <!-- ========================================================= -->
                <!-- PHẦN 2: CHỌN KHÓA HỌC & TÌM KIẾM KHÓA HỌC (GIỐNG LESSON LIST) -->
                <!-- ========================================================= -->
                <c:set var="currentCourseTitle" value="-- Tất cả khóa học --" />
                <c:forEach items="${not empty courses ? courses : assignedCourses}" var="assignedCourse">
                    <c:if test="${assignedCourse.id eq courseId}">
                        <c:set var="currentCourseTitle" value="${assignedCourse.title}" />
                    </c:if>
                </c:forEach>

                <div class="mt-6 p-4 bg-slate-50 rounded-2xl border border-slate-200 flex flex-wrap items-center gap-3">
                    <div class="flex items-center gap-2 text-xs font-bold text-slate-700 shrink-0">
                        <i class="fa-solid fa-graduation-cap text-emerald-600 text-sm" aria-hidden="true"></i>
                        <span>Khóa học:</span>
                    </div>

                    <!-- Dropdown chọn khóa học -->
                    <details id="questionCoursePicker" class="group relative w-full min-w-0 sm:w-80">
                        <summary title="${fn:escapeXml(currentCourseTitle)}"
                                 class="flex min-h-10 cursor-pointer list-none items-center justify-between gap-2 rounded-xl border border-slate-200 bg-white px-3.5 py-2 text-xs sm:text-sm font-semibold text-slate-800 hover:border-emerald-500 focus-visible:ring-2 focus-visible:ring-emerald-500 shadow-xs transition [&::-webkit-details-marker]:hidden">
                            <span class="truncate"><c:out value="${currentCourseTitle}" /></span>
                            <i class="fa-solid fa-chevron-down shrink-0 text-xs text-slate-400 group-open:rotate-180 transition-transform" aria-hidden="true"></i>
                        </summary>
                        <div class="absolute inset-x-0 top-full z-30 mt-1.5 rounded-xl border border-slate-200 bg-white shadow-lg overflow-hidden">
                            <ul id="questionCourseOptions" aria-label="Danh sách khóa học" class="max-h-60 overflow-y-auto divide-y divide-slate-100">
                                <li>
                                    <a href="${pageContext.request.contextPath}/expert/questions"
                                       class="flex h-11 items-center justify-between px-3.5 text-xs sm:text-sm hover:bg-emerald-50 hover:text-emerald-900 transition ${empty courseId ? 'bg-emerald-50 font-bold text-emerald-800' : 'text-slate-700'}">
                                        <span class="flex items-center truncate">
                                            <i class="fa-solid fa-layer-group text-slate-400 mr-2 text-xs" aria-hidden="true"></i>
                                            <span class="truncate">-- Tất cả khóa học --</span>
                                        </span>
                                    </a>
                                </li>
                                <c:forEach items="${not empty courses ? courses : assignedCourses}" var="assignedCourse">
                                    <c:url var="assignedCourseUrl" value="/expert/questions">
                                        <c:param name="courseId" value="${assignedCourse.id}" />
                                    </c:url>
                                    <li data-course-option>
                                        <a href="${fn:escapeXml(assignedCourseUrl)}" title="${fn:escapeXml(assignedCourse.title)}"
                                           aria-current="${assignedCourse.id eq courseId ? 'page' : 'false'}"
                                           class="flex h-11 items-center justify-between gap-2 px-3.5 text-xs sm:text-sm hover:bg-emerald-50 hover:text-emerald-900 transition ${assignedCourse.id eq courseId ? 'bg-emerald-50 font-bold text-emerald-800' : 'text-slate-700'}">
                                            <span class="flex items-center truncate">
                                                <i class="fa-solid fa-book text-slate-400 mr-2 text-xs shrink-0" aria-hidden="true"></i>
                                                <span class="truncate"><c:out value="${assignedCourse.title}" /></span>
                                            </span>
                                            <span class="shrink-0 text-[11px] font-semibold px-2 py-0.5 rounded-full ${assignedCourse.moduleCount > 0 ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-500'}">
                                                ${assignedCourse.moduleCount} chương
                                            </span>
                                        </a>
                                    </li>
                                </c:forEach>
                            </ul>
                            <p id="questionCourseSearchStatus" role="status" class="px-3.5 py-3 text-xs text-slate-400 text-center" hidden>Không tìm thấy khóa học phù hợp.</p>
                        </div>
                    </details>

                    <!-- Tìm kiếm tên khóa học trong danh sách (lọc tức thì) -->
                    <div class="w-full sm:w-56 relative">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none" aria-hidden="true"></i>
                        <input type="search" id="questionCourseSearch" aria-controls="questionCourseOptions"
                               placeholder="Tìm kiếm khóa học..."
                               class="min-h-10 w-full pl-9 pr-3.5 py-2 rounded-xl border border-slate-200 bg-white text-xs sm:text-sm font-medium text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 shadow-xs transition">
                    </div>
                </div>

                <!-- Tag hiển thị bộ lọc khóa học đang áp dụng và nút Xóa lọc nhanh -->
                <c:if test="${not empty courseId}">
                    <div class="mt-3 flex flex-wrap items-center justify-between gap-3 px-4 py-2.5 rounded-xl bg-emerald-50 border border-emerald-100 text-xs sm:text-sm animate-fade-in">
                        <div class="flex items-center gap-2 text-emerald-900 font-semibold truncate">
                            <i class="fa-solid fa-filter text-emerald-700 shrink-0" aria-hidden="true"></i>
                            <span>Đang lọc theo khóa học: <strong class="text-emerald-950"><c:out value="${not empty course.title ? course.title : currentCourseTitle}" /></strong></span>
                        </div>
                        <a href="${pageContext.request.contextPath}/expert/questions"
                           class="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-white border border-emerald-200 text-emerald-800 hover:bg-emerald-100 font-bold text-xs shrink-0 shadow-xs transition"
                           title="Hiển thị tất cả các câu hỏi từ tất cả khóa học">
                            <i class="fa-solid fa-xmark text-xs" aria-hidden="true"></i>
                            <span>Xem tất cả câu hỏi</span>
                        </a>
                    </div>
                </c:if>

                <!-- Thông báo hướng dẫn nếu khóa học đang chọn chưa có Module nào -->
                <c:if test="${not empty courseId and (courseHasNoModules or empty modules)}">
                    <div class="mt-3 p-4 rounded-xl bg-amber-50 border border-amber-200 text-xs sm:text-sm flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                        <div class="flex items-start gap-2.5 text-amber-900">
                            <i class="fa-solid fa-triangle-exclamation text-amber-600 text-base mt-0.5 shrink-0" aria-hidden="true"></i>
                            <div>
                                <p class="font-bold">Khóa học này hiện chưa có chương (Module) nào.</p>
                                <p class="text-amber-800 text-xs mt-0.5">Hãy tạo chương mới ở mục Quản lý bài học (Lesson List) hoặc chọn chương của khóa học khác bên dưới.</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-2 shrink-0">
                            <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${courseId}"
                               class="inline-flex items-center px-3.5 py-2 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-xs transition">
                                <i class="fa-solid fa-folder-plus mr-1.5" aria-hidden="true"></i>Tạo chương mới
                            </a>
                        </div>
                    </div>
                </c:if>

                <!-- ========================================================= -->
                <!-- PHẦN 3: THÔNG BÁO PHẢN HỒI KẾT QUẢ (ALERTS)                -->
                <!-- ========================================================= -->
                <!-- Thông báo lưu thành công -->
                <c:if test="${param.saved == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-check text-emerald-600" aria-hidden="true"></i>
                        <span>Lưu câu hỏi thành công!</span>
                    </div>
                </c:if>

                <!-- Thông báo xóa vĩnh viễn thành công -->
                <c:if test="${param.deleted == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-check text-emerald-600" aria-hidden="true"></i>
                        <span>Đã xóa vĩnh viễn câu hỏi thành công!</span>
                    </div>
                </c:if>

                <!-- Cảnh báo không thể xóa câu hỏi đã gán vào đề thi -->
                <c:if test="${param.cannotDelete == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-triangle-exclamation text-amber-600" aria-hidden="true"></i>
                        <span>Câu hỏi này đã được sử dụng trong bài thi nên không thể xóa vĩnh viễn. Bạn chỉ có thể ẩn câu hỏi để bảo toàn dữ liệu.</span>
                    </div>
                </c:if>

                <!-- Cảnh báo không thể sửa câu hỏi đã gán vào đề thi -->
                <c:if test="${param.cannotEditUsedQuestion == 'true'}">
                    <div role="alert" class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-triangle-exclamation text-amber-600 text-base" aria-hidden="true"></i>
                        <span>Câu hỏi này đã được sử dụng trong bài kiểm tra nên không thể chỉnh sửa để bảo toàn lịch sử dữ liệu thi.</span>
                    </div>
                </c:if>

                <!-- Thông báo đã ẩn câu hỏi -->
                <c:if test="${param.hidden == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-eye-slash text-amber-600" aria-hidden="true"></i>
                        <span>Đã ẩn câu hỏi. Lịch sử làm bài thi của học viên được bảo toàn an toàn.</span>
                    </div>
                </c:if>

                <!-- Thông báo đã hiện (khôi phục) câu hỏi -->
                <c:if test="${param.unhidden == 'true'}">
                    <div class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-eye text-emerald-600" aria-hidden="true"></i>
                        <span>Đã khôi phục hiển thị câu hỏi thành công.</span>
                    </div>
                </c:if>

                <!-- Báo lỗi khi thao tác xóa thất bại -->
                <c:if test="${param.deleted == 'false'}">
                    <div class="mt-4 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-xmark text-rose-600" aria-hidden="true"></i>
                        <span>Không thể xóa câu hỏi. Vui lòng kiểm tra lại.</span>
                    </div>
                </c:if>

                <!-- Kết quả Import Excel: Thành công hoặc Danh sách lỗi -->
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

                <!-- ========================================================= -->
                <!-- PHẦN 4: BỘ LỌC TÌM KIẾM CÂU HỎI (FILTERS & SEARCH)        -->
                <!-- ========================================================= -->
                <form method="get" action="${pageContext.request.contextPath}/expert/questions" class="mt-4 p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-3">
                    <c:if test="${not empty courseId}">
                        <input type="hidden" name="courseId" value="${courseId}">
                    </c:if>

                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                        <!-- Lọc theo Module / Chương (tự động lọc khi chọn) -->
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Chương / Module</label>
                            <select name="moduleId" onchange="this.form.submit()" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition cursor-pointer">
                                <option value="">-- Tất cả Module --</option>
                                <c:forEach var="m" items="${modules}">
                                    <option value="${m.id}" ${moduleId eq m.id or param.moduleId eq m.id.toString() ? 'selected' : ''}><c:if test="${(empty courseId or courseHasNoModules) and not empty m.courseTitle}">[<c:out value="${m.courseTitle}" />] </c:if><c:out value="${m.title}" /></option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Lọc theo Loại câu hỏi (tự động lọc khi chọn) -->
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Loại câu hỏi</label>
                            <select name="type" onchange="this.form.submit()" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition cursor-pointer">
                                <option value="">-- Tất cả loại câu hỏi --</option>
                                <option value="single_choice" ${type eq 'single_choice' ? 'selected' : ''}>Một đáp án (Single choice)</option>
                                <option value="multiple_choice" ${type eq 'multiple_choice' ? 'selected' : ''}>Nhiều đáp án (Multiple choice)</option>
                                <option value="fill_in_blank" ${type eq 'fill_in_blank' ? 'selected' : ''}>Điền vào chỗ trống</option>
                            </select>
                        </div>

                        <!-- Lọc theo Trạng thái (tự động lọc khi chọn) -->
                        <div>
                            <label class="block text-xs font-bold text-slate-600 mb-1">Trạng thái</label>
                            <select name="status" onchange="this.form.submit()" class="w-full px-3 py-2 rounded-xl bg-white border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 transition cursor-pointer">
                                <option value="">-- Tất cả trạng thái --</option>
                                <option value="public" ${status eq 'public' ? 'selected' : ''}>Công khai (Public)</option>
                                <option value="draft" ${status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft)</option>
                                <option value="hidden" ${status eq 'hidden' ? 'selected' : ''}>Đã ẩn (Hidden)</option>
                            </select>
                        </div>
                    </div>

                    <!-- Ô tìm kiếm từ khóa và Nút thực thi -->
                    <div class="flex flex-col sm:flex-row gap-3 pt-1 items-center">
                        <div class="relative flex-1 w-full">
                            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-slate-400 text-xs" aria-hidden="true"></i>
                            <input name="keyword" value="${keyword}" placeholder="Tìm kiếm nội dung câu hỏi..."
                                   class="w-full pl-9 pr-4 py-2.5 rounded-xl bg-white border border-slate-200 text-xs outline-none focus:ring-2 focus:ring-emerald-500 transition">
                        </div>
                        <div class="flex items-center gap-2 shrink-0 w-full sm:w-auto">
                            <button type="submit" class="flex-1 sm:flex-none px-5 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs shadow-sm transition">
                                <i class="fa-solid fa-filter mr-1.5" aria-hidden="true"></i>Lọc câu hỏi
                            </button>
                            <a href="${pageContext.request.contextPath}/expert/questions"
                               class="px-4 py-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 font-bold text-xs transition"
                               title="Đặt lại tất cả bộ lọc và xem toàn bộ câu hỏi">
                                Đặt lại
                            </a>
                        </div>
                    </div>
                </form>

                <!-- ========================================================= -->
                <!-- PHẦN 5: BẢNG DỮ LIỆU CÂU HỎI (QUESTION DATA TABLE)       -->
                <!-- ========================================================= -->
                <div class="mt-6 overflow-x-auto border border-slate-200 rounded-2xl">
                    <table class="w-full text-left text-sm text-slate-600">
                        <thead class="bg-slate-50 text-slate-700 text-xs font-bold border-b border-slate-200">
                        <tr>
                            <th class="px-5 py-4 w-12 text-center">#</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Nội dung câu hỏi</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Module &amp; Khóa học</th>
                            <th class="px-5 py-4 font-bold text-slate-800">Loại câu hỏi</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Trạng thái</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800">Đáp án</th>
                            <th class="px-5 py-4 text-center font-bold text-slate-800 w-44">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                        <c:choose>
                            <c:when test="${not empty questions}">
                                <c:forEach var="q" items="${questions}" varStatus="s">
                                    <tr class="hover:bg-slate-50/80 transition-colors ${q.status eq 'hidden' ? 'bg-slate-50/50 opacity-75' : ''}">
                                        <!-- Thứ tự -->
                                        <td class="px-5 py-4 text-center font-bold text-slate-400 text-xs">${s.count}</td>

                                        <!-- Nội dung câu hỏi -->
                                        <td class="px-5 py-4 max-w-md">
                                            <div class="font-semibold text-slate-900 leading-snug line-clamp-2">
                                                ${q.content}
                                            </div>
                                        </td>

                                        <!-- Module & Khóa học -->
                                        <td class="px-5 py-4">
                                            <c:choose>
                                                <c:when test="${not empty q.moduleTitle}">
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-slate-100 text-slate-700 border border-slate-200">
                                                        <i class="fa-solid fa-folder text-slate-400 mr-1 text-[10px]" aria-hidden="true"></i>${q.moduleTitle}
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

                                        <!-- Badge Loại câu hỏi -->
                                        <td class="px-5 py-4">
                                            <c:choose>
                                                <c:when test="${q.type eq 'fill_in_blank'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-purple-50 text-purple-700 text-xs font-bold border border-purple-200 whitespace-nowrap">
                                                        <i class="fa-solid fa-pen-nib mr-1.5 text-[10px]" aria-hidden="true"></i>Điền chỗ trống
                                                    </span>
                                                </c:when>
                                                <c:when test="${q.type eq 'multiple_choice'}">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-indigo-50 text-indigo-700 text-xs font-bold border border-indigo-200 whitespace-nowrap">
                                                        <i class="fa-solid fa-list-check mr-1.5 text-[10px]" aria-hidden="true"></i>Nhiều đáp án
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-blue-50 text-blue-700 text-xs font-bold border border-blue-200 whitespace-nowrap">
                                                        <i class="fa-solid fa-circle-dot mr-1.5 text-[10px]" aria-hidden="true"></i>1 đáp án
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Trạng thái & Tình trạng sử dụng trong đề thi -->
                                        <td class="px-5 py-4 text-center">
                                            <c:choose>
                                                <c:when test="${q.status eq 'hidden'}">
                                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-slate-100 text-slate-600 border border-slate-300">
                                                        <i class="fa-solid fa-eye-slash mr-1 text-[10px]" aria-hidden="true"></i>Đã ẩn
                                                    </span>
                                                </c:when>
                                                <c:when test="${q.status eq 'draft'}">
                                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                                        <i class="fa-solid fa-pen-ruler mr-1 text-[10px]" aria-hidden="true"></i>Bản nháp
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                        <i class="fa-solid fa-circle-check mr-1 text-[10px]" aria-hidden="true"></i>Công khai
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="mt-1">
                                                <c:choose>
                                                    <c:when test="${q.quizCount > 0}">
                                                        <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200" title="Đã được sử dụng trong ${q.quizCount} đề thi">
                                                            <i class="fa-solid fa-link mr-1 text-[8px]" aria-hidden="true"></i>Đã dùng (${q.quizCount})
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-slate-100 text-slate-500" title="Chưa gán vào đề thi nào">
                                                            Chưa dùng
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>

                                        <!-- Số lượng phương án đáp án -->
                                        <td class="px-5 py-4 text-center font-bold text-slate-700 text-xs">
                                            <span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-slate-100 text-slate-700 font-bold">
                                                ${q.options.size()}
                                            </span>
                                        </td>

                                        <!-- Cột Thao tác: Sửa (chỉ câu chưa dùng), Ẩn/Hiện (áp dụng mọi câu hỏi), Xóa (chỉ câu chưa dùng) -->
                                        <td class="px-5 py-4 text-center space-x-1.5 text-xs font-semibold whitespace-nowrap">
                                            <!-- 1. Nút Sửa: Chỉ hiển thị với câu hỏi CHƯA ĐƯỢC DÙNG (q.quizCount == 0) -->
                                            <c:if test="${q.quizCount == 0}">
                                                <a href="${pageContext.request.contextPath}/expert/questions/detail?id=${q.id}&courseId=${courseId}"
                                                   class="inline-flex items-center px-2.5 py-1 rounded-lg border border-slate-200 text-emerald-700 hover:bg-emerald-50 font-bold transition">
                                                    <i class="fa-solid fa-pen mr-1 text-[10px]" aria-hidden="true"></i>Sửa
                                                </a>
                                            </c:if>

                                            <!-- 2. Nút Ẩn / Hiện: Mọi câu hỏi (kể cả đã dùng hay chưa dùng) đều có thể Ẩn/Hiện -->
                                            <c:choose>
                                                <c:when test="${q.status eq 'hidden'}">
                                                    <a href="${pageContext.request.contextPath}/expert/questions?action=unhide&id=${q.id}&courseId=${courseId}"
                                                       class="inline-flex items-center px-2.5 py-1 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 font-bold transition"
                                                       title="Khôi phục hiển thị câu hỏi">
                                                        <i class="fa-solid fa-eye mr-1 text-[10px]" aria-hidden="true"></i>Hiện
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button"
                                                            onclick="confirmHideQuestion('${q.id}', '${courseId}')"
                                                            class="inline-flex items-center px-2.5 py-1 rounded-lg border border-amber-200 bg-amber-50 text-amber-700 hover:bg-amber-100 font-bold transition"
                                                            title="Tạm ẩn câu hỏi khỏi danh sách làm đề">
                                                        <i class="fa-solid fa-eye-slash mr-1 text-[10px]" aria-hidden="true"></i>Ẩn
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>

                                            <!-- 3. Nút Xóa vĩnh viễn: Chỉ hiển thị với câu hỏi CHƯA ĐƯỢC DÙNG (q.quizCount == 0) -->
                                            <c:if test="${q.quizCount == 0}">
                                                <button type="button"
                                                        onclick="confirmDeleteQuestion('${q.id}', '${courseId}')"
                                                        class="inline-flex items-center px-2.5 py-1 rounded-lg border border-rose-200 text-rose-600 hover:bg-rose-50 font-bold transition"
                                                        title="Xóa vĩnh viễn câu hỏi chưa từng sử dụng trong đề thi">
                                                    <i class="fa-solid fa-trash mr-1 text-[10px]" aria-hidden="true"></i>Xóa
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="px-6 py-16 text-center text-slate-400 text-sm">
                                        <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300" aria-hidden="true"></i>
                                        Không tìm thấy câu hỏi nào phù hợp với bộ lọc hiện tại.
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

<!-- ========================================================================= -->
<!-- PHẦN 6: CÁC MODAL HỘP THOẠI XÁC NHẬN (XÓA, ẨN, IMPORT EXCEL)              -->
<!-- ========================================================================= -->

<!-- 6.1 MODAL: XÁC NHẬN XÓA VĨNH VIỄN CÂU HỎI (CHỈ ÁP DỤNG CÂU CHƯA DÙNG) -->
<div id="deleteConfirmModal" onclick="if(event.target === this) closeDeleteModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-md p-6">
        <div class="w-12 h-12 rounded-2xl bg-rose-100 text-rose-700 flex items-center justify-center text-xl mb-4">
            <i class="fa-solid fa-trash" aria-hidden="true"></i>
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

<!-- 6.2 MODAL: XÁC NHẬN ẨN CÂU HỎI -->
<div id="hideConfirmModal" onclick="if(event.target === this) closeHideModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-md p-6">
        <div class="w-12 h-12 rounded-2xl bg-amber-100 text-amber-700 flex items-center justify-center text-xl mb-4">
            <i class="fa-solid fa-eye-slash" aria-hidden="true"></i>
        </div>
        <h3 class="font-black text-lg text-slate-900 mb-2">Ẩn câu hỏi này?</h3>
        <p class="text-xs text-slate-600 leading-relaxed mb-6">
            Học viên đã làm bài thi có câu hỏi này sẽ <strong>không bị mất lịch sử hay bị ảnh hưởng điểm</strong>. Câu hỏi sẽ được ẩn khỏi danh sách lựa chọn tạo đề thi mới và bạn có thể khôi phục lại bất kỳ lúc nào.
        </p>
        <div class="flex items-center justify-end gap-3">
            <button type="button" onclick="closeHideModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-xs hover:bg-slate-50 transition">Hủy bỏ</button>
            <a id="confirmHideLink" href="#" class="px-5 py-2.5 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-sm transition">
                Xác nhận Ẩn
            </a>
        </div>
    </div>
</div>

<!-- 6.3 MODAL: IMPORT CÂU HỎI TỪ FILE EXCEL -->
<div id="importModal" onclick="if(event.target === this) closeImportModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl w-full max-w-2xl overflow-hidden">
        <div class="p-6 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
                <div class="w-9 h-9 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
                    <i class="fa-solid fa-file-import" aria-hidden="true"></i>
                </div>
                <div>
                    <h3 class="font-black text-lg text-slate-900">Import câu hỏi từ file Excel</h3>
                    <p class="text-xs text-slate-500">Tạo hàng loạt câu hỏi trắc nghiệm hoặc điền vào chỗ trống từ file .xlsx.</p>
                </div>
            </div>
            <button type="button" onclick="closeImportModal()" aria-label="Đóng" class="text-slate-400 hover:text-slate-600 text-lg w-8 h-8 rounded-lg flex items-center justify-center hover:bg-slate-100 transition">
                <i class="fa-solid fa-xmark" aria-hidden="true"></i>
            </button>
        </div>

        <form id="importForm" method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}/expert/questions" class="p-6 space-y-4">
            <input type="hidden" name="action" value="import_excel">
            <input type="hidden" name="courseId" value="${courseId}">

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <!-- Chọn module cho file import -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Chương / Module áp dụng <span class="text-rose-500">*</span></label>
                    <select name="moduleId" required class="w-full px-3 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500">
                        <option value="">-- Chọn module --</option>
                        <c:forEach var="m" items="${modules}">
                            <option value="${m.id}" ${moduleId eq m.id ? 'selected' : ''}><c:if test="${not empty m.courseTitle}">[${m.courseTitle}] </c:if>${m.title}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Trạng thái ban đầu cho các câu hỏi import -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Trạng thái tạo</label>
                    <select name="status" class="w-full px-3 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500">
                        <option value="public">Công khai (Public)</option>
                        <option value="draft">Bản nháp (Draft)</option>
                    </select>
                </div>
            </div>

            <!-- Upload File Excel -->
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

            <!-- Hướng dẫn định dạng file Excel -->
            <div class="p-3 bg-emerald-50/70 border border-emerald-200 rounded-xl text-[11px] text-emerald-900 space-y-1">
                <div class="font-bold flex items-center gap-1.5">
                    <i class="fa-solid fa-lightbulb text-emerald-600" aria-hidden="true"></i>Quy tắc định dạng:
                </div>
                <p>• Dùng đúng file mẫu: hàng 1 là tiêu đề (không sửa), câu hỏi nhập từ hàng 2, tối đa 500 câu mỗi lần.</p>
                <p>• Trắc nghiệm: điền Đáp án A, B, C, D (ít nhất A và B). Cột <code>Đáp án đúng</code> chỉ nhận <code>A</code>, <code>B</code>, <code>C</code>, <code>D</code>; nhiều đáp án đúng cách nhau bằng dấu phẩy (ví dụ <code>A,C</code>).</p>
                <p>• Điền vào chỗ trống: cột <code>Loại câu hỏi</code> = <code>fill_in_blank</code>, để trống Đáp án A-D, từ khóa đúng nhập ở cột <code>Đáp án đúng</code> cách nhau bằng dấu phẩy.</p>
                <p>• Nếu file có lỗi, hệ thống báo rõ dòng nào lỗi gì và không lưu câu nào cho đến khi bạn sửa xong.</p>
            </div>

            <!-- Nút hành động trong Modal Import -->
            <div class="flex items-center justify-end gap-3 pt-2">
                <button type="button" onclick="closeImportModal()" class="px-5 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-xs hover:bg-slate-50 transition">Hủy bỏ</button>
                <button type="submit" id="importSubmit" class="px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs shadow-md transition disabled:opacity-60 disabled:cursor-not-allowed">
                    <i class="fa-solid fa-check mr-1.5" aria-hidden="true"></i>Bắt đầu Import
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================================= -->
<!-- PHẦN 7: JAVASCRIPT HỖ TRỢ XỬ LÝ SỰ KIỆN GIAO DIỆN & TÌM KIẾM KHÓA HỌC     -->
<!-- ========================================================================= -->
<script>
    // Xử lý bộ lọc tìm kiếm khóa học (đồng bộ giống Lesson List)
    (function() {
        const search = document.getElementById('questionCourseSearch');
        const picker = document.getElementById('questionCoursePicker');
        const options = document.getElementById('questionCourseOptions');
        if (!search || !picker || !options) return;
        const courses = Array.from(options.querySelectorAll('[data-course-option]'));
        const status = document.getElementById('questionCourseSearchStatus');
        const normalize = text => text.trim().toLocaleLowerCase('vi')
            .normalize('NFD').replace(/\p{M}/gu, '').replace(/đ/g, 'd');
        const showResults = () => {
            const keyword = normalize(search.value);
            for (const course of courses) {
                course.hidden = !normalize(course.textContent).includes(keyword);
            }
            if (status) status.hidden = courses.some(course => !course.hidden);
            options.scrollTop = 0;
            picker.open = true;
        };
        search.addEventListener('input', showResults);
        search.addEventListener('keydown', event => {
            if (event.key === 'Enter' && !event.isComposing) {
                event.preventDefault();
                showResults();
                const firstOpt = options.querySelector('li:not([hidden]) a');
                if (firstOpt) firstOpt.focus();
            }
        });
        document.addEventListener('click', event => {
            if (!picker.contains(event.target) && event.target !== search) picker.open = false;
        });
        document.addEventListener('keydown', event => {
            if (event.key === 'Escape' && picker.open) {
                picker.open = false;
                if (picker.contains(document.activeElement)) {
                    const summary = picker.querySelector('summary');
                    if (summary) summary.focus();
                }
            }
        });
    })();

    // Kiểm tra định dạng và dung lượng file Excel tải lên
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

    // Hiển thị trạng thái đang xử lý khi nhấn Submit Import
    document.getElementById('importForm').addEventListener('submit', function() {
        const button = document.getElementById('importSubmit');
        button.disabled = true;
        button.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1.5" aria-hidden="true"></i>Đang import...';
    });

    // Mở và đóng Modal Import
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

    // Mở và đóng Modal Xóa câu hỏi chưa dùng
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

    // Mở và đóng Modal Ẩn câu hỏi
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

    // Đóng toàn bộ Modal khi nhấn phím Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeImportModal();
            closeHideModal();
            closeDeleteModal();
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
