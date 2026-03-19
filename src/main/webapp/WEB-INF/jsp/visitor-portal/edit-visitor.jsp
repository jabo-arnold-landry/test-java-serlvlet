<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Edit Visitor</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/visitor-header.jsp"/>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="visit-log" />
    </jsp:include>

    <div class="vp-content-area">
        <div class="container-fluid">
            <div class="col-lg-8 mx-auto">

                <div class="bg-white rounded-3 p-4 shadow-sm border border-light mb-4">
                    <div class="d-flex align-items-center">
                        <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="btn btn-outline-secondary rounded-3 me-3">
                            <i class="bi bi-arrow-left"></i>
                        </a>
                        <div>
                            <h3 class="mb-0 text-dark fw-bold">Edit Visitor Details</h3>
                            <p class="text-muted mb-0 small">Ref: VR-${visitor.visitorId} &mdash; Update data entry for ${visitor.fullName}</p>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/visitor-portal/edit/${visitor.visitorId}" method="post">

                            <!-- Visitor Info -->
                            <h6 class="text-uppercase text-muted fw-bold mb-3" style="font-size:0.75rem; letter-spacing:1px;">Visitor Details</h6>
                            <div class="row g-3 mb-4">
                                <div class="col-md-12">
                                    <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                                    <input type="text" name="fullName" class="form-control" value="${visitor.fullName}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">National ID / Passport <span class="text-danger">*</span></label>
                                    <input type="text" name="nationalIdPassport" class="form-control" value="${visitor.nationalIdPassport}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Company / Organization</label>
                                    <input type="text" name="company" class="form-control" value="${visitor.company}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Phone Number</label>
                                    <input type="text" name="phone" class="form-control" value="${visitor.phone}">
                                </div>
                            </div>

                            <!-- Visit Details -->
                            <h6 class="text-uppercase text-muted fw-bold mb-3" style="font-size:0.75rem; letter-spacing:1px;">Visit Details</h6>
                            <div class="row g-3 mb-4">
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Purpose of Visit <span class="text-danger">*</span></label>
                                    <input type="text" name="purposeOfVisit" class="form-control" value="${visitor.purposeOfVisit}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Department to Visit</label>
                                    <select name="departmentToVisit" class="form-select">
                                        <option value="">Select Department</option>
                                        <option value="IT" ${visitor.departmentToVisit == 'IT' ? 'selected' : ''}>IT / Network Operations</option>
                                        <option value="Facilities" ${visitor.departmentToVisit == 'Facilities' ? 'selected' : ''}>Facilities / Cooling</option>
                                        <option value="Security" ${visitor.departmentToVisit == 'Security' ? 'selected' : ''}>Security</option>
                                        <option value="Management" ${visitor.departmentToVisit == 'Management' ? 'selected' : ''}>Management</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Visit Date <span class="text-danger">*</span></label>
                                    <input type="date" name="visitDate" class="form-control" value="${visitor.visitDate}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Arrival Time</label>
                                    <input type="time" name="arrivalTime" class="form-control" value="${visitor.arrivalTime}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Expected Duration (Hours)</label>
                                    <input type="number" name="expectedDurationHours" class="form-control"
                                           value="${visitor.expectedDurationHours}" min="1" max="12">
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Host Employee</label>
                                    <select name="hostEmployee.userId" class="form-select">
                                        <option value="">-- No Host --</option>
                                        <c:forEach var="staff" items="${staffList}">
                                            <option value="${staff.userId}"
                                                ${visitor.hostEmployee != null && visitor.hostEmployee.userId == staff.userId ? 'selected' : ''}>
                                                ${staff.fullName} (${staff.role})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Equipment Carried</label>
                                    <textarea name="equipmentCarried" class="form-control" rows="2">${visitor.equipmentCarried}</textarea>
                                </div>
                            </div>

                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg fw-bold rounded-3">
                                    <i class="bi bi-save2-fill me-2"></i>Save Changes
                                </button>
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
