<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Technical Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .report-kpi { border: 1px solid #e5e7eb; border-radius: 12px; padding: 14px 16px; background: #fff; height: 100%; }
        .report-kpi .label { font-size: 12px; color: #6b7280; margin-bottom: 6px; text-transform: uppercase; letter-spacing: .04em; }
        .report-kpi .value { font-size: 24px; font-weight: 700; color: #111827; }
        .table thead th { white-space: nowrap; font-size: 12px; text-transform: uppercase; color: #6b7280; letter-spacing: .02em; }
        .table td { font-size: 13px; }
        @media print {
            .sidebar, .topbar, .print-controls { display: none !important; }
            .main-content { margin: 0 !important; padding: 0 !important; }
            .card { border: 1px solid #d9d9d9 !important; box-shadow: none !important; break-inside: avoid; page-break-inside: avoid; }
            .card-header { background: #f7f7f7 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            code { color: #222 !important; background: #f2f2f2 !important; border: 1px solid #ddd; }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Technical Operations Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Daily / Weekly / Monthly report for IT Administrator and Manager</p>
            </div>
            <div class="d-flex align-items-center gap-2 print-controls">
                <span class="badge bg-primary-subtle text-primary-emphasis p-2">
                    <i class="bi bi-calendar3"></i> Generated: ${reportGeneratedAt}
                </span>
                <button type="button" class="btn btn-outline-primary btn-sm" onclick="window.print()">
                    <i class="bi bi-printer"></i> Print / Save PDF
                </button>
            </div>
        </div>

        <div class="card mb-4 print-controls">
            <div class="card-body">
                <form class="row g-3 align-items-end" method="get" action="${pageContext.request.contextPath}/reports/project">
                    <div class="col-md-4">
                        <label class="form-label">Period</label>
                        <select name="period" class="form-select">
                            <option value="daily" ${period == 'daily' ? 'selected' : ''}>Daily</option>
                            <option value="weekly" ${period == 'weekly' ? 'selected' : ''}>Weekly (Last 7 Days)</option>
                            <option value="monthly" ${period == 'monthly' ? 'selected' : ''}>Monthly (Month-to-date)</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Reference Date</label>
                        <input type="date" name="date" value="${reportDate}" class="form-control" />
                    </div>
                    <div class="col-md-4 d-grid">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-funnel"></i> Generate Report</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white fw-bold">Executive Summary</div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-8">
                        <p class="mb-1">Period: <strong>${startDate}</strong> to <strong>${endDate}</strong>. Includes all UPS and Cooling assets, maintenance, incidents, alerts, and reliability metrics.</p>
                        <p class="mb-0">Highlights: <strong>${totalIncidents}</strong> incidents, <strong>${totalDowntimeMin}</strong> minutes downtime, MTTR <strong>${mttr}</strong> min, MTBF <strong>${mtbf}</strong> hrs, Avg Load <strong>${avgLoad}%</strong>, Max Temp <strong>${maxTemp} degC</strong>.</p>
                    </div>
                    <div class="col-md-4 text-end">
                        <div style="padding: 12px; border: 2px solid; border-radius: 8px; ${systemHealthCss}">
                            <div style="font-size: 14px; opacity: 0.8;">System Health</div>
                            <div style="font-size: 24px; margin-top: 4px;">${systemHealthStatus}</div>
                        </div>
                    </div>
                </div>
                <div class="alert alert-warning mt-3 mb-0">
                    <i class="bi bi-exclamation-triangle"></i> ${executiveWarningText}
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-2"><div class="report-kpi"><div class="label">MTTR</div><div class="value">${mttr}</div><small>minutes</small></div></div>
            <div class="col-md-2"><div class="report-kpi"><div class="label">MTBF</div><div class="value">${mtbf}</div><small>hours</small></div></div>
            <div class="col-md-2"><div class="report-kpi"><div class="label">Avg Load</div><div class="value">${avgLoad}%</div><small>UPS average</small></div></div>
            <div class="col-md-2"><div class="report-kpi"><div class="label">Max Temp</div><div class="value">${maxTemp}</div><small>degC</small></div></div>
            <div class="col-md-2"><div class="report-kpi"><div class="label">Incidents</div><div class="value">${totalIncidents}</div><small>total count</small></div></div>
            <div class="col-md-2"><div class="report-kpi"><div class="label">Downtime</div><div class="value">${totalDowntimeMin}</div><small>minutes</small></div></div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-lg-8">
                <div class="card"><div class="card-header bg-white fw-bold">System Metrics Trend</div><div class="card-body"><canvas id="metricsTrendChart" height="120"></canvas></div></div>
            </div>
            <div class="col-lg-4">
                <div class="card"><div class="card-header bg-white fw-bold">Incident Severity Distribution</div><div class="card-body"><canvas id="severityChart" height="120"></canvas></div></div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white fw-bold">Asset Overview - UPS</div>
            <div class="card-body table-responsive">
                <table class="table table-sm table-striped align-middle">
                    <thead><tr><th>ID</th><th>Asset Tag</th><th>Brand</th><th>Model</th><th>Location</th><th>Status</th><th>Battery Health</th><th>Load %</th></tr></thead>
                    <tbody>
                        <c:forEach var="ups" items="${upsAssets}">
                            <tr>
                                <td>${ups.upsId}</td>
                                <td>${ups.assetTag}</td>
                                <td>${ups.brand}</td>
                                <td>${ups.model}</td>
                                <td>${ups.locationRoom}</td>
                                <td>${ups.status}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ups.batteryHealthPercentage != null}">
                                            <span class="${ups.batteryHealthPercentage >= 80 ? 'text-success' : (ups.batteryHealthPercentage >= 50 ? 'text-warning' : 'text-danger')}">
                                                ${ups.batteryHealthPercentage}%
                                            </span>
                                        </c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${ups.loadPercentage != null ? ups.loadPercentage : 'N/A'}%</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty upsAssets}"><tr><td colspan="8" class="text-center text-muted">No UPS assets found.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white fw-bold">Asset Overview - Cooling</div>
            <div class="card-body table-responsive">
                <table class="table table-sm table-striped align-middle">
                    <thead><tr><th>ID</th><th>Asset Tag</th><th>Brand</th><th>Model</th><th>Location</th><th>Status</th><th>Room Temp</th><th>Humidity</th></tr></thead>
                    <tbody>
                        <c:forEach var="unit" items="${coolingAssets}">
                            <tr><td>${unit.coolingId}</td><td>${unit.assetTag}</td><td>${unit.brand}</td><td>${unit.model}</td><td>${unit.locationRoom}</td><td>${unit.status}</td><td>${unit.roomTemperature}</td><td>${unit.humidityPercent}</td></tr>
                        </c:forEach>
                        <c:if test="${empty coolingAssets}"><tr><td colspan="8" class="text-center text-muted">No cooling assets found.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-lg-6">
                <div class="card h-100">
                    <div class="card-header bg-white fw-bold">UPS Maintenance Records</div>
                    <div class="card-body table-responsive">
                        <table class="table table-sm table-striped align-middle mb-0">
                            <thead><tr><th>Date</th><th>UPS ID</th><th>Type</th><th>Technician</th><th>Vendor</th><th>Next Due</th><th>Remarks</th></tr></thead>
                            <tbody>
                                <c:forEach var="m" items="${upsMaintenance}">
                                    <tr><td>${m.maintenanceDate}</td><td>${m.ups.upsId}</td><td>${m.maintenanceType}</td><td>${m.technician}</td><td>${m.vendor}</td><td>${m.nextDueDate}</td><td>${m.remarks}</td></tr>
                                </c:forEach>
                                <c:if test="${empty upsMaintenance}"><tr><td colspan="7" class="text-center text-muted">No UPS maintenance records for period.</td></tr></c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="card h-100">
                    <div class="card-header bg-white fw-bold">Cooling Maintenance Records</div>
                    <div class="card-body table-responsive">
                        <table class="table table-sm table-striped align-middle mb-0">
                            <thead><tr><th>Date</th><th>Cooling ID</th><th>Type</th><th>Technician</th><th>Vendor</th><th>Next Due</th><th>Remarks</th></tr></thead>
                            <tbody>
                                <c:forEach var="m" items="${coolingMaintenance}">
                                    <tr><td>${m.maintenanceDate}</td><td>${m.coolingUnit.coolingId}</td><td>${m.maintenanceType}</td><td>${m.technician}</td><td>${m.vendor}</td><td>${m.nextMaintenanceDate}</td><td>${m.remarks}</td></tr>
                                </c:forEach>
                                <c:if test="${empty coolingMaintenance}"><tr><td colspan="7" class="text-center text-muted">No cooling maintenance records for period.</td></tr></c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white fw-bold">Incident and Fault Log</div>
            <div class="card-body table-responsive">
                <table class="table table-sm table-striped align-middle">
                    <thead><tr><th>ID</th><th>Fault Type</th><th>Severity</th><th>Date/Time</th><th>Status</th><th>Downtime (min)</th><th>Technician</th></tr></thead>
                    <tbody>
                        <c:forEach var="inc" items="${incidents}">
                            <tr class="${inc.severity == 'CRITICAL' ? 'table-danger' : ''}">
                                <td>${inc.incidentId}</td>
                                <td>${inc.title}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${inc.severity == 'CRITICAL'}"><span class="badge bg-danger">CRITICAL</span></c:when>
                                        <c:when test="${inc.severity == 'HIGH'}"><span class="badge bg-warning">HIGH</span></c:when>
                                        <c:when test="${inc.severity == 'MEDIUM'}"><span class="badge bg-info">MEDIUM</span></c:when>
                                        <c:otherwise><span class="badge bg-success">LOW</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${inc.createdAt}</td>
                                <td>${inc.status}</td>
                                <td>${inc.downtimeMinutes != null ? inc.downtimeMinutes : 0}</td>
                                <td>${inc.assignedTo != null ? inc.assignedTo.fullName : 'Unassigned'}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty incidents}"><tr><td colspan="7" class="text-center text-muted">No incidents recorded in this period.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-lg-6">
                <div class="card h-100">
                    <div class="card-header bg-white fw-bold">System Alerts and Notifications</div>
                    <div class="card-body table-responsive">
                        <table class="table table-sm table-striped align-middle mb-0">
                            <thead><tr><th>Type</th><th>Asset ID</th><th>Severity</th><th>Timestamp</th><th>Action Taken</th></tr></thead>
                            <tbody>
                                <c:forEach var="row" items="${alertNotifications}">
                                    <tr>
                                        <td>${row.type}</td>
                                        <td>${row.assetId}</td>
                                        <td>${row.severity}</td>
                                        <td>${row.timestamp}</td>
                                        <td>${row.actionTaken}</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty alertNotifications}"><tr><td colspan="5" class="text-center text-muted">No system alerts in this period.</td></tr></c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="card h-100">
                    <div class="card-header bg-white fw-bold">Cooling Alarm Log</div>
                    <div class="card-body table-responsive">
                        <table class="table table-sm table-striped align-middle mb-0">
                            <thead><tr><th>ID</th><th>Cooling ID</th><th>Type</th><th>Severity</th><th>Time</th><th>Action Taken</th></tr></thead>
                            <tbody>
                                <c:forEach var="alarm" items="${coolingAlarms}">
                                    <tr><td>${alarm.alarmId}</td><td>${alarm.coolingUnit.coolingId}</td><td>${alarm.alarmType}</td><td>${alarm.severity}</td><td>${alarm.alarmTime}</td><td>${alarm.actionTaken}</td></tr>
                                </c:forEach>
                                <c:if test="${empty coolingAlarms}"><tr><td colspan="6" class="text-center text-muted">No cooling alarms in this period.</td></tr></c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white fw-bold">Compliance and Recommendations</div>
            <div class="card-body">
                <div class="row g-3 mb-3">
                    <div class="col-md-4">
                        <div class="p-3 border rounded-3">
                            <div class="fw-semibold mb-1">Maintenance Policy</div>
                            <div class="fw-bold ${maintenanceCompliance ? 'text-success' : 'text-danger'}">${maintenanceCompliance ? 'Compliant' : 'Breach Detected'}</div>
                            <small class="d-block text-muted mt-2">Overdue UPS: ${overdueUps.size()} | Overdue Cooling: ${overdueCooling.size()}</small>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="p-3 border rounded-3">
                            <div class="fw-semibold mb-1">Incident Resolution</div>
                            <div class="fw-bold ${incidentCompliance ? 'text-success' : 'text-danger'}">${incidentCompliance ? 'Compliant' : 'Attention Needed'}</div>
                            <small class="d-block text-muted mt-2">Unresolved incidents: ${unresolvedIncidents}</small>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="p-3 border rounded-3">
                            <div class="fw-semibold mb-1">Alert Handling</div>
                            <div class="fw-bold ${alertCompliance ? 'text-success' : 'text-danger'}">${alertCompliance ? 'Compliant' : 'Attention Needed'}</div>
                            <small class="d-block text-muted mt-2">Unacknowledged alerts: ${unacknowledgedAlerts}</small>
                        </div>
                    </div>
                </div>
                <div class="p-3 border rounded-3 mb-3">
                    <div class="fw-semibold mb-1">SLA Status (Resolution <= 120 minutes)</div>
                    <div class="${slaCompliance ? 'text-success' : 'text-danger'} fw-bold">${slaCompliance ? 'COMPLIANT' : 'BREACH DETECTED'}</div>
                    <small class="d-block mt-2">
                        <strong>Total Incidents:</strong> ${totalIncidentsInPeriod} | 
                        <strong>Resolved:</strong> ${resolvedTotal} | 
                        <strong>Within SLA:</strong> ${resolvedWithinSla} 
                        <c:if test="${resolvedTotal > 0}">| <strong>Compliance Rate:</strong> ${slaCompliancePercentage}%</c:if>
                    </small>
                    <c:if test="${slaBreachCount > 0}">
                        <small class="d-block text-danger mt-2"><strong>SLA Breaches:</strong> ${slaBreachCount} incident(s) resolved beyond 120-minute threshold</small>
                    </c:if>
                </div>

                <c:if test="${not empty slaBreachedIncidents}">
                    <div class="alert alert-danger mb-3" role="alert">
                        <h6 class="alert-heading fw-bold"><i class="bi bi-exclamation-octagon"></i> SLA Breached Incidents</h6>
                        <table class="table table-sm table-borderless mb-0">
                            <thead style="font-size: 12px; opacity: 0.8;"><tr><th>Incident ID</th><th>Title</th><th>Severity</th><th>Downtime (min)</th><th>Excess Beyond SLA</th></tr></thead>
                            <tbody>
                                <c:forEach var="breach" items="${slaBreachedIncidents}">
                                    <tr style="border-bottom: 1px solid rgba(255,255,255,0.2);">
                                        <td>${breach.incidentId}</td>
                                        <td>${breach.title}</td>
                                        <td><span class="badge bg-danger">${breach.severity}</span></td>
                                        <td><strong>${breach.downtimeMinutes}</strong></td>
                                        <td><strong class="text-danger">+${breach.excessMinutes} min</strong></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <c:if test="${not empty unacknowledgedAlertDetails}">
                    <div class="alert alert-warning mb-3" role="alert">
                        <h6 class="alert-heading fw-bold"><i class="bi bi-exclamation-circle"></i> Unacknowledged Alerts</h6>
                        <ul class="mb-0">
                            <c:forEach var="alert" items="${unacknowledgedAlertDetails}">
                                <li><strong>${alert.type}</strong> on ${alert.assetId} (${alert.severity}) - ${alert.timestamp}</li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>

                <h6 class="fw-bold">Recurring Faults</h6>
                <ul>
                    <c:forEach var="entry" items="${recurringFaults}"><li>${entry.key}: ${entry.value} occurrences</li></c:forEach>
                    <c:if test="${empty recurringFaults}"><li>No recurring faults detected in this period.</li></c:if>
                </ul>

                <h6 class="fw-bold">Recommendations</h6>
                <ul class="mb-0">
                    <c:forEach var="rec" items="${recommendations}"><li>${rec}</li></c:forEach>
                </ul>
            </div>
        </div>

        <div id="severityData" data-low="${lowCount}" data-medium="${mediumCount}" data-high="${highCount}" data-critical="${criticalCount}" style="display:none;"></div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const trendLabels = [<c:forEach var="r" items="${trendReports}" varStatus="s">"${r.reportDate}"${!s.last ? ',' : ''}</c:forEach>];
        const trendLoad = [<c:forEach var="r" items="${trendReports}" varStatus="s">${r.avgDailyLoad != null ? r.avgDailyLoad : 0}${!s.last ? ',' : ''}</c:forEach>];
        const trendTemp = [<c:forEach var="r" items="${trendReports}" varStatus="s">${r.highestTempRecorded != null ? r.highestTempRecorded : 0}${!s.last ? ',' : ''}</c:forEach>];

        const metricsCtx = document.getElementById('metricsTrendChart');
        if (metricsCtx) {
            new Chart(metricsCtx, {
                type: 'line',
                data: {
                    labels: trendLabels,
                    datasets: [
                        { label: 'Avg Load (%)', data: trendLoad, borderColor: '#2563eb', backgroundColor: 'rgba(37,99,235,0.15)', yAxisID: 'y', tension: 0.35, fill: true },
                        { label: 'Max Temp (degC)', data: trendTemp, borderColor: '#dc2626', backgroundColor: 'rgba(220,38,38,0.15)', yAxisID: 'y1', tension: 0.35, fill: false }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { position: 'left', title: { display: true, text: 'Load %' } },
                        y1: { position: 'right', grid: { drawOnChartArea: false }, title: { display: true, text: 'Temperature' } }
                    }
                }
            });
        }

        const severityCtx = document.getElementById('severityChart');
        if (severityCtx) {
            const s = document.getElementById('severityData');
            const low = parseInt((s?.dataset?.low || '0'), 10);
            const medium = parseInt((s?.dataset?.medium || '0'), 10);
            const high = parseInt((s?.dataset?.high || '0'), 10);
            const critical = parseInt((s?.dataset?.critical || '0'), 10);

            new Chart(severityCtx, {
                type: 'bar',
                data: {
                    labels: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
                    datasets: [{ label: 'Incidents', data: [low, medium, high, critical], backgroundColor: ['#22c55e', '#f59e0b', '#f97316', '#ef4444'] }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: { y: { beginAtZero: true, precision: 0 } }
                }
            });
        }
    </script>
</body>
</html>
