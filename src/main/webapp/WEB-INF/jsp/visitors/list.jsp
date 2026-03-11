<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
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
            <sec:authorize access="hasAnyRole('TECHNICIAN', 'ADMIN')">
                <a href="${pageContext.request.contextPath}/visitors/register" class="btn btn-primary"><i class="bi bi-person-plus"></i> Register Visitor</a>
            </sec:authorize>
        </div>
        
        <ul class="nav nav-tabs mb-4" id="visitorTabs" role="tablist">
            <sec:authorize access="hasAnyRole('TECHNICIAN', 'ADMIN')">
                <li class="nav-item" role="presentation"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#checkin">Check In</button></li>
                <li class="nav-item" role="presentation"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#active">Active Visitors</button></li>
            </sec:authorize>
            <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
                <li class="nav-item" role="presentation"><button class="nav-link <sec:authorize access="!hasRole('ADMIN')">active</sec:authorize>" data-bs-toggle="tab" data-bs-target="#pending">Pending Approvals</button></li>
            </sec:authorize>
        </ul>

        <div class="tab-content">
            <sec:authorize access="hasAnyRole('TECHNICIAN', 'ADMIN')">
                <div class="tab-pane fade" id="checkin">
                    <div class="table-container">
                        <table class="table">
                            <thead><tr><th>Pass #</th><th>Name</th><th>Purpose</th><th>Duration</th><th>Action</th></tr></thead>
                            <tbody>
                                <c:forEach var="a" items="${waitingForCheckIn}">
                                <tr>
                                    <td><span class="badge bg-secondary">${a.visitor.passNumber}</span></td>
                                    <td><strong>${a.visitor.fullName}</strong></td>
                                    <td>${a.visitor.purposeOfVisit}</td>
                                    <td>${a.approvedDurationHours} Hours</td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/visitors/checkin" method="post" class="d-flex gap-2">
                                            <input type="hidden" name="visitorId" value="${a.visitor.visitorId}">
                                            <input type="text" name="badge" class="form-control form-control-sm" placeholder="Temporary Badge" required>
                                            <select name="escortId" class="form-select form-select-sm" required>
                                                <option value="">Select Escort...</option>
                                                <c:forEach var="staff" items="${staffList}">
                                                    <option value="${staff.userId}">${staff.fullName} (${staff.role})</option>
                                                </c:forEach>
                                            </select>
                                            <button type="submit" class="btn btn-sm btn-success text-nowrap">Check In</button>
                                        </form>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty waitingForCheckIn}">
                                    <tr><td colspan="5" class="text-center text-muted">No visitors approved and waiting for check-in.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

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
            </sec:authorize>
            
            <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
                <div class="tab-pane fade <sec:authorize access="!hasRole('ADMIN')">show active</sec:authorize>" id="pending">
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
            </sec:authorize>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Ensure at least one tab is explicitly marked active based on rendering order
        document.addEventListener('DOMContentLoaded', function() {
            var activeNavs = document.querySelectorAll('.nav-link.active');
            if (activeNavs.length > 1) { // If Admin has both, prioritize active visitors
                activeNavs[1].classList.remove('active');
                document.getElementById('pending').classList.remove('show', 'active');
            } else if (activeNavs.length === 0) { // Fallback
                var firstBtn = document.querySelector('.nav-link');
                if(firstBtn) {
                    firstBtn.classList.add('active');
                    document.querySelector(firstBtn.getAttribute('data-bs-target')).classList.add('show', 'active');
                }
            }
        });
    </script>
</body>
</html>
