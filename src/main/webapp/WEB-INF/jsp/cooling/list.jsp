<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Cooling Units</title>
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
                <h4 style="font-weight:700;margin:0;">Cooling Units</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Manage precision cooling and air conditioning</p>
            </div>
            <a href="${pageContext.request.contextPath}/cooling/new" class="btn btn-primary"><i class="bi bi-plus-lg"></i> Add Cooling Unit</a>
        </div>

        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Asset Tag</th>
                        <th>Name</th>
                        <th>Zone</th>
                        <th>Return Temp</th>
                        <th>Status</th>
                        <th>Compressor</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="unit" items="${coolingList}">
                    <tr>
                        <td><strong>${unit.assetTag}</strong></td>
                        <td>${unit.unitName}</td>
                        <td>${unit.locationZone}</td>
                        <td>
                            <c:choose>
                                <c:when test="${unit.returnAirTemp > 25}">
                                    <span class="text-danger fw-bold"><i class="bi bi-thermometer-high"></i> ${unit.returnAirTemp}°C</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-success"><i class="bi bi-thermometer-half"></i> ${unit.returnAirTemp}°C</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><span class="badge ${unit.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'}">${unit.status}</span></td>
                        <td><span class="badge ${unit.compressorStatus == 'RUNNING' ? 'bg-info' : 'bg-secondary'}">${unit.compressorStatus}</span></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/cooling/view/${unit.coolingId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                            <a href="${pageContext.request.contextPath}/cooling/edit/${unit.coolingId}" class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></a>
                            <a href="${pageContext.request.contextPath}/cooling/delete/${unit.coolingId}" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this cooling unit?')"><i class="bi bi-trash"></i></a>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty coolingList}">
                    <tr><td colspan="7" class="text-center text-muted py-4">No cooling units recorded.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
