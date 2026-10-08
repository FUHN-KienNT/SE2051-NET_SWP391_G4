<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow pt-12 pb-16 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <div class="mb-6">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl sm:text-3xl font-bold text-text-primary tracking-tight">Assigned Courses</h1>
                <p class="text-text-secondary text-sm mt-1">Danh sách các khóa học được phân công xây dựng nội dung bài giảng & đề thi</p>
            </div>
        </div>
    </div>
    <!-- Stats Quick Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div class="bg-surface-card p-6 rounded-xl border border-border-default shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center text-xl font-bold">
                <i class="fa-solid fa-graduation-cap"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-text-secondary">Khóa học được giao</p>
                <h3 class="text-2xl font-bold text-text-primary">${totalCourses}</h3>
            </div>
        </div>
        <div class="bg-surface-card p-6 rounded-xl border border-border-default shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center text-xl font-bold">
                <i class="fa-solid fa-folder-tree"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-text-secondary">Trạng thái hệ thống</p>
                <h3 class="text-2xl font-bold text-brand-700">Đang hoạt động</h3>
            </div>
        </div>
        <div class="bg-surface-card p-6 rounded-xl border border-border-default shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center text-xl font-bold">
                <i class="fa-solid fa-chalkboard-user"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-text-secondary">Phân quyền</p>
                <h3 class="text-xl font-bold text-text-primary">Subject Expert</h3>
            </div>
        </div>
    </div>
    <div class="bg-surface-card rounded-xl border border-border-default shadow-sm overflow-hidden">
            <div class="p-4 sm:p-6 border-b border-border-default flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                <h2 class="font-bold text-text-primary text-lg min-w-0">Danh Sách Khóa Học (Assigned Courses)</h2>
                <div class="relative w-full lg:max-w-xs">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-secondary">
                        <i class="fa-solid fa-magnifying-glass text-sm"></i>
                    </div>
                    <input type="text"
                           id="courseSearchInput"
                           placeholder="Search courses..."
                           class="w-full pl-10 pr-4 py-2 bg-surface border border-border-default rounded-lg text-sm placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition-all">
                </div>
            </div>
        <div class="overflow-x-auto">
            <table class="w-full min-w-max text-left text-sm text-text-secondary" id="coursesTable">
                <thead class="bg-surface text-slate-700 uppercase text-xs font-bold border-b border-border-default">
                    <tr>
                        <th class="px-6 py-4 w-12 text-center">#</th>
                        <th class="px-6 py-4">Tên khóa học (Course Title)</th>
                        <th class="px-6 py-4 whitespace-nowrap">Danh mục</th>
                        <th class="px-6 py-4 text-center whitespace-nowrap">Modules</th>
                        <th class="px-6 py-4 text-center whitespace-nowrap">Lessons</th>
                        <th class="px-6 py-4 text-center whitespace-nowrap">Trạng thái</th>
                        <th class="px-6 py-4 text-right whitespace-nowrap">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-border-default">
                    <c:choose>
                        <c:when test="${not empty courses}">
                            <c:forEach var="c" items="${courses}" varStatus="loop">
                                <tr class="hover:bg-surface transition-colors course-row">
                                    <td class="px-6 py-4 text-center font-bold text-text-secondary">
                                        ${loop.count + (currentPage - 1) * 8}
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="font-semibold text-text-primary max-w-xs break-words course-title">${c.title}</div>
                                        <div class="text-xs text-text-secondary mt-1 max-w-xs line-clamp-1">${c.description}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold bg-surface text-slate-700 whitespace-nowrap">
                                            ${c.categoryName != null ? c.categoryName : 'Chuyên ngành'}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-center whitespace-nowrap">
                                        <span class="inline-flex items-center justify-center px-3 py-1 bg-brand-50 text-brand-700 rounded-lg text-xs font-bold whitespace-nowrap min-w-20">
                                            ${c.moduleCount} modules
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-center whitespace-nowrap">
                                        <span class="inline-flex items-center justify-center px-3 py-1 bg-brand-50 text-brand-700 rounded-lg text-xs font-bold whitespace-nowrap min-w-16">
                                            ${c.lessonCount} bài
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-center whitespace-nowrap">
                                        <c:choose>
                                            <c:when test="${c.status eq 'published'}">
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-brand-100 text-brand-900 whitespace-nowrap">
                                                    ● Published
                                                </span>
                                            </c:when>
                                            <c:when test="${c.status eq 'draft'}">
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-amber-100 text-amber-800 whitespace-nowrap">
                                                    ● Draft
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-surface text-text-secondary whitespace-nowrap">
                                                    ${c.status}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-6 py-4 text-right whitespace-nowrap">
                                        <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${c.id}"
                                           class="inline-flex items-center px-3.5 py-1.5 bg-brand-700 hover:bg-brand-800 text-white font-bold rounded-lg text-xs transition shadow-sm space-x-1 whitespace-nowrap focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                                            <i class="fa-solid fa-pen-to-square text-xs mr-1"></i>
                                            <span>Manage Content</span>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" class="px-6 py-12 text-center text-text-secondary">
                                    <i class="fa-regular fa-folder-open text-4xl mb-3 block text-slate-300"></i>
                                    Hiện chưa có khóa học nào được chỉ định cho bạn.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        <!-- Pagination Controls -->
        <c:if test="${totalPages > 1}">
            <div class="px-6 py-4 bg-surface border-t border-border-default flex flex-wrap items-center justify-between gap-4">
                <span class="text-xs text-text-secondary font-medium">Trang ${currentPage} / ${totalPages}</span>
                <div class="flex flex-wrap items-center gap-2">
                    <c:if test="${currentPage > 1}">
                        <a href="?page=${currentPage - 1}" class="px-3 py-1.5 bg-surface-card border border-border-default text-text-secondary text-xs font-bold rounded-lg hover:bg-surface transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            <i class="fa-solid fa-chevron-left mr-1"></i> Trước
                        </a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <a href="?page=${p}" class="px-3 py-1.5 text-xs font-bold rounded-lg transition ${currentPage eq p ? 'bg-brand-700 text-white' : 'bg-surface-card border border-border-default text-slate-700 hover:bg-surface'} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            ${p}
                        </a>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}" class="px-3 py-1.5 bg-surface-card border border-border-default text-text-secondary text-xs font-bold rounded-lg hover:bg-surface transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            Sau <i class="fa-solid fa-chevron-right ml-1"></i>
                        </a>
                    </c:if>
                </div>
            </div>
        </c:if>
    </div>
</main>
<script>
    document.getElementById('courseSearchInput').addEventListener('input', function(e) {
        const keyword = e.target.value.toLowerCase().trim();
        const rows = document.querySelectorAll('.course-row');
        rows.forEach(row => {
            const title = row.querySelector('.course-title').textContent.toLowerCase();
            if (title.includes(keyword)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />