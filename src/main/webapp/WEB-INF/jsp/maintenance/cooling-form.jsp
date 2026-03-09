<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Cooling Maintenance</title>
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
                <h4 style="font-weight:700;margin:0;">Schedule Cooling Maintenance</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Record or schedule maintenance for cooling units</p>
            </div>
            <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/maintenance/cooling/save" method="post">
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Cooling Unit ID <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" name="coolingUnit.coolingId" value="${coolingMaintenance.coolingUnit != null ? coolingMaintenance.coolingUnit.coolingId : ''}" required/>
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
                        <input type="date" class="form-control" name="maintenanceDate" value="${coolingMaintenance.maintenanceDate}" required/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Filter Cleaning Date</label>
                        <input type="date" class="form-control" name="filterCleaningDate" value="${coolingMaintenance.filterCleaningDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Gas Refill Date</label>
                        <input type="date" class="form-control" name="gasRefillDate" value="${coolingMaintenance.gasRefillDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Next Maintenance Date</label>
                        <input type="date" class="form-control" name="nextMaintenanceDate" value="${coolingMaintenance.nextMaintenanceDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Technician</label>
                        <input type="text" class="form-control" name="technician" value="${coolingMaintenance.technician}"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Vendor</label>
                        <input type="text" class="form-control" name="vendor" value="${coolingMaintenance.vendor}"/>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label">Remarks</label>
                        <textarea class="form-control" name="remarks" rows="2">${coolingMaintenance.remarks}</textarea>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Save Maintenance Record</button>
                    <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
