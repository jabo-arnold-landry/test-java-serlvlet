<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Maintenance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Maintenance Scheduler</h4></div>
            <div>
                <a href="${pageContext.request.contextPath}/maintenance/ups/new" class="btn btn-outline-primary shadow-sm me-2"><i class="bi bi-battery-charging"></i> Log UPS Maint</a>
                <a href="${pageContext.request.contextPath}/maintenance/cooling/new" class="btn btn-outline-info shadow-sm"><i class="bi bi-snow2"></i> Log Cooling Maint</a>
            </div>
        </div>
        
        <h6 class="mb-3 text-danger"><i class="bi bi-exclamation-circle-fill"></i> Overdue UPS Maintenance</h6>
        <div class="table-container mb-5">
            <table class="table hover">
                <thead><tr><th>UPS ID</th><th>Type</th><th>Maintenance Date</th><th>Next Due Date</th><th>Technician</th><th>Vendor</th></tr></thead>
                <tbody>
                    <c:forEach var="m" items="${overdueUps}">
                    <tr class="table-warning">
                        <td><strong>${m.ups.assetTag}</strong></td><td>${m.maintenanceType}</td>
                        <td>${m.maintenanceDate}</td><td class="text-danger fw-bold">${m.nextDueDate}</td>
                        <td>${m.technician}</td><td>${m.vendor}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty overdueUps}"><tr><td colspan="6" class="text-center text-muted">No overdue UPS maintenance.</td></tr></c:if>
                </tbody>
            </table>
        </div>

        <h6 class="mb-3 text-secondary"><i class="bi bi-clock-history"></i> UPS Maintenance History</h6>
        <div class="table-container mb-5">
            <table class="table hover">
                <thead><tr><th>UPS ID</th><th>Type</th><th>Maintenance Date</th><th>Next Due Date</th><th>Technician</th><th>Vendor</th></tr></thead>
                <tbody>
                    <c:forEach var="m" items="${allUpsMaintenance}">
                    <tr>
                        <td><strong>${m.ups.assetTag}</strong></td><td>${m.maintenanceType}</td>
                        <td>${m.maintenanceDate}</td><td>${m.nextDueDate}</td>
                        <td>${m.technician}</td><td>${m.vendor}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allUpsMaintenance}"><tr><td colspan="6" class="text-center text-muted">No UPS maintenance history found.</td></tr></c:if>
                </tbody>
            </table>
        </div>

        <h6 class="mb-3 text-primary"><i class="bi bi-card-checklist"></i> Cooling Maintenance History</h6>
        <div class="table-container">
            <table class="table hover">
                <thead><tr><th>Cooling ID</th><th>Type</th><th>Date</th><th>Filter Cleaned</th><th>Technician</th><th>Next Due</th></tr></thead>
                <tbody>
                    <c:forEach var="m" items="${allCoolingMaintenance}">
                    <tr>
                        <td><strong>${m.coolingUnit.assetTag}</strong></td><td>${m.maintenanceType}</td>
                        <td>${m.maintenanceDate}</td><td>${m.filterCleaningDate}</td>
                        <td>${m.technician}</td><td>${m.nextMaintenanceDate}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allCoolingMaintenance}"><tr><td colspan="6" class="text-center text-muted">No cooling maintenance records found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
