<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="min-h-[calc(100vh-64px)] flex flex-col md:flex-row bg-[#f8fafc]">
    

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
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
                    <p class="text-slate-500 text-sm mt-1">Manage platform configuration, roles, categories, and payment options (SRS 2.2 / 2.2.1)</p>
                </div>
                <div>
                    <button onclick="openCreateModal()" class="inline-flex items-center gap-2 px-5 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-[8px] text-sm transition shadow-sm cursor-pointer">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>+ Add New Setting</span>
                    </button>
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
                               placeholder="Search settings by name or value..."
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
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider sortable-header select-none group">
                                    <div class="flex items-center gap-1.5">TÊN CẤU HÌNH (NAME) <i class="fa-solid fa-sort text-[10px] text-slate-300"></i></div>
                                </th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider sortable-header select-none group">
                                    <div class="flex items-center gap-1.5">LOẠI (TYPE) <i class="fa-solid fa-sort text-[10px] text-slate-300"></i></div>
                                </th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider">GIÁ TRỊ (VALUE) / MÔ TẢ</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider text-center">THỨ TỰ</th>
                                <th class="px-6 py-4 font-bold text-[11px] text-slate-600 uppercase tracking-wider sortable-header select-none group">
                                    <div class="flex items-center gap-1.5">TRẠNG THÁI <i class="fa-solid fa-sort text-[10px] text-slate-300"></i></div>
                                </th>
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

                                            <!-- Value/Description -->
                                            <td class="px-6 py-5 text-slate-500 font-medium text-[13px] truncate max-w-[200px]" title="${s.value} ${s.description}">
                                                ${not empty s.value ? s.value : s.description}
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
                                                <button type="button"
                                                        onclick="openEditModal('${s.id}')"
                                                        class="px-4 py-2 bg-[#047857] hover:bg-[#065f46] text-white rounded-[8px] text-xs font-bold transition inline-flex items-center gap-2 shadow-sm" title="Manage Setting">
                                                    <i class="fa-solid fa-pen-to-square"></i> Manage
                                                </button>

                                                <form action="${pageContext.request.contextPath}/admin/setting-status" method="post" class="inline" onsubmit="return confirm('Bạn có chắc chắn muốn thay đổi trạng thái cài đặt này?');">
                                                    <input type="hidden" name="id" value="${s.id}">
                                                    <input type="hidden" name="status" value="${!s.status}">
                                                    <c:choose>
                                                        <c:when test="${s.status}">
                                                            <button type="submit" class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-[8px] text-xs font-bold transition inline-flex items-center shadow-sm" title="Deactivate">
                                                                <i class="fa-solid fa-power-off"></i>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="submit" class="px-3 py-2 bg-[#e8f5e9] hover:bg-[#c8e6c9] text-[#2e7d32] rounded-[8px] text-xs font-bold transition inline-flex items-center shadow-sm" title="Activate">
                                                                <i class="fa-solid fa-power-off"></i>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

<!-- Pagination Footer --><!-- Pagination Footer -->
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
</div>

<!-- ========================================================================= -->
<!-- Modal: Create / Edit Setting Form                                         -->
<!-- ========================================================================= -->
<div id="settingModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs hidden transition-opacity">
    <div class="bg-white rounded-3xl border border-slate-200 shadow-2xl max-w-lg w-full max-h-[92vh] overflow-y-auto transform transition-transform">
        <div class="flex items-center justify-between px-7 py-5 border-b border-slate-100">
            <div>
                <h3 id="modalTitle" class="text-xl font-black text-slate-900">Add New Setting</h3>
                <p id="modalSubtitle" class="text-xs text-slate-400 mt-0.5">Configure system master data</p>
            </div>
            <button type="button" onclick="closeSettingModal()" class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-400 hover:text-slate-700 flex items-center justify-center transition-colors cursor-pointer">
                <i class="fa-solid fa-xmark text-sm"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/admin/settings" method="post" class="p-7 space-y-4">
            <input type="hidden" name="action" value="save">
            <input type="hidden" id="settingId" name="id" value="">

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                    Setting Type <span class="text-rose-500">*</span>
                </label>
                <input type="text"
                       id="settingTypeInput"
                       name="type"
                       required
                       placeholder="e.g. role, category, payment_method"
                       class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                    Setting Code <span class="text-rose-500">*</span>
                </label>
                <input type="text"
                       id="settingCodeInput"
                       name="code"
                       required
                       placeholder="e.g. ROLE_ASSISTANT, web_security"
                       class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition font-mono">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                    Setting Name <span class="text-rose-500">*</span>
                </label>
                <input type="text"
                       id="settingNameInput"
                       name="name"
                       required
                       placeholder="e.g. Teaching Assistant"
                       class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition">
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                        Display Order
                    </label>
                    <input type="number"
                           id="settingOrderInput"
                           name="sortOrder"
                           value="1"
                           min="0"
                           class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition">
                </div>

                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                        Status
                    </label>
                    <select id="settingStatusInput"
                            name="status"
                            class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition cursor-pointer">
                        <option value="true">Active</option>
                        <option value="false">Inactive</option>
                    </select>
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
                    Description
                </label>
                <textarea id="settingDescriptionInput"
                          name="description"
                          rows="3"
                          placeholder="Optional notes or description..."
                          class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition"></textarea>
            </div>

            <div class="pt-4 border-t border-slate-100 flex items-center justify-end space-x-3">
                <button type="button"
                        onclick="closeSettingModal()"
                        class="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl text-sm transition cursor-pointer">
                    Cancel
                </button>
                <button type="submit"
                        class="px-6 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-[8px] text-sm transition shadow-sm transition cursor-pointer">
                    Save Setting
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    const modal = document.getElementById('settingModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalSubtitle = document.getElementById('modalSubtitle');
    const settingId = document.getElementById('settingId');
    const settingTypeInput = document.getElementById('settingTypeInput');
    const settingCodeInput = document.getElementById('settingCodeInput');
    const settingNameInput = document.getElementById('settingNameInput');
    const settingOrderInput = document.getElementById('settingOrderInput');
    const settingStatusInput = document.getElementById('settingStatusInput');
    const settingDescriptionInput = document.getElementById('settingDescriptionInput');

    function openCreateModal() {
        modalTitle.innerText = "Add New Setting";
        modalSubtitle.innerText = "Add a new system configuration item";
        settingId.value = "";
        settingTypeInput.value = "";
        settingCodeInput.value = "";
        settingNameInput.value = "";
        settingOrderInput.value = "1";
        settingStatusInput.value = "true";
        settingDescriptionInput.value = "";
        modal.classList.remove('hidden');
    }

    function openEditModal(id) {
        fetch('${pageContext.request.contextPath}/admin/settings?action=get-json&id=' + encodeURIComponent(id))
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    alert('Could not find setting item.');
                    return;
                }
                modalTitle.innerText = "Edit Setting";
                modalSubtitle.innerText = "Update configuration: " + data.name;
                settingId.value = data.id || "";
                settingTypeInput.value = data.type || "";
                settingCodeInput.value = data.code || "";
                settingNameInput.value = data.name || "";
                settingOrderInput.value = data.sortOrder != null ? data.sortOrder : "1";
                settingStatusInput.value = data.status ? "true" : "false";
                settingDescriptionInput.value = data.description || "";
                modal.classList.remove('hidden');
            })
            .catch(err => {
                console.error(err);
                alert('Error loading setting data.');
            });
    }

    function closeSettingModal() {
        modal.classList.add('hidden');
    }

    modal.addEventListener('click', function(e) {
        if (e.target === modal) closeSettingModal();
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
