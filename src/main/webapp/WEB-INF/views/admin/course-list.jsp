<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="min-h-[calc(100vh-64px)] flex flex-col md:flex-row bg-[#f8fafc]">
    <!-- Left Sidebar (SDS Admin Layout) -->
    <aside class="w-full md:w-64 bg-[#0f172a] text-slate-300 flex-shrink-0 flex flex-col justify-between p-5 select-none shadow-xl">
        <div>
            <!-- Brand Logo -->
            <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-3 px-3 py-4 mb-6 border-b border-slate-800/80">
                <i class="fa-solid fa-dolphin text-2xl text-emerald-400"></i>
                <span class="text-xl font-black text-white tracking-tight">LearnHub Admin</span>
            </a>

            <nav class="space-y-1.5 text-sm font-medium">
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-gauge-high w-5 text-center text-slate-400"></i>
                    <span>Dashboard</span>
                </a>

                <c:if test="${sessionScope.userRole eq 'manager' || sessionScope.userRole eq 'ROLE_MANAGER'}">
                    <a href="${pageContext.request.contextPath}/admin/courses"
                       class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-indigo-600 text-white font-bold shadow-md shadow-indigo-600/30 transition-all">
                        <i class="fa-solid fa-book-open w-5 text-center text-white"></i>
                        <span>Course Management</span>
                    </a>
                </c:if>

                <c:if test="${sessionScope.userRole eq 'admin' || sessionScope.userRole eq 'ROLE_ADMIN'}">
                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                        <i class="fa-solid fa-users w-5 text-center text-slate-400"></i>
                        <span>User Management</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/settings"
                       class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                        <i class="fa-solid fa-gear w-5 text-center text-slate-400"></i>
                        <span>System Settings</span>
                    </a>
                </c:if>
            </nav>
        </div>

        <!-- Current User Info & Back to Site -->
        <div class="pt-6 border-t border-slate-800/80 mt-6">
            <div class="flex items-center space-x-3 px-2 mb-3">
                <div class="w-9 h-9 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold text-sm uppercase">
                    ${fn:substring(sessionScope.currentUser.username, 0, 1)}
                </div>
                <div class="min-w-0 flex-1">
                    <p class="text-xs font-bold text-white truncate">${sessionScope.currentUser.username}</p>
                    <p class="text-[11px] text-slate-400 truncate">${sessionScope.currentUser.email}</p>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-2 text-xs text-slate-400 hover:text-white px-2 py-1 transition-colors">
                <i class="fa-solid fa-arrow-left text-[10px]"></i>
                <span>Return to LearnHub</span>
            </a>
        </div>
    </aside>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="flex-grow p-6 sm:p-8 lg:p-10 max-w-7xl w-full mx-auto">

            <!-- Success / Error Alert -->
            <c:if test="${not empty successMessage}">
                <div class="mb-6 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm flex items-center justify-between shadow-sm animate-fade-in">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                        <span class="font-medium">${successMessage}</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-800"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>
            <c:if test="${param.error eq 'status_failed'}">
                <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                        <span class="font-medium">Có lỗi xảy ra khi cập nhật trạng thái khóa học!</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>
            <c:if test="${param.error eq 'missing_title'}">
                <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                        <span class="font-medium">Vui lòng nhập tên khóa học!</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>

            <!-- Page Header -->
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">Course Management</h1>
                    <p class="text-slate-500 text-sm mt-1">Manage, filter, and oversee all courses published on the LearnHub platform</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/course-detail?action=new" class="inline-flex items-center gap-2 px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white font-bold rounded-xl text-sm transition shadow-sm shadow-indigo-600/20 cursor-pointer">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>+ Add New Course</span>
                    </a>
                </div>
            </div>

            <!-- Filter Bar (SDS 2.4.1) -->
            <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm mb-6">
                <form id="filterForm" action="${pageContext.request.contextPath}/admin/courses" method="get" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-12 gap-3.5 items-center">
                    <!-- Preserve Sorting and Page -->
                    <input type="hidden" name="sortBy" value="${sortBy}">
                    <input type="hidden" name="sortOrder" value="${sortOrder}">

                    <!-- Search Keyword -->
                    <div class="lg:col-span-4 relative">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                        <input type="text"
                               name="search"
                               value="${search}"
                               placeholder="Search course title or instructor..."
                               title="Search Keyword: Filter courses by title, course code, or instructor name"
                               class="w-full pl-9 pr-3.5 py-2.5 bg-slate-50/50 hover:bg-white focus:bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all">
                    </div>

                    <!-- Course Category Filter -->
                    <div class="lg:col-span-3">
                        <select name="categoryId"
                                title="Course Category"
                                class="w-full px-3.5 py-2.5 bg-slate-50/50 hover:bg-white focus:bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all cursor-pointer">
                            <option value="">All Categories</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${selectedCategory eq cat.id.toString() ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Course Status Filter -->
                    <div class="lg:col-span-2">
                        <select name="status"
                                title="Course Status"
                                class="w-full px-3.5 py-2.5 bg-slate-50/50 hover:bg-white focus:bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all cursor-pointer">
                            <option value="">All Statuses</option>
                            <option value="draft" ${selectedStatus eq 'draft' ? 'selected' : ''}>Draft</option>
                            <option value="published" ${selectedStatus eq 'published' ? 'selected' : ''}>Published</option>
                            <option value="archived" ${selectedStatus eq 'archived' ? 'selected' : ''}>Archived</option>
                        </select>
                    </div>

                    <!-- Price Type Filter -->
                    <div class="lg:col-span-2">
                        <select name="priceType"
                                title="Price Type: Free or Paid"
                                class="w-full px-3.5 py-2.5 bg-slate-50/50 hover:bg-white focus:bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all cursor-pointer">
                            <option value="">All Prices</option>
                            <option value="free" ${selectedPriceType eq 'free' ? 'selected' : ''}>Free</option>
                            <option value="paid" ${selectedPriceType eq 'paid' ? 'selected' : ''}>Paid</option>
                        </select>
                    </div>

                    <!-- Action Buttons -->
                    <div class="lg:col-span-1 flex space-x-2">
                        <button type="submit"
                                class="w-full py-2.5 bg-slate-800 hover:bg-slate-900 text-white rounded-xl font-bold text-sm transition shadow-sm text-center">
                            Filter
                        </button>
                    </div>
                </form>
            </div>

            <!-- Course Table (SDS 2.4 / 2.4.1) -->
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-slate-600">
                        <thead class="bg-slate-50/80 text-slate-500 uppercase text-[11px] font-bold tracking-wider border-b border-slate-200 select-none">
                            <tr>
                                <!-- Sortable: COURSE INFO -->
                                <th class="px-6 py-4">
                                    <a href="?search=${search}&categoryId=${selectedCategory}&status=${selectedStatus}&priceType=${selectedPriceType}&sortBy=title&sortOrder=${sortBy eq 'title' and sortOrder eq 'asc' ? 'desc' : 'asc'}"
                                       class="inline-flex items-center gap-1.5 hover:text-slate-800 transition-colors">
                                        <span>COURSE INFO</span>
                                        <c:choose>
                                            <c:when test="${sortBy eq 'title'}">
                                                <i class="fa-solid fa-arrow-${sortOrder eq 'asc' ? 'up' : 'down'} text-indigo-600 text-xs"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-sort text-slate-300 text-xs"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </a>
                                </th>

                                <!-- CATEGORY -->
                                <th class="px-6 py-4">CATEGORY</th>

                                <!-- Sortable: PRICE -->
                                <th class="px-6 py-4">
                                    <a href="?search=${search}&categoryId=${selectedCategory}&status=${selectedStatus}&priceType=${selectedPriceType}&sortBy=price&sortOrder=${sortBy eq 'price' and sortOrder eq 'asc' ? 'desc' : 'asc'}"
                                       class="inline-flex items-center gap-1.5 hover:text-slate-800 transition-colors">
                                        <span>PRICE</span>
                                        <c:choose>
                                            <c:when test="${sortBy eq 'price'}">
                                                <i class="fa-solid fa-arrow-${sortOrder eq 'asc' ? 'up' : 'down'} text-indigo-600 text-xs"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-sort text-slate-300 text-xs"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </a>
                                </th>

                                <!-- Sortable: TOTAL ENROLLED -->
                                <th class="px-6 py-4">
                                    <a href="?search=${search}&categoryId=${selectedCategory}&status=${selectedStatus}&priceType=${selectedPriceType}&sortBy=enrolled&sortOrder=${sortBy eq 'enrolled' and sortOrder eq 'asc' ? 'desc' : 'asc'}"
                                       class="inline-flex items-center gap-1.5 hover:text-slate-800 transition-colors">
                                        <span>TOTAL ENROLLED</span>
                                        <c:choose>
                                            <c:when test="${sortBy eq 'enrolled'}">
                                                <i class="fa-solid fa-arrow-${sortOrder eq 'asc' ? 'up' : 'down'} text-indigo-600 text-xs"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-sort text-slate-300 text-xs"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </a>
                                </th>

                                <!-- STATUS -->
                                <th class="px-6 py-4">STATUS</th>

                                <!-- ACTIONS -->
                                <th class="px-6 py-4 text-right">ACTIONS</th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-slate-100">
                            <c:choose>
                                <c:when test="${empty courses}">
                                    <tr>
                                        <td colspan="6" class="px-6 py-16 text-center text-slate-400">
                                            <div class="flex flex-col items-center justify-center">
                                                <i class="fa-regular fa-folder-open text-4xl mb-3 text-slate-300"></i>
                                                <p class="text-base font-semibold text-slate-700">No courses found</p>
                                                <p class="text-xs text-slate-400 mt-1">Try adjusting your keyword, category, or status filter.</p>
                                                <a href="${pageContext.request.contextPath}/admin/courses" class="mt-4 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition">
                                                    Reset all filters
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>

                                <c:otherwise>
                                    <c:forEach var="c" items="${courses}">
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <!-- Course Info -->
                                            <td class="px-6 py-4">
                                                <div class="flex items-center space-x-3.5">
                                                    <!-- Course Thumbnail / Box -->
                                                    <div class="w-12 h-12 rounded-xl overflow-hidden bg-gradient-to-br from-indigo-50 to-blue-100 border border-slate-200 flex-shrink-0 flex items-center justify-center shadow-xs">
                                                        <c:choose>
                                                            <c:when test="${not empty c.thumbnailUrl}">
                                                                <img src="${c.thumbnailUrl}" alt="${c.title}" class="w-full h-full object-cover">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-[11px] font-black tracking-wider text-indigo-700 uppercase">
                                                                    ${fn:substring(c.title, 0, 4)}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>

                                                    <!-- Title & Instructor -->
                                                    <div class="min-w-0">
                                                        <a href="${pageContext.request.contextPath}/admin/course-detail?id=${c.id}"
                                                           class="font-bold text-slate-900 hover:text-indigo-600 transition-colors line-clamp-1 block text-sm">
                                                            ${c.title}
                                                        </a>
                                                        <div class="text-xs text-slate-400 mt-0.5 flex items-center gap-2">
                                                            <span>
                                                                <i class="fa-solid fa-user-tie text-[10px] text-slate-400 mr-1"></i>Instructor: 
                                                                <strong class="text-slate-600 font-medium">${not empty c.expertName ? c.expertName : 'Unassigned'}</strong>
                                                            </span>
                                                            <span class="text-slate-300">•</span>
                                                            <span class="text-[11px] font-mono text-slate-400">#${fn:substring(c.id.toString(), 0, 8)}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- Category -->
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${not empty c.categoryName}">
                                                        <span class="px-2.5 py-1 rounded-lg text-xs font-semibold bg-slate-100 text-slate-700 border border-slate-200/80">
                                                            ${c.categoryName}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-xs text-slate-400 italic">None</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Price -->
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${empty c.price or c.price le 0}">
                                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700">
                                                            Free
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="font-bold text-slate-800">
                                                            <fmt:formatNumber value="${c.price}" type="number" maxFractionDigits="0"/> ₫
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Total Enrolled -->
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <span class="inline-flex items-center gap-1.5 font-bold text-slate-700">
                                                    <i class="fa-solid fa-user-graduate text-slate-400 text-xs"></i>
                                                    ${c.enrolledCount}
                                                    <span class="text-xs text-slate-400 font-normal">learners</span>
                                                </span>
                                            </td>

                                            <!-- Status -->
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${c.status eq 'published'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                            <i class="fa-solid fa-circle text-[6px]"></i> Published
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${c.status eq 'draft'}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                                                            <i class="fa-solid fa-circle text-[6px]"></i> Draft
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                                                            <i class="fa-solid fa-circle text-[6px]"></i> Archived
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Actions: Edit / Archive / Publish -->
                                            <td class="px-6 py-4 whitespace-nowrap text-right space-x-2">
                                                <!-- View detail link -->
                                                <a href="${pageContext.request.contextPath}/course-detail?id=${c.id}"
                                                   target="_blank"
                                                   title="View public course page"
                                                   class="inline-block text-xs font-semibold text-slate-400 hover:text-slate-600 transition">
                                                    <i class="fa-solid fa-arrow-up-right-from-square"></i>
                                                </a>

                                                <!-- Edit action -->
                                                <a href="${pageContext.request.contextPath}/admin/course-detail?id=${c.id}"
                                                   class="text-xs font-bold text-indigo-600 hover:text-indigo-800 hover:underline cursor-pointer">
                                                    Edit
                                                </a>

                                                <!-- Toggle Status (Archive / Publish) -->
                                                <c:choose>
                                                    <c:when test="${c.status eq 'published'}">
                                                        <form action="${pageContext.request.contextPath}/admin/course-status" method="post" class="inline" onsubmit="return confirm('Bạn có chắc chắn muốn lưu trữ (Archive) khóa học này?');">
                                                            <input type="hidden" name="courseId" value="${c.id}">
                                                            <input type="hidden" name="status" value="archived">
                                                            <button type="submit" class="text-xs font-bold text-amber-600 hover:text-amber-800 hover:underline cursor-pointer ml-2">
                                                                Archive
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="${pageContext.request.contextPath}/admin/course-status" method="post" class="inline" onsubmit="return confirm('Bạn có muốn xuất bản (Publish) khóa học này lên hệ thống?');">
                                                            <input type="hidden" name="courseId" value="${c.id}">
                                                            <input type="hidden" name="status" value="published">
                                                            <button type="submit" class="text-xs font-bold text-emerald-600 hover:text-emerald-800 hover:underline cursor-pointer ml-2">
                                                                Publish
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer -->
                <div class="px-6 py-4 bg-slate-50/50 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
                    <div>
                        Showing 
                        <strong class="text-slate-800 font-semibold">${totalCourses gt 0 ? (currentPage - 1) * pageSize + 1 : 0}</strong>
                        to 
                        <strong class="text-slate-800 font-semibold">${currentPage * pageSize lt totalCourses ? currentPage * pageSize : totalCourses}</strong>
                        of 
                        <strong class="text-slate-800 font-semibold">${totalCourses}</strong> courses
                    </div>

                    <c:if test="${totalPages gt 1}">
                        <div class="flex items-center space-x-1">
                            <!-- Prev button -->
                            <c:if test="${currentPage gt 1}">
                                <a href="?search=${search}&categoryId=${selectedCategory}&status=${selectedStatus}&priceType=${selectedPriceType}&sortBy=${sortBy}&sortOrder=${sortOrder}&page=${currentPage - 1}"
                                   class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-100 font-medium text-slate-700 transition">
                                    Previous
                                </a>
                            </c:if>

                            <!-- Pages -->
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:choose>
                                    <c:when test="${p eq currentPage}">
                                        <span class="px-3 py-1.5 rounded-lg bg-indigo-600 text-white font-bold">${p}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?search=${search}&categoryId=${selectedCategory}&status=${selectedStatus}&priceType=${selectedPriceType}&sortBy=${sortBy}&sortOrder=${sortOrder}&page=${p}"
                                           class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-100 text-slate-700 font-medium transition">
                                            ${p}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <!-- Next button -->
                            <c:if test="${currentPage lt totalPages}">
                                <a href="?search=${search}&categoryId=${selectedCategory}&status=${selectedStatus}&priceType=${selectedPriceType}&sortBy=${sortBy}&sortOrder=${sortOrder}&page=${currentPage + 1}"
                                   class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-100 font-medium text-slate-700 transition">
                                    Next
                                </a>
                            </c:if>
                        </div>
                    </c:if>
                </div>
            </div>

        </main>
    </div>
</div>

<!-- ========================================================================= -->
<!-- Modal: Create / Edit Course Form                                          -->
<!-- ========================================================================= -->
<div id="courseModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs hidden transition-opacity">
    <div class="bg-white rounded-3xl border border-slate-200 shadow-2xl max-w-2xl w-full max-h-[92vh] overflow-y-auto transform transition-transform animate-scale-up">
        <!-- Modal Header -->
        <div class="flex items-center justify-between px-7 py-5 border-b border-slate-100">
            <div>
                <h3 id="modalTitle" class="text-xl font-black text-slate-900">Add New Course</h3>
                <p id="modalSubtitle" class="text-xs text-slate-400 mt-0.5">Fill in the course details below</p>
            </div>
            <button type="button" onclick="closeCourseModal()" class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-400 hover:text-slate-700 flex items-center justify-center transition-colors cursor-pointer">
                <i class="fa-solid fa-xmark text-sm"></i>
            </button>
        </div>

        <!-- Modal Form -->
        <form action="${pageContext.request.contextPath}/admin/courses" method="post" class="p-7 space-y-4">
            <input type="hidden" name="action" value="save">
            <input type="hidden" id="courseId" name="id" value="">

            <!-- Title -->
            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                    Course Title <span class="text-rose-500">*</span>
                </label>
                <input type="text"
                       id="courseTitleInput"
                       name="title"
                       required
                       placeholder="e.g. Java Web Development with Servlets & JSP"
                       class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition">
            </div>

            <!-- Grid: Category & Instructor -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <!-- Category -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                        Category <span class="text-rose-500">*</span>
                    </label>
                    <select id="courseCategoryInput"
                            name="categoryId"
                            required
                            class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition cursor-pointer">
                        <option value="">Select Category</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}">${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Instructor -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                        Assigned Instructor
                    </label>
                    <select id="courseExpertInput"
                            name="expertId"
                            class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition cursor-pointer">
                        <option value="">Select Instructor</option>
                        <c:forEach var="inst" items="${instructors}">
                            <option value="${inst.id}">${inst.username} (${inst.email})</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- Grid: Price & Status -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <!-- Price -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                        Price (VND) <span class="text-xs text-slate-400 font-normal">(0 = Free)</span>
                    </label>
                    <div class="relative">
                        <input type="number"
                               id="coursePriceInput"
                               name="price"
                               min="0"
                               step="1000"
                               placeholder="499000"
                               class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition">
                        <span class="absolute right-3.5 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-400">₫</span>
                    </div>
                </div>

                <!-- Status -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                        Publication Status
                    </label>
                    <select id="courseStatusInput"
                            name="status"
                            class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition cursor-pointer">
                        <option value="draft">Draft (Bản nháp)</option>
                        <option value="published">Published (Công khai)</option>
                        <option value="archived">Archived (Lưu trữ / Tạm ẩn)</option>
                    </select>
                </div>
            </div>

            <!-- Thumbnail URL -->
            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                    Thumbnail Image URL
                </label>
                <input type="url"
                       id="courseThumbnailInput"
                       name="thumbnailUrl"
                       placeholder="https://images.unsplash.com/..."
                       class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition">
            </div>

            <!-- Description -->
            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                    Course Description
                </label>
                <textarea id="courseDescriptionInput"
                          name="description"
                          rows="4"
                          placeholder="Provide a comprehensive summary of what learners will achieve..."
                          class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition"></textarea>
            </div>

            <!-- Modal Footer Actions -->
            <div class="pt-4 border-t border-slate-100 flex items-center justify-end space-x-3">
                <button type="button"
                        onclick="closeCourseModal()"
                        class="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl text-sm transition cursor-pointer">
                    Cancel
                </button>
                <button type="submit"
                        class="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white font-bold rounded-xl text-sm shadow-md shadow-indigo-600/20 transition cursor-pointer">
                    Save Course
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    const modal = document.getElementById('courseModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalSubtitle = document.getElementById('modalSubtitle');
    const courseIdInput = document.getElementById('courseId');
    const courseTitleInput = document.getElementById('courseTitleInput');
    const courseCategoryInput = document.getElementById('courseCategoryInput');
    const courseExpertInput = document.getElementById('courseExpertInput');
    const coursePriceInput = document.getElementById('coursePriceInput');
    const courseStatusInput = document.getElementById('courseStatusInput');
    const courseThumbnailInput = document.getElementById('courseThumbnailInput');
    const courseDescriptionInput = document.getElementById('courseDescriptionInput');

    function openCreateModal() {
        modalTitle.innerText = "Add New Course";
        modalSubtitle.innerText = "Fill in the details to publish a new course";
        courseIdInput.value = "";
        courseTitleInput.value = "";
        courseCategoryInput.value = "";
        courseExpertInput.value = "";
        coursePriceInput.value = "0";
        courseStatusInput.value = "draft";
        courseThumbnailInput.value = "";
        courseDescriptionInput.value = "";
        modal.classList.remove('hidden');
    }

    function openEditModalFromRow(id) {
        // Fetch course JSON
        fetch('${pageContext.request.contextPath}/admin/courses?action=get-json&id=' + encodeURIComponent(id))
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    alert('Could not find course information.');
                    return;
                }
                modalTitle.innerText = "Edit Course";
                modalSubtitle.innerText = "Update details for: " + data.title;
                courseIdInput.value = data.id || "";
                courseTitleInput.value = data.title || "";
                courseCategoryInput.value = data.categoryId || "";
                courseExpertInput.value = data.expertId || "";
                coursePriceInput.value = data.price != null ? data.price : "0";
                courseStatusInput.value = data.status || "draft";
                courseThumbnailInput.value = data.thumbnailUrl || "";
                courseDescriptionInput.value = data.description || "";
                modal.classList.remove('hidden');
            })
            .catch(err => {
                console.error(err);
                alert('Error loading course details.');
            });
    }

    function closeCourseModal() {
        modal.classList.add('hidden');
    }

    // Close modal on backdrop click
    modal.addEventListener('click', function(e) {
        if (e.target === modal) {
            closeCourseModal();
        }
    });

    // Check if URL has ?action=new to auto-open modal
    (function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('action') === 'new') {
            openCreateModal();
        }
    })();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
