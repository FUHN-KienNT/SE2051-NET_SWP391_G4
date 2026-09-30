<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<style>
    .hide-scrollbar::-webkit-scrollbar {
        display: none;
    }
    .hide-scrollbar {
        -ms-overflow-style: none;
        scrollbar-width: none;
    }
    /* Coursera-style dark gradient */
    .bg-coursera-dark {
        background: linear-gradient(135deg, #00255d 0%, #001530 100%);
    }
    /* Coursera-style light gradient */
    .bg-coursera-light {
        background: linear-gradient(135deg, #f0f7ff 0%, #fff 100%);
    }
</style>

<main class="flex-grow bg-white pb-16">
    <!-- Hero Section (Logged-out style) -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 pb-12">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Left Banner (Dark) -->
            <div class="bg-coursera-dark rounded-2xl p-8 md:p-12 text-white flex flex-col justify-center relative overflow-hidden h-80">
                <div class="relative z-10 max-w-md">
                    <h1 class="text-3xl md:text-4xl font-bold mb-4 leading-tight">Learn from the experts. Build your skills.</h1>
                    <p class="text-sm md:text-base text-blue-100 mb-8">Access high-quality courses and start learning at your own pace today.</p>
                    <a href="${pageContext.request.contextPath}/courses" class="inline-block bg-white text-blue-700 font-bold px-6 py-3 rounded hover:bg-blue-50 transition shadow-sm">
                        Explore courses
                    </a>
                </div>
                <!-- Decorative element -->
                <div class="absolute -bottom-10 -right-10 w-64 h-64 bg-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-50"></div>
            </div>
            
            <!-- Right Banner (Light) -->
            <div class="bg-coursera-light rounded-2xl p-8 md:p-12 flex flex-col justify-center border border-blue-100 relative overflow-hidden h-80">
                <div class="relative z-10 max-w-sm">
                    <h2 class="text-2xl md:text-3xl font-bold text-slate-900 mb-4 leading-tight">Jumpstart your career path</h2>
                    <p class="text-sm md:text-base text-slate-600 mb-8">Discover structured learning modules and gain real-world knowledge.</p>
                    <a href="${pageContext.request.contextPath}/register" class="inline-block bg-blue-600 text-white font-bold px-6 py-3 rounded hover:bg-blue-700 transition shadow-sm">
                        Join for free
                    </a>
                </div>
                <!-- Decorative element -->
                <div class="absolute top-10 -right-10 w-48 h-48 bg-blue-200 rounded-full mix-blend-multiply filter blur-3xl opacity-50"></div>
            </div>
        </div>
    </section>

    <!-- Logos Strip -->
    <section class="border-y border-slate-100 bg-slate-50 py-8 mb-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p class="text-sm font-semibold text-slate-500 mb-6 uppercase tracking-wider">Learn with top industry experts</p>
            <div class="flex flex-wrap justify-center items-center gap-8 md:gap-16 opacity-60">
                <div class="flex items-center gap-2 font-bold text-xl text-slate-800"><i class="fa-solid fa-code text-2xl"></i> TechEdu</div>
                <div class="flex items-center gap-2 font-bold text-xl text-slate-800"><i class="fa-solid fa-chart-line text-2xl"></i> BizLearn</div>
                <div class="flex items-center gap-2 font-bold text-xl text-slate-800"><i class="fa-solid fa-pen-nib text-2xl"></i> DesignPro</div>
                <div class="flex items-center gap-2 font-bold text-xl text-slate-800"><i class="fa-solid fa-language text-2xl"></i> LinguaAcademy</div>
                <div class="flex items-center gap-2 font-bold text-xl text-slate-800"><i class="fa-solid fa-robot text-2xl"></i> AILabs</div>
            </div>
        </div>
    </section>

    <!-- Explore by Category Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-20">
        <h2 class="text-2xl font-bold text-slate-900 mb-6">Explore LearnHub categories</h2>
        
        <!-- Category Tabs -->
        <div class="flex gap-3 mb-8 overflow-x-auto pb-2 hide-scrollbar">
            <button class="px-5 py-2 bg-blue-700 text-white rounded-full text-sm font-bold whitespace-nowrap shadow-md">Popular</button>
            <c:forEach var="cat" items="${categories}">
                <button class="px-5 py-2 bg-white border border-slate-300 text-slate-700 rounded-full text-sm font-semibold hover:bg-slate-50 whitespace-nowrap transition">${cat.name}</button>
            </c:forEach>
        </div>

        <!-- Layout: Left Panel + Right Grid -->
        <div class="flex flex-col lg:flex-row gap-6">
            <!-- Left Panel (Launch Career) -->
            <div class="lg:w-1/4">
                <div class="bg-blue-600 rounded-2xl p-8 text-white h-full flex flex-col relative overflow-hidden shadow-lg">
                    <div class="relative z-10">
                        <h3 class="text-2xl font-bold mb-4 leading-tight">Master new skills<br>in 3 months</h3>
                        <p class="text-blue-100 text-sm mb-8">Follow expert-led modules to reach your learning goals.</p>
                        <a href="${pageContext.request.contextPath}/courses" class="inline-flex items-center text-sm font-bold bg-white text-blue-700 px-4 py-2 rounded hover:bg-blue-50 transition">
                            Explore more <i class="fa-solid fa-arrow-right ml-2"></i>
                        </a>
                    </div>
                    <!-- Decorative abstract shapes -->
                    <div class="absolute -bottom-12 -right-12 w-48 h-48 bg-white opacity-10 rounded-full"></div>
                    <div class="absolute top-12 -right-6 w-24 h-24 bg-blue-400 opacity-30 rounded-full"></div>
                </div>
            </div>
            
            <!-- Right Grid (Course Cards adapted to Schema) -->
            <div class="lg:w-3/4">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <c:forEach var="c" items="${featuredCourses}">
                        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden hover:shadow-xl transition-all duration-300 flex flex-col group h-full relative cursor-pointer" onclick="window.location.href='${pageContext.request.contextPath}/courses?action=detail&id=${c.id}'">
                            <!-- Image -->
                            <div class="relative h-44 overflow-hidden bg-slate-100 border-b border-slate-100">
                                <img src="${not empty c.thumbnail ? c.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'}" alt="${c.title}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500">
                            </div>
                            
                            <div class="p-5 flex flex-col flex-grow">
                                <!-- Expert / Provider -->
                                <div class="flex items-center gap-2 mb-3">
                                    <div class="w-6 h-6 bg-blue-100 text-blue-600 rounded flex items-center justify-center text-[10px]">
                                        <i class="fa-solid fa-user-tie"></i>
                                    </div>
                                    <span class="text-xs text-slate-500 font-semibold uppercase tracking-wider">${not empty c.expertName ? c.expertName : 'LearnHub Expert'}</span>
                                </div>
                                
                                <!-- Title -->
                                <h3 class="font-bold text-lg text-slate-900 mb-2 leading-tight group-hover:text-blue-600 transition-colors line-clamp-2">
                                    ${c.title}
                                </h3>
                                
                                <!-- Subtitle (Adapted to DB: modules/lessons instead of reviews) -->
                                <p class="text-sm text-slate-500 mb-4 line-clamp-2">
                                    <i class="fa-solid fa-book-open text-slate-400 mr-1"></i> ${c.moduleCount} modules &nbsp;&bull;&nbsp; ${c.lessonCount} lessons
                                </p>
                                
                                <div class="mt-auto">
                                    <!-- DB Adapted Tags -->
                                    <div class="flex gap-2 mb-4 flex-wrap">
                                        <span class="bg-blue-50 border border-blue-100 text-blue-700 text-xs font-semibold px-2.5 py-1 rounded-sm">${c.categoryName}</span>
                                    </div>
                                    
                                    <div class="border-t border-slate-100 pt-4 mt-2 flex items-center justify-between">
                                        <!-- Price (Adapted to DB) -->
                                        <div class="text-lg font-black text-slate-900">
                                            <c:choose>
                                                <c:when test="${c.price <= 0}"><span class="text-emerald-600">Free</span></c:when>
                                                <c:otherwise><fmt:formatNumber value="${c.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </section>

    <!-- Mid-page Banner -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-20">
        <div class="bg-blue-50 border border-blue-100 rounded-2xl p-8 flex flex-col md:flex-row items-center justify-between shadow-sm">
            <div>
                <h2 class="text-2xl font-bold text-slate-900 mb-2">Enhance your professional portfolio</h2>
                <p class="text-slate-600 max-w-xl">Complete courses, take quizzes, and track your learning progress seamlessly with our platform.</p>
            </div>
            <div class="mt-6 md:mt-0">
                <a href="${pageContext.request.contextPath}/register" class="inline-block bg-slate-900 text-white font-bold px-8 py-3 rounded hover:bg-slate-800 transition">
                    Start Learning
                </a>
            </div>
        </div>
    </section>

    <!-- Marketing / Stats Banner (Adapted Testimonial substitute) -->
    <section class="bg-coursera-dark py-16 mb-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row items-center justify-between">
            <div class="md:w-2/3">
                <h2 class="text-3xl font-bold text-white mb-4">91% of LearnHub learners</h2>
                <p class="text-xl text-blue-200 leading-relaxed">report gaining valuable skills and confidence to tackle new challenges in their career after completing a course.</p>
                <a href="${pageContext.request.contextPath}/courses" class="inline-block mt-6 text-white font-bold border border-white px-6 py-2 rounded hover:bg-white hover:text-blue-900 transition">
                    View all courses
                </a>
            </div>
            <div class="md:w-1/3 flex justify-center mt-8 md:mt-0">
                <!-- Large decorative stat circle -->
                <div class="w-48 h-48 rounded-full border-8 border-emerald-400 border-t-transparent border-l-transparent transform rotate-45 flex items-center justify-center relative">
                    <div class="transform -rotate-45 text-white font-black text-5xl">91%</div>
                    <div class="absolute inset-0 rounded-full border-8 border-blue-400 opacity-30"></div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section (Replaces avatar testimonials) -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-16">
        <h2 class="text-2xl font-bold text-slate-900 mb-10 text-center">Why learn on LearnHub?</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="text-center px-4">
                <div class="w-16 h-16 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-2xl mx-auto mb-4">
                    <i class="fa-solid fa-laptop-code"></i>
                </div>
                <h3 class="font-bold text-lg text-slate-900 mb-2">Learn anything</h3>
                <p class="text-slate-600 text-sm">Explore courses in programming, marketing, design, and more taught by experts.</p>
            </div>
            <div class="text-center px-4">
                <div class="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center text-2xl mx-auto mb-4">
                    <i class="fa-solid fa-wallet"></i>
                </div>
                <h3 class="font-bold text-lg text-slate-900 mb-2">Save money</h3>
                <p class="text-slate-600 text-sm">Affordable courses with lifetime access. Invest in your future without breaking the bank.</p>
            </div>
            <div class="text-center px-4">
                <div class="w-16 h-16 bg-purple-100 text-purple-600 rounded-full flex items-center justify-center text-2xl mx-auto mb-4">
                    <i class="fa-solid fa-clock"></i>
                </div>
                <h3 class="font-bold text-lg text-slate-900 mb-2">Flexible learning</h3>
                <p class="text-slate-600 text-sm">Learn at your own pace. Watch videos, take quizzes, and track your progress on any device.</p>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />