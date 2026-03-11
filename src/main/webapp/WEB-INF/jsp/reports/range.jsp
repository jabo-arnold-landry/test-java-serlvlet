<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Reports Range</title>
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
                <h4 style="font-weight:700;margin:0;">Daily Consolidated Reports</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Date range report view with MTTR/MTBF calculations</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Avg Load %</th>
                        <th>Avg Temp</th>
                        <th>Highest Temp</th>
                        <th>Incidents</th>
                        <th>Downtime (min)</th>
                        <th>MTTR (min)</th>
                        <th>MTBF (hrs)</th>
                        <th>Visitors</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${reports}">
                    <tr>
                        <td><strong>${r.reportDate}</strong></td>
                        <td>${r.avgDailyLoad}</td>
                        <td>${r.avgRoomTemperature}&deg;C</td>
                        <td style="color:${r.highestTempRecorded > 28 ? 'var(--accent-red)' : 'inherit'}">${r.highestTempRecorded}&deg;C</td>
                        <td>${r.totalIncidents}</td>
                        <td>${r.totalDowntimeMin}</td>
                        <td>${r.mttrMinutes}</td>
                        <td>${r.mtbfHours}</td>
                        <td>${r.totalVisitors}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty reports}">
                    <tr><td colspan="9" class="text-center text-muted py-4">No reports found for this date range.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
