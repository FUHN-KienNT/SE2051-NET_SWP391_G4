<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<c:set var="isEdit" value="${not empty user and not empty user.id and not isNew}" />
<c:set var="isNewMode" value="${not isEdit}" />

<div class="min-h-[calc(100vh-64px)] bg-[#f8fafc] py-8 sm:py-10">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">

        <!-- Breadcrumb & Section Title -->
        <div class="mb-6 flex items-center justify-between">
            <nav class="flex text-sm text-slate-500 space-x-2" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="hover:text-slate-700 transition">Dashboard</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/admin/users" class="hover:text-slate-700 transition">Users</a>
                <span>/</span>
                <span class="text-slate-800 font-semibold">
                    <c:choose>
                        <c:when test="${isNewMode}">Thêm người dùng mới</c:when>
                        <c:otherwise>User Details</c:otherwise>
                    </c:choose>
                </span>
            </nav>
            <span class="text-xs font-mono text-slate-500">2.1.2 User Details</span>
        </div>

        <!-- Flash Success Notification -->
        <c:if test="${not empty sessionScope.flashMessage}">
            <div class="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm flex items-center justify-between shadow-sm">
                <div class="flex items-center space-x-2.5">
                    <i class="fa-solid fa-circle-check text-emerald-600 text-base" aria-hidden="true"></i>
                    <span class="font-medium"><c:out value="${sessionScope.flashMessage}" /></span>
                </div>
                <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-800 p-1" aria-label="Dismiss">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <c:remove var="flashMessage" scope="session"/>
        </c:if>

        <!-- Flash Error Notification -->
        <c:if test="${not empty sessionScope.flashError}">
            <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                <div class="flex items-center space-x-2.5">
                    <i class="fa-solid fa-circle-exclamation text-rose-600 text-base" aria-hidden="true"></i>
                    <span class="font-medium"><c:out value="${sessionScope.flashError}" /></span>
                </div>
                <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800 p-1" aria-label="Dismiss">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <c:remove var="flashError" scope="session"/>
        </c:if>

        <!-- Validation Error Message Alert -->
        <c:if test="${not empty errorMessage}">
            <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center justify-between shadow-sm">
                <div class="flex items-center space-x-2.5">
                    <i class="fa-solid fa-circle-exclamation text-rose-600 text-base" aria-hidden="true"></i>
                    <span class="font-medium"><c:out value="${errorMessage}" /></span>
                </div>
                <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-800 p-1" aria-label="Dismiss">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
        </c:if>

        <!-- Main User Details Card -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8">

            <!-- Card Header -->
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between pb-6 border-b border-slate-200 gap-4 mb-6">
                <c:choose>
                    <c:when test="${isNewMode}">
                        <div class="flex items-center space-x-4">
                            <div class="w-12 h-12 rounded-xl bg-emerald-50 text-[#047857] flex items-center justify-center text-xl select-none shadow-xs border border-emerald-100 flex-shrink-0">
                                <i class="fa-solid fa-user-plus"></i>
                            </div>
                            <div>
                                <h1 class="text-xl font-bold text-slate-900 leading-snug">
                                    Thêm người dùng mới
                                </h1>
                                <p class="text-xs font-medium text-slate-500 mt-0.5">
                                    Tạo tài khoản người dùng mới trên hệ thống LearnHub. Mật khẩu tạm thời sẽ được tạo tự động và gửi qua email.
                                </p>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="flex items-center space-x-4">
                            <!-- Avatar circle with initials in system emerald green -->
                            <div class="w-14 h-14 rounded-full bg-[#047857] flex items-center justify-center text-white font-bold text-xl select-none shadow-sm flex-shrink-0 tracking-wide">
                                <c:out value="${not empty initials ? initials : 'U'}" />
                            </div>
                            <div>
                                <h1 class="text-xl font-bold text-slate-900 leading-snug">
                                    <c:out value="${not empty user.fullName ? user.fullName : user.username}" />
                                </h1>
                                <p class="text-xs font-medium text-slate-500 mt-0.5">
                                    ID: <c:out value="${not empty userCode ? userCode : user.id}" />
                                </p>
                            </div>
                        </div>

                        <!-- Right Status Pill Badge -->
                        <div>
                            <c:choose>
                                <c:when test="${user.status eq 'active'}">
                                    <span id="accountStatusBadge" class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 transition-all">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                        Active Account
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span id="accountStatusBadge" class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200 transition-all">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                        Inactive Account
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Profile / Creation Form -->
            <form id="userProfileForm" action="${pageContext.request.contextPath}/admin/user-detail" method="post" class="space-y-6">
                <c:choose>
                    <c:when test="${isNewMode}">
                        <input type="hidden" name="action" value="create">

                        <!-- Row 1: Username & Email Address -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label for="username" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Tên đăng nhập (Username) <span class="text-rose-500">*</span>
                                </label>
                                <input type="text" id="username" name="username" required
                                       value="<c:out value='${not empty enteredUsername ? enteredUsername : ""}'/>"
                                       pattern="^[\p{L}\p{N}._-]{3,255}$"
                                       title="Tên đăng nhập từ 3 đến 255 ký tự, chỉ chứa chữ cái, số, dấu chấm, gạch dưới hoặc gạch ngang"
                                       placeholder="Ví dụ: hoangnam2026"
                                       class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                            </div>
                            <div>
                                <label for="email" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Địa chỉ Email <span class="text-rose-500">*</span>
                                </label>
                                <input type="email" id="email" name="email" required
                                       value="<c:out value='${not empty enteredEmail ? enteredEmail : ""}'/>"
                                       placeholder="user@learnhub.edu.vn"
                                       class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                            </div>
                        </div>

                        <!-- Row 2: Full Name & Phone Number -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label for="fullName" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Họ và tên (Full Name) <span class="text-rose-500">*</span>
                                </label>
                                <input type="text" id="fullName" name="fullName" required
                                       value="<c:out value='${not empty enteredFullName ? enteredFullName : ""}'/>"
                                       placeholder="Ví dụ: Nguyễn Hoàng Nam"
                                       class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                            </div>
                            <div>
                                <label for="phone" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Số điện thoại (Phone Number)
                                </label>
                                <input type="tel" id="phone" name="phone"
                                       value="<c:out value='${not empty enteredPhone ? enteredPhone : ""}'/>"
                                       placeholder="0987654321"
                                       pattern="^0[0-9]{9}$"
                                       title="Số điện thoại gồm 10 chữ số bắt đầu bằng 0 (ví dụ: 0987654321)"
                                       class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                            </div>
                        </div>

                        <!-- Row 3: Role & Status -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label for="roleId" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Phân quyền vai trò (Assign Role) <span class="text-rose-500">*</span>
                                </label>
                                <select id="roleId" name="roleId" required
                                        class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                                    <option value="" disabled ${empty enteredRoleId ? 'selected' : ''}>-- Chọn vai trò --</option>
                                    <c:forEach var="role" items="${roles}">
                                        <option value="${role.id}" ${enteredRoleId eq role.id.toString() ? 'selected' : ''}>
                                            <c:out value="${role.name}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label for="status" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Trạng thái tài khoản (Status) <span class="text-rose-500">*</span>
                                </label>
                                <select id="status" name="status" required
                                        class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                                    <option value="active" ${empty enteredStatus or enteredStatus eq 'active' ? 'selected' : ''}>Hoạt động (Active)</option>
                                    <option value="inactive" ${enteredStatus eq 'inactive' ? 'selected' : ''}>Tạm ngưng (Inactive)</option>
                                </select>
                            </div>
                        </div>

                        <!-- Row 4: Password Info Box -->
                        <div class="p-4 rounded-xl bg-emerald-50/70 border border-emerald-200/80 text-emerald-900 text-sm flex items-start gap-3.5 shadow-xs">
                            <div class="w-8 h-8 rounded-lg bg-emerald-100 text-[#047857] flex items-center justify-center flex-shrink-0 mt-0.5">
                                <i class="fa-solid fa-key text-sm"></i>
                            </div>
                            <div class="text-xs sm:text-sm">
                                <p class="font-bold text-emerald-950">Mật khẩu khởi tạo tự động</p>
                                <p class="text-emerald-800 text-xs mt-0.5 leading-relaxed">
                                    Hệ thống sẽ tự động sinh mật khẩu ngẫu nhiên an toàn và gửi đến email của người dùng. Tài khoản sẽ được kích hoạt cờ yêu cầu đổi mật khẩu ngay trong lần đăng nhập đầu tiên để bảo đảm an toàn thông tin.
                                </p>
                            </div>
                        </div>

                        <!-- Action Footer for Creation -->
                        <div class="pt-6 border-t border-slate-200 flex items-center justify-end gap-3">
                            <a href="${pageContext.request.contextPath}/admin/users"
                               class="px-5 py-2.5 border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-semibold rounded-lg text-sm transition text-center shadow-sm">
                                Hủy
                            </a>
                            <button type="submit"
                                    class="px-6 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-lg text-sm shadow-sm transition focus:outline-none focus:ring-2 focus:ring-[#047857] focus:ring-offset-2 cursor-pointer">
                                Tạo người dùng
                            </button>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="userId" value="${user.id}">

                        <!-- Row 1: Full Name & Email Address -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label for="fullName" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Full Name <span class="text-rose-500">*</span>
                                </label>
                                <input type="text" id="fullName" name="fullName" required
                                       value="<c:out value='${user.fullName}'/>"
                                       placeholder="Nhập họ và tên..."
                                       class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                            </div>
                            <div>
                                <label for="email" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Email Address
                                </label>
                                <input type="email" id="email" name="email" readonly
                                       value="<c:out value='${user.email}'/>"
                                       class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-500 bg-slate-100 text-sm cursor-not-allowed select-none shadow-sm">
                            </div>
                        </div>

                        <!-- Row 2: Phone Number, Assign Role, Account Status -->
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                            <div>
                                <label for="phone" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Phone Number
                                </label>
                                <input type="tel" id="phone" name="phone"
                                       value="<c:out value='${user.phone}'/>"
                                       placeholder="0987654321"
                                       pattern="^0[0-9]{9}$"
                                       title="Số điện thoại gồm 10 chữ số bắt đầu bằng 0 (ví dụ: 0987654321)"
                                       class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                            </div>
                            <div>
                                <label for="roleId" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Assign Role <span class="text-rose-500">*</span>
                                </label>
                                <select id="roleId" name="roleId" required
                                        class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                                    <c:forEach var="role" items="${roles}">
                                        <option value="${role.id}" ${user.roleId eq role.id ? 'selected' : ''}>
                                            <c:out value="${role.name}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label for="status" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                    Account Status <span class="text-rose-500">*</span>
                                </label>
                                <select id="status" name="status" required onchange="updateAccountStatusBadge(this.value)"
                                        class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm">
                                    <option value="active" ${user.status eq 'active' ? 'selected' : ''}>Active</option>
                                    <option value="inactive" ${user.status eq 'inactive' ? 'selected' : ''}>Inactive</option>
                                </select>
                            </div>
                        </div>

                        <!-- Row 3: Notes / Reason for Status Change -->
                        <div>
                            <label for="statusNote" class="block text-xs font-semibold text-slate-700 mb-1.5">
                                Lý do thay đổi trạng thái / Lý do tạm ngưng
                                <span id="noteRequiredStar" class="text-rose-500 ${user.status eq 'inactive' ? '' : 'hidden'}">*</span>
                            </label>
                            <textarea id="statusNote" name="statusNote" rows="3"
                                      placeholder="Nhập lý do ngắn gọn, rõ ràng phù hợp hiển thị trực tiếp cho người dùng..."
                                      class="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-[#047857] focus:border-[#047857] transition shadow-sm resize-y"
                                      ${user.status eq 'inactive' ? 'required' : ''}><c:out value="${user.statusNote}" /></textarea>
                            <div id="statusNoteGuide" class="mt-2.5 p-3.5 bg-amber-50/80 border border-amber-200 rounded-xl text-xs text-amber-900 flex items-start gap-2.5 ${user.status eq 'inactive' ? '' : 'hidden'}">
                                <i class="fa-solid fa-circle-info text-amber-600 mt-0.5 text-sm flex-shrink-0"></i>
                                <div class="space-y-1">
                                    <p class="font-bold text-amber-950">Hướng dẫn viết lý do tạm ngưng tài khoản:</p>
                                    <p class="text-amber-800 leading-relaxed">
                                        Vui lòng nhập lý do ngắn gọn, lịch sự và rõ ràng (Ví dụ: <em>&ldquo;Chưa hoàn tất học phí học kỳ Fall 2026&rdquo;</em>, <em>&ldquo;Tạm ngưng theo yêu cầu cá nhân&rdquo;</em> hoặc <em>&ldquo;Phát hiện dấu hiệu vi phạm quy chế thi&rdquo;</em>).
                                    </p>
                                    <p class="text-amber-700 text-[11px] font-medium">
                                        💡 Lý do này sẽ được <strong>hiển thị trực tiếp cho người dùng</strong> khi họ đăng nhập và lưu trong thông báo hệ thống.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- Divider & Action Footer -->
                        <div class="pt-6 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-4">
                            <div>
                                <button type="button" onclick="openResetPasswordModal()"
                                        class="text-rose-600 hover:text-rose-700 font-semibold text-sm transition hover:underline focus:outline-none cursor-pointer">
                                    Reset Password
                                </button>
                            </div>
                            <div class="flex items-center gap-3 w-full sm:w-auto justify-end">
                                <a href="${pageContext.request.contextPath}/admin/users"
                                   class="px-5 py-2.5 border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-semibold rounded-lg text-sm transition text-center shadow-sm">
                                    Back to List
                                </a>
                                <button type="submit"
                                        class="px-6 py-2.5 bg-[#047857] hover:bg-[#065f46] text-white font-bold rounded-lg text-sm shadow-sm transition focus:outline-none focus:ring-2 focus:ring-[#047857] focus:ring-offset-2 cursor-pointer">
                                    Update User Profile
                                </button>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </form>
        </div>
    </div>
