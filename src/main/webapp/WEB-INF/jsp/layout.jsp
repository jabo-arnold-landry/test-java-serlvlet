<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - SmartPower & Cooling Management System</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --sidebar-width: 260px;
            --sidebar-bg: #1a1d23;
            --sidebar-hover: #2d3139;
            --sidebar-active: #3b82f6;
            --topbar-height: 60px;
            --body-bg: #f0f2f5;
            --card-bg: #ffffff;
            --text-primary: #1a1d23;
            --text-secondary: #6b7280;
            --accent-blue: #3b82f6;
            --accent-green: #10b981;
            --accent-orange: #f59e0b;
            --accent-red: #ef4444;
        }

        * { font-family: 'Inter', sans-serif; }

        body {
            background-color: var(--body-bg);
            margin: 0;
            padding: 0;
        }

        /* ==================== SIDEBAR ==================== */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: var(--sidebar-width);
            height: 100vh;
            background: var(--sidebar-bg);
            color: #ffffff;
            overflow-y: auto;
            z-index: 1000;
            transition: all 0.3s ease;
        }

        .sidebar-brand {
            padding: 20px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .sidebar-brand .brand-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--accent-blue), #8b5cf6);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .sidebar-brand h5 {
            margin: 0;
            font-weight: 700;
            font-size: 16px;
            letter-spacing: -0.3px;
        }

        .sidebar-brand small {
            font-size: 11px;
            color: rgba(255,255,255,0.5);
        }

        .sidebar-nav {
            padding: 15px 12px;
        }

        .nav-section-label {
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: rgba(255,255,255,0.35);
            padding: 15px 15px 8px;
            font-weight: 600;
        }

        .sidebar-nav .nav-link {
            color: rgba(255,255,255,0.7);
            padding: 10px 15px;
            border-radius: 8px;
            margin-bottom: 2px;
            font-size: 14px;
            font-weight: 400;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: all 0.2s ease;
        }

        .sidebar-nav .nav-link:hover {
            color: #ffffff;
            background: var(--sidebar-hover);
        }

        .sidebar-nav .nav-link.active {
            color: #ffffff;
            background: var(--sidebar-active);
            font-weight: 500;
        }

        .sidebar-nav .nav-link i {
            font-size: 18px;
            width: 22px;
            text-align: center;
        }

        .nav-badge {
            margin-left: auto;
            background: var(--accent-red);
            color: #fff;
            font-size: 10px;
            padding: 2px 7px;
            border-radius: 10px;
            font-weight: 600;
        }

        /* ==================== TOPBAR ==================== */
        .topbar {
            position: fixed;
            top: 0;
            left: var(--sidebar-width);
            right: 0;
            height: var(--topbar-height);
            background: var(--card-bg);
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 30px;
            z-index: 999;
        }

        .topbar-left h6 {
            margin: 0;
            font-weight: 600;
            color: var(--text-primary);
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .topbar-right .notification-bell {
            position: relative;
            cursor: pointer;
            font-size: 20px;
            color: var(--text-secondary);
        }

        .topbar-right .notification-bell .badge {
            position: absolute;
            top: -5px;
            right: -8px;
            font-size: 9px;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .user-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--accent-blue), #8b5cf6);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: 600;
            font-size: 14px;
        }

        /* ==================== MAIN CONTENT ==================== */
        .main-content {
            margin-left: var(--sidebar-width);
            margin-top: var(--topbar-height);
            padding: 30px;
            min-height: calc(100vh - var(--topbar-height));
        }

        /* ==================== CARDS ==================== */
        .stat-card {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #e5e7eb;
            transition: all 0.2s ease;
        }

        .stat-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }

        .stat-card .stat-icon {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .stat-card .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-primary);
        }

        .stat-card .stat-label {
            font-size: 13px;
            color: var(--text-secondary);
            font-weight: 500;
        }

        /* Color variants */
        .bg-blue-soft { background: rgba(59,130,246,0.1); color: var(--accent-blue); }
        .bg-green-soft { background: rgba(16,185,129,0.1); color: var(--accent-green); }
        .bg-orange-soft { background: rgba(245,158,11,0.1); color: var(--accent-orange); }
        .bg-red-soft { background: rgba(239,68,68,0.1); color: var(--accent-red); }

        /* ==================== TABLES ==================== */
        .table-container {
            background: var(--card-bg);
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            overflow: hidden;
        }

        .table-container .table { margin: 0; }
        .table-container .table th {
            background: #f9fafb;
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-secondary);
            border-bottom: 2px solid #e5e7eb;
            padding: 12px 16px;
        }

        .table-container .table td {
            padding: 12px 16px;
            font-size: 14px;
            vertical-align: middle;
        }

        .badge-status {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
        }

        /* ==================== RESPONSIVE ==================== */
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .topbar { left: 0; }
            .main-content { margin-left: 0; }
        }
    </style>
