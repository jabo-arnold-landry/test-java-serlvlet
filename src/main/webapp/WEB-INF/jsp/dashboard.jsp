<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
            <a href="${pageContext.request.contextPath}/reports/generate" class="btn btn-primary btn-sm">
                <i class="bi bi-arrow-clockwise"></i> Generate Today's Report
            </a>
            </sec:authorize>
        </div>

        <!-- Stat Cards Row -->
        <div class="row g-4 mb-4">
            <sec:authorize access="hasRole('SECURITY')">
                <!-- SECURITY: VISITOR FOCUS -->
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="stat-label text-uppercase small fw-bold">Wait-listed</div>
                                <div class="stat-value">${pendingApprovals}</div>
                                <small class="text-warning">Pending</small>
                            </div>
                            <div class="stat-icon bg-orange-soft"><i class="bi bi-hourglass-split"></i></div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="stat-label text-uppercase small fw-bold">Check-in Awaiting</div>
                                <div class="stat-value">${waitingForCheckIn}</div>
                                <small class="text-success">Ready</small>
                            </div>
                            <div class="stat-icon bg-green-soft"><i class="bi bi-calendar-check"></i></div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="stat-label text-uppercase small fw-bold">Currently Inside</div>
                                <div class="stat-value">${activeVisitorsCount}</div>
                                <small class="text-primary">Live</small>
                            </div>
                            <div class="stat-icon bg-blue-soft"><i class="bi bi-activity"></i></div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="stat-label text-uppercase small fw-bold">Total Check-outs</div>
                                <div class="stat-value">${checkOutsToday}</div>
                                <small class="text-muted">Metrics</small>
                            </div>
                            <div class="stat-icon bg-secondary bg-opacity-10 text-secondary"><i class="bi bi-clock-history"></i></div>
                        </div>
                    </div>
                </div>
            </sec:authorize>

            <sec:authorize access="!hasRole('SECURITY')">
                <!-- DEFAULT: INFRASTRUCTURE FOCUS -->
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
                                <div class="stat-value">${activeVisitorsCount != null ? activeVisitorsCount : 0}</div>
                                <small class="text-warning"><i class="bi bi-bell-fill"></i> ${unacknowledgedAlerts != null ? unacknowledgedAlerts : 0} Alerts</small>
                            </div>
                            <div class="stat-icon bg-purple-soft"><i class="bi bi-person-badge"></i></div>
                        </div>
                    </div>
                </div>
            </sec:authorize>
        </div>

        <!-- Charts Row -->
        <div class="row g-4 mb-4">
            <sec:authorize access="hasRole('SECURITY')">
                <div class="col-lg-8">
                    <div class="chart-container">
                        <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-people-fill"></i> Visitor Traffic Trend (Last 7 Days)</h6>
                        <div style="position:relative;height:280px;">
                            <canvas id="visitorTrendChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="chart-container">
                        <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-bar-chart-fill"></i> Monthly Visit Volume</h6>
                        <div style="position:relative;height:280px;">
                            <canvas id="visitorVolumeChart"></canvas>
                        </div>
                    </div>
                </div>
            </sec:authorize>
            <sec:authorize access="!hasRole('SECURITY')">
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
            </sec:authorize>
        </div>

        <!-- Daily Report Summary -->
        <c:if test="${dailyReport != null}">
        <sec:authorize access="!hasRole('SECURITY')">
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
        </sec:authorize>
        </c:if>

        <!-- Faulty Equipment Alert -->
        <c:if test="${faultyUps != null && faultyUps > 0}">
        <sec:authorize access="!hasRole('SECURITY')">
        <div class="alert alert-danger d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-octagon-fill me-2" style="font-size:20px;"></i>
            <div><strong>Attention!</strong> ${faultyUps} UPS system(s) are currently in FAULTY status. Immediate action required.</div>
        </div>
        </sec:authorize>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script>
        // --- INFRASTRUCTURE CHARTS (Admin/Manager) ---
        const loadTrendEl = document.getElementById('loadTrendChart');
        if (loadTrendEl) {
            const loadCtx = loadTrendEl.getContext('2d');
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
        }

        const tempTrendEl = document.getElementById('tempTrendChart');
        if (tempTrendEl) {
            const tempCtx = tempTrendEl.getContext('2d');
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
        }

        // --- VISITOR CHARTS (Security) ---
        const visitorTrendEl = document.getElementById('visitorTrendChart');
        if (visitorTrendEl) {
            const vTrendCtx = visitorTrendEl.getContext('2d');
            new Chart(vTrendCtx, {
                type: 'line',
                data: {
                    labels: [<c:forEach var="entry" items="${dailyStats}" varStatus="status">'${entry.key}'${status.last ? '' : ','}</c:forEach>],
                    datasets: [{
                        label: 'Visitors',
                        data: [<c:forEach var="entry" items="${dailyStats}" varStatus="status">${entry.value}${status.last ? '' : ','}</c:forEach>],
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#10b981',
                        pointBorderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, ticks: { stepSizeValue: 1 } }
                    }
                }
            });
        }

        const visitorVolEl = document.getElementById('visitorVolumeChart');
        if (visitorVolEl) {
            const vVolCtx = visitorVolEl.getContext('2d');
            new Chart(vVolCtx, {
                type: 'bar',
                data: {
                    labels: [<c:forEach var="entry" items="${monthlyStats}" varStatus="status">'${entry.key}'${status.last ? '' : ','}</c:forEach>],
                    datasets: [{
                        label: 'Total Visits',
                        data: [<c:forEach var="entry" items="${monthlyStats}" varStatus="status">${entry.value}${status.last ? '' : ','}</c:forEach>],
                        backgroundColor: 'rgba(59, 130, 246, 0.7)',
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, ticks: { stepSizeValue: 1 } }
                    }
                }
            });
        }
    </script>
</body>
</html>
