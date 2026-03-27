<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - System Audit Logs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .font-monospace { font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace !important; }
        .bg-slate-900 { background-color: #0f172a; }
        .text-slate-400 { color: #94a3b8; }
        .rounded-4 { border-radius: 1rem !important; }
        .audit-item:hover { background-color: #f8fafc; }
    </style>
</head>
<body>

    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="container-fluid py-5">
            <div class="d-flex align-items-center justify-content-between mb-5">
                <div>
                    <h2 class="fw-bold text-dark mb-1">System Audit Terminal</h2>
                    <p class="text-muted mb-0">Comprehensive tracking of all visitor management operations and security events</p>
                </div>
                <button onclick="window.print()" class="btn btn-outline-primary rounded-pill px-4">
                    <i class="bi bi-printer me-2"></i>Export PDF
                </button>
            </div>

            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="table-responsive">
                    <table class="table align-middle mb-0">
                        <thead class="bg-slate-900 text-white">
                            <tr>
                                <th class="px-4 py-3 small text-uppercase fw-bold">Timestamp</th>
                                <th class="px-4 py-3 small text-uppercase fw-bold">Operator</th>
                                <th class="px-4 py-3 small text-uppercase fw-bold">Action</th>
                                <th class="px-4 py-3 small text-uppercase fw-bold">Entity</th>
                                <th class="px-4 py-3 small text-uppercase fw-bold">Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="log" items="${logs}">
                                <tr class="audit-item">
                                    <td class="px-4 py-3 font-monospace small text-primary">
                                        ${log.timestamp.toString().replace('T', ' ').substring(0, 19)}
                                    </td>
                                    <td class="px-4 py-3">
                                        <div class="fw-bold text-dark">${log.user.fullName}</div>
                                        <div class="small text-muted">${log.user.role}</div>
                                    </td>
                                    <td class="px-4 py-3">
                                        <c:choose>
                                            <c:when test="${log.action == 'VISITOR_REGISTERED'}"><span class="badge bg-info bg-opacity-10 text-info rounded-pill px-3">REGISTERED</span></c:when>
                                            <c:when test="${log.action == 'VISIT_APPROVED'}"><span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3">APPROVED</span></c:when>
                                            <c:when test="${log.action == 'VISITOR_CHECK_IN'}"><span class="badge bg-primary bg-opacity-10 text-primary rounded-pill px-3">CHECK-IN</span></c:when>
                                            <c:when test="${log.action == 'VISITOR_CHECK_OUT'}"><span class="badge bg-secondary bg-opacity-10 text-secondary rounded-pill px-3">CHECK-OUT</span></c:when>
                                            <c:when test="${log.action == 'INCIDENT_REPORTED'}"><span class="badge bg-danger bg-opacity-10 text-danger rounded-pill px-3">INCIDENT</span></c:when>
                                            <c:otherwise><span class="badge bg-light text-dark rounded-pill px-3">${log.action}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-3">
                                        <div class="small fw-bold text-dark">${log.entityType}</div>
                                        <div class="small text-muted">ID: ${log.entityId}</div>
                                    </td>
                                    <td class="px-4 py-3 small text-secondary">
                                        ${log.details}
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty logs}">
                                <tr>
                                    <td colspan="5" class="text-center py-5">
                                        <i class="bi bi-shield-slash fs-1 text-light mb-3 d-block"></i>
                                        <p class="text-muted">No system activity has been recorded in the current audit period.</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="mt-4 text-center">
                <p class="text-muted small">Showing last 100 entries. For full historical data, please contact the System Administrator.</p>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
