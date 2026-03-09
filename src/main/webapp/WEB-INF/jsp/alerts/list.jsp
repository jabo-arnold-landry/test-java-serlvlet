<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Alerts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .alert-type-badge { font-size:12px; padding:5px 12px; border-radius:15px; font-weight:600; }
        .alert-type-HIGH_TEMP { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-HUMIDITY { background:rgba(59,130,246,0.1); color:#3b82f6; }
        .alert-type-LOW_BATTERY { background:rgba(245,158,11,0.1); color:#f59e0b; }
        .alert-type-UPS_OVERLOAD { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-MAINTENANCE_DUE { background:rgba(139,92,246,0.1); color:#8b5cf6; }
        .alert-type-EQUIPMENT_FAULT { background:rgba(239,68,68,0.1); color:#ef4444; }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle-fill"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">System Alerts</h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    <span class="badge bg-danger">${unacknowledgedAlerts}</span> unacknowledged alerts
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/alerts/settings" class="btn btn-outline-primary">
                <i class="bi bi-gear"></i> Settings
            </a>
            <a href="${pageContext.request.contextPath}/alerts/test" class="btn btn-outline-success">
                <i class="bi bi-broadcast"></i> Simulation
            </a>
        </div>
        
        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Message</th>
                        <th>Equipment</th>
                        <th>Values</th>
                        <th>Sent</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${alerts}">
                    <tr class="${a.isAcknowledged ? '' : 'table-warning'}">
                        <td>
                            <span class="alert-type-badge alert-type-${a.alertType}">
                                <c:choose>
                                    <c:when test="${a.alertType == 'HIGH_TEMP'}"><i class="bi bi-thermometer-high"></i></c:when>
                                    <c:when test="${a.alertType == 'HUMIDITY'}"><i class="bi bi-droplet"></i></c:when>
                                    <c:when test="${a.alertType == 'LOW_BATTERY'}"><i class="bi bi-battery-half"></i></c:when>
                                    <c:when test="${a.alertType == 'UPS_OVERLOAD'}"><i class="bi bi-lightning"></i></c:when>
                                    <c:otherwise><i class="bi bi-exclamation-triangle"></i></c:otherwise>
                                </c:choose>
                                ${a.alertType}
                            </span>
                        </td>
                        <td style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${a.message}">
                            ${a.message}
                        </td>
                        <td>${a.equipmentType} #${a.equipmentId}</td>
                        <td>
                            <c:if test="${a.actualValue != null && a.thresholdValue != null}">
                                <small class="text-danger fw-bold">${a.actualValue}</small> / 
                                <small class="text-muted">${a.thresholdValue}</small>
                            </c:if>
                        </td>
                        <td>
                            <span class="badge ${a.isSent ? 'bg-success' : 'bg-secondary'}">
                                ${a.isSent ? 'Yes' : 'No'}
                            </span>
                        </td>
                        <td>
                            <span class="badge ${a.isAcknowledged ? 'bg-success' : 'bg-danger'}">
                                ${a.isAcknowledged ? 'Acknowledged' : 'Pending'}
                            </span>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <a href="${pageContext.request.contextPath}/alerts/view/${a.alertId}" class="btn btn-outline-primary" title="View Details">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <c:if test="${!a.isAcknowledged}">
                                    <form action="${pageContext.request.contextPath}/alerts/acknowledge/${a.alertId}" method="post" style="display:inline;">
                                        <button type="submit" class="btn btn-success" title="Acknowledge">
                                            <i class="bi bi-check2"></i>
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty alerts}">
                    <tr><td colspan="7" class="text-center text-muted py-4">
                        <i class="bi bi-bell-slash" style="font-size:32px;"></i>
                        <p class="mb-0 mt-2">No alerts recorded.</p>
                    </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
