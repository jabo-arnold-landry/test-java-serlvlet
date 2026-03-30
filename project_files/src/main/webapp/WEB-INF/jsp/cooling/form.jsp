<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${coolingUnit.coolingId != null ? 'Edit' : 'Add'} Cooling Unit</title>
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
                <h4 style="font-weight:700;margin:0;">${coolingUnit.coolingId != null ? 'Edit' : 'Add New'} Cooling Unit</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Fill in cooling unit details</p>
            </div>
            <a href="${pageContext.request.contextPath}/cooling" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/cooling/save" method="post">
                <c:if test="${coolingUnit.coolingId != null}">
                    <input type="hidden" name="coolingId" value="${coolingUnit.coolingId}"/>
                </c:if>
                <h6 class="fw-bold mb-3">Basic Information</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Asset Tag <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="assetTag" value="${coolingUnit.assetTag}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Unit Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="unitName" value="${coolingUnit.unitName}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Serial Number</label>
                        <input type="text" class="form-control" name="serialNumber" value="${coolingUnit.serialNumber}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Brand</label>
                        <input type="text" class="form-control" name="brand" value="${coolingUnit.brand}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Model</label>
                        <input type="text" class="form-control" name="model" value="${coolingUnit.model}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Capacity (kW)</label>
                        <input type="number" step="0.01" class="form-control" name="coolingCapacityKw" value="${coolingUnit.coolingCapacityKw}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Installation Date</label>
                        <input type="date" class="form-control" name="installationDate" value="${coolingUnit.installationDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="ACTIVE" ${coolingUnit.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                            <option value="FAULTY" ${coolingUnit.status == 'FAULTY' ? 'selected' : ''}>Faulty</option>
                            <option value="UNDER_MAINTENANCE" ${coolingUnit.status == 'UNDER_MAINTENANCE' ? 'selected' : ''}>Under Maintenance</option>
                            <option value="DECOMMISSIONED" ${coolingUnit.status == 'DECOMMISSIONED' ? 'selected' : ''}>Decommissioned</option>
                        </select>
                    </div>
                </div>
                <h6 class="fw-bold mb-3">Location</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label">Room</label>
                        <input type="text" class="form-control" name="locationRoom" value="${coolingUnit.locationRoom}"/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Zone</label>
                        <input type="text" class="form-control" name="locationZone" value="${coolingUnit.locationZone}"/>
                    </div>
                </div>
                <h6 class="fw-bold mb-3">Environmental Parameters</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Room Temperature</label>
                        <input type="number" step="0.01" class="form-control" name="roomTemperature" value="${coolingUnit.roomTemperature}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Supply Air Temp</label>
                        <input type="number" step="0.01" class="form-control" name="supplyAirTemp" value="${coolingUnit.supplyAirTemp}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Return Air Temp</label>
                        <input type="number" step="0.01" class="form-control" name="returnAirTemp" value="${coolingUnit.returnAirTemp}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Humidity (%)</label>
                        <input type="number" step="0.01" class="form-control" name="humidityPercent" value="${coolingUnit.humidityPercent}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Set Temperature</label>
                        <input type="number" step="0.01" class="form-control" name="setTemperature" value="${coolingUnit.setTemperature}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Set Humidity</label>
                        <input type="number" step="0.01" class="form-control" name="setHumidity" value="${coolingUnit.setHumidity}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Cooling Mode</label>
                        <select class="form-select" name="coolingMode">
                            <option value="AUTO" ${coolingUnit.coolingMode == 'AUTO' ? 'selected' : ''}>Auto</option>
                            <option value="MANUAL" ${coolingUnit.coolingMode == 'MANUAL' ? 'selected' : ''}>Manual</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Compressor Status</label>
                        <select class="form-select" name="compressorStatus">
                            <option value="RUNNING" ${coolingUnit.compressorStatus == 'RUNNING' ? 'selected' : ''}>Running</option>
                            <option value="STOPPED" ${coolingUnit.compressorStatus == 'STOPPED' ? 'selected' : ''}>Stopped</option>
                        </select>
                    </div>
                </div>
                <h6 class="fw-bold mb-3">Electrical Parameters</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Input Voltage (V)</label>
                        <input type="number" step="0.01" class="form-control" name="inputVoltage" value="${coolingUnit.inputVoltage}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Current (Amps)</label>
                        <input type="number" step="0.01" class="form-control" name="currentAmps" value="${coolingUnit.currentAmps}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Power Consumption (kW)</label>
                        <input type="number" step="0.01" class="form-control" name="powerConsumption" value="${coolingUnit.powerConsumption}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Filter Status</label>
                        <select class="form-select" name="filterStatus">
                            <option value="CLEAN" ${coolingUnit.filterStatus == 'CLEAN' ? 'selected' : ''}>Clean</option>
                            <option value="DIRTY" ${coolingUnit.filterStatus == 'DIRTY' ? 'selected' : ''}>Dirty</option>
                            <option value="NEEDS_REPLACEMENT" ${coolingUnit.filterStatus == 'NEEDS_REPLACEMENT' ? 'selected' : ''}>Needs Replacement</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Drain Status</label>
                        <select class="form-select" name="drainStatus">
                            <option value="CLEAR" ${coolingUnit.drainStatus == 'CLEAR' ? 'selected' : ''}>Clear</option>
                            <option value="BLOCKED" ${coolingUnit.drainStatus == 'BLOCKED' ? 'selected' : ''}>Blocked</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Refrigerant Type</label>
                        <input type="text" class="form-control" name="refrigerantType" value="${coolingUnit.refrigerantType}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Refrigerant Pressure</label>
                        <input type="number" step="0.01" class="form-control" name="refrigerantPressure" value="${coolingUnit.refrigerantPressure}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Fan Speed</label>
                        <input type="text" class="form-control" name="fanSpeed" value="${coolingUnit.fanSpeed}"/>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Save Cooling Unit</button>
                    <a href="${pageContext.request.contextPath}/cooling" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
