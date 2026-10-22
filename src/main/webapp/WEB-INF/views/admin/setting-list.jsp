<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="min-h-[calc(100vh-64px)] bg-[#f8fafc]">
    <main class="flex-grow p-6 sm:p-8 lg:p-10 max-w-7xl w-full mx-auto">

            <!-- Flash Alert -->
            <c:if test="${not empty successMessage}">
                <div class="mb-6 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm flex items-center justify-between shadow-sm">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                        <span class="font-medium">${successMessage}</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-800"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                        <span class="font-medium"><c:out value="${errorMessage}" /></span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>
            <c:if test="${param.error eq 'missing_fields'}">
                <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                    <div class="flex items-center space-x-2.5">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                        <span class="font-medium">Vui lòng nhập đầy đủ các trường bắt buộc (Type, Code, Name)!</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>

            <!-- Page Header -->
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">System Settings</h1>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/setting-detail" class="inline-flex items-center gap-2 px-5 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-[8px] text-sm transition shadow-sm cursor-pointer">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span> Add New Setting</span>
                    </a>
                </div>
            </div>

            <!-- Filter Bar -->
            <div class="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm mb-6 flex flex-col md:flex-row items-center gap-4">
                <form id="filterForm" action="${pageContext.request.contextPath}/admin/settings" method="get" class="w-full flex flex-col md:flex-row items-center gap-4">
                    <input type="hidden" name="sortBy" value="${sortBy}">
                    <input type="hidden" name="sortOrder" value="${sortOrder}">

                    <!-- Search Input -->
                    <div class="relative w-full md:flex-1">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
                        <input type="text"
                               name="search"
                               value="${search}"
                               placeholder="Search settings by name or description..."
                               class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition-colors text-slate-800 font-medium placeholder-slate-400">
                    </div>

                    <!-- Setting Type Filter -->
                    <div class="relative w-full md:w-56" title="Setting Type">
                        <select name="type"
                                class="w-full pl-4 pr-10 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition-colors text-slate-700 font-medium appearance-none cursor-pointer">
                            <option value="">All Setting Types</option>
                            <c:forEach var="t" items="${types}">
                                <option value="${t}" ${selectedType eq t ? 'selected' : ''}>${t}</option>
                            </c:forEach>
                        </select>
                        <i class="fa-solid fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                    </div>

                    <!-- Setting Status Filter -->
                    <div class="relative w-full md:w-48" title="Setting Status">
                        <select name="status"
                                class="w-full pl-4 pr-10 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition-colors text-slate-700 font-medium appearance-none cursor-pointer">
                            <option value="">All Statuses</option>
                            <option value="active" ${selectedStatus eq 'active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${selectedStatus eq 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                        <i class="fa-solid fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                    </div>

                    <!-- Filter Button -->
                    <div class="w-full md:w-auto">
                        <button type="submit" class="w-full px-5 py-2.5 bg-slate-800 hover:bg-slate-900 text-white rounded-lg text-sm font-bold transition flex justify-center items-center gap-2">
                            <i class="fa-solid fa-filter text-xs"></i> Filter
                        </button>
                    </div>
                </form>
            </div>

            <!-- Settings Table -->
            <div class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden mb-6">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm whitespace-nowrap">
                        <thead class="bg-white border-b border-slate-100">
                            <tr>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider w-16">#</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider">TÊN CẤU HÌNH (NAME)</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider">LOẠI (TYPE)</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider">MÔ TẢ</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider text-center">THỨ TỰ</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider">TRẠNG THÁI</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider text-right">ACTION</th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-slate-100">
                            <c:choose>
                                <c:when test="${empty settings}">
                                    <tr>
                                        <td colspan="7" class="px-6 py-16 text-center text-slate-400">
                                            <div class="flex flex-col items-center justify-center">
                                                <i class="fa-regular fa-folder-open text-4xl mb-3 text-slate-300"></i>
                                                <p class="text-base font-semibold text-slate-700">No settings found</p>
                                                <p class="text-xs text-slate-400 mt-1">Try adjusting your search keyword or type filter.</p>
                                                <a href="${pageContext.request.contextPath}/admin/settings" class="mt-4 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition">
                                                    Reset all filters
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>

                                <c:otherwise>
                                    <c:forEach var="s" items="${settings}" varStatus="loop">
                                        <tr class="hover:bg-slate-50/50 transition group">
                                            <td class="px-6 py-5 text-slate-500 font-medium">${loop.index + 1}</td>
                                            
                                            <!-- Name and Code -->
                                            <td class="px-6 py-5">
                                                <div class="font-bold text-[#111827] text-[15px]">${s.name}</div>
                                                <div class="text-xs text-slate-400 mt-0.5">Code: ${s.code}</div>
                                            </td>

                                            <!-- Type -->
                                            <td class="px-6 py-5">
                                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded text-xs font-bold bg-[#e8f5e9] text-[#2e7d32]">
                                                    ${s.type}
                                                </span>
                                            </td>

                                            <!-- Description -->
                                            <td class="px-6 py-5 text-slate-500 font-medium text-[13px] truncate max-w-[320px]" title="${fn:escapeXml(s.description)}">
                                                <c:choose>
                                                    <c:when test="${not empty s.description}">
                                                        <c:out value="${s.description}" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-slate-300 italic">Chưa có mô tả</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Sort Order -->
                                            <td class="px-6 py-5 text-center font-semibold text-slate-600">
                                                ${s.sortOrder}
                                            </td>

                                            <!-- Status -->
                                            <td class="px-6 py-5">
                                                <c:choose>
                                                    <c:when test="${s.status}">
                                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-[#e8f5e9] text-[#2e7d32]">
                                                            <span class="w-1.5 h-1.5 rounded-full bg-[#2e7d32]"></span> Active
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-slate-100 text-slate-500">
                                                            <span class="w-1.5 h-1.5 rounded-full bg-slate-400"></span> Inactive
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Actions -->
                                            <td class="px-6 py-5 text-right space-x-2">
                                                <a href="${pageContext.request.contextPath}/admin/setting-detail?id=${s.id}"
                                                   class="px-4 py-2 bg-[#047857] hover:bg-[#065f46] text-white rounded-[8px] text-xs font-bold transition inline-flex items-center gap-2 shadow-sm" title="Manage Setting">
                                                    <i class="fa-solid fa-pen-to-square"></i> Manage
                                                </a>

                                                <c:set var="isRoleSetting" value="${s.type eq 'role'}" />
                                                <c:choose>
                                                    <c:when test="${isRoleSetting}">
                                                        <button type="button"
                                                                disabled
                                                                class="px-3 py-2 bg-slate-100 text-slate-400 rounded-[8px] text-xs font-bold inline-flex items-center justify-center cursor-not-allowed shadow-sm select-none relative group"
                                                                title="Vai trò hệ thống - Luôn Active, không thể tắt">
                                                            <span class="relative inline-flex items-center justify-center w-3.5 h-3.5">
                                                                <i class="fa-solid fa-power-off text-slate-400 text-xs"></i>
                                                                <!-- Đường gạch chéo đỏ xuyên qua icon -->
                                                                <span class="absolute w-[140%] h-[1.5px] bg-rose-500 -rotate-45 transform origin-center pointer-events-none"></span>
                                                            </span>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="${pageContext.request.contextPath}/admin/setting-status" method="post" class="inline">
                                                            <input type="hidden" name="id" value="${s.id}">
                                                            <input type="hidden" name="status" value="${!s.status}">
                                                            <c:choose>
                                                                <c:when test="${s.status}">
                                                                    <button type="submit" 
                                                                            data-confirm="Bạn có chắc chắn muốn TẮT cài đặt này không?"
                                                                            data-confirm-title="Tắt Cài đặt"
                                                                            data-confirm-btn="Tắt cài đặt"
                                                                            data-confirm-type="warning"
                                                                            class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-[8px] text-xs font-bold transition inline-flex items-center shadow-sm" title="Deactivate">
                                                                        <i class="fa-solid fa-power-off"></i>
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <button type="submit" 
                                                                            data-confirm="Bạn có muốn BẬT cài đặt này không?"
                                                                            data-confirm-title="Bật Cài đặt"
                                                                            data-confirm-btn="Bật cài đặt"
                                                                            data-confirm-type="info"
                                                                            class="px-3 py-2 bg-[#e8f5e9] hover:bg-[#c8e6c9] text-[#2e7d32] rounded-[8px] text-xs font-bold transition inline-flex items-center shadow-sm" title="Activate">
                                                                        <i class="fa-solid fa-power-off"></i>
                                                                    </button>
                                                                </c:otherwise>
                                                            </c:choose>
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
                        <strong class="text-slate-800 font-semibold">${totalSettings gt 0 ? (currentPage - 1) * pageSize + 1 : 0}</strong>
                        to 
                        <strong class="text-slate-800 font-semibold">${currentPage * pageSize lt totalSettings ? currentPage * pageSize : totalSettings}</strong>
                        of 
                        <strong class="text-slate-800 font-semibold">${totalSettings}</strong> settings
                    </div>

                    <c:if test="${totalPages gt 1}">
                        <div class="flex items-center space-x-1">
                            <c:if test="${currentPage gt 1}">
                                <a href="?search=${search}&type=${selectedType}&status=${selectedStatus}&sortBy=${sortBy}&sortOrder=${sortOrder}&page=${currentPage - 1}"
                                   class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-100 font-medium text-slate-700 transition">
                                    Previous
                                </a>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:choose>
                                    <c:when test="${p eq currentPage}">
                                        <span class="px-3 py-1.5 rounded-lg bg-[#047857] text-white font-bold">${p}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?search=${search}&type=${selectedType}&status=${selectedStatus}&sortBy=${sortBy}&sortOrder=${sortOrder}&page=${p}"
                                           class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-100 text-slate-700 font-medium transition">
                                            ${p}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <c:if test="${currentPage lt totalPages}">
                                <a href="?search=${search}&type=${selectedType}&status=${selectedStatus}&sortBy=${sortBy}&sortOrder=${sortOrder}&page=${currentPage + 1}"
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

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
