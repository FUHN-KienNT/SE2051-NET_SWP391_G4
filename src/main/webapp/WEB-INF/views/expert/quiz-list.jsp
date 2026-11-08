<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- ===========================================================================
     MÀN HÌNH: QUẢN LÝ BÀI KIỂM TRA (QUIZ LIST)
     Cấu trúc giao diện:
     1. Thanh điều hướng bên trái (management-sidebar.jsp - giống Lesson List)
     2. Tiêu đề trang và các nút điều hướng (Ngân hàng câu hỏi, Tạo bài kiểm tra)
     3. Thanh chọn khóa học & tìm kiếm khóa học (đồng bộ kiểu dáng với Lesson List)
     4. Thanh lọc bài kiểm tra (Chương/Module, Trạng thái, Từ khóa)
     5. Bảng danh sách bài kiểm tra (Quizzes Table)
     6. Hộp thoại (Modal) xác nhận ẩn bài kiểm tra
     =========================================================================== -->

<div class="min-h-screen flex flex-col bg-surface text-text-primary lg:flex-row">
    <!-- 1. THANH ĐIỀU HƯỚNG BÊN TRÁI (SIDEBAR GIỐNG LESSON LIST) -->
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="quizzes" />
    </jsp:include>

    <!-- NỘI DUNG CHÍNH PHÍA BÊN PHẢI -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-7xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">
            <div class="bg-surface-card rounded-2xl border border-border-default shadow-xs p-5 sm:p-7">

                <!-- 2. TIÊU ĐỀ TRANG & NÚT THAO TÁC NHANH -->
                <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-5 border-b border-border-default">
                    <div>
                        <div class="text-xs font-bold uppercase tracking-wider text-brand-700 mb-1">
                            Dashboard <span class="text-text-secondary">/ Quiz Management</span>
                        </div>
                        <h1 class="text-xl sm:text-2xl font-extrabold text-text-primary tracking-tight">
                            Quản lý bài kiểm tra (Quiz)
                        </h1>
                        <p class="text-xs sm:text-sm text-text-secondary mt-1">
                            Cấu hình thời gian làm bài, điểm đạt và danh sách câu hỏi theo từng chương.
                        </p>
                    </div>
                    <div class="flex flex-wrap items-center gap-2.5">
                        <a href="${pageContext.request.contextPath}/expert/questions?courseId=${courseId}&moduleId=${moduleId}"
                           class="inline-flex items-center px-4 py-2.5 rounded-xl border border-border-default bg-surface-card hover:bg-slate-50 text-text-primary font-semibold text-xs sm:text-sm shadow-xs transition">
                            <i class="fa-solid fa-list-check mr-2 text-brand-700" aria-hidden="true"></i>Ngân hàng câu hỏi
                        </a>
                        <a href="${pageContext.request.contextPath}/expert/quizzes/detail?courseId=${courseId}&moduleId=${moduleId}"
                           class="inline-flex items-center px-4 py-2.5 rounded-xl bg-brand-700 hover:bg-brand-800 text-white font-bold text-xs sm:text-sm shadow-sm transition">
                            <i class="fa-solid fa-plus mr-2" aria-hidden="true"></i>Tạo bài kiểm tra mới
                        </a>
                    </div>
                </div>

                <!-- 3. THANH CHỌN KHÓA HỌC & TÌM KIẾM KHÓA HỌC (GIỐNG LESSON LIST, HÒA HỢP VỚI QUIZ LIST) -->
                <c:set var="currentCourseTitle" value="-- Tất cả khóa học --" />
                <c:forEach items="${not empty courses ? courses : assignedCourses}" var="assignedCourse">
                    <c:if test="${assignedCourse.id eq courseId}">
                        <c:set var="currentCourseTitle" value="${assignedCourse.title}" />
                    </c:if>
                </c:forEach>

                <div class="mt-5 flex flex-col sm:flex-row sm:items-center gap-3 p-3.5 rounded-2xl bg-surface border border-border-default">
                    <div class="flex items-center gap-2 text-xs font-bold text-text-secondary shrink-0 px-1">
                        <i class="fa-solid fa-graduation-cap text-brand-700 text-sm" aria-hidden="true"></i>
                        <span>Khóa học:</span>
                    </div>

                    <!-- Dropdown chọn khóa học kiểu Lesson List -->
                    <details id="quizCoursePicker" class="relative w-full sm:w-80 group">
                        <summary title="${fn:escapeXml(currentCourseTitle)}"
                                 class="flex min-h-10 w-full cursor-pointer list-none items-center justify-between gap-2 rounded-xl border border-border-default bg-surface-card px-3.5 py-2 text-left text-xs sm:text-sm font-semibold text-text-primary shadow-xs transition hover:border-slate-300 focus:outline-none focus:ring-2 focus:ring-brand-700 [&::-webkit-details-marker]:hidden">
                            <span class="truncate"><c:out value="${currentCourseTitle}" /></span>
                            <i class="fa-solid fa-chevron-down shrink-0 text-xs text-text-secondary transition group-open:rotate-180" aria-hidden="true"></i>
                        </summary>
                        <div class="absolute left-0 z-30 mt-1.5 w-full overflow-hidden rounded-xl border border-border-default bg-surface-card shadow-lg">
                            <ul id="quizCourseOptions" aria-label="Danh sách khóa học" class="max-h-[240px] overflow-y-auto divide-y divide-border-default">
                                <li>
                                    <a href="${pageContext.request.contextPath}/expert/quizzes"
                                       class="flex h-11 items-center justify-between px-3.5 text-xs sm:text-sm hover:bg-brand-50 hover:text-brand-900 transition ${empty courseId ? 'bg-brand-50 font-bold text-brand-900' : 'text-text-primary'}">
                                        <span class="flex items-center truncate">
                                            <i class="fa-solid fa-layer-group text-text-secondary mr-2 text-xs" aria-hidden="true"></i>
                                            <span class="truncate">-- Tất cả khóa học --</span>
                                        </span>
                                    </a>
                                </li>
                                <c:forEach items="${not empty courses ? courses : assignedCourses}" var="assignedCourse">
                                    <c:url var="assignedCourseUrl" value="/expert/quizzes">
                                        <c:param name="courseId" value="${assignedCourse.id}" />
                                    </c:url>
                                    <li data-course-option>
                                        <a href="${fn:escapeXml(assignedCourseUrl)}" title="${fn:escapeXml(assignedCourse.title)}"
                                           aria-current="${assignedCourse.id eq courseId ? 'page' : 'false'}"
                                           class="flex h-11 items-center justify-between gap-2 px-3.5 text-xs sm:text-sm hover:bg-brand-50 hover:text-brand-900 transition ${assignedCourse.id eq courseId ? 'bg-brand-50 font-bold text-brand-900' : 'text-text-primary'}">
                                            <span class="flex items-center truncate">
                                                <i class="fa-solid fa-book text-text-secondary mr-2 text-xs shrink-0" aria-hidden="true"></i>
                                                <span class="truncate"><c:out value="${assignedCourse.title}" /></span>
                                            </span>
                                            <span class="shrink-0 text-[11px] font-semibold px-2 py-0.5 rounded-full ${assignedCourse.moduleCount > 0 ? 'bg-brand-50 text-brand-700' : 'bg-slate-100 text-slate-500'}">
                                                ${assignedCourse.moduleCount} chương
                                            </span>
                                        </a>
                                    </li>
                                </c:forEach>
                            </ul>
                            <p id="quizCourseSearchStatus" role="status" class="px-3.5 py-3 text-xs text-text-secondary text-center" hidden>Không tìm thấy khóa học phù hợp.</p>
                        </div>
                    </details>

                    <!-- Tìm kiếm tên khóa học trong danh sách (lọc tức thì) -->
                    <div class="w-full sm:w-56 relative">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none" aria-hidden="true"></i>
                        <input type="search" id="quizCourseSearch" aria-controls="quizCourseOptions"
                               placeholder="Tìm kiếm khóa học..."
                               class="min-h-10 w-full pl-9 pr-3.5 py-2 rounded-xl border border-border-default bg-surface-card text-xs sm:text-sm font-medium text-text-primary placeholder-text-secondary focus:outline-none focus:ring-2 focus:ring-brand-700 shadow-xs transition">
                    </div>
                </div>

                <!-- Tag hiển thị bộ lọc khóa học đang áp dụng và nút Xóa lọc nhanh -->
                <c:if test="${not empty courseId}">
                    <div class="mt-3 flex flex-wrap items-center justify-between gap-3 px-4 py-2.5 rounded-xl bg-brand-50 border border-brand-100 text-xs sm:text-sm animate-fade-in">
                        <div class="flex items-center gap-2 text-brand-900 font-semibold truncate">
                            <i class="fa-solid fa-filter text-brand-700 shrink-0" aria-hidden="true"></i>
                            <span>Đang lọc theo khóa học: <strong class="text-brand-950"><c:out value="${not empty course.title ? course.title : currentCourseTitle}" /></strong></span>
                        </div>
                        <a href="${pageContext.request.contextPath}/expert/quizzes"
                           class="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-surface-card border border-brand-200 text-brand-800 hover:bg-brand-100 font-bold text-xs shrink-0 shadow-xs transition"
                           title="Hiển thị tất cả các bài kiểm tra từ tất cả khóa học">
                            <i class="fa-solid fa-xmark text-xs" aria-hidden="true"></i>
                            <span>Xem tất cả bài kiểm tra</span>
                        </a>
                    </div>
                </c:if>

                <!-- Thông báo hướng dẫn nếu khóa học đang chọn chưa có Module nào -->
                <c:if test="${not empty courseId and (courseHasNoModules or empty modules)}">
                    <div class="mt-3 p-4 rounded-xl bg-amber-50 border border-amber-200 text-xs sm:text-sm flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                        <div class="flex items-start gap-2.5 text-amber-900">
                            <i class="fa-solid fa-triangle-exclamation text-status-warning text-base mt-0.5 shrink-0" aria-hidden="true"></i>
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

                <!-- 3B. THÔNG BÁO PHẢN HỒI (ALERTS KHI THAO TÁC THÀNH CÔNG / THẤT BẠI) -->
                <c:if test="${param.saved == 'true'}">
                    <div role="status" class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-status-success text-xs sm:text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-check text-status-success text-base" aria-hidden="true"></i>
                        <span>Lưu bài kiểm tra thành công!</span>
                    </div>
                </c:if>
                <c:if test="${param.deleted == 'true'}">
                    <div role="status" class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-status-success text-xs sm:text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-check text-status-success text-base" aria-hidden="true"></i>
                        <span>Đã xóa vĩnh viễn bài kiểm tra thành công!</span>
                    </div>
                </c:if>
                <c:if test="${param.cannotDelete == 'true'}">
                    <div role="alert" class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-status-warning text-xs sm:text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-triangle-exclamation text-status-warning text-base" aria-hidden="true"></i>
                        <span>Bài kiểm tra này đã được sử dụng trong khóa học / chương học nên không thể xóa vĩnh viễn. Bạn chỉ có thể ẩn bài kiểm tra để bảo toàn dữ liệu.</span>
                    </div>
                </c:if>
                <c:if test="${param.hidden == 'true'}">
                    <div role="status" class="mt-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-status-warning text-xs sm:text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-eye-slash text-status-warning text-base" aria-hidden="true"></i>
                        <span>Đã ẩn bài kiểm tra. Lịch sử làm bài và điểm số thi của học viên được bảo toàn an toàn.</span>
                    </div>
                </c:if>
                <c:if test="${param.unhidden == 'true'}">
                    <div role="status" class="mt-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-status-success text-xs sm:text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-eye text-status-success text-base" aria-hidden="true"></i>
                        <span>Đã khôi phục hiển thị bài kiểm tra thành công.</span>
                    </div>
                </c:if>
                <c:if test="${param.deleted == 'false'}">
                    <div role="alert" class="mt-4 p-4 rounded-xl bg-rose-50 border border-rose-200 text-status-danger text-xs sm:text-sm font-semibold flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-xmark text-status-danger text-base" aria-hidden="true"></i>
                        <span>Không thể xóa bài kiểm tra. Vui lòng kiểm tra lại.</span>
                    </div>
                </c:if>

                <!-- 4. BỘ LỌC TÌM KIẾM (FILTER TOOLBAR: MODULE, TRẠNG THÁI, TỪ KHÓA) -->
                <form method="get" action="${pageContext.request.contextPath}/expert/quizzes" class="mt-4 p-4 bg-surface rounded-2xl border border-border-default space-y-3">
                    <c:if test="${not empty courseId}">
                        <input type="hidden" name="courseId" value="${courseId}">
                    </c:if>

                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                        <!-- Lọc theo Module / Chương (tự động lọc khi chọn) -->
                        <div>
                            <label class="block text-xs font-bold text-text-secondary mb-1">Chương / Module</label>
                            <select name="moduleId" onchange="this.form.submit()" class="w-full px-3 py-2.5 rounded-xl bg-surface-card border border-border-default text-xs sm:text-sm font-semibold text-text-primary outline-none focus:ring-2 focus:ring-brand-700 transition cursor-pointer">
                                <option value="">-- Tất cả Module --</option>
                                <c:forEach var="m" items="${modules}">
                                    <option value="${m.id}" ${moduleId eq m.id or param.moduleId eq m.id.toString() ? 'selected' : ''}>
                                        <c:if test="${(empty courseId or courseHasNoModules) and not empty m.courseTitle}">[<c:out value="${m.courseTitle}" />] </c:if><c:out value="${m.title}" />
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Lọc theo trạng thái (tự động lọc khi chọn) -->
                        <div>
                            <label class="block text-xs font-bold text-text-secondary mb-1">Trạng thái</label>
                            <select name="status" onchange="this.form.submit()" class="w-full px-3 py-2.5 rounded-xl bg-surface-card border border-border-default text-xs sm:text-sm font-semibold text-text-primary outline-none focus:ring-2 focus:ring-brand-700 transition cursor-pointer">
                                <option value="">-- Tất cả trạng thái --</option>
                                <option value="published" ${status eq 'published' ? 'selected' : ''}>Công khai (Published)</option>
                                <option value="draft" ${status eq 'draft' ? 'selected' : ''}>Bản nháp (Draft)</option>
                                <option value="hidden" ${status eq 'hidden' ? 'selected' : ''}>Đã ẩn (Hidden)</option>
                            </select>
                        </div>
                    </div>

                    <!-- Ô tìm kiếm từ khóa và nút Lọc / Đặt lại -->
                    <div class="flex flex-col sm:flex-row gap-3 pt-1 items-center">
                        <div class="relative flex-1 w-full">
                            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3.5 text-slate-400 text-xs pointer-events-none" aria-hidden="true"></i>
                            <input name="keyword" value="${keyword}" placeholder="Tìm kiếm tên bài kiểm tra..."
                                   class="w-full pl-9 pr-4 py-2.5 rounded-xl bg-surface-card border border-border-default text-xs sm:text-sm outline-none focus:ring-2 focus:ring-brand-700 transition">
                        </div>
                        <div class="flex items-center gap-2 shrink-0 w-full sm:w-auto">
                            <button type="submit" class="flex-1 sm:flex-none px-5 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs sm:text-sm shadow-xs transition">
                                <i class="fa-solid fa-filter mr-1.5" aria-hidden="true"></i>Lọc Quiz
                            </button>
                            <a href="${pageContext.request.contextPath}/expert/quizzes"
                               class="px-4 py-2.5 rounded-xl border border-border-default bg-surface-card hover:bg-slate-100 text-text-secondary hover:text-text-primary font-semibold text-xs sm:text-sm transition"
                               title="Đặt lại tất cả bộ lọc và xem toàn bộ bài kiểm tra">
                                Đặt lại
                            </a>
                        </div>
                    </div>
                </form>

                <!-- 5. BẢNG HIỂN THỊ DỮ LIỆU BÀI KIỂM TRA -->
                <div class="mt-6 overflow-x-auto border border-border-default rounded-2xl">
                    <table class="w-full text-left text-xs sm:text-sm text-text-secondary">
                        <thead class="bg-surface text-text-primary uppercase text-[11px] font-bold border-b border-border-default select-none">
                            <tr>
                                <th class="px-5 py-4 w-12 text-center">#</th>
                                <th class="px-5 py-4 font-bold">Bài kiểm tra</th>
                                <th class="px-5 py-4 font-bold">Chương &amp; Khóa học</th>
                                <th class="px-5 py-4 font-bold">Cấu hình thi</th>
                                <th class="px-5 py-4 text-center font-bold">Trạng thái</th>
                                <th class="px-5 py-4 text-center font-bold w-36">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-border-default bg-surface-card">
                            <c:choose>
                                <c:when test="${not empty quizzes}">
                                    <c:forEach var="q" items="${quizzes}" varStatus="loop">
                                        <tr class="hover:bg-brand-50/20 transition-colors ${q.hidden ? 'bg-surface/50 opacity-70' : ''}">
                                            <!-- Số thứ tự -->
                                            <td class="px-5 py-4 text-center font-bold text-text-secondary text-xs">${loop.count}</td>

                                            <!-- Tên bài kiểm tra -->
                                            <td class="px-5 py-4 max-w-sm">
                                                <div class="font-bold text-text-primary text-sm line-clamp-1">
                                                    <c:out value="${q.title}" />
                                                </div>
                                            </td>

                                            <!-- Chương và Khóa học -->
                                            <td class="px-5 py-4">
                                                <div class="flex flex-col gap-1">
                                                    <span class="inline-flex items-center text-xs font-semibold text-text-primary">
                                                        <i class="fa-regular fa-folder text-brand-700 mr-1.5 text-xs" aria-hidden="true"></i>
                                                        <c:out value="${empty q.moduleTitle ? 'Chưa gán chương' : q.moduleTitle}" />
                                                    </span>
                                                    <c:if test="${not empty q.courseTitle}">
                                                        <span class="text-[11px] text-text-secondary">
                                                            <c:out value="${q.courseTitle}" />
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </td>

                                            <!-- Cấu hình bài thi: Câu hỏi, Thời gian, Điểm đạt -->
                                            <td class="px-5 py-4 text-xs text-text-secondary">
                                                <div class="flex flex-col gap-1">
                                                    <div>
                                                        <i class="fa-solid fa-list-check text-brand-700 mr-1" aria-hidden="true"></i>
                                                        <strong class="text-text-primary font-bold">${q.questionCount}</strong> câu hỏi
                                                    </div>
                                                    <div class="flex items-center gap-2">
                                                        <span title="Thời gian làm bài">
                                                            <i class="fa-regular fa-clock text-text-secondary mr-0.5" aria-hidden="true"></i>
                                                            ${empty q.timeLimit ? 15 : q.timeLimit} phút
                                                        </span>
                                                        <span class="text-border-default">•</span>
                                                        <span title="Điểm đạt qua môn">
                                                            <i class="fa-solid fa-award text-amber-500 mr-0.5" aria-hidden="true"></i>
                                                            Đạt: <strong class="text-text-primary font-bold">${q.passScore}</strong>/10
                                                        </span>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- Trạng thái hiển thị (Published, Draft, Hidden) & Tình trạng sử dụng -->
                                            <td class="px-5 py-4 text-center whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${q.status eq 'published'}">
                                                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-brand-50 text-brand-700 border border-brand-100">
                                                            <span class="w-1.5 h-1.5 rounded-full bg-brand-600 mr-1.5"></span>Công khai
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${q.status eq 'draft'}">
                                                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-amber-50 text-status-warning border border-amber-200">
                                                            <span class="w-1.5 h-1.5 rounded-full bg-amber-500 mr-1.5"></span>Bản nháp
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-600 border border-slate-300">
                                                            <span class="w-1.5 h-1.5 rounded-full bg-slate-400 mr-1.5"></span>Đã ẩn
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                                <c:set var="isQuizUsed" value="${not empty usedQuizIds and usedQuizIds.contains(q.id)}" />
                                                <div class="mt-1">
                                                    <c:choose>
                                                        <c:when test="${isQuizUsed}">
                                                            <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200" title="Đã được sử dụng trong khóa học / chương học hoặc đã có lượt làm bài">
                                                                <i class="fa-solid fa-link mr-1 text-[8px]" aria-hidden="true"></i>Đã dùng
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-surface text-text-secondary" title="Chưa được sử dụng ở khóa học hay chương học nào">
                                                                Chưa dùng
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>

                                            <!-- Các nút thao tác (Sửa, Ẩn/Hiện, Xóa khi chưa dùng) -->
                                            <td class="px-5 py-4 text-center whitespace-nowrap">
                                                <div class="flex items-center justify-center gap-1.5">
                                                    <a href="${pageContext.request.contextPath}/expert/quizzes/detail?id=${q.id}&courseId=${courseId}"
                                                       class="inline-flex items-center px-3 py-1.5 rounded-xl border border-border-default bg-surface-card hover:bg-slate-100 text-text-primary font-semibold text-xs shadow-xs transition">
                                                        <i class="fa-solid fa-pen-to-square mr-1 text-slate-400" aria-hidden="true"></i>Sửa
                                                    </a>

                                                    <c:choose>
                                                        <c:when test="${q.hidden}">
                                                            <a href="${pageContext.request.contextPath}/expert/quizzes?action=unhide&id=${q.id}&courseId=${courseId}"
                                                               class="inline-flex items-center px-3 py-1.5 rounded-xl bg-brand-50 text-brand-700 border border-brand-100 hover:bg-brand-100 font-bold text-xs transition"
                                                               title="Bỏ ẩn để hiển thị lại quiz">
                                                                <i class="fa-solid fa-eye mr-1 text-brand-600" aria-hidden="true"></i>Hiện
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" onclick="confirmHideQuiz('${q.id}', '${courseId}')"
                                                                    class="inline-flex items-center px-3 py-1.5 rounded-xl border border-amber-200 bg-amber-50 text-status-warning hover:bg-amber-100 font-bold text-xs transition"
                                                                    title="Ẩn bài quiz để bảo toàn kết quả cũ">
                                                                <i class="fa-solid fa-eye-slash mr-1 text-amber-500" aria-hidden="true"></i>Ẩn
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <c:if test="${not isQuizUsed}">
                                                        <button type="button" onclick="confirmDeleteQuiz('${q.id}', '${courseId}')"
                                                                class="inline-flex items-center px-3 py-1.5 rounded-xl border border-rose-200 text-status-danger hover:bg-rose-50 font-bold text-xs transition"
                                                                title="Xóa vĩnh viễn bài kiểm tra chưa được sử dụng ở khóa học hay chương học nào">
                                                            <i class="fa-solid fa-trash mr-1 text-xs" aria-hidden="true"></i>Xóa
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="px-6 py-16 text-center text-text-secondary text-sm">
                                            <div class="flex flex-col items-center justify-center">
                                                <div class="w-14 h-14 rounded-2xl bg-surface text-slate-400 flex items-center justify-center text-2xl mb-3 border border-border-default">
                                                    <i class="fa-regular fa-folder-open" aria-hidden="true"></i>
                                                </div>
                                                <span class="font-bold text-text-primary text-base mb-1">Chưa tìm thấy bài kiểm tra nào</span>
                                                <span class="text-xs text-text-secondary mb-4 max-w-sm">Không có bài kiểm tra nào phù hợp với bộ lọc hiện tại của bạn.</span>
                                                <a href="${pageContext.request.contextPath}/expert/quizzes/detail?courseId=${courseId}&moduleId=${moduleId}"
                                                   class="inline-flex items-center px-4 py-2 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-xl text-xs shadow-sm transition">
                                                    <i class="fa-solid fa-plus mr-1.5" aria-hidden="true"></i>Tạo bài kiểm tra đầu tiên
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

