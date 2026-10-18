<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<c:set var="isEdit" value="${not empty setting and not empty setting.id}" />
<c:set var="isActiveStatus" value="${empty setting or setting.status}" />

<div class="min-h-[calc(100vh-64px)] flex flex-col bg-[#f8fafc]">
    <main class="flex-grow p-6 sm:p-8 lg:p-10 max-w-4xl w-full mx-auto">

        <!-- Validation Error Alert -->
        <c:if test="${not empty errorMessage}">
            <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                <div class="flex items-center space-x-2.5">
                    <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                    <span class="font-medium"><c:out value="${errorMessage}" /></span>
                </div>
                <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
        </c:if>

        <!-- Setting Detail Card -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">

            <!-- Card Header -->
            <div class="flex items-center justify-between pb-5 mb-6 border-b border-slate-200">
                <h1 class="text-xl sm:text-2xl font-bold text-slate-900 tracking-tight">
                    <c:choose>
                        <c:when test="${isEdit}">
                            Setting Detail - <c:out value="${setting.code}" />
                        </c:when>
                        <c:otherwise>
                            Add New Setting
                        </c:otherwise>
                    </c:choose>
                </h1>

                <span id="statusBadge"
                      class="inline-flex items-center px-3.5 py-1 rounded-full text-xs font-semibold ${isActiveStatus ? 'bg-[#dcfce7] text-[#15803d]' : 'bg-slate-100 text-slate-600'}">
                    ${isActiveStatus ? 'Active' : 'Inactive'}
                </span>
            </div>

            <!-- Form -->
            <form action="${pageContext.request.contextPath}/admin/setting-detail" method="post" class="space-y-6">
                <input type="hidden" name="action" value="save">
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${setting.id}">
                    <input type="hidden" name="code" value="${fn:escapeXml(setting.code)}">
                </c:if>

                <!-- 2-Column Form Fields -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-5">

                    <!-- Setting Name -->
                    <div>
                        <label for="settingName" class="block text-sm font-semibold text-slate-600 mb-2">
                            Setting Name
                        </label>
                        <input type="text"
                               id="settingName"
                               name="name"
                               required
                               value="${fn:escapeXml(setting.name)}"
                               placeholder="Enter unique setting name..."
                               class="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-lg text-sm text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition">
                    </div>

                    <!-- Setting Type -->
                    <div>
                        <label for="settingType" class="block text-sm font-semibold text-slate-600 mb-2">
                            Setting Type
                        </label>
                        <div class="relative">
                            <select id="settingType"
                                    name="type"
                                    required
                                    class="w-full pl-3.5 pr-10 py-2.5 bg-white border border-slate-300 rounded-lg text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition appearance-none cursor-pointer">
                                <c:if test="${empty setting.type}">
                                    <option value="" disabled selected>-- Select Setting Type --</option>
                                </c:if>
                                <c:forEach var="t" items="${types}">
                                    <option value="${fn:escapeXml(t)}" ${setting.type eq t ? 'selected' : ''}>
                                        <c:out value="${t}" />
                                    </option>
                                </c:forEach>
                            </select>
                            <i class="fa-solid fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        </div>
                    </div>

                    <!-- Display Order -->
                    <div>
                        <label for="displayOrder" class="block text-sm font-semibold text-slate-600 mb-2">
                            Display Order
                        </label>
                        <input type="number"
                               id="displayOrder"
                               name="sortOrder"
                               min="0"
                               required
                               value="${not empty setting ? setting.sortOrder : 1}"
                               class="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-lg text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition">
                    </div>

                    <!-- Status (Radio Buttons) -->
                    <div>
                        <label class="block text-sm font-semibold text-slate-600 mb-2">
                            Status
                        </label>
                        <c:set var="isRoleType" value="${setting.type eq 'role'}" />
                        <div class="flex items-center space-x-6 h-[42px]">
                            <!-- Active Option (always shown and checked by default for roles) -->
                            <label class="inline-flex items-center space-x-2 text-sm text-slate-700 cursor-pointer">
                                <input type="radio"
                                       id="statusActiveRadio"
                                       name="status"
                                       value="true"
                                       ${isRoleType or isActiveStatus ? 'checked' : ''}
                                       onchange="updateStatusBadge(true)"
                                       class="w-4 h-4 accent-[#047857] cursor-pointer">
                                <span class="font-medium text-emerald-800">Active</span>
                            </label>

                            <!-- Inactive Option (hidden if type is role) -->
                            <label id="inactiveRadioWrapper"
                                   class="inline-flex items-center space-x-2 text-sm text-slate-700 cursor-pointer ${isRoleType ? 'hidden' : ''}">
                                <input type="radio"
                                       id="statusInactiveRadio"
                                       name="status"
                                       value="false"
                                       ${!isRoleType and not isActiveStatus ? 'checked' : ''}
                                       onchange="updateStatusBadge(false)"
                                       class="w-4 h-4 accent-[#047857] cursor-pointer">
                                <span>Inactive</span>
                            </label>

                            <!-- Helper note when type is role -->
                            <span id="roleActiveNotice" class="text-xs text-slate-400 italic ${isRoleType ? '' : 'hidden'}">
                                (Vai trò hệ thống mặc định luôn Active)
                            </span>
                        </div>
                    </div>

                </div>

                <!-- Description / Value Configuration -->
                <div>
                    <label for="settingDescription" class="block text-sm font-semibold text-slate-600 mb-2">
                        Description / Value Configuration
                    </label>
                    <textarea id="settingDescription"
                              name="description"
                              rows="4"
                              placeholder="Enter detailed configuration or value description..."
                              class="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-lg text-sm text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition"><c:out value="${setting.description}" /></textarea>
                </div>

                <!-- Card Footer Actions -->
                <div class="pt-5 border-t border-slate-200 flex items-center justify-end space-x-3">
                    <a href="${pageContext.request.contextPath}/admin/settings"
                       class="px-5 py-2.5 border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-semibold rounded-lg text-sm transition">
                        Cancel
                    </a>
                    <button type="submit"
                            class="px-6 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-lg text-sm shadow-sm transition cursor-pointer">
                        Save Changes
                    </button>
                </div>
            </form>

        </div>

    </main>
</div>

<script>
    function updateStatusBadge(isActive) {
        const badge = document.getElementById('statusBadge');
        if (!badge) return;
        if (isActive) {
            badge.textContent = 'Active';
            badge.className = 'inline-flex items-center px-3.5 py-1 rounded-full text-xs font-semibold bg-[#dcfce7] text-[#15803d]';
        } else {
            badge.textContent = 'Inactive';
            badge.className = 'inline-flex items-center px-3.5 py-1 rounded-full text-xs font-semibold bg-slate-100 text-slate-600';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const settingTypeSelect = document.getElementById('settingType');
        const inactiveRadioWrapper = document.getElementById('inactiveRadioWrapper');
        const roleActiveNotice = document.getElementById('roleActiveNotice');
        const statusActiveRadio = document.getElementById('statusActiveRadio');

        if (settingTypeSelect && inactiveRadioWrapper && roleActiveNotice && statusActiveRadio) {
            settingTypeSelect.addEventListener('change', function() {
                const isRole = this.value === 'role';
                if (isRole) {
                    statusActiveRadio.checked = true;
                    updateStatusBadge(true);
                    inactiveRadioWrapper.classList.add('hidden');
                    roleActiveNotice.classList.remove('hidden');
                } else {
                    inactiveRadioWrapper.classList.remove('hidden');
                    roleActiveNotice.classList.add('hidden');
                }
            });
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
