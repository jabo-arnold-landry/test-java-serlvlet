<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --sidebar-width: 260px;
            --sidebar-bg: #1a1d23;
            --topbar-height: 60px;
            --body-bg: #f0f2f5;
            --card-bg: #ffffff;
            --accent-blue: #3b82f6;
            --accent-green: #10b981;
            --accent-orange: #f59e0b;
            --accent-red: #ef4444;
        }
        * { font-family: 'Inter', sans-serif; }
        body { background: var(--body-bg); }

        .sidebar { position:fixed; top:0; left:0; width:var(--sidebar-width); height:100vh; background:var(--sidebar-bg); color:#fff; overflow-y:auto; z-index:1000; }
        .sidebar-brand { padding:20px; border-bottom:1px solid rgba(255,255,255,0.1); display:flex; align-items:center; gap:12px; }
        .sidebar-brand .brand-icon { width:40px; height:40px; background:linear-gradient(135deg,var(--accent-blue),#8b5cf6); border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:20px; }
        .sidebar-brand h5 { margin:0; font-weight:700; font-size:16px; }
        .sidebar-brand small { font-size:11px; color:rgba(255,255,255,0.5); }
        .sidebar-nav { padding:15px 12px; }
        .nav-section-label { font-size:10px; text-transform:uppercase; letter-spacing:1.5px; color:rgba(255,255,255,0.35); padding:15px 15px 8px; font-weight:600; }
        .sidebar-nav .nav-link { color:rgba(255,255,255,0.7); padding:10px 15px; border-radius:8px; margin-bottom:2px; font-size:14px; display:flex; align-items:center; gap:12px; transition:0.2s; }
        .sidebar-nav .nav-link:hover { color:#fff; background:#2d3139; }
        .sidebar-nav .nav-link.active { color:#fff; background:var(--accent-blue); font-weight:500; }
        .sidebar-nav .nav-link i { font-size:18px; width:22px; text-align:center; }

        .topbar { position:fixed; top:0; left:var(--sidebar-width); right:0; height:var(--topbar-height); background:var(--card-bg); border-bottom:1px solid #e5e7eb; display:flex; align-items:center; justify-content:space-between; padding:0 30px; z-index:999; }
        .main-content { margin-left:var(--sidebar-width); margin-top:var(--topbar-height); padding:30px; }

        .stat-card { background:var(--card-bg); border-radius:12px; padding:20px; border:1px solid #e5e7eb; transition:0.2s; }
        .stat-card:hover { box-shadow:0 4px 12px rgba(0,0,0,0.08); transform:translateY(-2px); }
        .stat-icon { width:45px; height:45px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:20px; }
        .stat-value { font-size:28px; font-weight:700; color:#1a1d23; }
        .stat-label { font-size:13px; color:#6b7280; font-weight:500; }
        .bg-blue-soft { background:rgba(59,130,246,0.1); color:var(--accent-blue); }
        .bg-green-soft { background:rgba(16,185,129,0.1); color:var(--accent-green); }
        .bg-orange-soft { background:rgba(245,158,11,0.1); color:var(--accent-orange); }
        .bg-red-soft { background:rgba(239,68,68,0.1); color:var(--accent-red); }
        .bg-purple-soft { background:rgba(139,92,246,0.1); color:#8b5cf6; }

        .chart-container { background:var(--card-bg); border-radius:12px; padding:20px; border:1px solid #e5e7eb; }
        .user-avatar { width:35px; height:35px; border-radius:50%; background:linear-gradient(135deg,var(--accent-blue),#8b5cf6); display:flex; align-items:center; justify-content:center; color:#fff; font-weight:600; font-size:14px; }

        @media (max-width:768px) { .sidebar{transform:translateX(-100%);} .topbar{left:0;} .main-content{margin-left:0;} }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <nav class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon"><i class="bi bi-lightning-charge-fill"></i></div>
            <div><h5>SPCMS</h5><small>Power &amp; Cooling Mgmt</small></div>
        </div>
        <div class="sidebar-nav">
            <div class="nav-section-label">Main</div>
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-link active"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>
            <div class="nav-section-label">Assets</div>
            <a href="${pageContext.request.contextPath}/ups" class="nav-link"><i class="bi bi-battery-charging"></i> UPS Systems</a>
            <a href="${pageContext.request.contextPath}/cooling" class="nav-link"><i class="bi bi-snow2"></i> Cooling Units</a>
            <a href="${pageContext.request.contextPath}/equipment" class="nav-link"><i class="bi bi-hdd-rack-fill"></i> Equipment</a>
            <div class="nav-section-label">Operations</div>
            <a href="${pageContext.request.contextPath}/monitoring" class="nav-link"><i class="bi bi-speedometer2"></i> Monitoring</a>
            <a href="${pageContext.request.contextPath}/maintenance" class="nav-link"><i class="bi bi-wrench-adjustable-circle"></i> Maintenance</a>
            <a href="${pageContext.request.contextPath}/incidents" class="nav-link"><i class="bi bi-exclamation-triangle-fill"></i> Incidents</a>
            <a href="${pageContext.request.contextPath}/alerts" class="nav-link"><i class="bi bi-bell-fill"></i> Alerts</a>
            <div class="nav-section-label">Visitors</div>
            <a href="${pageContext.request.contextPath}/visitors" class="nav-link"><i class="bi bi-person-badge"></i> Visitor Management</a>
            <div class="nav-section-label">Reports</div>
            <a href="${pageContext.request.contextPath}/reports" class="nav-link"><i class="bi bi-file-earmark-bar-graph"></i> Daily Report</a>
            <a href="${pageContext.request.contextPath}/shift-reports" class="nav-link"><i class="bi bi-clock-history"></i> Shift Reports</a>
            <div class="nav-section-label">Administration</div>
            <a href="${pageContext.request.contextPath}/users" class="nav-link"><i class="bi bi-people-fill"></i> User Management</a>
        </div>
    </nav>

    <!-- TOPBAR -->
    <div class="topbar">
        <h6 style="margin:0;font-weight:600;"><i class="bi bi-building"></i>&nbsp; Data Center Operations Dashboard</h6>
        <div style="display:flex;align-items:center;gap:15px;">
            <div style="position:relative;cursor:pointer;font-size:20px;color:#6b7280;">
                <i class="bi bi-bell"></i>
                <span class="badge bg-danger rounded-pill" style="position:absolute;top:-5px;right:-8px;font-size:9px;">${unacknowledgedAlerts != null ? unacknowledgedAlerts : 0}</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <div class="user-avatar">A</div>
                <div><div style="font-size:13px;font-weight:600;">Admin User</div><div style="font-size:11px;color:#6b7280;">Administrator</div></div>
            </div>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <!-- Alerts -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Dashboard Overview</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Real-time data center infrastructure status</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports/generate?date=<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>" class="btn btn-primary btn-sm">
                <i class="bi bi-arrow-clockwise"></i> Generate Today's Report
            </a>
        </div>

        <!-- Stat Cards Row -->
        <div class="row g-4 mb-4">
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Total UPS Systems</div>
                            <div class="stat-value">${totalUps != null ? totalUps : 0}</div>
                            <small class="text-success"><i class="bi bi-check-circle"></i> ${activeUps != null ? activeUps : 0} Active</small>
                        </div>
                        <div class="stat-icon bg-blue-soft"><i class="bi bi-battery-charging"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Cooling Systems</div>
                            <div class="stat-value">${totalCooling != null ? totalCooling : 0}</div>
                            <small class="text-success"><i class="bi bi-check-circle"></i> ${activeCooling != null ? activeCooling : 0} Active</small>
                        </div>
                        <div class="stat-icon bg-green-soft"><i class="bi bi-snow2"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Open Incidents</div>
                            <div class="stat-value">${openIncidents != null ? openIncidents : 0}</div>
                            <small class="text-danger"><i class="bi bi-exclamation-circle"></i> ${criticalIncidents != null ? criticalIncidents : 0} Critical</small>
                        </div>
                        <div class="stat-icon bg-orange-soft"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Active Visitors</div>
                            <div class="stat-value">${activeVisitors != null ? activeVisitors : 0}</div>
                            <small class="text-warning"><i class="bi bi-bell-fill"></i> ${unacknowledgedAlerts != null ? unacknowledgedAlerts : 0} Alerts</small>
                        </div>
                        <div class="stat-icon bg-purple-soft"><i class="bi bi-person-badge"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class="row g-4 mb-4">
            <div class="col-lg-8">
                <div class="chart-container">
                    <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-graph-up"></i> UPS Load Trend (Last 7 Days)</h6>
                    <canvas id="loadTrendChart" height="250"></canvas>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="chart-container">
                    <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-thermometer-half"></i> Temperature Trend</h6>
                    <canvas id="tempTrendChart" height="250"></canvas>
                </div>
            </div>
        </div>

        <!-- Daily Report Summary -->
        <c:if test="${dailyReport != null}">
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="stat-card">
                    <h6 style="font-weight:600;font-size:14px;"><i class="bi bi-clock-fill text-primary"></i> MTTR</h6>
                    <div class="stat-value">${dailyReport.mttrMinutes} <small style="font-size:14px;">min</small></div>
                    <small class="text-muted">Mean Time To Repair</small>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <h6 style="font-weight:600;font-size:14px;"><i class="bi bi-shield-check text-success"></i> MTBF</h6>
                    <div class="stat-value">${dailyReport.mtbfHours} <small style="font-size:14px;">hrs</small></div>
                    <small class="text-muted">Mean Time Between Failures</small>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <h6 style="font-weight:600;font-size:14px;"><i class="bi bi-thermometer-high text-danger"></i> Max Temp</h6>
                    <div class="stat-value">${dailyReport.highestTempRecorded} <small style="font-size:14px;">&deg;C</small></div>
                    <small class="text-muted">Highest Recorded Today</small>
                </div>
            </div>
        </div>
        </c:if>

        <!-- Faulty Equipment Alert -->
        <c:if test="${faultyUps != null && faultyUps > 0}">
        <div class="alert alert-danger d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-octagon-fill me-2" style="font-size:20px;"></i>
            <div><strong>Attention!</strong> ${faultyUps} UPS system(s) are currently in FAULTY status. Immediate action required.</div>
        </div>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script>
        // UPS Load Trend Chart (Sample data - replace with dynamic data)
        const loadCtx = document.getElementById('loadTrendChart').getContext('2d');
        new Chart(loadCtx, {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Avg Load %',
                    data: [45, 52, 48, 61, 55, 42, 50],
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59,130,246,0.1)',
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#3b82f6',
                    pointBorderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, max: 100, ticks: { callback: v => v + '%' } }
                }
            }
        });

        // Temperature Trend Chart
        const tempCtx = document.getElementById('tempTrendChart').getContext('2d');
        new Chart(tempCtx, {
            type: 'bar',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Avg Temp °C',
                    data: [22, 23, 24, 26, 25, 22, 23],
                    backgroundColor: function(context) {
                        const value = context.dataset.data[context.dataIndex];
                        return value > 25 ? 'rgba(239,68,68,0.7)' : 'rgba(16,185,129,0.7)';
                    },
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: false, min: 18, max: 35, ticks: { callback: v => v + '°C' } }
                }
            }
        });
    </script>
</body>
</html>
