<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.context.ApplicationContext" %>
<%@ page import="com.spcms.repositories.UpsMaintenanceRepository" %>
<%@ page import="com.spcms.repositories.CoolingMaintenanceRepository" %>
<%@ page import="org.springframework.data.domain.Sort" %>
<%
    ApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(config.getServletContext());
    UpsMaintenanceRepository upsRepo = ctx.getBean(UpsMaintenanceRepository.class);
    CoolingMaintenanceRepository coolRepo = ctx.getBean(CoolingMaintenanceRepository.class);
    request.setAttribute("allUpsMaintenance", upsRepo.findAll(Sort.by(Sort.Direction.DESC, "maintenanceDate")));
    request.setAttribute("allCoolingMaintenance", coolRepo.findAll(Sort.by(Sort.Direction.DESC, "maintenanceDate")));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Preventive Maintenance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .btn-action { padding: 4px 10px; font-size: 12px; border-radius: 6px; }
        .badge-overdue { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
        .badge-upcoming { background: #fffbeb; color: #d97706; border: 1px solid #fde68a; }
        .badge-completed { background: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; }
        .section-divider { border-top: 2px solid #e5e7eb; margin: 30px 0 20px; }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Preventive Maintenance Module</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Manage, track, and schedule all maintenance activities</p>
            </div>
            <div class="d-flex gap-2">
                <form action="${pageContext.request.contextPath}/maintenance/generate-reminders" method="post" style="display:inline;">
                    <button type="submit" class="btn btn-outline-warning shadow-sm" title="Generate maintenance reminders now">
                        <i class="bi bi-bell"></i> Generate Reminders
                    </button>
                </form>
                <a href="${pageContext.request.contextPath}/maintenance/report" class="btn btn-outline-success shadow-sm">
                    <i class="bi bi-file-earmark-bar-graph"></i> Maintenance Report
                </a>
                <a href="${pageContext.request.contextPath}/maintenance/ups/new" class="btn btn-primary shadow-sm">
                    <i class="bi bi-battery-charging"></i> Log UPS Maint
                </a>
                <a href="${pageContext.request.contextPath}/maintenance/cooling/new" class="btn btn-info text-white shadow-sm">
                    <i class="bi bi-snow2"></i> Log Cooling Maint
                </a>
            </div>
        </div>

        <!-- Success/Error Messages -->
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

        <!-- Overdue UPS Maintenance -->
        <h6 class="mb-3 text-danger"><i class="bi bi-exclamation-circle-fill"></i> Overdue & Upcoming UPS Maintenance</h6>
        <div class="table-container mb-4">
            <table class="table hover">
                <thead>
                    <tr>
                        <th>UPS Asset</th><th>Type</th><th>Maintenance Date</th>
                        <th>Next Due Date</th><th>Technician</th><th>Vendor</th><th>Service Report</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${overdueUps}">
                    <tr class="table-danger">
                        <td><strong>${m.ups.assetTag}</strong></td>
                        <td>
                            <span class="badge badge-overdue">OVERDUE</span> 
                            <small class="text-muted d-block mt-1" style="font-size:11px;">${m.maintenanceType}</small>
                        </td>
                        <td>${m.maintenanceDate}</td>
                        <td class="text-danger fw-bold">${m.nextDueDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.vendor}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/ups/${m.maintenanceId}"
                                   class="btn btn-sm btn-outline-secondary" title="Download Service Report">
                                    <i class="bi bi-file-earmark-arrow-down"></i>
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}">
                                <span class="text-muted">—</span>
                            </c:if>
                        </td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance/ups/edit/${m.maintenanceId}"
                                   class="btn btn-outline-primary btn-action" title="Edit">
                                    <i class="bi bi-pencil-square"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/maintenance/ups/delete/${m.maintenanceId}"
                                      method="post" onsubmit="return confirm('Are you sure you want to delete this UPS maintenance record?');">
                                    <button type="submit" class="btn btn-outline-danger btn-action" title="Delete">
                                        <i class="bi bi-trash3"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>

                    <c:forEach var="m" items="${upcomingUps}">
                    <tr class="table-warning">
                        <td><strong>${m.ups.assetTag}</strong></td>
                        <td>
                            <span class="badge badge-upcoming">UPCOMING</span> 
                            <small class="text-muted d-block mt-1" style="font-size:11px;">${m.maintenanceType}</small>
                        </td>
                        <td>${m.maintenanceDate}</td>
                        <td class="text-warning text-dark fw-bold">${m.nextDueDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.vendor}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/ups/${m.maintenanceId}"
                                   class="btn btn-sm btn-outline-secondary" title="Download Service Report">
                                    <i class="bi bi-file-earmark-arrow-down"></i>
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}">
                                <span class="text-muted">—</span>
                            </c:if>
                        </td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance/ups/edit/${m.maintenanceId}"
                                   class="btn btn-outline-primary btn-action" title="Edit">
                                    <i class="bi bi-pencil-square"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/maintenance/ups/delete/${m.maintenanceId}"
                                      method="post" onsubmit="return confirm('Are you sure you want to delete this UPS maintenance record?');">
                                    <button type="submit" class="btn btn-outline-danger btn-action" title="Delete">
                                        <i class="bi bi-trash3"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>

                    <c:if test="${empty overdueUps and empty upcomingUps}">
                        <tr><td colspan="8" class="text-center text-muted py-3">
                            <i class="bi bi-check-circle text-success"></i> No overdue or upcoming UPS maintenance. All up to date!
                        </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Overdue Cooling Maintenance -->
        <h6 class="mb-3 text-primary"><i class="bi bi-exclamation-circle-fill"></i> Overdue & Upcoming Cooling Maintenance</h6>
        <div class="table-container mb-4">
            <table class="table hover">
                <thead>
                    <tr>
                        <th>Cooling Asset</th><th>Type</th><th>Date</th>
                        <th>Filter Cleaned</th><th>Technician</th><th>Next Due</th><th>Service Report</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${overdueCooling}">
                    <tr class="table-danger">
                        <td><strong>${m.coolingUnit.assetTag}</strong></td>
                        <td>
                            <span class="badge badge-overdue">OVERDUE</span>
                            <small class="text-muted d-block mt-1" style="font-size:11px;">${m.maintenanceType}</small>
                        </td>
                        <td>${m.maintenanceDate}</td>
                        <td>${m.filterCleaningDate}</td>
                        <td>${m.technician}</td>
                        <td class="text-danger fw-bold">${m.nextMaintenanceDate}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/cooling/${m.maintenanceId}"
                                   class="btn btn-sm btn-outline-secondary" title="Download Service Report">
                                    <i class="bi bi-file-earmark-arrow-down"></i>
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}">
                                <span class="text-muted">—</span>
                            </c:if>
                        </td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance/cooling/edit/${m.maintenanceId}"
                                   class="btn btn-outline-primary btn-action" title="Edit">
                                    <i class="bi bi-pencil-square"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/maintenance/cooling/delete/${m.maintenanceId}"
                                      method="post" onsubmit="return confirm('Are you sure you want to delete this Cooling maintenance record?');">
                                    <button type="submit" class="btn btn-outline-danger btn-action" title="Delete">
                                        <i class="bi bi-trash3"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>

                    <c:forEach var="m" items="${upcomingCooling}">
                    <tr class="table-warning">
                        <td><strong>${m.coolingUnit.assetTag}</strong></td>
                        <td>
                            <span class="badge badge-upcoming">UPCOMING</span>
                            <small class="text-muted d-block mt-1" style="font-size:11px;">${m.maintenanceType}</small>
                        </td>
                        <td>${m.maintenanceDate}</td>
                        <td>${m.filterCleaningDate}</td>
                        <td>${m.technician}</td>
                        <td class="text-warning text-dark fw-bold">${m.nextMaintenanceDate}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/cooling/${m.maintenanceId}"
                                   class="btn btn-sm btn-outline-secondary" title="Download Service Report">
                                    <i class="bi bi-file-earmark-arrow-down"></i>
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}">
                                <span class="text-muted">—</span>
                            </c:if>
                        </td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance/cooling/edit/${m.maintenanceId}"
                                   class="btn btn-outline-primary btn-action" title="Edit">
                                    <i class="bi bi-pencil-square"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/maintenance/cooling/delete/${m.maintenanceId}"
                                      method="post" onsubmit="return confirm('Are you sure you want to delete this Cooling maintenance record?');">
                                    <button type="submit" class="btn btn-outline-danger btn-action" title="Delete">
                                        <i class="bi bi-trash3"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>

                    <c:if test="${empty overdueCooling and empty upcomingCooling}">
                        <tr><td colspan="8" class="text-center text-muted py-3">
                            <i class="bi bi-check-circle text-success"></i> No overdue or upcoming Cooling maintenance. All up to date!
                        </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <div class="section-divider"></div>

        <!-- All UPS Maintenance History -->
        <h6 class="mb-3"><i class="bi bi-battery-charging text-primary"></i> All UPS Maintenance Records</h6>
        <div class="table-container mb-4">
            <table class="table hover">
                <thead>
                    <tr>
                        <th>ID</th><th>UPS Asset</th><th>Type</th><th>Maintenance Date</th>
                        <th>Next Due</th><th>Technician</th><th>Vendor</th><th>Service Report</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${allUpsMaintenance}">
                    <tr>
                        <td>${m.maintenanceId}</td>
                        <td><strong>${m.ups.assetTag}</strong></td>
                        <td>
                            <c:choose>
                                <c:when test="${m.maintenanceType == 'PREVENTIVE'}">
                                    <span class="badge bg-success bg-opacity-10 text-success border border-success">PREVENTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-warning bg-opacity-10 text-warning border border-warning">CORRECTIVE</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${m.maintenanceDate}</td>
                        <td>${m.nextDueDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.vendor}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/ups/${m.maintenanceId}"
                                   class="btn btn-sm btn-outline-secondary" title="Download Report">
                                    <i class="bi bi-file-earmark-arrow-down"></i> Download
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}">
                                <span class="text-muted">No report</span>
                            </c:if>
                        </td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance/ups/edit/${m.maintenanceId}"
                                   class="btn btn-outline-primary btn-action" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                <form action="${pageContext.request.contextPath}/maintenance/ups/delete/${m.maintenanceId}"
                                      method="post" onsubmit="return confirm('Delete this UPS maintenance record?');" style="display:inline;">
                                    <button type="submit" class="btn btn-outline-danger btn-action" title="Delete"><i class="bi bi-trash3"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allUpsMaintenance}">
                        <tr><td colspan="9" class="text-center text-muted py-3">No UPS maintenance records found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- All Cooling Maintenance History -->
        <h6 class="mb-3"><i class="bi bi-snow2 text-info"></i> All Cooling Maintenance Records</h6>
        <div class="table-container">
            <table class="table hover">
                <thead>
                    <tr>
                        <th>ID</th><th>Cooling Asset</th><th>Type</th><th>Date</th>
                        <th>Filter Cleaned</th><th>Gas Refill</th><th>Technician</th><th>Next Due</th><th>Service Report</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${allCoolingMaintenance}">
                    <tr>
                        <td>${m.maintenanceId}</td>
                        <td><strong>${m.coolingUnit.assetTag}</strong></td>
                        <td>
                            <c:choose>
                                <c:when test="${m.maintenanceType == 'PREVENTIVE'}">
                                    <span class="badge bg-success bg-opacity-10 text-success border border-success">PREVENTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-warning bg-opacity-10 text-warning border border-warning">CORRECTIVE</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${m.maintenanceDate}</td>
                        <td>${m.filterCleaningDate}</td>
                        <td>${m.gasRefillDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.nextMaintenanceDate}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/cooling/${m.maintenanceId}"
                                   class="btn btn-sm btn-outline-secondary" title="Download Report">
                                    <i class="bi bi-file-earmark-arrow-down"></i> Download
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}">
                                <span class="text-muted">No report</span>
                            </c:if>
                        </td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance/cooling/edit/${m.maintenanceId}"
                                   class="btn btn-outline-primary btn-action" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                <form action="${pageContext.request.contextPath}/maintenance/cooling/delete/${m.maintenanceId}"
                                      method="post" onsubmit="return confirm('Delete this Cooling maintenance record?');" style="display:inline;">
                                    <button type="submit" class="btn btn-outline-danger btn-action" title="Delete"><i class="bi bi-trash3"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allCoolingMaintenance}">
                        <tr><td colspan="10" class="text-center text-muted py-3">No cooling maintenance records found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>