<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - <c:choose><c:when test="${isEdit}">Edit Incident #${incident.incidentId}</c:when><c:otherwise>Log New Incident</c:otherwise></c:choose></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .section-header {
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--accent, #e74c3c);
            border-bottom: 1px solid rgba(255,255,255,0.07);
            padding-bottom: 8px;
            margin-bottom: 18px;
        }
        .upload-zone {
            border: 2px dashed rgba(255,255,255,0.15);
            border-radius: 10px;
            padding: 24px;
            text-align: center;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
        }
        .upload-zone:hover { border-color: #e74c3c; background: rgba(231,76,60,0.05); }
        .upload-zone .bi { font-size: 2rem; color: #888; }
        #downtimeMinutesDisplay {
            font-size: 13px;
            color: #aaa;
            margin-top: 6px;
        }
        .existing-attachment {
            background: rgba(255,255,255,0.05);
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">

        <%-- Flash messages --%>
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">
                    <c:choose>
                        <c:when test="${isEdit}"><i class="bi bi-pencil-square text-warning me-2"></i>Edit Incident #${incident.incidentId}</c:when>
                        <c:otherwise><i class="bi bi-exclamation-triangle-fill text-danger me-2"></i>Log New Incident</c:otherwise>
                    </c:choose>
                </h4>
                <p class="text-muted mb-0" style="font-size:14px;">
                    <c:choose>
                        <c:when test="${isEdit}">Update incident details, attachments, and downtime</c:when>
                        <c:otherwise>Report equipment failures and faults</c:otherwise>
                    </c:choose>
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/incidents<c:if test="${isEdit}">/view/${incident.incidentId}</c:if>" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
        </div>

        <div class="stat-card">
            <c:choose>
                <c:when test="${isEdit}">
                    <form action="${pageContext.request.contextPath}/incidents/update/${incident.incidentId}"
                          method="post" enctype="multipart/form-data" id="incidentForm">
                </c:when>
                <c:otherwise>
                    <form action="${pageContext.request.contextPath}/incidents/save"
                          method="post" enctype="multipart/form-data" id="incidentForm">
                </c:otherwise>
            </c:choose>

                <%-- ===== INCIDENT DETAILS ===== --%>
                <p class="section-header"><i class="bi bi-file-text me-1"></i>Incident Details</p>
                <div class="row g-3 mb-4">
                    <div class="col-md-8">
                        <label class="form-label">Title <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title"
                               value="${incident.title}" required
                               placeholder="Brief description of the incident"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Severity <span class="text-danger">*</span></label>
                        <select class="form-select" name="severity" required>
                            <option value="LOW"      ${incident.severity == 'LOW'      ? 'selected' : ''}>🟢 Low</option>
                            <option value="MEDIUM"   ${incident.severity == 'MEDIUM'   ? 'selected' : ''}>🟡 Medium</option>
                            <option value="HIGH"     ${incident.severity == 'HIGH'     ? 'selected' : ''}>🟠 High</option>
                            <option value="CRITICAL" ${incident.severity == 'CRITICAL' ? 'selected' : ''}>🔴 Critical</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Equipment Type <span class="text-danger">*</span></label>
                        <select class="form-select" name="equipmentType" required>
                            <option value="UPS"     ${incident.equipmentType == 'UPS'     ? 'selected' : ''}>⚡ UPS</option>
                            <option value="COOLING" ${incident.equipmentType == 'COOLING' ? 'selected' : ''}>❄️ Cooling</option>
                            <option value="OTHER"   ${incident.equipmentType == 'OTHER'   ? 'selected' : ''}>🔧 Other</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Equipment ID</label>
                        <input type="number" class="form-control" name="equipmentId"
                               value="${incident.equipmentId}" placeholder="e.g. 101"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="OPEN"        ${incident.status == 'OPEN'        ? 'selected' : ''}>🔴 Open</option>
                            <option value="IN_PROGRESS" ${incident.status == 'IN_PROGRESS' ? 'selected' : ''}>🔵 In Progress</option>
                            <option value="RESOLVED"    ${incident.status == 'RESOLVED'    ? 'selected' : ''}>🟢 Resolved</option>
                            <option value="CLOSED"      ${incident.status == 'CLOSED'      ? 'selected' : ''}>⚫ Closed</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="description" rows="3"
                                  placeholder="Detailed description of the incident, symptoms, and impact...">${incident.description}</textarea>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Root Cause</label>
                        <textarea class="form-control" name="rootCause" rows="2"
                                  placeholder="Known or suspected root cause...">${incident.rootCause}</textarea>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Action Taken</label>
                        <textarea class="form-control" name="actionTaken" rows="2"
                                  placeholder="Steps taken to resolve or mitigate the incident...">${incident.actionTaken}</textarea>
                    </div>
                </div>

                <%-- ===== DOWNTIME TRACKING ===== --%>
                <p class="section-header"><i class="bi bi-stopwatch me-1"></i>Downtime Tracking</p>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Downtime Start</label>
                        <input type="datetime-local" class="form-control" name="downtimeStart"
                               id="downtimeStart"
                               value="${incident.downtimeStart}"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Downtime End</label>
                        <input type="datetime-local" class="form-control" name="downtimeEnd"
                               id="downtimeEnd"
                               value="${incident.downtimeEnd}"/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Downtime Duration (minutes)</label>
                        <input type="number" class="form-control" name="downtimeMinutes"
                               id="downtimeMinutes"
                               value="${incident.downtimeMinutes}"
                               placeholder="Auto-calculated or enter manually" min="0"/>
                        <div id="downtimeMinutesDisplay"></div>
                    </div>
                </div>

                <%-- ===== ATTACHMENT ===== --%>
                <p class="section-header"><i class="bi bi-paperclip me-1"></i>Photo / Report Attachment</p>
                <div class="mb-4">
                    <c:if test="${isEdit && not empty incident.attachmentPath}">
                        <div class="existing-attachment mb-3">
                            <i class="bi bi-file-earmark-check text-success fs-5"></i>
                            <div>
                                <div style="font-weight:600;">Current Attachment</div>
                                <a href="${incident.attachmentPath}" target="_blank" class="text-primary" style="font-size:12px;">
                                    ${incident.attachmentPath}
                                </a>
                            </div>
                            <span class="ms-auto badge bg-secondary">Existing</span>
                        </div>
                    </c:if>
                    <label class="form-label">
                        <c:choose>
                            <c:when test="${isEdit && not empty incident.attachmentPath}">Replace Attachment (optional)</c:when>
                            <c:otherwise>Upload Photo or Report (optional)</c:otherwise>
                        </c:choose>
                    </label>
                    <div class="upload-zone" onclick="document.getElementById('attachmentFile').click()">
                        <i class="bi bi-cloud-arrow-up"></i>
                        <p class="mb-1 mt-2" style="font-weight:600;">Click to upload or drag & drop</p>
                        <p class="text-muted mb-0" style="font-size:12px;">Supports: JPG, PNG, PDF, DOCX (max 10MB)</p>
                        <div id="fileNameDisplay" class="mt-2 text-primary" style="font-size:13px;font-weight:500;"></div>
                    </div>
                    <input type="file" id="attachmentFile" name="attachmentFile"
                           accept=".jpg,.jpeg,.png,.gif,.pdf,.doc,.docx,.txt"
                           class="d-none" onchange="showFileName(this)"/>
                </div>

                <%-- ===== SUBMIT ===== --%>
                <div class="d-flex gap-2 flex-wrap">
                    <c:choose>
                        <c:when test="${isEdit}">
                            <button type="submit" class="btn btn-warning text-dark fw-bold">
                                <i class="bi bi-save2"></i> Save Changes
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="btn btn-danger fw-bold">
                                <i class="bi bi-exclamation-triangle"></i> Log Incident
                            </button>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/incidents<c:if test="${isEdit}">/view/${incident.incidentId}</c:if>"
                       class="btn btn-outline-secondary">Cancel</a>
                </div>

            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Show selected file name
        function showFileName(input) {
            const display = document.getElementById('fileNameDisplay');
            if (input.files && input.files[0]) {
                display.textContent = '📎 ' + input.files[0].name;
            } else {
                display.textContent = '';
            }
        }

        // Auto-calculate downtime minutes from start/end
        function calcDowntime() {
            const start = document.getElementById('downtimeStart').value;
            const end   = document.getElementById('downtimeEnd').value;
            const display = document.getElementById('downtimeMinutesDisplay');
            if (start && end) {
                const startMs = new Date(start).getTime();
                const endMs   = new Date(end).getTime();
                if (endMs > startMs) {
                    const mins = Math.round((endMs - startMs) / 60000);
                    document.getElementById('downtimeMinutes').value = mins;
                    const h = Math.floor(mins / 60), m = mins % 60;
                    display.textContent = '⏱ Auto-calculated: ' + (h > 0 ? h + 'h ' : '') + m + 'min';
                    display.style.color = '#2ecc71';
                } else {
                    display.textContent = '⚠ End time must be after start time';
                    display.style.color = '#e74c3c';
                }
            } else {
                display.textContent = '';
            }
        }

        document.getElementById('downtimeStart').addEventListener('change', calcDowntime);
        document.getElementById('downtimeEnd').addEventListener('change', calcDowntime);

        // Drag & drop support
        const zone = document.querySelector('.upload-zone');
        zone.addEventListener('dragover', e => { e.preventDefault(); zone.style.borderColor = '#e74c3c'; });
        zone.addEventListener('dragleave', () => { zone.style.borderColor = ''; });
        zone.addEventListener('drop', e => {
            e.preventDefault();
            zone.style.borderColor = '';
            const file = e.dataTransfer.files[0];
            if (file) {
                const input = document.getElementById('attachmentFile');
                const dt = new DataTransfer();
                dt.items.add(file);
                input.files = dt.files;
                document.getElementById('fileNameDisplay').textContent = '📎 ' + file.name;
            }
        });
    </script>
</body>
</html>
