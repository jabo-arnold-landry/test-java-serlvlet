<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Daily Consolidated Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Daily Consolidated Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Selected date: ${selectedDate}</p>
            </div>
            <form class="d-flex gap-2 align-items-center" method="get" action="${pageContext.request.contextPath}/reports/generate">
                <input type="date" name="date" class="form-control" value="${selectedDate}" style="max-width:180px;" />
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-arrow-clockwise"></i> Generate
                </button>
                <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary">
                    <i class="bi bi-house"></i> Today
                </a>
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
                    <div class="col-md-3"><div class="stat-card"><h6>MTTR</h6><h3 class="text-primary">${report.mttrMinutes != null ? report.mttrMinutes : 0} min</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>MTBF</h6><h3 class="text-success">${report.mtbfHours != null ? report.mtbfHours : 0} hrs</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Avg Load</h6><h3>${report.avgDailyLoad != null ? report.avgDailyLoad : 0}%</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Max Temp</h6><h3 class="text-danger">${report.highestTempRecorded != null ? report.highestTempRecorded : 0}&deg;C</h3></div></div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-3"><div class="stat-card"><h6>Avg Room Temp</h6><h3>${report.avgRoomTemperature != null ? report.avgRoomTemperature : 0}&deg;C</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>UPS Alarms</h6><h3>${report.totalUpsAlarms != null ? report.totalUpsAlarms : 0}</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Cooling Failure</h6><h3 class="${report.coolingFailure ? 'text-danger' : 'text-success'}">${report.coolingFailure ? 'Yes' : 'No'}</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Generator Failover</h6><h3 class="${report.failoverToGenerator ? 'text-warning' : 'text-success'}">${report.failoverToGenerator ? 'Used' : 'Not Used'}</h3></div></div>
                </div>

                <div class="card mb-4">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incident Summary</h6></div>
                    <div class="card-body">
                        <p>Total Incidents: <strong>${report.totalIncidents != null ? report.totalIncidents : 0}</strong></p>
                        <p>Total Downtime: <strong class="text-danger">${report.totalDowntimeMin != null ? report.totalDowntimeMin : 0} mins</strong></p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Facility / Visitor Summary</h6></div>
                    <div class="card-body">
                        <p>Total Visitors: <strong>${report.totalVisitors != null ? report.totalVisitors : 0}</strong></p>
                        <p>Overstayed: <strong class="text-warning">${report.overstayedVisitors != null ? report.overstayedVisitors : 0}</strong></p>
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
                    <i class="bi bi-info-circle"></i> No report generated for the selected date. Use the <strong>Generate</strong> button above to create it.
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
