<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Decision Report</title>
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
                <h4 style="font-weight:700;margin:0;">Decision Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Approval summary and decision history</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/decisions" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Back
                </a>
                <button class="btn btn-outline-primary" onclick="window.print()">
                    <i class="bi bi-printer"></i> Print
                </button>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="text-muted">Total Requests</div>
                    <div class="fs-4 fw-bold">${totalCount}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="text-muted">Pending</div>
                    <div class="fs-4 fw-bold text-warning">${pendingCount}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="text-muted">Approved</div>
                    <div class="fs-4 fw-bold text-success">${approvedCount}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="text-muted">Rejected</div>
                    <div class="fs-4 fw-bold text-danger">${rejectedCount}</div>
                </div>
            </div>
        </div>

        <div class="stat-card mb-4">
            <div class="text-muted">Total Approved Cost</div>
            <div class="fs-4 fw-bold">${approvedCostTotal}</div>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Title</th>
                        <th>Requested By</th>
                        <th>Status</th>
                        <th>Decision By</th>
                        <th>Decision Notes</th>
                        <th>Requested At</th>
                        <th>Decision At</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="req" items="${decisionRequests}">
                        <tr>
                            <td>${fn:replace(req.requestType, '_', ' ')}</td>
                            <td>${req.title}</td>
                            <td>${req.requestedBy != null ? req.requestedBy.fullName : 'N/A'}</td>
                            <td>${req.status}</td>
                            <td>${req.approvedBy != null ? req.approvedBy.fullName : '-'}</td>
                            <td>${req.decisionNotes}</td>
                            <td>${req.requestedAt}</td>
                            <td>${req.decisionAt}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
