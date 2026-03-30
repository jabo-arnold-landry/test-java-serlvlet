<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Log Incident</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Log New Incident</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Report equipment failures and incidents</p>
            </div>
            <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/incidents/save" method="post" enctype="multipart/form-data">
                <h6 class="fw-bold mb-3">Incident Details</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-8">
                        <label class="form-label">Title <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title" value="${incident.title}" required placeholder="Brief incident description"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Severity <span class="text-danger">*</span></label>
                        <select class="form-select" name="severity" required>
                            <option value="LOW" ${incident.severity == 'LOW' ? 'selected' : ''}>Low</option>
                            <option value="MEDIUM" ${incident.severity == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                            <option value="HIGH" ${incident.severity == 'HIGH' ? 'selected' : ''}>High</option>
                            <option value="CRITICAL" ${incident.severity == 'CRITICAL' ? 'selected' : ''}>Critical</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Equipment Type <span class="text-danger">*</span></label>
                        <select class="form-select" name="equipmentType" required>
                            <option value="UPS" ${incident.equipmentType == 'UPS' ? 'selected' : ''}>UPS</option>
                            <option value="COOLING" ${incident.equipmentType == 'COOLING' ? 'selected' : ''}>Cooling</option>
                            <option value="OTHER" ${incident.equipmentType == 'OTHER' ? 'selected' : ''}>Other</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Equipment ID</label>
                        <input type="number" class="form-control" name="equipmentId" value="${incident.equipmentId}"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Reported By (User ID)</label>
                        <input type="number" class="form-control" name="reportedBy.userId"/>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="description" rows="3" placeholder="Detailed description of the incident...">${incident.description}</textarea>
                    </div>
                </div>
                <h6 class="fw-bold mb-3">Downtime Tracking</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label">Downtime Start</label>
                        <input type="datetime-local" class="form-control" name="downtimeStart"/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="OPEN" selected>Open</option>
                        </select>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-danger"><i class="bi bi-exclamation-triangle"></i> Log Incident</button>
                    <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
