<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageLanguage" value="en" scope="request" />
<c:set var="pageTitle" value="Complete your profile - LearnHub" scope="request" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<main class="flex flex-grow items-center justify-center bg-surface px-4 py-12 sm:px-6">
    <div class="w-full max-w-md rounded-xl border border-border-default bg-surface-card p-6 shadow-sm sm:p-8">
        <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-2 rounded-lg text-xl font-bold text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
            <i class="fa-solid fa-dolphin" aria-hidden="true"></i> LearnHub
        </a>
        <h1 class="mt-8 text-2xl font-bold text-text-primary">Complete your profile</h1>
        <p class="mt-2 text-sm text-text-secondary">
            Add your full name to finish creating your account with <c:out value="${providerName}" />.
        </p>

        <c:if test="${not empty errorMessage}">
            <p role="alert" class="mt-6 rounded-lg border border-border-default bg-surface p-3 text-sm text-status-danger"><c:out value="${errorMessage}" /></p>
        </c:if>

        <form action="${pageContext.request.contextPath}/auth/oauth/complete-profile" method="post" class="mt-6 space-y-4">
            <input type="hidden" name="csrfToken" value="${fn:escapeXml(csrfToken)}">
            <div>
                <label for="fullName" class="mb-2 block text-sm font-semibold text-text-primary">Full name</label>
                <input id="fullName" name="fullName" type="text" required maxlength="255" autocomplete="name"
                       value="${fn:escapeXml(enteredFullName)}"
                       class="w-full rounded-lg border border-border-default bg-surface px-3 py-2.5 text-base text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
            </div>
            <button type="submit" class="w-full rounded-lg bg-brand-700 px-5 py-2.5 text-sm font-semibold text-white hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                Create account
            </button>
        </form>
    </div>
</main>
</body>
</html>