<!-- ===========================================================================
     6. MODAL XÁC NHẬN XÓA VĨNH VIỄN & ẨN BÀI KIỂM TRA
     =========================================================================== -->
<div id="deleteConfirmModal" onclick="if(event.target === this) closeDeleteModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-surface-card rounded-2xl border border-border-default shadow-xl w-full max-w-md p-6 animate-fade-in">
        <div class="w-12 h-12 rounded-2xl bg-rose-50 text-status-danger flex items-center justify-center text-xl mb-4 border border-rose-200">
            <i class="fa-solid fa-trash" aria-hidden="true"></i>
        </div>
        <h3 class="font-extrabold text-lg text-text-primary mb-2">Xóa vĩnh viễn bài kiểm tra?</h3>
        <p class="text-xs text-text-secondary leading-relaxed mb-6">
            Bài kiểm tra này <strong>chưa từng được sử dụng</strong> ở bất kỳ khóa học hay chương học nào. Bài kiểm tra sẽ bị xóa hoàn toàn khỏi hệ thống (các câu hỏi trong ngân hàng câu hỏi vẫn được giữ nguyên). Thao tác này <strong>không thể hoàn tác</strong>.
        </p>
        <div class="flex items-center justify-end gap-3">
            <button type="button" onclick="closeDeleteModal()" class="px-4 py-2.5 rounded-xl border border-border-default text-text-secondary font-semibold text-xs hover:bg-slate-100 transition">Hủy bỏ</button>
            <a id="confirmDeleteLink" href="#" class="px-5 py-2.5 rounded-xl bg-status-danger hover:bg-rose-700 text-white font-bold text-xs shadow-sm transition">
                Xác nhận Xóa
            </a>
        </div>
    </div>
