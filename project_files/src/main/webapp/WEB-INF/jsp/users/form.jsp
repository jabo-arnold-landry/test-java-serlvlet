<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${user.userId != null ? 'Edit User' : 'New User'}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .fw-black { font-weight: 800; }
        .rounded-5 { border-radius: 1.5rem !important; }
        .form-control, .form-select { border: 1px solid #e2e8f0; padding: 0.8rem 1rem; border-radius: 0.75rem; background: #f8fafc; }
        .form-control:focus, .form-select:focus { background: #fff; border-color: #3b82f6; box-shadow: 0 0 0 4px rgba(59,130,246,0.1); }
    </style>
</head>
<body>

    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="container py-4">
            <div class="d-flex align-items-center justify-content-between mb-4">
                <div>
                    <h2 class="fw-black text-dark mb-1">${user.userId != null ? 'Edit Profile' : 'Provision Account'}</h2>
                    <p class="text-muted mb-0">Define credentials and role-based permissions</p>
                </div>
                <a href="${pageContext.request.contextPath}/users" class="btn btn-light rounded-pill px-4">
                    <i class="bi bi-arrow-left me-2"></i>Back to Directory
                </a>
            </div>

        <div class="card border-0 shadow-sm" style="border-radius:12px;">
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/users/save" method="post">
                    <c:if test="${user.userId != null}">
                        <input type="hidden" name="userId" value="${user.userId}"/>
                    </c:if>

                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Username</label>
                            <input type="text" class="form-control" name="username" value="${user.username}" required placeholder="e.g. jsmith">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Password</label>
                            <input type="password" class="form-control" name="password" value="${user.password}" required placeholder="Enter password">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Full Name</label>
                            <input type="text" class="form-control" name="fullName" value="${user.fullName}" required placeholder="e.g. John Smith">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email</label>
                            <input type="email" class="form-control" name="email" value="${user.email}" required placeholder="jsmith@company.com">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Role</label>
                            <select class="form-select" name="role" required>
                                <c:forEach var="r" items="${roles}">
                                    <option value="${r}" ${user.role == r ? 'selected' : ''}>${r}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Department</label>
                            <input type="text" class="form-control" name="department" value="${user.department}" placeholder="e.g. Operations">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Branch</label>
                            <input type="text" class="form-control" name="branch" value="${user.branch}" placeholder="e.g. Main Data Center">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Phone</label>
                            <input type="text" class="form-control" name="phone" value="${user.phone}" placeholder="e.g. +27 123 456 7890">
                        </div>
                    </div>

                    <div class="d-flex align-items-center justify-content-between pt-3 border-top">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" role="switch" id="isActiveSwitch" name="isActive" value="true" ${user.userId == null || user.isActive ? 'checked' : ''}>
                            <label class="form-check-label fw-bold ms-2" for="isActiveSwitch">Account Active</label>
                        </div>
                        <button type="submit" class="btn btn-primary px-4">
                            <i class="bi bi-check-lg me-1"></i> ${user.userId != null ? 'Save Changes' : 'Create User'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>