<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<nav class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-icon"><i class="bi bi-lightning-charge-fill"></i></div>
        <div><h5>SPCMS</h5><small>Power &amp; Cooling Mgmt</small></div>
    </div>
    <div class="sidebar-nav">
        <sec:authorize access="!hasRole('SECURITY')">
            <div class="nav-section-label">Main</div>
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>
        </sec:authorize>
        
        <sec:authorize access="hasAnyRole('TECHNICIAN', 'MANAGER', 'ADMIN')">
            <div class="nav-section-label">Assets</div>
            <a href="${pageContext.request.contextPath}/ups" class="nav-link"><i class="bi bi-battery-charging"></i> UPS Systems</a>
            <a href="${pageContext.request.contextPath}/cooling" class="nav-link"><i class="bi bi-snow2"></i> Cooling Units</a>
            <a href="${pageContext.request.contextPath}/equipment" class="nav-link"><i class="bi bi-hdd-rack-fill"></i> Equipment</a>

            <div class="nav-section-label">Operations</div>
            <a href="${pageContext.request.contextPath}/monitoring" class="nav-link"><i class="bi bi-speedometer2"></i> Monitoring</a>
            <a href="${pageContext.request.contextPath}/maintenance" class="nav-link"><i class="bi bi-wrench-adjustable-circle"></i> Maintenance</a>
            <a href="${pageContext.request.contextPath}/incidents" class="nav-link"><i class="bi bi-exclamation-triangle-fill"></i> Incidents</a>
        </sec:authorize>
        
        <sec:authorize access="!hasRole('SECURITY')">
            <a href="${pageContext.request.contextPath}/alerts" class="nav-link"><i class="bi bi-bell-fill"></i> Alerts</a>
        </sec:authorize>
        
        <sec:authorize access="hasRole('ADMIN')">
            <div class="nav-section-label">Global Intelligence</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-window-stack"></i> Visitor Management</a>
        </sec:authorize>

        <!-- 2. MANAGER: Governance & Oversight -->
        <sec:authorize access="hasRole('MANAGER')">
            <div class="nav-section-label">Management Governance</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-window-stack"></i> Visitor Management</a>
        </sec:authorize>

        <sec:authorize access="hasRole('SECURITY')">
            <div class="nav-section-label">Receptionist Desk</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-shield-shaded"></i> Security Dashboard</a>
        </sec:authorize>

        <sec:authorize access="hasRole('TECHNICIAN')">
            <div class="nav-section-label">Operational Terminal</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-display"></i> Visitor Management</a>
        </sec:authorize>

        <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
            <div class="nav-section-label">Reports</div>
            <a href="${pageContext.request.contextPath}/reports" class="nav-link"><i class="bi bi-file-earmark-bar-graph"></i> Daily Report</a>
            <a href="${pageContext.request.contextPath}/reports/project" class="nav-link"><i class="bi bi-file-earmark-text"></i> Full Project Report</a>
        </sec:authorize>
        
        <sec:authorize access="hasAnyRole('TECHNICIAN', 'MANAGER', 'ADMIN')">
            <a href="${pageContext.request.contextPath}/shift-reports" class="nav-link"><i class="bi bi-clock-history"></i> Shift Reports</a>
        </sec:authorize>

        <sec:authorize access="hasRole('ADMIN')">
            <div class="nav-section-label">Administration</div>
            <a href="${pageContext.request.contextPath}/users" class="nav-link"><i class="bi bi-people-fill"></i> User Management</a>
        </sec:authorize>
    </div>
</nav>
