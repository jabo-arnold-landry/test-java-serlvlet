<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Decision Report</title>
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
                <h4 style="font-weight:700;margin:0;">Decision Report</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Filter approvals by date, status, and type</p>
            </div>
            <a href="${pageContext.request.contextPath}/decisions" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="stat-card mb-4">
            <form method="get" action="${pageContext.request.contextPath}/decisions/report" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Start Date</label>
                    <input type="date" class="form-control" name="start" value="${start}"/>
                </div>
                <div class="col-md-3">
                    <label class="form-label">End Date</label>
                    <input type="date" class="form-control" name="end" value="${end}"/>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Status</label>
                    <select class="form-select" name="status">
                        <option value="">All</option>
                        <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="APPROVED" ${status == 'APPROVED' ? 'selected' : ''}>Approved</option>
                        <option value="REJECTED" ${status == 'REJECTED' ? 'selected' : ''}>Rejected</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select class="form-select" name="type">
                        <option value="">All</option>
                        <option value="MAINTENANCE_BUDGET" ${type == 'MAINTENANCE_BUDGET' ? 'selected' : ''}>Maintenance Budget</option>
                        <option value="EQUIPMENT_REPLACEMENT" ${type == 'EQUIPMENT_REPLACEMENT' ? 'selected' : ''}>Equipment Replacement</option>
                        <option value="UPS_PROCUREMENT" ${type == 'UPS_PROCUREMENT' ? 'selected' : ''}>UPS Procurement</option>
                        <option value="COOLING_PROCUREMENT" ${type == 'COOLING_PROCUREMENT' ? 'selected' : ''}>Cooling Procurement</option>
                    </select>
                </div>
                <div class="col-12">
                    <button class="btn btn-primary"><i class="bi bi-funnel"></i> Apply Filters</button>
                </div>
            </form>
        </div>

        <div class="table-container">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Title</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Decision Time</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="d" items="${decisions}">
                        <tr>
                            <td>${d.decisionId}</td>
                            <td>${d.requestType}</td>
                            <td>${d.title}</td>
                            <td><c:if test="${d.amount != null}">${d.amount}</c:if></td>
                            <td>${d.status}</td>
                            <td>${d.decisionTime}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty decisions}">
                        <tr><td colspan="6" class="text-center text-muted py-4">No results for the selected filters.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
