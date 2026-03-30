<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Incidents</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Incident Logger</h4></div>
            <a href="${pageContext.request.contextPath}/incidents/new" class="btn btn-danger"><i class="bi bi-plus-lg"></i> Report Incident</a>
        </div>
        <div class="table-container">
            <table class="table table-hover">
                <thead><tr><th>ID</th><th>Title</th><th>Type</th><th>Severity</th><th>Status</th><th>Downtime (min)</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="inc" items="${incidents}">
                    <tr>
                        <td>#INC-${inc.incidentId}</td>
                        <td>${inc.title}</td><td>${inc.equipmentType}</td>
                        <td><span class="badge ${inc.severity == 'CRITICAL' ? 'bg-danger' : inc.severity == 'HIGH' ? 'bg-warning text-dark' : 'bg-secondary'}">${inc.severity}</span></td>
                        <td><span class="badge ${inc.status == 'OPEN' ? 'bg-danger' : inc.status == 'RESOLVED' ? 'bg-success' : 'bg-primary'}">${inc.status}</span></td>
                        <td>${inc.downtimeMinutes != null ? inc.downtimeMinutes : '-'}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/incidents/view/${inc.incidentId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i> View</a>
                        </td>
                    </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
