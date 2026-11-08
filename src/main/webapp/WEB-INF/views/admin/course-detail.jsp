<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="min-h-screen flex flex-col bg-surface lg:flex-row">
    <jsp:include page="/WEB-INF/views/common/management-sidebar.jsp">
        <jsp:param name="activeSection" value="courses" />
    </jsp:include>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
        <main class="w-full max-w-5xl flex-grow mx-auto px-4 py-8 sm:px-6 lg:px-8 lg:py-10">

            <!-- Breadcrumbs -->
            <div class="mb-5 flex items-center space-x-2 text-xs text-slate-400">
                <a href="${pageContext.request.contextPath}/manager/courses" class="hover:text-brand-700 transition flex items-center gap-1">
                    <i class="fa-solid fa-book-open"></i>
                    <span>Courses</span>
                </a>
                <span>/</span>
                <span class="text-slate-600 font-semibold">Course Detail</span>
            </div>

            <!-- Flash Alert Messages -->
            <c:if test="${not empty successMessage}">
                <div class="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-semibold flex items-center justify-between shadow-xs">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-circle-check text-sm text-emerald-600"></i>
                        <span>${successMessage}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-700">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center justify-between shadow-xs">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-circle-exclamation text-sm text-rose-600"></i>
                        <span>${errorMessage}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-700">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <!-- Card Container (Exact Match to User Mockup Image) -->
            <div class="bg-white rounded-2xl border border-slate-200/90 shadow-sm p-6 sm:p-8">
                <!-- Header with Course Title and Back Link -->
                <div class="flex items-center justify-between gap-3 pb-4 border-b border-slate-200">
                    <h1 class="min-w-0 truncate text-xl font-bold tracking-tight text-text-primary sm:text-2xl" title="${fn:escapeXml(empty course.id ? 'New Course' : course.title)}">
                        <c:out value="${empty course.id ? 'New Course' : course.title}" />
                    </h1>
                    <a href="${pageContext.request.contextPath}/manager/courses"
                       class="shrink-0 rounded-lg border border-border-default bg-surface-card px-3 py-2 text-sm font-semibold text-text-primary hover:bg-surface focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 sm:px-5">
                        Back to List
                    </a>
                </div>

                <!-- Form to update course attributes -->
                <form id="courseDetailForm"
                      action="${pageContext.request.contextPath}/manager/course-detail"
                      method="post"
                      enctype="multipart/form-data"
                      class="pt-6 space-y-6">

                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="source" value="detail">
                    <c:if test="${not empty course.id}">
                        <input type="hidden" name="id" value="${course.id}">
                    </c:if>

                    <!-- Course Title -->
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">
                            Course Title <span class="text-rose-500">*</span>
                        </label>
                        <input type="text"
                               name="title"
                               value="${course.title}"
                               required
                               placeholder="e.g. Java Web Development with Servlets & JSP"
                               class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm font-medium text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 bg-white shadow-2xs">
                    </div>

                    <!-- Row 1: Category & Price (VND) -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <!-- Category -->
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">
                                Category <span class="text-rose-500">*</span>
                            </label>
                            <div class="relative">
                                <select name="categoryId"
                                        required
                                        class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm font-medium text-slate-800 bg-white focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 cursor-pointer appearance-none">
                                    <option value="">Select Category</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}" ${course.categoryId eq cat.id ? 'selected' : ''}>
                                            ${cat.name}
                                        </option>
                                    </c:forEach>
                                </select>
                                <i class="fa-solid fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                            </div>
                        </div>

                        <!-- Price (VND) -->
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">
                                Price (VND) <span class="text-xs text-slate-400 font-normal">(0 = Free)</span>
                            </label>
                            <input type="number"
                                   name="price"
                                   min="0"
                                   step="1000"
                                   value="<fmt:formatNumber value='${course.price != null ? course.price : 0}' pattern='#'/>"
                                   placeholder="499000"
                                   class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm font-medium text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 shadow-2xs">
                        </div>
                    </div>

                    <!-- Row 2: Course Status & Thumbnail Media (Cloudinary) -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <!-- Course Status -->
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">
                                Course Status
                            </label>
                            <div class="relative">
                                <select name="status"
                                        class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm font-medium text-slate-800 bg-white focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 cursor-pointer appearance-none">
                                    <option value="draft" ${course.status eq 'draft' ? 'selected' : ''}>Draft</option>
                                    <option value="published" ${course.status eq 'published' ? 'selected' : ''}>Published</option>
                                    <option value="archived" ${course.status eq 'archived' ? 'selected' : ''}>Archived</option>
                                </select>
                                <i class="fa-solid fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                            </div>
                        </div>

                        <!-- Thumbnail Media (Cloudinary) -->
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">
                                Thumbnail Media (Cloudinary)
                            </label>
                            <input type="file"
                                   name="thumbnailFile"
                                   accept="image/*"
                                   class="w-full text-xs text-slate-500 file:mr-3 file:py-2 file:px-3 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-slate-100 file:text-slate-700 hover:file:bg-slate-200 border border-slate-300 rounded-xl px-2 py-1.5 cursor-pointer bg-white">
                            
                            <!-- Current Thumbnail Preview -->
                            <c:if test="${not empty course.thumbnailUrl}">
                                <div class="mt-2 flex items-center space-x-3 text-xs text-slate-500 bg-slate-50 p-2 rounded-xl border border-slate-200">
                                    <img src="${course.thumbnailUrl}" alt="Thumbnail" class="w-10 h-10 object-cover rounded-lg border border-slate-200 shrink-0">
                                    <div class="min-w-0 flex-1">
                                        <p class="text-[11px] font-bold text-slate-700 truncate">Current Cloudinary Media</p>
                                        <p class="text-[10px] font-mono text-slate-400 truncate">${course.thumbnailUrl}</p>
                                    </div>
                                </div>
                                <input type="hidden" name="thumbnailUrl" value="${course.thumbnailUrl}">
                            </c:if>
                        </div>
                    </div>

                    <!-- Row 3: Assigned Instructor (Optional) -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">
                                Assigned Instructor / Expert
                            </label>
                            <div class="relative">
                                <select name="expertId"
                                        class="w-full px-3.5 py-2.5 border border-slate-300 rounded-xl text-sm font-medium text-slate-800 bg-white focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 cursor-pointer appearance-none">
                                    <option value="">Select Instructor</option>
                                    <c:forEach var="inst" items="${instructors}">
                                        <option value="${inst.id}" ${course.expertId eq inst.id ? 'selected' : ''}>
                                            ${inst.username} (${inst.email})
                                        </option>
                                    </c:forEach>
                                </select>
                                <i class="fa-solid fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Course Description -->
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">
                            Course Description
                        </label>
                        <textarea name="description"
                                  rows="4"
                                  placeholder="Comprehensive course covering Jakarta Servlets, JSP, JDBC database integration with PostgreSQL, and MVC architectural patterns."
                                  class="w-full px-4 py-2.5 border border-slate-300 rounded-xl text-sm font-medium text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-brand-700 focus:border-brand-700 shadow-2xs">${course.description}</textarea>
                    </div>

                    <!-- Curriculum & Sections Management (SDS Requirement) -->
                    <c:if test="${not empty course.id}">
                        <div class="pt-6 border-t border-slate-200">
                            <div class="flex items-center justify-between mb-4">
                                <div>
                                    <h2 class="text-base font-bold text-slate-900 flex items-center gap-2">
                                        <i class="fa-solid fa-layer-group text-brand-700"></i>
                                        <span>Curriculum & Sections (${fn:length(course.modules)} modules)</span>
                                    </h2>
                                    <p class="text-xs text-slate-500 mt-0.5">Inspect and organize course sections, lesson lists, and attached quiz assessments</p>
                                </div>
                                <div class="flex items-center gap-2">
                                    <c:choose>
                                        <c:when test="${sessionScope.currentUser.roleCode eq 'ROLE_MANAGER'}">
                                            <a href="${pageContext.request.contextPath}/manager/lessons?courseId=${course.id}"
                                               class="inline-flex items-center gap-2 px-3 py-2 text-xs font-bold text-brand-700 bg-brand-50 rounded-lg hover:bg-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700">
                                                <i class="fa-solid fa-clipboard-check" aria-hidden="true"></i>
                                                <span>Review Lessons</span>
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/expert/lessons?courseId=${course.id}"
                                       class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-bold text-brand-700 hover:text-brand-900 bg-brand-50 hover:bg-brand-100 rounded-xl transition">
                                        <i class="fa-solid fa-book-open text-xs"></i>
                                        <span>Manage Lessons</span>
                                    </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Modules Accordion / List -->
                            <div class="space-y-3">
                                <c:choose>
                                    <c:when test="${empty course.modules}">
                                        <div class="text-center py-8 bg-slate-50 rounded-xl border border-slate-200 text-slate-400 text-xs">
                                            <i class="fa-regular fa-folder-open text-3xl mb-2 text-slate-300 block"></i>
                                            <span>No sections yet. Click "Manage Lessons" above to create course curriculum.</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="courseModule" items="${course.modules}" varStatus="status">
                                            <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
                                                <div class="flex items-center justify-between">
                                                    <div class="flex items-center space-x-2.5">
                                                        <span class="w-6 h-6 rounded-lg bg-brand-100 text-brand-800 flex items-center justify-center font-bold text-xs">
                                                            ${status.count}
                                                        </span>
                                                        <h3 class="text-xs font-bold text-slate-900">${courseModule.title}</h3>
                                                    </div>
                                                    <div class="text-[11px] font-semibold text-slate-500 flex items-center gap-3">
                                                        <span><i class="fa-solid fa-play text-slate-400 mr-1 text-[10px]"></i>${fn:length(courseModule.lessons)} lessons</span>
                                                        <span><i class="fa-solid fa-clipboard-question text-slate-400 mr-1 text-[10px]"></i>${fn:length(courseModule.quizzes)} quizzes</span>
                                                    </div>
                                                </div>

                                                <!-- Lessons in module -->
                                                <c:if test="${not empty courseModule.lessons}">
                                                    <div class="mt-3 pl-8 space-y-1.5 border-t border-slate-200/60 pt-2.5">
                                                        <c:forEach var="les" items="${courseModule.lessons}">
                                                            <div class="flex items-center justify-between text-xs text-slate-600 py-1 hover:text-slate-900">
                                                                <span class="flex items-center gap-2">
                                                                    <i class="fa-regular fa-circle-play text-[11px] text-slate-400"></i>
                                                                    <span>${les.title}</span>
                                                                </span>
                                                                <span class="text-[10px] text-slate-400 font-mono">Lesson #${les.orderIndex}</span>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>

                                                <!-- Quizzes in module -->
                                                <c:if test="${not empty courseModule.quizzes}">
                                                    <div class="mt-2 pl-8 space-y-1 border-t border-slate-200/60 pt-2">
                                                        <c:forEach var="qz" items="${courseModule.quizzes}">
                                                            <div class="flex items-center justify-between text-xs text-purple-700 py-0.5">
                                                                <span class="flex items-center gap-2 font-medium">
                                                                    <i class="fa-solid fa-trophy text-[11px] text-purple-500"></i>
                                                                    <span>Assessment: ${qz.title}</span>
                                                                </span>
                                                                <span class="text-[10px] bg-purple-100 text-purple-800 px-2 py-0.5 rounded-full font-bold">
                                                                    ${qz.timeLimit} mins
                                                                </span>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>

                    <!-- Bottom Divider & Action Buttons (Exact Match to Mockup) -->
                    <div class="pt-5 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-end gap-4">
                        <!-- Save Changes -->
                        <div class="flex items-center space-x-3">
                            <button type="submit"
                                    class="px-6 py-2.5 bg-brand-700 hover:bg-brand-800 active:bg-brand-900 text-white font-bold rounded-xl text-sm shadow-md shadow-brand-700/20 transition cursor-pointer">
                                Save Changes
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/management-footer.jsp" />
