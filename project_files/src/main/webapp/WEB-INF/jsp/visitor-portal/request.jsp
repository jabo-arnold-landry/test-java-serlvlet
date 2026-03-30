<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Request Visit</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>

    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="container-fluid py-5">
            <jsp:include page="../common/visitor-nav.jsp">
                <jsp:param name="pageName" value="request" />
            </jsp:include>
            <div class="row justify-content-center">
                <div class="col-xl-10">
                    <!-- Page Header -->
                    <div class="d-flex align-items-center justify-content-between mb-5">
                        <div>
                            <h2 class="fw-black text-slate-900 mb-1" style="color: #0f172a;">Visitor Registration</h2>
                            <p class="text-slate-500 mb-0">Secure facility access protocol and visitor documentation</p>
                        </div>
                        <div class="d-none d-md-block">
                            <span class="badge bg-white text-primary border border-primary border-opacity-10 px-4 py-3 rounded-4 shadow-sm">
                                <i class="bi bi-shield-lock-fill me-2"></i>Secure Submission
                            </span>
                        </div>
                    </div>

                    <c:if test="${not empty success}">
                        <div class="alert alert-success border-0 shadow-lg rounded-4 p-4 mb-5 d-flex align-items-center">
                            <div class="p-3 bg-success bg-opacity-20 rounded-circle me-4">
                                <i class="bi bi-check-lg fs-4 text-success"></i>
                            </div>
                            <div>
                                <h5 class="alert-heading fw-bold mb-1">Registration Successful</h5>
                                <p class="mb-0 small">${success}</p>
                            </div>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/visitor-portal/request" method="post" class="needs-validation" novalidate>
                        <c:if test="${not empty _csrf}">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        </c:if>

                        <div class="row g-5">
                            <!-- Left Column -->
                            <div class="col-lg-8">
                                <!-- Section 1: Principal Details -->
                                <div class="card border-0 shadow-sm rounded-5 mb-5 overflow-hidden">
                                    <div class="card-header bg-white p-4 border-0 border-bottom border-light">
                                        <div class="d-flex align-items-center">
                                            <div class="bg-primary bg-opacity-10 p-2 rounded-3 text-primary me-3">
                                                <i class="bi bi-person-badge-fill fs-5"></i>
                                            </div>
                                            <h5 class="fw-bold mb-0 text-slate-800">Identity & Credentials</h5>
                                        </div>
                                    </div>
                                    <div class="card-body p-4 p-md-5">
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Subject Full Name</label>
                                                <div class="input-group input-group-lg border rounded-4 overflow-hidden bg-white focus-within-ring transition-300">
                                                    <span class="input-group-text bg-white border-0 ps-4"><i class="bi bi-person text-slate-400"></i></span>
                                                    <input type="text" name="fullName" class="form-control border-0 bg-white fs-6 py-3" placeholder="Legal Name" required>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Identification #</label>
                                                <div class="input-group border rounded-4 overflow-hidden bg-white focus-within-ring transition-300">
                                                    <span class="input-group-text bg-white border-0 ps-3"><i class="bi bi-card-text text-slate-400"></i></span>
                                                    <input type="text" name="nationalIdPassport" class="form-control border-0 bg-white py-3" placeholder="Passport/ID" required>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Primary Phone</label>
                                                <div class="input-group border rounded-4 overflow-hidden bg-white focus-within-ring transition-300">
                                                    <span class="input-group-text bg-white border-0 ps-3"><i class="bi bi-telephone text-slate-400"></i></span>
                                                    <input type="text" name="phone" class="form-control border-0 bg-white py-3" placeholder="+250..." required>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Email Address</label>
                                                <div class="input-group border rounded-4 overflow-hidden bg-white focus-within-ring transition-300">
                                                    <span class="input-group-text bg-white border-0 ps-3"><i class="bi bi-envelope text-slate-400"></i></span>
                                                    <input type="email" name="visitorEmail" class="form-control border-0 bg-white py-3" placeholder="visitor@example.com" required>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Representing Organization</label>
                                                <div class="input-group border rounded-4 overflow-hidden bg-white focus-within-ring transition-300">
                                                    <span class="input-group-text bg-white border-0 ps-3"><i class="bi bi-building text-slate-400"></i></span>
                                                    <input type="text" name="company" class="form-control border-0 bg-white py-3" placeholder="Company Name" required>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Section 2: Operational Data -->
                                <div class="card border-0 shadow-sm rounded-5 mb-5 overflow-hidden">
                                    <div class="card-header bg-white p-4 border-0 border-bottom border-light">
                                        <div class="d-flex align-items-center">
                                            <div class="bg-indigo-500 bg-opacity-10 p-2 rounded-3 text-primary me-3">
                                                <i class="bi bi-journal-text fs-5"></i>
                                            </div>
                                            <h5 class="fw-bold mb-0 text-slate-800">Visit Objectives</h5>
                                        </div>
                                    </div>
                                    <div class="card-body p-4 p-md-5">
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Mission Purpose</label>
                                                <textarea name="purposeOfVisit" class="form-control border rounded-4 bg-white p-4 transition-300 focus-within-ring" rows="3" placeholder="Describe the reason for access..." required></textarea>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Target Department</label>
                                                <select name="departmentToVisit" class="form-select border rounded-4 bg-white py-3 px-4 transition-300 focus-within-ring" required>
                                                    <option value="">Select Target...</option>
                                                    <option value="IT">IT / Network</option>
                                                    <option value="Facilities">Facilities</option>
                                                    <option value="Security">Security</option>
                                                    <option value="Management">Management</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label small fw-bold text-uppercase text-muted mb-2">Assigned Host</label>
                                                <select name="hostEmployee.userId" class="form-select border rounded-4 bg-white py-3 px-4 transition-300 focus-within-ring" required>
                                                    <option value="">Choose Staff...</option>
                                                    <c:forEach var="staff" items="${staffList}">
                                                        <option value="${staff.userId}">${staff.fullName}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Column -->
                            <div class="col-lg-4">
                                <!-- Section 3: Timeline -->
                                <div class="card border-0 shadow-sm rounded-5 mb-5 bg-white">
                                    <div class="card-body p-4">
                                        <h6 class="fw-black text-slate-900 text-uppercase small mb-4" style="letter-spacing: 1.5px;">Scheduling</h6>
                                        <div class="mb-4">
                                            <label class="form-label small fw-bold text-muted">Activation Date</label>
                                            <input type="date" name="visitDate" class="form-control border rounded-4 bg-slate-50 py-3 transition-300 focus-within-ring" required min="${today}">
                                        </div>
                                        <div class="row g-3 mb-2">
                                            <div class="col-6">
                                                <label class="form-label small fw-bold text-muted">Expected In</label>
                                                <input type="time" name="arrivalTime" class="form-control border rounded-4 bg-slate-50 py-3 transition-300 focus-within-ring" required>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-label small fw-bold text-muted">Duration (H)</label>
                                                <input type="number" name="expectedDurationHours" class="form-control border rounded-4 bg-slate-50 py-3 transition-300 focus-within-ring" min="1" max="12" required>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Section 4: Equipment -->
                                <div class="card border-0 shadow-sm rounded-5 mb-5 bg-white">
                                    <div class="card-body p-4">
                                        <h6 class="fw-black text-slate-900 text-uppercase small mb-4" style="letter-spacing: 1.5px;">Logistics</h6>
                                        <div class="mb-4">
                                            <label class="form-label small fw-bold text-muted">Equipment Manifest</label>
                                            <textarea name="equipmentCarried" class="form-control border rounded-4 bg-slate-50 p-3 transition-300 focus-within-ring" rows="3" placeholder="Laptops, toolboxes, hardware..."></textarea>
                                        </div>
                                        <div class="p-3 rounded-4 border border-primary border-opacity-10 bg-primary bg-opacity-5 mb-4">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" id="safetyCheck" required>
                                                <label class="form-check-label small fw-bold text-primary" for="safetyCheck">
                                                    Policy Compliance Confirmation
                                                </label>
                                            </div>
                                        </div>
                                        <button type="submit" class="btn btn-primary w-100 py-3 rounded-4 fw-black shadow-lg hover-lift transition-300">
                                            COMPLETE REGISTRATION
                                        </button>
                                    </div>
                                </div>

                                <!-- Guidelines -->
                                <div class="p-4 rounded-5 border-0 bg-slate-900 text-white shadow-lg overflow-hidden position-relative">
                                    <div class="position-absolute top-0 end-0 p-3 opacity-20">
                                        <i class="bi bi-info-circle fs-3"></i>
                                    </div>
                                    <h6 class="fw-bold mb-2">Security Directive</h6>
                                    <p class="small mb-0 text-slate-400" style="color: #94a3b8;">
                                        By submitting this form, you acknowledge that all visual and physical interactions are monitored and logged for security auditing.
                                    </p>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <style>
        .fw-black { font-weight: 800; }
        .rounded-5 { border-radius: 1.5rem !important; }
        .transition-300 { transition: all 0.3s ease; }
        .hover-lift:hover { transform: translateY(-3px); }
        .focus-within-ring:focus-within, .focus-within-ring:focus {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15) !important;
            outline: none;
        }
        .bg-slate-50 { background-color: #f8fafc; }
        .text-slate-900 { color: #0f172a; }
        .text-slate-400 { color: #94a3b8; }
        .card-header { border-bottom: 1px solid #f1f5f9 !important; }
    </style>

    <style>
        .transition-all { transition: all 0.3s ease; }
        .hover-lift:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }
        .form-control:focus, .form-select:focus {
            background-color: #fff !important;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
            border-color: #3b82f6;
        }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
