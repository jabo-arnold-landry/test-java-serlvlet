<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Incident Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .report-header {
            background: linear-gradient(135deg, #1e3a5f 0%, #0f2744 100%);
            border-radius: 16px;
            padding: 28px 32px;
            color: #fff;
            margin-bottom: 24px;
            border: 1px solid rgba(59, 130, 246, 0.3);
        }
        .report-header h4 { font-weight: 700; margin: 0; }
        .report-header p { color: rgba(255,255,255,0.7); margin: 4px 0 0; font-size: 14px; }

        .kpi-card {
            background: var(--card-bg);
            border-radius: 14px;
            padding: 22px 20px;
            border: 1px solid #e5e7eb;
            text-align: center;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .kpi-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            border-radius: 14px 14px 0 0;
        }
        .kpi-card.kpi-total::before   { background: linear-gradient(90deg, #3b82f6, #60a5fa); }
        .kpi-card.kpi-resolved::before { background: linear-gradient(90deg, #10b981, #34d399); }
        .kpi-card.kpi-open::before     { background: linear-gradient(90deg, #ef4444, #f87171); }
        .kpi-card.kpi-downtime::before { background: linear-gradient(90deg, #f59e0b, #fbbf24); }

        .kpi-card:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
        .kpi-value { font-size: 2.2rem; font-weight: 800; line-height: 1; margin: 10px 0 6px; }
        .kpi-label { font-size: 11px; text-transform: uppercase; letter-spacing: 1.2px; color: #6b7280; font-weight: 600; }
        .kpi-icon { font-size: 28px; opacity: 0.15; position: absolute; top: 14px; right: 16px; }

        .section-title {
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            padding-bottom: 10px;
            margin-bottom: 16px;
            border-bottom: 2px solid #e5e7eb;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .section-title i { font-size: 16px; }

        .dept-bar {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 18px;
            border-radius: 10px;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            margin-bottom: 10px;
            transition: all 0.2s;
        }
        .dept-bar:hover { background: #f0f4ff; border-color: #c7d2fe; }
        .dept-icon {
            width: 42px; height: 42px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; color: #fff; flex-shrink: 0;
        }
        .dept-icon.ups     { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .dept-icon.cooling { background: linear-gradient(135deg, #06b6d4, #0891b2); }
        .dept-icon.other   { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }
        .dept-name { font-weight: 600; font-size: 14px; color: #1f2937; }
        .dept-count {
            margin-left: auto;
            font-size: 1.5rem;
            font-weight: 800;
            color: #3b82f6;
        }
        .dept-progress {
            flex-grow: 1;
            height: 8px;
            border-radius: 4px;
            background: #e5e7eb;
            overflow: hidden;
            min-width: 80px;
        }
        .dept-progress-fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.6s ease;
        }

        .incident-table th { font-size: 11px !important; }
        .incident-table td { font-size: 13px !important; }

        .date-picker-form {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #9ca3af;
        }
        .empty-state i { font-size: 3rem; margin-bottom: 12px; display: block; opacity: 0.3; }

        .print-btn { transition: all 0.2s; }
        .print-btn:hover { transform: scale(1.05); }

        @media print {
            .sidebar, .topbar, .no-print { display: none !important; }
            .main-content { margin: 0 !important; padding: 15px !important; }
            .kpi-card:hover { transform: none; box-shadow: none; }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">

        <%-- Report Header --%>
        <div class="report-header d-flex justify-content-between align-items-center flex-wrap gap-3">
            <div>
                <h4><i class="bi bi-clipboard2-data me-2"></i>Incident Report</h4>
                <p><i class="bi bi-calendar3 me-1"></i>Report for: <strong style="color:#60a5fa;">${selectedDate}</strong></p>
            </div>
            <div class="d-flex gap-2 align-items-center no-print">
                <form action="${pageContext.request.contextPath}/incidents/report" method="get" class="date-picker-form">
                    <input type="date" class="form-control form-control-sm" name="date" id="reportDate"
                           value="${selectedDate}" style="width:155px;background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.25);color:#fff;"/>
                    <button type="submit" class="btn btn-sm btn-outline-light">
                        <i class="bi bi-search"></i> View
                    </button>
                </form>
                <button onclick="window.print()" class="btn btn-sm btn-light print-btn">
                    <i class="bi bi-printer me-1"></i>Print
                </button>
                <a href="${pageContext.request.contextPath}/incidents" class="btn btn-sm btn-outline-light">
                    <i class="bi bi-arrow-left"></i> Back
                </a>
            </div>
        </div>

        <%-- KPI Cards --%>
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="kpi-card kpi-total">
                    <i class="bi bi-exclamation-triangle-fill kpi-icon"></i>
                    <div class="kpi-label">Total Incidents</div>
                    <div class="kpi-value" style="color:#3b82f6;">${totalCount}</div>
                    <div class="text-muted" style="font-size:12px;">on ${selectedDate}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card kpi-resolved">
                    <i class="bi bi-check-circle-fill kpi-icon"></i>
                    <div class="kpi-label">Resolved</div>
                    <div class="kpi-value" style="color:#10b981;">${resolvedCount}</div>
                    <div class="text-muted" style="font-size:12px;">incident(s) closed</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card kpi-open">
                    <i class="bi bi-exclamation-octagon-fill kpi-icon"></i>
                    <div class="kpi-label">Open / In Progress</div>
                    <div class="kpi-value" style="color:#ef4444;">${openCount + inProgressCount}</div>
                    <div class="text-muted" style="font-size:12px;">${criticalCount} critical</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card kpi-downtime">
                    <i class="bi bi-stopwatch-fill kpi-icon"></i>
                    <div class="kpi-label">Total Downtime</div>
                    <div class="kpi-value" style="color:#f59e0b;">${totalDowntime}</div>
                    <div class="text-muted" style="font-size:12px;">minutes</div>
                </div>
            </div>
        </div>

        <div class="row g-4">

            <%-- ===== SECTION 1: ALL INCIDENTS TODAY ===== --%>
            <div class="col-lg-8">
                <div class="stat-card">
                    <div class="section-title">
                        <i class="bi bi-list-check text-primary"></i>
                        <span>All Incidents — ${selectedDate}</span>
                        <span class="badge bg-primary ms-auto">${totalCount}</span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty todayIncidents}">
                            <div class="table-responsive">
                                <table class="table table-hover incident-table mb-0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Title</th>
                                            <th>Type</th>
                                            <th>Severity</th>
                                            <th>Status</th>
                                            <th>Downtime</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="inc" items="${todayIncidents}">
                                            <tr>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/incidents/view/${inc.incidentId}"
                                                       class="text-decoration-none fw-bold">#INC-${inc.incidentId}</a>
                                                </td>
                                                <td>${inc.title}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${inc.equipmentType == 'UPS'}">⚡ UPS</c:when>
                                                        <c:when test="${inc.equipmentType == 'COOLING'}">❄️ Cooling</c:when>
                                                        <c:otherwise>🔧 ${inc.equipmentType}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <span class="badge
                                                        ${inc.severity == 'CRITICAL' ? 'bg-danger' :
                                                          inc.severity == 'HIGH'     ? 'bg-warning text-dark' :
                                                          inc.severity == 'MEDIUM'   ? 'bg-info text-dark' : 'bg-secondary'}">
                                                        ${inc.severity}
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge
                                                        ${inc.status == 'OPEN'        ? 'bg-danger' :
                                                          inc.status == 'IN_PROGRESS' ? 'bg-primary' :
                                                          inc.status == 'RESOLVED'    ? 'bg-success' : 'bg-secondary'}">
                                                        ${inc.status}
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${inc.downtimeMinutes != null}">
                                                            <strong>${inc.downtimeMinutes}</strong>
                                                            <span class="text-muted" style="font-size:10px;">min</span>
                                                        </c:when>
                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="bi bi-inbox"></i>
                                <p class="mb-0">No incidents recorded for this date</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- ===== SECTION 2: INCIDENTS BY DEPARTMENT ===== --%>
            <div class="col-lg-4">
                <div class="stat-card mb-4">
                    <div class="section-title">
                        <i class="bi bi-pie-chart-fill text-info"></i>
                        <span>By Department</span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty byDepartment}">
                            <c:forEach var="dept" items="${byDepartment}">
                                <div class="dept-bar">
                                    <div class="dept-icon ${dept[0] == 'UPS' ? 'ups' : dept[0] == 'COOLING' ? 'cooling' : 'other'}">
                                        <c:choose>
                                            <c:when test="${dept[0] == 'UPS'}"><i class="bi bi-lightning-charge-fill"></i></c:when>
                                            <c:when test="${dept[0] == 'COOLING'}"><i class="bi bi-snow2"></i></c:when>
                                            <c:otherwise><i class="bi bi-gear-fill"></i></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div>
                                        <div class="dept-name">${dept[0]}</div>
                                    </div>
                                    <div class="dept-count">${dept[1]}</div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state" style="padding:25px 10px;">
                                <i class="bi bi-diagram-3" style="font-size:2rem;"></i>
                                <p class="mb-0" style="font-size:13px;">No department data available</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- Downtime Summary Card --%>
                <div class="stat-card" style="background:linear-gradient(135deg,#fffbeb,#fef3c7);border-color:#fbbf24;">
                    <div class="section-title" style="border-color:#fde68a;">
                        <i class="bi bi-stopwatch text-warning"></i>
                        <span style="color:#92400e;">Downtime Summary</span>
                    </div>
                    <div class="text-center py-2">
                        <div style="font-size:3rem;font-weight:800;color:#d97706;">${totalDowntime}</div>
                        <div style="font-size:13px;color:#92400e;font-weight:600;">Total Minutes of Downtime</div>
                        <c:if test="${totalDowntime > 0 && totalCount > 0}">
                            <div class="mt-2" style="font-size:12px;color:#a16207;">
                                <i class="bi bi-calculator me-1"></i>
                                Average: <strong>${totalDowntime / totalCount}</strong> min per incident
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <%-- ===== SECTION 3: RESOLVED INCIDENTS ===== --%>
            <div class="col-12">
                <div class="stat-card">
                    <div class="section-title">
                        <i class="bi bi-check-circle-fill text-success"></i>
                        <span>Resolved Incidents</span>
                        <span class="badge bg-success ms-auto">${resolvedCount}</span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty resolvedIncidents}">
                            <div class="table-responsive">
                                <table class="table table-hover incident-table mb-0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Title</th>
                                            <th>Type</th>
                                            <th>Severity</th>
                                            <th>Root Cause</th>
                                            <th>Action Taken</th>
                                            <th>Downtime</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="inc" items="${resolvedIncidents}">
                                            <tr>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/incidents/view/${inc.incidentId}"
                                                       class="text-decoration-none fw-bold">#INC-${inc.incidentId}</a>
                                                </td>
                                                <td>${inc.title}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${inc.equipmentType == 'UPS'}">⚡ UPS</c:when>
                                                        <c:when test="${inc.equipmentType == 'COOLING'}">❄️ Cooling</c:when>
                                                        <c:otherwise>🔧 ${inc.equipmentType}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <span class="badge
                                                        ${inc.severity == 'CRITICAL' ? 'bg-danger' :
                                                          inc.severity == 'HIGH'     ? 'bg-warning text-dark' :
                                                          inc.severity == 'MEDIUM'   ? 'bg-info text-dark' : 'bg-secondary'}">
                                                        ${inc.severity}
                                                    </span>
                                                </td>
                                                <td style="max-width:200px;">
                                                    <span class="text-truncate d-inline-block" style="max-width:200px;" title="${inc.rootCause}">
                                                        ${not empty inc.rootCause ? inc.rootCause : '—'}
                                                    </span>
                                                </td>
                                                <td style="max-width:200px;">
                                                    <span class="text-truncate d-inline-block" style="max-width:200px;" title="${inc.actionTaken}">
                                                        ${not empty inc.actionTaken ? inc.actionTaken : '—'}
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${inc.downtimeMinutes != null}">
                                                            <strong class="text-success">${inc.downtimeMinutes}</strong>
                                                            <span class="text-muted" style="font-size:10px;">min</span>
                                                        </c:when>
                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="bi bi-emoji-neutral"></i>
                                <p class="mb-0">No resolved incidents for this date</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set today as default date and limit future dates
        const dateInput = document.getElementById('reportDate');
        if (!dateInput.value) {
            dateInput.value = new Date().toISOString().split('T')[0];
        }
        dateInput.max = new Date().toISOString().split('T')[0];
    </script>
</body>
</html>