</div>

<c:if test="${isEdit}">
    <!-- Reset Password Confirmation Modal -->
    <div id="resetPasswordModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-slate-100 transform transition-all">
            <div class="flex items-start gap-4">
                <div class="w-10 h-10 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center flex-shrink-0">
                    <i class="fa-solid fa-key text-lg"></i>
                </div>
                <div>
                    <h3 class="text-base font-bold text-slate-900">Đặt lại mật khẩu người dùng</h3>
                    <p class="text-sm text-slate-600 mt-2">
                        Bạn có chắc chắn muốn đặt lại mật khẩu cho <strong class="text-slate-900"><c:out value="${user.email}" /></strong>?
                    </p>
                    <p class="text-xs text-slate-500 mt-1">
                        Hệ thống sẽ tự động tạo mật khẩu tạm thời, gửi email thông báo và yêu cầu người dùng đổi mật khẩu khi đăng nhập lần tiếp theo.
                    </p>
                </div>
            </div>
            <div class="mt-6 flex items-center justify-end gap-3">
                <button type="button" onclick="closeResetPasswordModal()"
                        class="px-4 py-2 border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-semibold rounded-lg text-sm transition cursor-pointer">
                    Hủy bỏ
                </button>
                <form action="${pageContext.request.contextPath}/admin/user-detail" method="post" class="inline">
                    <input type="hidden" name="action" value="reset-password">
                    <input type="hidden" name="userId" value="${user.id}">
                    <button type="submit"
                            class="px-4 py-2 bg-rose-600 hover:bg-rose-700 text-white font-semibold rounded-lg text-sm shadow transition cursor-pointer">
                        Xác nhận đặt lại
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
    function updateAccountStatusBadge(status) {
        const badge = document.getElementById('accountStatusBadge');
        const guide = document.getElementById('statusNoteGuide');
        const star = document.getElementById('noteRequiredStar');
        const noteInput = document.getElementById('statusNote');

        if (status === 'inactive') {
            if (badge) {
                badge.className = 'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200 transition-all';
                badge.innerHTML = '<span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span> Inactive Account';
            }
            if (guide) guide.classList.remove('hidden');
            if (star) star.classList.remove('hidden');
            if (noteInput) noteInput.setAttribute('required', 'required');
        } else {
            if (badge) {
                badge.className = 'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 transition-all';
                badge.innerHTML = '<span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Active Account';
            }
            if (guide) guide.classList.add('hidden');
            if (star) star.classList.add('hidden');
            if (noteInput) noteInput.removeAttribute('required');
        }
    }

    document.getElementById('userProfileForm')?.addEventListener('submit', function(e) {
        const statusSelect = document.getElementById('status');
        const noteInput = document.getElementById('statusNote');
        if (statusSelect && statusSelect.value === 'inactive') {
            if (!noteInput || !noteInput.value.trim()) {
                e.preventDefault();
                alert('Vui lòng nhập lý do tạm ngưng tài khoản để người dùng nắm được thông tin.');
                if (noteInput) noteInput.focus();
            }
        }
    });

    function openResetPasswordModal() {
        const modal = document.getElementById('resetPasswordModal');
        if (modal) {
            modal.classList.remove('hidden');
        }
    }

    function closeResetPasswordModal() {
        const modal = document.getElementById('resetPasswordModal');
        if (modal) {
            modal.classList.add('hidden');
        }
    }

    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeResetPasswordModal();
        }
    });
    </script>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