</div>

<div id="hideConfirmModal" onclick="if(event.target === this) closeHideModal()" class="hidden fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-surface-card rounded-2xl border border-border-default shadow-xl w-full max-w-md p-6 animate-fade-in">
        <div class="w-12 h-12 rounded-2xl bg-amber-50 text-status-warning flex items-center justify-center text-xl mb-4 border border-amber-200">
            <i class="fa-solid fa-eye-slash" aria-hidden="true"></i>
        </div>
        <h3 class="font-extrabold text-lg text-text-primary mb-2">Ẩn bài kiểm tra này?</h3>
        <p class="text-xs text-text-secondary leading-relaxed mb-6">
            Học viên sẽ không thấy bài kiểm tra này trong danh sách thi nữa. <strong>Lịch sử làm bài và điểm số của học viên thi trước đó vẫn được bảo toàn an toàn</strong> và bạn có thể khôi phục lại bất kỳ lúc nào.
        </p>
        <div class="flex items-center justify-end gap-3">
            <button type="button" onclick="closeHideModal()" class="px-4 py-2.5 rounded-xl border border-border-default text-text-secondary font-semibold text-xs hover:bg-slate-100 transition">Hủy bỏ</button>
            <a id="confirmHideLink" href="#" class="px-5 py-2.5 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-sm transition">
                Xác nhận Ẩn
            </a>
        </div>
    </div>
