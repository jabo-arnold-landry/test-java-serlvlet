<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Visitor Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    
    <jsp:include page="../common/visitor-header.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="dashboard" />
    </jsp:include>

    <div class="vp-content-area" style="background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);">
        <!-- Dashboard Header -->
        <div class="card border-0 shadow-lg rounded-5 overflow-hidden mb-5" style="background: #0f172a;">
            <div class="card-body p-5 position-relative">
                <div class="position-absolute top-0 end-0 p-4 opacity-10">
                    <i class="bi bi-shield-check" style="font-size: 8rem;"></i>
                </div>
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h6 class="text-primary text-uppercase fw-bold mb-2" style="letter-spacing: 2px;">
                            ${isAdmin ? 'Intelligence Dashboard' : (isManager ? 'Visitor Management Portal' : (isSecurity ? 'Security Reception Desk' : 'Operational Terminal'))}
                        </h6>
                        <h1 class="display-6 fw-bold text-white mb-2">Welcome Back, ${currentUser.fullName}</h1>
                        <p class="text-slate-400 mb-0 fs-5" style="color: #94a3b8;">
                            ${isAdmin ? 'Analyzing global visitor trends and security compliance metrics.' : (isManager ? 'Overseeing visitor approvals, pipeline tracking, and live monitoring.' : (isSecurity ? 'Registering visitors, managing check-ins, and monitoring entrance/exit traffic.' : 'Managing your assigned visitor escorts and duty operations.'))}
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 1. Stats Section (Only for Security/Receptionist Desk) -->
        <c:if test="${isSecurity}">
            <div class="row g-4 mb-5">
                <div class="col-xl-3 col-sm-6">
                    <div class="card border-0 shadow-sm rounded-4 h-100 bg-white hover-up transition-300">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="p-3 rounded-4 bg-warning bg-opacity-10 text-warning">
                                    <i class="bi bi-hourglass-split fs-4"></i>
                                </div>
                                <span class="badge bg-warning bg-opacity-10 text-warning rounded-pill px-3">Pending</span>
                            </div>
                            <h3 class="fw-black mb-1">${pendingCount}</h3>
                            <div class="text-muted small fw-semibold text-uppercase">${isSecurity ? 'Wait-listed' : 'Approvals Needed'}</div>
                        </div>
                    </div>
                </div>
                
                <div class="col-xl-3 col-sm-6">
                    <div class="card border-0 shadow-sm rounded-4 h-100 bg-white hover-up transition-300">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="p-3 rounded-4 bg-success bg-opacity-10 text-success">
                                    <i class="bi bi-calendar-check fs-4"></i>
                                </div>
                                <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3">${isSecurity ? 'Ready' : 'Pipeline'}</span>
                            </div>
                            <h3 class="fw-black mb-1">${awaitingCount}</h3>
                            <div class="text-muted small fw-semibold text-uppercase">${isSecurity ? 'Check-In Awaiting' : 'Awaiting Arrival'}</div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="card border-0 shadow-sm rounded-4 h-100 bg-white hover-up transition-300">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="p-3 rounded-4 bg-primary bg-opacity-10 text-primary">
                                    <i class="bi bi-activity fs-4"></i>
                                </div>
                                <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill px-3">Live</span>
                            </div>
                            <h3 class="fw-black mb-1">${activeCount}</h3>
                            <div class="text-muted small fw-semibold text-uppercase">${isSecurity ? 'Currently Inside' : 'Visitors Inside'}</div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="card border-0 shadow-sm rounded-4 h-100 bg-white hover-up transition-300">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="p-3 rounded-4 bg-dark bg-opacity-10 text-dark">
                                    <i class="bi bi-clock-history fs-4"></i>
                                </div>
                                <span class="badge bg-dark bg-opacity-10 text-dark rounded-pill px-3">Metrics</span>
                            </div>
                            <h3 class="fw-black mb-1">${isManager ? avgDuration : completedCount}</h3>
                            <div class="text-muted small fw-semibold text-uppercase">${isManager ? 'Avg Visit Duration' : (isSecurity ? 'Total Check-outs' : 'Visits Completed')}</div>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <div class="row g-4">
            <c:choose>
                <c:when test="${isAdmin}">
                    <!-- 1. ADMIN: INTELLIGENCE HUB -->
                    <div class="col-xl-8">
                        <div class="card border-0 shadow-sm rounded-4 bg-white p-4 mb-4">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h5 class="fw-bold mb-0 text-dark">Security Compliance Monitoring</h5>
                                <div class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill small">System Health: Operational</div>
                            </div>
                            <div class="row g-4 mb-2">
                                <div class="col-md-4">
                                    <div class="p-3 bg-slate-50 rounded-4 border border-slate-100">
                                        <div class="small text-muted text-uppercase fw-bold mb-1">Total Visitors</div>
                                        <div class="h4 fw-black mb-0">${totalVisitorsCount}</div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-3 bg-slate-50 rounded-4 border border-slate-100">
                                        <div class="small text-muted text-uppercase fw-bold mb-1">Active Staff</div>
                                        <div class="h4 fw-black mb-0">12</div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-3 bg-slate-50 rounded-4 border border-slate-100">
                                        <div class="small text-muted text-uppercase fw-bold mb-1">Risk Level</div>
                                        <div class="h4 fw-black mb-0 text-success">LOW</div>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-4" style="height: 250px;">
                                <canvas id="trafficChart"></canvas>
                            </div>
                        </div>

                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                            <div class="card-header bg-white p-4 border-0 d-flex justify-content-between align-items-center">
                                <h5 class="fw-bold mb-0 text-dark">Security Incident Audit</h5>
                                <a href="${pageContext.request.contextPath}/visitor-portal/active" class="btn btn-outline-danger btn-sm rounded-pill px-3">
                                    <i class="bi bi-shield-exclamation me-1"></i> Review All
                                </a>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="bg-light">
                                        <tr class="small text-muted text-uppercase">
                                            <th class="px-4 border-0 py-3">Incident</th>
                                            <th class="px-4 border-0 py-3">Reporter</th>
                                            <th class="px-4 border-0 py-3">Severity</th>
                                            <th class="px-4 border-0 py-3">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="inc" items="${allIncidents}" end="4">
                                            <tr>
                                                <td class="px-4 py-3 fw-bold text-dark">${fn:escapeXml(inc.title)}</td>
                                                <td class="px-4 py-3 small text-muted">${inc.reportedBy.fullName}</td>
                                                <td class="px-4 py-3">
                                                    <span class="badge ${inc.severity == 'HIGH' || inc.severity == 'CRITICAL' ? 'bg-danger' : 'bg-warning'} bg-opacity-10 ${inc.severity == 'HIGH' || inc.severity == 'CRITICAL' ? 'text-danger' : 'text-warning'} px-2 rounded-pill">
                                                        ${inc.severity}
                                                    </span>
                                                </td>
                                                <td class="px-4 py-3">
                                                    <span class="badge bg-slate-100 text-slate-600 rounded-pill px-2">
                                                        ${inc.status}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty allIncidents}">
                                            <tr><td colspan="4" class="text-center py-4 text-muted small italic">No security violations recorded in current cycle.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4">
                        <div class="card border-0 shadow-sm rounded-4 bg-slate-900 text-white p-4 mb-4">
                            <h6 class="text-slate-400 small text-uppercase mb-4">Governance Terminal</h6>
                            <div class="d-grid gap-3">
                                <!-- Removed Compliance Audit Logs from Admin Dashboard as requested -->
                                <a href="${pageContext.request.contextPath}/users" class="btn btn-outline-light rounded-3 text-start py-3 px-4">
                                    <i class="bi bi-people me-2"></i> System User Management
                                </a>
                                <hr class="border-secondary my-1">
                                <button onclick="window.print()" class="btn btn-outline-info rounded-3 text-start py-3 px-4">
                                    <i class="bi bi-printer me-2"></i> Generate Activity Report
                                </button>
                                <button onclick="exportTrafficData()" class="btn btn-outline-success rounded-3 text-start py-3 px-4">
                                    <i class="bi bi-file-earmark-spreadsheet me-2"></i> Export CSV Dataset
                                </button>
                            </div>
                        </div>
                        
                        <div class="card border-0 shadow-sm rounded-4 bg-white p-4">
                            <h6 class="fw-bold mb-4 text-uppercase small text-muted">System Oversight Status</h6>
                            <div class="d-flex align-items-center mb-3">
                                <div class="bg-success bg-opacity-10 p-2 rounded-3 text-success me-3">
                                    <i class="bi bi-check-circle-fill"></i>
                                </div>
                                <div class="small">Data backups verified</div>
                            </div>
                            <div class="d-flex align-items-center mb-0">
                                <div class="bg-primary bg-opacity-10 p-2 rounded-3 text-primary me-3">
                                    <i class="bi bi-clock-fill"></i>
                                </div>
                                <div class="small">Last audit: Today, 08:30</div>
                            </div>
                        </div>
                    </div>
                </c:when>

                <c:when test="${isManager}">
                    <!-- 2. MANAGER: GOVERNANCE & MONITORING -->
                    <div class="col-xl-12 mb-4">
                        <c:if test="${not empty overstayedAlerts}">
                            <div class="alert alert-danger border-0 shadow-sm rounded-4 p-4 mb-4 d-flex align-items-center">
                                <div class="p-3 bg-danger bg-opacity-10 text-danger rounded-circle me-4">
                                    <i class="bi bi-exclamation-triangle-fill fs-3"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-1 text-danger">Protocol Overstay Alert</h5>
                                    <p class="mb-0 text-danger opacity-75">${overstayedAlerts.size()} visitors have exceeded their approved session duration. Action required.</p>
                                </div>
                                <a href="${pageContext.request.contextPath}/visitor-portal/active" class="btn btn-danger rounded-pill px-4">VIEW ALERTS</a>
                            </div>
                        </c:if>
                    </div>

                    <div class="col-xl-7">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                            <div class="card-header bg-white p-4 border-0">
                                <h5 class="fw-bold mb-0 text-dark">Live Monitoring View</h5>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="bg-light text-muted small uppercase">
                                        <tr>
                                            <th class="px-4">Visitor</th>
                                            <th class="px-4">Check-in</th>
                                            <th class="px-4">Duration</th>
                                            <th class="px-4">Escort</th>
                                            <th class="px-4 text-end">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="v" items="${activeVisitors}" end="4">
                                            <c:set var="isOverstay" value="false" />
                                            <c:forEach var="ov" items="${overstayedAlerts}">
                                                <c:if test="${ov.checkId == v.checkId}"><c:set var="isOverstay" value="true" /></c:if>
                                            </c:forEach>
                                            <tr class="${isOverstay ? 'bg-danger bg-opacity-10' : ''}">
                                                <td class="px-4 py-3 fw-bold text-dark">
                                                    ${v.visitor.fullName}
                                                    <c:if test="${isOverstay}"><span class="badge bg-danger ms-2">OVERSTAY</span></c:if>
                                                </td>
                                                <td class="px-4 small text-muted">${v.checkInTime.toLocalTime().toString().substring(0, 5)}</td>
                                                <td class="px-4 fw-bold ${isOverstay ? 'text-danger' : 'text-primary'}">${durationMap[v.checkId]}</td>
                                                <td class="px-4 small">${v.escort.fullName}</td>
                                                <td class="px-4 text-end">
                                                    <c:choose>
                                                        <c:when test="${isOverstay}">
                                                            <button class="btn btn-sm btn-danger rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#escalateModal${v.checkId}">ESCALATE</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill px-3">Active</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>

                                            <!-- ESCALATION MODAL -->
                                            <div class="modal fade" id="escalateModal${v.checkId}" tabindex="-1">
                                                <div class="modal-dialog modal-sm">
                                                    <div class="modal-content border-0 shadow rounded-4">
                                                        <div class="modal-header bg-danger text-white border-0 py-3">
                                                            <h6 class="modal-title fw-bold">Escalate Protocol</h6>
                                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body p-4">
                                                            <label class="small text-muted text-uppercase fw-bold mb-2 d-block">Contact Technician</label>
                                                            <div class="p-3 bg-light rounded-3 mb-3 d-flex align-items-center">
                                                                <i class="bi bi-person-badge text-danger me-3 fs-3"></i>
                                                                <div>
                                                                    <div class="fw-bold">${v.escort.fullName}</div>
                                                                    <div class="small text-muted">Int: ${v.escort.userId * 123} | SEC-NET</div>
                                                                </div>
                                                            </div>
                                                            <button class="btn btn-danger w-100 rounded-pill fw-bold" onclick="alert('Escalation signal sent to security desk and technician handheld.')">SEND ALERT</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                        <c:if test="${empty activeVisitors}">
                                            <tr><td colspan="5" class="text-center py-4 text-muted small italic">No live sessions.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-5">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                            <div class="card-header bg-white p-4 border-0">
                                <h5 class="fw-bold mb-0 text-dark">Governance Queue</h5>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="bg-light text-muted small uppercase">
                                        <tr>
                                            <th class="px-4">Visitor</th>
                                            <th class="px-4">Internal Info</th>
                                            <th class="px-4 text-end">Management Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="v" items="${recentVisits}" end="4">
                                            <tr>
                                                <td class="px-4 py-3 fw-bold text-dark">
                                                    ${v.visitorName}
                                                    <div class="small text-muted fw-normal">${v.company}</div>
                                                </td>
                                                <td class="px-4">
                                                    <span class="badge ${v.status == 'PENDING' ? 'bg-warning' : 'bg-info'} bg-opacity-10 ${v.status == 'PENDING' ? 'text-warning' : 'text-info'} rounded-pill px-2 small">
                                                        ${v.status == 'PENDING' ? 'Initial Review' : 'Clarification Requested'}
                                                    </span>
                                                </td>
                                                <td class="px-4 text-end">
                                                    <button class="btn btn-sm btn-slate-900 text-white rounded-pill px-4 fw-bold shadow-sm" 
                                                            data-bs-toggle="modal" data-bs-target="#reviewModal${v.approvalId}">
                                                        REVIEW & DECIDE
                                                    </button>

                                                    <!-- COMPREHENSIVE REVIEW & DECISION MODAL (Moved inside TD for valid HTML) -->
                                                    <div class="modal fade" id="reviewModal${v.approvalId}" tabindex="-1" aria-hidden="true" style="text-align: left;">
                                                        <div class="modal-dialog modal-lg modal-dialog-centered">
                                                            <div class="modal-content border-0 shadow-lg rounded-5 overflow-hidden">
                                                                <div class="modal-header bg-slate-900 p-4 border-0">
                                                                    <div class="d-flex align-items-center">
                                                                        <div class="p-2 bg-primary bg-opacity-20 rounded-3 me-3 text-primary">
                                                                            <i class="bi bi-person-badge fs-4"></i>
                                                                        </div>
                                                                        <div>
                                                                            <h5 class="modal-title fw-black text-white">Visitor Authentication Protocol</h5>
                                                                            <p class="text-slate-400 small mb-0">Review log data before access authorization</p>
                                                                        </div>
                                                                    </div>
                                                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                                </div>
                                                                <div class="modal-body p-5">
                                                                    <!-- VISOR PROFILE DATA -->
                                                                    <div class="row g-4 mb-5">
                                                                        <div class="col-md-6">
                                                                            <label class="form-label small fw-black text-uppercase text-slate-400">Full Legal Name</label>
                                                                            <div class="p-3 bg-slate-50 rounded-4 border border-slate-100 fw-bold text-dark text-start">${v.visitorName}</div>
                                                                        </div>
                                                                        <div class="col-md-6">
                                                                            <label class="form-label small fw-black text-uppercase text-slate-400">Identification (ID / Passport)</label>
                                                                            <div class="p-3 bg-slate-50 rounded-4 border border-slate-100 fw-bold text-dark text-start">${v.nationalId}</div>
                                                                        </div>
                                                                        <div class="col-md-6">
                                                                            <label class="form-label small fw-black text-uppercase text-slate-400">Target Department</label>
                                                                            <div class="p-3 bg-slate-50 rounded-4 border border-slate-100 fw-bold text-dark text-start">${v.department}</div>
                                                                        </div>
                                                                        <div class="col-md-6">
                                                                            <label class="form-label small fw-black text-uppercase text-slate-400">Purpose of Visit</label>
                                                                            <div class="p-3 bg-slate-50 rounded-4 border border-slate-100 fw-bold text-dark text-start">${v.purposeOfVisit}</div>
                                                                        </div>
                                                                        <div class="col-md-4">
                                                                            <label class="form-label small fw-black text-uppercase text-slate-400">Phone Number</label>
                                                                            <div class="p-3 bg-slate-50 rounded-4 border border-slate-100 text-dark text-start">${v.phone}</div>
                                                                        </div>
                                                                        <div class="col-md-4">
                                                                            <label class="form-label small fw-black text-uppercase text-slate-400">Arrival Time</label>
                                                                            <div class="p-3 bg-slate-50 rounded-4 border border-slate-100 text-dark text-start">${v.arrivalTime}</div>
                                                                        </div>
                                                                        <div class="col-md-4">
                                                                            <label class="form-label small fw-black text-uppercase text-slate-400">Visit Date</label>
                                                                            <div class="p-3 bg-slate-50 rounded-4 border border-slate-100 text-dark text-start">${v.visitDate}</div>
                                                                        </div>
                                                                    </div>

                                                                    <!-- ACTION TABS / DECISION AREA -->
                                                                    <div class="card border-0 bg-slate-50 rounded-5 p-4">
                                                                        <h6 class="fw-black text-slate-900 mb-4 d-flex align-items-center text-start">
                                                                            <i class="bi bi-gear-fill me-2 text-primary"></i> DECISION COMMANDS
                                                                        </h6>
                                                                        
                                                                        <div class="nav nav-pills mb-4 gap-2" id="pills-tab${v.approvalId}" role="tablist">
                                                                            <button class="nav-link active rounded-pill px-4 fw-bold" id="pills-approve-tab${v.approvalId}" data-bs-toggle="pill" data-bs-target="#pills-approve${v.approvalId}" type="button">APPROVE</button>
                                                                            <button class="nav-link rounded-pill px-4 fw-bold" id="pills-info-tab${v.approvalId}" data-bs-toggle="pill" data-bs-target="#pills-info${v.approvalId}" type="button">REQUEST INFO</button>
                                                                            <button class="nav-link rounded-pill px-4 fw-bold btn-outline-danger" id="pills-reject-tab${v.approvalId}" data-bs-toggle="pill" data-bs-target="#pills-reject${v.approvalId}" type="button">REJECT</button>
                                                                        </div>
                                                                        
                                                                        <div class="tab-content" id="pills-tabContent${v.approvalId}">
                                                                            <!-- APPROVE TAB -->
                                                                            <div class="tab-pane fade show active" id="pills-approve${v.approvalId}">
                                                                                <form action="${pageContext.request.contextPath}/visitor-portal/approve/${v.approvalId}" method="post">
                                                                                    <c:if test="${not empty _csrf}">
                                                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                                                    </c:if>
                                                                                    <div class="mb-3 text-start">
                                                                                        <label class="form-label small fw-bold">Authorized Session Duration (Hours)</label>
                                                                                        <input type="number" name="durationHours" class="form-control border-0 shadow-sm rounded-4 py-3" value="4" min="1" max="24">
                                                                                    </div>
                                                                                    <button type="submit" class="btn btn-success w-100 py-3 rounded-4 fw-black shadow-lg">GRANT FULL ACCESS</button>
                                                                                </form>
                                                                            </div>
                                                                            <!-- INFO TAB -->
                                                                            <div class="tab-pane fade" id="pills-info${v.approvalId}">
                                                                                <form action="${pageContext.request.contextPath}/visitor-portal/request-info/${v.approvalId}" method="post">
                                                                                    <c:if test="${not empty _csrf}">
                                                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                                                    </c:if>
                                                                                    <div class="mb-3 text-start">
                                                                                        <label class="form-label small fw-bold">Instructions for Security Desk</label>
                                                                                        <textarea name="remarks" class="form-control border-0 shadow-sm rounded-4" rows="3" required placeholder="Specify missing info..."></textarea>
                                                                                    </div>
                                                                                    <button type="submit" class="btn btn-info text-white w-100 py-3 rounded-4 fw-black shadow-lg">SEND PROTOCOL CLARIFICATION</button>
                                                                                </form>
                                                                            </div>
                                                                            <!-- REJECT TAB -->
                                                                            <div class="tab-pane fade" id="pills-reject${v.approvalId}">
                                                                                <form action="${pageContext.request.contextPath}/visitor-portal/reject/${v.approvalId}" method="post">
                                                                                    <c:if test="${not empty _csrf}">
                                                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                                                    </c:if>
                                                                                    <div class="mb-3 text-start">
                                                                                        <label class="form-label small fw-bold text-danger">Security Justification for Denial</label>
                                                                                        <textarea name="reason" class="form-control border-0 shadow-sm rounded-4" rows="3" required placeholder="Specify why visit is denied..."></textarea>
                                                                                    </div>
                                                                                    <button type="submit" class="btn btn-danger w-100 py-3 rounded-4 fw-black shadow-lg">DENY FACILITY ACCESS</button>
                                                                                </form>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty recentVisits}">
                                            <tr><td colspan="3" class="text-center py-5 text-muted small italic">Queue is clear. No pending authorizations.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- 3. MANAGER REPORTS SECTION -->
                    <div class="col-xl-12 mb-5">
                        <div class="card border-0 shadow-sm rounded-4 bg-white p-4">
                            <h5 class="fw-bold mb-4 text-dark"><i class="bi bi-file-earmark-bar-graph text-primary me-2"></i> Advanced Governance Reports</h5>
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <h6 class="text-muted small text-uppercase mb-3">Daily Traffic Trends (Last 7 Days)</h6>
                                    <div style="height: 250px;">
                                        <canvas id="dailyTrafficChart"></canvas>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="text-muted small text-uppercase mb-3">Monthly Visit Volume</h6>
                                    <div style="height: 250px;">
                                        <canvas id="monthlyVolumeChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:when>

                <c:when test="${isSecurity}">
                    <!-- 3. SECURITY: RECEPTIONIST DESK -->
                    <div class="col-xl-9">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                            <div class="card-header bg-white p-4 border-0">
                                <h5 class="fw-bold mb-0 text-dark">Live Operational Desk (Active Sessions)</h5>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="bg-light text-muted small uppercase">
                                        <tr>
                                            <th class="px-4">Visitor</th>
                                            <th class="px-4">Check-In</th>
                                            <th class="px-4">Duration</th>
                                            <th class="px-4 text-end">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="v" items="${activeVisitors}" end="4">
                                            <tr>
                                                <td class="px-4 py-3 fw-bold text-dark">${v.visitor.fullName}</td>
                                                <td class="px-4 small text-muted">${v.checkInTime.toLocalTime().toString().substring(0, 5)}</td>
                                                <td class="px-4 fw-bold text-primary">${durationMap[v.checkId]}</td>
                                                <td class="px-4 text-end">
                                                    <button class="btn btn-sm btn-warning text-white rounded-pill px-3 fw-bold shadow-sm" 
                                                            data-bs-toggle="modal" data-bs-target="#checkoutModal${v.checkId}">
                                                        LOG OUT
                                                    </button>
                                                </td>
                                            </tr>

                                            <!-- CHECK-OUT MODAL FOR DASHBOARD -->
                                            <div class="modal fade" id="checkoutModal${v.checkId}" tabindex="-1">
                                                <div class="modal-dialog modal-dialog-centered">
                                                    <div class="modal-content border-0 shadow-lg rounded-5 overflow-hidden">
                                                        <div class="modal-header bg-warning p-4 border-0">
                                                            <h5 class="modal-title fw-black text-white">Session Termination</h5>
                                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <form action="${pageContext.request.contextPath}/visitor-portal/checkout/${v.checkId}" method="post">
                                                            <div class="modal-body p-5">
                                                                <div class="text-center mb-4 text-dark">
                                                                    <div class="p-3 bg-warning bg-opacity-10 text-warning rounded-circle d-inline-block mb-3">
                                                                        <i class="bi bi-exclamation-triangle fs-2"></i>
                                                                    </div>
                                                                    <h6 class="fw-bold">Finalizing visit for ${v.visitor.fullName}</h6>
                                                                    <p class="small text-muted">Duration: ${durationMap[v.checkId]}</p>
                                                                </div>
                                                                <div class="space-y-3">
                                                                    <div class="p-3 border border-light bg-light rounded-4">
                                                                        <div class="form-check form-switch custom-switch">
                                                                            <input class="form-check-input" type="checkbox" name="equipmentConfirmed" id="dashEquip${v.checkId}" value="true" checked>
                                                                            <label class="form-check-label fw-bold text-dark" for="dashEquip${v.checkId}">All Equipment Recovered</label>
                                                                        </div>
                                                                    </div>
                                                                    <div class="p-3 border border-light bg-light rounded-4 mt-3">
                                                                        <div class="form-check form-switch custom-switch">
                                                                            <input class="form-check-input" type="checkbox" name="badgeReturned" id="dashBadge${v.checkId}" value="true" checked>
                                                                            <label class="form-check-label fw-bold text-dark" for="dashBadge${v.checkId}">Access Badge Deactivated</label>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer p-4 border-0">
                                                                <button type="button" class="btn btn-light px-4 py-3 rounded-4 fw-bold" data-bs-dismiss="modal">CANCEL</button>
                                                                <button type="submit" class="btn btn-warning text-white px-4 py-3 rounded-4 fw-black shadow-lg">CONFIRM DEPARTURE</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                        <c:if test="${empty activeVisitors}">
                                            <tr><td colspan="4" class="text-center py-5 text-muted italic small">No active sessions detected at the front desk.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 bg-slate-900 text-white p-4 mb-4">
                            <h6 class="text-slate-400 small text-uppercase mb-3">Front Desk Operations</h6>
                            <a href="${pageContext.request.contextPath}/visitor-portal/request" class="btn btn-primary w-100 mb-2 rounded-3 text-white fw-bold">New Registration</a>
                            <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="btn btn-outline-light w-100 rounded-3">Tracking & Check-In</a>
                        </div>
                    </div>
                </c:when>

                <c:otherwise>
                    <!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->
                    <div class="col-12">
                        <!-- Notifications (Top Priority) -->
                        <div class="card border-0 shadow-sm rounded-4 bg-white p-4 mb-4">
                            <h5 class="fw-bold mb-3 d-flex align-items-center text-dark">
                                <i class="bi bi-bell-fill text-warning me-2"></i> Operational Alerts
                            </h5>
                            <div class="list-group list-group-flush">
                                <c:forEach var="notif" items="${dashNotifications}">
                                    <div class="list-group-item px-0 border-0 d-flex align-items-start py-3">
                                        <div class="me-3 mt-1">
                                            <c:choose>
                                                <c:when test="${notif.type == 'ASSIGNMENT'}">
                                                    <i class="bi bi-person-plus-fill text-primary fs-5"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="bi bi-geo-alt-fill text-success fs-5"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div>
                                            <div class="fw-bold text-dark small text-uppercase mb-1">
                                                ${notif.type == 'ASSIGNMENT' ? 'New Assignment' : 'Visitor Check-In'}
                                            </div>
                                            <div class="text-secondary small line-height-sm">${notif.content}</div>
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty dashNotifications}">
                                    <div class="text-center py-4 text-muted small italic">
                                        <i class="bi bi-check2-all d-block fs-3 mb-2 opacity-25"></i>
                                        All operational protocols are current.
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <!-- Assignments Table -->
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                            <div class="card-header bg-white p-4 border-0 d-flex justify-content-between align-items-center">
                                <h5 class="fw-bold mb-0 text-dark">My Escort Assignments</h5>
                                <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="btn btn-light btn-sm rounded-pill px-3">View Full List</a>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="bg-light text-muted small uppercase">
                                        <tr>
                                            <th class="px-4">Visitor</th>
                                            <th class="px-4">Company</th>
                                            <th class="px-4">Purpose</th>
                                            <th class="px-4 text-center">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="v" items="${recentVisits}">
                                            <tr>
                                                <td class="px-4 py-3 fw-bold">${v.visitorName}</td>
                                                <td class="px-4">${v.company}</td>
                                                <td class="px-4 small">${v.purposeOfVisit}</td>
                                                <td class="px-4 text-center">
                                                    <span class="badge ${v.status == 'ACTIVE' ? 'bg-primary' : 'bg-success'} bg-opacity-10 ${v.status == 'ACTIVE' ? 'text-primary' : 'text-success'} rounded-pill px-3">
                                                        ${v.status}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Incident Report Action -->
                        <div class="mt-4 text-center">
                            <a href="${pageContext.request.contextPath}/visitor-portal/report-incident" class="btn btn-danger rounded-pill px-5 py-3 fw-bold shadow-sm">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i> Report Security Violation
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <style>
        :root {
            --slate-50: #f8fafc;
            --slate-100: #f1f5f9;
            --slate-400: #94a3b8;
            --slate-600: #475569;
            --slate-900: #0f172a;
        }
        .bg-slate-50 { background-color: var(--slate-50) !important; }
        .bg-slate-100 { background-color: var(--slate-100) !important; }
        .bg-slate-900 { background-color: var(--slate-900) !important; }
        .text-slate-400 { color: var(--slate-400) !important; }
        .text-slate-900 { color: var(--slate-900) !important; }
        .border-slate-100 { border-color: var(--slate-100) !important; }
        
        .btn-slate-900 { 
            background-color: var(--slate-900); 
            color: white; 
            border: none;
            transition: all 0.3s ease;
        }
        .btn-slate-900:hover { 
            background-color: #1e293b; 
            color: #3b82f6;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .hover-up:hover { transform: translateY(-5px); box-shadow: 0 1rem 3rem rgba(0,0,0,0.1) !important; }
        .hover-bg-primary:hover { background-color: #f8fafc !important; }
        .transition-300 { transition: all 0.3s ease-in-out; }
        .fw-black { font-weight: 800; }
        .p-5 { padding: 3rem !important; }
        .rounded-5 { border-radius: 2rem !important; }
        .icon-box { display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; }
        
        .custom-switch .form-check-input:checked {
            background-color: #10b981;
            border-color: #10b981;
        }
    </style>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            if (document.getElementById('dailyTrafficChart')) {
                const ctxD = document.getElementById('dailyTrafficChart').getContext('2d');
                new Chart(ctxD, {
                    type: 'line',
                    data: {
                        labels: [<c:forEach var="entry" items="${dailyStats}" varStatus="status">'${entry.key}'${status.last ? '' : ','}</c:forEach>],
                        datasets: [{
                            label: 'Today Visitors',
                            data: [<c:forEach var="entry" items="${dailyStats}" varStatus="status">${entry.value}${status.last ? '' : ','}</c:forEach>],
                            borderColor: '#10b981',
                            backgroundColor: 'rgba(16, 185, 129, 0.1)',
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: { maintainAspectRatio: false, plugins: { legend: { display: false } } }
                });
            }

            if (document.getElementById('monthlyVolumeChart')) {
                const ctxM = document.getElementById('monthlyVolumeChart').getContext('2d');
                new Chart(ctxM, {
                    type: 'bar',
                    data: {
                        labels: [<c:forEach var="entry" items="${monthlyStats}" varStatus="status">'${entry.key}'${status.last ? '' : ','}</c:forEach>],
                        datasets: [{
                            label: 'Monthly Volume',
                            data: [<c:forEach var="entry" items="${monthlyStats}" varStatus="status">${entry.value}${status.last ? '' : ','}</c:forEach>],
                            backgroundColor: '#3b82f6',
                            borderRadius: 8
                        }]
                    },
                    options: { maintainAspectRatio: false, plugins: { legend: { display: false } } }
                });
            }
        });

        function downloadCSV(filename, rows) {
            const content = rows.map(r => r.join(',')).join('\n');
            const blob = new Blob([content], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.setAttribute('download', filename);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        function exportTrafficData() {
            const rows = [['Month', 'Visitor Count']];
            <c:forEach var="entry" items="${monthlyStats}">
                rows.push(['<c:out value="${entry.key}"/>', '${entry.value}']);
            </c:forEach>
            downloadCSV('monthly_traffic_report.csv', rows);
        }

        function exportIncidentData() {
            const rows = [['Title', 'Severity', 'Status']];
            <c:forEach var="inc" items="${allIncidents}">
                rows.push(['<c:out value="${inc.title}"/>', '${inc.severity}', '${inc.status}']);
            </c:forEach>
            downloadCSV('security_incident_log.csv', rows);
        }

        function exportMovementData() {
            const rows = [['Visitor', 'Company', 'Status']];
            <c:forEach var="v" items="${recentVisits}">
                rows.push(['<c:out value="${v.visitorName}"/>', '<c:out value="${v.company}"/>', '${v.status}']);
            </c:forEach>
            downloadCSV('movement_audit_log.csv', rows);
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
