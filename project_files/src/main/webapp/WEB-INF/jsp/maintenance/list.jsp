<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
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

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Maintenance Scheduler</h4>
                <small class="text-muted">Manage UPS & Cooling maintenance records</small>
            </div>
            <div class="d-flex gap-2">
                <form action="${pageContext.request.contextPath}/maintenance/generate-reminders" method="post" class="m-0">
                    <button type="submit" class="btn btn-warning shadow-sm">
                        <i class="bi bi-bell"></i> Generate Reminders
                    </button>
                </form>
                <a href="${pageContext.request.contextPath}/maintenance/ups/new"
                   class="btn btn-outline-primary shadow-sm"><i class="bi bi-battery-charging"></i> Log UPS Maint</a>
                <a href="${pageContext.request.contextPath}/maintenance/cooling/new"
                   class="btn btn-outline-info shadow-sm"><i class="bi bi-snow2"></i> Log Cooling Maint</a>
            </div>
        </div>

        <!-- Success/Error messages -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- ==================== Overdue UPS ==================== -->
        <h6 class="mb-3 text-danger"><i class="bi bi-exclamation-circle-fill"></i> Overdue UPS Maintenance</h6>
        <div class="table-container mb-5">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>UPS Asset</th>
                        <th>Type</th>
                        <th>Maintenance Date</th>
                        <th>Next Due Date</th>
                        <th>Technician</th>
                        <th>Vendor</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${overdueUps}">
                        <tr class="table-warning">
                            <td><strong>${m.ups.assetTag}</strong></td>
                            <td>${m.maintenanceType}</td>
                            <td>${m.maintenanceDate}</td>
                            <td class="text-danger fw-bold">${m.nextDueDate}</td>
                            <td>${m.technician}</td>
                            <td>${m.vendor}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty overdueUps}">
                        <tr><td colspan="6" class="text-center text-muted">No overdue UPS maintenance.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- ==================== UPS Maintenance History ==================== -->
        <h6 class="mb-3 text-secondary"><i class="bi bi-clock-history"></i> UPS Maintenance History</h6>
        <div class="table-container mb-5">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>UPS Asset</th>
                        <th>Type</th>
                        <th>Maintenance Date</th>
                        <th>Next Due Date</th>
                        <th>Technician</th>
                        <th>Vendor</th>
                        <th>Service Report</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${allUpsMaintenance}">
                        <tr>
                            <td><strong>${m.ups.assetTag}</strong></td>
                            <td>
                                <span class="badge ${m.maintenanceType == 'PREVENTIVE' ? 'bg-success' : 'bg-danger'}">${m.maintenanceType}</span>
                            </td>
                            <td>${m.maintenanceDate}</td>
                            <td>${m.nextDueDate}</td>
                            <td>${m.technician}</td>
                            <td>${m.vendor}</td>
                            <td>
                                <c:if test="${not empty m.serviceReportPath}">
                                    <a href="${pageContext.request.contextPath}/maintenance/download-report/ups/${m.maintenanceId}"
                                       class="btn btn-sm btn-outline-success" title="Download Report">
                                        <i class="bi bi-file-earmark-arrow-down"></i> Download
                                    </a>
                                </c:if>
                                <c:if test="${empty m.serviceReportPath}">
                                    <span class="text-muted"><i class="bi bi-x-circle"></i> None</span>
                                </c:if>
                            </td>
                            <td>
                                <div class="d-flex gap-1">
                                    <a href="${pageContext.request.contextPath}/maintenance/ups/edit/${m.maintenanceId}"
                                       class="btn btn-sm btn-outline-primary" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/maintenance/ups/delete/${m.maintenanceId}"
                                          method="post" class="m-0"
                                          onsubmit="return confirm('Delete this UPS maintenance record?');">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty allUpsMaintenance}">
                        <tr><td colspan="8" class="text-center text-muted">No UPS maintenance history found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- ==================== Cooling Maintenance History ==================== -->
        <h6 class="mb-3 text-primary"><i class="bi bi-card-checklist"></i> Cooling Maintenance History</h6>
        <div class="table-container">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>Cooling Asset</th>
                        <th>Type</th>
                        <th>Date</th>
                        <th>Filter Cleaned</th>
                        <th>Technician</th>
                        <th>Next Due</th>
                        <th>Service Report</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${allCoolingMaintenance}">
                        <tr>
                            <td><strong>${m.coolingUnit.assetTag}</strong></td>
                            <td>
                                <span class="badge ${m.maintenanceType == 'PREVENTIVE' ? 'bg-success' : 'bg-danger'}">${m.maintenanceType}</span>
                            </td>
                            <td>${m.maintenanceDate}</td>
                            <td>${m.filterCleaningDate}</td>
                            <td>${m.technician}</td>
                            <td>${m.nextMaintenanceDate}</td>
                            <td>
                                <c:if test="${not empty m.serviceReportPath}">
                                    <a href="${pageContext.request.contextPath}/maintenance/download-report/cooling/${m.maintenanceId}"
                                       class="btn btn-sm btn-outline-success" title="Download Report">
                                        <i class="bi bi-file-earmark-arrow-down"></i> Download
                                    </a>
                                </c:if>
                                <c:if test="${empty m.serviceReportPath}">
                                    <span class="text-muted"><i class="bi bi-x-circle"></i> None</span>
                                </c:if>
                            </td>
                            <td>
                                <div class="d-flex gap-1">
                                    <a href="${pageContext.request.contextPath}/maintenance/cooling/edit/${m.maintenanceId}"
                                       class="btn btn-sm btn-outline-primary" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/maintenance/cooling/delete/${m.maintenanceId}"
                                          method="post" class="m-0"
                                          onsubmit="return confirm('Delete this cooling maintenance record?');">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty allCoolingMaintenance}">
                        <tr><td colspan="8" class="text-center text-muted">No cooling maintenance records found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>