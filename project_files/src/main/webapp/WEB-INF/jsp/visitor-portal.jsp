<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Visitor Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="common/styles.jsp"/>
</head>
<body class="bg-light">
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="bi bi-lightning-charge-fill text-warning"></i> SPCMS Visitor Portal
            </a>
            <div class="d-flex align-items-center">
                <span class="text-light me-3">Welcome, ${currentUser.fullName}</span>
                <form action="${pageContext.request.contextPath}/logout" method="post" class="m-0">
                    <c:if test="${not empty _csrf}">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    </c:if>
                    <button class="btn btn-outline-light btn-sm"><i class="bi bi-box-arrow-right"></i> Logout</button>
                </form>
            </div>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-header bg-white border-0 pt-4 pb-0 text-center">
                        <h4 class="mb-0 text-primary"><i class="bi bi-calendar-event"></i> Request a Visit</h4>
                        <p class="text-muted mt-2">Fill out the form below to submit your visit request to our management team.</p>
                    </div>
                    <div class="card-body p-4">
                        <c:if test="${not empty success}">
                            <div class="alert alert-success"><i class="bi bi-check-circle-fill"></i> ${success}</div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/visitor-portal/request" method="post">
                            <c:if test="${not empty _csrf}">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            </c:if>

                            <input type="hidden" name="fullName" value="${visitor.fullName}">
                            
                            <div class="mb-3">
                                <label class="form-label text-muted">National ID / Passport</label>
                                <input type="text" name="nationalIdPassport" class="form-control" placeholder="ID Number" required>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label text-muted">Company / Organization</label>
                                    <input type="text" name="company" class="form-control" value="${visitor.company}">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label text-muted">Phone Number</label>
                                    <input type="text" name="phone" class="form-control" placeholder="+1...">
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-muted">Select Host (Staff to visit)</label>
                                <select name="hostEmployee.userId" class="form-select" required>
                                    <option value="">Choose...</option>
                                    <c:forEach var="staff" items="${staffList}">
                                        <option value="${staff.userId}">${staff.fullName} - ${staff.role}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label text-muted">Date of Visit</label>
                                    <input type="date" name="visitDate" class="form-control" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label text-muted">Equipment Carried (Optional)</label>
                                    <input type="text" name="equipmentCarried" class="form-control" placeholder="e.g. Laptop">
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label text-muted">Purpose of Visit</label>
                                <textarea name="purposeOfVisit" class="form-control" rows="3" required></textarea>
                            </div>

                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg"><i class="bi bi-send-fill"></i> Submit Request</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
