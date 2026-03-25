<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Equipment Health</title>
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
                <h4 style="font-weight:700;margin:0;">Equipment Health Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Status snapshot as of ${asOfDate}</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
        </div>

        <form class="row g-2 align-items-end mb-4" method="get" action="${pageContext.request.contextPath}/reports/equipment-health">
            <div class="col-auto">
                <label class="form-label">As of date</label>
                <input type="date" class="form-control" name="asOf" value="${asOfDate}">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary"><i class="bi bi-funnel"></i> Apply</button>
            </div>
        </form>

        <div class="row g-3 mb-4">
            <div class="col-md-2"><div class="stat-card text-center"><div class="text-muted">Total</div><div class="fw-bold">${totalEquipment}</div></div></div>
            <div class="col-md-2"><div class="stat-card text-center"><div class="text-muted">Healthy</div><div class="fw-bold text-success">${healthyCount}</div></div></div>
            <div class="col-md-2"><div class="stat-card text-center"><div class="text-muted">Needs Attention</div><div class="fw-bold text-warning">${needsAttentionCount}</div></div></div>
            <div class="col-md-2"><div class="stat-card text-center"><div class="text-muted">At Risk</div><div class="fw-bold text-warning">${atRiskCount}</div></div></div>
            <div class="col-md-2"><div class="stat-card text-center"><div class="text-muted">Critical</div><div class="fw-bold text-danger">${criticalCount}</div></div></div>
            <div class="col-md-2"><div class="stat-card text-center"><div class="text-muted">Decommissioned</div><div class="fw-bold text-secondary">${decommissionedCount}</div></div></div>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Asset Tag</th>
                        <th>Equipment</th>
                        <th>Type</th>
                        <th>Maintenance Status</th>
                        <th>Health</th>
                        <th>Next Maintenance</th>
                        <th>Warranty</th>
                        <th>End of Life</th>
                        <th>Incidents (30d)</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${equipmentHealth}">
                    <tr>
                        <td>${r.equipment.assetTagNumber}</td>
                        <td>${r.equipment.equipmentName}</td>
                        <td>${r.equipment.equipmentType}</td>
                        <td>${r.equipment.maintenanceStatus}</td>
                        <td>
                            <c:choose>
                                <c:when test="${r.healthStatus == 'Critical'}"><span class="badge bg-danger">Critical</span></c:when>
                                <c:when test="${r.healthStatus == 'At Risk'}"><span class="badge bg-warning text-dark">At Risk</span></c:when>
                                <c:when test="${r.healthStatus == 'Needs Attention'}"><span class="badge bg-warning">Needs Attention</span></c:when>
                                <c:when test="${r.healthStatus == 'Decommissioned'}"><span class="badge bg-secondary">Decommissioned</span></c:when>
                                <c:otherwise><span class="badge bg-success">Healthy</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div>${r.equipment.nextMaintenanceDue}</div>
                            <c:choose>
                                <c:when test="${r.daysToMaintenanceDue == null}"><span class="text-muted">No schedule</span></c:when>
                                <c:when test="${r.daysToMaintenanceDue lt 0}"><span class="text-danger">Overdue by ${-r.daysToMaintenanceDue} days</span></c:when>
                                <c:otherwise><span class="text-muted">Due in ${r.daysToMaintenanceDue} days</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div>${r.equipment.warrantyExpiryDate}</div>
                            <c:choose>
                                <c:when test="${r.warrantyExpired}"><span class="text-danger">Expired</span></c:when>
                                <c:when test="${r.warrantyExpiring}"><span class="text-warning">Expiring</span></c:when>
                                <c:otherwise><span class="text-success">Active</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div>${r.equipment.endOfLife}</div>
                            <c:choose>
                                <c:when test="${r.endOfLife}"><span class="text-danger">Past EOL</span></c:when>
                                <c:when test="${r.endOfLifeSoon}"><span class="text-warning">Approaching</span></c:when>
                                <c:otherwise><span class="text-muted">OK</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${r.incidentsLast30Days}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty equipmentHealth}">
                    <tr><td colspan="9" class="text-center text-muted py-4">No equipment records found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
