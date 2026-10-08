<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<footer lang="en" class="mt-auto border-t border-border-default bg-surface-footer text-text-primary">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-10 py-12">
            <div>
                <a href="${pageContext.request.contextPath}/home" class="inline-block rounded-lg text-2xl font-bold tracking-tight text-brand-700 hover:text-brand-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2">
                    LearnHub
                </a>
                <p class="mt-4 max-w-sm text-sm leading-relaxed text-slate-600">
                    Find a course, build practical skills, and learn at your own pace.
                </p>
            </div>
            <nav aria-label="Footer navigation">
                <ul class="grid grid-cols-2 gap-x-8 gap-y-4 text-sm font-semibold sm:flex sm:flex-wrap sm:items-center">
                    <li><a href="${pageContext.request.contextPath}/home" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Home</a></li>
                    <li><a href="${pageContext.request.contextPath}/courses" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Courses</a></li>
                    <c:if test="${sessionScope.currentUser.roleCode eq 'ROLE_STUDENT'}">
                        <li><a href="${pageContext.request.contextPath}/my-enrollments" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">My courses</a></li>
                    </c:if>
                    <c:if test="${sessionScope.currentUser.roleCode eq 'ROLE_EXPERT'}">
                        <li><a href="${pageContext.request.contextPath}/expert/dashboard" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Dashboard</a></li>
                    </c:if>
                    <c:if test="${sessionScope.currentUser.roleCode eq 'ROLE_ADMIN'}">
                        <li><a href="${pageContext.request.contextPath}/admin/users" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Manage users</a></li>
                    </c:if>
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <li><a href="${pageContext.request.contextPath}/auth/logout" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Sign out</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/auth/login" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Sign in</a></li>
                            <li><a href="${pageContext.request.contextPath}/auth/register" class="rounded text-text-primary hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">Join LearnHub</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </nav>
        </div>
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 border-t border-slate-300 py-6 text-xs text-slate-600">
            <p>&copy; 2026 LearnHub. All rights reserved.</p>
            <p>Explore. Learn. Grow.</p>
        </div>
    </div>
</footer>
</body>
</html>
