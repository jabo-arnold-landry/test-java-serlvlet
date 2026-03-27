<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - My Visits</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>

    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="bg-white rounded-3 p-4 shadow-sm border border-light mb-4">
            <h3 class="mb-0 text-dark fw-bold">My Active Visits</h3>
            <p class="text-muted mb-0">List of your current and upcoming visit requests</p>
        </div>

        <div class="card border-0 shadow-sm rounded-3">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="bg-light text-muted" style="font-size: 0.85rem; text-transform: uppercase;">
                            <tr>
                                <th class="py-3 px-4 fw-semibold border-0">Request ID</th>
                                <th class="py-3 px-4 fw-semibold border-0">Date</th>
                                <th class="py-3 px-4 fw-semibold border-0">Purpose</th>
                                <th class="py-3 px-4 fw-semibold border-0">Duration</th>
                                <th class="py-3 px-4 fw-semibold border-0">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty activeVisits}">
                                    <tr>
                                        <td colspan="5" class="text-center py-5 text-muted">
                                            <i class="bi bi-calendar-x fs-1 mb-2 d-block text-black-50"></i>
                                            No active or pending visit requests found.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="v" items="${activeVisits}">
                                        <tr>
                                            <td class="px-4 py-3 fw-bold text-primary">VR-${v.id}</td>
                                            <td class="px-4 py-3">${v.visitDate}</td>
                                            <td class="px-4 py-3">${v.purposeOfVisit}</td>
                                            <td class="px-4 py-3">${v.duration} hrs</td>
                                            <td class="px-4 py-3">
                                                <c:choose>
                                                    <c:when test="${v.status == 'PENDING'}">
                                                        <span class="badge bg-warning text-dark px-3 py-2 rounded-pill">Pending</span>
                                                    </c:when>
                                                    <c:when test="${v.status == 'APPROVED'}">
                                                        <span class="badge bg-success px-3 py-2 rounded-pill">Approved</span>
                                                    </c:when>
                                                    <c:when test="${v.status == 'REJECTED'}">
                                                        <span class="badge bg-danger px-3 py-2 rounded-pill">Rejected</span>
                                                    </c:when>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
