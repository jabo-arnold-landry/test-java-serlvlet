<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - System Accounts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>

    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="container-fluid py-5">
            <c:if test="${not empty success}">
                <div class="alert alert-success border-0 shadow-sm rounded-4 p-4 mb-5 d-flex align-items-center">
                    <div class="p-2 bg-success bg-opacity-10 text-success rounded-circle me-3"><i class="bi bi-check-lg"></i></div>
                    <div>${success}</div>
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
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

            <div class="card border-0 shadow-sm rounded-5 overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="bg-light">
                                <th class="ps-4 py-4 text-uppercase small fw-black text-slate-400">Username/Profile</th>
                                <th class="py-4 text-uppercase small fw-black text-slate-400">Role & Dept</th>
                                <th class="py-4 text-uppercase small fw-black text-slate-400">Communication</th>
                                <th class="py-4 text-uppercase small fw-black text-slate-400">Status</th>
                                <th class="pe-4 py-4 text-end text-uppercase small fw-black text-slate-400">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${users}">
                                <tr>
                                    <td class="ps-4 py-4">
                                        <div class="fw-bold text-slate-900">${u.fullName}</div>
                                        <div class="small text-slate-400">@${u.username}</div>
                                    </td>
                                    <td class="py-4">
                                        <div class="badge bg-primary bg-opacity-10 text-primary rounded-pill px-3 py-1 mb-1">${u.role}</div>
                                        <div class="small text-slate-500">${u.department}</div>
                                    </td>
                                    <td class="py-4 small text-slate-600">
                                        <div><i class="bi bi-envelope me-2 text-slate-400"></i>${u.email}</div>
                                        <div><i class="bi bi-phone me-2 text-slate-400"></i>${u.phone}</div>
                                    </td>
                                    <td class="py-4">
                                        <span class="badge ${u.isActive ? 'bg-success' : 'bg-danger'} rounded-pill px-3 py-1 fw-bold">
                                            ${u.isActive ? 'ACTIVE' : 'DEACTIVATED'}
                                        </span>
                                    </td>
                                    <td class="pe-4 py-4 text-end">
                                        <a href="${pageContext.request.contextPath}/users/edit/${u.userId}" class="btn btn-light btn-sm rounded-3 me-1" title="Edit Profile">
                                            <i class="bi bi-pencil-square text-primary"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/users/activity/${u.userId}" class="btn btn-light btn-sm rounded-3 me-1" title="Access Logs">
                                            <i class="bi bi-shield-check text-info"></i>
                                        </a>
                                        <c:if test="${u.isActive}">
                                            <form action="${pageContext.request.contextPath}/users/deactivate/${u.userId}" method="post" style="display:inline;">
                                                <button type="submit" class="btn btn-light btn-sm rounded-3" onclick="return confirm('Immediately terminate access for this user?')" title="Deactivate">
                                                    <i class="bi bi-person-x text-danger"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <style>
        .fw-black { font-weight: 800; }
        .text-slate-900 { color: #0f172a; }
        .text-slate-400 { color: #94a3b8; }
        .text-slate-500 { color: #64748b; }
        .text-slate-600 { color: #475569; }
        .rounded-5 { border-radius: 1.5rem !important; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
