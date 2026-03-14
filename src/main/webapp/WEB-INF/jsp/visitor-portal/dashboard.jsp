<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Visitor Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    
    <jsp:include page="../common/visitor-header.jsp"/>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="dashboard" />
    </jsp:include>

    <div class="vp-content-area" style="background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);">
        <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
        
        <!-- Header Section -->
        <div class="card border-0 shadow-lg rounded-5 overflow-hidden mb-5" style="background: #0f172a;">
            <div class="card-body p-5 position-relative">
                <div class="position-absolute top-0 end-0 p-4 opacity-10">
                    <i class="bi bi-shield-check" style="font-size: 8rem;"></i>
                </div>
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h6 class="text-primary text-uppercase fw-bold mb-2" style="letter-spacing: 2px;">
                            ${isTech ? 'Technician Terminal' : 'Security Operations'}
                        </h6>
                        <h1 class="display-6 fw-bold text-white mb-2">Welcome Back, ${currentUser.fullName}</h1>
                        <p class="text-slate-400 mb-0 fs-5" style="color: #94a3b8;">
                            ${isTech ? 'Managing your visitor escorts and technical safety protocols.' : 'Overseeing facility access and visitor security logs.'}
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Section -->
        <div class="row g-4 mb-5">
            <c:if test="${!isTech}">
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
                            <div class="text-muted small fw-semibold text-uppercase">Approvals Needed</div>
                        </div>
                    </div>
                </div>
            </c:if>
            
            <div class="${isTech ? 'col-xl-4' : 'col-xl-3'} col-sm-6">
                <div class="card border-0 shadow-sm rounded-4 h-100 bg-white hover-up transition-300">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="p-3 rounded-4 bg-success bg-opacity-10 text-success">
                                <i class="bi bi-calendar-check fs-4"></i>
                            </div>
                            <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3">Pipeline</span>
                        </div>
                        <h3 class="fw-black mb-1">${awaitingCount}</h3>
                        <div class="text-muted small fw-semibold text-uppercase">${isTech ? 'My Assignments' : 'Approved/Awaiting'}</div>
                    </div>
                </div>
            </div>

            <div class="${isTech ? 'col-xl-4' : 'col-xl-3'} col-sm-6">
                <div class="card border-0 shadow-sm rounded-4 h-100 bg-white hover-up transition-300">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="p-3 rounded-4 bg-primary bg-opacity-10 text-primary">
                                <i class="bi bi-activity fs-4"></i>
                            </div>
                            <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill px-3">Live</span>
                        </div>
                        <h3 class="fw-black mb-1">${activeCount}</h3>
                        <div class="text-muted small fw-semibold text-uppercase">${isTech ? 'Active Escorts' : 'Visitors Inside'}</div>
                    </div>
                </div>
            </div>

            <div class="${isTech ? 'col-xl-4' : 'col-xl-3'} col-sm-6">
                <div class="card border-0 shadow-sm rounded-4 h-100 bg-white hover-up transition-300">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="p-3 rounded-4 bg-dark bg-opacity-10 text-dark">
                                <i class="bi bi-check2-all fs-4"></i>
                            </div>
                            <span class="badge bg-dark bg-opacity-10 text-dark rounded-pill px-3">Today</span>
                        </div>
                        <h3 class="fw-black mb-1">${completedCount}</h3>
                        <div class="text-muted small fw-semibold text-uppercase">Completed</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Table Section -->
            <div class="${isTech ? 'col-xl-8' : 'col-xl-9'}">
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                    <div class="card-header bg-white p-4 border-0 d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold mb-0 text-dark">
                            ${isTech ? 'My Recent Assignments' : 'Recent System Activity'}
                        </h5>
                        <a href="${pageContext.request.contextPath}/visitor-portal/visit-log" class="btn btn-light btn-sm rounded-3 px-3">View All</a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="bg-light text-muted" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px;">
                                    <tr>
                                        <th class="py-3 px-4 border-0">Visitor / Company</th>
                                        <th class="py-3 px-4 border-0">Purpose</th>
                                        <th class="py-3 px-4 border-0 text-center">Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty recentVisits}">
                                            <tr>
                                                <td colspan="3" class="text-center py-5 text-muted italic">
                                                    No recent activity recorded.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="v" items="${recentVisits}">
                                                <tr>
                                                    <td class="px-4 py-3">
                                                        <div class="fw-bold text-dark">${v.visitorName}</div>
                                                        <div class="small text-muted">${v.company}</div>
                                                    </td>
                                                    <td class="px-4 py-3">
                                                        <div class="text-truncate" style="max-width: 250px;">${v.purposeOfVisit}</div>
                                                        <div class="small text-muted">${v.visitDate}</div>
                                                    </td>
                                                    <td class="px-4 py-3 text-center">
                                                        <c:choose>
                                                            <c:when test="${v.status == 'ACTIVE'}">
                                                                <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25 rounded-pill px-3 py-2">Active</span>
                                                            </c:when>
                                                            <c:when test="${v.status == 'APPROVED'}">
                                                                <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 rounded-pill px-3 py-2">Awaiting</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-slate-200 text-slate-600 rounded-pill px-3 py-2" style="background:#e2e8f0; color:#475569;">${v.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Side Alerts Section -->
            <div class="${isTech ? 'col-xl-4' : 'col-xl-3'}">
                <div class="card border-0 shadow-sm rounded-4 h-100 bg-white overflow-hidden">
                    <div class="card-header bg-white p-4 border-0 border-bottom border-light">
                        <h6 class="fw-bold mb-0 text-dark text-uppercase small" style="letter-spacing:1px;">Security Brief</h6>
                    </div>
                    <div class="card-body p-4">
                        <div class="mb-4">
                            <div class="small text-muted mb-2 fw-bold text-uppercase" style="font-size: 0.65rem;">System Health</div>
                            <div class="d-flex align-items-center">
                                <div class="bg-success rounded-circle me-2" style="width: 8px; height: 8px;"></div>
                                <span class="small fw-semibold">Data Center Online</span>
                            </div>
                        </div>
                        <div class="bg-primary bg-opacity-5 p-3 rounded-4 border border-primary border-opacity-10 mb-4">
                            <div class="d-flex mb-2">
                                <i class="bi bi-info-circle-fill text-primary me-2"></i>
                                <span class="small fw-bold">Live Assignments</span>
                            </div>
                            <p class="small text-muted mb-0">Assignments are automatically updated. Check notifications for arrivals.</p>
                        </div>
                        <div class="d-grid gap-2">
                            <a href="${pageContext.request.contextPath}/visitor-portal/notifications" class="btn btn-outline-primary btn-sm rounded-3 py-2 fw-bold">
                                <i class="bi bi-broadcast me-2"></i>View Notifications
                            </a>
                            <c:if test="${isTech}">
                                <a href="${pageContext.request.contextPath}/visitor-portal/report-incident" class="btn btn-danger btn-sm rounded-3 py-2 fw-bold shadow-sm">
                                    <i class="bi bi-exclamation-triangle me-2"></i>Report Policy Violation
                                </a>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        .hover-up:hover { transform: translateY(-5px); box-shadow: 0 1rem 3rem rgba(0,0,0,0.1) !important; }
        .transition-300 { transition: all 0.3s ease-in-out; }
        .fw-black { font-weight: 800; }
        .p-5 { padding: 3rem !important; }
        .rounded-5 { border-radius: 2rem !important; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
