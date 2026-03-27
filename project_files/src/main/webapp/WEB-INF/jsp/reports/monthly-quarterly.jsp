<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Monthly/Quarterly Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 style="font-weight:700;margin:0;">Monthly / Quarterly Report</h4>
            <div class="btn-group" role="group">
                <a href="${pageContext.request.contextPath}/reports/monthly-quarterly?period=MONTH" class="btn btn-outline-primary btn-sm">Monthly</a>
                <a href="${pageContext.request.contextPath}/reports/monthly-quarterly?period=QUARTER" class="btn btn-outline-primary btn-sm">Quarterly</a>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-4"><div class="stat-card"><h6>Period</h6><h3>${report.period}</h3></div></div>
            <div class="col-md-4"><div class="stat-card"><h6>Days in Period</h6><h3>${report.daysInPeriod}</h3></div></div>
            <div class="col-md-4"><div class="stat-card"><h6>Incidents</h6><h3>${report.incidentCount}</h3></div></div>
        </div>

        <div class="card mt-4">
            <div class="card-body">
                <p class="mb-1">Total Downtime: <strong>${report.totalDowntimeMinutes} minutes</strong></p>
                <small class="text-muted">Generated: ${report.generatedAt}</small>
            </div>
        </div>
    </div>
</body>
</html>
