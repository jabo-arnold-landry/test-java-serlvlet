<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>SPCMS - Incidents</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                    rel="stylesheet">
                <jsp:include page="../common/styles.jsp" />
                <style>
                    .action-btns {
                        display: flex;
                        gap: 6px;
                        flex-wrap: nowrap;
                    }

                    .btn-delete {
                        border-color: #e74c3c;
                        color: #e74c3c;
                    }

                    .btn-delete:hover {
                        background: #e74c3c;
                        color: #fff;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="../common/sidebar.jsp" />
                <jsp:include page="../common/topbar.jsp" />
                <div class="main-content">

                    <%-- Flash Messages --%>
                        <c:if test="${not empty success}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <i class="bi bi-check-circle-fill me-2"></i>${success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h4 style="font-weight:700;margin:0;"><i
                                        class="bi bi-exclamation-octagon text-danger me-2"></i>Incident Logger</h4>
                                <p class="text-muted mb-0" style="font-size:14px;">${openCount} open incident(s)</p>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/incidents/report" class="btn btn-outline-primary">
                                    <i class="bi bi-clipboard2-data me-1"></i> Incident Report
                                </a>
                                <a href="${pageContext.request.contextPath}/incidents/new" class="btn btn-danger">
                                    <i class="bi bi-plus-lg"></i> Report Incident
                                </a>
                            </div>
                        </div>

                        <div class="table-container">
                            <table class="table table-hover" id="incidentsTable">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Title</th>
                                        <th>Type</th>
                                        <th>Severity</th>
                                        <th>Status</th>
                                        <th>Downtime (min)</th>
                                        <th>Attachment</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="inc" items="${incidents}">
                                        <tr>
                                            <td><strong>#INC-${inc.incidentId}</strong></td>
                                            <td>${inc.title}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${inc.equipmentType == 'UPS'}">⚡ UPS</c:when>
                                                    <c:when test="${inc.equipmentType == 'COOLING'}">❄️ Cooling</c:when>
                                                    <c:otherwise>🔧 ${inc.equipmentType}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="badge
                                ${inc.severity == 'CRITICAL' ? 'bg-danger' :
                                  inc.severity == 'HIGH'     ? 'bg-warning text-dark' :
                                  inc.severity == 'MEDIUM'   ? 'bg-info text-dark' : 'bg-secondary'}">
                                                    ${inc.severity}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge
                                ${inc.status == 'OPEN'        ? 'bg-danger' :
                                  inc.status == 'IN_PROGRESS' ? 'bg-primary' :
                                  inc.status == 'RESOLVED'    ? 'bg-success' : 'bg-secondary'}">
                                                    ${inc.status}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${inc.downtimeMinutes != null}">
                                                        <strong>${inc.downtimeMinutes}</strong>
                                                        <span class="text-muted" style="font-size:11px;">min</span>
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty inc.attachmentPath}">
                                                        <a href="${inc.attachmentPath}" target="_blank"
                                                            class="btn btn-sm btn-outline-secondary"
                                                            title="View Attachment">
                                                            <i class="bi bi-paperclip"></i>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted"
                                                            style="font-size:12px;">None</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="action-btns">
                                                    <a href="${pageContext.request.contextPath}/incidents/view/${inc.incidentId}"
                                                        class="btn btn-sm btn-outline-primary" title="View">
                                                        <i class="bi bi-eye"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/incidents/edit/${inc.incidentId}"
                                                        class="btn btn-sm btn-outline-warning" title="Edit">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                    <button type="button"
                                                        class="btn btn-sm btn-delete btn-outline-danger" title="Delete"
                                                        onclick="confirmDelete(${inc.incidentId}, '${inc.title}')">
                                                        <i class="bi bi-trash3"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty incidents}">
                                        <tr>
                                            <td colspan="8" class="text-center text-muted py-5">
                                                <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                                                No incidents recorded yet
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                </div>

                <%-- Delete Confirmation Modal --%>
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
                                    <p class="text-muted">Are you sure you want to permanently delete:</p>
                                    <p class="fw-bold" id="deleteIncidentName" style="color:#fff;"></p>
                                    <p class="text-muted" style="font-size:13px;">This action cannot be undone.</p>
                                </div>
                                <div class="modal-footer border-0">
                                    <button type="button" class="btn btn-outline-secondary"
                                        data-bs-dismiss="modal">Cancel</button>
                                    <form id="deleteForm" method="post">
                                        <button type="submit" class="btn btn-danger"><i class="bi bi-trash3"></i>
                                            Delete</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
                    <script>
                        function confirmDelete(id, title) {
                            document.getElementById('deleteIncidentName').textContent = '#INC-' + id + ': ' + title;
                            document.getElementById('deleteForm').action =
                                '${pageContext.request.contextPath}/incidents/delete/' + id;
                            new bootstrap.Modal(document.getElementById('deleteModal')).show();
                        }
                    </script>
            </body>

            </html>