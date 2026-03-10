<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - UPS Systems</title>
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

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">UPS Systems</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Manage Uninterruptible Power Supply units</p>
            </div>
            <a href="${pageContext.request.contextPath}/ups/new" class="btn btn-primary"><i class="bi bi-plus-lg"></i> Add UPS</a>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Asset Tag</th>
                        <th>Name</th>
                        <th>Brand/Model</th>
                        <th>Capacity (kVA)</th>
                        <th>Load %</th>
                        <th>Status</th>
                        <th>Location</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="ups" items="${upsList}">
                    <tr>
                        <td><strong>${ups.assetTag}</strong></td>
                        <td>${ups.upsName}</td>
                        <td>${ups.brand} ${ups.model}</td>
                        <td>${ups.capacityKva}</td>
                        <td>
                            <div class="progress" style="height:20px;">
                                <div class="progress-bar ${ups.loadPercentage > 80 ? 'bg-danger' : ups.loadPercentage > 60 ? 'bg-warning' : 'bg-success'}" 
                                     style="width:${ups.loadPercentage != null ? ups.loadPercentage : 0}%">${ups.loadPercentage}%</div>
                            </div>
                        </td>
                        <td><span class="badge ${ups.status == 'ACTIVE' ? 'bg-success' : ups.status == 'FAULTY' ? 'bg-danger' : 'bg-warning'}">${ups.status}</span></td>
                        <td>${ups.locationRoom}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/ups/view/${ups.upsId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                            <a href="${pageContext.request.contextPath}/ups/edit/${ups.upsId}" class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></a>
                            <a href="${pageContext.request.contextPath}/ups/delete/${ups.upsId}" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this UPS?')"><i class="bi bi-trash"></i></a>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty upsList}">
                    <tr><td colspan="8" class="text-center text-muted py-4">No UPS systems registered yet. Click "Add UPS" to get started.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- Global Alert Notification System -->
    <jsp:include page="../common/alert-notifications.jsp"/>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
