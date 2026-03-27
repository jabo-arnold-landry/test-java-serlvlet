<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - User Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .fw-black { font-weight: 800; }
        .text-slate-900 { color: #0f172a; }
        .text-slate-400 { color: #94a3b8; }
        .text-slate-500 { color: #64748b; }
        .text-slate-600 { color: #475569; }
        .rounded-5 { border-radius: 1.5rem !important; }
        .badge-role { font-size: 0.75rem; padding: 0.35em 0.75em; }
    </style>
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
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="d-flex align-items-center justify-content-between mb-5">
            <div>
                <h2 class="fw-black text-slate-900 mb-1">System Account Management</h2>
                <p class="text-slate-500 mb-0">Authorized personnel access and role governance</p>
            </div>
            <a href="${pageContext.request.contextPath}/users/new" class="btn btn-primary px-4 py-3 rounded-4 fw-black shadow-lg">
                <i class="bi bi-person-plus-fill me-2"></i>Provision New Account
            </a>
        </div>

        <div class="table-container">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Role & Department</th>
                        <th>Contact</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>
                                <div class="fw-bold">${u.fullName}</div>
                                <div class="small text-muted">@${u.username}</div>
                            </td>
                            <td>
                                <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill badge-role mb-1">${u.role}</span>
                                <div class="small text-muted">${u.department}</div>
                            </td>
                            <td class="small">
                                <div><i class="bi bi-envelope me-1 text-muted"></i>${u.email}</div>
                                <div><i class="bi bi-phone me-1 text-muted"></i>${u.phone}</div>
                            </td>
                            <td>
                                <span class="badge ${u.isActive ? 'bg-success' : 'bg-danger'} rounded-pill">
                                    ${u.isActive ? 'Active' : 'Deactivated'}
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="${pageContext.request.contextPath}/users/edit/${u.userId}" class="btn btn-light btn-sm" title="Edit">
                                    <i class="bi bi-pencil-square text-primary"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/users/activity/${u.userId}" class="btn btn-light btn-sm" title="Activity Log">
                                    <i class="bi bi-shield-check text-info"></i>
                                </a>
                                <c:if test="${u.isActive}">
                                    <form action="${pageContext.request.contextPath}/users/deactivate/${u.userId}" method="post" style="display:inline;">
                                        <button type="submit" class="btn btn-light btn-sm" onclick="return confirm('Deactivate this user?')" title="Deactivate">
                                            <i class="bi bi-person-x text-warning"></i>
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${!u.isActive}">
                                    <form action="${pageContext.request.contextPath}/users/reactivate/${u.userId}" method="post" style="display:inline;">
                                        <button type="submit" class="btn btn-light btn-sm" onclick="return confirm('Reactivate this user?')" title="Reactivate">
                                            <i class="bi bi-person-check text-success"></i>
                                        </button>
                                    </form>
                                </c:if>
                                <form action="${pageContext.request.contextPath}/users/delete/${u.userId}" method="post" style="display:inline;">
                                    <button type="submit" class="btn btn-light btn-sm" onclick="return confirm('Permanently delete this user? This cannot be undone.')" title="Delete">
                                        <i class="bi bi-trash text-danger"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty users}">
                        <tr><td colspan="5" class="text-center text-muted py-4">No users found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>