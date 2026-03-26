<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Monthly Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Monthly Consolidated Report</h4></div>
        </div>

        <div class="card mb-4">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/reports/monthly" method="get" class="row g-3 align-items-center">
                    <div class="col-auto">
                        <label for="year" class="col-form-label">Year</label>
                    </div>
                    <div class="col-auto">
                        <input type="number" id="year" name="year" class="form-control" value="${selectedYear}">
                    </div>
                    <div class="col-auto">
                        <label for="month" class="col-form-label">Month</label>
                    </div>
                    <div class="col-auto">
                        <select id="month" name="month" class="form-select">
                            <c:forEach var="m" begin="1" end="12">
                                <option value="${m}" ${m == selectedMonth ? 'selected' : ''}>${m}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-auto">
                        <button type="submit" class="btn btn-primary">Generate</button>
                    </div>
                </form>
            </div>
        </div>
        
        <c:choose>
            <c:when test="${report != null}">
                <h5 class="mb-3">Period: ${report.periodName}</h5>
                <div class="row g-4 mb-4">
                    <div class="col-md-3"><div class="stat-card"><h6>MTTR</h6><h3 class="text-primary">${report.mttrMinutes} min</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>MTBF</h6><h3 class="text-success">${report.mtbfHours} hrs</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Avg Load</h6><h3>${report.avgDailyLoad}%</h3></div></div>
                    <div class="col-md-3"><div class="stat-card"><h6>Max Temp</h6><h3 class="text-danger">${report.highestTempRecorded}°C</h3></div></div>
                </div>
                
                <div class="card mb-4">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incident Summary</h6></div>
                    <div class="card-body">
                        <p>Total Incidents: <strong>${report.totalIncidents}</strong></p>
                        <p>Total Downtime: <strong class="text-danger">${report.totalDowntimeMin} mins</strong></p>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Facility / Visitor / Alarm Summary</h6></div>
                    <div class="card-body">
                        <p>Total Ups Alarms: <strong>${report.totalUpsAlarms}</strong></p>
                        <p>Total Visitors: <strong>${report.totalVisitors}</strong></p>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> No report data found for this month.
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
