<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="flex min-h-screen bg-surface p-4 sm:p-6 lg:p-8">
    <div class="flex w-full flex-col pt-4 lg:w-1/2">
        <a href="${pageContext.request.contextPath}/home"
           class="mb-12 flex items-center space-x-2 rounded-lg text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 sm:ml-8">
            <i class="fa-solid fa-dolphin text-2xl text-brand-500" aria-hidden="true"></i>
            <span class="text-xl font-bold tracking-tight">LearnHub</span>
        </a>

        <main class="mx-auto flex w-full max-w-sm flex-grow flex-col justify-center pb-20">
            <h1 class="mb-2 text-3xl font-bold text-text-primary">Create new password</h1>
            <p class="mb-8 text-sm leading-relaxed text-text-secondary">
                Your new password must be at least 8 characters.
            </p>

            <c:if test="${not empty errorMessage}">
                <div role="alert" class="mb-6 flex items-center rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-status-danger">
                    <i class="fa-solid fa-circle-exclamation mr-3" aria-hidden="true"></i>
                    <span><c:out value="${errorMessage}" /></span>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/reset-password" method="post" class="space-y-4">
                <div>
                    <label for="password" class="mb-1.5 block text-sm font-semibold text-text-primary">New password</label>
                    <input id="password" name="password" type="password" required
                           minlength="8" maxlength="72"
                           class="w-full rounded-lg border border-border-default bg-surface-card px-4 py-2.5 text-text-primary placeholder:text-text-secondary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700"
                           placeholder="••••••••">
                </div>
                
                <div>
                    <label for="confirmPassword" class="mb-1.5 block text-sm font-semibold text-text-primary">Confirm new password</label>
                    <input id="confirmPassword" name="confirmPassword" type="password" required
                           minlength="8" maxlength="72"
                           class="w-full rounded-lg border border-border-default bg-surface-card px-4 py-2.5 text-text-primary placeholder:text-text-secondary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700"
                           placeholder="••••••••">
                </div>
                
                <button type="submit"
                        class="w-full rounded-lg bg-brand-700 py-3 text-sm font-bold text-white shadow-sm hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    Reset password
                </button>
            </form>

        </main>
    </div>
    <div class="relative hidden overflow-hidden rounded-3xl bg-surface-inverse lg:block lg:w-1/2">
        <img src="${pageContext.request.contextPath}/assets/images/auth-bg.png" alt=""
             class="h-full w-full object-cover">
    </div>
</div>
</body>
</html>
