<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Maintenance Activity Detail</title>
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
                <h4 style="font-weight:700;margin:0;">Maintenance Activity Detail</h4>
                <p class="text-muted mb-0">Report ID: ${record.reportId}</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports/maintenance-history" class="btn btn-outline-primary btn-sm">Back to History</a>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Asset Information</h6></div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-4"><strong>Equipment Type:</strong><br>${record.equipmentType}</div>
                    <div class="col-md-4"><strong>Equipment Name:</strong><br>${record.equipmentName}</div>
                    <div class="col-md-4"><strong>Asset ID:</strong><br>${record.assetId}</div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Maintenance Information</h6></div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-4"><strong>Maintenance Date:</strong><br>${record.maintenanceDate}</div>
                    <div class="col-md-4"><strong>Maintenance Type:</strong><br>${record.maintenanceType}</div>
                    <div class="col-md-4"><strong>Status:</strong><br>${record.status}</div>
                    <div class="col-md-4"><strong>Technician Assigned:</strong><br>${record.technicianName}</div>
                    <div class="col-md-4"><strong>Vendor:</strong><br>${record.vendor}</div>
                    <div class="col-md-4"><strong>Next Scheduled Maintenance:</strong><br>${record.nextScheduledMaintenance}</div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header bg-white"><h6 class="m-0 fw-bold">Work Performed and Remarks</h6></div>
            <div class="card-body">
                <p><strong>Description of Work Done:</strong><br>${record.description}</p>
                <p><strong>Work Performed:</strong><br>${record.workPerformed}</p>
                <p><strong>Remarks:</strong><br>${record.remarks}</p>
                <c:if test="${not empty record.partsOrMaterials}">
                    <p><strong>Parts / Materials Used:</strong><br>${record.partsOrMaterials}</p>
                </c:if>
                <c:if test="${record.filterCleaningDate != null}">
                    <p><strong>Filter Cleaning Date:</strong><br>${record.filterCleaningDate}</p>
                </c:if>
                <c:if test="${record.gasRefillDate != null}">
                    <p><strong>Gas Refill Date:</strong><br>${record.gasRefillDate}</p>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