</div>

<!-- ===========================================================================
     7. JAVASCRIPT ĐIỀU KHIỂN: MODAL & BỘ LỌC TÌM KHÓA HỌC (GIỐNG LESSON LIST)
     =========================================================================== -->
<script>
    // Mở popup xác nhận xóa bài kiểm tra
    function confirmDeleteQuiz(quizId, courseId) {
        let url = '${pageContext.request.contextPath}/expert/quizzes?action=delete&id=' + quizId;
        if (courseId) {
            url += '&courseId=' + courseId;
        }
        document.getElementById('confirmDeleteLink').href = url;
        document.getElementById('deleteConfirmModal').classList.remove('hidden');
    }

    function closeDeleteModal() {
        document.getElementById('deleteConfirmModal').classList.add('hidden');
    }

    // Mở popup xác nhận ẩn bài kiểm tra
    function confirmHideQuiz(quizId, courseId) {
        let url = '${pageContext.request.contextPath}/expert/quizzes?action=hide&id=' + quizId;
        if (courseId) {
            url += '&courseId=' + courseId;
        }
        document.getElementById('confirmHideLink').href = url;
        document.getElementById('hideConfirmModal').classList.remove('hidden');
    }

    // Đóng popup xác nhận
    function closeHideModal() {
        document.getElementById('hideConfirmModal').classList.add('hidden');
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeDeleteModal();
            closeHideModal();
        }
    });

    // Xử lý bộ lọc tìm kiếm khóa học (đồng bộ giống Lesson List)
    (function() {
        const search = document.getElementById('quizCourseSearch');
        const picker = document.getElementById('quizCoursePicker');
        const options = document.getElementById('quizCourseOptions');
        if (!search || !picker || !options) return;
        const courses = Array.from(options.querySelectorAll('[data-course-option]'));
        const status = document.getElementById('quizCourseSearchStatus');
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
</script>

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
