<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Compliance Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .report-card {
            border: 1px solid rgba(0,0,0,0.08);
            border-radius: 14px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
            background: linear-gradient(160deg, #f8f9ff 0%, #eef8ff 100%);
        }
        .report-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(18, 64, 101, 0.12);
        }
        .report-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: grid;
            place-items: center;
            font-size: 1.2rem;
            color: #0a4f70;
            background: #c9ecff;
        }
    </style>
</head>
<body>
<jsp:include page="../common/sidebar.jsp"/>
<jsp:include page="../common/topbar.jsp"/>

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 style="font-weight:700;margin:0;">Compliance & Documentation Module</h4>
            <p class="text-muted mb-0" style="font-size:14px;">Technical reports for IT Administrators and Managers</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/compliance/reports/generate" class="btn btn-primary">
                <i class="bi bi-funnel"></i> Generate Report
            </a>
            <a href="${pageContext.request.contextPath}/compliance/reports/viewer" class="btn btn-outline-primary">
                <i class="bi bi-table"></i> Open Viewer
            </a>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-md-6 col-xl-4">
            <div class="report-card p-3">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <div class="report-icon"><i class="bi bi-heart-pulse"></i></div>
                    <h6 class="mb-0 fw-bold">Equipment Health</h6>
                </div>
                <p class="text-muted mb-3">UPS load, battery health, cooling temperature, humidity, status and high-risk markers.</p>
                <a class="btn btn-sm btn-outline-dark" href="${pageContext.request.contextPath}/compliance/reports/viewer?reportType=equipment-health">View</a>
            </div>
        </div>

        <div class="col-md-6 col-xl-4">
            <div class="report-card p-3">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <div class="report-icon"><i class="bi bi-tools"></i></div>
                    <h6 class="mb-0 fw-bold">Maintenance History</h6>
                </div>
                <p class="text-muted mb-3">Technician/vendor records, maintenance type, next due date and overdue detection.</p>
                <a class="btn btn-sm btn-outline-dark" href="${pageContext.request.contextPath}/compliance/reports/viewer?reportType=maintenance">View</a>
            </div>
        </div>

        <div class="col-md-6 col-xl-4">
            <div class="report-card p-3">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <div class="report-icon"><i class="bi bi-exclamation-triangle"></i></div>
                    <h6 class="mb-0 fw-bold">Incident & Downtime</h6>
                </div>
                <p class="text-muted mb-3">Severity, downtime minutes, root cause, resolution status and SLA violations.</p>
                <a class="btn btn-sm btn-outline-dark" href="${pageContext.request.contextPath}/compliance/reports/viewer?reportType=incidents">View</a>
            </div>
        </div>

        <div class="col-md-6 col-xl-4">
            <div class="report-card p-3">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <div class="report-icon"><i class="bi bi-person-workspace"></i></div>
                    <h6 class="mb-0 fw-bold">Shift Report</h6>
                </div>
                <p class="text-muted mb-3">Per-technician shift summary with incidents handled, maintenance and handover notes.</p>
                <a class="btn btn-sm btn-outline-dark" href="${pageContext.request.contextPath}/compliance/reports/viewer?reportType=shift">View</a>
            </div>
        </div>

        <div class="col-md-6 col-xl-4">
            <div class="report-card p-3">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <div class="report-icon"><i class="bi bi-calendar3"></i></div>
                    <h6 class="mb-0 fw-bold">Daily Consolidated</h6>
                </div>
                <p class="text-muted mb-3">UPS and cooling performance with MTTR/MTBF, incidents and total downtime.</p>
                <a class="btn btn-sm btn-outline-dark" href="${pageContext.request.contextPath}/compliance/reports/viewer?reportType=daily">View</a>
            </div>
        </div>

        <div class="col-md-6 col-xl-4">
            <div class="report-card p-3">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <div class="report-icon"><i class="bi bi-shield-check"></i></div>
                    <h6 class="mb-0 fw-bold">Compliance</h6>
                </div>
                <p class="text-muted mb-3">Overdue maintenance, critical alerts and SLA violations across infrastructure.</p>
                <a class="btn btn-sm btn-outline-dark" href="${pageContext.request.contextPath}/compliance/reports/viewer?reportType=compliance">View</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
