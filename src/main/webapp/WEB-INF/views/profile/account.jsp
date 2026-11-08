<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageLanguage" value="en" scope="request" />
<c:set var="pageTitle" value="Account - LearnHub" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow w-full max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
    <div class="flex flex-wrap items-start justify-between gap-4 mb-8">
        <div>
            <p class="text-sm font-semibold uppercase tracking-wide text-brand-700 mb-2">Settings</p>
            <h1 class="text-3xl font-bold text-text-primary">Account</h1>
        <p class="mt-2 text-sm text-text-secondary">Manage your name, username, and phone number, and keep your account secure.</p>
        </div>
        <a href="${pageContext.request.contextPath}/profile"
           class="inline-flex items-center gap-2 rounded-lg border border-border-default bg-surface-card px-4 py-2.5 text-sm font-semibold text-text-primary hover:border-brand-700 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
            <i class="fa-solid fa-arrow-left" aria-hidden="true"></i> View profile
        </a>
    </div>

    <c:if test="${param.updated eq 'profile' || param.updated eq 'password' || param.updated eq 'avatar'}">
        <p role="status" class="mb-6 rounded-xl border border-brand-100 bg-brand-50 p-4 text-sm font-medium text-status-success">
            <c:choose>
                <c:when test="${param.updated eq 'profile'}">Your profile has been updated.</c:when>
                <c:when test="${param.updated eq 'avatar'}">Your profile photo has been updated.</c:when>
                <c:otherwise>Your password has been changed.</c:otherwise>
            </c:choose>
        </p>
    </c:if>

    <div class="space-y-6">
        <section class="rounded-xl border border-border-default bg-surface-card p-4 sm:p-6 shadow-sm" aria-labelledby="profile-details-heading">
            <h2 id="profile-details-heading" class="text-xl font-bold text-text-primary">Profile details</h2>
            <p class="mt-1 text-sm text-text-secondary">Your email is linked to this account and cannot be changed here.</p>
            <div class="my-6 flex items-center gap-4">
                <span id="avatar-current"><jsp:include page="/WEB-INF/views/common/avatar.jsp">
                    <jsp:param name="avatarUrl" value="${profileUser.avatarUrl}" />
                    <jsp:param name="avatarName" value="${profileUser.fullName}" />
                    <jsp:param name="avatarClass" value="h-16 w-16 text-2xl" />
                </jsp:include></span>
                <img id="avatar-preview" alt="Preview of selected profile photo" class="hidden h-16 w-16 shrink-0 rounded-full object-cover">
                <div class="min-w-0">
                    <p class="font-semibold text-text-primary break-words"><c:out value="${profileUser.fullName}" /></p>
                    <p class="mt-1 text-sm text-text-secondary break-words"><c:out value="${profileUser.username}" /></p>
                    <p class="mt-1 text-sm text-text-secondary">Your profile photo appears across LearnHub.</p>
                </div>
            </div>

            <c:if test="${not empty avatarError}">
                <p role="alert" class="mb-5 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-status-danger"><c:out value="${avatarError}" /></p>
            </c:if>
            <form action="${pageContext.request.contextPath}/account/avatar" method="post" enctype="multipart/form-data" class="mb-8">
                <input type="hidden" name="csrfToken" value="${fn:escapeXml(csrfToken)}">
                <label for="avatar-file" class="mb-2 block text-sm font-semibold text-text-primary">Profile photo</label>
                <input id="avatar-file" name="avatar" type="file" accept="image/jpeg,image/png" required aria-describedby="avatar-help"
                       class="block w-full text-sm text-text-secondary file:mr-4 file:rounded-lg file:border-0 file:bg-brand-50 file:px-4 file:py-2 file:font-semibold file:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                <p id="avatar-help" class="mt-2 text-xs text-text-secondary">JPEG or PNG, up to 5 MB.</p>
                <button type="submit" class="mt-4 rounded-lg bg-brand-700 px-5 py-2.5 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">Save photo</button>
            </form>
            <c:if test="${not empty profileError}">
                <p role="alert" class="mb-5 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-status-danger"><c:out value="${profileError}" /></p>
            </c:if>
            <form action="${pageContext.request.contextPath}/account/profile" method="post">
                <input type="hidden" name="csrfToken" value="${fn:escapeXml(csrfToken)}">
                <div class="grid gap-4 sm:grid-cols-2">
                    <div>
                        <label for="account-full-name" class="mb-2 block text-sm font-semibold text-text-primary">Full name</label>
                        <input id="account-full-name" name="fullName" type="text" maxlength="255" required autocomplete="name"
                               value="${fn:escapeXml(enteredFullName != null ? enteredFullName : profileUser.fullName)}"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                    </div>
                    <div>
                        <label for="account-username" class="mb-2 block text-sm font-semibold text-text-primary">Username</label>
                        <input id="account-username" name="username" type="text" minlength="3" maxlength="255" required autocomplete="username"
                               value="${fn:escapeXml(enteredUsername != null ? enteredUsername : profileUser.username)}"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                        <p class="mt-2 text-xs text-text-secondary">3–255 letters, numbers, dots, underscores, or hyphens.</p>
                    </div>
                    <div class="sm:col-span-2">
                        <label for="account-email" class="mb-2 block text-sm font-semibold text-text-primary">Email</label>
                        <input id="account-email" type="email" readonly aria-readonly="true" value="${fn:escapeXml(profileUser.email)}"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-secondary">
                        <p class="mt-2 text-xs text-text-secondary">Contact support if your email needs to change.</p>
                    </div>
                    <div class="sm:col-span-2">
                        <label for="account-phone" class="mb-2 block text-sm font-semibold text-text-primary">Phone</label>
                        <c:choose>
                            <c:when test="${not empty profileError}"><c:set var="phoneValue" value="${enteredPhone}" /></c:when>
                            <c:otherwise><c:set var="phoneValue" value="${profileUser.phone}" /></c:otherwise>
                        </c:choose>
                        <input id="account-phone" name="phone" type="tel" inputmode="numeric" autocomplete="tel" maxlength="10" pattern="0[0-9]{9}"
                               value="${fn:escapeXml(phoneValue)}"
                               aria-describedby="account-phone-help"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                        <p id="account-phone-help" class="mt-2 text-xs text-text-secondary">Optional. Enter 10 digits starting with 0.</p>
                    </div>
                </div>
                <button type="submit"
                        class="mt-6 inline-flex items-center gap-2 rounded-lg bg-brand-700 px-5 py-2.5 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-regular fa-floppy-disk" aria-hidden="true"></i> Save changes
                </button>
            </form>
        </section>

        <section class="rounded-xl border border-border-default bg-surface-card p-4 sm:p-6 shadow-sm" aria-labelledby="change-password-heading">
            <h2 id="change-password-heading" class="text-xl font-bold text-text-primary">Change password</h2>
            <p class="mt-1 text-sm text-text-secondary">Choose a password different from your current one.</p>
            <c:if test="${not empty passwordError}">
                <p role="alert" class="mt-5 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-status-danger"><c:out value="${passwordError}" /></p>
            </c:if>
            <form action="${pageContext.request.contextPath}/account/password" method="post">
                <input type="hidden" name="csrfToken" value="${fn:escapeXml(csrfToken)}">
                <div class="mt-6 grid gap-4 md:grid-cols-3">
                    <div>
                        <label for="current-password" class="mb-2 block text-sm font-semibold text-text-primary">Current password</label>
                        <input id="current-password" name="currentPassword" type="password" required autocomplete="current-password"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                    </div>
                    <div>
                        <label for="new-password" class="mb-2 block text-sm font-semibold text-text-primary">New password</label>
                        <input id="new-password" name="newPassword" type="password" required minlength="8" autocomplete="new-password"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                        <p class="mt-2 text-xs text-text-secondary">At least 8 characters, at most 72 bytes.</p>
                    </div>
                    <div>
                        <label for="confirm-password" class="mb-2 block text-sm font-semibold text-text-primary">Confirm new password</label>
                        <input id="confirm-password" name="confirmPassword" type="password" required autocomplete="new-password"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                    </div>
                </div>
                <button type="submit"
                        class="mt-6 inline-flex items-center gap-2 rounded-lg bg-brand-700 px-5 py-2.5 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    <i class="fa-solid fa-key" aria-hidden="true"></i> Change password
                </button>
            </form>
            <p class="mt-5 text-sm leading-relaxed text-text-secondary">
                Signed in with Google or GitHub and do not know your current password?
                <a href="${pageContext.request.contextPath}/auth/forgot-password"
                   class="font-semibold text-brand-700 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                    Reset it by email
                </a>.
            </p>
        </section>
    </div>
</main>
<script src="${pageContext.request.contextPath}/assets/js/avatar-preview.js" defer></script>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
