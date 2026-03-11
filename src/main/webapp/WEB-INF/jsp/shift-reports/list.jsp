<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Shift Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Shift Handover Reports</h4></div>
            <a href="${pageContext.request.contextPath}/shift-reports/new" class="btn btn-primary"><i class="bi bi-journal-text"></i> Start New Shift</a>
        </div>
        
        <div class="table-container">
            <table class="table shadow-sm">
                <thead class="bg-light"><tr><th>Date</th><th>Shift</th><th>Engineer</th><th>Status</th><th>Events</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="s" items="${shifts}">
                    <tr>
                        <td><strong>${s.shiftDate}</strong></td>
                        <td><span class="badge bg-secondary">${s.shiftIdentifier}</span></td>
                        <td>${s.engineer.fullName}</td>
                        <td><span class="badge ${s.status == 'OPEN' ? 'bg-success' : 'bg-dark'}">${s.status}</span></td>
                        <td><small>${s.majorEvents != null ? s.majorEvents : 'No major events'}</small></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/shift-reports/view/${s.reportId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                            <c:if test="${s.status == 'OPEN'}">
                            <form action="${pageContext.request.contextPath}/shift-reports/close/${s.reportId}" method="post" class="d-inline">
                                <button type="submit" class="btn btn-sm btn-danger"><i class="bi bi-lock-fill"></i> Close Shift</button>
                            </form>
                            </c:if>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty shifts}"><tr><td colspan="6" class="text-center text-muted">No shift reports found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
