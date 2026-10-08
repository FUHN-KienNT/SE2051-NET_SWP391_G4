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
                    Courses
                </a>
               <c:if test="${not empty sessionScope.currentUser}">
                   <c:choose>
                       <c:when test="${sessionScope.currentUser.roleCode eq 'ROLE_ADMIN'
                                      || sessionScope.currentUser.roleCode eq 'ROLE_MANAGER'}">
                           <a href="${pageContext.request.contextPath}/admin/dashboard"
                              class="text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors">
                               Dashboard
                           </a>
                       </c:when>

                       <c:when test="${sessionScope.currentUser.roleCode eq 'ROLE_EXPERT'}">
                           <a href="${pageContext.request.contextPath}/expert/dashboard"
                              class="text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors">
                               Dashboard
                           </a>
                       </c:when>

                       <c:when test="${sessionScope.currentUser.roleCode eq 'ROLE_STUDENT'}">
                           <a href="${pageContext.request.contextPath}/my-enrollments"
                              class="text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors">
                               My Courses
                           </a>
                       </c:when>
                   </c:choose>
               </c:if>
            </nav>
        </div>

        <!-- User Auth & CTA -->
        <div class="flex items-center space-x-4">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <button type="button" id="notificationButton"
                            class="relative flex h-9 w-9 items-center justify-center rounded-lg text-text-secondary hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700"
                            aria-label="Mở thông báo" aria-expanded="false" aria-controls="notificationPanel">
                        <i class="fa-regular fa-bell" aria-hidden="true"></i>
                        <span id="notificationUnreadDot" class="hidden absolute right-1 top-1 h-2 w-2 rounded-full bg-status-success" aria-hidden="true"></span>
                    </button>
                    <div class="relative ml-2" id="userMenuDropdown">
                        <button type="button" id="userMenuBtn" class="flex items-center justify-center w-9 h-9 rounded-full border border-brand-700 bg-brand-50 text-brand-700 hover:bg-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2" aria-label="Account menu" aria-expanded="false" aria-haspopup="true" aria-controls="userMenuPanel">
                            <span class="text-brand-700 font-bold text-sm uppercase select-none">
                                <c:out value="${fn:substring(sessionScope.currentUser.username, 0, 1)}" />
                            </span>
                        </button>
                        <div id="userMenuPanel" class="absolute right-0 mt-2 w-56 bg-white border border-slate-100 rounded-2xl shadow-xl py-2 z-50 transition-all duration-200 ease-out opacity-0 invisible translate-y-1 pointer-events-none before:content-[''] before:absolute before:-top-3 before:left-0 before:right-0 before:h-3">
                            <div class="px-4 py-3 border-b border-slate-50">
                                <p class="text-xs text-slate-400 font-medium">Signed in as</p>
                                <p class="text-sm font-semibold text-slate-800 truncate"><c:out value="${sessionScope.currentUser.email}" /></p>
                            </div>
                            <a href="${pageContext.request.contextPath}/profile" class="block px-4 py-2 text-sm text-slate-600 hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                <i class="fa-regular fa-user w-5 text-slate-400"></i>Profile
                            </a>
                            <a href="${pageContext.request.contextPath}/account" class="block px-4 py-2 text-sm text-slate-600 hover:bg-brand-50 hover:text-brand-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                <i class="fa-solid fa-gear w-5 text-slate-400"></i>Account
                            </a>
                            <c:if test="${sessionScope.currentUser.roleCode eq 'ROLE_STUDENT'}">
                                <a href="${pageContext.request.contextPath}/my-enrollments"
                                   class="block px-4 py-2 text-sm text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-colors">
                                    <i class="fa-solid fa-book-bookmark w-5 text-slate-400"></i>My Courses
                                </a>
                            </c:if>
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
    <c:if test="${not empty sessionScope.currentUser}">
        <section id="notificationPanel" data-notification-url="${pageContext.request.contextPath}/notifications"
                 class="hidden absolute left-4 right-4 top-full mt-2 overflow-hidden rounded-2xl border border-border-default bg-surface-card shadow-xl sm:left-auto sm:right-20 sm:w-96"
                 aria-labelledby="notificationHeading" tabindex="-1">
            <div class="flex items-center justify-between gap-4 border-b border-border-default px-4 py-4">
                <h2 id="notificationHeading" class="text-base font-semibold text-text-primary">Thông báo</h2>
                <button type="button" id="notificationReadAll" disabled
                        class="inline-flex items-center gap-2 rounded-lg px-2 py-1 text-sm font-medium text-text-secondary hover:bg-brand-50 hover:text-brand-700 disabled:cursor-not-allowed disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                    <i class="fa-solid fa-check-double" aria-hidden="true"></i>
                    Đọc hết
                </button>
            </div>
            <div class="max-h-96 overflow-y-auto bg-brand-50">
                <p id="notificationStatus" class="hidden px-4 py-6 text-sm text-text-secondary" role="status" aria-live="polite"></p>
                <button type="button" id="notificationRetry"
                        class="hidden mx-4 mb-4 rounded-lg px-3 py-2 text-sm font-semibold text-brand-700 hover:bg-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                    Thử lại
                </button>
                <ul id="notificationList" aria-label="Danh sách thông báo"></ul>
                <p id="notificationLimitNote" class="hidden border-t border-brand-100 px-4 py-3 text-xs text-text-secondary">Hiển thị 20 thông báo gần nhất.</p>
            </div>
        </section>
    </c:if>
</header>

<script>
    (function() {
        const dropdown = document.getElementById('userMenuDropdown');
        const btn = document.getElementById('userMenuBtn');
        const panel = document.getElementById('userMenuPanel');
        if (!dropdown || !btn || !panel) return;

        let closeTimeout = null;

        function openMenu() {
            if (closeTimeout) {
                clearTimeout(closeTimeout);
                closeTimeout = null;
            }
            panel.classList.remove('opacity-0', 'invisible', 'translate-y-1', 'pointer-events-none');
            panel.classList.add('opacity-100', 'visible', 'translate-y-0', 'pointer-events-auto');
            btn.setAttribute('aria-expanded', 'true');
        }

        function closeMenu() {
            panel.classList.remove('opacity-100', 'visible', 'translate-y-0', 'pointer-events-auto');
            panel.classList.add('opacity-0', 'invisible', 'translate-y-1', 'pointer-events-none');
            btn.setAttribute('aria-expanded', 'false');
        }

        function scheduleClose() {
            if (closeTimeout) clearTimeout(closeTimeout);
            closeTimeout = setTimeout(function() {
                closeMenu();
            }, 300);
        }

        dropdown.addEventListener('mouseenter', openMenu);
        dropdown.addEventListener('mouseleave', scheduleClose);

        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            const isOpen = panel.classList.contains('opacity-100');
            if (isOpen) {
                closeMenu();
            } else {
                openMenu();
            }
        });

        document.addEventListener('click', function(e) {
            if (!dropdown.contains(e.target)) {
                closeMenu();
            }
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && panel.classList.contains('opacity-100')) {
                closeMenu();
                btn.focus();
            }
        });
    })();
</script>
<c:if test="${not empty sessionScope.currentUser}">
    <script src="${pageContext.request.contextPath}/assets/js/notifications.js" defer></script>
</c:if>
