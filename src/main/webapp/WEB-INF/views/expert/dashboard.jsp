<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="dashboard" />
    </jsp:include>

    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-7xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">
    <div class="mb-6">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl sm:text-3xl font-bold text-text-primary tracking-tight">Assigned Courses</h1>
                <p class="text-text-secondary text-sm mt-1">Danh sách các khóa học được phân công xây dựng nội dung bài giảng & đề thi</p>
            </div>
        </div>
    </div>
    <div class="bg-surface-card rounded-xl border border-border-default shadow-sm overflow-hidden">
            <div class="p-4 sm:p-6 border-b border-border-default flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                <div class="min-w-0">
                    <h2 class="font-bold text-text-primary text-lg">
                        Danh Sách Khóa Học (Assigned Courses)
                    </h2>
                    <dl class="mt-2 flex flex-wrap gap-x-6 gap-y-2 text-sm">
                        <div class="flex items-center gap-2">
                            <dt class="text-text-secondary">Published</dt>
                            <dd class="font-bold text-status-success">
                                ${empty publishedCourses ? 0 : publishedCourses}
                            </dd>
                        </div>
                        <div class="flex items-center gap-2">
                            <dt class="text-text-secondary">Draft</dt>
                            <dd class="font-bold text-status-warning">
                                ${empty draftCourses ? 0 : draftCourses}
                            </dd>
                        </div>
                        <div class="flex items-center gap-2">
                            <dt class="text-text-secondary">Archived</dt>
                            <dd class="font-bold text-text-secondary">
                                ${empty archivedCourses ? 0 : archivedCourses}
                            </dd>
                        </div>
                    </dl>
                </div>
                <form method="GET" action="${pageContext.request.contextPath}/expert/dashboard" class="relative w-full lg:max-w-xs">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-secondary">
                        <i class="fa-solid fa-magnifying-glass text-sm"></i>
                    </div>
                    <input type="text"
                           id="courseSearchInput"
                           name="search"
                           value="${fn:escapeXml(search)}"
                           aria-label="Search courses"
                           placeholder="Search courses..."
                           class="w-full pl-10 pr-4 py-2 bg-surface border border-border-default rounded-lg text-sm placeholder-text-secondary focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 transition-all">
                </form>
            </div>
        <div class="overflow-x-auto">
            <table class="w-full min-w-max text-left text-sm text-text-secondary" id="coursesTable">
                <thead class="bg-surface text-slate-700 uppercase text-xs font-bold border-b border-border-default">
                    <tr>
                        <th class="px-6 py-4 w-12 text-center">#</th>
                        <th class="px-6 py-4">Tên khóa học (Course Title)</th>
                        <th class="px-6 py-4 whitespace-nowrap">Danh mục</th>
                        <th class="px-6 py-4 text-center whitespace-nowrap">Modules</th>
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
                                                    ● ${c.status}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-6 py-4 text-right whitespace-nowrap">
                                        <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${c.id}"
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
                                <td colspan="6" class="px-6 py-12 text-center text-text-secondary">
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
                        <c:url var="previousPageUrl" value="/expert/dashboard">
                            <c:param name="page" value="${currentPage - 1}" />
                            <c:param name="search" value="${search}" />
                        </c:url>
                        <a href="${fn:escapeXml(previousPageUrl)}" class="px-3 py-1.5 bg-surface-card border border-border-default text-text-secondary text-xs font-bold rounded-lg hover:bg-surface transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            <i class="fa-solid fa-chevron-left mr-1"></i> Trước
                        </a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:url var="pageUrl" value="/expert/dashboard">
                            <c:param name="page" value="${p}" />
                            <c:param name="search" value="${search}" />
                        </c:url>
                        <a href="${fn:escapeXml(pageUrl)}" class="px-3 py-1.5 text-xs font-bold rounded-lg transition ${currentPage eq p ? 'bg-brand-700 text-white' : 'bg-surface-card border border-border-default text-slate-700 hover:bg-surface'} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            ${p}
                        </a>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <c:url var="nextPageUrl" value="/expert/dashboard">
                            <c:param name="page" value="${currentPage + 1}" />
                            <c:param name="search" value="${search}" />
                        </c:url>
                        <a href="${fn:escapeXml(nextPageUrl)}" class="px-3 py-1.5 bg-surface-card border border-border-default text-text-secondary text-xs font-bold rounded-lg hover:bg-surface transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                            Sau <i class="fa-solid fa-chevron-right ml-1"></i>
                        </a>
                    </c:if>
                </div>
            </div>
        </c:if>
    </div>
        </main>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
