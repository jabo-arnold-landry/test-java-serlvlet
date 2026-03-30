<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${ups.upsId != null ? 'Edit' : 'Add'} UPS</title>
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
                <h4 style="font-weight:700;margin:0;">${ups.upsId != null ? 'Edit' : 'Add New'} UPS</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Fill in UPS details below</p>
            </div>
            <a href="${pageContext.request.contextPath}/ups" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/ups/save" method="post">
                <c:if test="${ups.upsId != null}">
                    <input type="hidden" name="upsId" value="${ups.upsId}"/>
                </c:if>
                <h6 class="fw-bold mb-3">Basic Information</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Asset Tag <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="assetTag" value="${ups.assetTag}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">UPS Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="upsName" value="${ups.upsName}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Serial Number</label>
                        <input type="text" class="form-control" name="serialNumber" value="${ups.serialNumber}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Brand</label>
                        <input type="text" class="form-control" name="brand" value="${ups.brand}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Model</label>
                        <input type="text" class="form-control" name="model" value="${ups.model}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Capacity (kVA)</label>
                        <input type="number" step="0.01" class="form-control" name="capacityKva" value="${ups.capacityKva}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Phase</label>
                        <select class="form-select" name="phase">
                            <option value="SINGLE_PHASE" ${ups.phase == 'SINGLE_PHASE' ? 'selected' : ''}>Single Phase</option>
                            <option value="THREE_PHASE" ${ups.phase == 'THREE_PHASE' ? 'selected' : ''}>Three Phase</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Installation Date</label>
                        <input type="date" class="form-control" name="installationDate" value="${ups.installationDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="ACTIVE" ${ups.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                            <option value="FAULTY" ${ups.status == 'FAULTY' ? 'selected' : ''}>Faulty</option>
                            <option value="UNDER_MAINTENANCE" ${ups.status == 'UNDER_MAINTENANCE' ? 'selected' : ''}>Under Maintenance</option>
                            <option value="DECOMMISSIONED" ${ups.status == 'DECOMMISSIONED' ? 'selected' : ''}>Decommissioned</option>
                        </select>
                    </div>
                </div>
                <h6 class="fw-bold mb-3">Location</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Room</label>
                        <input type="text" class="form-control" name="locationRoom" value="${ups.locationRoom}"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Rack</label>
                        <input type="text" class="form-control" name="locationRack" value="${ups.locationRack}"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Zone</label>
                        <input type="text" class="form-control" name="locationZone" value="${ups.locationZone}"/>
                    </div>
                </div>
                <h6 class="fw-bold mb-3">Electrical Parameters</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Input Voltage (V)</label>
                        <input type="number" step="0.01" class="form-control" name="inputVoltage" value="${ups.inputVoltage}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Output Voltage (V)</label>
                        <input type="number" step="0.01" class="form-control" name="outputVoltage" value="${ups.outputVoltage}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Load (%)</label>
                        <input type="number" step="0.01" class="form-control" name="loadPercentage" value="${ups.loadPercentage}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Current Load (kW)</label>
                        <input type="number" step="0.01" class="form-control" name="currentLoadKw" value="${ups.currentLoadKw}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Battery Voltage (V)</label>
                        <input type="number" step="0.01" class="form-control" name="batteryVoltage" value="${ups.batteryVoltage}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Battery Current (A)</label>
                        <input type="number" step="0.01" class="form-control" name="batteryCurrent" value="${ups.batteryCurrent}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Frequency (Hz)</label>
                        <input type="number" step="0.01" class="form-control" name="frequencyHz" value="${ups.frequencyHz}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Power Factor</label>
                        <input type="number" step="0.01" class="form-control" name="powerFactor" value="${ups.powerFactor}"/>
                    </div>
                    <div class="col-md-3">
                        <div class="form-check mt-4">
                            <input type="checkbox" class="form-check-input" name="bypassStatus" value="true" ${ups.bypassStatus ? 'checked' : ''}/>
                            <label class="form-check-label">Bypass Active</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-check mt-4">
                            <input type="checkbox" class="form-check-input" name="generatorMode" value="true" ${ups.generatorMode ? 'checked' : ''}/>
                            <label class="form-check-label">Generator Mode</label>
                        </div>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Save UPS</button>
                    <a href="${pageContext.request.contextPath}/ups" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
