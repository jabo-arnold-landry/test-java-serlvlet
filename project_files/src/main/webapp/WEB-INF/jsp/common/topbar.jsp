<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<div class="topbar">
    <h6 style="margin:0;font-weight:600;"><i class="bi bi-building"></i>&nbsp; SPCMS Control Panel</h6>
    <div style="display:flex;align-items:center;gap:15px;">
        <a href="${pageContext.request.contextPath}/alerts" style="position:relative;font-size:20px;color:#6b7280;text-decoration:none;">
            <i class="bi bi-bell"></i>
            <c:if test="${unacknowledgedAlerts != null && unacknowledgedAlerts > 0}">
                <span class="badge bg-danger rounded-pill" style="position:absolute;top:-5px;right:-8px;font-size:9px;">${unacknowledgedAlerts}</span>
            </c:if>
        </a>
        <div style="display:flex;align-items:center;gap:10px;">
            <div class="user-avatar" style="text-transform: uppercase;">
                <sec:authentication property="name" var="username" />
                ${fn:substring(username, 0, 1)}
            </div>
            <div>
                <div style="font-size:13px;font-weight:600;"><sec:authentication property="name" /></div>
                <div style="font-size:11px;color:#6b7280;text-transform:uppercase;"><sec:authentication property="principal.authorities[0]" /></div>
            </div>
        </div>
        <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0;">
            <button type="submit" class="btn btn-sm" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.2);">
                <i class="bi bi-box-arrow-right"></i> Logout
            </button>
        </form>
    </div>
</div>
