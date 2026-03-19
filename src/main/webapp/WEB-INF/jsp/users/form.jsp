<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Account Provisioning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/visitor-header.jsp"/>
    <style>
        .fw-black { font-weight: 800; }
        .rounded-5 { border-radius: 1.5rem !important; }
        .form-control, .form-select { border: 1px solid #e2e8f0; padding: 0.8rem 1rem; border-radius: 0.75rem; background: #f8fafc; }
        .form-control:focus, .form-select:focus { background: #fff; border-color: #3b82f6; box-shadow: 0 0 0 4px rgba(59,130,246,0.1); }
    </style>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="support" />
    </jsp:include>

    <div class="vp-content-area" style="background: #f1f5f9; min-height: 100vh;">
        <div class="container py-5">
            <div class="d-flex align-items-center justify-content-between mb-5">
                <div>
                    <h2 class="fw-black text-dark mb-1">${user.userId != null ? 'Edit Profile' : 'Provision Account'}</h2>
                    <p class="text-muted mb-0">Define credentials and role-based permissions</p>
                </div>
                <a href="${pageContext.request.contextPath}/users" class="btn btn-light rounded-pill px-4">
                    <i class="bi bi-arrow-left me-2"></i>Back to Directory
                </a>
            </div>

            <div class="card border-0 shadow-lg rounded-5 p-5 bg-white">
                <form action="${pageContext.request.contextPath}/users/save" method="post">
                    <c:if test="${user.userId != null}">
                        <input type="hidden" name="userId" value="${user.userId}"/>
                    </c:if>
                    
                    <div class="row g-4 mb-5">
                        <div class="col-md-6">
                            <label class="form-label small fw-black text-muted text-uppercase">Username</label>
                            <input type="text" class="form-control" name="username" value="${user.username}" required placeholder="e.g. jsmith">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-black text-muted text-uppercase">Security Password</label>
                            <input type="password" class="form-control" name="password" value="${user.password}" required placeholder="••••••••">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-black text-muted text-uppercase">Full Professional Name</label>
                            <input type="text" class="form-control" name="fullName" value="${user.fullName}" required placeholder="e.g. John Smith">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-black text-muted text-uppercase">Corporate Email</label>
                            <input type="email" class="form-control" name="email" value="${user.email}" required placeholder="jsmith@spcms.iot">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-black text-muted text-uppercase">Assigned Role</label>
                            <select class="form-select" name="role" required>
                                <c:forEach var="r" items="${roles}">
                                    <option value="${r}" ${user.role == r ? 'selected' : ''}>${r}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-black text-muted text-uppercase">Department</label>
                            <input type="text" class="form-control" name="department" value="${user.department}" placeholder="e.g. Operations">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-black text-muted text-uppercase">Branch/Sector</label>
                            <input type="text" class="form-control" name="branch" value="${user.branch}" placeholder="e.g. HQ-Delta">
                        </div>
                    </div>

                    <div class="d-flex align-items-center justify-content-between pt-4 border-top">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" role="switch" id="isActiveSwitch" name="isActive" value="true" ${user.userId == null || user.isActive ? 'checked' : ''}>
                            <label class="form-check-label fw-bold ms-2" for="isActiveSwitch">ACCOUNT ACTIVE</label>
                        </div>
                        <button type="submit" class="btn btn-primary px-5 py-3 rounded-4 fw-black shadow-lg">
                            <i class="bi bi-shield-check me-2"></i> ${user.userId != null ? 'SAVE CHANGES' : 'AUTHORIZE ACCOUNT'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
