<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow flex items-center justify-center py-16 px-4">
    <div class="text-center max-w-md">
        <div class="text-8xl font-black text-brand-600 mb-4">404</div>
        <h1 class="text-2xl font-bold text-slate-900 mb-2">Page Not Found</h1>
        <p class="text-slate-600 mb-6">Sorry, the content you are looking for does not exist or has been moved.</p>
        <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center px-6 py-3 font-semibold text-white bg-brand-600 rounded-xl hover:bg-brand-700 shadow-md transition">
            <i class="fa-solid fa-arrow-left mr-2"></i> Back to Home
        </a>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
