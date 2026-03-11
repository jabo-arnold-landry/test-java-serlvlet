<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Visitor Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Visitor Management System</h4></div>
            <a href="${pageContext.request.contextPath}/visitors/register" class="btn btn-primary"><i class="bi bi-person-plus"></i> Register Visitor</a>
        </div>
        
        <ul class="nav nav-tabs mb-4" id="visitorTabs" role="tablist">
            <li class="nav-item" role="presentation"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#active">Active Visitors</button></li>
            <li class="nav-item" role="presentation"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#pending">Pending Approvals</button></li>
        </ul>

        <div class="tab-content">
            <div class="tab-pane fade show active" id="active">
                <div class="table-container">
                    <table class="table">
                        <thead><tr><th>Pass #</th><th>Name</th><th>Company</th><th>Host</th><th>Check In</th><th>Action</th></tr></thead>
                        <tbody>
                            <c:forEach var="v" items="${activeVisitors}">
                            <tr>
                                <td><span class="badge bg-secondary">${v.visitor.passNumber}</span></td>
                                <td><strong>${v.visitor.fullName}</strong></td><td>${v.visitor.company}</td>
                                <td>${v.visitor.hostEmployee.fullName}</td>
                                <td>${v.checkInTime}</td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/visitors/checkout/${v.checkId}" method="post">
                                        <input type="hidden" name="equipmentConfirmed" value="true">
                                        <button type="submit" class="btn btn-sm btn-danger">Check Out</button>
                                    </form>
                                </td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="tab-pane fade" id="pending">
                <div class="table-container">
                    <table class="table">
                        <thead><tr><th>Name</th><th>Purpose</th><th>Host</th><th>Action</th></tr></thead>
                        <tbody>
                            <c:forEach var="a" items="${pendingApprovals}">
                            <tr>
                                <td>${a.visitor.fullName}</td><td>${a.visitor.purposeOfVisit}</td>
                                <td>${a.visitor.hostEmployee.fullName}</td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/visitors/approve/${a.approvalId}" method="post" class="d-inline align-items-center">
                                        <input type="hidden" name="managerId" value="1">
                                        <input type="number" name="durationHours" value="1" min="1" class="form-control form-control-sm d-inline" style="width: 70px;" title="Approved Duration (Hours)">
                                        <button class="btn btn-sm btn-success">Approve</button>
                                    </form>
                                </td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
