<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Branch Performance Range</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Branch Performance Range Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">${selectedBranch} - Performance from ${startDate} to ${endDate}</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports/branch-performance" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        
        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Avg Load %</th>
                        <th>Peak Load %</th>
                        <th>Avg Temp °C</th>
                        <th>Max Temp °C</th>
                        <th>Incidents</th>
                        <th>Critical</th>
                        <th>Downtime (min)</th>
                        <th>MTTR (min)</th>
                        <th>MTBF (hrs)</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${reports}">
                    <tr>
                        <td><strong>${r.reportDate}</strong></td>
                        <td>${r.avgDailyLoad}</td>
                        <td>${r.peakLoad}</td>
                        <td>${r.avgRoomTemperature}</td>
                        <td class="${r.highestTempRecorded > 28 ? 'text-danger' : ''}">${r.highestTempRecorded}°C</td>
                        <td>${r.totalIncidents}</td>
                        <td><span class="badge ${r.criticalIncidents > 0 ? 'bg-danger' : 'bg-success'}">${r.criticalIncidents}</span></td>
                        <td class="${r.totalDowntimeMin > 120 ? 'text-danger' : ''}">${r.totalDowntimeMin}</td>
                        <td>${r.mttrMinutes}</td>
                        <td>${r.mtbfHours}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty reports}">
                    <tr><td colspan="10" class="text-center text-muted py-4">No reports found for this branch and date range.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Summary Statistics -->
        <c:if test="${not empty reports}">
        <div class="row g-4 mt-4">
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Average Load (Range)</h6>
                        <h4>${reports.stream().map(r -> r.avgDailyLoad).reduce(BigDecimal.ZERO, (a,b) -> a.add(b)).divide(reports.size(), 2, BigDecimal.ROUND_HALF_UP) != null ? 'Calculating...' : '0'}%</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Incidents</h6>
                        <h4>${reports.stream().mapToInt(r -> r.totalIncidents).sum()}</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Downtime</h6>
                        <h4>${reports.stream().mapToInt(r -> r.totalDowntimeMin).sum()} min</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Avg MTBF</h6>
                        <h4>${reports.stream().map(r -> r.mtbfHours).reduce(BigDecimal.ZERO, (a,b) -> a.add(b)).divide(reports.size(), 2, BigDecimal.ROUND_HALF_UP)} hrs</h4>
                    </div>
                </div>
            </div>
        </div>
        </c:if>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
