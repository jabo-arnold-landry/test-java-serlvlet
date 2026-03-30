<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - ${isEdit ? 'Edit' : 'Add'} Cost Entry</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">${isEdit ? 'Edit' : 'Add'} Cost Entry</h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    ${isEdit ? 'Update this cost record' : 'Log a maintenance cost'}
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/maintenance-costs" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/maintenance-costs/save" method="post">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="costId" value="${costEntry.costId}"/>
                    </c:if>

                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Maintenance ID <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="maintenanceId"
                                   value="${costEntry.maintenanceId}" required
                                   ${costEntry.maintenanceId > 0 ? 'readonly' : ''}/>
                            <small class="text-muted">ID from UPS or Cooling maintenance record</small>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Equipment Type <span class="text-danger">*</span></label>
                            <select class="form-select" name="equipmentType" required>
                                <option value="UPS" ${costEntry.equipmentType == 'UPS' ? 'selected' : ''}>UPS</option>
                                <option value="COOLING" ${costEntry.equipmentType == 'COOLING' ? 'selected' : ''}>Cooling</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Cost Amount (RWF) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="costAmount"
                                   value="${costEntry.costAmount}" step="0.01" min="0.01" required
                                   placeholder="e.g. 150000.00"/>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea class="form-control" name="costDescription" rows="3"
                                      placeholder="Labor, spare parts, vendor fees, etc.">${costEntry.costDescription}</textarea>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save"></i> ${isEdit ? 'Update' : 'Save'} Cost Entry
                        </button>
                        <a href="${pageContext.request.contextPath}/maintenance-costs" class="btn btn-outline-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
