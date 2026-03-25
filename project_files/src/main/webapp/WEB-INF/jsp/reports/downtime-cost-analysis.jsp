<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Downtime Cost Analysis</title>
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
                <h4 style="font-weight:700;margin:0;">Downtime Cost Analysis</h4>
                <p class="text-muted mb-0" style="font-size:14px;">${selectedBranch} from ${startDate} to ${endDate}</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports/cost-analysis" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Total Downtime (min)</th>
                        <th>Cost Per Hour Loss</th>
                        <th>Downtime Cost</th>
                        <th>Incidents</th>
                        <th>Maintenance Events</th>
                        <th>Total Operational Cost</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${reports}">
                    <tr>
                        <td><strong>${r.reportDate}</strong></td>
                        <td>${r.totalDowntimeMinutes}</td>
                        <td>$${r.costPerHourLoss}</td>
                        <td class="${r.totalDowntimeCost > 5000 ? 'text-danger' : ''} fw-bold">$${r.totalDowntimeCost}</td>
                        <td>${r.totalIncidents}</td>
                        <td>${r.maintenanceEvents}</td>
                        <td>$${r.totalOperationalCost}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty reports}">
                    <tr><td colspan="7" class="text-center text-muted py-4">No cost data found for this period.</td></tr>
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
                        <h6 class="text-muted">Total Downtime (Period)</h6>
                        <h4>${reports.stream().mapToInt(r -> r.totalDowntimeMinutes).sum()} min</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Downtime Cost</h6>
                        <h4 class="text-danger">$${reports.stream().map(r -> r.totalDowntimeCost).reduce(java.math.BigDecimal.ZERO, (a,b) -> a.add(b))}</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Avg Daily Downtime Cost</h6>
                        <h4>$${reports.stream().map(r -> r.totalDowntimeCost).reduce(java.math.BigDecimal.ZERO, (a,b) -> a.add(b)).divide(java.math.BigDecimal.valueOf(reports.size()), 2, java.math.RoundingMode.HALF_UP)}</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body text-center">
                        <h6 class="text-muted">Total Operational Cost</h6>
                        <h4>$${reports.stream().map(r -> r.totalOperationalCost).reduce(java.math.BigDecimal.ZERO, (a,b) -> a.add(b))}</h4>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cost Trend Chart -->
        <div class="row g-4 mt-3">
            <div class="col-md-12">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-graph-up-arrow"></i> Downtime Cost Trend</h6>
                    <canvas id="downtimeCostChart" height="250"></canvas>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <script>
            var dates = [], downtimeCosts = [], incidents = [];
            <c:forEach var="r" items="${reports}">
                dates.push('${r.reportDate}');
                downtimeCosts.push(${r.totalDowntimeCost});
                incidents.push(${r.totalIncidents});
            </c:forEach>
            dates.reverse(); downtimeCosts.reverse(); incidents.reverse();

            new Chart(document.getElementById('downtimeCostChart'), {
                type: 'line',
                data: {
                    labels: dates,
                    datasets: [
                        {
                            label: 'Downtime Cost ($)',
                            data: downtimeCosts,
                            borderColor: '#ef4444',
                            backgroundColor: 'rgba(239,68,68,0.1)',
                            fill: true,
                            tension: 0.3,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Incidents',
                            data: incidents,
                            borderColor: '#f59e0b',
                            type: 'bar',
                            backgroundColor: 'rgba(245,158,11,0.3)',
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: { beginAtZero: true, position: 'left', title: { display: true, text: 'Cost ($)' } },
                        y1: { beginAtZero: true, position: 'right', title: { display: true, text: 'Incidents' } }
                    },
                    plugins: { legend: { position: 'bottom' } }
                }
            });
        </script>
        </c:if>
    </div>
</body>
</html>
