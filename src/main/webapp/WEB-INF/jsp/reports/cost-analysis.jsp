<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Cost Analysis Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Cost of Maintenance & Downtime Analysis</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Maintenance costs, repair costs, and downtime impact analysis</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <!-- Branch Selection & Navigation -->
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <label class="form-label">Select Branch</label>
                <form method="get" class="d-flex">
                    <select name="branch" class="form-select" onchange="this.form.submit()">
                        <option value="">-- All Branches --</option>
                        <c:forEach var="b" items="${branches}">
                            <option value="${b}" ${b eq selectedBranch ? 'selected' : ''}>${b}</option>
                        </c:forEach>
                    </select>
                </form>
            </div>
            <div class="col-md-8">
                <label class="form-label">&nbsp;</label>
                <div>
                    <a href="${pageContext.request.contextPath}/reports/cost-analysis/range?branch=${selectedBranch}&start=${date.minusMonths(1)}&end=${date}" class="btn btn-outline-primary btn-sm">
                        <i class="bi bi-graph-up"></i> Trend Analysis
                    </a>
                    <a href="${pageContext.request.contextPath}/reports/cost-analysis/downtime-cost?branch=${selectedBranch}&start=${date.minusMonths(1)}&end=${date}" class="btn btn-outline-warning btn-sm">
                        <i class="bi bi-clock-history"></i> Downtime Cost
                    </a>
                    <a href="${pageContext.request.contextPath}/reports/cost-analysis/maintenance-breakdown?branch=${selectedBranch}&date=${date}" class="btn btn-outline-info btn-sm">
                        <i class="bi bi-pie-chart"></i> Breakdown
                    </a>
                </div>
            </div>
        </div>

        <c:choose>
            <c:when test="${report != null}">
                <!-- Main Cost Metrics -->
                <div class="row g-4 mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Total Maintenance Cost</h6>
                            <h3 class="text-primary">$${report.totalMaintenanceCost}</h3>
                            <small class="text-muted">UPS: $${report.upsMaintenanceCost} | Cooling: $${report.coolingMaintenanceCost}</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Total Repair Cost</h6>
                            <h3 class="text-danger">$${report.totalRepairCost}</h3>
                            <small class="text-muted">Critical: $${report.criticalIncidentCost}</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Downtime Cost Impact</h6>
                            <h3 class="text-warning">$${report.totalDowntimeCost}</h3>
                            <small class="text-muted">${report.totalDowntimeMinutes} min @ $${report.costPerHourLoss}/hr</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Total Operational Cost</h6>
                            <h3 class="text-accent-red">$${report.totalOperationalCost}</h3>
                            <small class="text-muted">Maintenance + Repair + Downtime</small>
                        </div>
                    </div>
                </div>

                <!-- Cost Breakdown -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Maintenance Cost Breakdown</h6></div>
                            <div class="card-body">
                                <p>Preventive Maintenance: <strong>$${report.preventiveMaintenanceCost}</strong></p>
                                <p>Corrective Maintenance: <strong>$${report.correctiveMaintenanceCost}</strong></p>
                                <hr/>
                                <p>Total Events: <strong>${report.maintenanceEvents}</strong></p>
                                <p>Cost Per Hour: <strong>$${report.maintenanceCostPerHour}</strong></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incident & Downtime Summary</h6></div>
                            <div class="card-body">
                                <p>Total Incidents: <strong>${report.totalIncidents}</strong></p>
                                <p>Total Downtime: <strong>${report.totalDowntimeMinutes} minutes</strong></p>
                                <hr/>
                                <p>Downtime Cost Per Hour: <strong>$${report.costPerHourLoss}</strong></p>
                                <p>Total Downtime Cost: <strong class="text-warning">$${report.totalDowntimeCost}</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cost Analysis Insights -->
                <div class="card">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Cost Analysis Insights</h6></div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6 class="text-muted">Maintenance vs Repair Ratio</h6>
                                <c:set var="totalMaint" value="${report.totalMaintenanceCost}"/>
                                <c:set var="totalRepair" value="${report.totalRepairCost}"/>
                                <p>
                                    <c:choose>
                                        <c:when test="${totalMaint > 0 && totalRepair > 0}">
                                            Ratio: 1:${totalRepair/totalMaint} (Repair to Maintenance)
                                        </c:when>
                                        <c:when test="${totalMaint > 0}">
                                            Only maintenance costs recorded
                                        </c:when>
                                        <c:otherwise>
                                            Only repair costs recorded
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-muted">Operational Cost Efficiency</h6>
                                <p>Total Cost: <strong>$${report.totalOperationalCost}</strong></p>
                                <p>Incidents: ${report.totalIncidents} | Cost per Incident: <strong>$${report.totalOperationalCost/report.totalIncidents}</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${report.totalDowntimeCost > 5000}">
                    <div class="alert alert-danger alert-dismissible fade show mt-4" role="alert">
                        <i class="bi bi-exclamation-circle"></i> <strong>High Downtime Cost!</strong> Downtime cost ($${report.totalDowntimeCost}) is significant. Consider preventive maintenance improvements.
                    </div>
                </c:if>
                <c:if test="${report.correctiveMaintenanceCost > report.preventiveMaintenanceCost}">
                    <div class="alert alert-warning alert-dismissible fade show mt-2" role="alert">
                        <i class="bi bi-exclamation-triangle"></i> <strong>High Corrective Costs!</strong> Corrective maintenance ($${report.correctiveMaintenanceCost}) exceeds preventive ($${report.preventiveMaintenanceCost}).
                    </div>
                </c:if>

            </c:when>
            <c:otherwise>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> No cost analysis data available for the selected criteria.
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