</head>
<body>

    <!-- ==================== SIDEBAR ==================== -->
    <nav class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">
                <i class="bi bi-lightning-charge-fill"></i>
            </div>
            <div>
                <h5>SPCMS</h5>
                <small>Power &amp; Cooling Mgmt</small>
            </div>
        </div>

        <div class="sidebar-nav">
            <div class="nav-section-label">Main</div>
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-link active">
                <i class="bi bi-grid-1x2-fill"></i> Dashboard
            </a>

            <div class="nav-section-label">Assets</div>
            <a href="${pageContext.request.contextPath}/ups" class="nav-link">
                <i class="bi bi-battery-charging"></i> UPS Systems
            </a>
            <a href="${pageContext.request.contextPath}/cooling" class="nav-link">
                <i class="bi bi-snow2"></i> Cooling Units
            </a>
            <a href="${pageContext.request.contextPath}/equipment" class="nav-link">
                <i class="bi bi-hdd-rack-fill"></i> Equipment
            </a>

            <div class="nav-section-label">Operations</div>
            <a href="${pageContext.request.contextPath}/monitoring" class="nav-link">
                <i class="bi bi-speedometer2"></i> Monitoring
            </a>
            <a href="${pageContext.request.contextPath}/maintenance" class="nav-link">
                <i class="bi bi-wrench-adjustable-circle"></i> Maintenance
            </a>
            <a href="${pageContext.request.contextPath}/incidents" class="nav-link">
                <i class="bi bi-exclamation-triangle-fill"></i> Incidents
            </a>
            <a href="${pageContext.request.contextPath}/alerts" class="nav-link">
                <i class="bi bi-bell-fill"></i> Alerts
                <span class="nav-badge">${unacknowledgedAlerts != null ? unacknowledgedAlerts : 0}</span>
            </a>

            <div class="nav-section-label">Visitors</div>
            <a href="${pageContext.request.contextPath}/visitors" class="nav-link">
                <i class="bi bi-person-badge"></i> Visitor Management
            </a>

            <div class="nav-section-label">Reports</div>
            <a href="${pageContext.request.contextPath}/reports" class="nav-link">
                <i class="bi bi-file-earmark-bar-graph"></i> Daily Report
            </a>
            <a href="${pageContext.request.contextPath}/shift-reports" class="nav-link">
                <i class="bi bi-clock-history"></i> Shift Reports
            </a>

            <div class="nav-section-label">Administration</div>
            <a href="${pageContext.request.contextPath}/users" class="nav-link">
                <i class="bi bi-people-fill"></i> User Management
            </a>
        </div>
    </nav>

    <!-- ==================== TOP BAR ==================== -->
    <div class="topbar">
        <div class="topbar-left">
            <h6><i class="bi bi-building"></i>&nbsp; Data Center Operations</h6>
        </div>
        <div class="topbar-right">
            <div class="notification-bell">
                <i class="bi bi-bell"></i>
                <span class="badge bg-danger rounded-pill">3</span>
            </div>
            <div class="user-info">
                <div class="user-avatar">A</div>
                <div>
                    <div style="font-size:13px;font-weight:600;">Admin User</div>
                    <div style="font-size:11px;color:#6b7280;">Administrator</div>
                </div>
            </div>
        </div>
    </div>

    <!-- ==================== MAIN CONTENT ==================== -->
    <div class="main-content">
        <!-- Flash Messages -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Page content injected here by each JSP page -->
        <jsp:include page="${contentPage != null ? contentPage : 'dashboard-content.jsp'}" />
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Chart.js (for dashboard graphs) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</body>
</html>
