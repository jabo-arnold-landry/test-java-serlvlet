<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Past Warnings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .alert-type-badge { font-size:11px; padding:4px 10px; border-radius:12px; font-weight:600; }
        .alert-type-HIGH_TEMP { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-HUMIDITY { background:rgba(59,130,246,0.1); color:#3b82f6; }
        .alert-type-LOW_BATTERY { background:rgba(245,158,11,0.1); color:#f59e0b; }
        .alert-type-UPS_OVERLOAD { background:rgba(239,68,68,0.1); color:#ef4444; }
        .alert-type-MAINTENANCE_DUE { background:rgba(139,92,246,0.1); color:#8b5cf6; }
        .alert-type-EQUIPMENT_FAULT { background:rgba(239,68,68,0.1); color:#ef4444; }
        .filter-card { background:#fff; border:1px solid #e5e7eb; border-radius:12px; padding:16px; }
        .history-table td, .history-table th { font-size:13px; }
        .history-message { max-width:360px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
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
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h4 style="font-weight:700;margin:0;">Past Warnings</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Warnings acknowledged by your account, with date filters.</p>
            </div>
            <a href="${pageContext.request.contextPath}/alerts" class="btn btn-outline-primary btn-sm">
                <i class="bi bi-arrow-left"></i> Back To Active Warnings
            </a>
        </div>

        <div class="filter-card mb-4">
            <form method="get" action="${pageContext.request.contextPath}/alerts/history" class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label mb-1">From Date</label>
                    <input type="date" name="fromDate" class="form-control form-control-sm" value="${fromDate}">
                </div>
                <div class="col-md-3">
                    <label class="form-label mb-1">To Date</label>
                    <input type="date" name="toDate" class="form-control form-control-sm" value="${toDate}">
                </div>
                <div class="col-md-3">
                    <label class="form-label mb-1">Alert Type</label>
                    <select name="alertType" class="form-select form-select-sm">
                        <option value="">All Types</option>
                        <c:forEach var="type" items="${alertTypes}">
                            <option value="${type}" ${selectedAlertType == type ? 'selected' : ''}>${type}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-funnel"></i> Filter
                    </button>
                    <a href="${pageContext.request.contextPath}/alerts/history" class="btn btn-outline-secondary btn-sm">
                        Clear
                    </a>
                </div>
            </form>
        </div>

        <div class="table-container">
            <table class="table table-hover history-table mb-0">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Message</th>
                        <th>Equipment</th>
                        <th>Triggered At</th>
                        <th>Acknowledged At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${historyAlerts}">
                    <tr>
                        <td>
                            <span class="alert-type-badge alert-type-${a.alertType}">
                                ${a.alertType}
                            </span>
                        </td>
                        <td>
                            <div class="history-message" title="${a.message}">${a.message}</div>
                        </td>
                        <td>${a.equipmentType} #${a.equipmentId}</td>
                        <td>${triggeredAtById[a.alertId]}</td>
                        <td>${acknowledgedAtById[a.alertId]}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/alerts/view/${a.alertId}"
                               class="btn btn-outline-primary btn-sm"
                               title="View Alert Page">
                                <i class="bi bi-eye"></i>
                            </a>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty historyAlerts}">
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">
                                <i class="bi bi-clock-history" style="font-size:30px;"></i>
                                <p class="mb-0 mt-2">No past warnings found for the selected filters.</p>
                            </td>
                        </tr>
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
