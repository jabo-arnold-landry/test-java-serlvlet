<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Costs for ${equipmentType} #${maintenanceId}</title>
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
                <h4 style="font-weight:700;margin:0;">Costs for ${equipmentType} Maintenance #${maintenanceId}</h4>
                <small class="text-muted">All cost entries linked to this maintenance record</small>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/maintenance-costs/add?maintenanceId=${maintenanceId}&equipmentType=${equipmentType}"
                   class="btn btn-primary me-2"><i class="bi bi-plus-circle"></i> Add Cost</a>
                <a href="${pageContext.request.contextPath}/maintenance-costs"
                   class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back to Dashboard</a>
            </div>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Cost (RWF)</th>
                        <th>Description</th>
                        <th>Recorded At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${costs}" varStatus="loop">
                    <tr>
                        <td>${loop.index + 1}</td>
                        <td><strong><fmt:formatNumber value="${c.costAmount}" type="number" minFractionDigits="2"/></strong></td>
                        <td>${c.costDescription}</td>
                        <td>${c.recordedAt}</td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance-costs/edit/${c.costId}"
                                   class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></a>
                                <form action="${pageContext.request.contextPath}/maintenance-costs/delete/${c.costId}"
                                      method="post" class="m-0"
                                      onsubmit="return confirm('Delete this cost entry?');">
                                    <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty costs}">
                        <tr><td colspan="5" class="text-center text-muted">No cost entries for this maintenance record.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
