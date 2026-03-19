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
        <div class="nav-section-label">Main</div>
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>
        
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
        
        <a href="${pageContext.request.contextPath}/alerts" class="nav-link"><i class="bi bi-bell-fill"></i> Alerts</a>
        
        <!-- 1. ADMIN: Intelligence Dashboard -->
        <sec:authorize access="hasRole('ADMIN')">
            <div class="nav-section-label">Global Intelligence</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-cpu"></i> Intelligence Hub</a>
            <a href="${pageContext.request.contextPath}/visitors" class="nav-link"><i class="bi bi-shield-lock"></i> Security Dashboard</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="nav-link"><i class="bi bi-journals"></i> System Audit Log</a>
        </sec:authorize>

        <!-- 2. MANAGER: Governance & Oversight -->
        <sec:authorize access="hasRole('MANAGER')">
            <div class="nav-section-label">Management Governance</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-window-stack"></i> Governance Dashboard</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="nav-link"><i class="bi bi-file-earmark-check"></i> Approval Pipeline</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/active" class="nav-link"><i class="bi bi-door-open"></i> Live Traffic Monitor</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/history" class="nav-link"><i class="bi bi-clock-history"></i> Security Audit Logs</a>
        </sec:authorize>

        <!-- 3. SECURITY: Receptionist Desk -->
        <sec:authorize access="hasRole('SECURITY')">
            <div class="nav-section-label">Receptionist Desk</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-speedometer2"></i> Security Dashboard</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/request" class="nav-link"><i class="bi bi-person-plus"></i> Register Arrival</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="nav-link"><i class="bi bi-list-check"></i> Visitor Tracking</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/active" class="nav-link"><i class="bi bi-door-closed"></i> Live Escorts</a>
        </sec:authorize>

        <!-- 4. TECHNICIAN: Operational Terminal -->
        <sec:authorize access="hasRole('TECHNICIAN')">
            <div class="nav-section-label">Operational Terminal</div>
            <a href="${pageContext.request.contextPath}/visitor-portal" class="nav-link"><i class="bi bi-speedometer2"></i> Tech Dashboard</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="nav-link"><i class="bi bi-list-task"></i> My Escort Assignments</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/active" class="nav-link"><i class="bi bi-person-badge"></i> Active Escorts</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/report-incident" class="nav-link"><i class="bi bi-exclamation-octagon"></i> Incident Reports</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/history" class="nav-link"><i class="bi bi-clock-history"></i> My Visit History</a>
            <a href="${pageContext.request.contextPath}/visitor-portal/notifications" class="nav-link"><i class="bi bi-bell"></i> Notifications</a>
        </sec:authorize>

        <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
            <div class="nav-section-label">Reports</div>
            <a href="${pageContext.request.contextPath}/reports" class="nav-link"><i class="bi bi-file-earmark-bar-graph"></i> Daily Report</a>
            <a href="${pageContext.request.contextPath}/reports/project" class="nav-link"><i class="bi bi-file-earmark-text"></i> Full Project Report</a>
            <a href="${pageContext.request.contextPath}/reports/branch-performance" class="nav-link"><i class="bi bi-diagram-3"></i> Branch Performance</a>
            <a href="${pageContext.request.contextPath}/reports/cost-analysis" class="nav-link"><i class="bi bi-cash-coin"></i> Cost Analysis</a>
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
