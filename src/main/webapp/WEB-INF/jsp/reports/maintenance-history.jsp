<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Maintenance History Report</title>
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
                <h4 style="font-weight:700;margin:0;">Maintenance History Report</h4>
                <p class="text-muted mb-0">Reporting & Analysis for UPS and Cooling maintenance records</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-primary btn-sm">Back to Reports</a>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/reports/maintenance-history" class="card mb-4">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Search</label>
                        <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Equipment name, asset ID, technician, date"/>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Asset ID</label>
                        <input type="text" class="form-control" name="assetId" value="${assetId}" placeholder="e.g. UPS-001"/>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Equipment Type</label>
                        <select class="form-select" name="equipmentType">
                            <option value="ALL" ${equipmentType == 'ALL' ? 'selected' : ''}>All</option>
                            <option value="UPS" ${equipmentType == 'UPS' ? 'selected' : ''}>UPS</option>
                            <option value="COOLING" ${equipmentType == 'COOLING' ? 'selected' : ''}>Cooling</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Technician</label>
                        <input type="text" class="form-control" name="technicianName" value="${technicianName}" placeholder="Technician name"/>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Maintenance Type</label>
                        <select class="form-select" name="maintenanceCategory">
                            <option value="ALL" ${maintenanceCategory == 'ALL' ? 'selected' : ''}>All</option>
                            <option value="PREVENTIVE" ${maintenanceCategory == 'PREVENTIVE' ? 'selected' : ''}>Preventive</option>
                            <option value="CORRECTIVE" ${maintenanceCategory == 'CORRECTIVE' ? 'selected' : ''}>Corrective</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>All</option>
                            <option value="OVERDUE" ${status == 'OVERDUE' ? 'selected' : ''}>Overdue</option>
                            <option value="SCHEDULED" ${status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
                            <option value="COMPLETED" ${status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">From Date</label>
                        <input type="date" class="form-control" name="fromDate" value="${fromDate}"/>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">To Date</label>
                        <input type="date" class="form-control" name="toDate" value="${toDate}"/>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Sort</label>
                        <select class="form-select" name="sort">
                            <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Newest First</option>
                            <option value="oldest" ${sort == 'oldest' ? 'selected' : ''}>Oldest First</option>
                        </select>
                    </div>
                </div>

                <div class="d-flex flex-wrap gap-2 mt-3">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Search</button>
                    <button type="submit" formaction="${pageContext.request.contextPath}/reports/maintenance-history/export" class="btn btn-outline-success"><i class="bi bi-download"></i> Export CSV</button>
                    <button type="button" class="btn btn-outline-secondary" onclick="window.print()"><i class="bi bi-printer"></i> Print</button>
                    <a href="${pageContext.request.contextPath}/reports/maintenance-history" class="btn btn-outline-dark"><i class="bi bi-arrow-counterclockwise"></i> Reset</a>
                </div>
            </div>
        </form>

        <div class="row g-3 mb-4">
            <div class="col-md-2"><div class="stat-card"><h6>Total</h6><h3>${report.totalMaintenanceRecords}</h3></div></div>
            <div class="col-md-2"><div class="stat-card"><h6>Preventive</h6><h3 class="text-primary">${report.preventiveRecords}</h3></div></div>
            <div class="col-md-2"><div class="stat-card"><h6>Corrective</h6><h3 class="text-warning">${report.correctiveRecords}</h3></div></div>
            <div class="col-md-2"><div class="stat-card"><h6>Overdue</h6><h3 class="text-danger">${report.overdueRecords}</h3></div></div>
            <div class="col-md-2"><div class="stat-card"><h6>Completed</h6><h3 class="text-success">${report.completedRecords}</h3></div></div>
            <div class="col-md-2"><div class="stat-card"><h6>Scheduled</h6><h3 class="text-info">${report.scheduledRecords}</h3></div></div>
        </div>

        <div class="card">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <h6 class="m-0 fw-bold">Maintenance Activity History</h6>
                <small class="text-muted">Range: ${report.dateRange} | Generated: ${report.generatedAt}</small>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped table-hover m-0 align-middle">
                        <thead>
                            <tr>
                                <th>Equipment Name</th>
                                <th>Asset ID</th>
                                <th>Type</th>
                                <th>Maintenance Date</th>
                                <th>Maintenance Category</th>
                                <th>Technician</th>
                                <th>Work Performed</th>
                                <th>Status</th>
                                <th>Remarks</th>
                                <th>Next Scheduled</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="record" items="${records}">
                                <tr>
                                    <td>${record.equipmentName}</td>
                                    <td>${record.assetId}</td>
                                    <td>${record.equipmentType}</td>
                                    <td>${record.maintenanceDate}</td>
                                    <td>${record.maintenanceType}</td>
                                    <td>${record.technicianName}</td>
                                    <td>${record.workPerformed}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${record.status == 'OVERDUE'}"><span class="badge bg-danger">${record.status}</span></c:when>
                                            <c:when test="${record.status == 'SCHEDULED'}"><span class="badge bg-info text-dark">${record.status}</span></c:when>
                                            <c:otherwise><span class="badge bg-success">${record.status}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${record.remarks}</td>
                                    <td>${record.nextScheduledMaintenance}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/reports/maintenance-history/${record.equipmentType}/${record.reportId}" class="btn btn-sm btn-outline-primary">Details</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty records}">
                                <tr>
                                    <td colspan="11" class="text-center text-muted py-4">No maintenance records found for the selected criteria.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
