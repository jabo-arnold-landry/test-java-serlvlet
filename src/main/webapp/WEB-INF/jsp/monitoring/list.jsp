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
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Type</th>
                        <th>Equipment ID</th>
                        <th>UPS Load/Temp</th>
                        <th>Battery</th>
                        <th>Cooling Return/Humidity</th>
                        <th>Logged By</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${readings}">
                        <tr>
                            <td>${log.readingTime}</td>
                            <td>${log.equipmentType}</td>
                            <td>${log.equipmentId}</td>
                            <td>
                                <c:if test="${log.equipmentType == 'UPS'}">
                                    ${log.loadPercentage}% / ${log.temperature}°C
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${log.equipmentType == 'UPS'}">
                                    ${log.batteryStatus}
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${log.equipmentType == 'COOLING'}">
                                    ${log.returnAirTemp}°C / ${log.humidityPercent}%
                                </c:if>
                            </td>
                            <td>${log.recordedBy != null ? log.recordedBy.fullName : 'N/A'}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty readings}">
                        <tr><td colspan="7" class="text-center text-muted">No monitoring logs recorded yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
