<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Shift Report Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Shift Report #${report.reportId}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">${report.shiftType} Shift - ${report.shiftDate} | Staff: ${report.staff.fullName}</p>
            </div>
            <a href="${pageContext.request.contextPath}/shift-reports" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Max Load</div>
                    <div class="stat-value">${report.maxLoadPercent}%</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Highest Temp</div>
                    <div class="stat-value" style="color:${report.highestTempRecorded > 28 ? 'var(--accent-red)' : 'var(--accent-green)'}">${report.highestTempRecorded}&deg;C</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Incidents</div>
                    <div class="stat-value">${report.numIncidents}</div>
                    <div class="text-muted" style="font-size:12px;">${report.criticalIncidents} critical</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Downtime</div>
                    <div class="stat-value">${report.downtimeDurationMin}</div>
                    <div class="text-muted" style="font-size:12px;">minutes</div>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-battery-charging"></i> UPS Summary</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:45%;">Avg Input Voltage</td><td>${report.avgInputVoltage} V</td></tr>
                        <tr><td class="text-muted">Avg Output Voltage</td><td>${report.avgOutputVoltage} V</td></tr>
                        <tr><td class="text-muted">Max Load</td><td>${report.maxLoadPercent}%</td></tr>
                        <tr><td class="text-muted">Min Battery Level</td><td>${report.minBatteryLevel}%</td></tr>
                        <tr><td class="text-muted">Runtime Remaining</td><td>${report.batteryRuntimeRemaining} min</td></tr>
                        <tr><td class="text-muted">Overload Occurred</td><td>${report.overloadOccurred ? 'Yes' : 'No'}</td></tr>
                        <tr><td class="text-muted">Bypass Activated</td><td>${report.bypassActivated ? 'Yes' : 'No'}</td></tr>
                    </table>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-snow2"></i> Cooling Summary</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:45%;">Highest Temp</td><td>${report.highestTempRecorded}&deg;C</td></tr>
                        <tr><td class="text-muted">Lowest Temp</td><td>${report.lowestTempRecorded}&deg;C</td></tr>
                        <tr><td class="text-muted">Avg Humidity</td><td>${report.avgHumidity}%</td></tr>
                        <tr><td class="text-muted">Compressor Status</td><td>${report.compressorStatus}</td></tr>
                        <tr><td class="text-muted">High Temp Alarm</td><td>${report.highTempAlarm ? 'Yes' : 'No'}</td></tr>
                        <tr><td class="text-muted">Humidity Alarm</td><td>${report.humidityAlarm ? 'Yes' : 'No'}</td></tr>
                    </table>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-exclamation-triangle"></i> Incidents</h6>
                    <p style="font-size:14px;"><strong>Root Cause:</strong> ${report.rootCauseSummary != null ? report.rootCauseSummary : 'None'}</p>
                    <p style="font-size:14px;"><strong>Action Taken:</strong> ${report.actionTaken != null ? report.actionTaken : 'None'}</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-person-badge"></i> Visitors</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted">Total Visitors</td><td>${report.numVisitors}</td></tr>
                        <tr><td class="text-muted">Approved By</td><td>${report.visitorApprovedBy}</td></tr>
                        <tr><td class="text-muted">Escort</td><td>${report.escortName}</td></tr>
                    </table>
                </div>
            </div>
        </div>

        <div class="stat-card mb-4">
            <h6 class="fw-bold mb-3"><i class="bi bi-journal-text"></i> Handover Notes</h6>
            <c:forEach var="note" items="${handoverNotes}">
            <div class="border rounded p-3 mb-2">
                <p style="font-size:14px;"><strong>System Status:</strong> ${note.systemStatusSummary}</p>
                <p style="font-size:14px;"><strong>Pending Issues:</strong> ${note.pendingIssues}</p>
                <p style="font-size:14px;" class="mb-0"><strong>Recommendations:</strong> ${note.recommendations}</p>
                <small class="text-muted">Added: ${note.createdAt}</small>
            </div>
            </c:forEach>
            <c:if test="${empty handoverNotes}">
            <p class="text-muted">No handover notes yet.</p>
            </c:if>

            <hr/>
            <h6 class="fw-bold mb-3">Add Handover Note</h6>
            <form action="${pageContext.request.contextPath}/shift-reports/handover/${report.reportId}" method="post">
                <div class="row g-3 mb-3">
                    <div class="col-12">
                        <label class="form-label">System Status Summary <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="systemStatusSummary" rows="2" required></textarea>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Pending Issues</label>
                        <textarea class="form-control" name="pendingIssues" rows="2"></textarea>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Recommendations</label>
                        <textarea class="form-control" name="recommendations" rows="2"></textarea>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary"><i class="bi bi-plus-lg"></i> Add Handover Note</button>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
