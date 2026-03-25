<<<<<<< HEAD
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>SPCMS - Daily Consolidated Report</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                    rel="stylesheet">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <jsp:include page="../common/styles.jsp" />
                <style>
                    .report-metric {
                        text-align: center;
                    }

                    .report-metric .metric-value {
                        font-size: 2rem;
                        font-weight: 700;
                        margin: 6px 0;
                    }

                    .report-metric .metric-label {
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                        color: #888;
                    }

                    .date-picker-form {
                        display: flex;
                        gap: 10px;
                        align-items: center;
                    }

                    .section-title {
                        font-size: 13px;
                        font-weight: 700;
                        letter-spacing: 0.08em;
                        text-transform: uppercase;
                        color: #e74c3c;
                        border-bottom: 1px solid rgba(255, 255, 255, 0.07);
                        padding-bottom: 8px;
                        margin-bottom: 16px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="../common/sidebar.jsp" />
                <jsp:include page="../common/topbar.jsp" />
                <div class="main-content">

                    <%-- Flash messages --%>
                        <c:if test="${not empty success}">
                            <div class="alert alert-success alert-dismissible fade show">
                                <i class="bi bi-check-circle-fill me-2"></i>${success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <%-- Header --%>
                            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                                <div>
                                    <h4 style="font-weight:700;margin:0;"><i
                                            class="bi bi-file-earmark-bar-graph text-primary me-2"></i>Daily
                                        Consolidated Report</h4>
                                    <p class="text-muted mb-0" style="font-size:14px;">
                                        <c:choose>
                                            <c:when test="${selectedDate != null}">Viewing report for:
                                                <strong>${selectedDate}</strong></c:when>
                                            <c:otherwise>Select a date to view or generate a report</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                                <%-- Date Picker Form --%>
                                    <form action="${pageContext.request.contextPath}/reports" method="get"
                                        class="date-picker-form">
                                        <label class="form-label mb-0 text-muted"
                                            style="font-size:13px;white-space:nowrap;">Select Date:</label>
                                        <input type="date" class="form-control" name="date" id="reportDate"
                                            value="${selectedDate}" max="${pageContext.request.getAttribute('today')}"
                                            style="width:160px;" />
                                        <button type="submit" class="btn btn-outline-primary btn-sm">
                                            <i class="bi bi-search"></i> View
                                        </button>
                                        <a href="${pageContext.request.contextPath}/reports/generate<c:if test="
                                            ${selectedDate !=null}">?date=${selectedDate}</c:if>"
                                            class="btn btn-primary btn-sm">
                                            <i class="bi bi-arrow-clockwise"></i> Generate
                                        </a>
                                    </form>
                            </div>

                            <c:choose>
                                <c:when test="${report != null}">

                                    <%-- KPI Stats Row --%>
                                        <div class="row g-3 mb-4">
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">MTTR</div>
                                                    <div class="metric-value text-primary">${report.mttrMinutes != null
                                                        ? report.mttrMinutes : 0}</div>
                                                    <div class="text-muted" style="font-size:12px;">minutes</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">MTBF</div>
                                                    <div class="metric-value text-success">${report.mtbfHours != null ?
                                                        report.mtbfHours : 0}</div>
                                                    <div class="text-muted" style="font-size:12px;">hours</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">Avg Load</div>
                                                    <div class="metric-value">${report.avgDailyLoad != null ?
                                                        report.avgDailyLoad : 0}%</div>
                                                    <div class="text-muted" style="font-size:12px;">capacity</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">Max Temp</div>
                                                    <div class="metric-value text-danger">${report.highestTempRecorded
                                                        != null ? report.highestTempRecorded : 0}°C</div>
                                                    <div class="text-muted" style="font-size:12px;">recorded</div>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- Incident Summary --%>
                                            <div class="row g-3 mb-4">
                                                <div class="col-md-6">
                                                    <div class="stat-card">
                                                        <p class="section-title"><i
                                                                class="bi bi-exclamation-octagon me-1"></i>Incident
                                                            Summary</p>
                                                        <table class="table table-borderless mb-0"
                                                            style="font-size:14px;">
                                                            <tr>
                                                                <td class="text-muted">Total Incidents</td>
                                                                <td><strong>${report.totalIncidents != null ?
                                                                        report.totalIncidents : 0}</strong></td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Total Downtime</td>
                                                                <td><strong
                                                                        class="text-danger">${report.totalDowntimeMin !=
                                                                        null ? report.totalDowntimeMin : 0} min</strong>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Critical Incidents</td>
                                                                <td><strong
                                                                        class="text-danger">${report.criticalIncidents
                                                                        != null ? report.criticalIncidents : 0}</strong>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="stat-card">
                                                        <p class="section-title"><i
                                                                class="bi bi-people me-1"></i>Visitor Summary</p>
                                                        <table class="table table-borderless mb-0"
                                                            style="font-size:14px;">
                                                            <tr>
                                                                <td class="text-muted">Total Visitors</td>
                                                                <td><strong>${report.totalVisitors != null ?
                                                                        report.totalVisitors : 0}</strong></td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Overstayed</td>
                                                                <td><strong
                                                                        class="text-warning">${report.overstayedVisitors
                                                                        != null ? report.overstayedVisitors :
                                                                        0}</strong></td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Report Actions --%>
                                                <div class="d-flex gap-2">
                                                    <a href="${pageContext.request.contextPath}/reports/generate?date=${selectedDate}"
                                                        class="btn btn-outline-primary">
                                                        <i class="bi bi-arrow-clockwise"></i> Regenerate Report
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/reports/range"
                                                        class="btn btn-outline-secondary">
                                                        <i class="bi bi-calendar-range"></i> Date Range Report
                                                    </a>
                                                </div>

                                </c:when>
                                <c:otherwise>
                                    <%-- No Report State --%>
                                        <div class="stat-card text-center py-5">
                                            <i class="bi bi-file-earmark-x fs-1 text-muted d-block mb-3"></i>
                                            <h5 style="font-weight:600;">No Report Found</h5>
                                            <p class="text-muted mb-4">
                                                No report has been generated for
                                                <strong>${selectedDate != null ? selectedDate : 'today'}</strong> yet.
                                            </p>
                                            <a href="${pageContext.request.contextPath}/reports/generate<c:if test="
                                                ${selectedDate !=null}">?date=${selectedDate}</c:if>"
                                                class="btn btn-primary">
                                                <i class="bi bi-play-circle"></i> Generate Report Now
                                            </a>
                                        </div>
                                </c:otherwise>
                            </c:choose>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    // Set today as default date if none is selected
                    const dateInput = document.getElementById('reportDate');
                    if (!dateInput.value) {
                        dateInput.value = new Date().toISOString().split('T')[0];
                    }
                    dateInput.max = new Date().toISOString().split('T')[0];
                </script>
            </body>

            </html>
=======
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Daily Consolidated Report</h4></div>
            <form class="d-flex gap-2 align-items-center" method="get" action="${pageContext.request.contextPath}/reports/generate">
                <input type="date" name="date" class="form-control" value="${selectedDate != null ? selectedDate : ''}" style="max-width:180px;" required />
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-arrow-clockwise"></i> Generate
                </button>
                <button type="submit" name="force" value="true" class="btn btn-outline-warning">
                    <i class="bi bi-arrow-repeat"></i> Re-generate
                </button>
                <button type="button" class="btn btn-outline-success" onclick="exportReportCsv()">
                    <i class="bi bi-file-earmark-spreadsheet"></i> Export CSV
                </button>
            </form>
        </div>

        <c:if test="${reportStatus != null}">
            <div class="alert alert-success mb-4">
                <i class="bi bi-check-circle"></i> ${reportStatus}
            </div>
        </c:if>
        
        <c:choose>
            <c:when test="${report != null}">
                <div class="alert alert-secondary mb-4">
                    <strong>Report Date:</strong> ${selectedDate}
                    <span class="ms-3"><strong>Generated At:</strong> ${report.generatedAt != null ? report.generatedAt : 'N/A'}</span>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-3"><div class="stat-card"><h6>MTTR</h6><h3 id="mttrValue" class="text-primary">${report.mttrMinutes} min</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>MTBF</h6><h3 id="mtbfValue" class="text-success">${report.mtbfHours} hrs</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Avg Load</h6><h3 id="avgLoadValue">${report.avgDailyLoad}%</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Max Temp</h6><h3 id="maxTempValue" class="text-danger">${report.highestTempRecorded}°C</h3></div></div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-3"><div class="stat-card"><h6>Avg Room Temp</h6><h3>${report.avgRoomTemperature != null ? report.avgRoomTemperature : '0'}°C</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>UPS Alarms</h6><h3>${report.totalUpsAlarms != null ? report.totalUpsAlarms : 0}</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Cooling Failure</h6><h3 class="${report.coolingFailure ? 'text-danger' : 'text-success'}">${report.coolingFailure ? 'Yes' : 'No'}</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Generator Failover</h6><h3 class="${report.failoverToGenerator ? 'text-warning' : 'text-success'}">${report.failoverToGenerator ? 'Used' : 'Not Used'}</h3></div></div>
                </div>
                
                <div class="card mb-4">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incident Summary</h6></div>
                    <div class="card-body">
                        <p>Total Incidents: <strong id="totalIncidentsValue">${report.totalIncidents}</strong></p>
                        <p>Total Downtime: <strong id="totalDowntimeValue" class="text-danger">${report.totalDowntimeMin} mins</strong></p>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Facility / Visitor Summary</h6></div>
                    <div class="card-body">
                        <p>Total Visitors: <strong id="totalVisitorsValue">${report.totalVisitors}</strong></p>
                        <p>Overstayed: <strong id="overstayedValue" class="text-warning">${report.overstayedVisitors}</strong></p>
                        <p>High-Risk Visits: <strong>${report.highRiskVisits != null ? report.highRiskVisits : 0}</strong></p>
                        <hr/>
                        <p>Maintenance Performed: <strong>${report.maintenancePerformed != null ? report.maintenancePerformed : 'N/A'}</strong></p>
                        <p>Overdue Maintenance: <strong class="text-danger">${report.overdueMaintenance != null ? report.overdueMaintenance : 'None'}</strong></p>
                        <p>Humidity Stability: <strong>${report.humidityStability != null ? report.humidityStability : 'N/A'}</strong></p>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> No report generated for the selected date. 
                    Use the <strong>Generate</strong> button above to create it.
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script>
        (function ensureDateDefault() {
            var input = document.querySelector('input[name="date"]');
            if (!input) return;
            if (!input.value) {
                var now = new Date();
                var yyyy = now.getFullYear();
                var mm = String(now.getMonth() + 1).padStart(2, '0');
                var dd = String(now.getDate()).padStart(2, '0');
                input.value = yyyy + '-' + mm + '-' + dd;
            }
        })();

        function exportReportCsv() {
            var hasReport = document.getElementById('mttrValue');
            if (!hasReport) {
                alert('Generate a report first, then export CSV.');
                return;
            }

            var dateInput = document.querySelector('input[name="date"]');
            var reportDate = dateInput && dateInput.value ? dateInput.value : '';
            var rows = [
                ['Metric', 'Value'],
                ['Report Date', reportDate],
                ['MTTR (min)', document.getElementById('mttrValue').textContent.replace(' min', '').trim()],
                ['MTBF (hrs)', document.getElementById('mtbfValue').textContent.replace(' hrs', '').trim()],
                ['Average Load (%)', document.getElementById('avgLoadValue').textContent.replace('%', '').trim()],
                ['Max Temperature (C)', document.getElementById('maxTempValue').textContent.replace('°C', '').trim()],
                ['Total Incidents', document.getElementById('totalIncidentsValue').textContent.trim()],
                ['Total Downtime (min)', document.getElementById('totalDowntimeValue').textContent.replace(' mins', '').trim()],
                ['Total Visitors', document.getElementById('totalVisitorsValue').textContent.trim()],
                ['Overstayed Visitors', document.getElementById('overstayedValue').textContent.trim()]
            ];

            var csv = rows.map(function(r) {
                return r.map(function(v) {
                    return '"' + String(v).replace(/"/g, '""') + '"';
                }).join(',');
            }).join('\n');

            var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'daily-report-' + (reportDate || 'today') + '.csv';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(link.href);
        }
    </script>
</body>
</html>
>>>>>>> 95d3dde38a0a3ac562ab98aa5d020b1495d27cbd
