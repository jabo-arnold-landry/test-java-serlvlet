<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Active Visitors</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/visitor-header.jsp"/>
    <style>
        .duration-badge { font-size: 0.85rem; font-weight: 600; letter-spacing: 0.5px; }
    </style>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="active" />
    </jsp:include>

    <div class="vp-content-area" style="background: #f1f5f9; min-height: 100vh;">
        <div class="container-fluid py-5">
            <!-- Alert messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success border-0 shadow-lg rounded-4 p-4 mb-5 d-flex align-items-center">
                    <div class="p-3 bg-success bg-opacity-20 rounded-circle me-4">
                        <i class="bi bi-check-lg fs-4 text-success"></i>
                    </div>
                    <div>
                        <h5 class="alert-heading fw-bold mb-1">Session Update</h5>
                        <p class="mb-0 small">${success}</p>
                    </div>
                </div>
            </c:if>

            <!-- Page Header -->
            <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
            <div class="d-flex align-items-center justify-content-between mb-5">
                <div>
                    <h2 class="fw-black text-slate-900 mb-1" style="color: #0f172a;">${isTech ? 'Active Escorts' : 'Live Facility Traffic'}</h2>
                    <p class="text-slate-500 mb-0">
                        ${isTech ? 'Real-time tracking of visitors currently under your protocol supervision' : 'Monitor live visitor dispersion and manage session termination protocols'}
                    </p>
                </div>
                <div class="d-none d-md-flex align-items-center bg-white p-3 rounded-4 shadow-sm border border-light">
                    <div class="me-4 text-end">
                        <div class="small fw-black text-slate-400 text-uppercase" style="letter-spacing: 1px;">Live Count</div>
                        <div class="h4 fw-black text-primary mb-0">${activeVisitors.size()}</div>
                    </div>
                    <div class="p-3 bg-primary bg-opacity-10 rounded-3 text-primary">
                        <i class="bi bi-broadcast fs-4"></i>
                    </div>
                </div>
            </div>

            <!-- Active Visitors Table -->
            <div class="card border-0 shadow-sm rounded-5 overflow-hidden">
                <div class="card-header bg-white p-4 border-0 border-bottom border-light">
                    <div class="d-flex align-items-center">
                        <div class="bg-success bg-opacity-10 p-2 rounded-3 text-success me-3">
                            <i class="bi bi-person-walking fs-5"></i>
                        </div>
                        <h5 class="fw-bold mb-0 text-slate-800">Active Sessions</h5>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr class="bg-slate-50">
                                    <th class="ps-4 py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Visitor</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Company</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Purpose</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Check-In Time</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Location</th>
                                    <c:if test="${!isTech}">
                                        <th class="pe-4 py-4 text-end text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Protocol</th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty activeVisitors}">
                                        <tr>
                                            <td colspan="${isTech ? 5 : 6}" class="text-center py-5">
                                                <div class="p-5">
                                                    <i class="bi bi-radar fs-1 text-slate-200 mb-3 d-block"></i>
                                                    <p class="text-slate-400 fw-medium">All sessions terminated. No active visitor signals detected.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="v" items="${activeVisitors}">
                                            <tr>
                                                <td class="ps-4 py-4">
                                                    <div class="d-flex align-items-center">
                                                        <div class="p-2 bg-slate-100 rounded-circle me-3">
                                                            <i class="bi bi-person text-slate-500"></i>
                                                        </div>
                                                        <div>
                                                            <div class="fw-bold text-slate-900">${v.visitor.fullName}</div>
                                                            <div class="small fw-bold text-primary">ID: VR-${v.visitor.visitorId}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="py-4">
                                                    <span class="text-slate-600 fw-medium">${v.visitor.company}</span>
                                                </td>
                                                <td class="py-4">
                                                    <span class="badge bg-slate-100 text-slate-600 border border-slate-200 px-3 py-2 rounded-pill small">
                                                        ${v.visitor.purposeOfVisit}
                                                    </span>
                                                </td>
                                                <td class="py-4">
                                                    <div class="text-slate-800 fw-bold">${v.checkInTime.toLocalTime().toString().substring(0, 5)}</div>
                                                    <div class="small text-slate-400">${v.checkInTime.toLocalDate()}</div>
                                                </td>
                                                <td class="py-4">
                                                    <span class="badge bg-indigo-50 text-indigo-500 border border-indigo-100 px-3 py-2 rounded-3">
                                                        <i class="bi bi-building me-2"></i>${v.visitor.departmentToVisit}
                                                    </span>
                                                </td>
                                                <td class="pe-4 py-4 text-end">
                                                    <c:choose>
                                                        <c:when test="${isTech}">
                                                            <a href="${pageContext.request.contextPath}/visitor-portal/report-incident?visitorId=${v.visitor.visitorId}" 
                                                               class="btn btn-outline-danger btn-sm rounded-3 px-3 py-2 fw-bold hover-lift transition-300">
                                                                <i class="bi bi-exclamation-octagon me-1"></i>REPORT
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn btn-warning text-white px-4 py-2 rounded-4 fw-black shadow-sm hover-lift transition-300" 
                                                                    data-bs-toggle="modal" data-bs-target="#checkoutModal${v.checkId}">
                                                                <i class="bi bi-box-arrow-right me-2"></i>LOG OUT
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>

                                            <!-- CHECK-OUT MODAL (Redesigned) -->
                                            <div class="modal fade" id="checkoutModal${v.checkId}" tabindex="-1">
                                                <div class="modal-dialog modal-dialog-centered">
                                                    <div class="modal-content border-0 shadow-lg rounded-5 overflow-hidden">
                                                        <div class="modal-header bg-warning p-4 border-0">
                                                            <h5 class="modal-title fw-black">Session Termination</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <form action="${pageContext.request.contextPath}/visitor-portal/checkout/${v.checkId}" method="post">
                                                            <div class="modal-body p-5">
                                                                <div class="text-center mb-4">
                                                                    <div class="p-3 bg-warning bg-opacity-10 text-warning rounded-circle inline-block mb-3">
                                                                        <i class="bi bi-exclamation-triangle fs-2"></i>
                                                                    </div>
                                                                    <h6 class="fw-bold text-slate-900">Finalizing visit for ${v.visitor.fullName}</h6>
                                                                    <p class="small text-slate-500">Duration documented: ${durationMap[v.checkId]}</p>
                                                                </div>
                                                                <div class="space-y-3">
                                                                    <div class="p-3 border border-slate-100 bg-slate-50 rounded-4">
                                                                        <div class="form-check form-switch custom-switch">
                                                                            <input class="form-check-input" type="checkbox" name="equipmentConfirmed" id="equip${v.checkId}" value="true" checked>
                                                                            <label class="form-check-label fw-bold text-slate-700" for="equip${v.checkId}">All Equipment Recovered</label>
                                                                        </div>
                                                                    </div>
                                                                    <div class="p-3 border border-slate-100 bg-slate-50 rounded-4 mt-3">
                                                                        <div class="form-check form-switch custom-switch">
                                                                            <input class="form-check-input" type="checkbox" name="badgeReturned" id="badge${v.checkId}" value="true" checked>
                                                                            <label class="form-check-label fw-bold text-slate-700" for="badge${v.checkId}">Access Badge Deactivated</label>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer p-4 border-0">
                                                                <button type="button" class="btn btn-slate-100 text-slate-600 px-4 py-3 rounded-4 fw-bold" data-bs-dismiss="modal">CANCEL</button>
                                                                <button type="submit" class="btn btn-warning text-white px-4 py-3 rounded-4 fw-black shadow-lg">CONFIRM DEPARTURE</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        .fw-black { font-weight: 800; }
        .text-slate-900 { color: #0f172a; }
        .text-slate-800 { color: #1e293b; }
        .text-slate-700 { color: #334155; }
        .text-slate-600 { color: #475569; }
        .text-slate-500 { color: #64748b; }
        .text-slate-400 { color: #94a3b8; }
        .bg-slate-50 { background-color: #f8fafc; }
        .rounded-5 { border-radius: 1.5rem !important; }
        .text-indigo-500 { color: #6366f1; }
        .bg-indigo-50 { background-color: #eef2ff; }
        .border-indigo-100 { border-color: #e0e7ff; }
        .transition-300 { transition: all 0.3s ease; }
        .hover-lift:hover { transform: translateY(-3px); }
        .custom-switch .form-check-input { width: 3rem; height: 1.5rem; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
