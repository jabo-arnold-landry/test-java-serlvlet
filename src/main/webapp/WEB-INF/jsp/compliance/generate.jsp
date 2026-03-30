<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Generate Compliance Report</title>
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
            <h4 style="font-weight:700;margin:0;">Generate Compliance Reports</h4>
            <p class="text-muted mb-0" style="font-size:14px;">Apply filters and open viewer/API result instantly</p>
        </div>
        <a href="${pageContext.request.contextPath}/compliance/reports/dashboard" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left"></i> Back
        </a>
        <a href="${pageContext.request.contextPath}/compliance/reports/history" class="btn btn-outline-primary">
            <i class="bi bi-clock-history"></i> Download History
        </a>
    </div>

    <c:if test="${isTechnician}">
        <div class="alert alert-info">
            Technician access is limited to <strong>Shift</strong> and <strong>Maintenance</strong> reports.
        </div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <form id="reportFilterForm" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Report Type</label>
                    <select class="form-select" name="reportType" required>
                        <option value="maintenance">Maintenance History</option>
                        <option value="shift">Shift Report</option>
                        <c:if test="${!isTechnician}">
                            <option value="equipment-health">Equipment Health</option>
                            <option value="incidents">Incident & Downtime</option>
                            <option value="daily">Daily Consolidated</option>
                            <option value="compliance">Compliance</option>
                        </c:if>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Start Date</label>
                    <input type="date" class="form-control" name="startDate" value="${today.minusDays(7)}">
                </div>
                <div class="col-md-4">
                    <label class="form-label">End Date</label>
                    <input type="date" class="form-control" name="endDate" value="${today}">
                </div>

                <div class="col-md-3">
                    <label class="form-label">Equipment Type</label>
                    <select class="form-select" name="equipmentType">
                        <option value="">All</option>
                        <option value="UPS">UPS</option>
                        <option value="COOLING">Cooling</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Branch</label>
                    <input type="text" class="form-control" name="branch" placeholder="e.g. Kigali HQ">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Location</label>
                    <input type="text" class="form-control" name="location" placeholder="e.g. Server Room A">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Technician</label>
                    <input type="text" class="form-control" name="technician" placeholder="Name">
                </div>

                <div class="col-md-3">
                    <label class="form-label">Shift ID (for Shift Report)</label>
                    <input type="number" class="form-control" name="shiftId" min="1" value="1">
                </div>
                <div class="col-md-3">
                    <label class="form-label">High-Risk Threshold</label>
                    <input type="number" class="form-control" name="highRiskThreshold" value="3">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Downtime Threshold (min)</label>
                    <input type="number" class="form-control" name="downtimeThreshold" value="120">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Daily Auto-Generate</label>
                    <select class="form-select" name="autoGenerate">
                        <option value="false">No</option>
                        <option value="true">Yes</option>
                    </select>
                </div>

                <div class="col-12 d-flex gap-2">
                    <button type="button" class="btn btn-primary" onclick="openViewer()">
                        <i class="bi bi-table"></i> Open Report Viewer
                    </button>
                    <button type="button" class="btn btn-outline-dark" onclick="openApiInTab()">
                        <i class="bi bi-code-slash"></i> Open API URL
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function toParams() {
        const form = document.getElementById('reportFilterForm');
        const formData = new FormData(form);
        const params = new URLSearchParams();
        formData.forEach((value, key) => {
            if (value !== null && String(value).trim() !== '') {
                params.append(key, value);
            }
        });
        return params;
    }

    function apiPath(reportType) {
        if (reportType === 'equipment-health') return '/api/reports/equipment-health';
        if (reportType === 'maintenance') return '/api/reports/maintenance';
        if (reportType === 'incidents') return '/api/reports/incidents';
        if (reportType === 'shift') return '/api/reports/shift/' + (new FormData(document.getElementById('reportFilterForm')).get('shiftId') || '1');
        if (reportType === 'daily') return '/api/reports/daily';
        return '/api/reports/compliance';
    }

    function openViewer() {
        const params = toParams();
        window.location.href = '${pageContext.request.contextPath}/compliance/reports/viewer?' + params.toString();
    }

    function openApiInTab() {
        const params = toParams();
        const reportType = params.get('reportType') || 'equipment-health';
        params.delete('reportType');
        const url = '${pageContext.request.contextPath}' + apiPath(reportType) + '?' + params.toString();
        window.open(url, '_blank');
    }
</script>
</body>
</html>
