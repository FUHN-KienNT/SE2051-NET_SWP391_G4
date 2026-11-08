<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<span class="relative flex shrink-0 items-center justify-center overflow-hidden rounded-full bg-brand-50 font-bold uppercase text-brand-700 ${param.avatarClass}" aria-hidden="true">
    <span><c:out value="${empty param.avatarName ? 'LH' : fn:substring(param.avatarName, 0, 1)}" /></span>
    <c:if test="${not empty param.avatarUrl}">
        <img src="${fn:escapeXml(param.avatarUrl)}" alt="" class="absolute inset-0 h-full w-full object-cover" onerror="this.hidden=true">
    </c:if>
</span>
