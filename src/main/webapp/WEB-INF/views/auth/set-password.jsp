<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageLanguage" value="en" scope="request" />
<c:set var="pageTitle" value="Set your password - LearnHub" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<main class="flex flex-grow items-center justify-center px-4 py-12 sm:px-6">
    <div class="w-full max-w-md rounded-xl border border-border-default bg-surface-card p-6 shadow-sm sm:p-8">
        <div class="inline-flex items-center gap-2 text-xl font-bold text-brand-700">
            <i class="fa-solid fa-dolphin" aria-hidden="true"></i> LearnHub
        </div>
        <h1 class="mt-8 text-2xl font-bold text-text-primary">Set your password</h1>
        <p class="mt-2 text-sm leading-relaxed text-text-secondary">
            Your Google account is connected. Create a LearnHub password to finish setting up your account.
        </p>

        <c:if test="${not empty passwordError}">
            <p role="alert" class="mt-6 rounded-lg border border-border-default bg-surface p-3 text-sm text-status-danger"><c:out value="${passwordError}" /></p>
        </c:if>

        <form action="${pageContext.request.contextPath}/account/set-password" method="post" class="mt-6 space-y-4">
            <input type="hidden" name="csrfToken" value="${fn:escapeXml(csrfToken)}">
            <div>
                <label for="newPassword" class="mb-2 block text-sm font-semibold text-text-primary">New password</label>
                <input id="newPassword" name="newPassword" type="password" required minlength="8" autocomplete="new-password"
                       aria-describedby="passwordHelp"
                       class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                <p id="passwordHelp" class="mt-2 text-xs text-text-secondary">At least 8 characters, at most 72 bytes.</p>
            </div>
            <div>
                <label for="confirmPassword" class="mb-2 block text-sm font-semibold text-text-primary">Confirm new password</label>
                <input id="confirmPassword" name="confirmPassword" type="password" required autocomplete="new-password"
                       class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
            </div>
            <button type="submit" class="w-full rounded-lg bg-brand-700 px-5 py-2.5 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                Save password and continue
            </button>
        </form>
        <a href="${pageContext.request.contextPath}/auth/logout" class="mt-6 inline-block rounded-lg text-sm font-semibold text-brand-700 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Sign out</a>
    </div>
</main>
</body>
</html>
