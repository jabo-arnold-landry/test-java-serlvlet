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
                <thead><tr><th>Timestamp</th><th>Device</th><th>Load/Temp</th><th>Battery</th><th>Alarm</th><th>Logged By</th></tr></thead>
                <tbody>
                    <c:forEach var="log" items="${logs}">
                    <tr class="${log.isAlarmTriggered ? 'table-danger' : ''}">
                        <td>${log.timestamp}</td>
                        <td>
                            <c:if test="${log.ups != null}"><strong>UPS:</strong> ${log.ups.assetTag}</c:if>
                            <c:if test="${log.coolingUnit != null}"><strong>Cooling:</strong> ${log.coolingUnit.assetTag}</c:if>
                        </td>
                        <td>
                            <c:if test="${log.ups != null}">${log.upsLoadPercentage}% / ${log.roomTemperature}°C</c:if>
                            <c:if test="${log.coolingUnit != null}">Return: ${log.coolingReturnTemp}°C</c:if>
                        </td>
                        <td>${log.batteryVoltage != null ? log.batteryVoltage.toString().concat('V') : '-'}</td>
                        <td>
                            <c:if test="${log.isAlarmTriggered}">
                                <span class="badge bg-danger"><i class="bi bi-exclamation-triangle"></i> ALERT</span>
                            </c:if>
                        </td>
                        <td>${log.loggedBy}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty logs}"><tr><td colspan="6" class="text-center text-muted">No monitoring logs recorded yet.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- Global Alert Notification System -->
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
