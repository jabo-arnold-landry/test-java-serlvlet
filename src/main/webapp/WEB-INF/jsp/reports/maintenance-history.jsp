<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Maintenance History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h4 style="font-weight:700;margin:0;">Maintenance History Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">UPS and Cooling maintenance events</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
        </div>

        <form class="row g-2 align-items-end mb-4" method="get" action="${pageContext.request.contextPath}/reports/maintenance-history">
            <div class="col-auto">
                <label class="form-label">Start</label>
                <input type="date" class="form-control" name="start" value="${selectedStart}">
            </div>
            <div class="col-auto">
                <label class="form-label">End</label>
                <input type="date" class="form-control" name="end" value="${selectedEnd}">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary"><i class="bi bi-funnel"></i> Apply</button>
            </div>
        </form>

        <div class="row g-3 mb-4">
            <div class="col-md-4"><div class="stat-card text-center"><div class="text-muted">Total</div><div class="fw-bold">${totalMaintenance}</div></div></div>
            <div class="col-md-4"><div class="stat-card text-center"><div class="text-muted">UPS</div><div class="fw-bold text-primary">${upsMaintenanceCount}</div></div></div>
            <div class="col-md-4"><div class="stat-card text-center"><div class="text-muted">Cooling</div><div class="fw-bold text-info">${coolingMaintenanceCount}</div></div></div>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Asset Type</th>
                        <th>Asset Tag</th>
                        <th>Asset Name</th>
                        <th>Maintenance Type</th>
                        <th>Next Due</th>
                        <th>Technician</th>
                        <th>Vendor</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${maintenanceHistory}">
                    <tr>
                        <td>${r.maintenanceDate}</td>
                        <td>${r.assetType}</td>
                        <td>${r.assetTag}</td>
                        <td>${r.assetName}</td>
                        <td>${r.maintenanceType}</td>
                        <td>${r.nextDueDate}</td>
                        <td>${r.technician}</td>
                        <td>${r.vendor}</td>
                        <td>${r.remarks}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty maintenanceHistory}">
                    <tr><td colspan="9" class="text-center text-muted py-4">No maintenance records found for this date range.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
