<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<style>
    .vp-nav-pills {
        background: #fff;
        padding: 8px;
        border-radius: 16px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
        border: 1px solid #e2e8f0;
        margin-bottom: 2rem;
    }
    .vp-nav-link {
        color: #64748b;
        font-weight: 600;
        font-size: 0.9rem;
        padding: 10px 20px !important;
        border-radius: 12px !important;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .vp-nav-link i {
        font-size: 1.1rem;
    }
    .vp-nav-link:hover {
        background-color: #f1f5f9;
        color: #1e293b;
    }
    .vp-nav-link.active {
        background-color: #3b82f6 !important;
        color: #fff !important;
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
    }
    .vp-nav-badge {
        font-size: 0.7rem;
        padding: 2px 8px;
        border-radius: 20px;
        background: rgba(239, 68, 68, 0.1);
        color: #ef4444;
        font-weight: 700;
    }
</style>

<div class="row">
    <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
    <div class="col-12">
        <ul class="nav nav-pills vp-nav-pills">
            <li class="nav-item">
                <a class="nav-link vp-nav-link ${param.pageName == 'dashboard' ? 'active' : ''}" 
                   href="${pageContext.request.contextPath}/visitor-portal">
                    <i class="bi bi-grid-fill"></i> ${isTech ? 'Tech Dashboard' : 'Overview'}
                </a>
            </li>
            
            <sec:authorize access="hasRole('SECURITY')">
                <li class="nav-item">
                    <a class="nav-link vp-nav-link ${param.pageName == 'request' ? 'active' : ''}" 
                       href="${pageContext.request.contextPath}/visitor-portal/request">
                        <i class="bi bi-person-plus-fill"></i> Register Arrival
                    </a>
                </li>
            </sec:authorize>

            <li class="nav-item">
                <a class="nav-link vp-nav-link ${param.pageName == 'active' ? 'active' : ''}" 
                   href="${pageContext.request.contextPath}/visitor-portal/active">
                    <i class="bi bi-shield-shaded"></i> ${isTech ? 'Active Escorts' : 'Active Visitors'}
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link vp-nav-link ${param.pageName == 'visit-log' ? 'active' : ''}" 
                   href="${pageContext.request.contextPath}/visitor-portal/visit-log">
                    <i class="bi bi-journal-text"></i> ${isTech ? 'Escort Assignments' : 'Archive Log'}
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link vp-nav-link ${param.pageName == 'notifications' ? 'active' : ''}" 
                   href="${pageContext.request.contextPath}/visitor-portal/notifications">
                    <i class="bi bi-bell-fill"></i> Notifications
                    <span class="vp-nav-badge ms-1">Live</span>
                </a>
            </li>

            <li class="nav-item ms-auto">
                <a class="nav-link vp-nav-link ${param.pageName == 'support' ? 'active' : ''}" 
                   href="${pageContext.request.contextPath}/visitor-portal/support">
                    <i class="bi ${isTech ? 'bi-exclamation-octagon-fill' : 'bi-question-circle-fill'}"></i> ${isTech ? 'Incident Reports' : 'Support'}
                </a>
            </li>
        </ul>
    </div>
</div>
