<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Branch Performance Report</title>
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
                <h4 style="font-weight:700;margin:0;">Branch Performance Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Daily metrics for selected branch - Load, Temperature, Incidents, Downtime</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <!-- Branch Selection -->
        <form method="get" class="mb-4">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label">Select Branch</label>
                    <select name="branch" class="form-select" onchange="this.form.submit()">
                        <c:forEach var="b" items="${branches}">
                            <option value="${b}" ${b eq selectedBranch ? 'selected' : ''}>${b}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-8">
                    <a href="${pageContext.request.contextPath}/reports/branch-performance/range?branch=${selectedBranch}&start=${date.minusMonths(1)}&end=${date}" class="btn btn-outline-primary">
                        <i class="bi bi-graph-up"></i> View Date Range
                    </a>
                    <a href="${pageContext.request.contextPath}/reports/branch-performance/comparison?date=${date}" class="btn btn-outline-info">
                        <i class="bi bi-diagram-3"></i> Compare All Branches
                    </a>
                </div>
            </div>
        </form>

        <c:choose>
            <c:when test="${report != null}">
                <!-- Key Metrics Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Average Load</h6>
                            <h3 class="text-primary">${report.avgDailyLoad}%</h3>
                            <small class="text-muted">Peak: ${report.peakLoad}%</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Avg Temperature</h6>
                            <h3 class="text-warning">${report.avgRoomTemperature}°C</h3>
                            <small class="text-muted">Max: ${report.highestTempRecorded}°C</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Total Incidents</h6>
                            <h3 class="text-danger">${report.totalIncidents}</h3>
                            <small class="text-muted">Critical: ${report.criticalIncidents}</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Total Downtime</h6>
                            <h3 class="${report.totalDowntimeMin > 60 ? 'text-danger' : 'text-success'}">${report.totalDowntimeMin} min</h3>
                            <small class="text-muted">MTTR: ${report.mttrMinutes} min</small>
                        </div>
                    </div>
                </div>

                <!-- Reliability Metrics -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                            <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Reliability Metrics (MTBF)</h6></div>
                            <div class="card-body">
                                <p>Mean Time Between Failures (MTBF): <strong class="text-success">${report.mtbfHours} hours</strong></p>
                                <div class="progress" style="height: 25px;">
                                    <div class="progress-bar bg-success" role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100">
                                        ${report.mtbfHours > 24 ? 'Healthy (>24h)' : report.mtbfHours}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Details</h6></div>
                            <div class="card-body">
                                <p>UPS Alarms: <strong>${report.totalUpsAlarms}</strong></p>
                                <p>Active Users (Branch): <strong>${report.userCount}</strong></p>
                                <p>Visitors: <strong>${report.totalVisitors}</strong></p>
                                <p>Report Generated: <strong>${report.generatedAt}</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${report.highestTempRecorded > 28}">
                    <div class="alert alert-warning alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle"></i> <strong>High Temperature Warning!</strong> Maximum recorded temperature (${report.highestTempRecorded}°C) exceeds recommended threshold (28°C).
                    </div>
                </c:if>
                <c:if test="${report.totalDowntimeMin > 120}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-circle"></i> <strong>Significant Downtime!</strong> Total downtime (${report.totalDowntimeMin} minutes) is above acceptable levels.
                    </div>
                </c:if>

            </c:when>
            <c:when test="${message != null}">
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> ${message}
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> No report generated for the selected branch and date.
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
