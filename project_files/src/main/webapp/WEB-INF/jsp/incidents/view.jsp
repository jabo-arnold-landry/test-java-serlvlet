<<<<<<< HEAD
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">
=======
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
>>>>>>> origin/ft-kimenyi

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>SPCMS - Incident #${incident.incidentId}</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                    rel="stylesheet">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <jsp:include page="../common/styles.jsp" />
                <style>
                    .detail-row {
                        padding: 10px 0;
                        border-bottom: 1px solid rgba(255, 255, 255, 0.06);
                    }

                    .detail-row:last-child {
                        border-bottom: none;
                    }

                    .detail-label {
                        font-size: 12px;
                        font-weight: 600;
                        color: #888;
                        text-transform: uppercase;
                        letter-spacing: 0.05em;
                    }

                    .detail-value {
                        font-size: 14px;
                        color: #eee;
                        margin-top: 2px;
                    }

                    .attachment-preview {
                        border: 1px solid rgba(255, 255, 255, 0.1);
                        border-radius: 8px;
                        padding: 12px 16px;
                    }

                    .timeline-dot {
                        width: 10px;
                        height: 10px;
                        border-radius: 50%;
                        display: inline-block;
                        margin-right: 6px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="../common/sidebar.jsp" />
                <jsp:include page="../common/topbar.jsp" />
                <div class="main-content">

                    <%-- Flash Messages --%>
                        <c:if test="${not empty success}">
                            <div class="alert alert-success alert-dismissible fade show">
                                <i class="bi bi-check-circle-fill me-2"></i>${success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <%-- Page Header --%>
                            <div class="d-flex justify-content-between align-items-start mb-4">
                                <div>
                                    <h4 style="font-weight:700;margin:0;">
                                        <span class="badge bg-secondary me-2"
                                            style="font-size:14px;">#INC-${incident.incidentId}</span>
                                        ${incident.title}
                                    </h4>
                                    <p class="text-muted mb-0" style="font-size:13px;">
                                        <i class="bi bi-clock me-1"></i>Logged: ${incident.createdAt} &nbsp;|&nbsp;
                                        <i class="bi bi-tools me-1"></i>${incident.equipmentType}
                                        <c:if test="${incident.equipmentId != null}"> #${incident.equipmentId}</c:if>
                                        <c:if test="${incident.reportedBy != null}">
                                            &nbsp;|&nbsp; <i
                                                class="bi bi-person me-1"></i>${incident.reportedBy.fullName}
                                        </c:if>
                                    </p>
                                </div>
                                <div class="d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/incidents"
                                        class="btn btn-outline-secondary btn-sm">
                                        <i class="bi bi-arrow-left"></i> Back
                                    </a>
                                    <a href="${pageContext.request.contextPath}/incidents/edit/${incident.incidentId}"
                                        class="btn btn-warning btn-sm text-dark fw-bold">
                                        <i class="bi bi-pencil"></i> Edit
                                    </a>
                                    <button type="button" class="btn btn-outline-danger btn-sm" onclick="document.getElementById('deleteModal').querySelector('form').action=
                                '${pageContext.request.contextPath}/incidents/delete/${incident.incidentId}';
                                new bootstrap.Modal(document.getElementById('deleteModal')).show();">
                                        <i class="bi bi-trash3"></i> Delete
                                    </button>
                                </div>
                            </div>

                            <%-- Stats Row --%>
                                <div class="row g-3 mb-4">
                                    <div class="col-md-3">
                                        <div class="stat-card text-center">
                                            <div class="stat-label">Status</div>
                                            <span class="badge fs-6 mt-2
                        ${incident.status == 'OPEN'        ? 'bg-danger' :
                          incident.status == 'IN_PROGRESS' ? 'bg-warning text-dark' :
                          incident.status == 'RESOLVED'    ? 'bg-success' : 'bg-secondary'}">
                                                ${incident.status}
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="stat-card text-center">
                                            <div class="stat-label">Severity</div>
                                            <span class="badge fs-6 mt-2
                        ${incident.severity == 'CRITICAL' ? 'bg-danger' :
                          incident.severity == 'HIGH'     ? 'bg-warning text-dark' :
                          incident.severity == 'MEDIUM'   ? 'bg-info text-dark' : 'bg-secondary'}">
                                                ${incident.severity}
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="stat-card text-center">
                                            <div class="stat-label">Downtime</div>
                                            <div class="stat-value">${incident.downtimeMinutes != null ?
                                                incident.downtimeMinutes : '—'}</div>
                                            <c:if test="${incident.downtimeMinutes != null}">
                                                <div class="text-muted" style="font-size:12px;">minutes</div>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="stat-card text-center">
                                            <div class="stat-label">Assigned To</div>
                                            <div style="font-size:15px;font-weight:600;margin-top:8px;">
                                                ${incident.assignedTo != null ? incident.assignedTo.fullName :
                                                'Unassigned'}
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row g-3 mb-4">
                                    <%-- Main Details --%>
                                        <div class="col-md-8">
                                            <div class="stat-card">
                                                <h6 class="fw-bold mb-3"><i class="bi bi-file-text me-2"></i>Incident
                                                    Details</h6>

                                                <div class="detail-row">
                                                    <div class="detail-label">Description</div>
                                                    <div class="detail-value">${not empty incident.description ?
                                                        incident.description : '—'}</div>
                                                </div>
                                                <div class="detail-row">
                                                    <div class="detail-label">Root Cause</div>
                                                    <div class="detail-value">${not empty incident.rootCause ?
                                                        incident.rootCause : 'Not yet determined'}</div>
                                                </div>
                                                <div class="detail-row">
                                                    <div class="detail-label">Action Taken</div>
                                                    <div class="detail-value">${not empty incident.actionTaken ?
                                                        incident.actionTaken : 'Pending'}</div>
                                                </div>
                                                <div class="detail-row row g-0">
                                                    <div class="col-md-6">
                                                        <div class="detail-label">Downtime Start</div>
                                                        <div class="detail-value">${incident.downtimeStart != null ?
                                                            incident.downtimeStart : '—'}</div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="detail-label">Downtime End</div>
                                                        <div class="detail-value">${incident.downtimeEnd != null ?
                                                            incident.downtimeEnd : '—'}</div>
                                                    </div>
                                                </div>
                                                <div class="detail-row">
                                                    <div class="detail-label">Reported By</div>
                                                    <div class="detail-value">${incident.reportedBy != null ?
                                                        incident.reportedBy.fullName : 'N/A'}</div>
                                                </div>
                                                <c:if test="${incident.status == 'RESOLVED' || incident.status == 'CLOSED'}">
                                                    <div class="detail-row">
                                                        <div class="detail-label">Resolved By</div>
                                                        <div class="detail-value">${incident.resolvedBy != null ? incident.resolvedBy.fullName : '—'}</div>
                                                    </div>
                                                </c:if>
                                                <div class="detail-row">
                                                    <div class="detail-label">Last Updated</div>
                                                    <div class="detail-value">${incident.updatedAt}</div>
                                                </div>

                                                <%-- Attachment Section --%>
                                                    <c:if test="${not empty incident.attachmentPath}">
                                                        <div class="detail-row">
                                                            <div class="detail-label mb-2">Attachment</div>
                                                            <div
                                                                class="attachment-preview d-flex align-items-center gap-3">
                                                                <c:choose>
                                                                    <c:when
                                                                        test="${incident.attachmentPath.endsWith('.jpg') || incident.attachmentPath.endsWith('.jpeg') || incident.attachmentPath.endsWith('.png') || incident.attachmentPath.endsWith('.gif')}">
                                                                        <i class="bi bi-file-image text-info fs-3"></i>
                                                                        <div>
                                                                            <div
                                                                                style="font-weight:600;font-size:13px;">
                                                                                Photo Attachment</div>
                                                                            <a href="${pageContext.request.contextPath}${incident.attachmentPath}"
                                                                                target="_blank" class="text-primary"
                                                                                style="font-size:12px;">
                                                                                <i
                                                                                    class="bi bi-box-arrow-up-right me-1"></i>View
                                                                                Photo
                                                                            </a>
                                                                        </div>
                                                                        <a href="${pageContext.request.contextPath}${incident.attachmentPath}"
                                                                            target="_blank" class="ms-auto">
                                                                            <img src="${pageContext.request.contextPath}${incident.attachmentPath}"
                                                                                alt="Attachment preview"
                                                                                style="max-height:60px;max-width:120px;border-radius:6px;object-fit:cover;"
                                                                                onerror="this.style.display='none'" />
                                                                        </a>
                                                                    </c:when>
                                                                    <c:when
                                                                        test="${incident.attachmentPath.endsWith('.pdf')}">
                                                                        <i class="bi bi-file-pdf text-danger fs-3"></i>
                                                                        <div>
                                                                            <div
                                                                                style="font-weight:600;font-size:13px;">
                                                                                PDF Report</div>
                                                                            <a href="${pageContext.request.contextPath}${incident.attachmentPath}"
                                                                                target="_blank" class="text-primary"
                                                                                style="font-size:12px;">
                                                                                <i
                                                                                    class="bi bi-box-arrow-up-right me-1"></i>Open
                                                                                PDF
                                                                            </a>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <i
                                                                            class="bi bi-file-earmark text-secondary fs-3"></i>
                                                                        <div>
                                                                            <div
                                                                                style="font-weight:600;font-size:13px;">
                                                                                Document</div>
                                                                            <a href="${pageContext.request.contextPath}${incident.attachmentPath}"
                                                                                target="_blank" class="text-primary"
                                                                                style="font-size:12px;">
                                                                                <i
                                                                                    class="bi bi-download me-1"></i>Download
                                                                                File
                                                                            </a>
                                                                        </div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </c:if>
                                            </div>
                                        </div>

                                        <%-- Action Panel --%>
                                            <div class="col-md-4">
                                                <%-- Assign --%>
                                                    <c:if
                                                        test="${(incident.status == 'OPEN' || incident.status == 'IN_PROGRESS') && pageContext.request.isUserInRole('TECHNICIAN')}">
                                                        <div class="stat-card mb-3">
                                                            <h6 class="fw-bold mb-3"><i
                                                                    class="bi bi-person-check me-2"></i>Assign Incident
                                                            </h6>
                                                            <form
                                                                action="${pageContext.request.contextPath}/incidents/assign/${incident.incidentId}"
                                                                method="post">
                                                                <div class="mb-3">
                                                                    <label class="form-label">Assign to Technician</label>
                                                                    <select class="form-select" name="assigneeId" required>
                                                                        <option value="" disabled ${incident.assignedTo == null ? 'selected' : ''}>Select a technician</option>
                                                                        <c:forEach var="tech" items="${technicians}">
                                                                            <option value="${tech.userId}" ${incident.assignedTo != null && incident.assignedTo.userId == tech.userId ? 'selected' : ''}>
                                                                                ${tech.fullName}
                                                                            </option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                                <button type="submit"
                                                                    class="btn btn-primary btn-sm w-100">
                                                                    <i class="bi bi-person-plus"></i> Assign
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </c:if>

                                                    <%-- Resolve --%>
                                                        <c:if
                                                            test="${(incident.status == 'OPEN' || incident.status == 'IN_PROGRESS') && pageContext.request.isUserInRole('TECHNICIAN')}">
                                                            <div class="stat-card mb-3">
                                                                <h6 class="fw-bold mb-3"><i
                                                                        class="bi bi-gear-fill me-2"></i>Update Status</h6>
                                                                <form
                                                                    action="${pageContext.request.contextPath}/incidents/resolve/${incident.incidentId}"
                                                                    method="post">
                                                                    <div class="mb-2">
                                                                        <label class="form-label">Technician (Logger)</label>
                                                                        <select class="form-select" name="resolverId" required>
                                                                            <option value="" disabled ${incident.resolvedBy == null ? 'selected' : ''}>Select a technician</option>
                                                                            <c:forEach var="tech" items="${technicians}">
                                                                                <option value="${tech.userId}" ${incident.assignedTo != null && incident.assignedTo.userId == tech.userId ? 'selected' : ''}>
                                                                                    ${tech.fullName}
                                                                                </option>
                                                                            </c:forEach>
                                                                        </select>
                                                                    </div>
                                                                    <div class="mb-2">
                                                                        <label class="form-label">Downtime Start</label>
                                                                        <input type="datetime-local" class="form-control" name="downtimeStart" value="${incident.downtimeStart}" required />
                                                                    </div>
                                                                    <div class="mb-2">
                                                                        <label class="form-label">Root Cause</label>
                                                                        <textarea class="form-control" name="rootCause"
                                                                            rows="2"
                                                                            placeholder="Root cause...">${incident.rootCause}</textarea>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Action Taken</label>
                                                                        <textarea class="form-control"
                                                                            name="actionTaken" rows="2"
                                                                            placeholder="Steps taken...">${incident.actionTaken}</textarea>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Status</label>
                                                                        <select class="form-select" name="newStatus" required>
                                                                            <option value="IN_PROGRESS" ${incident.status == 'IN_PROGRESS' ? 'selected' : ''}>🔵 In Progress</option>
                                                                            <option value="RESOLVED" ${incident.status == 'RESOLVED' ? 'selected' : ''}>🟢 Resolved</option>
                                                                            <option value="CLOSED" ${incident.status == 'CLOSED' ? 'selected' : ''}>⚫ Closed</option>
                                                                        </select>
                                                                    </div>
                                                                    <button type="submit"
                                                                        class="btn btn-success btn-sm w-100">
                                                                        <i class="bi bi-arrow-clockwise"></i> Update Log
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </c:if>

                                                        <%-- Quick Edit Link --%>
                                                            <div class="stat-card">
                                                                <h6 class="fw-bold mb-3"><i
                                                                        class="bi bi-gear me-2"></i>Quick Actions</h6>
                                                                <div class="d-grid gap-2">
                                                                    <a href="${pageContext.request.contextPath}/incidents/edit/${incident.incidentId}"
                                                                        class="btn btn-warning text-dark btn-sm">
                                                                        <i class="bi bi-pencil-square me-1"></i>Full
                                                                        Edit
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/incidents"
                                                                        class="btn btn-outline-secondary btn-sm">
                                                                        <i class="bi bi-list-ul me-1"></i>All Incidents
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/incidents/new"
                                                                        class="btn btn-outline-danger btn-sm">
                                                                        <i class="bi bi-plus me-1"></i>New Incident
                                                                    </a>
                                                                </div>
                                                            </div>
                                            </div>
                                </div>
                </div>

                <%-- Delete Confirm Modal --%>
                    <div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content"
                                style="background:#1e1e2e;border:1px solid rgba(255,255,255,0.1);">
                                <div class="modal-header border-0">
                                    <h5 class="modal-title text-danger"><i class="bi bi-trash3-fill me-2"></i>Delete
                                        Incident</h5>
                                    <button type="button" class="btn-close btn-close-white"
                                        data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <p class="text-muted">You are about to permanently delete:</p>
                                    <p class="fw-bold" style="color:#fff;">#INC-${incident.incidentId}:
                                        ${incident.title}</p>
                                    <p class="text-muted" style="font-size:13px;">⚠️ This action cannot be undone.</p>
                                </div>
                                <div class="modal-footer border-0">
                                    <button type="button" class="btn btn-outline-secondary"
                                        data-bs-dismiss="modal">Cancel</button>
                                    <form method="post">
                                        <button type="submit" class="btn btn-danger"><i class="bi bi-trash3"></i>
                                            Delete</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>