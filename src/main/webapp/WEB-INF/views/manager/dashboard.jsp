<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<style>
    .custom-scrollbar::-webkit-scrollbar {
        width: 6px;
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: rgba(148, 163, 184, 0.08);
        border-radius: 9999px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: rgba(148, 163, 184, 0.4);
        border-radius: 9999px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover {
        background: rgba(148, 163, 184, 0.7);
    }
</style>

<main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">

            <!-- Success / Error Alert Messages -->
            <c:if test="${not empty successMessage}">
                <div class="p-4 rounded-xl bg-brand-50 border border-brand-100 text-status-success text-sm flex items-center justify-between shadow-xs">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-check text-status-success text-base"></i>
                        <span class="font-medium">${successMessage}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-text-secondary hover:text-text-primary"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="p-4 rounded-xl bg-rose-50 border border-rose-200 text-status-danger text-sm flex items-center justify-between shadow-xs">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-status-danger text-base"></i>
                        <span class="font-medium">${errorMessage}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-text-secondary hover:text-text-primary"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>

            <!-- Page Header -->
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-2 border-b border-border-default">
                <div>
                    <div class="flex items-center gap-2.5">
                        <span class="w-8 h-8 rounded-lg bg-brand-50 text-brand-700 flex items-center justify-center font-bold text-sm">
                            <i class="fa-solid fa-book-bookmark"></i>
                        </span>
                        <h1 class="text-2xl sm:text-3xl font-black text-text-primary tracking-tight">Manager Dashboard</h1>
                    </div>
                    <p class="text-xs sm:text-sm text-text-secondary mt-1">
                        Oversee courses, evaluate expert curriculum submissions, allocate domain experts, and monitor real-time enrollments.
                    </p>
                </div>
                <div class="flex items-center gap-2.5">
                    <a href="${pageContext.request.contextPath}/admin/course-detail?action=new"
                       class="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold bg-brand-700 hover:bg-brand-800 text-white shadow-xs transition cursor-pointer">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>Create Course</span>
                    </a>
                </div>
            </div>

            <!-- Filter & Period Bar -->
            <div class="bg-surface-card p-4 rounded-2xl border border-border-default shadow-xs">
                <form action="${pageContext.request.contextPath}/manager/dashboard" method="get" class="flex flex-col md:flex-row md:items-center justify-between gap-3">
                    <!-- Search Course -->
                    <div class="relative flex-1 max-w-md">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-text-secondary text-xs"></i>
                        <input type="text"
                               name="search"
                               value="${dashboard.search}"
                               placeholder="Search course by title or unique code (e.g. CS101, JAVA)..."
                               class="w-full pl-9 pr-3.5 py-2 text-xs sm:text-sm bg-surface border border-border-default rounded-xl text-text-primary placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-brand-700 transition">
                    </div>

                    <!-- Filters: Period and Category -->
                    <div class="flex flex-wrap items-center gap-2.5">
                        <div class="flex items-center gap-1.5">
                            <label for="periodSelect" class="text-xs font-semibold text-text-secondary whitespace-nowrap">Period:</label>
                            <select id="periodSelect"
                                    name="period"
                                    onchange="this.form.submit()"
                                    class="px-3 py-2 text-xs sm:text-sm bg-surface border border-border-default rounded-xl text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700 cursor-pointer">
                                <option value="month" ${dashboard.dateRange eq 'month' ? 'selected' : ''}>This Month</option>
                                <option value="quarter" ${dashboard.dateRange eq 'quarter' ? 'selected' : ''}>Last Quarter</option>
                                <option value="all" ${dashboard.dateRange eq 'all' ? 'selected' : ''}>All Time</option>
                            </select>
                        </div>

                        <div class="flex items-center gap-1.5">
                            <select name="categoryId"
                                    onchange="this.form.submit()"
                                    class="px-3 py-2 text-xs sm:text-sm bg-surface border border-border-default rounded-xl text-text-primary focus:outline-none focus:ring-2 focus:ring-brand-700 cursor-pointer">
                                <option value="">All Categories</option>
                                <c:forEach var="cat" items="${dashboard.categories}">
                                    <option value="${cat.id}" ${dashboard.selectedCategory eq cat.id.toString() ? 'selected' : ''}>${cat.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <button type="submit" class="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white font-bold rounded-xl text-xs sm:text-sm transition shadow-xs">
                            Filter
                        </button>
                        <c:if test="${not empty dashboard.search or not empty dashboard.selectedCategory or dashboard.dateRange ne 'month'}">
                            <a href="${pageContext.request.contextPath}/manager/dashboard" class="px-3 py-2 text-xs text-text-secondary hover:text-text-primary underline">
                                Reset
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>

            <!-- 4 Metric Cards (KPIs) -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                
                <!-- Card 1: Total Courses Metric (Published vs Unpublished) -->
                <div class="bg-surface-card border border-border-default rounded-2xl p-4 sm:p-5 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <span class="text-xs font-semibold uppercase tracking-wider text-text-secondary">Total Courses</span>
                        <span class="w-8 h-8 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-sm">
                            <i class="fa-solid fa-book"></i>
                        </span>
                    </div>
                    <div class="mt-3">
                        <div class="text-2xl sm:text-3xl font-black text-text-primary">
                            <fmt:formatNumber value="${dashboard.totalCourses}" type="number"/>
                        </div>
                        <div class="flex items-center gap-2 mt-2 pt-2 border-t border-border-default text-xs">
                            <span class="inline-flex items-center gap-1 text-status-success font-semibold">
                                <span class="w-2 h-2 rounded-full bg-status-success"></span>
                                <strong>${dashboard.publishedCourses}</strong> Published
                            </span>
                            <span class="text-border-default">|</span>
                            <span class="inline-flex items-center gap-1 text-status-warning font-semibold">
                                <span class="w-2 h-2 rounded-full bg-status-warning"></span>
                                <strong>${dashboard.unpublishedCourses}</strong> Unpublished
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Pending Reviews Metric -->
                <div class="bg-surface-card border border-border-default rounded-2xl p-4 sm:p-5 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <span class="text-xs font-semibold uppercase tracking-wider text-text-secondary">Courses Awaiting Review</span>
                        <span class="w-8 h-8 rounded-xl bg-amber-50 text-status-warning flex items-center justify-center text-sm">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </span>
                    </div>
                    <div class="mt-3">
                        <div class="text-2xl sm:text-3xl font-black text-status-warning">
                            <fmt:formatNumber value="${dashboard.pendingReviewsCount}" type="number"/>
                        </div>
                        <p class="text-xs text-text-secondary mt-2 pt-2 border-t border-border-default flex items-center justify-between">
                            <span>Curriculum submissions</span>
                            <c:choose>
                                <c:when test="${dashboard.pendingReviewsCount gt 0}">
                                    <span class="text-status-warning font-bold">Needs Review</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-status-success font-medium">All cleared</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>

                <!-- Card 3: Unassigned Courses Metric -->
                <div class="bg-surface-card border border-border-default rounded-2xl p-4 sm:p-5 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <span class="text-xs font-semibold uppercase tracking-wider text-text-secondary">Unassigned Courses</span>
                        <span class="w-8 h-8 rounded-xl bg-rose-50 text-status-danger flex items-center justify-center text-sm">
                            <i class="fa-solid fa-user-slash"></i>
                        </span>
                    </div>
                    <div class="mt-3">
                        <div class="text-2xl sm:text-3xl font-black text-status-danger">
                            <fmt:formatNumber value="${dashboard.unassignedCoursesCount}" type="number"/>
                        </div>
                        <p class="text-xs text-text-secondary mt-2 pt-2 border-t border-border-default flex items-center justify-between">
                            <span>Lacking domain expert</span>
                            <c:choose>
                                <c:when test="${dashboard.unassignedCoursesCount gt 0}">
                                    <span class="text-status-danger font-bold">Pending Allocation</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-status-success font-medium">All assigned</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>

                <!-- Card 4: Total Enrollments Metric + Growth -->
                <div class="bg-surface-card border border-border-default rounded-2xl p-4 sm:p-5 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <span class="text-xs font-semibold uppercase tracking-wider text-text-secondary">Total Enrollments</span>
                        <span class="w-8 h-8 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center text-sm">
                            <i class="fa-solid fa-users"></i>
                        </span>
                    </div>
                    <div class="mt-3">
                        <div class="flex items-baseline justify-between">
                            <div class="text-2xl sm:text-3xl font-black text-text-primary">
                                <fmt:formatNumber value="${dashboard.totalEnrollments}" type="number"/>
                            </div>
                            <span class="inline-flex items-center text-xs font-bold px-2 py-0.5 rounded-full bg-brand-50 text-brand-700">
                                <c:choose>
                                    <c:when test="${dashboard.enrollmentGrowthPct ge 0}">
                                        ↑ +<fmt:formatNumber value="${dashboard.enrollmentGrowthPct}" maxFractionDigits="1"/>%
                                    </c:when>
                                    <c:otherwise>
                                        ↓ <fmt:formatNumber value="${dashboard.enrollmentGrowthPct}" maxFractionDigits="1"/>%
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <p class="text-xs text-text-secondary mt-2 pt-2 border-t border-border-default">
                            vs previous period (${dashboard.dateRange eq 'quarter' ? 'Last Quarter' : 'Last Month'})
                        </p>
                    </div>
                </div>

            </div>

            <!-- Manager Action Queues: Pending Reviews & Unassigned Courses -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-5">
                
                <!-- Queue 1: Pending Curriculum Submissions -->
                <div class="bg-surface-card border border-border-default rounded-2xl p-5 shadow-xs">
                    <div class="flex items-center justify-between pb-3 border-b border-border-default">
                        <div class="flex items-center gap-2">
                            <span class="w-2.5 h-2.5 rounded-full bg-status-warning animate-pulse"></span>
                            <h3 class="font-bold text-sm sm:text-base text-text-primary">Pending Curriculum Submissions</h3>
                        </div>
                        <span class="text-xs font-bold px-2.5 py-0.5 rounded-full bg-amber-50 text-status-warning border border-amber-200">
                            ${dashboard.pendingReviewsCount} awaiting review
                        </span>
                    </div>

                    <div class="divide-y divide-border-default mt-2">
                        <c:choose>
                            <c:when test="${empty dashboard.pendingReviews}">
                                <div class="py-8 text-center text-text-secondary text-xs">
                                    <i class="fa-regular fa-circle-check text-2xl text-status-success mb-2 block"></i>
                                    No pending curriculum submissions awaiting review at this time.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${dashboard.pendingReviews}">
                                    <div class="py-3 flex items-center justify-between gap-3">
                                        <div class="min-w-0">
                                            <h4 class="text-xs sm:text-sm font-bold text-text-primary truncate">${item.courseTitle}</h4>
                                            <p class="text-xs text-text-secondary mt-0.5">
                                                Authoring Expert: <strong class="text-text-primary font-medium">${not empty item.expertName ? item.expertName : 'Unassigned'}</strong> • 
                                                <span class="font-semibold text-status-warning">${item.pendingLessonCount} draft lesson(s) submitted</span>
                                            </p>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/admin/lesson-review?courseId=${item.courseId}"
                                           class="shrink-0 px-3 py-1.5 rounded-xl text-xs font-bold bg-brand-700 hover:bg-brand-800 text-white transition shadow-xs">
                                            Review
                                        </a>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Queue 2: Unassigned Courses (Needs Domain Expert Allocation) -->
                <div class="bg-surface-card border border-border-default rounded-2xl p-5 shadow-xs">
                    <div class="flex items-center justify-between pb-3 border-b border-border-default">
                        <div class="flex items-center gap-2">
                            <span class="w-2.5 h-2.5 rounded-full bg-status-danger"></span>
                            <h3 class="font-bold text-sm sm:text-base text-text-primary">Courses Lacking Assigned Expert</h3>
                        </div>
                        <span class="text-xs font-bold px-2.5 py-0.5 rounded-full bg-rose-50 text-status-danger border border-rose-200">
                            ${dashboard.unassignedCoursesCount} unassigned
                        </span>
                    </div>

                    <div class="divide-y divide-border-default mt-2">
                        <c:choose>
                            <c:when test="${empty dashboard.unassignedCourses}">
                                <div class="py-8 text-center text-text-secondary text-xs">
                                    <i class="fa-regular fa-circle-check text-2xl text-status-success mb-2 block"></i>
                                    All active courses currently have an assigned domain expert.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="u" items="${dashboard.unassignedCourses}">
                                    <div class="py-3 flex items-center justify-between gap-3">
                                        <div class="min-w-0">
                                            <div class="flex items-center gap-2">
                                                <span class="text-xs font-mono font-bold px-1.5 py-0.5 rounded bg-slate-100 text-slate-700">
                                                    #${fn:substring(u.id.toString(), 0, 8)}
                                                </span>
                                                <h4 class="text-xs sm:text-sm font-bold text-text-primary truncate">${u.title}</h4>
                                            </div>
                                            <p class="text-xs text-text-secondary mt-0.5">
                                                Category: <strong class="text-text-primary font-medium">${not empty u.categoryName ? u.categoryName : 'Uncategorized'}</strong> • 
                                                <span>Status: ${u.status}</span>
                                            </p>
                                        </div>
                                        <button type="button"
                                                onclick="openAssignExpertModal('${u.id}', '${fn:escapeXml(u.title)}', '')"
                                                class="shrink-0 px-3 py-1.5 rounded-xl text-xs font-bold border border-rose-300 text-status-danger hover:bg-rose-50 transition cursor-pointer">
                                            Assign Expert
                                        </button>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>

            <!-- Course Catalog Management Table -->
            <div class="bg-surface-card border border-border-default rounded-2xl shadow-xs overflow-hidden">
                <div class="p-5 border-b border-border-default flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <div>
                        <h2 class="text-base sm:text-lg font-bold text-text-primary">Course Catalog Management</h2>
                        <p class="text-xs text-text-secondary">Browse courses, toggle instant publishing visibility, and update domain experts</p>
                    </div>
                    <div class="flex items-center gap-2 text-xs">
                        <span class="text-text-secondary">Catalog preview:</span>
                        <strong class="text-text-primary">${fn:length(dashboard.courses)} of ${dashboard.totalCatalogCourses} courses</strong>
                        <a href="${pageContext.request.contextPath}/admin/courses" class="ml-2 font-bold text-brand-700 hover:text-brand-800 underline">View Full Table →</a>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs sm:text-sm text-text-secondary">
                        <thead class="bg-slate-50 text-slate-500 uppercase text-xs font-bold tracking-wider border-b border-border-default select-none">
                            <tr>
                                <th class="px-5 py-3.5">Course Title & Code</th>
                                <th class="px-5 py-3.5">Category</th>
                                <th class="px-5 py-3.5">Assigned Expert</th>
                                <th class="px-5 py-3.5">Total Enrollments</th>
                                <th class="px-5 py-3.5">Publish Status</th>
                                <th class="px-5 py-3.5 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-border-default text-text-primary">
                            <c:choose>
                                <c:when test="${empty dashboard.courses}">
                                    <tr>
                                        <td colspan="6" class="px-5 py-12 text-center text-text-secondary">
                                            <i class="fa-regular fa-folder-open text-3xl mb-2 text-slate-300 block"></i>
                                            <p class="font-semibold text-text-primary">No courses match the criteria</p>
                                            <p class="text-xs mt-1">Try adjusting your search keyword or category filter.</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="c" items="${dashboard.courses}">
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <!-- Title & Code -->
                                            <td class="px-5 py-3.5">
                                                <div class="font-bold text-text-primary line-clamp-1">${c.title}</div>
                                                <div class="text-xs text-text-secondary font-mono mt-0.5">#${fn:substring(c.id.toString(), 0, 8)}</div>
                                            </td>

                                            <!-- Category -->
                                            <td class="px-5 py-3.5 whitespace-nowrap">
                                                <span class="px-2.5 py-0.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                                                    ${not empty c.categoryName ? c.categoryName : 'General'}
                                                </span>
                                            </td>

                                            <!-- Assigned Expert -->
                                            <td class="px-5 py-3.5 whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${not empty c.expertName}">
                                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold bg-brand-50 text-brand-700 border border-brand-100">
                                                            <i class="fa-solid fa-user-tie text-xs"></i>
                                                            ${c.expertName}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-bold bg-rose-50 text-status-danger border border-rose-200">
                                                            <i class="fa-solid fa-triangle-exclamation text-xs"></i>
                                                            Unassigned
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Total Enrollments -->
                                            <td class="px-5 py-3.5 whitespace-nowrap font-semibold">
                                                <fmt:formatNumber value="${c.enrolledCount}" type="number"/> 
                                                <span class="text-xs text-text-secondary font-normal">learners</span>
                                            </td>

                                            <!-- Publish Status (Toggle Switch) -->
                                            <td class="px-5 py-3.5 whitespace-nowrap">
                                                <form action="${pageContext.request.contextPath}/manager/dashboard" method="post" class="inline">
                                                    <input type="hidden" name="action" value="toggle-status">
                                                    <input type="hidden" name="courseId" value="${c.id}">
                                                    <input type="hidden" name="period" value="${dashboard.dateRange}">
                                                    <input type="hidden" name="status" value="${c.status eq 'published' ? 'draft' : 'published'}">
                                                    
                                                    <button type="submit" 
                                                            title="Click to toggle between Published and Draft"
                                                            class="inline-flex items-center gap-2 cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 rounded-full">
                                                        <span class="relative inline-flex h-5 w-9 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out ${c.status eq 'published' ? 'bg-brand-700' : 'bg-slate-300'}">
                                                            <span class="pointer-events-none inline-block h-4 w-4 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${c.status eq 'published' ? 'translate-x-4' : 'translate-x-0'}"></span>
                                                        </span>
                                                        <span class="text-xs font-bold ${c.status eq 'published' ? 'text-brand-700' : 'text-text-secondary'}">
                                                            ${c.status eq 'published' ? 'Published' : 'Draft'}
                                                        </span>
                                                    </button>
                                                </form>
                                            </td>

                                            <!-- Actions -->
                                            <td class="px-5 py-3.5 whitespace-nowrap text-right space-x-2">
                                                <button type="button"
                                                        onclick="openAssignExpertModal('${c.id}', '${fn:escapeXml(c.title)}', '${c.expertId}')"
                                                        class="text-xs font-bold text-brand-700 hover:text-brand-800 hover:underline cursor-pointer">
                                                    Assign Expert
                                                </button>
                                                <span class="text-border-default">|</span>
                                                <a href="${pageContext.request.contextPath}/admin/course-detail?id=${c.id}"
                                                   class="text-xs font-bold text-indigo-600 hover:text-indigo-800 hover:underline cursor-pointer">
                                                    Edit Info
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Student Enrollments Log Feed -->
            <div class="bg-surface-card border border-border-default rounded-2xl p-5 shadow-xs">
                <div class="flex items-center justify-between pb-3 border-b border-border-default">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-bolt text-brand-700 text-sm"></i>
                        <h3 class="font-bold text-sm sm:text-base text-text-primary">Student Enrollments Log</h3>
                    </div>
                    <c:if test="${not empty dashboard.recentEnrollments}">
                        <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-brand-50 text-brand-700 border border-brand-100">
                            ${fn:length(dashboard.recentEnrollments)} records
                        </span>
                    </c:if>
                </div>

                <div class="custom-scrollbar overflow-y-auto max-h-[340px] pr-2 divide-y divide-border-default mt-2">
                    <c:choose>
                        <c:when test="${empty dashboard.recentEnrollments}">
                            <div class="py-6 text-center text-text-secondary text-xs">
                                No enrollment logs found for this period.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="reg" items="${dashboard.recentEnrollments}">
                                <div class="py-3 flex items-center justify-between gap-3 text-xs sm:text-sm hover:bg-slate-50/70 px-2 rounded-xl transition">
                                    <div class="flex items-center gap-3 min-w-0">
                                        <div class="w-8 h-8 rounded-full bg-brand-50 text-brand-700 font-bold flex items-center justify-center text-xs shrink-0 uppercase">
                                            ${fn:substring(reg.userName, 0, 1)}
                                        </div>
                                        <div class="min-w-0">
                                            <p class="font-semibold text-text-primary truncate">
                                                ${reg.userName} 
                                                <span class="text-text-secondary font-normal">registered for</span> 
                                                <strong class="text-text-primary">${reg.courseTitle}</strong>
                                            </p>
                                            <p class="text-xs text-text-secondary mt-0.5">
                                                Payment: <strong class="text-text-primary font-medium">${reg.paymentStatus}</strong> 
                                                • <fmt:formatNumber value="${reg.amount}" type="number" maxFractionDigits="0"/> ₫
                                                <c:if test="${not empty reg.transactionId}"> • Trx: ${reg.transactionId}</c:if>
                                            </p>
                                        </div>
                                    </div>
                                    <span class="text-xs text-text-secondary shrink-0 font-medium">
                                        <fmt:formatDate value="${reg.enrolledAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </main>

<!-- ========================================================================= -->
<!-- Modal: Assign Domain Expert                                               -->
<!-- ========================================================================= -->
<div id="assignExpertModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs hidden">
    <div class="bg-surface-card rounded-2xl border border-border-default shadow-2xl max-w-md w-full p-6 animate-scale-up">
        <div class="flex items-center justify-between pb-3 border-b border-border-default">
            <h3 class="font-bold text-base text-text-primary">Assign Domain Expert</h3>
            <button type="button" onclick="closeAssignExpertModal()" class="text-text-secondary hover:text-text-primary cursor-pointer">
                <i class="fa-solid fa-xmark text-sm"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/manager/dashboard" method="post" class="mt-4 space-y-4">
            <input type="hidden" name="action" value="assign-expert">
            <input type="hidden" id="assignModalCourseId" name="courseId" value="">
            <input type="hidden" name="period" value="${dashboard.dateRange}">

            <div>
                <label class="block text-xs font-bold uppercase text-text-secondary mb-1">Target Course</label>
                <div id="assignModalCourseTitle" class="text-xs sm:text-sm font-bold text-text-primary bg-surface p-3 rounded-xl border border-border-default break-words">
                    Course Title
                </div>
            </div>

            <div>
                <label for="assignExpertSelect" class="block text-xs font-bold uppercase text-text-secondary mb-1">Select Domain Expert</label>
                <select id="assignExpertSelect" name="expertId" class="w-full px-3 py-2 text-xs sm:text-sm bg-surface border border-border-default rounded-xl text-text-primary focus:ring-2 focus:ring-brand-700 cursor-pointer">
                    <option value="">-- No Expert Assigned (Unassign) --</option>
                    <c:forEach var="inst" items="${dashboard.instructors}">
                        <option value="${inst.id}">${inst.username} (${inst.email})</option>
                    </c:forEach>
                </select>
            </div>

            <p class="text-xs text-text-secondary leading-relaxed">
                Allocating a domain expert authorizes them to author modules, submit lesson curricula for review, and evaluate student quizzes.
            </p>

            <div class="mt-6 flex items-center justify-end gap-3 pt-3 border-t border-border-default">
                <button type="button" onclick="closeAssignExpertModal()" class="px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold border border-border-default bg-surface hover:bg-slate-100 text-text-secondary cursor-pointer">
                    Cancel
                </button>
                <button type="submit" class="px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold bg-brand-700 hover:bg-brand-800 text-white transition shadow-xs cursor-pointer">
                    Save Assignment
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAssignExpertModal(courseId, title, expertId) {
        document.getElementById('assignModalCourseId').value = courseId;
        document.getElementById('assignModalCourseTitle').innerText = title;
        const select = document.getElementById('assignExpertSelect');
        if (expertId) {
            select.value = expertId;
        } else {
            select.selectedIndex = 0;
        }
        document.getElementById('assignExpertModal').classList.remove('hidden');
    }

    function closeAssignExpertModal() {
        document.getElementById('assignExpertModal').classList.add('hidden');
    }

    document.getElementById('assignExpertModal').addEventListener('click', function(e) {
        if (e.target === this) closeAssignExpertModal();
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
