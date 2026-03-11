<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Incident Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty info}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="bi bi-info-circle-fill"></i> ${info}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Incident #${incident.incidentId}: ${incident.title}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Logged: ${incident.createdAt} | Equipment: ${incident.equipmentType} #${incident.equipmentId}</p>
            </div>
            <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Status</div>
                    <span class="badge ${incident.status == 'OPEN' ? 'bg-danger' : incident.status == 'IN_PROGRESS' ? 'bg-warning' : incident.status == 'RESOLVED' ? 'bg-success' : 'bg-secondary'} fs-6 mt-2">${incident.status}</span>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Severity</div>
                    <span class="badge ${incident.severity == 'CRITICAL' ? 'bg-danger' : incident.severity == 'HIGH' ? 'bg-warning' : incident.severity == 'MEDIUM' ? 'bg-info' : 'bg-secondary'} fs-6 mt-2">${incident.severity}</span>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Downtime</div>
                    <div class="stat-value">${incident.downtimeMinutes != null ? incident.downtimeMinutes : 'N/A'}</div>
                    <div class="text-muted" style="font-size:12px;">minutes</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Assigned To</div>
                    <div style="font-size:16px;font-weight:600;margin-top:8px;">${incident.assignedTo != null ? incident.assignedTo.fullName : 'Unassigned'}</div>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-8">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-file-text"></i> Incident Details</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:30%;">Description</td><td>${incident.description}</td></tr>
                        <tr><td class="text-muted">Downtime Start</td><td>${incident.downtimeStart}</td></tr>
                        <tr><td class="text-muted">Downtime End</td><td>${incident.downtimeEnd}</td></tr>
                        <tr><td class="text-muted">Root Cause</td><td>${incident.rootCause != null ? incident.rootCause : 'Not yet determined'}</td></tr>
                        <tr><td class="text-muted">Action Taken</td><td>${incident.actionTaken != null ? incident.actionTaken : 'Pending'}</td></tr>
                        <tr><td class="text-muted">Reported By</td><td>${incident.reportedBy != null ? incident.reportedBy.fullName : 'N/A'}</td></tr>
                        <c:if test="${incident.attachmentPath != null}">
                        <tr><td class="text-muted">Attachment</td><td><a href="${incident.attachmentPath}" target="_blank">View Attachment</a></td></tr>
                        </c:if>
                    </table>
                </div>
            </div>
            <div class="col-md-4">
                <c:if test="${incident.status == 'OPEN' || incident.status == 'IN_PROGRESS'}">
                <div class="stat-card mb-3">
                    <h6 class="fw-bold mb-3"><i class="bi bi-person-check"></i> Assign Incident</h6>
                    <form action="${pageContext.request.contextPath}/incidents/assign/${incident.incidentId}" method="post">
                        <div class="mb-3">
                            <label class="form-label">Assign to User ID</label>
                            <input type="number" class="form-control" name="assigneeId" required/>
                        </div>
                        <button type="submit" class="btn btn-primary btn-sm w-100"><i class="bi bi-person-plus"></i> Assign</button>
                    </form>
                </div>
                </c:if>
                <c:if test="${incident.status == 'IN_PROGRESS'}">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-check-circle"></i> Resolve Incident</h6>
                    <form action="${pageContext.request.contextPath}/incidents/resolve/${incident.incidentId}" method="post">
                        <div class="mb-3">
                            <label class="form-label">Root Cause</label>
                            <textarea class="form-control" name="rootCause" rows="2" required></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Action Taken</label>
                            <textarea class="form-control" name="actionTaken" rows="2" required></textarea>
                        </div>
                        <button type="submit" class="btn btn-success btn-sm w-100"><i class="bi bi-check-lg"></i> Mark Resolved</button>
                    </form>
                </div>
                </c:if>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
