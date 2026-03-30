<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Alerts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
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
        <h4 style="font-weight:700;margin-bottom:20px;">System Alerts</h4>
        <div class="table-container">
            <table class="table table-hover">
                <thead><tr><th>Type</th><th>Message</th><th>Target</th><th>Sent?</th><th>Status</th><th>Action</th></tr></thead>
                <tbody>
                    <c:forEach var="a" items="${alerts}">
                    <tr class="${a.isAcknowledged ? '' : 'table-warning'}">
                        <td><strong>${a.alertType}</strong></td>
                        <td>${a.message}</td><td>${a.equipmentType} ID: ${a.equipmentId}</td>
                        <td>${a.isSent ? 'Yes' : 'No'}</td>
                        <td>
                            <span class="badge ${a.isAcknowledged ? 'bg-success' : 'bg-danger'}">
                                ${a.isAcknowledged ? 'Acked' : 'Pending'}
                            </span>
                        </td>
                        <td>
                            <c:if test="${!a.isAcknowledged}">
                                <form action="${pageContext.request.contextPath}/alerts/acknowledge/${a.alertId}" method="post" style="display:inline;">
                                    <button type="submit" class="btn btn-sm btn-success"><i class="bi bi-check2-all"></i> Ack</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty alerts}">
                    <tr><td colspan="6" class="text-center text-muted py-4">No alerts recorded.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
