<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - User Activity Log</title>
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
                <h4 style="font-weight:700;margin:0;">Activity Log - ${user.fullName}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Role: ${user.role} | Username: ${user.username} | Last Login: ${user.lastLogin}</p>
            </div>
            <a href="${pageContext.request.contextPath}/users" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="table-container">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Action</th>
                        <th>Entity Type</th>
                        <th>Entity ID</th>
                        <th>Details</th>
                        <th>IP Address</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${logs}">
                    <tr>
                        <td>${log.timestamp}</td>
                        <td><span class="badge bg-primary">${log.action}</span></td>
                        <td>${log.entityType}</td>
                        <td>${log.entityId}</td>
                        <td style="max-width:300px;">${log.details}</td>
                        <td>${log.ipAddress}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty logs}">
                    <tr><td colspan="6" class="text-center text-muted py-4">No activity logs found for this user.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
