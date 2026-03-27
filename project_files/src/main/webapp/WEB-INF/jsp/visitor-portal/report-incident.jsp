<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Security Protocol Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/visitor-header.jsp"/>
    <style>
        :root {
            --slate-50: #f8fafc;
            --slate-100: #f1f5f9;
            --slate-200: #e2e8f0;
            --slate-300: #cbd5e1;
            --slate-400: #94a3b8;
            --slate-500: #64748b;
            --slate-600: #475569;
            --slate-700: #334155;
            --slate-800: #1e293b;
            --slate-900: #0f172a;
            --primary: #3b82f6;
            --danger: #ef4444;
        }
        body { background: var(--slate-50); font-family: 'Inter', sans-serif; }
        .fw-black { font-weight: 800; }
        .glass-card { background: rgba(255, 255, 255, 0.9); backdrop-filter: blur(10px); border: 1px solid var(--slate-200); }
        .rounded-5 { border-radius: 1.5rem !important; }
        .form-control, .form-select { border: 1px solid var(--slate-200); padding: 0.8rem 1rem; border-radius: 0.75rem; background: var(--slate-50); transition: all 0.2s; }
        .form-control:focus, .form-select:focus { background: #fff; border-color: var(--primary); box-shadow: 0 0 0 4px rgba(59,130,246,0.1); }
        .btn-primary-premium { background: var(--slate-900); color: white; border: none; padding: 1rem 2rem; border-radius: 1rem; font-weight: 800; transition: all 0.3s; }
        .btn-primary-premium:hover { background: var(--slate-800); transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }
        .incident-header { background: linear-gradient(135deg, var(--slate-900) 0%, #1e293b 100%); color: white; padding: 3rem 0; border-radius: 0 0 3rem 3rem; margin-bottom: -4rem; }
    </style>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="active" />
    </jsp:include>

    <div class="vp-content-area p-0">
        <div class="incident-header">
            <div class="container-fluid px-5">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb mb-2">
                                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/visitor-portal" class="text-slate-400 text-decoration-none small fw-bold">DASHBOARD</a></li>
                                <li class="breadcrumb-item active text-white small fw-bold" aria-current="page">SECURITY PROTOCOL</li>
                            </ol>
                        </nav>
                        <h1 class="fw-black mb-0">Report Security Incident</h1>
                        <p class="text-slate-400 mb-0">Formal documentation of policy violations or equipment risks</p>
                    </div>
                    <div class="p-4 bg-danger bg-opacity-10 rounded-pill border border-danger border-opacity-20">
                        <i class="bi bi-exclamation-triangle fs-2 text-danger"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="container-fluid px-5 pb-5">
            <div class="row">
                <div class="col-lg-8">
                    <div class="card glass-card shadow-sm rounded-5 border-0 p-5 mt-5">
                        <form action="${pageContext.request.contextPath}/visitor-portal/save-incident" method="post">
                            <input type="hidden" name="visitorId" value="${visitorId}">
                            
                            <div class="row g-4 mb-5">
                                <div class="col-12">
                                    <label class="form-label small fw-black text-slate-400 text-uppercase" style="letter-spacing: 1px;">Incident Title</label>
                                    <input type="text" name="title" class="form-control" value="${incident.title}" required placeholder="e.g., Unauthorized Access Attempt in Sector B">
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label small fw-black text-slate-400 text-uppercase" style="letter-spacing: 1px;">Criticality Level</label>
                                    <select name="severity" class="form-select" required>
                                        <option value="LOW">Low - Policy Reminder</option>
                                        <option value="MEDIUM">Medium - Escalation Required</option>
                                        <option value="HIGH">High - Immediate Intervention</option>
                                        <option value="CRITICAL">Critical - Facility Lockdown</option>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label small fw-black text-slate-400 text-uppercase" style="letter-spacing: 1px;">Linked Visit Session</label>
                                    <select name="visitorId" class="form-select" id="visitLink">
                                        <option value="">-- No Specific Visitor --</option>
                                        <c:forEach var="v" items="${activeEscorts}">
                                            <option value="${v.visitor.visitorId}" ${v.visitor.visitorId == visitorId ? 'selected' : ''}>
                                                ${v.visitor.fullName} (${v.visitor.company})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-12">
                                    <label class="form-label small fw-black text-slate-400 text-uppercase" style="letter-spacing: 1px;">Incident Classification</label>
                                    <div class="row g-2">
                                        <div class="col-md-4">
                                            <input type="radio" class="btn-check" name="equipmentType" id="type_policy" value="OTHER" checked>
                                            <label class="btn btn-outline-slate w-100 py-3 rounded-4 fw-bold" for="type_policy">
                                                <i class="bi bi-shield-lock me-2"></i>Security Policy
                                            </label>
                                        </div>
                                        <div class="col-md-4">
                                            <input type="radio" class="btn-check" name="equipmentType" id="type_equip" value="OTHER">
                                            <label class="btn btn-outline-slate w-100 py-3 rounded-4 fw-bold" for="type_equip">
                                                <i class="bi bi-tools me-2"></i>Equipment Risk
                                            </label>
                                        </div>
                                        <div class="col-md-4">
                                            <input type="radio" class="btn-check" name="equipmentType" id="type_other" value="OTHER">
                                            <label class="btn btn-outline-slate w-100 py-3 rounded-4 fw-bold" for="type_other">
                                                <i class="bi bi-question-circle me-2"></i>Other
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <label class="form-label small fw-black text-slate-400 text-uppercase" style="letter-spacing: 1px;">Detailed Findings</label>
                                    <textarea name="description" class="form-control" rows="6" required placeholder="Describe the incident, sequence of events, and parties involved...">${incident.description}</textarea>
                                </div>
                            </div>

                            <div class="d-flex align-items-center justify-content-between pt-4 border-top">
                                <a href="${pageContext.request.contextPath}/visitor-portal" class="btn btn-link text-slate-400 fw-bold text-decoration-none">
                                    <i class="bi bi-arrow-left me-2"></i>ABORT REPORT
                                </a>
                                <button type="submit" class="btn btn-primary-premium">
                                    SUBMIT SECURITY LOG
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="col-lg-4 mt-5">
                    <div class="card border-0 shadow-sm rounded-5 p-4 bg-slate-900 text-white">
                        <h5 class="fw-black mb-4">Protocol Requirements</h5>
                        <div class="d-flex mb-4">
                            <div class="me-3 p-2 bg-white bg-opacity-10 rounded-3">
                                <i class="bi bi-info-circle"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1">Accurate Classification</h6>
                                <p class="small text-slate-400 mb-0">Ensure the severity level matches the operational impact of the incident.</p>
                            </div>
                        </div>
                        <div class="d-flex mb-4">
                            <div class="me-3 p-2 bg-white bg-opacity-10 rounded-3">
                                <i class="bi bi-person-badge"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1">Session Linkage</h6>
                                <p class="small text-slate-400 mb-0">Always link the incident to an active visit if applicable for audit trails.</p>
                            </div>
                        </div>
                        <div class="d-flex mb-0">
                            <div class="me-3 p-2 bg-white bg-opacity-10 rounded-3">
                                <i class="bi bi-megaphone"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1">Immediate Alert</h6>
                                <p class="small text-slate-400 mb-0">High and Critical reports will trigger instant SMS alerts to the Facility Manager.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        .btn-outline-slate { border-color: var(--slate-200); color: var(--slate-600); }
        .btn-check:checked + .btn-outline-slate { background: var(--slate-900); border-color: var(--slate-900); color: white; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
