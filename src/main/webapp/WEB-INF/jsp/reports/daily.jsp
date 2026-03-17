<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>SPCMS - Daily Consolidated Report</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                    rel="stylesheet">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <jsp:include page="../common/styles.jsp" />
                <style>
                    .report-metric {
                        text-align: center;
                    }

                    .report-metric .metric-value {
                        font-size: 2rem;
                        font-weight: 700;
                        margin: 6px 0;
                    }

                    .report-metric .metric-label {
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                        color: #888;
                    }

                    .date-picker-form {
                        display: flex;
                        gap: 10px;
                        align-items: center;
                    }

                    .section-title {
                        font-size: 13px;
                        font-weight: 700;
                        letter-spacing: 0.08em;
                        text-transform: uppercase;
                        color: #e74c3c;
                        border-bottom: 1px solid rgba(255, 255, 255, 0.07);
                        padding-bottom: 8px;
                        margin-bottom: 16px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="../common/sidebar.jsp" />
                <jsp:include page="../common/topbar.jsp" />
                <div class="main-content">

                    <%-- Flash messages --%>
                        <c:if test="${not empty success}">
                            <div class="alert alert-success alert-dismissible fade show">
                                <i class="bi bi-check-circle-fill me-2"></i>${success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <%-- Header --%>
                            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                                <div>
                                    <h4 style="font-weight:700;margin:0;"><i
                                            class="bi bi-file-earmark-bar-graph text-primary me-2"></i>Daily
                                        Consolidated Report</h4>
                                    <p class="text-muted mb-0" style="font-size:14px;">
                                        <c:choose>
                                            <c:when test="${selectedDate != null}">Viewing report for:
                                                <strong>${selectedDate}</strong></c:when>
                                            <c:otherwise>Select a date to view or generate a report</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                                <%-- Date Picker Form --%>
                                    <form action="${pageContext.request.contextPath}/reports" method="get"
                                        class="date-picker-form">
                                        <label class="form-label mb-0 text-muted"
                                            style="font-size:13px;white-space:nowrap;">Select Date:</label>
                                        <input type="date" class="form-control" name="date" id="reportDate"
                                            value="${selectedDate}" max="${pageContext.request.getAttribute('today')}"
                                            style="width:160px;" />
                                        <button type="submit" class="btn btn-outline-primary btn-sm">
                                            <i class="bi bi-search"></i> View
                                        </button>
                                        <a href="${pageContext.request.contextPath}/reports/generate<c:if test="
                                            ${selectedDate !=null}">?date=${selectedDate}</c:if>"
                                            class="btn btn-primary btn-sm">
                                            <i class="bi bi-arrow-clockwise"></i> Generate
                                        </a>
                                    </form>
                            </div>

                            <c:choose>
                                <c:when test="${report != null}">

                                    <%-- KPI Stats Row --%>
                                        <div class="row g-3 mb-4">
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">MTTR</div>
                                                    <div class="metric-value text-primary">${report.mttrMinutes != null
                                                        ? report.mttrMinutes : 0}</div>
                                                    <div class="text-muted" style="font-size:12px;">minutes</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">MTBF</div>
                                                    <div class="metric-value text-success">${report.mtbfHours != null ?
                                                        report.mtbfHours : 0}</div>
                                                    <div class="text-muted" style="font-size:12px;">hours</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">Avg Load</div>
                                                    <div class="metric-value">${report.avgDailyLoad != null ?
                                                        report.avgDailyLoad : 0}%</div>
                                                    <div class="text-muted" style="font-size:12px;">capacity</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="stat-card report-metric">
                                                    <div class="metric-label">Max Temp</div>
                                                    <div class="metric-value text-danger">${report.highestTempRecorded
                                                        != null ? report.highestTempRecorded : 0}°C</div>
                                                    <div class="text-muted" style="font-size:12px;">recorded</div>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- Incident Summary --%>
                                            <div class="row g-3 mb-4">
                                                <div class="col-md-6">
                                                    <div class="stat-card">
                                                        <p class="section-title"><i
                                                                class="bi bi-exclamation-octagon me-1"></i>Incident
                                                            Summary</p>
                                                        <table class="table table-borderless mb-0"
                                                            style="font-size:14px;">
                                                            <tr>
                                                                <td class="text-muted">Total Incidents</td>
                                                                <td><strong>${report.totalIncidents != null ?
                                                                        report.totalIncidents : 0}</strong></td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Total Downtime</td>
                                                                <td><strong
                                                                        class="text-danger">${report.totalDowntimeMin !=
                                                                        null ? report.totalDowntimeMin : 0} min</strong>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Critical Incidents</td>
                                                                <td><strong
                                                                        class="text-danger">${report.criticalIncidents
                                                                        != null ? report.criticalIncidents : 0}</strong>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="stat-card">
                                                        <p class="section-title"><i
                                                                class="bi bi-people me-1"></i>Visitor Summary</p>
                                                        <table class="table table-borderless mb-0"
                                                            style="font-size:14px;">
                                                            <tr>
                                                                <td class="text-muted">Total Visitors</td>
                                                                <td><strong>${report.totalVisitors != null ?
                                                                        report.totalVisitors : 0}</strong></td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Overstayed</td>
                                                                <td><strong
                                                                        class="text-warning">${report.overstayedVisitors
                                                                        != null ? report.overstayedVisitors :
                                                                        0}</strong></td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Report Actions --%>
                                                <div class="d-flex gap-2">
                                                    <a href="${pageContext.request.contextPath}/reports/generate?date=${selectedDate}"
                                                        class="btn btn-outline-primary">
                                                        <i class="bi bi-arrow-clockwise"></i> Regenerate Report
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/reports/range"
                                                        class="btn btn-outline-secondary">
                                                        <i class="bi bi-calendar-range"></i> Date Range Report
                                                    </a>
                                                </div>

                                </c:when>
                                <c:otherwise>
                                    <%-- No Report State --%>
                                        <div class="stat-card text-center py-5">
                                            <i class="bi bi-file-earmark-x fs-1 text-muted d-block mb-3"></i>
                                            <h5 style="font-weight:600;">No Report Found</h5>
                                            <p class="text-muted mb-4">
                                                No report has been generated for
                                                <strong>${selectedDate != null ? selectedDate : 'today'}</strong> yet.
                                            </p>
                                            <a href="${pageContext.request.contextPath}/reports/generate<c:if test="
                                                ${selectedDate !=null}">?date=${selectedDate}</c:if>"
                                                class="btn btn-primary">
                                                <i class="bi bi-play-circle"></i> Generate Report Now
                                            </a>
                                        </div>
                                </c:otherwise>
                            </c:choose>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    // Set today as default date if none is selected
                    const dateInput = document.getElementById('reportDate');
                    if (!dateInput.value) {
                        dateInput.value = new Date().toISOString().split('T')[0];
                    }
                    dateInput.max = new Date().toISOString().split('T')[0];
                </script>
            </body>

            </html>