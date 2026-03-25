<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Support</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/visitor-header.jsp"/>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="support" />
    </jsp:include>

    <div class="vp-content-area d-flex align-items-center justify-content-center">
        <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
        
        <div class="col-lg-6 col-md-8">
            <c:choose>
                <c:when test="${isTech}">
                    <!-- Technician Incident Reporting Form -->
                    <div class="card border-0 shadow-lg rounded-5 overflow-hidden">
                        <div class="card-body p-5">
                            <div class="text-center mb-4">
                                <div class="bg-danger bg-opacity-10 text-danger p-4 rounded-circle d-inline-block mb-3">
                                    <i class="bi bi-exclamation-triangle fs-1"></i>
                                </div>
                                <h2 class="fw-bold mb-1">Report Incident</h2>
                                <p class="text-muted small">Submit a security or operational report</p>
                            </div>

                            <form action="${pageContext.request.contextPath}/visitor-portal/incident" method="post" class="needs-validation">
                                <c:if test="${not empty _csrf}">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                </c:if>

                                <div class="mb-4">
                                    <label class="form-label fw-bold small text-muted text-uppercase" style="letter-spacing:1px;">Incident Type</label>
                                    <select name="type" class="form-select bg-light border-0 py-3 rounded-3 shadow-none" required>
                                        <option value="">Select Incident Type...</option>
                                        <option value="Visitor Overstayed">Visitor Overstayed</option>
                                        <option value="Unauthorized Access">Unauthorized Access</option>
                                        <option value="Restricted Area Entry">Restricted Area Entry</option>
                                        <option value="Equipment Misuse">Equipment Misuse</option>
                                        <option value="Other Safety Issue">Other Safety Issue</option>
                                    </select>
                                </div>

                                <div class="mb-5">
                                    <label class="form-label fw-bold small text-muted text-uppercase" style="letter-spacing:1px;">Report Description</label>
                                    <textarea name="description" class="form-control bg-light border-0 py-3 rounded-3 shadow-none" rows="4" placeholder="Describe what happened, including visitor names and locations..." required></textarea>
                                </div>

                                <button type="submit" class="btn btn-danger btn-lg shadow-sm w-100 rounded-pill py-3 fw-bold transition-all hover-lift">
                                    <i class="bi bi-shield-fill-exclamation me-2"></i> Submit Incident Report
                                </button>
                                <p class="text-center mt-3 mb-0 small text-muted">This report will be sent to Manager and Admin.</p>
                            </form>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Standard Support Info -->
                    <div class="card border-0 shadow-lg rounded-5 overflow-hidden">
                        <div class="card-body p-5 text-center">
                            <div class="bg-primary bg-opacity-10 text-primary p-4 rounded-circle d-inline-block mb-4">
                                <i class="bi bi-headset fs-1"></i>
                            </div>
                            <h2 class="fw-bold mb-3">Help &amp; Support</h2>
                            <p class="text-muted mb-5 px-4">Need help with your visit request or portal access? Our system administrators are available to assist you.</p>
                            
                            <div class="d-flex flex-column gap-3 mb-5">
                                <div class="d-flex align-items-center justify-content-center gap-3 p-3 rounded-4 bg-light">
                                    <i class="bi bi-envelope-at text-primary fs-4"></i>
                                    <div class="text-start">
                                        <div class="small text-muted mb-0">Email Us</div>
                                        <div class="fw-bold">support@spcms.iot</div>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center justify-content-center gap-3 p-3 rounded-4 bg-light">
                                    <i class="bi bi-telephone text-primary fs-4"></i>
                                    <div class="text-start">
                                        <div class="small text-muted mb-0">Call Support</div>
                                        <div class="fw-bold">+250 123 456 789</div>
                                    </div>
                                </div>
                            </div>
                            
                            <a href="mailto:support@spcms.iot" class="btn btn-primary btn-lg shadow-sm w-100 rounded-pill py-3 fw-bold">
                                <i class="bi bi-envelope-fill me-2"></i> Contact Administrator
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <style>
        .transition-all { transition: all 0.3s ease; }
        .hover-lift:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1) !important; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
