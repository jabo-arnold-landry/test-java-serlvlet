<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Monitoring Logs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">System Monitoring Logs</h4></div>
            <a href="${pageContext.request.contextPath}/monitoring/new" class="btn btn-primary"><i class="bi bi-plus-lg"></i> Record Manual Reading</a>
        </div>

        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <div class="table-container">
            <table class="table hover">
                <thead><tr><th>Timestamp</th><th>Type</th><th>Equipment ID</th><th>Key Readings</th><th>Notes</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="log" items="${readings}">
                    <tr>
                        <td>${log.readingTime}</td>
                        <td>
                            <span class="badge ${log.equipmentType == 'UPS' ? 'bg-info' : 'bg-success'}">${log.equipmentType}</span>
                        </td>
                        <td>${log.equipmentId}</td>
                        <td>
                            <c:if test="${log.equipmentType == 'UPS'}">
                                <c:if test="${log.loadPercentage != null}">Load: ${log.loadPercentage}%</c:if>
                                <c:if test="${log.temperature != null}"> | Temp: ${log.temperature}°C</c:if>
                                <c:if test="${log.inputVoltage != null}"> | In: ${log.inputVoltage}V</c:if>
                            </c:if>
                            <c:if test="${log.equipmentType == 'COOLING'}">
                                <c:if test="${log.returnAirTemp != null}">Return: ${log.returnAirTemp}°C</c:if>
                                <c:if test="${log.supplyAirTemp != null}"> | Supply: ${log.supplyAirTemp}°C</c:if>
                                <c:if test="${log.humidityPercent != null}"> | Humidity: ${log.humidityPercent}%</c:if>
                            </c:if>
                        </td>
                        <td>${log.notes != null ? log.notes : '-'}</td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <a href="${pageContext.request.contextPath}/monitoring/view/${log.logId}" class="btn btn-outline-info" title="View"><i class="bi bi-eye"></i></a>
                                <a href="${pageContext.request.contextPath}/monitoring/edit/${log.logId}" class="btn btn-outline-warning" title="Edit"><i class="bi bi-pencil"></i></a>
                                <a href="${pageContext.request.contextPath}/monitoring/delete/${log.logId}" class="btn btn-outline-danger" title="Delete" onclick="return confirm('Are you sure you want to delete this reading?')"><i class="bi bi-trash"></i></a>
                            </div>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <a href="${pageContext.request.contextPath}/monitoring/edit/${log.logId}" class="btn btn-outline-primary" title="Edit"><i class="bi bi-pencil"></i></a>
                                <a href="${pageContext.request.contextPath}/monitoring/delete/${log.logId}" class="btn btn-outline-danger" title="Delete" onclick="return confirm('Are you sure you want to delete this log?');"><i class="bi bi-trash"></i></a>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty readings}"><tr><td colspan="6" class="text-center text-muted">No monitoring logs recorded yet.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

