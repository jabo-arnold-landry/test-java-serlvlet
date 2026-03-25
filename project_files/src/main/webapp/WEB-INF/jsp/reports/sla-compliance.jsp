<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - SLA Compliance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Reporting &amp; Analysis</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Monitor SLA compliance for power and cooling operations</p>
            </div>
            <div class="btn-group" role="group" aria-label="Window Selector">
                <a class="btn ${windowDays == 7 ? 'btn-primary' : 'btn-outline-primary'}" href="${pageContext.request.contextPath}/reports/sla-compliance?windowDays=7">7 days</a>
                <a class="btn ${windowDays == 14 ? 'btn-primary' : 'btn-outline-primary'}" href="${pageContext.request.contextPath}/reports/sla-compliance?windowDays=14">14 days</a>
                <a class="btn ${windowDays == 30 ? 'btn-primary' : 'btn-outline-primary'}" href="${pageContext.request.contextPath}/reports/sla-compliance?windowDays=30">30 days</a>
            </div>
        </div>

        <div class="alert alert-info mb-4" role="alert">
            <h6 class="fw-bold mb-2"><i class="bi bi-journal-text"></i> Reporting &amp; Analysis</h6>
            <p class="mb-2">Use this section to convert operations data into manager decisions.</p>
            <p class="mb-1"><strong>Daily Report:</strong> daily health summary (load, temperature, incidents, MTTR/MTBF).</p>
            <p class="mb-1"><strong>Trends Dashboard:</strong> pattern analysis for load, temperature, and incident intensity.</p>
            <p class="mb-2"><strong>SLA Monitor:</strong> compliance checks for temperature, downtime, response, and maintenance.</p>
            <a class="btn btn-sm btn-outline-primary me-2" href="${pageContext.request.contextPath}/reports">Open Daily Report</a>
            <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/reports/downtime-trend">Open Trends Dashboard</a>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-label">Availability SLA</div>
                    <div class="stat-value ${summary.availabilityCompliance >= summary.availabilityTargetPercent ? 'text-success' : 'text-danger'}">${summary.availabilityCompliance}%</div>
                    <div class="text-muted" style="font-size:12px;">Target: ${summary.availabilityTargetPercent}% uptime</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-label">Total Downtime</div>
                    <div class="stat-value">${summary.totalDowntimeMinutes} min</div>
                    <div class="text-muted" style="font-size:12px;">Allowed: ${summary.allowedDowntimeMinutes} min</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-label">Rule Compliance</div>
                    <div class="stat-value ${summary.violatedRuleCount == 0 ? 'text-success' : 'text-warning'}">${summary.compliantRuleCount}/${summary.compliantRuleCount + summary.violatedRuleCount}</div>
                    <div class="text-muted" style="font-size:12px;">In last ${windowDays} day(s)</div>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-label">Downtime Trend</div>
                    <div class="stat-value ${summary.downtimeTrend > 0 ? 'text-danger' : 'text-success'}">${summary.downtimeTrend}%</div>
                    <div class="text-muted" style="font-size:12px;">vs previous ${windowDays} day(s)</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-label">Max Temperature</div>
                    <div class="stat-value ${summary.temperatureViolations > 0 ? 'text-danger' : 'text-success'}">${summary.maxTemperature}&deg;C</div>
                    <div class="text-muted" style="font-size:12px;">Violations: ${summary.temperatureViolations}</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-label">Response SLA</div>
                    <div class="stat-value ${summary.responseViolations > 0 ? 'text-danger' : 'text-success'}">${summary.responseCompliance}%</div>
                    <div class="text-muted" style="font-size:12px;">Violations: ${summary.responseViolations}</div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <h6 class="m-0 fw-bold"><i class="bi bi-shield-check"></i> SLA Rule Checks</h6>
                <span class="badge ${summary.violatedRuleCount == 0 ? 'bg-success' : 'bg-warning text-dark'}">
                    ${summary.violatedRuleCount == 0 ? 'Compliant' : 'Action Required'}
                </span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead>
                            <tr>
                                <th style="width:18%;">Rule</th>
                                <th style="width:30%;">Definition</th>
                                <th style="width:17%;">Target</th>
                                <th style="width:17%;">Actual</th>
                                <th style="width:8%;">Status</th>
                                <th style="width:10%;">Notes</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${summary.checks}" var="check">
                                <tr>
                                    <td><strong>${check.name}</strong></td>
                                    <td>${check.description}</td>
                                    <td>${check.target}</td>
                                    <td>${check.actual}</td>
                                    <td>
                                        <span class="badge ${check.compliant ? 'bg-success' : 'bg-danger'}">
                                            ${check.compliant ? 'OK' : 'Violation'}
                                        </span>
                                    </td>
                                    <td>${check.notes}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header bg-white">
                <h6 class="m-0 fw-bold"><i class="bi bi-info-circle"></i> How this is calculated</h6>
            </div>
            <div class="card-body">
                <p class="mb-2"><strong>Availability SLA</strong> is computed from downtime in the selected window:</p>
                <p class="mb-2">Compliance % = ((Total window minutes - Downtime minutes) / Total window minutes) x 100</p>
                <p class="mb-2"><strong>Configured availability target:</strong> ${summary.availabilityTargetPercent}% uptime.</p>
                <p class="mb-2"><strong>Configured response target:</strong> <= ${summary.responseTargetMinutes} minutes.</p>
                <p class="mb-2"><strong>Response SLA</strong> uses the incident lifecycle as a proxy for first response time (createdAt to first update).</p>
                <p class="mb-2"><strong>Configured temperature target:</strong> <= ${summary.temperatureTargetC}&deg;C.</p>
                <p class="mb-2"><strong>Temperature SLA</strong> checks monitoring values against the configured temperature target.</p>
                <p class="mb-2"><strong>Maintenance SLA</strong> flags records with due date in the past.</p>
                <p class="mb-2"><strong>Configured monthly downtime limit:</strong> ${summary.monthlyDowntimeTargetMinutes} minutes (prorated by selected window).</p>
                <p class="mb-0 text-muted">Reports used in this window: ${summary.reportsCount}. If this is lower than expected, generate missing daily reports from Daily Report page.</p>
            </div>
        </div>
    </div>
</body>
</html>
