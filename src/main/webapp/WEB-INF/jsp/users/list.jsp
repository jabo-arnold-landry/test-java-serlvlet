<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Users</title>
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
            <div><h4 style="font-weight:700;margin:0;">User Management</h4></div>
            <a href="${pageContext.request.contextPath}/users/new" class="btn btn-primary"><i class="bi bi-person-plus"></i> New User</a>
        </div>
        <div class="table-container">
            <table class="table">
                <thead><tr><th>Username</th><th>Full Name</th><th>Email</th><th>Role</th><th>Dept</th><th>Status</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="u" items="${users}">
                    <tr>
                        <td><strong>${u.username}</strong></td><td>${u.fullName}</td><td>${u.email}</td>
                        <td><span class="badge bg-secondary">${u.role}</span></td><td>${u.department}</td>
                        <td><span class="badge ${u.isActive ? 'bg-success' : 'bg-danger'}">${u.isActive ? 'Active' : 'Inactive'}</span></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/users/edit/${u.userId}" class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></a>
                            <a href="${pageContext.request.contextPath}/users/activity/${u.userId}" class="btn btn-sm btn-outline-info"><i class="bi bi-clock-history"></i></a>
                            <c:if test="${u.isActive}">
                                <form action="${pageContext.request.contextPath}/users/deactivate/${u.userId}" method="post" style="display:inline;">
                                    <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to deactivate this user?')"><i class="bi bi-person-x"></i></button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
