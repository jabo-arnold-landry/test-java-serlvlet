<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Decision Making</title>
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
                <h4 style="font-weight:700;margin:0;">Decision Making</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Maintenance budgets, equipment replacement, and procurement approvals</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/decisions/new" class="btn btn-primary">
                    <i class="bi bi-plus-lg"></i> New Request
                </a>
                <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
                    <a href="${pageContext.request.contextPath}/decisions/report" class="btn btn-outline-secondary">
                        <i class="bi bi-graph-up"></i> Report
                    </a>
                </sec:authorize>
            </div>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Title</th>
                        <th>Asset/System</th>
                        <th>Estimated Cost</th>
                        <th>Status</th>
                        <th>Requested By</th>
                        <th>Requested At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="req" items="${decisionRequests}">
                        <tr>
                            <td>${fn:replace(req.requestType, '_', ' ')}</td>
                            <td><strong>${req.title}</strong></td>
                            <td>${req.assetOrSystem}</td>
                            <td>${req.estimatedCost}</td>
                            <td>
                                <span class="badge
                                    ${req.status == 'APPROVED' ? 'bg-success' : (req.status == 'REJECTED' ? 'bg-danger' : 'bg-warning')}">
                                    ${req.status}
                                </span>
                            </td>
                            <td>${req.requestedBy != null ? req.requestedBy.fullName : 'N/A'}</td>
                            <td>${req.requestedAt}</td>
                            <td>
                                <c:if test="${currentUser.role == 'ADMIN' || (req.requestedBy != null && req.requestedBy.userId == currentUser.userId && req.status == 'PENDING')}">
                                    <a href="${pageContext.request.contextPath}/decisions/edit/${req.requestId}" class="btn btn-sm btn-outline-secondary">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/decisions/delete/${req.requestId}" method="post" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this decision request?')">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                        <c:if test="${currentUser.role == 'ADMIN' && req.status == 'PENDING'}">
                            <tr>
                                <td colspan="8" style="background:#f9fafb;">
                                    <form method="post" class="d-flex gap-2 align-items-center flex-wrap">
                                        <input type="text" class="form-control form-control-sm" name="decisionNotes" placeholder="Decision notes (optional)" style="max-width:380px;">
                                        <button type="submit" class="btn btn-sm btn-success" formaction="${pageContext.request.contextPath}/decisions/approve/${req.requestId}">
                                            <i class="bi bi-check-circle"></i> Approve
                                        </button>
                                        <button type="submit" class="btn btn-sm btn-danger" formaction="${pageContext.request.contextPath}/decisions/reject/${req.requestId}">
                                            <i class="bi bi-x-circle"></i> Reject
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:if>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
