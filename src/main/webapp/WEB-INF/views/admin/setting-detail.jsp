<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<c:set var="isEdit" value="${not empty setting and not empty setting.id}" />
<c:set var="isRoleType" value="${not empty setting and (setting.type eq 'role' or isProtected)}" />
<c:set var="isActiveStatus" value="${empty setting or setting.status}" />

<div class="min-h-[calc(100vh-64px)] flex flex-col bg-[#f8fafc]">
    <main class="flex-grow p-6 sm:p-8 lg:p-10 max-w-4xl w-full mx-auto">

        <!-- Role Protected Notice -->
        <c:if test="${isRoleType}">
            <div class="mb-6 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-sm flex items-start space-x-3 shadow-sm">
                <i class="fa-solid fa-shield-halved text-amber-600 text-lg mt-0.5"></i>
                <div>
                    <p class="font-bold text-amber-950">Vai trò hệ thống (Chỉ xem)</p>
                    <p class="text-amber-800 text-xs mt-0.5">
                        Vai trò hệ thống là cấu hình dữ liệu cốt lõi được bảo vệ: chỉ xem chi tiết, không được phép chỉnh sửa tên, loại, mã hay mô tả. Thứ tự hiển thị có thể điều chỉnh tại danh sách bằng thao tác kéo thả (drag &amp; drop).
                    </p>
                </div>
            </div>
        </c:if>

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
                <div class="flex items-center gap-3">
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
                    <c:if test="${isRoleType}">
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-100 text-amber-800 border border-amber-200">
                            <i class="fa-solid fa-lock text-[10px]"></i> Protected Role
                        </span>
                    </c:if>
                </div>

                <span id="statusBadge"
                      class="inline-flex items-center px-3.5 py-1 rounded-full text-xs font-semibold ${isActiveStatus ? 'bg-[#dcfce7] text-[#15803d]' : 'bg-slate-100 text-slate-600'}">
                    ${isActiveStatus ? 'Active' : 'Inactive'}
                </span>
            </div>

            <!-- Form -->
            <form action="${pageContext.request.contextPath}/admin/setting-detail" method="post" class="space-y-6">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="sortOrder" value="${not empty setting ? setting.sortOrder : 1}">
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${setting.id}">
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
                               ${isRoleType ? 'readonly' : ''}
                               value="${fn:escapeXml(setting.name)}"
                               placeholder="Enter unique setting name..."
                               class="w-full px-3.5 py-2.5 rounded-lg text-sm transition ${isRoleType ? 'bg-slate-100 text-slate-600 cursor-not-allowed border border-slate-200' : 'bg-white text-slate-800 border border-slate-300 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857]'}">
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
                                    ${isRoleType ? 'disabled' : ''}
                                    class="w-full pl-3.5 pr-10 py-2.5 rounded-lg text-sm transition appearance-none ${isRoleType ? 'bg-slate-100 text-slate-600 cursor-not-allowed border border-slate-200' : 'bg-white text-slate-800 border border-slate-300 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] cursor-pointer'}">
                                <c:if test="${empty setting.type}">
                                    <option value="" disabled selected>-- Select Setting Type --</option>
                                </c:if>
                                <c:forEach var="t" items="${types}">
                                    <option value="${fn:escapeXml(t)}" ${setting.type eq t ? 'selected' : ''}>
                                        <c:out value="${t}" />
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${isRoleType}">
                                <input type="hidden" name="type" value="${fn:escapeXml(setting.type)}">
                            </c:if>
                            <i class="fa-solid fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        </div>
                    </div>

                    <!-- Value / Setting Code -->
                    <div>
                        <label for="settingCode" class="block text-sm font-semibold text-slate-600 mb-2">
                            Value / Setting Code <c:if test="${not isRoleType}"><span class="text-rose-500">*</span></c:if>
                        </label>
                        <input type="text"
                               id="settingCode"
                               name="code"
                               required
                               ${isRoleType ? 'readonly' : ''}
                               value="${fn:escapeXml(setting.code)}"
                               placeholder="e.g. ROLE_ADMIN, CAT_WEB, PAY_VNPAY..."
                               class="w-full px-3.5 py-2.5 font-mono rounded-lg text-sm transition ${isRoleType ? 'bg-slate-100 text-slate-600 cursor-not-allowed border border-slate-200' : 'bg-white text-slate-800 border border-slate-300 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857]'}">
                    </div>

                    <!-- Status (Radio Buttons) -->
                    <div>
                        <label class="block text-sm font-semibold text-slate-600 mb-2">
                            Status
                        </label>
                        <div class="flex items-center space-x-6 h-[42px]">
                            <!-- Active Option (always checked for roles) -->
                            <label class="inline-flex items-center space-x-2 text-sm text-slate-700 ${isRoleType ? 'cursor-not-allowed' : 'cursor-pointer'}">
                                <input type="radio"
                                       id="statusActiveRadio"
                                       name="status"
                                       value="true"
                                       ${isRoleType ? 'disabled' : ''}
                                       ${isRoleType or isActiveStatus ? 'checked' : ''}
                                       onchange="updateStatusBadge(true)"
                                       class="w-4 h-4 accent-[#047857] ${isRoleType ? 'cursor-not-allowed' : 'cursor-pointer'}">
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
                                (Luôn Active - Vai trò hệ thống)
                            </span>
                        </div>
                    </div>

                </div>

                <!-- Description -->
                <div>
                    <label for="settingDescription" class="block text-sm font-semibold text-slate-600 mb-2">
                        Description
                    </label>
                    <textarea id="settingDescription"
                              name="description"
                              rows="4"
                              ${isRoleType ? 'readonly' : ''}
                              placeholder="Nhập mô tả giải thích ý nghĩa hoặc ghi chú chi tiết về cấu hình..."
                              class="w-full px-3.5 py-2.5 rounded-lg text-sm transition ${isRoleType ? 'bg-slate-100 text-slate-600 cursor-not-allowed border border-slate-200' : 'bg-white text-slate-800 border border-slate-300 focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857]'}"><c:out value="${setting.description}" /></textarea>
                </div>

                <!-- Card Footer Actions -->
                <div class="pt-5 border-t border-slate-200 flex items-center justify-end space-x-3">
                    <a href="${pageContext.request.contextPath}/admin/settings"
                       class="px-5 py-2.5 border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-semibold rounded-lg text-sm transition inline-flex items-center gap-2">
                        <i class="fa-solid fa-arrow-left text-xs"></i>
                        <span>${isRoleType ? 'Quay lại Setting List' : 'Cancel'}</span>
                    </a>
                    <c:if test="${not isRoleType}">
                        <button type="submit"
                                class="px-6 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-lg text-sm shadow-sm transition cursor-pointer inline-flex items-center gap-2">
                            <i class="fa-solid fa-check text-xs"></i>
                            <span>Save Changes</span>
                        </button>
                    </c:if>
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
