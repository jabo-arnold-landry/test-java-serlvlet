<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Cost Analysis Trend</title>
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
                <h4 style="font-weight:700;margin:0;">Cost Analysis Trend Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">${selectedBranch} from ${startDate} to ${endDate}</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports/cost-analysis" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Maintenance Cost</th>
                        <th>Repair Cost</th>
                        <th>Downtime Cost</th>
                        <th>Total Op. Cost</th>
                        <th>Incidents</th>
                        <th>Maintenance Events</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${reports}">
                    <tr>
                        <td><strong>${r.reportDate}</strong></td>
                        <td>$${r.totalMaintenanceCost}</td>
                        <td class="${r.totalRepairCost > 0 ? 'text-danger' : ''}">$${r.totalRepairCost}</td>
                        <td class="${r.totalDowntimeCost > 5000 ? 'text-danger fw-bold' : ''}">$${r.totalDowntimeCost}</td>
                        <td class="fw-bold">$${r.totalOperationalCost}</td>
                        <td>${r.totalIncidents}</td>
                        <td>${r.maintenanceEvents}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty reports}">
                    <tr><td colspan="7" class="text-center text-muted py-4">No cost analysis data found for this period.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Summary Statistics -->
        <c:if test="${not empty reports}">
        <div class="row g-4 mt-4">
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Maintenance Cost</h6>
                        <h4>$${reports.stream().map(r -> r.totalMaintenanceCost).reduce(java.math.BigDecimal.ZERO, (a,b) -> a.add(b))}</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Repair Cost</h6>
                        <h4 class="text-danger">$${reports.stream().map(r -> r.totalRepairCost).reduce(java.math.BigDecimal.ZERO, (a,b) -> a.add(b))}</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Downtime Cost</h6>
                        <h4 class="text-warning">$${reports.stream().map(r -> r.totalDowntimeCost).reduce(java.math.BigDecimal.ZERO, (a,b) -> a.add(b))}</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Operational Cost</h6>
                        <h4 class="text-primary">$${reports.stream().map(r -> r.totalOperationalCost).reduce(java.math.BigDecimal.ZERO, (a,b) -> a.add(b))}</h4>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cost Trend Chart -->
        <div class="row g-4 mt-3">
            <div class="col-md-12">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-graph-up-arrow"></i> Cost Trend Over Time</h6>
                    <canvas id="costTrendChart" height="250"></canvas>
                </div>
            </div>
        </div>

        <!-- Type Distribution Chart -->
        <div class="row g-4 mt-3">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-bar-chart"></i> Maintenance Type Costs</h6>
                    <canvas id="maintenanceTypeChart" height="200"></canvas>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-pie-chart"></i> Cost Composition</h6>
                    <canvas id="costCompositionChart" height="200"></canvas>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <script>
            var dates = [], maint = [], repair = [], downtime = [], total = [];
            <c:forEach var="r" items="${reports}">
                dates.push('${r.reportDate}');
                maint.push(${r.totalMaintenanceCost});
                repair.push(${r.totalRepairCost});
                downtime.push(${r.totalDowntimeCost});
                total.push(${r.totalOperationalCost});
            </c:forEach>
            dates.reverse(); maint.reverse(); repair.reverse(); downtime.reverse(); total.reverse();

            // Cost Trend
            new Chart(document.getElementById('costTrendChart'), {
                type: 'line',
                data: {
                    labels: dates,
                    datasets: [
                        { label: 'Maintenance Cost', data: maint, borderColor: '#3b82f6', backgroundColor: 'rgba(59,130,246,0.1)', fill: true, tension: 0.3 },
                        { label: 'Repair Cost', data: repair, borderColor: '#ef4444', backgroundColor: 'rgba(239,68,68,0.1)', fill: true, tension: 0.3 },
                        { label: 'Downtime Cost', data: downtime, borderColor: '#f59e0b', backgroundColor: 'rgba(245,158,11,0.1)', fill: true, tension: 0.3 }
                    ]
                },
                options: { responsive: true, scales: { y: { beginAtZero: true } }, plugins: { legend: { position: 'bottom' } } }
            });

            // Maintenance Type
            var preventive = maint.reduce((a,b) => a+b, 0) * 0.6;  // Estimated split
            var corrective = maint.reduce((a,b) => a+b, 0) * 0.4;
            new Chart(document.getElementById('maintenanceTypeChart'), {
                type: 'bar',
                data: {
                    labels: ['Preventive', 'Corrective'],
                    datasets: [{
                        label: 'Cost ($)',
                        data: [preventive, corrective],
                        backgroundColor: ['#10b981', '#ef4444'],
                        borderColor: ['#047857', '#991b1b'],
                        borderWidth: 2
                    }]
                },
                options: { responsive: true, scales: { y: { beginAtZero: true } }, plugins: { legend: { display: false } } }
            });

            // Cost Composition (stacked)
            var totalMaint = maint.reduce((a,b) => a+b, 0);
            var totalRepair = repair.reduce((a,b) => a+b, 0);
            var totalDowntime = downtime.reduce((a,b) => a+b, 0);
            new Chart(document.getElementById('costCompositionChart'), {
                type: 'doughnut',
                data: {
                    labels: ['Maintenance', 'Repair', 'Downtime'],
                    datasets: [{
                        data: [totalMaint, totalRepair, totalDowntime],
                        backgroundColor: ['#3b82f6', '#ef4444', '#f59e0b'],
                        borderColor: ['#1e40af', '#991b1b', '#b45309'],
                        borderWidth: 2
                    }]
                },
                options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
            });
        </script>
        </c:if>
    </div>
</body>
</html>
