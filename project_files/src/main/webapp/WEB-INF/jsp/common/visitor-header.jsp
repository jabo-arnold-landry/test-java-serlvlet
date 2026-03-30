<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* Custom Visitor Portal Variables */
    :root {
        --vp-bg-primary: #0f172a;
        --vp-bg-secondary: #1e293b;
        --vp-accent-blue: #3b82f6;
        --vp-accent-hover: #2563eb;
        --vp-text-primary: #f8fafc;
        --vp-text-muted: #94a3b8;
        --vp-border: rgba(255, 255, 255, 0.08);
    }
    
    body.visitor-app {
        background-color: #f1f5f9;
        font-family: 'Inter', sans-serif;
    }

    /* Top Navbar */
    .vp-navbar {
        background-color: var(--vp-bg-primary);
        border-bottom: 1px solid var(--vp-border);
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        padding: 0.8rem 2rem;
        position: fixed;
        width: 100%;
        top: 0;
        z-index: 1030;
    }
    
    .vp-brand {
        display: flex;
        align-items: center;
        gap: 12px;
        color: white;
        text-decoration: none;
        font-weight: 600;
        font-size: 1.2rem;
    }
    
    .vp-logo-icon {
        width: 36px;
        height: 36px;
        background: linear-gradient(135deg, var(--vp-accent-blue), #10b981);
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem;
        box-shadow: 0 0 15px rgba(59,130,246,0.3);
    }

    .vp-nav-right {
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .vp-notification {
        position: relative;
        color: var(--vp-text-muted);
        font-size: 1.2rem;
        cursor: pointer;
        transition: color 0.2s;
    }
    .vp-notification:hover { color: white; }
    
    .vp-notification-badge {
        position: absolute;
        top: -4px;
        right: -6px;
        background: #ef4444;
        color: white;
        font-size: 0.65rem;
        font-weight: bold;
        padding: 2px 5px;
        border-radius: 10px;
        border: 2px solid var(--vp-bg-primary);
    }

    .vp-profile {
        display: flex;
        align-items: center;
        gap: 10px;
        color: white;
    }
    .vp-avatar {
        width: 32px; height: 32px;
        background: rgba(255,255,255,0.1);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.9rem;
    }

    .vp-logout-btn {
        background: rgba(255,255,255,0.05);
        border: 1px solid rgba(255,255,255,0.1);
        color: white;
        padding: 5px 12px;
        border-radius: 6px;
        font-size: 0.85rem;
        transition: all 0.2s;
    }
    .vp-logout-btn:hover {
        background: rgba(239,68,68,0.1);
        border-color: rgba(239,68,68,0.3);
        color: #f87171;
    }

</style>

<!-- Top Navigation Bar -->
<nav class="vp-navbar d-flex justify-content-between align-items-center">
    <div class="d-flex align-items-center">
        <a href="${pageContext.request.contextPath}/visitor-portal" class="vp-brand">
            <div class="vp-logo-icon"><i class="bi bi-buildings-fill text-white"></i></div>
            <span>SPCMS Visitor Portal</span>
        </a>
    </div>

    <div class="vp-nav-right">
        <a href="${pageContext.request.contextPath}/visitor-portal/notifications" class="vp-notification text-decoration-none">
            <i class="bi bi-bell-fill"></i>
            <span class="vp-notification-badge" id="notificationBadge" style="display:none;">!</span>
        </a>

        <div class="vp-profile">
            <div class="vp-avatar"><i class="bi bi-person-fill"></i></div>
            <span class="d-none d-md-inline text-sm">${currentUser.fullName}</span>
            <span class="text-muted mx-2">|</span>
            <form action="${pageContext.request.contextPath}/logout" method="post" class="m-0">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <button type="submit" class="vp-logout-btn"><i class="bi bi-box-arrow-right"></i> Logout</button>
            </form>
        </div>
    </div>
</nav>
