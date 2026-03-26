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
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Shift Handover Reports</h4></div>
            <a href="${pageContext.request.contextPath}/shift-reports/new" class="btn btn-primary"><i class="bi bi-journal-text"></i> Start New Shift</a>
        </div>
        
        <div class="table-container">
            <table class="table shadow-sm">
                <thead class="bg-light"><tr><th>Date</th><th>Shift</th><th>Engineer</th><th>Status</th><th>Events</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="r" items="${reports}">
                    <tr>
                        <td><strong>${r.shiftDate}</strong></td>
                        <td><span class="badge bg-secondary">${r.shiftType}</span></td>
                        <td>${r.staff.userId} - ${r.staff.fullName}</td>
                        <td><span class="badge ${empty r.logoutTime ? 'bg-success' : 'bg-dark'}">${empty r.logoutTime ? 'OPEN' : 'CLOSED'}</span></td>
                        <td><small>Incidents: ${empty r.numIncidents ? 0 : r.numIncidents} (${empty r.criticalIncidents ? 0 : r.criticalIncidents} critical), Downtime: ${empty r.downtimeDurationMin ? 0 : r.downtimeDurationMin} min</small></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/shift-reports/view/${r.reportId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                            <c:if test="${empty r.logoutTime}">
                            <form action="${pageContext.request.contextPath}/shift-reports/close/${r.reportId}" method="post" class="d-inline">
                                <button type="submit" class="btn btn-sm btn-danger"><i class="bi bi-lock-fill"></i> Close Shift</button>
                            </form>
                            </c:if>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty reports}"><tr><td colspan="6" class="text-center text-muted">No shift reports found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
