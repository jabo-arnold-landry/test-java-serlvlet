<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Branch Comparison Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Branch Comparison Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Performance metrics across all branches for ${date}</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports/branch-performance" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Branch</th>
                        <th>Avg Load %</th>
                        <th>Peak Load %</th>
                        <th>Avg Temp °C</th>
                        <th>Max Temp °C</th>
                        <th>Incidents</th>
                        <th>Critical</th>
                        <th>Downtime (min)</th>
                        <th>MTTR (min)</th>
                        <th>MTBF (hrs)</th>
                        <th>Users</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${reports}">
                    <tr>
                        <td><strong>${r.branch}</strong></td>
                        <td>${r.avgDailyLoad}</td>
                        <td>${r.peakLoad}</td>
                        <td>${r.avgRoomTemperature}</td>
                        <td class="${r.highestTempRecorded > 28 ? 'text-danger' : ''}">${r.highestTempRecorded}°C</td>
                        <td>${r.totalIncidents}</td>
                        <td><span class="badge ${r.criticalIncidents > 0 ? 'bg-danger' : 'bg-success'}">${r.criticalIncidents}</span></td>
                        <td class="${r.totalDowntimeMin > 120 ? 'text-danger' : ''}">${r.totalDowntimeMin}</td>
                        <td>${r.mttrMinutes}</td>
                        <td>${r.mtbfHours}</td>
                        <td>${r.userCount}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty reports}">
                    <tr><td colspan="11" class="text-center text-muted py-4">No branch reports found for this date.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Comparison Charts -->
        <c:if test="${not empty reports}">
        <div class="row g-4 mt-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-graph-up"></i> Average Load Comparison</h6>
                    <canvas id="loadComparisonChart" height="250"></canvas>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-thermometer-half"></i> Temperature Comparison</h6>
                    <canvas id="tempComparisonChart" height="250"></canvas>
                </div>
            </div>
        </div>

        <div class="row g-4 mt-3">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-exclamation-triangle"></i> Incidents Comparison</h6>
                    <canvas id="incidentComparisonChart" height="250"></canvas>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-heart-pulse"></i> MTBF Comparison</h6>
                    <canvas id="mtbfComparisonChart" height="250"></canvas>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <script>
            var branches = [], loadData = [], tempData = [], incidentData = [], mtbfData = [];
            <c:forEach var="r" items="${reports}">
                branches.push('${r.branch}');
                loadData.push(${r.avgDailyLoad != null ? r.avgDailyLoad : 0});
                tempData.push(${r.avgRoomTemperature != null ? r.avgRoomTemperature : 0});
                incidentData.push(${r.totalIncidents != null ? r.totalIncidents : 0});
                mtbfData.push(${r.mtbfHours != null ? r.mtbfHours : 0});
            </c:forEach>

            // Load Comparison
            new Chart(document.getElementById('loadComparisonChart'), {
                type: 'bar',
                data: {
                    labels: branches,
                    datasets: [{
                        label: 'Avg Load %',
                        data: loadData,
                        backgroundColor: '#3b82f6',
                        borderColor: '#1e40af',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: { beginAtZero: true, max: 100, title: { display: true, text: 'Load %' } }
                    },
                    plugins: { legend: { display: false } }
                }
            });

            // Temperature Comparison
            new Chart(document.getElementById('tempComparisonChart'), {
                type: 'bar',
                data: {
                    labels: branches,
                    datasets: [{
                        label: 'Avg Temp °C',
                        data: tempData,
                        backgroundColor: tempData.map(t => t > 28 ? '#ef4444' : '#10b981'),
                        borderColor: '#1e40af',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    scales: { y: { beginAtZero: true } },
                    plugins: { legend: { display: false } }
                }
            });

            // Incidents Comparison
            new Chart(document.getElementById('incidentComparisonChart'), {
                type: 'bar',
                data: {
                    labels: branches,
                    datasets: [{
                        label: 'Total Incidents',
                        data: incidentData,
                        backgroundColor: '#f59e0b',
                        borderColor: '#b45309',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } },
                    plugins: { legend: { display: false } }
                }
            });

            // MTBF Comparison
            new Chart(document.getElementById('mtbfComparisonChart'), {
                type: 'bar',
                data: {
                    labels: branches,
                    datasets: [{
                        label: 'MTBF (hours)',
                        data: mtbfData,
                        backgroundColor: '#10b981',
                        borderColor: '#047857',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    scales: { y: { beginAtZero: true } },
                    plugins: { legend: { display: false } }
                }
            });
        </script>
        </c:if>
    </div>
</body>
</html>
