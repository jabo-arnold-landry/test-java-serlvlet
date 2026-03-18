<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="common/styles.jsp"/>
    <style>
        .stat-icon { width:45px; height:45px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:20px; }
        .stat-value { font-size:28px; font-weight:700; color:#1a1d23; }
        .stat-label { font-size:13px; color:#6b7280; font-weight:500; }
        .bg-blue-soft { background:rgba(59,130,246,0.1); color:#3b82f6; }
        .bg-green-soft { background:rgba(16,185,129,0.1); color:#10b981; }
        .bg-orange-soft { background:rgba(245,158,11,0.1); color:#f59e0b; }
        .bg-red-soft { background:rgba(239,68,68,0.1); color:#ef4444; }
        .bg-purple-soft { background:rgba(139,92,246,0.1); color:#8b5cf6; }
        .chart-container { background:#fff; border-radius:12px; padding:20px; border:1px solid #e5e7eb; }
        .warning-board { background:#fff; border-radius:12px; border:1px solid #fcd34d; padding:20px; }
        .warning-chip { border:1px solid #fde68a; background:#fffbeb; border-radius:10px; padding:12px; }
        .warning-chip .count { font-size:22px; font-weight:700; color:#92400e; line-height:1; }
        .warning-chip .label { font-size:12px; color:#78350f; font-weight:600; }
        .warning-list { border:1px solid #e5e7eb; border-radius:10px; overflow:hidden; }
        .warning-item { display:flex; justify-content:space-between; align-items:flex-start; gap:12px; text-decoration:none; color:inherit; padding:12px 14px; border-bottom:1px solid #e5e7eb; }
        .warning-item:last-child { border-bottom:none; }
        .warning-item:hover { background:#f9fafb; }
        .warning-icon { width:28px; height:28px; border-radius:8px; display:flex; align-items:center; justify-content:center; background:#f3f4f6; color:#374151; }
        .warning-main { flex:1; min-width:0; }
        .warning-head { display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:6px; }
        .warning-message { font-size:13px; font-weight:600; color:#111827; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .warning-meta { display:flex; gap:12px; flex-wrap:wrap; font-size:12px; color:#6b7280; }
        .warning-right { display:flex; align-items:center; gap:8px; margin-top:2px; }
        .warning-chevron { color:#9ca3af; }

        @media (max-width: 992px) {
            .warning-item { flex-direction:column; }
            .warning-right { width:100%; justify-content:flex-start; }
        }
    </style>
</head>
<body>
    <jsp:include page="common/sidebar.jsp"/>
    <jsp:include page="common/topbar.jsp"/>

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
            <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
            <a href="${pageContext.request.contextPath}/reports/generate?date=<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>" class="btn btn-primary btn-sm">
                <i class="bi bi-arrow-clockwise"></i> Generate Today's Report
            </a>
            </sec:authorize>
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

        <!-- Dashboard Warnings -->
        <c:if test="${not empty dashboardWarnings}">
        <div class="warning-board mb-4">
            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
                <div>
                    <h6 style="font-weight:700;margin:0;"><i class="bi bi-exclamation-triangle-fill text-warning"></i> Dashboard Warnings</h6>
                    <p class="text-muted mb-0" style="font-size:13px;">Unresolved alerts that need technician or admin action.</p>
                </div>
                <a href="${pageContext.request.contextPath}/alerts" class="btn btn-warning btn-sm text-dark fw-semibold">
                    <i class="bi bi-bell-fill"></i> View Alerts (${dashboardTotalWarnings != null ? dashboardTotalWarnings : 0})
                </a>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-xl col-md-4 col-6">
                    <div class="warning-chip">
                        <div class="count">${dashboardHighTempWarnings != null ? dashboardHighTempWarnings : 0}</div>
                        <div class="label">High Temp</div>
                    </div>
                </div>
                <div class="col-xl col-md-4 col-6">
                    <div class="warning-chip">
                        <div class="count">${dashboardHumidityWarnings != null ? dashboardHumidityWarnings : 0}</div>
                        <div class="label">Humidity</div>
                    </div>
                </div>
                <div class="col-xl col-md-4 col-6">
                    <div class="warning-chip">
                        <div class="count">${dashboardLowBatteryWarnings != null ? dashboardLowBatteryWarnings : 0}</div>
                        <div class="label">Low Battery</div>
                    </div>
                </div>
                <div class="col-xl col-md-4 col-6">
                    <div class="warning-chip">
                        <div class="count">${dashboardOverloadWarnings != null ? dashboardOverloadWarnings : 0}</div>
                        <div class="label">UPS Overload</div>
                    </div>
                </div>
                <div class="col-xl col-md-4 col-6">
                    <div class="warning-chip">
                        <div class="count">${dashboardMaintenanceDueWarnings != null ? dashboardMaintenanceDueWarnings : 0}</div>
                        <div class="label">Maintenance Due</div>
                    </div>
                </div>
            </div>

                <div class="warning-list">
                    <c:forEach var="warn" items="${dashboardWarnings}" end="4">
                        <a href="${pageContext.request.contextPath}/alerts/view/${warn.alertId}" class="warning-item">
                            <div class="warning-main">
                                <div class="warning-head">
                                <span class="warning-icon">
                                    <c:choose>
                                        <c:when test="${warn.alertType == 'HIGH_TEMP'}"><i class="bi bi-thermometer-high"></i></c:when>
                                        <c:when test="${warn.alertType == 'HUMIDITY'}"><i class="bi bi-droplet"></i></c:when>
                                        <c:when test="${warn.alertType == 'LOW_BATTERY'}"><i class="bi bi-battery-half"></i></c:when>
                                        <c:when test="${warn.alertType == 'UPS_OVERLOAD'}"><i class="bi bi-lightning"></i></c:when>
                                        <c:when test="${warn.alertType == 'MAINTENANCE_DUE'}"><i class="bi bi-calendar-check"></i></c:when>
                                        <c:otherwise><i class="bi bi-exclamation-triangle"></i></c:otherwise>
                                    </c:choose>
                                </span>
                                <span class="badge bg-secondary">${warn.alertType}</span>
                                <span class="badge bg-${dashboardWarningSeverityClassById[warn.alertId]}">${dashboardWarningSeverityById[warn.alertId]}</span>
                                <span class="text-muted" style="font-size:12px;">${warn.equipmentType} #${warn.equipmentId}</span>
                            </div>
                            <div class="warning-message" title="${warn.message}">${warn.message}</div>
                            <div class="warning-meta">
                                <span><i class="bi bi-clock"></i> ${dashboardWarningTriggeredAtById[warn.alertId]}</span>
                                <span><i class="bi bi-speedometer2"></i> ${dashboardWarningReadingById[warn.alertId]}</span>
                            </div>
                            </div>
                            <div class="warning-right">
                                <span class="badge ${fn:contains(dashboardWarningSlaById[warn.alertId], 'Breached') ? 'bg-danger' : 'bg-light text-dark'}">${dashboardWarningSlaById[warn.alertId]}</span>
                                <i class="bi bi-chevron-right warning-chevron"></i>
                            </div>
                        </a>
                    </c:forEach>
                </div>
        </div>
        </c:if>

        <!-- Charts Row -->
        <div class="row g-4 mb-4">
            <div class="col-lg-8">
                <div class="chart-container">
                    <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-graph-up"></i> UPS Load Trend (Last 7 Days)</h6>
                    <div style="position:relative;height:280px;">
                        <canvas id="loadTrendChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="chart-container">
                    <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-thermometer-half"></i> Temperature Trend</h6>
                    <div style="position:relative;height:280px;">
                        <canvas id="tempTrendChart"></canvas>
                    </div>
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
    
    <!-- Global Alert Notification System -->
    <jsp:include page="common/alert-notifications.jsp"/>
</body>
</html>
