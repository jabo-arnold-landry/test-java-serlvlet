<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${isEdit ? 'Edit' : 'Schedule'} Cooling Maintenance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .file-upload-area {
            border: 2px dashed #d1d5db; border-radius: 10px; padding: 20px;
            text-align: center; transition: 0.3s; cursor: pointer; background: #f9fafb;
        }
        .file-upload-area:hover { border-color: var(--accent-blue); background: #eff6ff; }
        .file-upload-area.has-file { border-color: #10b981; background: #f0fdf4; }
        .existing-file { display: flex; align-items: center; gap: 8px; padding: 8px 12px;
            background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; font-size: 13px; }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">${isEdit ? 'Edit' : 'Schedule'} Cooling Maintenance</h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    ${isEdit ? 'Update this maintenance record' : 'Record or schedule maintenance for cooling units'}
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back to List
            </a>
        </div>

        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/maintenance/cooling/save" method="post" enctype="multipart/form-data">
                <!-- Hidden ID for edit mode -->
                <c:if test="${isEdit}">
                    <input type="hidden" name="maintenanceId" value="${coolingMaintenance.maintenanceId}"/>
                </c:if>

                <h6 class="fw-bold mb-3"><i class="bi bi-info-circle text-info"></i> Maintenance Details</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Cooling Unit <span class="text-danger">*</span></label>
                        <select class="form-select" name="coolingUnit.coolingId" required>
                            <option value="">-- Select Cooling Unit --</option>
                            <c:forEach var="unit" items="${coolingList}">
                                <option value="${unit.coolingId}" 
                                        ${coolingMaintenance.coolingUnit != null && coolingMaintenance.coolingUnit.coolingId == unit.coolingId ? 'selected' : ''}>
                                    ${unit.assetTag} - ${unit.unitName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Maintenance Type <span class="text-danger">*</span></label>
                        <select class="form-select" name="maintenanceType" required>
                            <option value="PREVENTIVE" ${coolingMaintenance.maintenanceType == 'PREVENTIVE' ? 'selected' : ''}>Preventive</option>
                            <option value="CORRECTIVE" ${coolingMaintenance.maintenanceType == 'CORRECTIVE' ? 'selected' : ''}>Corrective</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Maintenance Date <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" name="maintenanceDate"
                               value="${coolingMaintenance.maintenanceDate}" required/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Filter Cleaning Date</label>
                        <input type="date" class="form-control" name="filterCleaningDate"
                               value="${coolingMaintenance.filterCleaningDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Gas Refill Date</label>
                        <input type="date" class="form-control" name="gasRefillDate"
                               value="${coolingMaintenance.gasRefillDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Next Maintenance Date</label>
                        <input type="date" class="form-control" name="nextMaintenanceDate"
                               value="${coolingMaintenance.nextMaintenanceDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Technician</label>
                        <input type="text" class="form-control" name="technician"
                               value="${coolingMaintenance.technician}" placeholder="Technician name"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Vendor</label>
                        <input type="text" class="form-control" name="vendor"
                               value="${coolingMaintenance.vendor}" placeholder="Vendor / Company"/>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label">Remarks</label>
                        <textarea class="form-control" name="remarks" rows="2"
                                  placeholder="Additional notes or observations...">${coolingMaintenance.remarks}</textarea>
                    </div>
                </div>

                <!-- Service Report Upload -->
                <h6 class="fw-bold mb-3"><i class="bi bi-file-earmark-arrow-up text-success"></i> Upload Service Report</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-8">
                        <c:if test="${isEdit && not empty coolingMaintenance.serviceReportPath}">
                            <div class="existing-file mb-2">
                                <i class="bi bi-file-earmark-check text-success"></i>
                                <span>Current report uploaded</span>
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/cooling/${coolingMaintenance.maintenanceId}"
                                   class="btn btn-sm btn-outline-success ms-auto">
                                    <i class="bi bi-download"></i> Download
                                </a>
                            </div>
                            <small class="text-muted">Upload a new file below to replace the existing report:</small>
                        </c:if>
                        <div class="file-upload-area mt-2" id="uploadArea" onclick="document.getElementById('serviceReportFile').click();">
                            <i class="bi bi-cloud-arrow-up" style="font-size:28px;color:#6b7280;"></i>
                            <p class="mb-0 mt-1 text-muted" id="fileLabel">Click to upload service report (PDF, DOC, DOCX, JPG, PNG — max 10MB)</p>
                            <input type="file" name="serviceReportFile" id="serviceReportFile"
                                   accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.xlsx,.xls" style="display:none;"
                                   onchange="handleFileSelect(this)"/>
                        </div>
                    </div>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-save"></i> ${isEdit ? 'Update' : 'Save'} Maintenance Record
                    </button>
                    <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function handleFileSelect(input) {
            var area = document.getElementById('uploadArea');
            var label = document.getElementById('fileLabel');
            if (input.files && input.files[0]) {
                var file = input.files[0];
                label.innerHTML = '<strong>' + file.name + '</strong> (' + (file.size / 1024 / 1024).toFixed(2) + ' MB)';
                area.classList.add('has-file');
            } else {
                label.textContent = 'Click to upload service report (PDF, DOC, DOCX, JPG, PNG — max 10MB)';
                area.classList.remove('has-file');
            }
        }
    </script>
</body>
</html>
