<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Downtime Analysis Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 style="font-weight:700;margin:0;">Downtime Analysis Report</h4>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-primary btn-sm">Back to Daily Report</a>
        </div>

        <div class="row g-4">
            <div class="col-md-3"><div class="stat-card"><h6>Total Downtime</h6><h3>${report.totalDowntimeMinutes} min</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Total Hours</h6><h3>${report.totalDowntimeHours}</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Incidents</h6><h3>${report.incidentCount}</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Critical Incidents</h6><h3 class="text-danger">${report.criticalIncidents}</h3></div></div>
        </div>

        <div class="card mt-4">
            <div class="card-body">
                <p class="mb-1">Average Downtime per Incident: <strong>${report.avgDowntimePerIncident} min</strong></p>
                <small class="text-muted">Range: ${report.dateRange}</small><br>
                <small class="text-muted">Generated: ${report.generatedAt}</small>
            </div>
        </div>
    </div>
</body>
</html>
