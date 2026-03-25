<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Cooling Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .chart-container {
            position: relative;
            height: 300px;
            margin-bottom: 20px;
        }
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Cooling System Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Monitor and analyze cooling unit performance</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/cooling" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-left"></i> Back to Cooling
                </a>
            </div>
        </div>

        <!-- Report Filters -->
        <div class="card mb-4">
            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Report Filters</h6></div>
            <div class="card-body">
                <form method="get" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Date From</label>
                        <input type="date" name="dateFrom" class="form-control" value="${dateFrom}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Date To</label>
                        <input type="date" name="dateTo" class="form-control" value="${dateTo}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Cooling Unit</label>
                        <select name="coolingId" class="form-select">
                            <option value="">All Units</option>
                            <c:forEach var="unit" items="${coolingUnits}">
                                <option value="${unit.coolingId}" ${unit.coolingId == selectedUnitId ? 'selected' : ''}>${unit.unitName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-search"></i> Generate Report
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <c:choose>
            <c:when test="${reportData != null}">
                <!-- Key Metrics -->
                <div class="row g-4 mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Average Temperature</h6>
                            <h3 class="text-primary">${reportData.avgTemperature}°C</h3>
                            <small class="text-muted">Period average</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Max Temperature</h6>
                            <h3 class="text-danger">${reportData.maxTemperature}°C</h3>
                            <small class="text-muted">Peak recorded</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Average Humidity</h6>
                            <h3 class="text-info">${reportData.avgHumidity}%</h3>
                            <small class="text-muted">Period average</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>System Uptime</h6>
                            <h3 class="text-success">${reportData.uptimePercent}%</h3>
                            <small class="text-muted">Active time</small>
                        </div>
                    </div>
                </div>

                <!-- Temperature Trend Chart -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-8">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Temperature Trend</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="temperatureChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Unit Status</h6></div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <p class="mb-2"><strong>Active Units:</strong></p>
                                    <span class="status-badge bg-success text-white">${reportData.activeUnits} Units</span>
                                </div>
                                <div class="mb-3">
                                    <p class="mb-2"><strong>Faulty Units:</strong></p>
                                    <span class="status-badge bg-danger text-white">${reportData.faultyUnits} Units</span>
                                </div>
                                <div>
                                    <p class="mb-2"><strong>Maintenance Due:</strong></p>
                                    <span class="status-badge bg-warning text-dark">${reportData.maintenanceDue} Units</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Compressor Performance -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Compressor Runtime Analysis</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="compressorChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Energy Consumption</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="energyChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Incidents Summary -->
                <div class="card mb-4">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incidents & Alerts</h6></div>
                    <div class="card-body">
                        <div class="row g-4">
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-warning">${reportData.totalAlerts}</h4>
                                    <p class="text-muted mb-0">Temperature Alerts</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-danger">${reportData.criticalAlerts}</h4>
                                    <p class="text-muted mb-0">Critical Alerts</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-info">${reportData.maintenanceAlerts}</h4>
                                    <p class="text-muted mb-0">Maintenance Alerts</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-secondary">${reportData.resolvedAlerts}</h4>
                                    <p class="text-muted mb-0">Resolved Issues</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Unit Performance Details -->
                <div class="card">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Unit Performance Details</h6></div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Unit Name</th>
                                        <th>Avg Temp</th>
                                        <th>Max Temp</th>
                                        <th>Humidity</th>
                                        <th>Status</th>
                                        <th>Uptime</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="unit" items="${unitPerformance}">
                                        <tr>
                                            <td><strong>${unit.unitName}</strong></td>
                                            <td>${unit.avgTemp}°C</td>
                                            <td class="${unit.maxTemp > 28 ? 'text-danger fw-bold' : ''}">${unit.maxTemp}°C</td>
                                            <td>${unit.humidity}%</td>
                                            <td>
                                                <span class="badge ${unit.status == 'ACTIVE' ? 'bg-success' : unit.status == 'FAULTY' ? 'bg-danger' : 'bg-warning'}">
                                                    ${unit.status}
                                                </span>
                                            </td>
                                            <td>${unit.uptime}%</td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/cooling/view/${unit.coolingId}" class="btn btn-sm btn-outline-primary">
                                                    <i class="bi bi-eye"></i> View
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> Select date range and filters above to generate the cooling system report.
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.min.js"></script>
    <script>
        var temperatureLabels = <c:out value='${temperatureLabels != null ? temperatureLabels : "[]"}'/>;
        var temperatureData = <c:out value='${temperatureData != null ? temperatureData : "[]"}'/>;
        var compressorRuntimeData = <c:out value='${compressorRuntimeData != null ? compressorRuntimeData : "[0,0,0]"}'/>;
        var energyLabels = <c:out value='${energyLabels != null ? energyLabels : "[]"}'/>;
        var energyData = <c:out value='${energyData != null ? energyData : "[]"}'/>;

        // Temperature Trend Chart
        const temperatureCtx = document.getElementById('temperatureChart');
        if (temperatureCtx) {
            new Chart(temperatureCtx, {
                type: 'line',
                data: {
                    labels: temperatureLabels,
                    datasets: [{
                        label: 'Temperature (°C)',
                        data: temperatureData,
                        borderColor: '#dc3545',
                        backgroundColor: 'rgba(220, 53, 69, 0.1)',
                        borderWidth: 2,
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: false
                        }
                    }
                }
            });
        }

        // Compressor Runtime Chart
        const compressorCtx = document.getElementById('compressorChart');
        if (compressorCtx) {
            new Chart(compressorCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Running', 'Idle', 'Maintenance'],
                    datasets: [{
                        data: compressorRuntimeData,
                        backgroundColor: ['#198754', '#ffc107', '#6c757d']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        }

        // Energy Consumption Chart
        const energyCtx = document.getElementById('energyChart');
        if (energyCtx) {
            new Chart(energyCtx, {
                type: 'bar',
                data: {
                    labels: energyLabels,
                    datasets: [{
                        label: 'Energy (kWh)',
                        data: energyData,
                        backgroundColor: '#0d6efd'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });
        }
    </script>
</body>
</html>
