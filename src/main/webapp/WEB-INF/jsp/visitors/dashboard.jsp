<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Visitor Monitoring Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .dashboard-card { border-radius: 10px; padding: 20px; color: white; margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .bg-active { background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%); }
        .bg-overstay { background: linear-gradient(135deg, #dc3545 0%, #b02a37 100%); }
        .dashboard-card h3 { margin: 0; font-size: 2.5rem; font-weight: 700; }
        .dashboard-card p { margin: 0; font-size: 1.1rem; opacity: 0.9; }
        .table-container { background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 25px;}
        .section-title { font-weight: 600; color: #333; margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <h4 style="font-weight:700;margin-bottom:25px;"><i class="bi bi-speedometer"></i> Visitor Monitoring Dashboard</h4>
        
        <!-- Summary Cards -->
        <div class="row">
            <div class="col-md-6 col-lg-4">
                <div class="dashboard-card bg-active">
                    <h3>${activeVisitors.size()}</h3>
                    <p>Current Active Visitors</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-4">
                <div class="dashboard-card bg-overstay">
                    <h3>${overstayedVisitors.size()}</h3>
                    <p>Overstayed Visitors</p>
                </div>
            </div>
        </div>

        <!-- Real-Time Monitoring -->
        <div class="row">
            <div class="col-lg-6">
                <div class="table-container">
                    <h5 class="section-title text-primary"><i class="bi bi-broadcast"></i> Active Visitors</h5>
                    <table class="table table-hover align-middle">
                        <thead><tr><th>Name</th><th>Badge</th><th>Check-In</th><th>Duration</th></tr></thead>
                        <tbody>
                            <c:if test="${empty activeVisitors}"><tr><td colspan="4" class="text-muted text-center">No active visitors.</td></tr></c:if>
                            <c:forEach var="v" items="${activeVisitors}">
                            <tr>
                                <td><strong>${v.visitor.fullName}</strong><br><small class="text-muted">${v.visitor.company}</small></td>
                                <td><span class="badge bg-secondary">${v.temporaryBadge}</span></td>
                                <td>
                                    <fmt:parseDate value="${v.checkInTime}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedCIT" type="both" />
                                    <fmt:formatDate pattern="HH:mm" value="${parsedCIT}" />
                                </td>
                                <td><span class="badge bg-info text-dark">${durationStrings[v.checkId]}</span></td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="col-lg-6">
                <div class="table-container">
                    <h5 class="section-title text-danger"><i class="bi bi-exclamation-triangle-fill"></i> Overstayed Visitors</h5>
                    <table class="table table-hover align-middle">
                        <thead><tr><th>Name</th><th>Badge</th><th>Check-In</th><th>Escort</th></tr></thead>
                        <tbody>
                            <c:if test="${empty overstayedVisitors}"><tr><td colspan="4" class="text-muted text-center">No overstayed visitors.</td></tr></c:if>
                            <c:forEach var="v" items="${overstayedVisitors}">
                            <tr class="table-danger">
                                <td><strong>${v.visitor.fullName}</strong></td>
                                <td><span class="badge bg-dark">${v.temporaryBadge}</span></td>
                                <td>
                                    <fmt:parseDate value="${v.checkInTime}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedOvtCIT" type="both" />
                                    <fmt:formatDate pattern="HH:mm" value="${parsedOvtCIT}" />
                                </td>
                                <td>${v.escort.fullName}</td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- History & Analytics -->
        <div class="row">
            <div class="col-lg-8">
                <div class="table-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="section-title mb-0" style="border:none;"><i class="bi bi-clock-history"></i> Visit History</h5>
                        <form class="d-flex gap-2" action="${pageContext.request.contextPath}/visitors/dashboard" method="get">
                            <input type="date" name="startDate" class="form-control form-control-sm" value="${startDate}">
                            <input type="date" name="endDate" class="form-control form-control-sm" value="${endDate}">
                            <button class="btn btn-sm btn-outline-primary" type="submit">Filter</button>
                        </form>
                    </div>
                    <table class="table table-sm table-striped">
                        <thead><tr><th>Name</th><th>Date</th><th>In</th><th>Out</th><th>Escort</th></tr></thead>
                        <tbody>
                            <c:if test="${empty visitHistory}"><tr><td colspan="5" class="text-muted text-center">No history found for this range.</td></tr></c:if>
                            <c:forEach var="v" items="${visitHistory}">
                            <tr>
                                <td>${v.visitor.fullName}</td>
                                <td>
                                    <fmt:parseDate value="${v.checkInTime}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedHistDate" type="both" />
                                    <fmt:formatDate pattern="yyyy-MM-dd" value="${parsedHistDate}" />
                                </td>
                                <td>
                                    <fmt:formatDate pattern="HH:mm" value="${parsedHistDate}" />
                                </td>
                                <td>
                                    <fmt:parseDate value="${v.checkOutTime}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedHistOut" type="both" />
                                    <fmt:formatDate pattern="HH:mm" value="${parsedHistOut}" />
                                </td>
                                <td>${v.escort.fullName}</td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="col-lg-4">
                <div class="table-container">
                    <h5 class="section-title text-success"><i class="bi bi-graph-up-arrow"></i> High-Frequency Visitors</h5>
                    <ul class="list-group list-group-flush">
                        <c:if test="${empty highFrequencyVisitors}"><li class="list-group-item text-muted text-center">No data available.</li></c:if>
                        <c:forEach var="row" items="${highFrequencyVisitors}">
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>${row[0].fullName}</strong><br>
                                    <small class="text-muted">${row[0].company}</small>
                                </div>
                                <span class="badge bg-primary rounded-pill">${row[1]} visits</span>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
        </div>

    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
