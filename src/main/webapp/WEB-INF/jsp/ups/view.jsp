<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - UPS Details</title>
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
                <h4 style="font-weight:700;margin:0;">UPS: ${ups.upsName}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Asset Tag: ${ups.assetTag} | Serial: ${ups.serialNumber}</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/ups/reports" class="btn btn-outline-info" title="View Reports for this UPS"><i class="bi bi-bar-chart"></i> Reports</a>
                <a href="${pageContext.request.contextPath}/ups/edit/${ups.upsId}" class="btn btn-outline-primary"><i class="bi bi-pencil"></i> Edit</a>
                <a href="${pageContext.request.contextPath}/ups" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
            </div>
        </div>
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Status</div>
                    <span class="badge ${ups.status == 'ACTIVE' ? 'bg-success' : ups.status == 'FAULTY' ? 'bg-danger' : 'bg-warning'} fs-6 mt-2">${ups.status}</span>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Load</div>
                    <div class="stat-value">${ups.loadPercentage != null ? ups.loadPercentage : 0}%</div>
                    <div class="progress mt-2" style="height:8px;">
                        <div class="progress-bar ${ups.loadPercentage > 80 ? 'bg-danger' : ups.loadPercentage > 60 ? 'bg-warning' : 'bg-success'}" style="width:${ups.loadPercentage != null ? ups.loadPercentage : 0}%"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Capacity</div>
                    <div class="stat-value">${ups.capacityKva} kVA</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Phase</div>
                    <div class="stat-value" style="font-size:18px;">${ups.phase}</div>
                </div>
            </div>
        </div>
        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-info-circle"></i> General Information</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Brand</td><td>${ups.brand}</td></tr>
                        <tr><td class="text-muted">Model</td><td>${ups.model}</td></tr>
                        <tr><td class="text-muted">Installation Date</td><td>${ups.installationDate}</td></tr>
                        <tr><td class="text-muted">Room</td><td>${ups.locationRoom}</td></tr>
                        <tr><td class="text-muted">Rack</td><td>${ups.locationRack}</td></tr>
                        <tr><td class="text-muted">Zone</td><td>${ups.locationZone}</td></tr>
                    </table>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-lightning"></i> Electrical Parameters</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Input Voltage</td><td>${ups.inputVoltage} V</td></tr>
                        <tr><td class="text-muted">Output Voltage</td><td>${ups.outputVoltage} V</td></tr>
                        <tr><td class="text-muted">Battery Voltage</td><td>${ups.batteryVoltage} V</td></tr>
                        <tr><td class="text-muted">Battery Current</td><td>${ups.batteryCurrent} A</td></tr>
                        <tr><td class="text-muted">Frequency</td><td>${ups.frequencyHz} Hz</td></tr>
                        <tr><td class="text-muted">Power Factor</td><td>${ups.powerFactor}</td></tr>
                        <tr><td class="text-muted">Bypass Active</td><td>${ups.bypassStatus ? 'Yes' : 'No'}</td></tr>
                        <tr><td class="text-muted">Generator Mode</td><td>${ups.generatorMode ? 'Yes' : 'No'}</td></tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="stat-card">
            <h6 class="fw-bold mb-3"><i class="bi bi-battery-charging"></i> Batteries</h6>
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr><th>Type</th><th>Qty</th><th>Capacity (Ah)</th><th>Install Date</th><th>Health</th><th>Runtime (min)</th><th>Replacement Due</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="bat" items="${batteries}">
                        <tr>
                            <td>${bat.batteryType}</td>
                            <td>${bat.batteryQuantity}</td>
                            <td>${bat.batteryCapacityAh}</td>
                            <td>${bat.batteryInstallDate}</td>
                            <td><span class="badge ${bat.batteryHealthStatus == 'GOOD' ? 'bg-success' : bat.batteryHealthStatus == 'FAIR' ? 'bg-info' : bat.batteryHealthStatus == 'POOR' ? 'bg-warning' : 'bg-danger'}">${bat.batteryHealthStatus}</span></td>
                            <td>${bat.estimatedRuntimeMin}</td>
                            <td>${bat.replacementDueDate}</td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty batteries}">
                        <tr><td colspan="7" class="text-center text-muted py-3">No batteries registered for this UPS.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
