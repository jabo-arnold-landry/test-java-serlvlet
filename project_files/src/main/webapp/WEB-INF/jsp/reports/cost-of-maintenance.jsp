<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Maintenance Cost Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 style="font-weight:700;margin:0;">Maintenance Cost Report</h4>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-primary btn-sm">Back to Daily Report</a>
        </div>

        <div class="row g-4">
            <div class="col-md-3"><div class="stat-card"><h6>Labor Cost</h6><h3>$${report.laborCost}</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Downtime Cost</h6><h3 class="text-danger">$${report.downtimeCost}</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Parts Cost</h6><h3>$${report.partsCost}</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Total Cost</h6><h3 class="text-primary">$${report.totalCost}</h3></div></div>
        </div>

        <div class="card mt-4">
            <div class="card-body">
                <p class="mb-1">Incident Count: <strong>${report.incidentCount}</strong></p>
                <p class="mb-1">Average Cost per Incident: <strong>$${report.avgCostPerIncident}</strong></p>
                <small class="text-muted">Range: ${report.dateRange}</small><br>
                <small class="text-muted">Generated: ${report.generatedAt}</small>
            </div>
        </div>
    </div>
</body>
</html>
