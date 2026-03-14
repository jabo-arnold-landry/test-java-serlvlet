<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Visit Log</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/visitor-header.jsp"/>
</head>
<body class="visitor-app">

    <jsp:include page="../common/visitor-sidebar.jsp">
        <jsp:param name="pageName" value="visit-log" />
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
                        <h5 class="alert-heading fw-bold mb-1">Action Successful</h5>
                        <p class="mb-0 small">${success}</p>
                    </div>
                </div>
            </c:if>

            <!-- Page Header -->
            <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
            <div class="d-flex align-items-center justify-content-between mb-5">
                <div>
                    <h2 class="fw-black text-slate-900 mb-1" style="color: #0f172a;">${isTech ? 'Assigned Visits' : 'Check-In Registry'}</h2>
                    <p class="text-slate-500 mb-0">
                        ${isTech ? 'Protocol-approved visitors pending your escort activation' : 'Authorize facility access and manage security badge issuance'}
                    </p>
                </div>
                <c:if test="${!isTech}">
                    <a href="${pageContext.request.contextPath}/visitor-portal/request" class="btn btn-primary px-4 py-3 rounded-4 fw-black shadow-lg hover-lift transition-300">
                        <i class="bi bi-plus-lg me-2"></i>INVOKE REGISTRATION
                    </a>
                </c:if>
            </div>

            <!-- Main Log Section -->
            <div class="card border-0 shadow-sm rounded-5 overflow-hidden mb-5">
                <div class="card-header bg-white p-4 border-0 border-bottom border-light">
                    <div class="d-flex align-items-center">
                        <div class="bg-primary bg-opacity-10 p-2 rounded-3 text-primary me-3">
                            <i class="bi bi-clock-history fs-5"></i>
                        </div>
                        <h5 class="fw-bold mb-0 text-slate-800">Awaiting Check-In</h5>
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
                                    <th class="py-4 text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Status</th>
                                    <c:if test="${!isTech}">
                                        <th class="pe-4 py-4 text-end text-uppercase small fw-black text-slate-400" style="letter-spacing: 1px;">Actions</th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty awaitingCheckIn}">
                                        <tr>
                                            <td colspan="${isTech ? 5 : 6}" class="text-center py-5">
                                                <i class="bi bi-inbox fs-1 text-slate-200 mb-3 d-block"></i>
                                                <p class="text-slate-400 fw-medium">No approved visitors awaiting activation in this sector.</p>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="a" items="${awaitingCheckIn}">
                                            <tr>
                                                <td class="ps-4 py-4">
                                                    <div class="fw-bold text-slate-900">${a.visitor.fullName}</div>
                                                    <div class="small text-slate-400">ID: ${a.visitor.nationalIdPassport}</div>
                                                </td>
                                                <td class="py-4">
                                                    <span class="text-slate-600 fw-medium">${a.visitor.company}</span>
                                                </td>
                                                <td class="py-4">
                                                    <span class="badge bg-slate-100 text-slate-600 border border-slate-200 px-3 py-2 rounded-pill font-monospace small">
                                                        ${a.visitor.purposeOfVisit}
                                                    </span>
                                                </td>
                                                <td class="py-4 text-slate-600">
                                                    <i class="bi bi-calendar-event me-2 text-slate-400"></i>${a.visitor.visitDate}
                                                </td>
                                                <td class="py-4">
                                                    <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3 py-2 fw-bold">
                                                        <i class="bi bi-shield-check me-1"></i>Approved
                                                    </span>
                                                </td>
                                                <c:if test="${!isTech}">
                                                    <td class="pe-4 py-4 text-end">
                                                        <button class="btn btn-slate-900 text-white px-3 py-2 rounded-3 hover-lift transition-300 me-2" 
                                                                data-bs-toggle="modal" data-bs-target="#checkinModal${a.visitor.visitorId}">
                                                            <i class="bi bi-box-arrow-in-right"></i>
                                                        </button>
                                                        <button class="btn btn-outline-danger px-3 py-2 rounded-3 hover-lift transition-300" 
                                                                data-bs-toggle="modal" data-bs-target="#deleteModal${a.visitor.visitorId}">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </td>
                                                </c:if>
                                            </tr>

                                            <!-- CHECK-IN MODAL (Redesigned) -->
                                            <div class="modal fade" id="checkinModal${a.visitor.visitorId}" tabindex="-1">
                                                <div class="modal-dialog modal-dialog-centered">
                                                    <div class="modal-content border-0 shadow-lg rounded-5 overflow-hidden">
                                                        <div class="modal-header bg-slate-900 text-white p-4 border-0">
                                                            <h5 class="modal-title fw-black">Security Activation</h5>
                                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <form action="${pageContext.request.contextPath}/visitor-portal/checkin" method="post">
                                                            <div class="modal-body p-5">
                                                                <input type="hidden" name="visitorId" value="${a.visitor.visitorId}">
                                                                <div class="mb-4">
                                                                    <label class="form-label small fw-black text-uppercase text-slate-400">Visitor Profile</label>
                                                                    <div class="p-3 bg-slate-50 rounded-4 border border-slate-100">
                                                                        <div class="fw-bold text-slate-900">${a.visitor.fullName}</div>
                                                                        <div class="small text-slate-500">${a.visitor.company} | ${a.visitor.purposeOfVisit}</div>
                                                                    </div>
                                                                </div>
                                                                <div class="mb-4">
                                                                    <label class="form-label small fw-black text-uppercase text-slate-400">Assigned Badge</label>
                                                                    <input type="text" name="badge" class="form-control border rounded-4 py-3 bg-slate-50" placeholder="e.g. VIS-SEC-001">
                                                                </div>
                                                                <div class="mb-2">
                                                                    <label class="form-label small fw-black text-uppercase text-slate-400">Protocol Escort</label>
                                                                    <select name="escortId" class="form-select border rounded-4 py-3 bg-slate-50">
                                                                        <option value="">Select Personnel...</option>
                                                                        <c:forEach var="s" items="${staffList}">
                                                                            <option value="${s.userId}">${s.fullName} (${s.role})</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer p-4 border-0">
                                                                <button type="button" class="btn btn-slate-100 text-slate-600 px-4 py-3 rounded-4 fw-bold" data-bs-dismiss="modal">CANCEL</button>
                                                                <button type="submit" class="btn btn-primary px-4 py-3 rounded-4 fw-black shadow-lg">INITIALIZE SESSION</button>
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

            <c:if test="${!isTech}">
                <!-- Secondary Section: Full Pipeline (Only for Security/Admins) -->
                ...
            </c:if>
        </div>
    </div>

    <style>
        .fw-black { font-weight: 800; }
        .text-slate-900 { color: #0f172a; }
        .text-slate-400 { color: #94a3b8; }
        .text-slate-600 { color: #475569; }
        .bg-slate-50 { background-color: #f8fafc; }
        .rounded-5 { border-radius: 1.5rem !important; }
        .transition-300 { transition: all 0.3s ease; }
        .hover-lift:hover { transform: translateY(-3px); }
        .btn-slate-900 { background: #0f172a; border: none; }
        .btn-slate-900:hover { background: #1e293b; }
    </style>

            <!-- SECTION 2: All Registrations -->
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-header bg-white border-0 py-3 px-4">
                    <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-list-ul me-2 text-primary"></i>All Visitor Registrations</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="bg-light text-muted" style="font-size:0.82rem; text-transform:uppercase;">
                                <tr>
                                    <th class="py-3 px-4 border-0">Visitor Name</th>
                                    <th class="py-3 px-4 border-0">Ref</th>
                                    <th class="py-3 px-4 border-0">Date</th>
                                    <th class="py-3 px-4 border-0">Status</th>
                                    <c:if test="${!isTech}">
                                        <th class="py-3 px-4 border-0">Actions</th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty allApprovals}">
                                        <tr><td colspan="5" class="text-center py-5 text-muted">
                                            <i class="bi bi-inbox fs-1 d-block mb-2 text-black-50"></i>No registrations yet.
                                        </td></tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="a" items="${allApprovals}">
                                            <tr>
                                                <td class="px-4 py-3 fw-semibold">${a.visitor.fullName}</td>
                                                <td class="px-4 py-3 text-primary fw-bold">VR-${a.visitor.visitorId}</td>
                                                <td class="px-4 py-3">${a.visitor.visitDate}</td>
                                                <td class="px-4 py-3">
                                                    <c:choose>
                                                        <c:when test="${a.status == 'PENDING'}"><span class="badge bg-warning text-dark rounded-pill px-3">Pending</span></c:when>
                                                        <c:when test="${a.status == 'APPROVED'}"><span class="badge bg-success rounded-pill px-3">Approved</span></c:when>
                                                        <c:when test="${a.status == 'REJECTED'}"><span class="badge bg-danger rounded-pill px-3">Rejected</span></c:when>
                                                    </c:choose>
                                                </td>
                                                <c:if test="${!isTech}">
                                                    <td class="px-4 py-3">
                                                        <a href="${pageContext.request.contextPath}/visitor-portal/edit/${a.visitor.visitorId}"
                                                           class="btn btn-sm btn-outline-primary me-1">
                                                            <i class="bi bi-pencil me-1"></i>Edit
                                                        </a>
                                                        <button class="btn btn-sm btn-outline-danger" data-bs-toggle="modal"
                                                                data-bs-target="#deleteModalAll${a.visitor.visitorId}">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </td>
                                                </c:if>
                                            </tr>

                                            <!-- DELETE MODAL for all-registrations section -->
                                            <div class="modal fade" id="deleteModalAll${a.visitor.visitorId}" tabindex="-1">
                                                <div class="modal-dialog">
                                                    <div class="modal-content rounded-4">
                                                        <div class="modal-header bg-danger text-white rounded-top-4">
                                                            <h5 class="modal-title fw-bold"><i class="bi bi-trash me-2"></i>Delete: ${a.visitor.fullName}</h5>
                                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <form action="${pageContext.request.contextPath}/visitor-portal/delete/${a.visitor.visitorId}" method="post">
                                                            <div class="modal-body">
                                                                <c:if test="${a.status == 'APPROVED'}">
                                                                    <div class="alert alert-warning border-0 rounded-3 mb-3">
                                                                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                                                                        Manager-approved visit — deletion reason will be sent to the Manager.
                                                                    </div>
                                                                </c:if>
                                                                <label class="form-label fw-semibold">Reason for Deletion <span class="text-danger">*</span></label>
                                                                <textarea name="reason" class="form-control" rows="3" required
                                                                          placeholder="e.g. Data entry error, visitor cancelled..."></textarea>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                                <button type="submit" class="btn btn-danger fw-bold">
                                                                    <i class="bi bi-trash me-1"></i>Delete Record
                                                                </button>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
