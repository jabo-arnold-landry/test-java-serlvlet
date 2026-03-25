<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Incident Report</title>
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
                <h4 style="font-weight:700;margin:0;">Incident Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Generate incident details by date range</p>
            </div>
            <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
        </div>

        <div class="stat-card mb-4">
            <form action="${pageContext.request.contextPath}/incidents/report" method="post">
                <div class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label">Start Date</label>
                        <input type="date" class="form-control" name="startDate" value="${reportStart}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">End Date</label>
                        <input type="date" class="form-control" name="endDate" value="${reportEnd}"/>
                        <div class="text-muted" style="font-size:12px;">Leave blank to use start date only.</div>
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-file-earmark-text"></i> Generate Report
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <c:if test="${reportIncidents != null}">
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Total Incidents</div>
                        <div class="stat-value">${fn:length(reportIncidents)}</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Critical Incidents</div>
                        <div class="stat-value">${criticalCount}</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Total Downtime</div>
                        <div class="stat-value">${totalDowntime}</div>
                        <div class="text-muted" style="font-size:12px;">minutes</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Date Range</div>
                        <div class="stat-value" style="font-size:16px;">${reportStart} to ${reportEnd}</div>
                    </div>
                </div>
            </div>

            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Title</th>
                            <th>Equipment</th>
                            <th>Severity</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th>Down Start</th>
                            <th>Down End</th>
                            <th>Down (min)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="inc" items="${reportIncidents}">
                        <tr>
                            <td>#INC-${inc.incidentId}</td>
                            <td>${inc.title}</td>
                            <td>
                                ${inc.equipmentType}
                                <c:if test="${inc.equipmentId != null}">#${inc.equipmentId}</c:if>
                            </td>
                            <td>${inc.severity}</td>
                            <td>${inc.status}</td>
                            <td>${inc.createdAt}</td>
                            <td>${inc.downtimeStart}</td>
                            <td>${inc.downtimeEnd}</td>
                            <td>${inc.downtimeMinutes != null ? inc.downtimeMinutes : '-'}</td>
                        </tr>
                        <tr class="table-light">
                            <td colspan="9">
                                <div><strong>Description:</strong> ${inc.description}</div>
                                <div><strong>Root Cause:</strong> ${inc.rootCause != null ? inc.rootCause : 'Not yet determined'}</div>
                                <div><strong>Action Taken:</strong> ${inc.actionTaken != null ? inc.actionTaken : 'Pending'}</div>
                                <div><strong>Reported By:</strong> ${inc.reportedBy != null ? inc.reportedBy.fullName : 'N/A'}</div>
                                <div><strong>Assigned To:</strong> ${inc.assignedTo != null ? inc.assignedTo.fullName : 'Unassigned'}</div>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty reportIncidents}">
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">No incidents found for the selected date range.</td>
                        </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
