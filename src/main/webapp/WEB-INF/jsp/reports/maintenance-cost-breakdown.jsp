<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Maintenance Cost Breakdown</title>
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
                <h4 style="font-weight:700;margin:0;">Maintenance Cost Breakdown</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Detailed cost analysis for ${selectedBranch} on ${date}</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports/cost-analysis" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <c:choose>
            <c:when test="${report != null}">
                <!-- Cost Breakdown Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Equipment Maintenance Costs</h6></div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between mb-3">
                                    <span>UPS Maintenance:</span>
                                    <strong>$${report.upsMaintenanceCost}</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Cooling Unit Maintenance:</span>
                                    <strong>$${report.coolingMaintenanceCost}</strong>
                                </div>
                                <hr/>
                                <div class="d-flex justify-content-between">
                                    <span class="fw-bold">Total Equipment Maintenance:</span>
                                    <strong class="text-primary">$${report.totalMaintenanceCost}</strong>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Maintenance Type Distribution</h6></div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Preventive Maintenance:</span>
                                    <strong class="text-success">$${report.preventiveMaintenanceCost}</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Corrective Maintenance:</span>
                                    <strong class="text-danger">$${report.correctiveMaintenanceCost}</strong>
                                </div>
                                <hr/>
                                <div class="d-flex justify-content-between">
                                    <span class="fw-bold">Total Maintenance Events:</span>
                                    <strong>${report.maintenanceEvents}</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Incident & Downtime Costs -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incident Repair Costs</h6></div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Total Repair Cost:</span>
                                    <strong class="text-danger">$${report.totalRepairCost}</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Critical Incident Cost:</span>
                                    <strong class="text-accent-red">$${report.criticalIncidentCost}</strong>
                                </div>
                                <hr/>
                                <div class="d-flex justify-content-between">
                                    <span class="fw-bold">Total Incidents:</span>
                                    <strong>${report.totalIncidents}</strong>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Downtime Impact</h6></div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Total Downtime:</span>
                                    <strong>${report.totalDowntimeMinutes} minutes</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Cost Per Hour Loss:</span>
                                    <strong>$${report.costPerHourLoss}</strong>
                                </div>
                                <hr/>
                                <div class="d-flex justify-content-between">
                                    <span class="fw-bold">Downtime Cost:</span>
                                    <strong class="text-warning">$${report.totalDowntimeCost}</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Total Cost Pie Chart -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <div class="stat-card">
                            <h6 class="fw-bold mb-3"><i class="bi bi-pie-chart"></i> Cost Distribution</h6>
                            <canvas id="costPieChart" height="250"></canvas>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Total Cost Summary</h6></div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Maintenance Cost:</span>
                                    <strong>$${report.totalMaintenanceCost}</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Repair Cost:</span>
                                    <strong>$${report.totalRepairCost}</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-3">
                                    <span>Downtime Cost:</span>
                                    <strong>$${report.totalDowntimeCost}</strong>
                                </div>
                                <hr/>
                                <div class="d-flex justify-content-between">
                                    <span class="fw-bold">Total Operational Cost:</span>
                                    <strong class="text-accent-red" style="font-size: 1.2em;">$${report.totalOperationalCost}</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cost Efficiency Metrics -->
                <div class="card">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Cost Efficiency Metrics</h6></div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4">
                                <h6 class="text-muted">Maintenance Cost Per Hour</h6>
                                <h4>$${report.maintenanceCostPerHour}</h4>
                            </div>
                            <div class="col-md-4">
                                <h6 class="text-muted">Cost Per Incident</h6>
                                <h4>$<c:choose>
                                    <c:when test="${report.totalIncidents > 0}">
                                        ${report.totalOperationalCost/report.totalIncidents}
                                    </c:when>
                                    <c:otherwise>0</c:otherwise>
                                </c:choose></h4>
                            </div>
                            <div class="col-md-4">
                                <h6 class="text-muted">Preventive vs Corrective Ratio</h6>
                                <h4><c:choose>
                                    <c:when test="${report.preventiveMaintenanceCost > 0 && report.correctiveMaintenanceCost > 0}">
                                        1:${report.correctiveMaintenanceCost/report.preventiveMaintenanceCost}
                                    </c:when>
                                    <c:otherwise>N/A</c:otherwise>
                                </c:choose></h4>
                            </div>
                        </div>
                    </div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
                <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
                <script>
                    var chartData = [parseFloat('${report.totalMaintenanceCost}'), parseFloat('${report.totalRepairCost}'), parseFloat('${report.totalDowntimeCost}')];
                    
                    new Chart(document.getElementById('costPieChart'), {
                        type: 'doughnut',
                        data: {
                            labels: ['Maintenance', 'Repair', 'Downtime'],
                            datasets: [{
                                data: chartData,
                                backgroundColor: ['#3b82f6', '#ef4444', '#f59e0b'],
                                borderColor: ['#1e40af', '#991b1b', '#b45309'],
                                borderWidth: 2
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: { position: 'bottom' },
                                tooltip: {
                                    callbacks: {
                                        label: function(context) {
                                            return context.label + ': $' + context.parsed;
                                        }
                                    }
                                }
                            }
                        }
                    });
                </script>

            </c:when>
            <c:otherwise>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> No cost breakdown data available for the selected date.
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
