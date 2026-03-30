<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - UPS Report</title>
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
        .health-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">UPS System Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Monitor UPS performance and battery health</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/ups" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-left"></i> Back to UPS
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
                        <label class="form-label">UPS Unit</label>
                        <select name="upsId" class="form-select">
                            <option value="">All Units</option>
                            <c:forEach var="unit" items="${upsUnits}">
                                <option value="${unit.upsId}" ${unit.upsId == selectedUnitId ? 'selected' : ''}>${unit.upsName}</option>
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
                            <h6>Battery Health</h6>
                            <h3 class="text-success">${reportData.avgBatteryHealth}%</h3>
                            <small class="text-muted">Overall average</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Average Load</h6>
                            <h3 class="text-primary">${reportData.avgLoad}%</h3>
                            <small class="text-muted">Period average</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>System Availability</h6>
                            <h3 class="text-success">${reportData.systemAvailability}%</h3>
                            <small class="text-muted">Uptime percentage</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h6>Total Runtime</h6>
                            <h3 class="text-info">${reportData.totalRuntime} hrs</h3>
                            <small class="text-muted">Battery mode hours</small>
                        </div>
                    </div>
                </div>

                <!-- Load and Battery Trend -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-8">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Load & Battery Level Trend</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="loadBatteryChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">UPS Status Overview</h6></div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <p class="mb-2"><strong>Online Units:</strong></p>
                                    <span class="status-badge bg-success text-white">${reportData.onlineUnits} Units</span>
                                </div>
                                <div class="mb-3">
                                    <p class="mb-2"><strong>On Battery:</strong></p>
                                    <span class="status-badge bg-warning text-dark">${reportData.onBatteryUnits} Units</span>
                                </div>
                                <div>
                                    <p class="mb-2"><strong>Faulty Units:</strong></p>
                                    <span class="status-badge bg-danger text-white">${reportData.faultyUnits} Units</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Battery & Efficiency Charts -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Battery Cycle Analysis</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="batteryChartId"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Operating Mode Distribution</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="operatingModeChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Incidents & Maintenance -->
                <div class="card mb-4">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incidents & Maintenance</h6></div>
                    <div class="card-body">
                        <div class="row g-4">
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-danger">${reportData.failovers}</h4>
                                    <p class="text-muted mb-0">Battery Failovers</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-warning">${reportData.batteryReplacements}</h4>
                                    <p class="text-muted mb-0">Battery Replacements Due</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-info">${reportData.maintenanceEvents}</h4>
                                    <p class="text-muted mb-0">Maintenance Events</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h4 class="text-secondary">${reportData.mttf}</h4>
                                    <p class="text-muted mb-0">MTTF (hours)</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Temperature & Efficiency -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Operating Temperature</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="temperatureChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Power Efficiency</h6></div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="efficiencyChart"></canvas>
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
                                        <th>Status</th>
                                        <th>Battery Health</th>
                                        <th>Load</th>
                                        <th>Temperature</th>
                                        <th>Last Test Date</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="unit" items="${unitPerformance}">
                                        <tr>
                                            <td><strong>${unit.upsName}</strong></td>
                                            <td>
                                                <span class="status-badge ${unit.status == 'ONLINE' ? 'bg-success' : unit.status == 'ON_BATTERY' ? 'bg-warning' : 'bg-danger'} text-white">
                                                    ${unit.status}
                                                </span>
                                            </td>
                                            <td>
                                                <div class="progress" style="height: 20px;">
                                                    <div class="progress-bar battery-bar-${unit.upsId} ${unit.batteryHealth > 80 ? 'bg-success' : unit.batteryHealth > 60 ? 'bg-warning' : 'bg-danger'}"
                                                         role="progressbar" 
                                                         aria-valuenow="${unit.batteryHealth}" 
                                                         aria-valuemin="0" 
                                                         aria-valuemax="100">
                                                        <small><c:out value="${unit.batteryHealth}"/>%</small>
                                                    </div>
                                                </div>
                                                <script>document.querySelector('.battery-bar-${unit.upsId}').style.width = '${unit.batteryHealth}%';</script>
                                            </td>
                                            <td>${unit.load}%</td>
                                            <td>${unit.temperature}°C</td>
                                            <td><fmt:formatDate value="${unit.lastTestDate}" pattern="MM/dd/yyyy"/></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/ups/view/${unit.upsId}" class="btn btn-sm btn-outline-primary">
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
                    <i class="bi bi-info-circle"></i> Select date range and filters above to generate the UPS system report.
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.min.js"></script>
    <script>
        var timeLabels = <c:out value='${timeLabels != null ? timeLabels : "[]"}'/>;
        var loadData = <c:out value='${loadData != null ? loadData : "[]"}'/>;
        var batteryLevelData = <c:out value='${batteryLevelData != null ? batteryLevelData : "[]"}'/>;
        var batteryLabels = <c:out value='${batteryLabels != null ? batteryLabels : "[]"}'/>;
        var batteryCycleData = <c:out value='${batteryCycleData != null ? batteryCycleData : "[]"}'/>;
        var operatingModeData = <c:out value='${operatingModeData != null ? operatingModeData : "[0,0,0,0]"}'/>;
        var tempLabels = <c:out value='${tempLabels != null ? tempLabels : "[]"}'/>;
        var temperatureData = <c:out value='${temperatureData != null ? temperatureData : "[]"}'/>;
        var efficiencyLabels = <c:out value='${efficiencyLabels != null ? efficiencyLabels : "[]"}'/>;
        var efficiencyData = <c:out value='${efficiencyData != null ? efficiencyData : "[]"}'/>;

        // Load and Battery Level Chart
        const loadBatteryCtx = document.getElementById('loadBatteryChart');
        if (loadBatteryCtx) {
            new Chart(loadBatteryCtx, {
                type: 'line',
                data: {
                    labels: timeLabels,
                    datasets: [
                        {
                            label: 'Load (%)',
                            data: loadData,
                            borderColor: '#0d6efd',
                            backgroundColor: 'rgba(13, 110, 253, 0.1)',
                            borderWidth: 2,
                            tension: 0.4,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Battery Level (%)',
                            data: batteryLevelData,
                            borderColor: '#198754',
                            backgroundColor: 'rgba(25, 135, 84, 0.1)',
                            borderWidth: 2,
                            tension: 0.4,
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            type: 'linear',
                            position: 'left',
                            title: {
                                display: true,
                                text: 'Load (%)'
                            }
                        },
                        y1: {
                            type: 'linear',
                            position: 'right',
                            title: {
                                display: true,
                                text: 'Battery Level (%)'
                            },
                            grid: {
                                drawOnChartArea: false
                            }
                        }
                    }
                }
            });
        }

        // Battery Cycle Chart
        const batteryCtx = document.getElementById('batteryChartId');
        if (batteryCtx) {
            new Chart(batteryCtx, {
                type: 'bar',
                data: {
                    labels: batteryLabels,
                    datasets: [{
                        label: 'Charge Cycles',
                        data: batteryCycleData,
                        backgroundColor: '#198754'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });
        }

        // Operating Mode Distribution
        const modeCtx = document.getElementById('operatingModeChart');
        if (modeCtx) {
            new Chart(modeCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Online Mode', 'Battery Mode', 'ECO Mode', 'Maintenance'],
                    datasets: [{
                        data: operatingModeData,
                        backgroundColor: ['#198754', '#ffc107', '#0d6efd', '#6c757d']
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

        // Temperature Chart
        const tempCtx = document.getElementById('temperatureChart');
        if (tempCtx) {
            new Chart(tempCtx, {
                type: 'line',
                data: {
                    labels: tempLabels,
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
                    }
                }
            });
        }

        // Power Efficiency Chart
        const effCtx = document.getElementById('efficiencyChart');
        if (effCtx) {
            new Chart(effCtx, {
                type: 'bar',
                data: {
                    labels: efficiencyLabels,
                    datasets: [{
                        label: 'Efficiency (%)',
                        data: efficiencyData,
                        backgroundColor: '#0d6efd'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100
                        }
                    }
                }
            });
        }
    </script>
</body>
</html>
