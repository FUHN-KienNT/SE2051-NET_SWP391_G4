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
            <h1 class="mb-2 text-3xl font-bold text-text-primary">Verify your email</h1>
            <p class="mb-8 text-sm leading-relaxed text-text-secondary">
                Enter the 6-digit code sent to <strong class="font-semibold text-text-primary"><c:out value="${pendingEmail}" /></strong>.
                The code expires in 10 minutes.
            </p>

            <c:if test="${not empty errorMessage}">
                <div role="alert" class="mb-6 flex items-center rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-status-danger">
                    <i class="fa-solid fa-circle-exclamation mr-3" aria-hidden="true"></i>
                    <span><c:out value="${errorMessage}" /></span>
                </div>
            </c:if>
            <c:if test="${param.sent eq '1'}">
                <div role="status" class="mb-6 flex items-center rounded-xl border border-brand-100 bg-brand-50 p-4 text-sm text-status-success">
                    <i class="fa-solid fa-circle-check mr-3" aria-hidden="true"></i>
                    <span>Verification code sent. Check your inbox.</span>
                </div>
            </c:if>
            <c:if test="${param.wait eq '1'}">
                <div role="status" class="mb-6 rounded-xl border border-border-default bg-surface-card p-4 text-sm text-text-secondary">
                    Please wait 60 seconds before requesting another code.
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/verify-email" method="post" class="space-y-4">
                <div>
                    <label for="code" class="mb-1.5 block text-sm font-semibold text-text-primary">Verification code</label>
                    <input id="code" name="code" type="text" inputmode="numeric" autocomplete="one-time-code"
                           pattern="[0-9]{6}" maxlength="6" required autofocus
                           class="w-full rounded-lg border border-border-default bg-surface-card px-4 py-3 text-center text-xl font-semibold tracking-widest text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700"
                           placeholder="000000">
                </div>
                <button type="submit"
                        class="w-full rounded-lg bg-brand-700 py-3 text-sm font-bold text-white shadow-sm hover:bg-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    Verify and create account
                </button>
            </form>

            <form action="${pageContext.request.contextPath}/auth/resend-code" method="post" class="mt-6 text-center">
                <p class="text-sm text-text-secondary">Didn't receive the code?</p>
                <button type="submit"
                        class="mt-2 rounded-lg text-sm font-semibold text-brand-700 hover:text-brand-800 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    Send a new code
                </button>
            </form>
            <a href="${pageContext.request.contextPath}/auth/register"
               class="mt-6 self-center rounded-lg text-sm font-medium text-text-secondary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                Change registration details
            </a>
        </main>
    </div>
    <div class="relative hidden overflow-hidden rounded-3xl bg-surface-inverse lg:block lg:w-1/2">
        <img src="${pageContext.request.contextPath}/assets/images/auth-bg.png" alt=""
             class="h-full w-full object-cover">
    </div>
</div>
</body>
</html>
