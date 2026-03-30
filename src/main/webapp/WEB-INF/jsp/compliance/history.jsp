<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Download History</title>
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
            <h4 style="font-weight:700;margin:0;">Download History</h4>
            <p class="text-muted mb-0" style="font-size:14px;">Audit trail of exported reports</p>
        </div>
        <a href="${pageContext.request.contextPath}/compliance/reports/generate" class="btn btn-outline-primary">
            <i class="bi bi-plus-lg"></i> New Export
        </a>
    </div>

    <div class="card mb-3">
        <div class="card-body">
            <form method="get" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Start Date</label>
                    <input type="date" class="form-control" name="startDate" value="${selectedStartDate}">
                </div>
                <div class="col-md-3">
                    <label class="form-label">End Date</label>
                    <input type="date" class="form-control" name="endDate" value="${selectedEndDate}">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Report Type</label>
                    <select class="form-select" name="reportType">
                        <option value="">All</option>
                        <option value="maintenance" ${selectedReportType == 'maintenance' ? 'selected' : ''}>Maintenance</option>
                        <option value="shift" ${selectedReportType == 'shift' ? 'selected' : ''}>Shift</option>
                        <c:if test="${!isTechnician}">
                            <option value="equipment-health" ${selectedReportType == 'equipment-health' ? 'selected' : ''}>Equipment Health</option>
                            <option value="incidents" ${selectedReportType == 'incidents' ? 'selected' : ''}>Incidents</option>
                            <option value="daily" ${selectedReportType == 'daily' ? 'selected' : ''}>Daily</option>
                            <option value="compliance" ${selectedReportType == 'compliance' ? 'selected' : ''}>Compliance</option>
                        </c:if>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">User</label>
                    <select class="form-select" name="userId" ${isTechnician ? 'disabled' : ''}>
                        <option value="">All</option>
                        <c:forEach var="u" items="${users}">
                            <option value="${u.userId}" ${selectedUserId == u.userId ? 'selected' : ''}>${u.fullName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-12 d-flex gap-2">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Filter</button>
                    <a href="${pageContext.request.contextPath}/compliance/reports/history" class="btn btn-outline-secondary">Reset</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered table-sm">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Report Type</th>
                        <th>User</th>
                        <th>Format</th>
                        <th>File Path</th>
                        <th>Filters</th>
                        <th>Status</th>
                        <th>Generated At</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="log" items="${logs}">
                        <tr>
                            <td>${log.reportId}</td>
                            <td>${log.reportType}</td>
                            <td>${log.generatedBy != null ? log.generatedBy.fullName : 'System'}</td>
                            <td><span class="badge bg-info text-dark">${log.fileFormat}</span></td>
                            <td>
                                <c:if test="${not empty log.filePath}">
                                    <a href="${pageContext.request.contextPath}${log.filePath}" target="_blank">${log.filePath}</a>
                                </c:if>
                                <c:if test="${empty log.filePath}">-</c:if>
                            </td>
                            <td style="max-width:260px; white-space:normal;">${log.filtersUsed}</td>
                            <td>
                                <span class="badge ${log.status == 'SUCCESS' ? 'bg-success' : 'bg-danger'}">${log.status}</span>
                            </td>
                            <td>${log.generatedAt}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty logs}">
                        <tr><td colspan="8" class="text-center text-muted">No report logs found.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>
