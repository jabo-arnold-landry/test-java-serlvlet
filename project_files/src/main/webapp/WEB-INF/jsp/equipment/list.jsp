<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Equipment</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Equipment Inventory</h4></div>
            <a href="${pageContext.request.contextPath}/equipment/new" class="btn btn-primary"><i class="bi bi-plus-lg"></i> Add Equipment</a>
        </div>
        <div class="table-container">
            <table class="table table-hover">
                <thead><tr><th>Asset Tag</th><th>Name</th><th>Type</th><th>Location</th><th>IP Address</th><th>Status</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="item" items="${equipmentList}">
                    <tr>
                        <td><strong>${item.assetTagNumber}</strong></td>
                        <td>${item.equipmentName}</td><td>${item.equipmentType}</td>
                        <td>${item.dataCenterName} / Rack ${item.rackNumber}</td>
                        <td>${item.ipAddress}</td>
                        <td><span class="badge ${item.maintenanceStatus == 'ACTIVE' ? 'bg-success' : 'bg-warning'}">${item.maintenanceStatus}</span></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/equipment/view/${item.equipmentId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                            <a href="${pageContext.request.contextPath}/equipment/edit/${item.equipmentId}" class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></a>
                            <a href="${pageContext.request.contextPath}/equipment/delete/${item.equipmentId}" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this equipment?')"><i class="bi bi-trash"></i></a>
                        </td>
                    </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
