<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Cooling Unit Details</title>
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
                <h4 style="font-weight:700;margin:0;">Cooling: ${coolingUnit.unitName}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Asset Tag: ${coolingUnit.assetTag} | Serial: ${coolingUnit.serialNumber}</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/cooling/edit/${coolingUnit.coolingId}" class="btn btn-outline-primary"><i class="bi bi-pencil"></i> Edit</a>
                <a href="${pageContext.request.contextPath}/cooling" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
            </div>
        </div>
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Status</div>
                    <span class="badge ${coolingUnit.status == 'ACTIVE' ? 'bg-success' : coolingUnit.status == 'FAULTY' ? 'bg-danger' : 'bg-warning'} fs-6 mt-2">${coolingUnit.status}</span>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Room Temperature</div>
                    <div class="stat-value" style="color:${coolingUnit.roomTemperature > 28 ? 'var(--accent-red)' : 'var(--accent-green)'}">${coolingUnit.roomTemperature}&deg;C</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Humidity</div>
                    <div class="stat-value">${coolingUnit.humidityPercent}%</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Compressor</div>
                    <span class="badge ${coolingUnit.compressorStatus == 'RUNNING' ? 'bg-success' : 'bg-secondary'} fs-6 mt-2">${coolingUnit.compressorStatus}</span>
                </div>
            </div>
        </div>
        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-info-circle"></i> General Information</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Brand</td><td>${coolingUnit.brand}</td></tr>
                        <tr><td class="text-muted">Model</td><td>${coolingUnit.model}</td></tr>
                        <tr><td class="text-muted">Capacity</td><td>${coolingUnit.coolingCapacityKw} kW</td></tr>
                        <tr><td class="text-muted">Installation Date</td><td>${coolingUnit.installationDate}</td></tr>
                        <tr><td class="text-muted">Room</td><td>${coolingUnit.locationRoom}</td></tr>
                        <tr><td class="text-muted">Zone</td><td>${coolingUnit.locationZone}</td></tr>
                        <tr><td class="text-muted">Cooling Mode</td><td>${coolingUnit.coolingMode}</td></tr>
                        <tr><td class="text-muted">Filter Status</td><td><span class="badge ${coolingUnit.filterStatus == 'CLEAN' ? 'bg-success' : coolingUnit.filterStatus == 'DIRTY' ? 'bg-warning' : 'bg-danger'}">${coolingUnit.filterStatus}</span></td></tr>
                        <tr><td class="text-muted">Drain Status</td><td><span class="badge ${coolingUnit.drainStatus == 'CLEAR' ? 'bg-success' : 'bg-danger'}">${coolingUnit.drainStatus}</span></td></tr>
                    </table>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-thermometer-half"></i> Environmental & Electrical</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Supply Air Temp</td><td>${coolingUnit.supplyAirTemp}&deg;C</td></tr>
                        <tr><td class="text-muted">Return Air Temp</td><td>${coolingUnit.returnAirTemp}&deg;C</td></tr>
                        <tr><td class="text-muted">Set Temperature</td><td>${coolingUnit.setTemperature}&deg;C</td></tr>
                        <tr><td class="text-muted">Set Humidity</td><td>${coolingUnit.setHumidity}%</td></tr>
                        <tr><td class="text-muted">Input Voltage</td><td>${coolingUnit.inputVoltage} V</td></tr>
                        <tr><td class="text-muted">Current</td><td>${coolingUnit.currentAmps} A</td></tr>
                        <tr><td class="text-muted">Power Consumption</td><td>${coolingUnit.powerConsumption} kW</td></tr>
                        <tr><td class="text-muted">Refrigerant</td><td>${coolingUnit.refrigerantType} (${coolingUnit.refrigerantPressure} bar)</td></tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="stat-card">
            <h6 class="fw-bold mb-3"><i class="bi bi-exclamation-triangle"></i> Alarm History</h6>
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr><th>Type</th><th>Time</th><th>Severity</th><th>Action Taken</th><th>Resolved By</th><th>Resolution Time</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="alarm" items="${alarms}">
                        <tr>
                            <td>${alarm.alarmType}</td>
                            <td>${alarm.alarmTime}</td>
                            <td><span class="badge ${alarm.severity == 'CRITICAL' ? 'bg-danger' : alarm.severity == 'HIGH' ? 'bg-warning' : alarm.severity == 'MEDIUM' ? 'bg-info' : 'bg-secondary'}">${alarm.severity}</span></td>
                            <td>${alarm.actionTaken}</td>
                            <td>${alarm.resolvedBy}</td>
                            <td>${alarm.resolutionTime}</td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty alarms}">
                        <tr><td colspan="6" class="text-center text-muted py-3">No alarm history.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
