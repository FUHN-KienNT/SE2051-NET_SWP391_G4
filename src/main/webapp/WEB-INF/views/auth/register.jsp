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
            <h2 class="text-3xl font-bold text-slate-900 mb-2">Create an account</h2>
            <p class="text-sm text-slate-500 mb-8">
                Already have an account? 
                <c:set var="loginUrl" value="${pageContext.request.contextPath}/auth/login" />
                <c:if test="${not empty param.redirect_uri}">
                    <c:set var="loginUrl" value="${loginUrl}?redirect_uri=${param.redirect_uri}" />
                </c:if>
                <a href="${loginUrl}" class="font-bold text-[#028446] hover:underline">Sign in</a>
            </p>

            <c:if test="${not empty errorMessage}">
                <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm flex items-center">
                    <i class="fa-solid fa-circle-exclamation mr-3 text-rose-500"></i>
                    <span>${errorMessage}</span>
                </div>
            </c:if>

            <button type="button" class="w-full mb-3 flex items-center justify-center space-x-2 py-2.5 border border-slate-300 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-50 transition-colors">
                <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" class="w-4 h-4">
                <span>Sign up with Google</span>
            </button>
            <button type="button" class="w-full mb-6 flex items-center justify-center space-x-2 py-2.5 border border-slate-300 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-50 transition-colors">
                <i class="fa-brands fa-github text-base"></i>
                <span>Sign up with GitHub</span>
            </button>

            <div class="relative flex items-center justify-center mb-6">
                <div class="absolute inset-x-0 border-t border-slate-200"></div>
                <span class="relative bg-[#faf9f6] px-4 text-xs text-slate-400 font-medium">or continue with email</span>
            </div>

            <form action="${pageContext.request.contextPath}/auth/register" method="post" class="space-y-4">
                <input type="hidden" name="redirect_uri" value="${param.redirect_uri}">
                <div>
                    <label for="username" class="block text-xs font-semibold text-slate-600 mb-1.5">Username</label>
                    <input id="username" name="username" type="text" required value="${username != null ? username : param.username}" class="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition-all" placeholder="John Doe">
                </div>
                
                <div>
                    <label for="email" class="block text-xs font-semibold text-slate-600 mb-1.5">Email</label>
                    <input id="email" name="email" type="email" required value="${email != null ? email : param.email}" class="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition-all" placeholder="me@example.com">
                </div>

                <div>
                    <label for="password" class="block text-xs font-semibold text-slate-600 mb-1.5">Password</label>
                    <div class="relative">
                        <input id="password" name="password" type="password" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition-all pr-10" placeholder="Create a password">
                        <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                            <i class="fa-regular fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div>
                    <label for="confirmPassword" class="block text-xs font-semibold text-slate-600 mb-1.5">Confirm Password</label>
                    <div class="relative">
                        <input id="confirmPassword" name="confirmPassword" type="password" required class="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition-all pr-10" placeholder="Confirm your password">
                        <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                            <i class="fa-regular fa-eye"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" class="w-full py-2.5 mt-2 text-sm font-bold text-white bg-[#028446] hover:bg-emerald-800 rounded-lg shadow-sm transition-colors">
                    Create account
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
            <div class="w-96 h-96 bg-gradient-to-br from-indigo-900/40 via-transparent to-transparent rounded-full blur-3xl absolute -top-20 -left-20"></div>
            <div class="w-96 h-96 bg-gradient-to-tl from-purple-900/40 via-transparent to-transparent rounded-full blur-3xl absolute -bottom-20 -right-20"></div>
            
            <!-- Central shape simulating the particle swirl -->
            <div class="w-80 h-80 border-[0.5px] border-indigo-900/30 rounded-full flex items-center justify-center relative -rotate-45">
                <div class="w-64 h-64 border-[0.5px] border-indigo-800/30 rounded-full flex items-center justify-center">
                    <div class="w-48 h-48 border-[1px] border-indigo-700/30 rounded-full flex items-center justify-center border-dashed">
                        <div class="w-32 h-32 bg-gradient-to-bl from-indigo-800/40 to-transparent rounded-full blur-md"></div>
                    </div>
                </div>
                <div class="absolute bottom-10 right-20 w-1 h-1 bg-indigo-400 rounded-full opacity-50 blur-[1px]"></div>
                <div class="absolute top-20 left-10 w-1 h-1 bg-indigo-500 rounded-full opacity-70 blur-[1px]"></div>
                <div class="absolute bottom-1/2 left-1/4 w-1.5 h-1.5 bg-indigo-300 rounded-full opacity-80 blur-[2px]"></div>
            </div>
        </div>
    </div>
</div>
<!-- Note: Intentionally not including footer or navbar for a clean auth page layout -->
