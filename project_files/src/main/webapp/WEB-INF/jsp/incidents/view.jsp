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
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty info}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="bi bi-info-circle-fill me-2"></i>${info}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Incident #${incident.incidentId}: ${incident.title}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    Logged: ${incident.createdAt} |
                    Status: ${incident.status} |
                    Severity: ${incident.severity}
                </p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
                <a href="${pageContext.request.contextPath}/incidents/edit/${incident.incidentId}" class="btn btn-warning text-dark"><i class="bi bi-pencil"></i> Edit</a>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-3"><div class="stat-card"><h6>Status</h6><h3>${incident.status}</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Severity</h6><h3>${incident.severity}</h3></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Downtime</h6><h3>${incident.downtimeMinutes != null ? incident.downtimeMinutes : 0}</h3><small class="text-muted">minutes</small></div></div>
            <div class="col-md-3"><div class="stat-card"><h6>Assigned To</h6><h3 style="font-size:1.1rem;">${incident.assignedTo != null ? incident.assignedTo.fullName : 'Unassigned'}</h3></div></div>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header bg-white"><h6 class="m-0 fw-bold">Incident Details</h6></div>
                    <div class="card-body">
                        <p><strong>Equipment:</strong> ${incident.equipmentType} <c:if test="${incident.equipmentId != null}">#${incident.equipmentId}</c:if></p>
                        <p><strong>Description:</strong> ${not empty incident.description ? incident.description : 'N/A'}</p>
                        <p><strong>Root Cause:</strong> ${not empty incident.rootCause ? incident.rootCause : 'Not yet recorded'}</p>
                        <p><strong>Action Taken:</strong> ${not empty incident.actionTaken ? incident.actionTaken : 'Pending'}</p>
                        <p><strong>Reported By:</strong> ${incident.reportedBy != null ? incident.reportedBy.fullName : 'N/A'}</p>
                        <p><strong>Resolved By:</strong> ${incident.resolvedBy != null ? incident.resolvedBy.fullName : 'N/A'}</p>
                        <p><strong>Downtime Start:</strong> ${incident.downtimeStart != null ? incident.downtimeStart : 'N/A'}</p>
                        <p><strong>Downtime End:</strong> ${incident.downtimeEnd != null ? incident.downtimeEnd : 'N/A'}</p>
                        <p><strong>Last Updated:</strong> ${incident.updatedAt}</p>
                        <c:if test="${not empty incident.attachmentPath}">
                            <p><strong>Attachment:</strong> <a href="${pageContext.request.contextPath}${incident.attachmentPath}" target="_blank">Open attachment</a></p>
                        </c:if>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <c:if test="${pageContext.request.isUserInRole('TECHNICIAN') && (incident.status == 'OPEN' || incident.status == 'IN_PROGRESS')}">
                    <div class="card mb-3">
                        <div class="card-header bg-white"><h6 class="m-0 fw-bold">Assign Incident</h6></div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/incidents/assign/${incident.incidentId}" method="post">
                                <div class="mb-3">
                                    <label class="form-label">Technician</label>
                                    <select class="form-select" name="assigneeId" required>
                                        <option value="" disabled ${incident.assignedTo == null ? 'selected' : ''}>Select a technician</option>
                                        <c:forEach var="tech" items="${technicians}">
                                            <option value="${tech.userId}" ${incident.assignedTo != null && incident.assignedTo.userId == tech.userId ? 'selected' : ''}>${tech.fullName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">Assign</button>
                            </form>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header bg-white"><h6 class="m-0 fw-bold">Update Status</h6></div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/incidents/resolve/${incident.incidentId}" method="post">
                                <div class="mb-3">
                                    <label class="form-label">Technician</label>
                                    <select class="form-select" name="resolverId" required>
                                        <option value="" disabled ${incident.assignedTo == null ? 'selected' : ''}>Select a technician</option>
                                        <c:forEach var="tech" items="${technicians}">
                                            <option value="${tech.userId}" ${incident.assignedTo != null && incident.assignedTo.userId == tech.userId ? 'selected' : ''}>${tech.fullName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Downtime Start</label>
                                    <input type="datetime-local" class="form-control" name="downtimeStart" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Root Cause</label>
                                    <textarea class="form-control" name="rootCause" rows="2">${incident.rootCause}</textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Action Taken</label>
                                    <textarea class="form-control" name="actionTaken" rows="2">${incident.actionTaken}</textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <select class="form-select" name="newStatus">
                                        <option value="IN_PROGRESS">In Progress</option>
                                        <option value="RESOLVED">Resolved</option>
                                        <option value="CLOSED">Closed</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-success w-100">Update</button>
                            </form>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
