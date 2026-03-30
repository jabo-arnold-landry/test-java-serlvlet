<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Equipment Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        /* === Documentation & Attachments View Styles === */
        .doc-section {
            background: var(--card-bg);
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            overflow: hidden;
        }
        .doc-section-title {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 18px 20px;
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border-bottom: 1px solid #e5e7eb;
        }
        .doc-section-title .title-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: linear-gradient(135deg, #3b82f6, #8b5cf6);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }
        .doc-section-title h6 {
            margin: 0;
            font-weight: 700;
            font-size: 16px;
            color: #1f2937;
        }
        .doc-section-title p {
            margin: 0;
            font-size: 12px;
            color: #6b7280;
        }
        .doc-files-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 0;
        }
        .doc-file-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 16px 20px;
            border-bottom: 1px solid #f3f4f6;
            transition: all 0.2s;
        }
        .doc-file-item:hover {
            background: #f8fafc;
        }
        .doc-file-item:last-child {
            border-bottom: none;
        }
        .doc-type-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }
        .doc-type-icon.config { background: linear-gradient(135deg, #dbeafe, #bfdbfe); color: #2563eb; }
        .doc-type-icon.network { background: linear-gradient(135deg, #fce7f3, #fbcfe8); color: #db2777; }
        .doc-type-icon.rack { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #d97706; }
        .doc-type-icon.maintenance { background: linear-gradient(135deg, #d1fae5, #a7f3d0); color: #059669; }
        .doc-type-icon.photos { background: linear-gradient(135deg, #e0e7ff, #c7d2fe); color: #4f46e5; }

        .doc-file-details {
            flex: 1;
            min-width: 0;
        }
        .doc-file-details .doc-type-label {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #9ca3af;
            font-weight: 600;
            margin-bottom: 2px;
        }
        .doc-file-details .doc-file-name {
            font-size: 14px;
            font-weight: 600;
            color: #1f2937;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .doc-file-details .doc-file-ext {
            display: inline-block;
            padding: 1px 6px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            margin-top: 3px;
        }
        .doc-file-ext.pdf { background: #fee2e2; color: #dc2626; }
        .doc-file-ext.img { background: #dbeafe; color: #2563eb; }
        .doc-file-ext.doc { background: #e0e7ff; color: #4f46e5; }
        .doc-file-ext.code { background: #fef3c7; color: #d97706; }
        .doc-file-ext.default { background: #f3f4f6; color: #6b7280; }

        .doc-file-actions {
            display: flex;
            gap: 8px;
            flex-shrink: 0;
        }
        .doc-download-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 14px;
            font-size: 13px;
            font-weight: 500;
            border-radius: 8px;
            border: 1px solid #d1d5db;
            background: white;
            color: #374151;
            text-decoration: none;
            transition: all 0.2s;
        }
        .doc-download-btn:hover {
            background: var(--accent-blue);
            color: white;
            border-color: var(--accent-blue);
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
        }
        .doc-empty-state {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 16px 20px;
            border-bottom: 1px solid #f3f4f6;
            opacity: 0.5;
        }
        .doc-empty-state:last-child {
            border-bottom: none;
        }
        .doc-empty-state .doc-file-name {
            color: #9ca3af;
            font-style: italic;
            font-size: 13px;
        }
        .doc-stats-bar {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 12px 20px;
            background: #f9fafb;
            border-top: 1px solid #e5e7eb;
            font-size: 12px;
            color: #6b7280;
        }
        .doc-stats-bar .stat-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .doc-stats-bar .stat-item i {
            font-size: 14px;
        }
        .doc-stats-bar .stat-item .count {
            font-weight: 700;
            color: #1f2937;
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">${equipment.equipmentName}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Asset: ${equipment.assetTagNumber} | Type: ${equipment.equipmentType} | S/N: ${equipment.serialNumber}</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/equipment/edit/${equipment.equipmentId}" class="btn btn-outline-primary"><i class="bi bi-pencil"></i> Edit</a>
                <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
            </div>
        </div>
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Status</div>
                    <span class="badge ${equipment.maintenanceStatus == 'ACTIVE' ? 'bg-success' : equipment.maintenanceStatus == 'FAULTY' ? 'bg-danger' : 'bg-warning'} fs-6 mt-2">${equipment.maintenanceStatus}</span>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Location</div>
                    <div style="font-size:16px;font-weight:600;margin-top:8px;">${equipment.rackNumber} - ${equipment.rackUnitPosition}</div>
                    <div class="text-muted" style="font-size:12px;">${equipment.dataCenterName} / ${equipment.roomName}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Warranty Expiry</div>
                    <div style="font-size:16px;font-weight:600;margin-top:8px;">${equipment.warrantyExpiryDate}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card text-center">
                    <div class="stat-label">Cost</div>
                    <div style="font-size:16px;font-weight:600;margin-top:8px;">$${equipment.cost}</div>
                </div>
            </div>
        </div>
        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-cpu"></i> Technical Specifications</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Brand</td><td>${equipment.brandManufacturer}</td></tr>
                        <tr><td class="text-muted">Model</td><td>${equipment.modelNumber}</td></tr>
                        <tr><td class="text-muted">Hostname</td><td>${equipment.hostname}</td></tr>
                        <tr><td class="text-muted">IP Address</td><td>${equipment.ipAddress}</td></tr>
                        <tr><td class="text-muted">MAC Address</td><td>${equipment.macAddress}</td></tr>
                        <tr><td class="text-muted">CPU</td><td>${equipment.cpuType}</td></tr>
                        <tr><td class="text-muted">RAM</td><td>${equipment.ramSize}</td></tr>
                        <tr><td class="text-muted">Storage</td><td>${equipment.storageCapacity}</td></tr>
                        <tr><td class="text-muted">OS</td><td>${equipment.operatingSystem}</td></tr>
                        <tr><td class="text-muted">Firmware</td><td>${equipment.firmwareVersion}</td></tr>
                        <tr><td class="text-muted">Power Rating</td><td>${equipment.powerRating}</td></tr>
                    </table>
                </div>
                <div class="stat-card mt-3">
                    <h6 class="fw-bold mb-3"><i class="bi bi-activity"></i> Power &amp; Environment</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Power Source</td><td>${equipment.powerSource}</td></tr>
                        <tr><td class="text-muted">Connected PDU</td><td>${equipment.connectedPdu}</td></tr>
                        <tr><td class="text-muted">Temperature Range</td><td>${equipment.temperatureRange}</td></tr>
                        <tr><td class="text-muted">Humidity Level</td><td>${equipment.humidityLevel}</td></tr>
                        <tr><td class="text-muted">Power Consumption</td><td>${equipment.powerConsumption}</td></tr>
                        <tr><td class="text-muted">Cooling Zone</td><td>${equipment.coolingZone}</td></tr>
                    </table>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card mb-3">
                    <h6 class="fw-bold mb-3"><i class="bi bi-receipt"></i> Procurement</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Purchase Date</td><td>${equipment.purchaseDate}</td></tr>
                        <tr><td class="text-muted">Supplier</td><td>${equipment.supplierName}</td></tr>
                        <tr><td class="text-muted">PO Number</td><td>${equipment.purchaseOrderNumber}</td></tr>
                        <tr><td class="text-muted">Invoice</td><td>${equipment.invoiceNumber}</td></tr>
                        <tr><td class="text-muted">Warranty Start</td><td>${equipment.warrantyStartDate}</td></tr>
                        <tr><td class="text-muted">Warranty Expiry</td><td>${equipment.warrantyExpiryDate}</td></tr>
                        <tr><td class="text-muted">Funding Source</td><td>${equipment.fundingSource}</td></tr>
                    </table>
                </div>
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-wrench"></i> Maintenance & Lifecycle</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Last Maintenance</td><td>${equipment.lastMaintenanceDate}</td></tr>
                        <tr><td class="text-muted">Next Due</td><td>${equipment.nextMaintenanceDue}</td></tr>
                        <tr><td class="text-muted">Support Vendor</td><td>${equipment.supportVendor}</td></tr>
                        <tr><td class="text-muted">Installation</td><td>${equipment.installationDate}</td></tr>
                        <tr><td class="text-muted">End of Life</td><td>${equipment.endOfLife}</td></tr>
                        <tr><td class="text-muted">End of Support</td><td>${equipment.endOfSupport}</td></tr>
                    </table>
                </div>
            </div>
        </div>

        <!-- ============================================================ -->
        <!-- 8. DOCUMENTATION & ATTACHMENTS SECTION -->
        <!-- ============================================================ -->
        <div class="doc-section mb-4">
            <div class="doc-section-title">
                <div class="title-icon">
                    <i class="bi bi-folder2-open"></i>
                </div>
                <div>
                    <h6>Documentation & Attachments</h6>
                    <p>Configuration files, diagrams, maintenance reports, and equipment photos</p>
                </div>
            </div>

            <div>
                <!-- Config File -->
                <c:choose>
                    <c:when test="${not empty equipment.configFilePath}">
                        <div class="doc-file-item">
                            <div class="doc-type-icon config">
                                <i class="bi bi-file-earmark-code"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Configuration File</div>
                                <div class="doc-file-name">${configFileName}</div>
                                <span class="doc-file-ext code">${configFileExt}</span>
                            </div>
                            <div class="doc-file-actions">
                                <a href="${pageContext.request.contextPath}/equipment/download/${equipment.equipmentId}/config" class="doc-download-btn">
                                    <i class="bi bi-download"></i> Download
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="doc-empty-state">
                            <div class="doc-type-icon config" style="opacity:0.4;">
                                <i class="bi bi-file-earmark-code"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Configuration File</div>
                                <div class="doc-file-name">No configuration file uploaded</div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Network Diagram -->
                <c:choose>
                    <c:when test="${not empty equipment.networkDiagramRef}">
                        <div class="doc-file-item">
                            <div class="doc-type-icon network">
                                <i class="bi bi-diagram-3"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Network Diagram</div>
                                <div class="doc-file-name">${networkDiagramFileName}</div>
                                <span class="doc-file-ext ${networkDiagramFileExt == 'pdf' ? 'pdf' : networkDiagramFileExt == 'png' || networkDiagramFileExt == 'jpg' || networkDiagramFileExt == 'jpeg' || networkDiagramFileExt == 'svg' ? 'img' : 'default'}">${networkDiagramFileExt}</span>
                            </div>
                            <div class="doc-file-actions">
                                <a href="${pageContext.request.contextPath}/equipment/download/${equipment.equipmentId}/network-diagram" class="doc-download-btn">
                                    <i class="bi bi-download"></i> Download
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="doc-empty-state">
                            <div class="doc-type-icon network" style="opacity:0.4;">
                                <i class="bi bi-diagram-3"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Network Diagram</div>
                                <div class="doc-file-name">No network diagram uploaded</div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Rack Layout Diagram -->
                <c:choose>
                    <c:when test="${not empty equipment.rackLayoutDiagram}">
                        <div class="doc-file-item">
                            <div class="doc-type-icon rack">
                                <i class="bi bi-grid-3x3-gap"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Rack Layout Diagram</div>
                                <div class="doc-file-name">${rackLayoutFileName}</div>
                                <span class="doc-file-ext ${rackLayoutFileExt == 'pdf' ? 'pdf' : rackLayoutFileExt == 'png' || rackLayoutFileExt == 'jpg' || rackLayoutFileExt == 'jpeg' || rackLayoutFileExt == 'svg' ? 'img' : 'default'}">${rackLayoutFileExt}</span>
                            </div>
                            <div class="doc-file-actions">
                                <a href="${pageContext.request.contextPath}/equipment/download/${equipment.equipmentId}/rack-layout" class="doc-download-btn">
                                    <i class="bi bi-download"></i> Download
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="doc-empty-state">
                            <div class="doc-type-icon rack" style="opacity:0.4;">
                                <i class="bi bi-grid-3x3-gap"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Rack Layout Diagram</div>
                                <div class="doc-file-name">No rack layout diagram uploaded</div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Maintenance Report -->
                <c:choose>
                    <c:when test="${not empty equipment.maintenanceReportPath}">
                        <div class="doc-file-item">
                            <div class="doc-type-icon maintenance">
                                <i class="bi bi-clipboard2-check"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Maintenance Report</div>
                                <div class="doc-file-name">${maintenanceReportFileName}</div>
                                <span class="doc-file-ext ${maintenanceReportFileExt == 'pdf' ? 'pdf' : maintenanceReportFileExt == 'doc' || maintenanceReportFileExt == 'docx' ? 'doc' : 'default'}">${maintenanceReportFileExt}</span>
                            </div>
                            <div class="doc-file-actions">
                                <a href="${pageContext.request.contextPath}/equipment/download/${equipment.equipmentId}/maintenance-report" class="doc-download-btn">
                                    <i class="bi bi-download"></i> Download
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="doc-empty-state">
                            <div class="doc-type-icon maintenance" style="opacity:0.4;">
                                <i class="bi bi-clipboard2-check"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Maintenance Report</div>
                                <div class="doc-file-name">No maintenance report uploaded</div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Equipment Photos -->
                <c:choose>
                    <c:when test="${not empty equipment.photosPath}">
                        <div class="doc-file-item">
                            <div class="doc-type-icon photos">
                                <i class="bi bi-camera"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Equipment Photos</div>
                                <div class="doc-file-name">${photosFileName}</div>
                                <span class="doc-file-ext img">${photosFileExt}</span>
                            </div>
                            <div class="doc-file-actions">
                                <a href="${pageContext.request.contextPath}/equipment/download/${equipment.equipmentId}/photos" class="doc-download-btn">
                                    <i class="bi bi-download"></i> Download
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="doc-empty-state">
                            <div class="doc-type-icon photos" style="opacity:0.4;">
                                <i class="bi bi-camera"></i>
                            </div>
                            <div class="doc-file-details">
                                <div class="doc-type-label">Equipment Photos</div>
                                <div class="doc-file-name">No equipment photos uploaded</div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Document Stats Bar -->
            <div class="doc-stats-bar">
                <div class="stat-item">
                    <i class="bi bi-paperclip"></i>
                    <span>Attached Files:</span>
                    <span class="count">
                        <c:set var="fileCount" value="0"/>
                        <c:if test="${not empty equipment.configFilePath}"><c:set var="fileCount" value="${fileCount + 1}"/></c:if>
                        <c:if test="${not empty equipment.networkDiagramRef}"><c:set var="fileCount" value="${fileCount + 1}"/></c:if>
                        <c:if test="${not empty equipment.rackLayoutDiagram}"><c:set var="fileCount" value="${fileCount + 1}"/></c:if>
                        <c:if test="${not empty equipment.maintenanceReportPath}"><c:set var="fileCount" value="${fileCount + 1}"/></c:if>
                        <c:if test="${not empty equipment.photosPath}"><c:set var="fileCount" value="${fileCount + 1}"/></c:if>
                        ${fileCount} / 5
                    </span>
                </div>
                <div class="stat-item">
                    <i class="bi bi-shield-check" style="color:var(--accent-green);"></i>
                    <span>Secure Storage</span>
                </div>
                <div class="stat-item" style="margin-left:auto;">
                    <a href="${pageContext.request.contextPath}/equipment/edit/${equipment.equipmentId}" style="color: var(--accent-blue); text-decoration: none; font-weight: 600; display: flex; align-items: center; gap: 4px;">
                        <i class="bi bi-cloud-arrow-up"></i> Manage Documents
                    </a>
                </div>
            </div>
        </div>

        <!-- Power & Environmental Section -->
        <c:if test="${not empty equipment.powerSource || not empty equipment.connectedPdu || not empty equipment.powerConsumption || not empty equipment.coolingZone}">
        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-lightning-charge"></i> Power & Environmental</h6>
                    <table class="table table-borderless mb-0" style="font-size:14px;">
                        <tr><td class="text-muted" style="width:40%;">Power Source</td><td>${equipment.powerSource}</td></tr>
                        <tr><td class="text-muted">Connected PDU</td><td>${equipment.connectedPdu}</td></tr>
                        <tr><td class="text-muted">Power Consumption</td><td>${equipment.powerConsumption} W</td></tr>
                        <tr><td class="text-muted">Temperature Range</td><td>${equipment.temperatureRange}</td></tr>
                        <tr><td class="text-muted">Humidity Level</td><td>${equipment.humidityLevel}</td></tr>
                        <tr><td class="text-muted">Cooling Zone</td><td>${equipment.coolingZone}</td></tr>
                    </table>
                </div>
            </div>
        </div>
        </c:if>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
