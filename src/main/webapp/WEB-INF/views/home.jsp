<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<style>
    /* Custom styles for Coursera-like curves */
    .bg-coursera-hero {
        background-color: #fefce8; /* light yellow */
        background-image: radial-gradient(circle at 100% 0%, #fef08a 0%, transparent 50%),
                          radial-gradient(circle at 0% 100%, #fef08a 0%, transparent 50%);
    }
    .hide-scrollbar::-webkit-scrollbar {
        display: none;
    }
    .hide-scrollbar {
        -ms-overflow-style: none;
        scrollbar-width: none;
    }
</style>

<main class="flex-grow bg-slate-50 pb-12">
    <!-- Hero Section (Logged In style) -->
    <section class="bg-coursera-hero pt-8 pb-12 px-4 sm:px-6 lg:px-8 border-b border-slate-200">
        <div class="max-w-7xl mx-auto">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <p class="text-sm text-slate-800 mb-2 font-medium">
                        Welcome back, <span class="font-bold">${sessionScope.user.username}</span>. <span class="bg-yellow-200 px-2 py-0.5 rounded text-yellow-800 text-xs ml-2">Keep up the good work!</span>
                    </p>
                    <h1 class="text-2xl font-bold text-slate-900 mb-6 hover:underline cursor-pointer">Continue your learning journey</h1>
                </c:when>
                <c:otherwise>
                    <p class="text-sm text-slate-800 mb-2 font-medium">
                        Welcome to <span class="font-bold">LearnHub</span>.
                    </p>
                    <h1 class="text-2xl font-bold text-slate-900 mb-6 hover:underline cursor-pointer">Start learning today and reach your goals</h1>
                </c:otherwise>
            </c:choose>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Main "Up Next" Card -->
                <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden flex flex-col md:flex-row">
                    <div class="p-6 md:w-1/2 flex flex-col justify-center">
                        <h2 class="text-xl font-bold text-slate-900 mb-2">Up next: Explore our top courses</h2>
                        <p class="text-sm text-slate-500 mb-6">Video • 5 min</p>
                        <div>
                            <a href="${pageContext.request.contextPath}/courses" class="inline-block bg-blue-600 text-white font-semibold px-6 py-2 rounded hover:bg-blue-700 transition">
                                Resume Learning
                            </a>
                        </div>
                    </div>
                    <div class="md:w-1/2 bg-blue-50 relative flex items-center justify-center p-6 min-h-[200px] overflow-hidden">
                         <div class="absolute inset-0 bg-gradient-to-br from-blue-400 to-indigo-600 transform skew-x-12 scale-150 opacity-90"></div>
                         <h3 class="relative z-10 text-3xl font-bold text-white text-center leading-tight">LearnHub<br>E-Learning</h3>
                    </div>
                </div>

                <!-- Side Widgets -->
                <div class="flex flex-col gap-4">
                    <!-- Goals Widget -->
                    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                        <div class="flex justify-between items-center mb-3">
                            <h3 class="text-sm font-bold text-slate-900">Today's goals</h3>
                        </div>
                        <div class="flex items-start gap-3">
                            <div class="mt-1 w-6 h-6 rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
                                <i class="fa-solid fa-star text-xs"></i>
                            </div>
                            <div>
                                <a href="${pageContext.request.contextPath}/courses" class="text-sm font-semibold text-blue-600 hover:underline">Complete 1 learning item in LearnHub</a>
                                <p class="text-xs text-slate-500 mt-1">0/1</p>
                            </div>
                        </div>
                    </div>
                    <!-- Streak Widget -->
                    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                        <div class="flex justify-between items-center mb-2">
                            <h3 class="text-sm font-bold text-slate-900">3-week streak</h3>
                            <i class="fa-solid fa-circle-info text-slate-400 text-xs"></i>
                        </div>
                        <p class="text-xs text-slate-600 mb-3">6 days left to start your weekly streak!</p>
                        <div class="flex justify-between gap-1">
                            <div class="w-8 h-8 rounded border border-blue-200 bg-blue-50 text-blue-600 flex items-center justify-center text-xs font-semibold">Mo</div>
                            <div class="w-8 h-8 rounded border border-slate-200 text-slate-500 flex items-center justify-center text-xs font-medium">Tu</div>
                            <div class="w-8 h-8 rounded border border-slate-200 text-slate-500 flex items-center justify-center text-xs font-medium">We</div>
                            <div class="w-8 h-8 rounded border border-slate-200 text-slate-500 flex items-center justify-center text-xs font-medium">Th</div>
                            <div class="w-8 h-8 rounded border border-slate-200 text-slate-500 flex items-center justify-center text-xs font-medium">Fr</div>
                            <div class="w-8 h-8 rounded border border-slate-200 text-slate-500 flex items-center justify-center text-xs font-medium">Sa</div>
                            <div class="w-8 h-8 rounded border border-slate-200 text-slate-500 flex items-center justify-center text-xs font-medium">Su</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Skills Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
        <div class="bg-blue-50 rounded-xl p-4 flex flex-col md:flex-row items-center gap-4">
            <span class="text-sm font-bold text-slate-900 whitespace-nowrap">Select the skills you'd like to develop</span>
            <span class="text-xs text-slate-500">(These are recommended based on your profile)</span>
            <div class="flex-grow flex gap-2 overflow-x-auto pb-2 md:pb-0 hide-scrollbar w-full md:w-auto">
                <c:forEach var="cat" items="${categories}">
                    <div class="px-4 py-1.5 bg-slate-200/50 rounded-full text-xs font-medium text-slate-600 whitespace-nowrap cursor-pointer hover:bg-slate-200 transition">
                        ${cat.value}
                    </div>
                </c:forEach>
                <c:if test="${empty categories}">
                    <div class="px-4 py-1.5 bg-slate-200/50 rounded-full text-xs font-medium text-slate-600 whitespace-nowrap cursor-pointer hover:bg-slate-200 transition">Programming</div>
                    <div class="px-4 py-1.5 bg-slate-200/50 rounded-full text-xs font-medium text-slate-600 whitespace-nowrap cursor-pointer hover:bg-slate-200 transition">Data Analysis</div>
                    <div class="px-4 py-1.5 bg-slate-200/50 rounded-full text-xs font-medium text-slate-600 whitespace-nowrap cursor-pointer hover:bg-slate-200 transition">Design</div>
                </c:if>
            </div>
            <button class="text-xs font-semibold text-slate-400 hover:text-slate-600 md:ml-auto"><i class="fa-solid fa-xmark"></i></button>
        </div>
    </section>

    <!-- Featured Courses / In-demand skills -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-12 mb-16">
        <div class="flex items-center gap-2 mb-6">
            <h2 class="text-xl font-bold text-slate-900">In-demand skills for <span class="underline decoration-2 decoration-blue-500">LearnHub</span> learners</h2>
            <a href="#" class="text-xs font-semibold text-blue-600 hover:underline">Edit goal</a>
        </div>
        
        <!-- Filter chips -->
        <div class="flex gap-3 mb-6 overflow-x-auto pb-2 hide-scrollbar">
            <button class="px-4 py-1.5 bg-slate-800 text-white rounded-full text-sm font-medium whitespace-nowrap">All</button>
            <c:forEach var="cat" items="${categories}" end="4">
                <button class="px-4 py-1.5 bg-white border border-slate-300 text-slate-700 rounded-full text-sm font-medium hover:bg-slate-50 whitespace-nowrap">${cat.value}</button>
            </c:forEach>
            <c:if test="${empty categories}">
                <button class="px-4 py-1.5 bg-white border border-slate-300 text-slate-700 rounded-full text-sm font-medium hover:bg-slate-50 whitespace-nowrap">Python</button>
                <button class="px-4 py-1.5 bg-white border border-slate-300 text-slate-700 rounded-full text-sm font-medium hover:bg-slate-50 whitespace-nowrap">SQL</button>
            </c:if>
        </div>

        <!-- Course Cards Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <c:forEach var="c" items="${featuredCourses}">
                <div class="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-md transition flex flex-col group h-full">
                    <div class="relative h-40 overflow-hidden bg-slate-100 block">
                        <img src="${not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" alt="${c.title}" class="w-full h-full object-cover group-hover:scale-105 transition duration-500">
                    </div>
                    <div class="p-5 flex flex-col flex-grow">
                        <div class="flex items-center gap-2 mb-2">
                            <div class="w-5 h-5 bg-blue-100 text-blue-600 rounded flex items-center justify-center text-[10px]">
                                <i class="fa-solid fa-graduation-cap"></i>
                            </div>
                            <span class="text-xs text-slate-600 font-medium">LearnHub</span>
                        </div>
                        <h3 class="font-bold text-base text-slate-900 mb-1 line-clamp-2 min-h-[3rem]">
                            <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" class="hover:underline">${c.title}</a>
                        </h3>
                        <p class="text-xs text-slate-500 mb-3 line-clamp-2">Skills you'll gain: ${not empty c.description ? c.description : 'Explore comprehensive modules to master this topic.'}</p>
                        
                        <div class="mt-auto">
                            <div class="flex items-center gap-1 mb-2">
                                <i class="fa-solid fa-star text-amber-500 text-[10px]"></i>
                                <span class="text-xs font-bold text-slate-800">4.8</span>
                                <span class="text-xs text-slate-500">(12K reviews)</span>
                            </div>
                            <div class="flex gap-2 mb-4 flex-wrap">
                                <span class="bg-slate-100 text-slate-600 text-[10px] font-semibold px-2 py-0.5 rounded">Beginner</span>
                                <span class="bg-slate-100 text-slate-600 text-[10px] font-semibold px-2 py-0.5 rounded">Certificate</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" class="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded hover:bg-blue-700 transition w-full text-center">
                                    Enroll for free
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>

    <!-- Resume your exploration Section (Mini cards list) -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-8">
        <h2 class="text-lg font-bold text-slate-900 mb-4">Resume your exploration</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <!-- Recently viewed -->
            <div class="bg-blue-50/50 rounded-xl p-6 border border-blue-100/50">
                <h3 class="text-sm font-bold text-slate-900 mb-4">Recently viewed</h3>
                <div class="flex flex-col gap-3">
                    <c:forEach var="c" items="${featuredCourses}" end="2">
                        <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" class="bg-white rounded-lg p-3 flex gap-4 items-center shadow-sm border border-slate-100 hover:shadow transition group">
                            <img src="${not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" class="w-16 h-16 rounded object-cover">
                            <div>
                                <p class="text-[10px] text-slate-500 font-medium">LearnHub</p>
                                <h4 class="text-sm font-bold text-slate-900 line-clamp-1 group-hover:text-blue-600">${c.title}</h4>
                                <div class="flex items-center gap-1 mt-1">
                                    <span class="text-[10px] text-slate-500">Course</span>
                                    <span class="text-[10px] text-slate-300">•</span>
                                    <i class="fa-solid fa-star text-amber-500 text-[10px]"></i>
                                    <span class="text-[10px] font-bold text-slate-700">4.7</span>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </div>
            <!-- Similar to your activity -->
            <div class="bg-blue-50/50 rounded-xl p-6 border border-blue-100/50">
                <h3 class="text-sm font-bold text-slate-900 mb-4">Similar to your activity</h3>
                <div class="flex flex-col gap-3">
                    <c:forEach var="c" items="${featuredCourses}" begin="1" end="3">
                        <a href="${pageContext.request.contextPath}/courses?action=detail&id=${c.id}" class="bg-white rounded-lg p-3 flex gap-4 items-center shadow-sm border border-slate-100 hover:shadow transition group">
                            <img src="${not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" class="w-16 h-16 rounded object-cover">
                            <div>
                                <p class="text-[10px] text-slate-500 font-medium">LearnHub</p>
                                <h4 class="text-sm font-bold text-slate-900 line-clamp-1 group-hover:text-blue-600">${c.title}</h4>
                                <div class="flex items-center gap-1 mt-1">
                                    <span class="text-[10px] text-slate-500">Course</span>
                                    <span class="text-[10px] text-slate-300">•</span>
                                    <i class="fa-solid fa-star text-amber-500 text-[10px]"></i>
                                    <span class="text-[10px] font-bold text-slate-700">4.8</span>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </div>
    </section>

</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />