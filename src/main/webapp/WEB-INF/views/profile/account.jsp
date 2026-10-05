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
            <p class="mt-2 text-sm text-text-secondary">Manage your username and keep your account secure.</p>
        </div>
        <a href="${pageContext.request.contextPath}/profile"
           class="inline-flex items-center gap-2 rounded-lg border border-border-default bg-surface-card px-4 py-2.5 text-sm font-semibold text-text-primary hover:border-brand-700 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
            <i class="fa-solid fa-arrow-left" aria-hidden="true"></i> View profile
        </a>
    </div>

    <c:if test="${param.updated eq 'profile' || param.updated eq 'password'}">
        <p role="status" class="mb-6 rounded-xl border border-brand-100 bg-brand-50 p-4 text-sm font-medium text-status-success">
            <c:choose>
                <c:when test="${param.updated eq 'profile'}">Your username has been updated.</c:when>
                <c:otherwise>Your password has been changed.</c:otherwise>
            </c:choose>
        </p>
    </c:if>

    <div class="space-y-6">
        <section class="rounded-xl border border-border-default bg-surface-card p-4 sm:p-6 shadow-sm" aria-labelledby="profile-details-heading">
            <h2 id="profile-details-heading" class="text-xl font-bold text-text-primary">Profile details</h2>
            <p class="mt-1 text-sm text-text-secondary">Your email is linked to this account and cannot be changed here.</p>
            <div class="my-6 flex items-center gap-4">
                <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-brand-50 text-2xl font-bold uppercase text-brand-700" aria-hidden="true">
                    <c:out value="${fn:substring(profileUser.username, 0, 1)}" />
                </div>
                <div class="min-w-0">
                    <p class="font-semibold text-text-primary break-words"><c:out value="${profileUser.username}" /></p>
                    <p class="mt-1 text-sm text-text-secondary">Your initial is shown in place of a profile photo.</p>
                </div>
            </div>

            <c:if test="${not empty profileError}">
                <p role="alert" class="mb-5 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-status-danger"><c:out value="${profileError}" /></p>
            </c:if>
            <form action="${pageContext.request.contextPath}/account/profile" method="post">
                <input type="hidden" name="csrfToken" value="${fn:escapeXml(csrfToken)}">
                <div class="grid gap-4 sm:grid-cols-2">
                    <div>
                        <label for="account-username" class="mb-2 block text-sm font-semibold text-text-primary">Username</label>
                        <input id="account-username" name="username" type="text" minlength="3" maxlength="255" required autocomplete="username"
                               value="${fn:escapeXml(enteredUsername != null ? enteredUsername : profileUser.username)}"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                        <p class="mt-2 text-xs text-text-secondary">3–255 letters, numbers, dots, underscores, or hyphens.</p>
                    </div>
                    <div>
                        <label for="account-email" class="mb-2 block text-sm font-semibold text-text-primary">Email</label>
                        <input id="account-email" type="email" readonly aria-readonly="true" value="${fn:escapeXml(profileUser.email)}"
                               class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-secondary">
                        <p class="mt-2 text-xs text-text-secondary">Contact support if your email needs to change.</p>
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
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
