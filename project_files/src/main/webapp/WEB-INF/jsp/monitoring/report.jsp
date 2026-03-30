<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>SPCMS - Monitoring Report</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <jsp:include page="../common/styles.jsp" />
        </head>

        <body>
            <jsp:include page="../common/sidebar.jsp" />
            <jsp:include page="../common/topbar.jsp" />
            <div class="main-content">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h4 style="font-weight:700;margin:0;">Monitoring Report</h4>
                        <p class="text-muted mb-0" style="font-size:14px;">Overview of UPS and Cooling monitoring data
                        </p>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-secondary" onclick="window.print();"><i
                                class="bi bi-printer"></i> Print</button>
                        <a href="${pageContext.request.contextPath}/monitoring" class="btn btn-outline-secondary"><i
                                class="bi bi-arrow-left"></i> Back</a>
                    </div>
                </div>

                <!-- Summary Cards -->
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <div class="stat-card text-center">
                            <div class="stat-label">Total Readings</div>
                            <div class="stat-value">${totalReadings}</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-card text-center">
                            <div class="stat-label">UPS Readings</div>
                            <div class="stat-value" style="color:#0dcaf0;">${upsReadings}</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-card text-center">
                            <div class="stat-label">Cooling Readings</div>
                            <div class="stat-value" style="color:#198754;">${coolingReadings}</div>
                        </div>
                    </div>
                </div>

                <!-- UPS Statistics -->
                <div class="stat-card mb-4">
                    <h6 class="fw-bold mb-3"><i class="bi bi-lightning-charge text-info"></i> UPS Statistics</h6>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <table class="table table-borderless mb-0" style="font-size:14px;">
                                <tr>
                                    <td class="text-muted" style="width:50%;">Average Load</td>
                                    <td><strong>${avgLoad}%</strong></td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Average Temperature</td>
                                    <td><strong>${avgTemp}°C</strong></td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Total UPS Readings</td>
                                    <td><strong>${upsReadings}</strong></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Cooling Statistics -->
                <div class="stat-card mb-4">
                    <h6 class="fw-bold mb-3"><i class="bi bi-snow text-success"></i> Cooling Statistics</h6>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <table class="table table-borderless mb-0" style="font-size:14px;">
                                <tr>
                                    <td class="text-muted" style="width:50%;">Avg Return Air Temp</td>
                                    <td><strong>${avgReturnAir}°C</strong></td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Avg Supply Air Temp</td>
                                    <td><strong>${avgSupplyAir}°C</strong></td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Avg Humidity</td>
                                    <td><strong>${avgHumidity}%</strong></td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Total Cooling Readings</td>
                                    <td><strong>${coolingReadings}</strong></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Recent Readings Table -->
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-clock-history"></i> Recent Readings (Last 10)</h6>
                    <div class="table-container">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Timestamp</th>
                                    <th>Type</th>
                                    <th>Equipment ID</th>
                                    <th>Key Readings</th>
                                    <th>Notes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="log" items="${recentReadings}">
                                    <tr>
                                        <td>${log.readingTime}</td>
                                        <td><span
                                                class="badge ${log.equipmentType == 'UPS' ? 'bg-info' : 'bg-success'}">${log.equipmentType}</span>
                                        </td>
                                        <td>${log.equipmentId}</td>
                                        <td>
                                            <c:if test="${log.equipmentType == 'UPS'}">
                                                <c:if test="${log.loadPercentage != null}">Load: ${log.loadPercentage}%
                                                </c:if>
                                                <c:if test="${log.temperature != null}"> | Temp: ${log.temperature}°C
                                                </c:if>
                                                <c:if test="${log.inputVoltage != null}"> | In: ${log.inputVoltage}V
                                                </c:if>
                                            </c:if>
                                            <c:if test="${log.equipmentType == 'COOLING'}">
                                                <c:if test="${log.returnAirTemp != null}">Return: ${log.returnAirTemp}°C
                                                </c:if>
                                                <c:if test="${log.supplyAirTemp != null}"> | Supply:
                                                    ${log.supplyAirTemp}°C</c:if>
                                                <c:if test="${log.humidityPercent != null}"> | Humidity:
                                                    ${log.humidityPercent}%</c:if>
                                            </c:if>
                                        </td>
                                        <td>${log.notes != null ? log.notes : '-'}</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recentReadings}">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-3">No monitoring data
                                            available.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>