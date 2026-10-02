<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="min-h-screen bg-[#faf9f6] flex p-4 sm:p-6 lg:p-8">
    <!-- Left Section: Form -->
    <div class="w-full lg:w-1/2 flex flex-col pt-4">
        <!-- Logo -->
        <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-2 text-slate-900 mb-12 sm:ml-8">
            <i class="fa-solid fa-dolphin text-2xl text-emerald-500"></i>
            <span class="text-xl font-bold tracking-tight">LearnHub</span>
        </a>

        <!-- Form Container -->
        <div class="max-w-sm w-full mx-auto flex-grow flex flex-col justify-center pb-20">
            <h2 class="text-3xl font-bold text-slate-900 mb-2">Sign in to LearnHub</h2>
            <p class="text-sm text-slate-500 mb-8">
                Don't have an account? 
                <c:set var="regUrl" value="${pageContext.request.contextPath}/auth/register" />
                <c:if test="${not empty param.redirect_uri}">
                    <c:set var="regUrl" value="${regUrl}?redirect_uri=${param.redirect_uri}" />
                </c:if>
                <a href="${regUrl}" class="font-bold text-[#028446] hover:underline">Create account</a>
            </p>

            <c:if test="${not empty errorMessage}">
                <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm flex items-center">
                    <i class="fa-solid fa-circle-exclamation mr-3 text-rose-500"></i>
                    <span><c:out value="${errorMessage}" /></span>
                </div>
            </c:if>
            <c:if test="${not empty message}">
                <div class="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm flex items-center">
                    <i class="fa-solid fa-circle-check mr-3 text-emerald-500"></i>
                    <span>${message}</span>
                </div>
            </c:if>

            <c:url var="googleOAuthUrl" value="/auth/oauth/google"><c:if test="${not empty param.redirect_uri}"><c:param name="redirect_uri" value="${param.redirect_uri}" /></c:if></c:url>
            <c:url var="githubOAuthUrl" value="/auth/oauth/github"><c:if test="${not empty param.redirect_uri}"><c:param name="redirect_uri" value="${param.redirect_uri}" /></c:if></c:url>
            <a href="${googleOAuthUrl}" class="w-full mb-3 flex items-center justify-center space-x-2 py-2.5 border border-slate-300 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-600 transition-colors">
                <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" class="w-4 h-4">
                <span>Continue with Google</span>
            </a>
            <a href="${githubOAuthUrl}" class="w-full mb-6 flex items-center justify-center space-x-2 py-2.5 border border-slate-300 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-600 transition-colors">
                <i class="fa-brands fa-github text-base"></i>
                <span>Continue with GitHub</span>
            </a>

            <div class="relative flex items-center justify-center mb-6">
                <div class="absolute inset-x-0 border-t border-slate-200"></div>
                <span class="relative bg-[#faf9f6] px-4 text-xs text-slate-400 font-medium">or continue with email</span>
            </div>

            <form action="${pageContext.request.contextPath}/auth/login" method="post" class="space-y-4">
                <input type="hidden" name="redirect_uri" value="${param.redirect_uri}">
                <div>
                    <label for="email" class="block text-xs font-semibold text-slate-600 mb-1.5">Email or Username</label>
                    <input id="email" name="email" type="text" required value="${email != null ? email : param.email}" class="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition-all" placeholder="me@example.com">
                </div>

                <div class="relative">
                    <label for="password" class="block text-xs font-semibold text-slate-600 mb-1.5">Password</label>
                    <div class="relative">
                        <input id="password" name="password" type="password" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition-all pr-10" placeholder="Enter your password">
                        <button type="button" tabindex="-1" onclick="togglePassword()" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                            <i id="eyeIcon" class="fa-regular fa-eye"></i>
                        </button>
                    </div>
                    <a href="#" class="absolute top-0 right-0 text-xs font-medium text-slate-500 hover:text-slate-700 underline">Forgot Password?</a>
                </div>

                <button type="submit" class="w-full py-2.5 mt-2 text-sm font-bold text-white bg-[#028446] hover:bg-emerald-800 rounded-lg shadow-sm transition-colors">
                    Sign in
                </button>
            </form>

            <p class="text-center text-[11px] text-slate-500 mt-6">
                By continuing, you agree to our <a href="#" class="underline hover:text-slate-700">Terms</a> & <a href="#" class="underline hover:text-slate-700">Privacy Policy</a>.
            </p>
        </div>
    </div>

    <!-- Right Section: Graphic -->
    <div class="hidden lg:block lg:w-1/2 bg-[#0a0a0a] rounded-3xl relative overflow-hidden">
        <div class="absolute inset-0 flex items-center justify-center opacity-80">
            <img src="${pageContext.request.contextPath}/assets/images/auth-bg.png" alt="Authentication Graphic" class="w-full h-full object-cover">
        </div>
    </div>
</div>
<!-- Note: Intentionally not including footer or navbar for a clean auth page layout -->
<script>
    function togglePassword() {
        const passwordInput = document.getElementById('password');
        const eyeIcon = document.getElementById('eyeIcon');
        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            eyeIcon.classList.remove('fa-eye');
            eyeIcon.classList.add('fa-eye-slash');
        } else {
            passwordInput.type = 'password';
            eyeIcon.classList.remove('fa-eye-slash');
            eyeIcon.classList.add('fa-eye');
        }
    }
</script>
