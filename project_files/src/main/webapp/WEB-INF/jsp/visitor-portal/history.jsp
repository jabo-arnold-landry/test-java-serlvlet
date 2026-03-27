<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Visit History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/visitor-header.jsp"/>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="history" />
    </jsp:include>

    <div class="vp-content-area" style="background: #f1f5f9; min-height: 100vh;">
        <div class="container-fluid py-5">
            <!-- Page Header -->
            <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
            <div class="d-flex align-items-center justify-content-between mb-5">
                <div>
                    <h2 class="fw-black text-slate-900 mb-1" style="color: #0f172a;">${isTech ? 'Personal Visit Archive' : 'Global Audit Log'}</h2>
                    <p class="text-slate-500 mb-0">
                        ${isTech ? 'Historical record of protocol escorts completed under your authorization' : 'Comprehensive timeline of facility security interactions and session metadata'}
                    </p>
                </div>
                <div class="d-none d-md-block">
                    <a href="${pageContext.request.contextPath}/visitor-portal/history/export-pdf" class="btn btn-white border border-light text-slate-600 px-4 py-3 rounded-4 shadow-sm fw-bold">
                        <i class="bi bi-download me-2"></i>EXPORT LOGS
                    </a>
                </div>
            </div>

            <!-- History Table -->
            <div class="card border-0 shadow-sm rounded-5 overflow-hidden">
                <div class="card-header bg-white p-4 border-0 border-bottom border-light">
                    <div class="d-flex align-items-center">
                        <div class="p-2 bg-slate-900 rounded-3 text-white me-3">
                            <i class="bi bi-archive fs-5"></i>
                        </div>
                        <h5 class="fw-bold mb-0 text-slate-800">Visit Logs</h5>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr class="bg-slate-50">
                                    <th class="ps-4 py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Visitor Name</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Company</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Purpose</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Visit Date</th>
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Final Status</th>
                                    <c:if test="${!isTech}">
                                        <th class="pe-4 py-4 text-end text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Authorized By</th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty pastVisits}">
                                        <tr>
                                            <td colspan="${isTech ? 5 : 6}" class="text-center py-5">
                                                <div class="p-5">
                                                    <i class="bi bi-journal-x fs-1 text-slate-200 mb-3 d-block"></i>
                                                    <p class="text-slate-400 fw-medium">Archive is empty. No historical sessions recorded.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="v" items="${pastVisits}">
                                            <tr>
                                                <td class="ps-4 py-4">
                                                    <div class="fw-bold text-slate-900">${v.visitor.fullName}</div>
                                                    <div class="small font-monospace text-slate-400">#VR-${v.visitor.visitorId}</div>
                                                </td>
                                                <td class="py-4 text-slate-600 fw-medium">${v.visitor.company}</td>
                                                <td class="py-4">
                                                    <span class="badge bg-slate-100 text-slate-600 border border-slate-200 px-3 py-2 rounded-pill small fw-medium">
                                                        ${v.visitor.purposeOfVisit}
                                                    </span>
                                                </td>
                                                <td class="py-4">
                                                    <div class="text-slate-700 fw-bold">${v.visitor.visitDate}</div>
                                                    <div class="small text-slate-400">${v.checkInTime.toLocalTime().toString().substring(0, 5)} - ${v.checkOutTime.toLocalTime().toString().substring(0, 5)}</div>
                                                </td>
                                                <td class="py-4">
                                                    <span class="badge bg-slate-900 text-white rounded-pill px-3 py-2 fw-black small" style="background: #0f172a;">
                                                        CLOSED
                                                    </span>
                                                </td>
                                                <c:if test="${!isTech}">
                                                    <td class="pe-4 py-4 text-end">
                                                        <div class="d-flex align-items-center justify-content-end">
                                                            <div class="me-2 text-end">
                                                                <div class="small fw-bold text-slate-800">${v.escort.fullName}</div>
                                                                <div class="small text-slate-400">Protocol Escort</div>
                                                            </div>
                                                            <div class="p-2 bg-slate-100 rounded-circle"><i class="bi bi-shield-check text-slate-500"></i></div>
                                                        </div>
                                                    </td>
                                                </c:if>
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
        .bg-white { background-color: #ffffff !important; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
