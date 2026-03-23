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
        
        <div class="table-container">
            <table class="table hover">
                <thead><tr><th>Timestamp</th><th>Device</th><th>Voltage</th><th>Load/Temp</th><th>Humidity</th><th>Battery Status</th><th>Logged By</th></tr></thead>
                <tbody>
                    <c:forEach var="log" items="${readings}">
                    <tr class="${log.equipmentType == 'COOLING' && log.humidityPercent > 65 ? 'table-danger' : ''}">
                        <td>${log.readingTime}</td>
                        <td>
                            <strong>${log.equipmentType}:</strong> ${log.equipmentId}
                        </td>
                        <td>
                            <c:if test="${log.equipmentType == 'UPS'}">${log.loadPercentage}% / ${log.temperature}°C</c:if>
                            <c:if test="${log.equipmentType == 'COOLING'}">Return: ${log.returnAirTemp}°C</c:if>
                        </td>
                        <td>
                            <c:if test="${log.equipmentType == 'UPS'}">${log.batteryStatus} / ${log.runtimeRemaining}m</c:if>
                            <c:if test="${log.equipmentType == 'COOLING'}">-</c:if>
                        </td>
                        <td>
                            <c:if test="${log.recordedBy != null}">
                                ${log.recordedBy.username}
                            </c:if>
                            <c:if test="${log.recordedBy == null}">
                                -
                            </c:if>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <a href="${pageContext.request.contextPath}/monitoring/edit/${log.logId}" class="btn btn-outline-primary" title="Edit"><i class="bi bi-pencil"></i></a>
                                <a href="${pageContext.request.contextPath}/monitoring/delete/${log.logId}" class="btn btn-outline-danger" title="Delete" onclick="return confirm('Are you sure you want to delete this log?');"><i class="bi bi-trash"></i></a>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty logs}"><tr><td colspan="7" class="text-center text-muted">No monitoring logs recorded yet. Use "Record Manual Reading" to add data.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
