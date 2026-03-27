<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Alerts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .alert-type-badge { font-size:11px; padding:4px 9px; border-radius:12px; font-weight:600; }
        .alert-type-HIGH_TEMP { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-HUMIDITY { background:rgba(59,130,246,0.1); color:#3b82f6; }
        .alert-type-LOW_BATTERY { background:rgba(245,158,11,0.1); color:#f59e0b; }
        .alert-type-UPS_OVERLOAD { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-MAINTENANCE_DUE { background:rgba(139,92,246,0.1); color:#8b5cf6; }
        .alert-type-EQUIPMENT_FAULT { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alerts-table { width:100%; margin-bottom:0; }
        .alerts-table th { white-space:nowrap; font-size:12px; }
        .alerts-table td { font-size:13px; vertical-align:middle; }
        .severity-score { white-space:nowrap; }
        .sla-cell { min-width:110px; }
        .sla-badge { display:inline-block; max-width:100%; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .sla-detail { display:block; margin-top:3px; font-size:11px; color:#6b7280; line-height:1.2; white-space:nowrap; }
        .alert-toolbar { display:flex; gap:10px; flex-wrap:wrap; }
        .alert-toolbar .btn { min-width:120px; }
        .alert-row-actions { display:flex; align-items:center; gap:6px; }
        .alert-row-actions .btn { width:30px; height:30px; padding:0; display:inline-flex; align-items:center; justify-content:center; }
        .alert-view-modal .modal-dialog { max-width: 1100px; }
        .alert-view-modal .modal-content {
            border: 0;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 20px 50px rgba(15, 23, 42, 0.24);
            animation: modalReveal 0.22s ease-out;
        }
        .alert-view-modal .modal-header {
            background: linear-gradient(120deg, #0f172a, #1e293b);
            color: #fff;
            border-bottom: 0;
            padding: 14px 18px;
        }
        .alert-view-modal .modal-header .btn-close {
            filter: invert(1) grayscale(100%);
            opacity: 0.85;
        }
        .alert-view-modal .modal-header .btn-close:hover {
            opacity: 1;
            transform: scale(1.06);
        }
        .alert-view-modal .modal-body {
            background: linear-gradient(180deg, #f8fafc, #f1f5f9);
            padding: 18px;
        }
        .modal-kv-card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 10px 12px;
            min-height: 76px;
            transition: transform 0.16s ease, box-shadow 0.16s ease, border-color 0.16s ease;
        }
        .modal-kv-card:hover {
            border-color: #cbd5e1;
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.08);
        }
        .modal-kv-label { font-size:11px; color:#6b7280; text-transform:uppercase; letter-spacing:0.4px; }
        .modal-kv-value { font-size:14px; font-weight:600; color:#1f2937; }
        .modal-message { white-space:pre-wrap; word-break:break-word; }

        @keyframes modalReveal {
            from { opacity: 0; transform: translateY(8px) scale(0.985); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        @media (max-width: 1320px) {
            .col-values,
            .col-sent { display:none; }
            .severity-score { display:none; }
        }

        @media (max-width: 1100px) {
            .alerts-table td:nth-child(3) {
                max-width:220px;
            }
        }
    </style>
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
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle-fill"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
            <div>
                <h4 style="font-weight:700;margin:0;">Active Warnings</h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    <span class="badge bg-danger">${unacknowledgedAlerts}</span> unacknowledged alerts for your account
                </p>
            </div>
            <div class="alert-toolbar">
                <a href="${pageContext.request.contextPath}/alerts/history" class="btn btn-outline-dark btn-sm">
                    <i class="bi bi-clock-history"></i> Past Warnings
                </a>
                <sec:authorize access="!hasAnyRole('MANAGER','VIEWER')">
                    <a href="${pageContext.request.contextPath}/alerts/settings" class="btn btn-outline-primary btn-sm">
                        <i class="bi bi-gear"></i> Settings
                    </a>
                    <a href="${pageContext.request.contextPath}/alerts/test" class="btn btn-outline-success btn-sm">
                        <i class="bi bi-broadcast"></i> Simulation
                    </a>
                </sec:authorize>
            </div>
        </div>
        
        <div class="table-container">
            <table class="table table-hover alerts-table">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Severity</th>
                        <th>Message</th>
                        <th>Equipment</th>
                        <th class="col-values">Values</th>
                        <th class="col-sent">Sent</th>
                        <th>Status</th>
                        <th>SLA</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${alerts}">
                    <tr class="${a.isAcknowledged ? '' : 'table-warning'}">
                        <td>
                            <span class="alert-type-badge alert-type-${a.alertType}">
                                <c:choose>
                                    <c:when test="${a.alertType == 'HIGH_TEMP'}"><i class="bi bi-thermometer-high"></i></c:when>
                                    <c:when test="${a.alertType == 'HUMIDITY'}"><i class="bi bi-droplet"></i></c:when>
                                    <c:when test="${a.alertType == 'LOW_BATTERY'}"><i class="bi bi-battery-half"></i></c:when>
                                    <c:when test="${a.alertType == 'UPS_OVERLOAD'}"><i class="bi bi-lightning"></i></c:when>
                                    <c:otherwise><i class="bi bi-exclamation-triangle"></i></c:otherwise>
                                </c:choose>
                                ${a.alertType}
                            </span>
                        </td>
                        <td>
                            <span class="badge bg-${severityClassById[a.alertId]}" title="${recommendationById[a.alertId]}">
                                ${severityLabelById[a.alertId]}
                            </span>
                            <div class="small text-muted mt-1">Score: ${severityScoreById[a.alertId]}</div>
                        </td>
                        <td style="max-width:280px;">
                            <div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${a.message}">${a.message}</div>
                            <a href="${pageContext.request.contextPath}/alerts/view/${a.alertId}"
                               class="btn btn-link p-0 small text-decoration-none"
                               title="View Full Warning Page">
                                View full warning
                            </a>
                        </td>
                        <td>${a.equipmentType} #${a.equipmentId}</td>
                        <td class="col-values">
                            <c:if test="${a.actualValue != null && a.thresholdValue != null}">
                                <small class="text-danger fw-bold">${a.actualValue}</small> / 
                                <small class="text-muted">${a.thresholdValue}</small>
                            </c:if>
                        </td>
                        <td class="col-sent">
                            <span class="badge ${a.isSent ? 'bg-success' : 'bg-secondary'}">
                                ${a.isSent ? 'Yes' : 'No'}
                            </span>
                        </td>
                        <td>
                            <span class="badge bg-danger">Pending</span>
                        </td>
                        <td class="sla-cell">
                            <c:set var="slaText" value="${slaStatusById[a.alertId]}"/>
                            <span class="badge ${fn:contains(slaText, 'Breached') ? 'bg-danger' : 'bg-light text-dark'} sla-badge" title="${slaText}">
                                <c:choose>
                                    <c:when test="${fn:contains(slaText, 'Breached by')}">Breached</c:when>
                                    <c:when test="${fn:contains(slaText, 'Due in')}">Due Soon</c:when>
                                    <c:otherwise>${slaText}</c:otherwise>
                                </c:choose>
                            </span>
                            <c:if test="${fn:contains(slaText, 'Breached by')}">
                                <span class="sla-detail">${fn:substringAfter(slaText, 'Breached by ')}</span>
                            </c:if>
                            <c:if test="${fn:contains(slaText, 'Due in')}">
                                <span class="sla-detail">${fn:substringAfter(slaText, 'Due in ')}</span>
                            </c:if>
                        </td>
                        <td>
                            <div class="alert-row-actions">
                                <a href="${pageContext.request.contextPath}/alerts/view/${a.alertId}"
                                   class="btn btn-outline-primary btn-sm"
                                   title="View Full Warning Page">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/alerts/acknowledge/${a.alertId}" method="post" class="m-0">
                                    <button type="submit" class="btn btn-success btn-sm" title="Acknowledge">
                                        <i class="bi bi-check2"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty alerts}">
                    <tr><td colspan="9" class="text-center text-muted py-4">
                        <i class="bi bi-bell-slash" style="font-size:32px;"></i>
                        <p class="mb-0 mt-2">No active warnings. Acknowledged items are available in Past Warnings.</p>
                    </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade alert-view-modal" id="alertViewModal" tabindex="-1" aria-labelledby="alertViewModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="alertViewModalLabel">Alert Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="alertModalLoading" class="text-center py-4">
                        <div class="spinner-border text-primary" role="status"></div>
                        <p class="text-muted mt-2 mb-0">Loading alert details...</p>
                    </div>
                    <div id="alertModalError" class="alert alert-danger d-none mb-0"></div>
                    <div id="alertModalContent" class="d-none">
                        <div class="row g-3">
                            <div class="col-md-4">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Type</div>
                                    <div id="modalType" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Severity</div>
                                    <div id="modalSeverity" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Status</div>
                                    <div id="modalStatus" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Equipment</div>
                                    <div id="modalEquipment" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Actual</div>
                                    <div id="modalActual" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Threshold</div>
                                    <div id="modalThreshold" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Triggered At</div>
                                    <div id="modalCreatedAt" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Acknowledged At</div>
                                    <div id="modalAcknowledgedAt" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">SLA</div>
                                    <div id="modalSla" class="modal-kv-value">-</div>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Message</div>
                                    <div id="modalMessage" class="modal-kv-value modal-message">-</div>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="modal-kv-card">
                                    <div class="modal-kv-label">Recommendation</div>
                                    <div id="modalRecommendation" class="modal-kv-value modal-message">-</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Global Alert Notification System -->
    
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        (function() {
            const modalEl = document.getElementById('alertViewModal');
            const titleEl = document.getElementById('alertViewModalLabel');
            const loadingEl = document.getElementById('alertModalLoading');
            const errorEl = document.getElementById('alertModalError');
            const contentEl = document.getElementById('alertModalContent');
            const fields = {
                type: document.getElementById('modalType'),
                severity: document.getElementById('modalSeverity'),
                status: document.getElementById('modalStatus'),
                equipment: document.getElementById('modalEquipment'),
                actual: document.getElementById('modalActual'),
                threshold: document.getElementById('modalThreshold'),
                createdAt: document.getElementById('modalCreatedAt'),
                acknowledgedAt: document.getElementById('modalAcknowledgedAt'),
                sla: document.getElementById('modalSla'),
                message: document.getElementById('modalMessage'),
                recommendation: document.getElementById('modalRecommendation')
            };

            if (!modalEl || !titleEl || !loadingEl || !errorEl || !contentEl || typeof bootstrap === 'undefined') {
                return;
            }

            const modal = new bootstrap.Modal(modalEl);

            function resetModal() {
                titleEl.textContent = 'Alert Details';
                loadingEl.classList.remove('d-none');
                errorEl.classList.add('d-none');
                errorEl.textContent = '';
                contentEl.classList.add('d-none');
                Object.values(fields).forEach(function(field) {
                    if (field) {
                        field.textContent = '-';
                    }
                });
            }

            document.addEventListener('click', function(event) {
                const trigger = event.target.closest('.open-alert-modal');
                if (!trigger) {
                    return;
                }
                event.preventDefault();

                const alertUrl = trigger.getAttribute('data-alert-url');
                const alertType = trigger.getAttribute('data-alert-type') || 'Alert';
                if (!alertUrl) {
                    return;
                }

                resetModal();
                titleEl.textContent = alertType + ' Details';
                modal.show();

                fetch(alertUrl, { headers: { 'Accept': 'application/json' } })
                    .then(function(response) {
                        if (!response.ok) {
                            throw new Error('Failed to load alert details.');
                        }
                        return response.json();
                    })
                    .then(function(data) {
                        fields.type.textContent = data.type || '-';
                        fields.severity.textContent = (data.severity || '-') + (data.score != null ? ' (' + data.score + ')' : '');
                        fields.status.textContent = data.status || '-';
                        fields.equipment.textContent = data.equipment || '-';
                        fields.actual.textContent = data.actualValue || '-';
                        fields.threshold.textContent = data.thresholdValue || '-';
                        fields.createdAt.textContent = data.createdAt || '-';
                        fields.acknowledgedAt.textContent = data.acknowledgedAt || '-';
                        fields.sla.textContent = data.sla || '-';
                        fields.message.textContent = data.message || '-';
                        fields.recommendation.textContent = data.recommendation || '-';

                        loadingEl.classList.add('d-none');
                        contentEl.classList.remove('d-none');
                    })
                    .catch(function(error) {
                        loadingEl.classList.add('d-none');
                        errorEl.textContent = error.message || 'Unable to load alert details.';
                        errorEl.classList.remove('d-none');
                    });
            });

            modalEl.addEventListener('hidden.bs.modal', function() {
                resetModal();
            });
        })();
    </script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
