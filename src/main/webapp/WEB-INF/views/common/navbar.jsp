<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="sticky top-0 z-50 bg-white border-b border-slate-200 shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
            <!-- Brand Logo -->
            <div class="flex items-center space-x-3">
                <a href="${pageContext.request.contextPath}/home" class="flex items-center space-x-2">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-brand-600 to-indigo-600 flex items-center justify-center text-white shadow-md shadow-brand-500/20">
                        <i class="fa-solid fa-graduation-cap text-xl"></i>
                    </div>
                    <span class="text-2xl font-black bg-gradient-to-r from-brand-600 to-indigo-600 bg-clip-text text-transparent">LearnHub</span>
                </a>
            </div>

            <!-- Main Navigation Links -->
            <nav class="hidden md:flex items-center space-x-8">
                <a href="${pageContext.request.contextPath}/home" class="text-sm font-semibold hover:text-brand-600 transition-colors">Trang chủ</a>
                <a href="${pageContext.request.contextPath}/courses" class="text-sm font-semibold hover:text-brand-600 transition-colors">Khóa học</a>
                <c:if test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/learning-process?action=dashboard" class="text-sm font-semibold hover:text-brand-600 transition-colors">Học tập</a>
                    <a href="${pageContext.request.contextPath}/enrollment?action=my-courses" class="text-sm font-semibold hover:text-brand-600 transition-colors">Khóa học của tôi</a>
                </c:if>
                <c:if test="${sessionScope.userRole eq 'admin' || sessionScope.userRole eq 'manager'}">
                    <div class="relative group">
                        <button class="text-sm font-semibold hover:text-brand-600 flex items-center space-x-1">
                            <span>Quản trị</span>
                            <i class="fa-solid fa-chevron-down text-xs"></i>
                        </button>
                        <div class="absolute left-0 mt-2 w-48 bg-white border border-slate-200 rounded-xl shadow-lg py-2 hidden group-hover:block transition-all">
                            <a href="${pageContext.request.contextPath}/admin/users" class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50">Quản lý người dùng</a>
                            <a href="${pageContext.request.contextPath}/content-review" class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50">Duyệt nội dung</a>
                        </div>
                    </div>
                </c:if>
            </nav>

            <!-- User Auth & CTA -->
            <div class="flex items-center space-x-4">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div class="relative group">
                            <button class="flex items-center space-x-3 text-sm focus:outline-none">
                                <div class="w-9 h-9 rounded-full bg-brand-100 text-brand-700 font-bold flex items-center justify-center border border-brand-200">
                                    ${fn:substring(sessionScope.user.username, 0, 1)}
                                </div>
                                <span class="hidden sm:inline font-semibold text-slate-700">${sessionScope.user.username}</span>
                                <i class="fa-solid fa-angle-down text-xs text-slate-400"></i>
                            </button>
                            <div class="absolute right-0 mt-2 w-56 bg-white border border-slate-200 rounded-xl shadow-xl py-2 hidden group-hover:block transition-all">
                                <div class="px-4 py-2 border-b border-slate-100">
                                    <p class="text-xs text-slate-400">Đăng nhập với</p>
                                    <p class="text-sm font-semibold text-slate-800 truncate">${sessionScope.user.email}</p>
                                </div>
                                <a href="${pageContext.request.contextPath}/admin/users?action=profile" class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50">
                                    <i class="fa-regular fa-user mr-2 text-slate-400"></i>Hồ sơ cá nhân
                                </a>
                                <a href="${pageContext.request.contextPath}/enrollment?action=my-courses" class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50">
                                    <i class="fa-solid fa-book-bookmark mr-2 text-slate-400"></i>Khóa học của tôi
                                </a>
                                <div class="border-t border-slate-100 my-1"></div>
                                <a href="${pageContext.request.contextPath}/auth?action=logout" class="block px-4 py-2 text-sm text-rose-600 hover:bg-rose-50 font-medium">
                                    <i class="fa-solid fa-arrow-right-from-bracket mr-2"></i>Đăng xuất
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/auth?action=login" class="text-sm font-semibold text-slate-700 hover:text-brand-600 transition-colors">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/auth?action=register" class="inline-flex items-center px-4 py-2 text-sm font-semibold text-white bg-brand-600 rounded-xl hover:bg-brand-700 transition shadow-sm shadow-brand-500/20">
                            Đăng ký ngay
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</header>
