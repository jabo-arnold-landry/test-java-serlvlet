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
