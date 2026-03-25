<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Maintenance Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .report-stat {
            text-align: center; padding: 24px;
        }
        .report-stat h2 {
            font-size: 2rem; font-weight: 700; margin: 0;
        }
        .report-stat p {
            font-size: 13px; color: #6b7280; margin: 4px 0 0;
        }
        .stat-icon {
            width: 48px; height: 48px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; margin: 0 auto 10px;
        }
        .stat-icon.blue { background: #eff6ff; color: #3b82f6; }
        .stat-icon.green { background: #f0fdf4; color: #10b981; }
        .stat-icon.orange { background: #fffbeb; color: #f59e0b; }
        .stat-icon.red { background: #fef2f2; color: #ef4444; }
        .stat-icon.purple { background: #faf5ff; color: #8b5cf6; }
        .stat-icon.cyan { background: #ecfeff; color: #06b6d4; }
        .summary-bar {
            height: 8px; border-radius: 4px; background: #e5e7eb; overflow: hidden; margin-top: 6px;
        }
        .summary-bar-fill {
            height: 100%; border-radius: 4px; transition: width 0.6s ease;
        }
        .section-header {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 16px; padding-bottom: 10px;
            border-bottom: 2px solid #e5e7eb;
        }
        .section-header h5 { margin: 0; font-weight: 700; }
        .print-btn { position: fixed; bottom: 30px; right: 30px; z-index: 1001; }
        @media print {
            .sidebar, .topbar, .print-btn, .no-print { display: none !important; }
            .main-content { margin: 0 !important; padding: 15px !important; }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Maintenance Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Complete overview of all maintenance activities, statistics, and status</p>
            </div>
            <div class="d-flex gap-2 no-print">
                <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Back to Maintenance
                </a>
                <button onclick="window.print()" class="btn btn-outline-primary">
                    <i class="bi bi-printer"></i> Print Report
                </button>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-2">
                <div class="stat-card report-stat">
                    <div class="stat-icon blue"><i class="bi bi-battery-charging"></i></div>
                    <h2 class="text-primary">${totalUps}</h2>
                    <p>Total UPS Maintenance</p>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card report-stat">
                    <div class="stat-icon cyan"><i class="bi bi-snow2"></i></div>
                    <h2 class="text-info">${totalCooling}</h2>
                    <p>Total Cooling Maintenance</p>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card report-stat">
                    <div class="stat-icon green"><i class="bi bi-shield-check"></i></div>
                    <h2 class="text-success">${upsPreventive + coolingPreventive}</h2>
                    <p>Preventive Total</p>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card report-stat">
                    <div class="stat-icon orange"><i class="bi bi-tools"></i></div>
                    <h2 class="text-warning">${upsCorrective + coolingCorrective}</h2>
                    <p>Corrective Total</p>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card report-stat">
                    <div class="stat-icon red"><i class="bi bi-exclamation-triangle"></i></div>
                    <c:set var="overdueCount" value="${overdueUps.size() + overdueCooling.size()}" />
                    <h2 class="text-danger">${overdueCount}</h2>
                    <p>Overdue</p>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card report-stat">
                    <div class="stat-icon purple"><i class="bi bi-calendar-event"></i></div>
                    <c:set var="upcomingCount" value="${upcomingUps.size() + upcomingCooling.size()}" />
                    <h2 style="color:#8b5cf6;">${upcomingCount}</h2>
                    <p>Upcoming (30 days)</p>
                </div>
            </div>
        </div>

        <!-- Maintenance Type Breakdown -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-battery-charging text-primary"></i> UPS Maintenance Breakdown</h6>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span style="font-size:14px;">Preventive</span>
                        <span class="badge bg-success bg-opacity-10 text-success border border-success">${upsPreventive}</span>
                    </div>
                    <div class="summary-bar mb-3">
                        <c:set var="upsPrevPct" value="${totalUps > 0 ? (upsPreventive * 100 / totalUps) : 0}" />
                        <div class="summary-bar-fill" style="width:${upsPrevPct}%;background:#10b981;"></div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span style="font-size:14px;">Corrective</span>
                        <span class="badge bg-warning bg-opacity-10 text-warning border border-warning">${upsCorrective}</span>
                    </div>
                    <div class="summary-bar">
                        <c:set var="upsCorrPct" value="${totalUps > 0 ? (upsCorrective * 100 / totalUps) : 0}" />
                        <div class="summary-bar-fill" style="width:${upsCorrPct}%;background:#f59e0b;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-snow2 text-info"></i> Cooling Maintenance Breakdown</h6>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span style="font-size:14px;">Preventive</span>
                        <span class="badge bg-success bg-opacity-10 text-success border border-success">${coolingPreventive}</span>
                    </div>
                    <div class="summary-bar mb-3">
                        <c:set var="coolPrevPct" value="${totalCooling > 0 ? (coolingPreventive * 100 / totalCooling) : 0}" />
                        <div class="summary-bar-fill" style="width:${coolPrevPct}%;background:#10b981;"></div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span style="font-size:14px;">Corrective</span>
                        <span class="badge bg-warning bg-opacity-10 text-warning border border-warning">${coolingCorrective}</span>
                    </div>
                    <div class="summary-bar">
                        <c:set var="coolCorrPct" value="${totalCooling > 0 ? (coolingCorrective * 100 / totalCooling) : 0}" />
                        <div class="summary-bar-fill" style="width:${coolCorrPct}%;background:#f59e0b;"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Overdue Maintenance Section -->
        <c:if test="${not empty overdueUps || not empty overdueCooling}">
            <div class="section-header">
                <i class="bi bi-exclamation-triangle-fill text-danger" style="font-size:20px;"></i>
                <h5 class="text-danger">Overdue Maintenance</h5>
            </div>

            <c:if test="${not empty overdueUps}">
                <h6 class="mb-2 text-muted">UPS — Overdue</h6>
                <div class="table-container mb-3">
                    <table class="table hover">
                        <thead><tr><th>UPS Asset</th><th>Type</th><th>Maintenance Date</th><th>Due Date</th><th>Technician</th><th>Vendor</th></tr></thead>
                        <tbody>
                            <c:forEach var="m" items="${overdueUps}">
                            <tr class="table-danger">
                                <td><strong>${m.ups.assetTag}</strong></td><td>${m.maintenanceType}</td>
                                <td>${m.maintenanceDate}</td><td class="fw-bold">${m.nextDueDate}</td>
                                <td>${m.technician}</td><td>${m.vendor}</td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <c:if test="${not empty overdueCooling}">
                <h6 class="mb-2 text-muted">Cooling — Overdue</h6>
                <div class="table-container mb-4">
                    <table class="table hover">
                        <thead><tr><th>Cooling Asset</th><th>Type</th><th>Maintenance Date</th><th>Due Date</th><th>Technician</th><th>Vendor</th></tr></thead>
                        <tbody>
                            <c:forEach var="m" items="${overdueCooling}">
                            <tr class="table-danger">
                                <td><strong>${m.coolingUnit.assetTag}</strong></td><td>${m.maintenanceType}</td>
                                <td>${m.maintenanceDate}</td><td class="fw-bold">${m.nextMaintenanceDate}</td>
                                <td>${m.technician}</td><td>${m.vendor}</td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>
        </c:if>

        <!-- Upcoming Maintenance Section -->
        <c:if test="${not empty upcomingUps || not empty upcomingCooling}">
            <div class="section-header">
                <i class="bi bi-calendar-event" style="font-size:20px;color:#8b5cf6;"></i>
                <h5 style="color:#8b5cf6;">Upcoming Maintenance (Next 30 Days)</h5>
            </div>

            <c:if test="${not empty upcomingUps}">
                <h6 class="mb-2 text-muted">UPS — Upcoming</h6>
                <div class="table-container mb-3">
                    <table class="table hover">
                        <thead><tr><th>UPS Asset</th><th>Type</th><th>Scheduled Date</th><th>Technician</th><th>Vendor</th><th>Remarks</th></tr></thead>
                        <tbody>
                            <c:forEach var="m" items="${upcomingUps}">
                            <tr>
                                <td><strong>${m.ups.assetTag}</strong></td><td>${m.maintenanceType}</td>
                                <td>${m.nextDueDate}</td><td>${m.technician}</td>
                                <td>${m.vendor}</td><td>${m.remarks}</td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <c:if test="${not empty upcomingCooling}">
                <h6 class="mb-2 text-muted">Cooling — Upcoming</h6>
                <div class="table-container mb-4">
                    <table class="table hover">
                        <thead><tr><th>Cooling Asset</th><th>Type</th><th>Scheduled Date</th><th>Technician</th><th>Vendor</th><th>Remarks</th></tr></thead>
                        <tbody>
                            <c:forEach var="m" items="${upcomingCooling}">
                            <tr>
                                <td><strong>${m.coolingUnit.assetTag}</strong></td><td>${m.maintenanceType}</td>
                                <td>${m.nextMaintenanceDate}</td><td>${m.technician}</td>
                                <td>${m.vendor}</td><td>${m.remarks}</td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>
        </c:if>

        <!-- Full UPS Maintenance History -->
        <div class="section-header">
            <i class="bi bi-battery-charging text-primary" style="font-size:20px;"></i>
            <h5>Complete UPS Maintenance History</h5>
        </div>
        <div class="table-container mb-4">
            <table class="table hover">
                <thead>
                    <tr><th>ID</th><th>UPS Asset</th><th>Type</th><th>Date</th><th>Next Due</th><th>Technician</th><th>Vendor</th><th>Spare Parts</th><th>Remarks</th><th>Report</th></tr>
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
                        <td>${m.maintenanceDate}</td><td>${m.nextDueDate}</td>
                        <td>${m.technician}</td><td>${m.vendor}</td>
                        <td>${m.sparePartsUsed}</td><td>${m.remarks}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/ups/${m.maintenanceId}" class="text-success">
                                    <i class="bi bi-file-earmark-check"></i> Yes
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}"><span class="text-muted">—</span></c:if>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allUpsMaintenance}">
                        <tr><td colspan="10" class="text-center text-muted py-3">No UPS maintenance records.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Full Cooling Maintenance History -->
        <div class="section-header">
            <i class="bi bi-snow2 text-info" style="font-size:20px;"></i>
            <h5>Complete Cooling Maintenance History</h5>
        </div>
        <div class="table-container">
            <table class="table hover">
                <thead>
                    <tr><th>ID</th><th>Cooling Asset</th><th>Type</th><th>Date</th><th>Filter Cleaned</th><th>Gas Refill</th><th>Technician</th><th>Vendor</th><th>Next Due</th><th>Remarks</th><th>Report</th></tr>
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
                        <td>${m.maintenanceDate}</td><td>${m.filterCleaningDate}</td>
                        <td>${m.gasRefillDate}</td><td>${m.technician}</td>
                        <td>${m.vendor}</td><td>${m.nextMaintenanceDate}</td>
                        <td>${m.remarks}</td>
                        <td>
                            <c:if test="${not empty m.serviceReportPath}">
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/cooling/${m.maintenanceId}" class="text-success">
                                    <i class="bi bi-file-earmark-check"></i> Yes
                                </a>
                            </c:if>
                            <c:if test="${empty m.serviceReportPath}"><span class="text-muted">—</span></c:if>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allCoolingMaintenance}">
                        <tr><td colspan="11" class="text-center text-muted py-3">No cooling maintenance records.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Floating Print Button -->
    <button onclick="window.print()" class="btn btn-primary btn-lg rounded-circle shadow print-btn no-print" title="Print Report">
        <i class="bi bi-printer"></i>
    </button>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
