<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Decision Requests</title>
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
                <h4 style="font-weight:700;margin:0;">Decision Requests</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Approve maintenance budgets, equipment replacement, and procurement</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/decisions/report" class="btn btn-outline-secondary"><i class="bi bi-bar-chart-line"></i> Report</a>
                <a href="${pageContext.request.contextPath}/decisions/new" class="btn btn-primary"><i class="bi bi-plus-circle"></i> New Request</a>
            </div>
        </div>

        <c:if test="${not empty pending}">
            <div class="alert alert-warning">
                <strong>Pending:</strong> ${pending.size()} request(s) awaiting approval.
            </div>
        </c:if>

        <div class="table-container">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Title</th>
                        <th>Amount</th>
                        <th>Requested By</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="d" items="${decisions}">
                        <tr>
                            <td>${d.decisionId}</td>
                            <td>${d.requestType}</td>
                            <td><strong>${d.title}</strong></td>
                            <td><c:if test="${d.amount != null}">${d.amount}</c:if></td>
                            <td>${d.requestedBy != null ? d.requestedBy.fullName : 'N/A'}</td>
                            <td>
                                <span class="badge ${d.status == 'APPROVED' ? 'bg-success' : (d.status == 'REJECTED' ? 'bg-danger' : 'bg-warning text-dark')}">
                                    ${d.status}
                                </span>
                            </td>
                            <td>${d.createdAt}</td>
                            <td class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/decisions/view/${d.decisionId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                                <a href="${pageContext.request.contextPath}/decisions/edit/${d.decisionId}" class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></a>
                                <a href="${pageContext.request.contextPath}/decisions/delete/${d.decisionId}" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this decision request?');"><i class="bi bi-trash"></i></a>
                                <sec:authorize access="hasRole('ADMIN')">
                                    <c:if test="${d.status == 'PENDING'}">
                                        <form action="${pageContext.request.contextPath}/decisions/approve/${d.decisionId}" method="post" class="d-inline">
                                            <input type="hidden" name="remarks" value="Approved">
                                            <button class="btn btn-sm btn-success"><i class="bi bi-check2-circle"></i></button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/decisions/reject/${d.decisionId}" method="post" class="d-inline">
                                            <input type="hidden" name="remarks" value="Rejected">
                                            <button class="btn btn-sm btn-danger"><i class="bi bi-x-circle"></i></button>
                                        </form>
                                    </c:if>
                                </sec:authorize>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty decisions}">
                        <tr><td colspan="8" class="text-center text-muted py-4">No decision requests found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
