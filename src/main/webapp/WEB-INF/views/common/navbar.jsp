<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<header class="sticky top-4 z-50 w-full px-4 sm:px-6 lg:px-8 max-w-[1600px] mx-auto">
    <div class="bg-white rounded-full shadow-[0_2px_15px_-3px_rgba(0,0,0,0.07),0_10px_20px_-2px_rgba(0,0,0,0.04)] border border-slate-100 px-6 h-14 flex items-center justify-between">
        <!-- Brand Logo -->
        <div class="flex items-center space-x-6">
            <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-2 mr-4">
                <i class="fa-solid fa-dolphin text-2xl text-emerald-500"></i>
                <span class="text-xl font-bold text-slate-800 tracking-tight">LearnHub</span>
            </a>
            
            <!-- Main Navigation Links -->
            <nav class="hidden md:flex items-center space-x-6">
                <a href="${pageContext.request.contextPath}/home" class="text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors">Home</a>
                <a href="${pageContext.request.contextPath}/courses" class="text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors flex items-center">
                    Courses <i class="fa-solid fa-chevron-down text-[10px] ml-1.5 opacity-60"></i>
                </a>
                <c:if test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/learning-process?action=dashboard" class="text-sm font-medium text-emerald-600 hover:text-emerald-700 transition-colors">Dashboard</a>
                    <a href="${pageContext.request.contextPath}/enrollment?action=my-courses" class="text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors">My Courses</a>
                </c:if>
                <c:if test="${sessionScope.userRole eq 'admin' || sessionScope.userRole eq 'manager'}">
                    <div class="relative group">
                        <button class="text-sm font-medium text-slate-500 hover:text-slate-800 flex items-center">
                            <span>Admin</span>
                            <i class="fa-solid fa-chevron-down text-[10px] ml-1.5 opacity-60"></i>
                        </button>
                        <div class="absolute left-0 mt-4 w-48 bg-white border border-slate-100 rounded-2xl shadow-xl py-2 hidden group-hover:block transition-all z-50">
                            <a href="${pageContext.request.contextPath}/admin/users" class="block px-4 py-2 text-sm text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-colors">Manage Users</a>
                        </div>
                    </div>
                </c:if>
            </nav>
        </div>

        <!-- User Auth & CTA -->
        <div class="flex items-center space-x-4">
            <button class="text-slate-400 hover:text-slate-600 hidden sm:block transition-colors"><i class="fa-solid fa-bullhorn"></i></button>

            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <div class="relative group ml-2">
                        <button class="flex items-center space-x-2 text-sm focus:outline-none bg-slate-50 hover:bg-slate-100 pl-2 pr-3 py-1 rounded-full border border-slate-200 transition-colors">
                            <div class="w-7 h-7 rounded-full bg-emerald-100 text-emerald-700 font-bold flex items-center justify-center text-xs">
                                ${fn:substring(sessionScope.user.username, 0, 1)}
                            </div>
                            <span class="hidden sm:inline font-semibold text-slate-700">${sessionScope.user.username}</span>
                        </button>
                        <div class="absolute right-0 mt-3 w-56 bg-white border border-slate-100 rounded-2xl shadow-xl py-2 hidden group-hover:block transition-all z-50">
                            <div class="px-4 py-3 border-b border-slate-50">
                                <p class="text-xs text-slate-400 font-medium">Signed in as</p>
                                <p class="text-sm font-semibold text-slate-800 truncate">${sessionScope.user.email}</span></p>
                            </div>
                            <a href="${pageContext.request.contextPath}/admin/users?action=profile" class="block px-4 py-2 text-sm text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-colors">
                                <i class="fa-regular fa-user w-5 text-slate-400"></i>Profile
                            </a>
                            <a href="${pageContext.request.contextPath}/enrollment?action=my-courses" class="block px-4 py-2 text-sm text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-colors">
                                <i class="fa-solid fa-book-bookmark w-5 text-slate-400"></i>My Courses
                            </a>
                            <div class="border-t border-slate-50 my-1"></div>
                            <a href="${pageContext.request.contextPath}/auth/logout" class="block px-4 py-2 text-sm text-rose-600 hover:bg-rose-50 font-medium transition-colors">
                                <i class="fa-solid fa-arrow-right-from-bracket w-5"></i>Sign out
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <%
                        String uri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
                        if (uri == null) uri = request.getRequestURI();
                        String q = (String) request.getAttribute("jakarta.servlet.forward.query_string");
                        if (q == null) q = request.getQueryString();
                        
                        String authQuery = "";
                        // Prevents infinite nesting by just retaining the original redirect_uri if we are on an auth page
                        if (uri != null && uri.contains("/auth/")) {
                            String existing = request.getParameter("redirect_uri");
                            if (existing != null && !existing.trim().isEmpty()) {
                                authQuery = "?redirect_uri=" + java.net.URLEncoder.encode(existing, "UTF-8");
                            }
                        } else {
                            String rUrl = uri + (q != null && !q.isEmpty() ? "?" + q : "");
                            authQuery = "?redirect_uri=" + java.net.URLEncoder.encode(rUrl, "UTF-8");
                        }
                        request.setAttribute("authQuery", authQuery);
                    %>
                    <div class="ml-2 flex space-x-2">
                        <a href="${pageContext.request.contextPath}/auth/login${authQuery}" class="px-5 py-2 text-sm font-semibold text-white bg-[#028446] rounded-full hover:bg-emerald-800 transition-colors">
                            Sign in
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>
