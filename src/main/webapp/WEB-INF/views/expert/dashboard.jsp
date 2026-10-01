<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<header class="sticky top-0 z-50 bg-white border-b border-slate-200 shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16 gap-4">
            
            <!-- Phía bên trái: LMS LOGO -->
            <div class="flex items-center space-x-3 shrink-0">
                <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-2.5">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-600 flex items-center justify-center text-white shadow-md shadow-blue-500/20">
                        <i class="fa-solid fa-graduation-cap text-xl"></i>
                    </div>
                    <span class="text-2xl font-black bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">LearnHub</span>
                </a>
                <span class="hidden md:inline-block px-2.5 py-0.5 text-xs font-bold bg-purple-50 text-purple-700 rounded-full border border-purple-200">
                    Expert
                </span>
            </div>
            <!-- Ở giữa: THANH TÌM KIẾM (SEARCH BAR) -->
            <div class="flex-1 max-w-md mx-2 sm:mx-6">
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                        <i class="fa-solid fa-magnifying-glass text-sm"></i>
                    </div>
                    <input type="text" 
                           id="courseSearchInput"
                           placeholder="Search courses..." 
                           class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                </div>
            </div>
            <!-- Phía bên phải: USER NAME & AVATAR DROPDOWN -->
            <div class="flex items-center space-x-3 shrink-0">
                <div class="relative group">
                    <button class="flex items-center space-x-2.5 p-1.5 rounded-xl hover:bg-slate-50 transition focus:outline-none">
                        <div class="w-9 h-9 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-600 text-white font-bold flex items-center justify-center shadow-sm text-sm">
                            <c:choose>
                                <c:when test="${not empty sessionScope.userName}">
                                    ${fn:substring(sessionScope.userName, 0, 1)}
                                </c:when>
                                <c:when test="${not empty sessionScope.currentUser}">
                                    ${fn:substring(sessionScope.currentUser.username, 0, 1)}
                                </c:when>
                                <c:otherwise>E</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="hidden sm:block text-left">
                            <p class="text-sm font-bold text-slate-800 leading-tight">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.userName}">
                                        ${sessionScope.userName}
                                    </c:when>
                                    <c:when test="${not empty sessionScope.currentUser}">
                                        ${sessionScope.currentUser.username}
                                    </c:when>
                                    <c:otherwise>Expert Name</c:otherwise>
                                </c:choose>
                            </p>
                            <p class="text-[11px] font-semibold text-purple-600">Subject Expert</p>
                        </div>
                        <i class="fa-solid fa-angle-down text-xs text-slate-400 ml-1 transition-transform group-hover:rotate-180"></i>
                    </button>
                    <!-- Dropdown Menu -->
                    <div class="absolute right-0 mt-1 w-52 bg-white border border-slate-200 rounded-xl shadow-xl py-2 hidden group-hover:block transition-all z-50">
                        <div class="px-4 py-2 border-b border-slate-100">
                            <p class="text-[11px] uppercase font-bold text-slate-400">Tài khoản</p>
                            <p class="text-sm font-semibold text-slate-800 truncate">
                                ${not empty sessionScope.currentUser ? sessionScope.currentUser.email : 'expert@learnhub.vn'}
                            </p>
                        </div>
                        <a href="${pageContext.request.contextPath}/home" class="flex items-center px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition">
                            <i class="fa-solid fa-house w-5 text-slate-400 mr-2"></i> Trang chủ
                        </a>
                        <a href="${pageContext.request.contextPath}/lessons/manage" class="flex items-center px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition">
                            <i class="fa-solid fa-book-open w-5 text-slate-400 mr-2"></i> Quản lý bài học
                        </a>
                        <div class="border-t border-slate-100 my-1"></div>
                        <a href="${pageContext.request.contextPath}/auth/logout" class="flex items-center px-4 py-2 text-sm text-rose-600 hover:bg-rose-50 transition">
                            <i class="fa-solid fa-arrow-right-from-bracket w-5 mr-2"></i> Đăng xuất
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</header>
<main class="flex-grow py-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
    <!-- Breadcrumb & Tiêu đề -->
    <div class="mb-6">
        <nav class="flex items-center text-xs text-slate-400 font-medium mb-2 space-x-2">
            <a href="${pageContext.request.contextPath}/home" class="hover:text-blue-600 transition">Home</a>
            <span>/</span>
            <span class="text-slate-600">Assigned Courses</span>
        </nav>
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">Assigned Courses</h1>
                <p class="text-slate-500 text-sm mt-1">Danh sách các khóa học được phân công xây dựng nội dung bài giảng & đề thi</p>
            </div>
        </div>
    </div>
    <!-- Stats Quick Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-xl font-bold">
                <i class="fa-solid fa-graduation-cap"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-slate-400">Khóa học được giao</p>
                <h3 class="text-2xl font-black text-slate-900">${totalCourses}</h3>
            </div>
        </div>
        <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-xl font-bold">
                <i class="fa-solid fa-folder-tree"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-slate-400">Trạng thái hệ thống</p>
                <h3 class="text-2xl font-black text-emerald-600">Đang hoạt động</h3>
            </div>
        </div>
        <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center space-x-4">
            <div class="w-12 h-12 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-xl font-bold">
                <i class="fa-solid fa-chalkboard-user"></i>
            </div>
            <div>
                <p class="text-xs font-semibold uppercase text-slate-400">Phân quyền</p>
                <h3 class="text-xl font-bold text-slate-900">Subject Expert</h3>
            </div>
        </div>
    </div>
    <!-- Assigned Courses Table -->
    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mb-6">
        <div class="p-5 border-b border-slate-100 flex items-center justify-between">
            <h2 class="font-bold text-slate-800 text-lg">Danh Sách Khóa Học (Assigned Courses)</h2>
            <span class="text-xs font-semibold px-3 py-1 bg-slate-100 text-slate-600 rounded-full">
                Tổng cộng: ${totalCourses} khóa học
            </span>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-600" id="coursesTable">
                <thead class="bg-slate-50 text-slate-700 uppercase text-xs font-bold border-b border-slate-200">
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
                <tbody class="divide-y divide-slate-100">
                    <c:choose>
                        <c:when test="${not empty courses}">
                            <c:forEach var="c" items="${courses}" varStatus="loop">
                                <tr class="hover:bg-slate-50 transition-colors course-row">
                                    <td class="px-6 py-4 text-center font-bold text-slate-400">
                                        ${loop.count + (currentPage - 1) * 8}
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="font-bold text-slate-900 course-title">${c.title}</div>
                                        <div class="text-xs text-slate-400 mt-0.5 line-clamp-1">${c.description}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold bg-slate-100 text-slate-700 whitespace-nowrap">
                                            ${c.categoryName != null ? c.categoryName : 'Chuyên ngành'}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-center whitespace-nowrap">
                                        <span class="inline-flex items-center justify-center px-3 py-1 bg-blue-50 text-blue-700 rounded-lg text-xs font-bold whitespace-nowrap min-w-[80px]">
                                            ${c.moduleCount} modules
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-center whitespace-nowrap">
                                        <span class="inline-flex items-center justify-center px-3 py-1 bg-emerald-50 text-emerald-700 rounded-lg text-xs font-bold whitespace-nowrap min-w-[65px]">
                                            ${c.lessonCount} bài
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-center whitespace-nowrap">
                                        <c:choose>
                                            <c:when test="${c.status eq 'published'}">
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 whitespace-nowrap">
                                                    ● Published
                                                </span>
                                            </c:when>
                                            <c:when test="${c.status eq 'draft'}">
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-amber-100 text-amber-800 whitespace-nowrap">
                                                    ● Draft
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-600 whitespace-nowrap">
                                                    ${c.status}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-6 py-4 text-right whitespace-nowrap">
                                        <a href="${pageContext.request.contextPath}/lessons/manage?courseId=${c.id}" 
                                           class="inline-flex items-center px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-xs transition shadow-sm space-x-1 whitespace-nowrap">
                                            <i class="fa-solid fa-pen-to-square text-xs mr-1"></i>
                                            <span>Manage Content</span>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" class="px-6 py-12 text-center text-slate-400">
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
            <div class="px-6 py-4 bg-slate-50 border-t border-slate-100 flex items-center justify-between">
                <span class="text-xs text-slate-500 font-medium">Trang ${currentPage} / ${totalPages}</span>
                <div class="flex items-center space-x-2">
                    <c:if test="${currentPage > 1}">
                        <a href="?page=${currentPage - 1}" class="px-3 py-1.5 bg-white border border-slate-200 text-slate-600 text-xs font-bold rounded-lg hover:bg-slate-100 transition">
                            <i class="fa-solid fa-chevron-left mr-1"></i> Trước
                        </a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <a href="?page=${p}" class="px-3 py-1.5 text-xs font-bold rounded-lg transition ${currentPage eq p ? 'bg-blue-600 text-white' : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-100'}">
                            ${p}
                        </a>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}" class="px-3 py-1.5 bg-white border border-slate-200 text-slate-600 text-xs font-bold rounded-lg hover:bg-slate-100 transition">
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
