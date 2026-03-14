<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* Sidebar Styles */
    .vp-sidebar {
        position: fixed;
        top: 68px; /* Height of navbar */
        left: 0;
        bottom: 0;
        width: 250px;
        background-color: #0f172a; /* Deep Dark Blue - Slate 900 */
        border-right: 1px solid #1e293b;
        padding-top: 20px;
        box-shadow: 4px 0 15px rgba(0,0,0,0.1);
        z-index: 1020;
    }

    .vp-nav-header {
        padding: 10px 24px;
        font-size: 0.7rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        font-weight: 700;
        color: #475569; /* Slate 600 */
        margin-top: 15px;
        margin-bottom: 5px;
    }

    .vp-nav-item {
        display: flex;
        align-items: center;
        padding: 12px 24px;
        color: #94a3b8; /* Slate 400 */
        text-decoration: none;
        font-weight: 500;
        font-size: 0.9rem;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        margin: 2px 12px;
        border-radius: 8px;
    }

    .vp-nav-item i {
        font-size: 1.1rem;
        margin-right: 12px;
        transition: transform 0.2s;
    }

    .vp-nav-item:hover {
        background-color: rgba(255, 255, 255, 0.05);
        color: #f8fafc; /* Slate 50 */
    }
    
    .vp-nav-item:hover i {
        transform: scale(1.1);
    }

    .vp-nav-item.active {
        background-color: #3b82f6; /* Professional Blue 500 */
        color: white;
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
    }
    
    .vp-nav-item.active i {
        color: white;
    }

    .vp-content-area {
        margin-left: 250px;
        padding: 90px 30px 40px; /* Account for navbar + margins */
        min-height: 100vh;
        background-color: #f8fafc;
    }
    
    @media (max-width: 768px) {
        .vp-sidebar { display: none; }
        .vp-content-area { margin-left: 0; padding: 80px 15px 20px; }
    }
</style>

<!-- Sidebar Navigation -->
<div class="vp-sidebar d-flex flex-column">
    
    <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
    <c:set var="isSecurity" value="${currentUser.role == 'SECURITY' || currentUser.role == 'ADMIN' || currentUser.role == 'MANAGER'}" />
    
    <div class="vp-nav-header">
        ${isTech ? 'Technician Terminal' : 'Security Console'}
    </div>

    <a href="${pageContext.request.contextPath}/visitor-portal" class="vp-nav-item ${pageName == 'dashboard' ? 'active' : ''}">
        <i class="bi bi-speedometer2"></i> ${isTech ? 'My Terminal' : 'Overview'}
    </a>
    
    <c:if test="${!isTech}">
        <a href="${pageContext.request.contextPath}/visitor-portal/request" class="vp-nav-item ${pageName == 'request' ? 'active' : ''}">
            <i class="bi bi-person-plus-fill"></i> Register Arrival
        </a>
    </c:if>

    <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="vp-nav-item ${pageName == 'visit-log' ? 'active' : ''}">
        <i class="bi bi-journal-check"></i> ${isTech ? 'My Assignments' : 'Visit Log'}
    </a>

    <a href="${pageContext.request.contextPath}/visitor-portal/active" class="vp-nav-item ${pageName == 'active' ? 'active' : ''}">
        <i class="bi bi-shield-shaded"></i> ${isTech ? 'Active Escorts' : 'Active Visitors'}
    </a>

    <a href="${pageContext.request.contextPath}/visitor-portal/history" class="vp-nav-item ${pageName == 'history' ? 'active' : ''}">
        <i class="bi bi-clock-history"></i> ${isTech ? 'My History' : 'Archive Log'}
    </a>

    <div class="vp-nav-header mt-4">Intelligence & Alerts</div>

    <a href="${pageContext.request.contextPath}/visitor-portal/notifications" class="vp-nav-item ${pageName == 'notifications' ? 'active' : ''}">
        <i class="bi bi-broadcast"></i> Notifications
        <span class="badge rounded-pill bg-danger border border-light ms-auto small" style="font-size: 0.65rem;">Live</span>
    </a>

    <a href="${pageContext.request.contextPath}/visitor-portal/support" class="vp-nav-item ${pageName == 'support' ? 'active' : ''}">
        <i class="bi bi-exclamation-triangle"></i> ${isTech ? 'Log Incident' : 'Support'}
    </a>
    
    <div class="mt-auto p-4">
        <div class="p-3 rounded-4 bg-white bg-opacity-5 border border-white border-opacity-10 text-center">
            <div class="small text-muted mb-1">System Status</div>
            <div class="small fw-bold text-success"><i class="bi bi-circle-fill me-2" style="font-size: 0.5rem;"></i>Operational</div>
        </div>
    </div>
</div>
