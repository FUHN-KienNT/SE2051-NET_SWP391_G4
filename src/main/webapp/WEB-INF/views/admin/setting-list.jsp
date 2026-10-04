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

            <!-- Navigation Links -->
            <nav class="space-y-1.5 text-sm font-medium">
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-gauge-high w-5 text-slate-400"></i>
                    <span>Dashboard</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/courses"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-book-open w-5 text-slate-400"></i>
                    <span>Course Management</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/users"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-all">
                    <i class="fa-solid fa-users w-5 text-slate-400"></i>
                    <span>User Management</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/settings"
                   class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-indigo-600 text-white font-bold shadow-md shadow-indigo-600/30 transition-all">
                    <i class="fa-solid fa-gear w-5 text-white"></i>
                    <span>System Settings</span>
                </a>
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
                    <button onclick="openCreateModal()" class="inline-flex items-center gap-2 px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white font-bold rounded-xl text-sm transition shadow-sm shadow-indigo-600/20 cursor-pointer">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>+ Add New Setting</span>
                    </button>
                </div>
            </div>

            <!-- Filter Bar (SRS 2.2.1) -->
            <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm mb-6">
                <form id="filterForm" action="${pageContext.request.contextPath}/admin/settings" method="get" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-12 gap-3.5 items-center">
                    <input type="hidden" name="sortBy" value="${sortBy}">
                    <input type="hidden" name="sortOrder" value="${sortOrder}">

                    <!-- Search Input -->
                    <div class="lg:col-span-5 relative">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                        <input type="text"
                               name="search"
                               value="${search}"
                               placeholder="Search setting name, code, description..."
                               title="Search Settings: Enter keyword to search master data"
                               class="w-full pl-9 pr-3.5 py-2.5 bg-slate-50/50 hover:bg-white focus:bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all">
                    </div>

                    <!-- Type Filter -->
                    <div class="lg:col-span-3">
                        <select name="type"
                                title="Setting Type: Filter by category group"
                                class="w-full px-3.5 py-2.5 bg-slate-50/50 hover:bg-white focus:bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all cursor-pointer">
                            <option value="">All Types</option>
                            <c:forEach var="t" items="${types}">
                                <option value="${t}" ${selectedType eq t ? 'selected' : ''}>${t}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Status Filter -->
                    <div class="lg:col-span-2">
                        <select name="status"
                                title="Setting Status: Filter by active/inactive"
                                class="w-full px-3.5 py-2.5 bg-slate-50/50 hover:bg-white focus:bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all cursor-pointer">
                            <option value="">All Statuses</option>
                            <option value="active" ${selectedStatus eq 'active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${selectedStatus eq 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>

                    <!-- Filter Button -->
                    <div class="lg:col-span-2 flex space-x-2">
                        <button type="submit"
                                class="w-full py-2.5 bg-slate-800 hover:bg-slate-900 text-white rounded-xl font-bold text-sm transition shadow-sm text-center">
                            Filter
                        </button>
                    </div>
                </form>
            </div>

            <!-- Settings Table -->
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-slate-600">
                        <thead class="bg-slate-50/80 text-slate-500 uppercase text-[11px] font-bold tracking-wider border-b border-slate-200 select-none">
                            <tr>
                                <th class="px-6 py-4">TYPE</th>
                                <th class="px-6 py-4">CODE</th>
                                <th class="px-6 py-4">NAME &amp; DESCRIPTION</th>
                                <th class="px-6 py-4 text-center">ORDER</th>
                                <th class="px-6 py-4">STATUS</th>
                                <th class="px-6 py-4 text-right">ACTIONS</th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-slate-100">
                            <c:choose>
                                <c:when test="${empty settings}">
                                    <tr>
                                        <td colspan="6" class="px-6 py-16 text-center text-slate-400">
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
                                    <c:forEach var="s" items="${settings}">
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <!-- Type -->
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <span class="px-2.5 py-1 rounded-lg text-xs font-bold bg-slate-100 text-slate-700 border border-slate-200 uppercase">
                                                    ${s.type}
                                                </span>
                                            </td>

                                            <!-- Code -->
                                            <td class="px-6 py-4 whitespace-nowrap font-mono text-xs text-indigo-600 font-bold">
                                                ${s.code}
                                            </td>

                                            <!-- Name & Description -->
                                            <td class="px-6 py-4">
                                                <div class="font-bold text-slate-900">${s.name}</div>
                                                <c:if test="${not empty s.description}">
                                                    <div class="text-xs text-slate-400 mt-0.5 line-clamp-1">${s.description}</div>
                                                </c:if>
                                            </td>

                                            <!-- Sort Order -->
                                            <td class="px-6 py-4 whitespace-nowrap text-center font-bold text-slate-700">
                                                ${s.sortOrder}
                                            </td>

                                            <!-- Status -->
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${s.status}">
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                            <i class="fa-solid fa-circle text-[6px]"></i> Active
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-slate-100 text-slate-500 border border-slate-200">
                                                            <i class="fa-solid fa-circle text-[6px]"></i> Inactive
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Actions: Edit / Toggle Status -->
                                            <td class="px-6 py-4 whitespace-nowrap text-right space-x-2">
                                                <button type="button"
                                                        onclick="openEditModal('${s.id}')"
                                                        class="text-xs font-bold text-indigo-600 hover:text-indigo-800 hover:underline cursor-pointer">
                                                    Edit
                                                </button>

                                                <form action="${pageContext.request.contextPath}/admin/setting-status" method="post" class="inline" onsubmit="return confirm('Bạn có chắc chắn muốn thay đổi trạng thái cài đặt này?');">
                                                    <input type="hidden" name="id" value="${s.id}">
                                                    <input type="hidden" name="status" value="${!s.status}">
                                                    <c:choose>
                                                        <c:when test="${s.status}">
                                                            <button type="submit" class="text-xs font-bold text-amber-600 hover:text-amber-800 hover:underline cursor-pointer ml-2">
                                                                Deactivate
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="submit" class="text-xs font-bold text-emerald-600 hover:text-emerald-800 hover:underline cursor-pointer ml-2">
                                                                Activate
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
                                        <span class="px-3 py-1.5 rounded-lg bg-indigo-600 text-white font-bold">${p}</span>
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
                        class="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white font-bold rounded-xl text-sm shadow-md shadow-indigo-600/20 transition cursor-pointer">
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
