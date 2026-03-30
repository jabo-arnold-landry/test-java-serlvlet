<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.context.ApplicationContext" %>
<%@ page import="com.spcms.repositories.UpsRepository" %>
<%
    ApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(config.getServletContext());
    UpsRepository upsRepo = ctx.getBean(UpsRepository.class);
    request.setAttribute("upsList", upsRepo.findAll());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${isEdit ? 'Edit' : 'Schedule'} UPS Maintenance</title>
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
                <h4 style="font-weight:700;margin:0;">${isEdit ? 'Edit' : 'Schedule'} UPS Maintenance</h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    ${isEdit ? 'Update this maintenance record' : 'Record or schedule maintenance for UPS units'}
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back to List
            </a>
        </div>

        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/maintenance/ups/save" method="post" enctype="multipart/form-data">
                <!-- Hidden ID for edit mode -->
                <c:if test="${isEdit}">
                    <input type="hidden" name="maintenanceId" value="${upsMaintenance.maintenanceId}"/>
                </c:if>

                <h6 class="fw-bold mb-3"><i class="bi bi-info-circle text-primary"></i> Maintenance Details</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">UPS <span class="text-danger">*</span></label>
                        <select class="form-select" name="ups.upsId" required>
                            <option value="">-- Select UPS --</option>
                            <c:forEach var="upsUnit" items="${upsList}">
                                <option value="${upsUnit.upsId}" 
                                        ${upsMaintenance.ups != null && upsMaintenance.ups.upsId == upsUnit.upsId ? 'selected' : ''}>
                                    ${upsUnit.assetTag} - ${upsUnit.upsName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Maintenance Type <span class="text-danger">*</span></label>
                        <select class="form-select" name="maintenanceType" required>
                            <option value="PREVENTIVE" ${upsMaintenance.maintenanceType == 'PREVENTIVE' ? 'selected' : ''}>Preventive</option>
                            <option value="CORRECTIVE" ${upsMaintenance.maintenanceType == 'CORRECTIVE' ? 'selected' : ''}>Corrective</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Maintenance Date <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" name="maintenanceDate"
                               value="${upsMaintenance.maintenanceDate}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Next Due Date</label>
                        <input type="date" class="form-control" name="nextDueDate"
                               value="${upsMaintenance.nextDueDate}"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Technician</label>
                        <select class="form-select" name="technician">
                            <option value="">-- Select Technician --</option>
                            <c:forEach var="tech" items="${technicianList}">
                                <option value="${tech.fullName}" ${upsMaintenance.technician == tech.fullName ? 'selected' : ''}>${tech.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Vendor</label>
                        <input type="text" class="form-control" name="vendor"
                               value="${upsMaintenance.vendor}" placeholder="Vendor / Company"/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Spare Parts Used</label>
                        <textarea class="form-control" name="sparePartsUsed" rows="2"
                                  placeholder="List any spare parts used...">${upsMaintenance.sparePartsUsed}</textarea>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Remarks</label>
                        <textarea class="form-control" name="remarks" rows="2"
                                  placeholder="Additional notes or observations...">${upsMaintenance.remarks}</textarea>
                    </div>
                </div>

                <!-- Service Report Upload -->
                <h6 class="fw-bold mb-3"><i class="bi bi-file-earmark-arrow-up text-success"></i> Upload Service Report</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-8">
                        <c:if test="${isEdit && not empty upsMaintenance.serviceReportPath}">
                            <div class="existing-file mb-2">
                                <i class="bi bi-file-earmark-check text-success"></i>
                                <span>Current report uploaded</span>
                                <a href="${pageContext.request.contextPath}/maintenance/download-report/ups/${upsMaintenance.maintenanceId}"
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

        <!-- ==================== Quarterly UPS Maintenance Scheduler ==================== -->
        <div class="card border-0 shadow-lg mt-5" style="border-left:5px solid #0d6efd !important;">
            <div class="card-header text-white py-3" style="background: linear-gradient(135deg, #0d6efd, #6610f2);">
                <h5 class="mb-0 fw-bold">
                    <i class="bi bi-calendar3 me-2" style="font-size:1.3rem;"></i>
                    Quarterly UPS Maintenance Scheduler
                </h5>
            </div>
            <div class="card-body p-4">
                <div class="alert alert-primary border-0 d-flex align-items-center mb-4" style="background: #e8f0fe;">
                    <i class="bi bi-info-circle-fill fs-4 me-3 text-primary"></i>
                    <div>
                        <strong>Auto-Suggested Date:</strong> The next maintenance date is automatically set to
                        <span class="badge bg-primary fs-6">today + 3 months</span>.
                        You can <strong>override</strong> it manually below.
                    </div>
                </div>

                <!-- Flash messages -->
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i>${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/maintenance/ups/schedule-quarterly" method="post">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label fw-bold"><i class="bi bi-battery-charging text-primary me-1"></i>UPS Unit <span class="text-danger">*</span></label>
                            <select class="form-select form-select-lg" name="upsId" required>
                                <option value="">-- Choose UPS --</option>
                                <c:forEach var="upsUnit" items="${upsList}">
                                    <option value="${upsUnit.upsId}">${upsUnit.assetTag} - ${upsUnit.upsName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold"><i class="bi bi-calendar-date me-1"></i>Current Date</label>
                            <input type="date" class="form-control form-control-lg" name="startDate" id="qStartDate" required readonly style="background:#f0f0f0;">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold"><i class="bi bi-calendar-plus me-1 text-success"></i>Next Quarter Maintenance Date</label>
                            <input type="date" class="form-control form-control-lg border-success" name="nextDueDate" id="qNextDate" required>
                        </div>
                        <div class="col-md-3">
                            <button type="submit" class="btn btn-lg text-white w-100 shadow" style="background: linear-gradient(135deg, #0d6efd, #6610f2);">
                                <i class="bi bi-calendar-plus"></i> Schedule Quarterly
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function handleFileSelect(input) {
            var area = document.getElementById('uploadArea');
            var label = document.getElementById('fileLabel');
            if (input.files && input.files[0]) {
                var file = input.files[0];
                if (file.size > 10 * 1024 * 1024) {
                    alert('File size exceeds 10MB limit. Please choose a smaller file.');
                    input.value = '';
                    return;
                }
                label.innerHTML = '<strong>' + file.name + '</strong> (' + (file.size / 1024 / 1024).toFixed(2) + ' MB)';
                area.classList.add('has-file');
            } else {
                label.textContent = 'Click to upload service report (PDF, DOC, DOCX, JPG, PNG — max 10MB)';
                area.classList.remove('has-file');
            }
        }

        // Set default maintenance date to today if empty (new form only)
        document.addEventListener('DOMContentLoaded', function() {
            var maintDateInput = document.querySelector('input[name="maintenanceDate"]');
            if (maintDateInput && !maintDateInput.value) {
                maintDateInput.value = new Date().toISOString().split('T')[0];
            }

            // Quarterly scheduler: auto-suggest next date = today + 3 months
            var qStartDate = document.getElementById('qStartDate');
            var qNextDate = document.getElementById('qNextDate');
            if (qStartDate && qNextDate) {
                var today = new Date();
                qStartDate.value = today.toISOString().split('T')[0];
                var suggestedDate = new Date(today);
                suggestedDate.setMonth(suggestedDate.getMonth() + 3);
                qNextDate.value = suggestedDate.toISOString().split('T')[0];

                qStartDate.addEventListener('change', function() {
                    var d = new Date(this.value);
                    d.setMonth(d.getMonth() + 3);
                    qNextDate.value = d.toISOString().split('T')[0];
                });
            }
        });
    </script>
</body>
</html>

