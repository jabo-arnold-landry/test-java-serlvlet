<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Alert Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .alert-detail-card { background:#fff; border-radius:12px; padding:25px; border:1px solid #e5e7eb; }
        .gauge-container { position:relative; width:200px; height:200px; margin:0 auto; }
        .gauge-bg { fill:none; stroke:#e5e7eb; stroke-width:20; }
        .gauge-fill { fill:none; stroke-width:20; stroke-linecap:round; transition:stroke-dashoffset 1s ease-out; }
        .gauge-text { font-size:32px; font-weight:700; text-anchor:middle; dominant-baseline:middle; }
        .gauge-label { font-size:14px; fill:#6b7280; text-anchor:middle; }
        .threshold-line { stroke:#1a1d23; stroke-width:3; stroke-dasharray:5,3; }
        .alert-type-badge { font-size:14px; padding:8px 16px; border-radius:20px; font-weight:600; }
        .alert-type-HIGH_TEMP { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-HUMIDITY { background:rgba(59,130,246,0.1); color:#3b82f6; }
        .alert-type-LOW_BATTERY { background:rgba(245,158,11,0.1); color:#f59e0b; }
        .alert-type-UPS_OVERLOAD { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-MAINTENANCE_DUE { background:rgba(139,92,246,0.1); color:#8b5cf6; }
        .alert-type-EQUIPMENT_FAULT { background:rgba(239,68,68,0.1); color:#ef4444; }
        .history-chart { height:250px; }
        .info-row { display:flex; justify-content:space-between; padding:12px 0; border-bottom:1px solid #f0f0f0; }
        .info-row:last-child { border-bottom:none; }
        .info-label { color:#6b7280; font-size:14px; }
        .info-value { font-weight:600; font-size:14px; }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    
    <div class="main-content">
        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Alert Details</h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    <span class="alert-type-badge alert-type-${alert.alertType}">${alert.alertType}</span>
                    <span class="ms-2">${alert.equipmentType} ID: ${alert.equipmentId}</span>
                </p>
            </div>
            <div class="d-flex gap-2">
                <c:if test="${!alert.isAcknowledged}">
                    <form action="${pageContext.request.contextPath}/alerts/acknowledge/${alert.alertId}" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-success"><i class="bi bi-check2-all"></i> Acknowledge</button>
                    </form>
                </c:if>
                <a href="${pageContext.request.contextPath}/alerts" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Column: Gauge Graphic -->
            <div class="col-lg-5">
                <div class="alert-detail-card text-center">
                    <h6 style="font-weight:600;margin-bottom:20px;">
                        <c:choose>
                            <c:when test="${alert.alertType == 'HIGH_TEMP'}"><i class="bi bi-thermometer-high text-danger"></i> Temperature Reading</c:when>
                            <c:when test="${alert.alertType == 'HUMIDITY'}"><i class="bi bi-droplet text-primary"></i> Humidity Reading</c:when>
                            <c:when test="${alert.alertType == 'LOW_BATTERY'}"><i class="bi bi-battery-half text-warning"></i> Battery Level</c:when>
                            <c:when test="${alert.alertType == 'UPS_OVERLOAD'}"><i class="bi bi-lightning text-danger"></i> Load Percentage</c:when>
                            <c:otherwise><i class="bi bi-exclamation-triangle"></i> Alert Value</c:otherwise>
                        </c:choose>
                    </h6>
                    
                    <!-- SVG Gauge -->
                    <div class="gauge-container">
                        <svg viewBox="0 0 200 200">
                            <!-- Background arc -->
                            <circle class="gauge-bg" cx="100" cy="100" r="80" 
                                    transform="rotate(-90 100 100)"
                                    stroke-dasharray="502" stroke-dashoffset="125"/>
                            <!-- Threshold marker -->
                            <c:set var="thresholdAngle" value="${(alert.thresholdValue / maxGaugeValue) * 270 - 135}"/>
                            <!-- Fill arc -->
                            <circle class="gauge-fill" cx="100" cy="100" r="80"
                                    transform="rotate(-90 100 100)"
                                    stroke-dasharray="502"
                                    stroke-dashoffset="${502 - (alert.actualValue / maxGaugeValue * 377)}"
                                    stroke="${alert.alertType == 'HIGH_TEMP' || alert.alertType == 'UPS_OVERLOAD' ? '#ef4444' : 
                                             alert.alertType == 'HUMIDITY' ? '#3b82f6' : 
                                             alert.alertType == 'LOW_BATTERY' ? '#f59e0b' : '#ef4444'}"/>
                            <!-- Center text -->
                            <text x="100" y="95" class="gauge-text" fill="#1a1d23">
                                <fmt:formatNumber value="${alert.actualValue}" maxFractionDigits="1"/>
                            </text>
                            <text x="100" y="125" class="gauge-label">
                                <c:choose>
                                    <c:when test="${alert.alertType == 'HIGH_TEMP'}">°C</c:when>
                                    <c:when test="${alert.alertType == 'HUMIDITY' || alert.alertType == 'LOW_BATTERY' || alert.alertType == 'UPS_OVERLOAD'}">%</c:when>
                                    <c:otherwise>units</c:otherwise>
                                </c:choose>
                            </text>
                        </svg>
                    </div>
                    
                    <!-- Threshold indicator -->
                    <div class="d-flex justify-content-center gap-4 mt-3">
                        <div class="text-center">
                            <small class="text-muted d-block">Threshold</small>
                            <strong class="text-dark"><fmt:formatNumber value="${alert.thresholdValue}" maxFractionDigits="1"/></strong>
                        </div>
                        <div class="text-center">
                            <small class="text-muted d-block">Actual</small>
                            <strong class="${alert.actualValue > alert.thresholdValue ? 'text-danger' : 'text-success'}">
                                <fmt:formatNumber value="${alert.actualValue}" maxFractionDigits="1"/>
                            </strong>
                        </div>
                        <div class="text-center">
                            <small class="text-muted d-block">Deviation</small>
                            <strong class="text-danger">
                                +<fmt:formatNumber value="${alert.actualValue - alert.thresholdValue}" maxFractionDigits="1"/>
                            </strong>
                        </div>
                    </div>
                    
                    <!-- Visual Bar -->
                    <div class="mt-4">
                        <div class="d-flex justify-content-between mb-1" style="font-size:12px;">
                            <span>0</span>
                            <span class="text-muted">Threshold: <fmt:formatNumber value="${alert.thresholdValue}" maxFractionDigits="1"/></span>
                            <span>${maxGaugeValue}</span>
                        </div>
                        <div class="position-relative" style="height:30px;background:#e5e7eb;border-radius:6px;overflow:hidden;">
                            <div style="position:absolute;left:0;top:0;height:100%;width:${(alert.actualValue / maxGaugeValue) * 100}%;
                                        background:${alert.alertType == 'HIGH_TEMP' || alert.alertType == 'UPS_OVERLOAD' ? '#ef4444' : 
                                                     alert.alertType == 'HUMIDITY' ? '#3b82f6' : '#f59e0b'};
                                        border-radius:6px;transition:width 1s ease-out;"></div>
                            <div style="position:absolute;left:${(alert.thresholdValue / maxGaugeValue) * 100}%;top:0;height:100%;
                                        width:3px;background:#1a1d23;"></div>
                        </div>
                    </div>
                </div>
                
                <!-- Send Email Card -->
                <div class="alert-detail-card mt-4">
                    <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-envelope"></i> Email Notification</h6>
                    <c:choose>
                        <c:when test="${alert.isSent}">
                            <div class="alert alert-success mb-0">
                                <i class="bi bi-check-circle-fill"></i> Email notification has been sent.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <form action="${pageContext.request.contextPath}/alerts/send-email/${alert.alertId}" method="post">
                                <div class="mb-3">
                                    <label class="form-label">Recipient Email</label>
                                    <input type="email" name="email" class="form-control" placeholder="manager@company.com" required>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-send"></i> Send Alert Email
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <!-- Right Column: Details & History -->
            <div class="col-lg-7">
                <div class="alert-detail-card mb-4">
                    <h6 style="font-weight:600;margin-bottom:15px;"><i class="bi bi-info-circle"></i> Alert Information</h6>
                    <div class="info-row">
                        <span class="info-label">Alert ID</span>
                        <span class="info-value">#${alert.alertId}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Alert Type</span>
                        <span class="info-value">${alert.alertType}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Equipment</span>
                        <span class="info-value">${alert.equipmentType} (ID: ${alert.equipmentId})</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Message</span>
                        <span class="info-value">${alert.message}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Created At</span>
                        <span class="info-value"><fmt:formatDate value="${alert.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" type="both"/></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Status</span>
                        <span class="info-value">
                            <span class="badge ${alert.isAcknowledged ? 'bg-success' : 'bg-danger'}">
                                ${alert.isAcknowledged ? 'Acknowledged' : 'Pending'}
                            </span>
                        </span>
                    </div>
                    <c:if test="${alert.isAcknowledged}">
                    <div class="info-row">
                        <span class="info-label">Acknowledged By</span>
                        <span class="info-value">${alert.acknowledgedBy.fullName}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Acknowledged At</span>
                        <span class="info-value"><fmt:formatDate value="${alert.acknowledgedAt}" pattern="yyyy-MM-dd HH:mm:ss" type="both"/></span>
                    </div>
                    </c:if>
                </div>
                
                <!-- Historical Trend Chart -->
                <div class="alert-detail-card">
                    <h6 style="font-weight:600;margin-bottom:15px;">
                        <i class="bi bi-graph-up"></i> 
                        <c:choose>
                            <c:when test="${alert.alertType == 'HIGH_TEMP'}">Temperature History (Last 24h)</c:when>
                            <c:when test="${alert.alertType == 'HUMIDITY'}">Humidity History (Last 24h)</c:when>
                            <c:otherwise>Value History (Last 24h)</c:otherwise>
                        </c:choose>
                    </h6>
                    <div class="history-chart">
                        <canvas id="historyChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script>
        // History Chart
        const historyCtx = document.getElementById('historyChart').getContext('2d');
        const thresholdValue = ${alert.thresholdValue != null ? alert.thresholdValue : 0};
        const alertType = '${alert.alertType}';
        
        // Generate sample historical data (in real app, this would come from backend)
        const labels = [];
        const data = [];
        const now = new Date();
        for (let i = 23; i >= 0; i--) {
            const hour = new Date(now.getTime() - i * 60 * 60 * 1000);
            labels.push(hour.getHours() + ':00');
            // Generate realistic variations around actual value
            const baseValue = ${alert.actualValue != null ? alert.actualValue : 0};
            const variation = (Math.random() - 0.5) * 10;
            data.push(Math.max(0, baseValue - 5 + variation + (i < 3 ? 8 : 0)));
        }
        
        const chartColor = alertType === 'HIGH_TEMP' || alertType === 'UPS_OVERLOAD' ? '#ef4444' : 
                          alertType === 'HUMIDITY' ? '#3b82f6' : '#f59e0b';
        
        new Chart(historyCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: alertType === 'HIGH_TEMP' ? 'Temperature (°C)' : 
                           alertType === 'HUMIDITY' ? 'Humidity (%)' : 'Value',
                    data: data,
                    borderColor: chartColor,
                    backgroundColor: chartColor + '20',
                    fill: true,
                    tension: 0.4,
                    pointRadius: 2,
                    pointHoverRadius: 5
                }, {
                    label: 'Threshold',
                    data: Array(24).fill(thresholdValue),
                    borderColor: '#1a1d23',
                    borderDash: [5, 5],
                    borderWidth: 2,
                    pointRadius: 0,
                    fill: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { 
                        position: 'top',
                        labels: { usePointStyle: true, padding: 15 }
                    }
                },
                scales: {
                    y: { 
                        beginAtZero: false,
                        grid: { color: '#f0f0f0' }
                    },
                    x: {
                        grid: { display: false }
                    }
                }
            }
        });
    </script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
