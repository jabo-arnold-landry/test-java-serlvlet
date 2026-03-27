<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Notifications</title>
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
                <jsp:param name="pageName" value="notifications" />
            </jsp:include>
            <div class="row justify-content-center">
                <div class="col-xl-8 col-lg-10">
                    <!-- Page Header -->
                    <div class="d-flex align-items-center justify-content-between mb-5">
                        <div>
                            <h2 class="fw-black text-slate-900 mb-1" style="color: #0f172a;">Notifications</h2>
                            <p class="text-slate-500 mb-0">System alerts and assignment updates for your station</p>
                        </div>
                        <div class="d-none d-md-block text-end">
                            <span class="badge bg-white text-muted border border-light px-3 py-2 rounded-3 shadow-sm mb-1">
                                <i class="bi bi-clock me-1"></i> Live Feedback
                            </span>
                            <div class="small fw-bold text-success"><i class="bi bi-circle-fill me-2" style="font-size: 0.5rem;"></i>Operational</div>
                        </div>
                    </div>

                    <div class="notification-feed">
                        <c:choose>
                            <c:when test="${empty notifications}">
                                <div class="text-center py-5">
                                    <div class="p-5 bg-white rounded-5 shadow-sm inline-block">
                                        <i class="bi bi-broadcast fs-1 text-slate-200 mb-3 d-block"></i>
                                        <h5 class="fw-bold text-slate-800 mb-1">Quiet Wavefront</h5>
                                        <p class="text-slate-400 mb-0">No active alerts at this moment.</p>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="n" items="${notifications}">
                                    <div class="notification-card hover-lift transition-300 mb-4">
                                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                                            <div class="card-body p-4 p-md-5">
                                                <div class="row align-items-center">
                                                    <div class="col-auto">
                                                        <c:choose>
                                                            <c:when test="${n.type == 'ASSIGNMENT'}">
                                                                <div class="p-4 bg-primary bg-opacity-10 text-primary rounded-4">
                                                                    <i class="bi bi-person-check-fill fs-3"></i>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${n.type == 'CHECKIN'}">
                                                                <div class="p-4 bg-success bg-opacity-10 text-success rounded-4">
                                                                    <i class="bi bi-geo-alt-fill fs-3"></i>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${n.type == 'SECURITY_ALERT'}">
                                                                <div class="p-4 bg-danger bg-opacity-10 text-danger rounded-4">
                                                                    <i class="bi bi-exclamation-octagon-fill fs-3"></i>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="p-4 bg-slate-100 text-slate-600 rounded-4">
                                                                    <i class="bi bi-info-circle-fill fs-3"></i>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="col ms-md-2">
                                                        <div class="d-flex justify-content-between align-items-start mb-1">
                                                            <h5 class="fw-bold text-slate-900 mb-0">${n.title}</h5>
                                                            <span class="small text-slate-400 fw-medium">${n.date}</span>
                                                        </div>
                                                        <p class="fs-6 text-slate-700 fw-medium mb-3">${n.content}</p>
                                                        <div class="p-3 bg-slate-50 border border-slate-100 rounded-3">
                                                            <span class="small text-slate-500 fw-bold text-uppercase d-block mb-1" style="font-size: 0.65rem; letter-spacing: 0.5px;">Protocol Details</span>
                                                            <p class="small text-slate-600 mb-0 italic">${n.details}</p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
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
        .transition-300 { transition: all 0.3s ease; }
        .hover-lift:hover { transform: translateY(-3px); }
        .rounded-5 { border-radius: 2rem !important; }
        .notification-card .card { border-left: 5px solid transparent !important; }
        .notification-card:has(.text-primary) .card { border-left-color: #3b82f6 !important; }
        .notification-card:has(.text-success) .card { border-left-color: #10b981 !important; }
        .notification-card:has(.text-danger) .card { border-left-color: #ef4444 !important; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
