<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${equipment.equipmentId != null ? 'Edit' : 'Add'} Equipment</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        /* === Documentation & Attachments Styles === */
        .doc-upload-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 16px;
        }
        .doc-upload-card {
            border: 2px dashed #d1d5db;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s ease;
            background: #fafbfc;
            position: relative;
            cursor: pointer;
        }
        .doc-upload-card:hover {
            border-color: var(--accent-blue);
            background: #f0f4ff;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.12);
        }
        .doc-upload-card.drag-over {
            border-color: var(--accent-blue);
            background: #e8f0fe;
            border-style: solid;
        }
        .doc-upload-card.has-file {
            border-color: var(--accent-green);
            border-style: solid;
            background: #f0fdf4;
        }
        .doc-upload-card.has-file:hover {
            background: #ecfdf5;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.12);
        }
        .doc-upload-icon {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 12px;
            font-size: 24px;
        }
        .doc-upload-icon.config { background: linear-gradient(135deg, #dbeafe, #bfdbfe); color: #2563eb; }
        .doc-upload-icon.network { background: linear-gradient(135deg, #fce7f3, #fbcfe8); color: #db2777; }
        .doc-upload-icon.rack { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #d97706; }
        .doc-upload-icon.maintenance { background: linear-gradient(135deg, #d1fae5, #a7f3d0); color: #059669; }
        .doc-upload-icon.photos { background: linear-gradient(135deg, #e0e7ff, #c7d2fe); color: #4f46e5; }

        .doc-upload-title {
            font-weight: 600;
            font-size: 14px;
            color: #1f2937;
            margin-bottom: 4px;
        }
        .doc-upload-desc {
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 12px;
        }
        .doc-upload-input {
            display: none;
        }
        .doc-upload-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            font-size: 13px;
            font-weight: 500;
            border-radius: 8px;
            border: 1px solid #d1d5db;
            background: white;
            color: #374151;
            cursor: pointer;
            transition: all 0.2s;
        }
        .doc-upload-btn:hover {
            background: #f3f4f6;
            border-color: #9ca3af;
        }
        .doc-file-info {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: white;
            border-radius: 8px;
            border: 1px solid #d1d5db;
            margin-top: 10px;
            font-size: 13px;
        }
        .doc-file-info .file-icon {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0;
        }
        .doc-file-info .file-icon.pdf { background: #fee2e2; color: #dc2626; }
        .doc-file-info .file-icon.img { background: #dbeafe; color: #2563eb; }
        .doc-file-info .file-icon.doc { background: #e0e7ff; color: #4f46e5; }
        .doc-file-info .file-icon.default { background: #f3f4f6; color: #6b7280; }

        .doc-file-info .file-name {
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            color: #1f2937;
            font-weight: 500;
        }
        .doc-file-info .file-size {
            color: #9ca3af;
            font-size: 11px;
            white-space: nowrap;
        }
        .doc-file-remove {
            width: 24px;
            height: 24px;
            border-radius: 6px;
            border: none;
            background: #fee2e2;
            color: #dc2626;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            flex-shrink: 0;
        }
        .doc-file-remove:hover {
            background: #fecaca;
        }
        .doc-section-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 16px;
        }
        .doc-section-header .section-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: linear-gradient(135deg, #3b82f6, #8b5cf6);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }
        .doc-section-header h6 {
            margin: 0;
            font-weight: 700;
            font-size: 15px;
        }
        .doc-section-header p {
            margin: 0;
            font-size: 12px;
            color: #6b7280;
        }
        .doc-formats-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 8px;
            background: #f3f4f6;
            border-radius: 6px;
            font-size: 10px;
            color: #6b7280;
            font-weight: 500;
            margin-top: 6px;
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">${equipment.equipmentId != null ? 'Edit' : 'Register New'} Equipment</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Complete equipment record with all technical specifications</p>
            </div>
            <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/equipment/save" method="post" enctype="multipart/form-data">
                <c:if test="${equipment.equipmentId != null}">
                    <input type="hidden" name="equipmentId" value="${equipment.equipmentId}"/>
                </c:if>

                <h6 class="fw-bold mb-3">Basic Information</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Asset Tag Number <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="assetTagNumber" value="${equipment.assetTagNumber}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Equipment Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="equipmentName" value="${equipment.equipmentName}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Equipment Type</label>
                        <input type="text" class="form-control" name="equipmentType" value="${equipment.equipmentType}" placeholder="e.g., Server, Switch, Router"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Brand / Manufacturer</label>
                        <input type="text" class="form-control" name="brandManufacturer" value="${equipment.brandManufacturer}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Model Number</label>
                        <input type="text" class="form-control" name="modelNumber" value="${equipment.modelNumber}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Serial Number</label>
                        <input type="text" class="form-control" name="serialNumber" value="${equipment.serialNumber}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Hostname</label>
                        <input type="text" class="form-control" name="hostname" value="${equipment.hostname}"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Network Information</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">IP Address</label>
                        <input type="text" class="form-control" name="ipAddress" value="${equipment.ipAddress}" placeholder="e.g., 192.168.1.100"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">MAC Address</label>
                        <input type="text" class="form-control" name="macAddress" value="${equipment.macAddress}" placeholder="e.g., AA:BB:CC:DD:EE:FF"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Network Ports</label>
                        <input type="number" class="form-control" name="networkPortsCount" value="${equipment.networkPortsCount}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">VLAN Assignment</label>
                        <input type="text" class="form-control" name="vlanAssignment" value="${equipment.vlanAssignment}"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Location</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Data Center</label>
                        <input type="text" class="form-control" name="dataCenterName" value="${equipment.dataCenterName}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Room</label>
                        <input type="text" class="form-control" name="roomName" value="${equipment.roomName}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Rack Number</label>
                        <input type="text" class="form-control" name="rackNumber" value="${equipment.rackNumber}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Rack Unit Position</label>
                        <input type="text" class="form-control" name="rackUnitPosition" value="${equipment.rackUnitPosition}" placeholder="e.g., U12"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Technical Specifications</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">CPU Type</label>
                        <input type="text" class="form-control" name="cpuType" value="${equipment.cpuType}" placeholder="e.g., Intel Xeon E5-2680"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">RAM Size</label>
                        <input type="text" class="form-control" name="ramSize" value="${equipment.ramSize}" placeholder="e.g., 64GB DDR4"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Storage Capacity</label>
                        <input type="text" class="form-control" name="storageCapacity" value="${equipment.storageCapacity}" placeholder="e.g., 2TB SSD"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Operating System</label>
                        <input type="text" class="form-control" name="operatingSystem" value="${equipment.operatingSystem}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Firmware Version</label>
                        <input type="text" class="form-control" name="firmwareVersion" value="${equipment.firmwareVersion}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Power Rating</label>
                        <input type="text" class="form-control" name="powerRating" value="${equipment.powerRating}"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Power &amp; Environmental Monitoring</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Power Source</label>
                        <input type="text" class="form-control" name="powerSource" value="${equipment.powerSource}" placeholder="e.g., Utility, UPS"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Connected PDU</label>
                        <input type="text" class="form-control" name="connectedPdu" value="${equipment.connectedPdu}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Temperature Range</label>
                        <input type="text" class="form-control" name="temperatureRange" value="${equipment.temperatureRange}" placeholder="e.g., 18-27C"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Humidity Level</label>
                        <input type="text" class="form-control" name="humidityLevel" value="${equipment.humidityLevel}" placeholder="e.g., 45%"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Power Consumption (kW)</label>
                        <input type="number" step="0.01" class="form-control" name="powerConsumption" value="${equipment.powerConsumption}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Cooling Zone</label>
                        <input type="text" class="form-control" name="coolingZone" value="${equipment.coolingZone}"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Procurement & Warranty</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Purchase Date</label>
                        <input type="date" class="form-control" name="purchaseDate" value="${equipment.purchaseDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Supplier Name</label>
                        <input type="text" class="form-control" name="supplierName" value="${equipment.supplierName}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Purchase Order #</label>
                        <input type="text" class="form-control" name="purchaseOrderNumber" value="${equipment.purchaseOrderNumber}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Invoice Number</label>
                        <input type="text" class="form-control" name="invoiceNumber" value="${equipment.invoiceNumber}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Warranty Start</label>
                        <input type="date" class="form-control" name="warrantyStartDate" value="${equipment.warrantyStartDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Warranty Expiry</label>
                        <input type="date" class="form-control" name="warrantyExpiryDate" value="${equipment.warrantyExpiryDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Cost</label>
                        <input type="number" step="0.01" class="form-control" name="cost" value="${equipment.cost}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Funding Source</label>
                        <input type="text" class="form-control" name="fundingSource" value="${equipment.fundingSource}"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Maintenance & Support</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Maintenance Status</label>
                        <select class="form-select" name="maintenanceStatus">
                            <option value="ACTIVE" ${equipment.maintenanceStatus == 'ACTIVE' ? 'selected' : ''}>Active</option>
                            <option value="FAULTY" ${equipment.maintenanceStatus == 'FAULTY' ? 'selected' : ''}>Faulty</option>
                            <option value="UNDER_REPAIR" ${equipment.maintenanceStatus == 'UNDER_REPAIR' ? 'selected' : ''}>Under Repair</option>
                            <option value="DECOMMISSIONED" ${equipment.maintenanceStatus == 'DECOMMISSIONED' ? 'selected' : ''}>Decommissioned</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Last Maintenance</label>
                        <input type="date" class="form-control" name="lastMaintenanceDate" value="${equipment.lastMaintenanceDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Next Maintenance Due</label>
                        <input type="date" class="form-control" name="nextMaintenanceDue" value="${equipment.nextMaintenanceDue}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Support Vendor</label>
                        <input type="text" class="form-control" name="supportVendor" value="${equipment.supportVendor}"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Power & Environmental Monitoring</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Power Source</label>
                        <input type="text" class="form-control" name="powerSource" value="${equipment.powerSource}" placeholder="e.g., UPS-A1, PDU-B2"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Connected PDU</label>
                        <input type="text" class="form-control" name="connectedPdu" value="${equipment.connectedPdu}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Temperature Range</label>
                        <input type="text" class="form-control" name="temperatureRange" value="${equipment.temperatureRange}" placeholder="e.g., 18-27°C"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Humidity Level</label>
                        <input type="text" class="form-control" name="humidityLevel" value="${equipment.humidityLevel}" placeholder="e.g., 40-60%"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Power Consumption (W)</label>
                        <input type="number" step="0.01" class="form-control" name="powerConsumption" value="${equipment.powerConsumption}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Cooling Zone</label>
                        <input type="text" class="form-control" name="coolingZone" value="${equipment.coolingZone}"/>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Lifecycle</h6>
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label">Installation Date</label>
                        <input type="date" class="form-control" name="installationDate" value="${equipment.installationDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Commissioning Date</label>
                        <input type="date" class="form-control" name="commissioningDate" value="${equipment.commissioningDate}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">End of Life</label>
                        <input type="date" class="form-control" name="endOfLife" value="${equipment.endOfLife}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">End of Support</label>
                        <input type="date" class="form-control" name="endOfSupport" value="${equipment.endOfSupport}"/>
                    </div>
                </div>

                <!-- ============================================================ -->
                <!-- 8. DOCUMENTATION & ATTACHMENTS -->
                <!-- ============================================================ -->
                <div style="border-top: 2px solid #e5e7eb; margin-top: 8px; padding-top: 24px;">
                    <div class="doc-section-header">
                        <div class="section-icon">
                            <i class="bi bi-folder2-open"></i>
                        </div>
                        <div>
                            <h6>Documentation & Attachments</h6>
                            <p>Upload configuration files, diagrams, reports, and photos for this equipment</p>
                        </div>
                    </div>

                    <div class="doc-upload-grid mb-4">

                        <!-- Config File -->
                        <div class="doc-upload-card ${not empty equipment.configFilePath ? 'has-file' : ''}" id="configCard" onclick="document.getElementById('configFile').click()">
                            <div class="doc-upload-icon config">
                                <i class="bi bi-file-earmark-code"></i>
                            </div>
                            <div class="doc-upload-title">Configuration File</div>
                            <div class="doc-upload-desc">Device configs, startup scripts, settings</div>
                            <input type="file" class="doc-upload-input" id="configFile" name="configFile"
                                   accept=".cfg,.conf,.xml,.json,.yaml,.yml,.txt,.ini,.log,.csv" onchange="handleFileSelect(this, 'configCard', 'configInfo')"/>
                            <div class="doc-upload-btn" onclick="event.stopPropagation(); document.getElementById('configFile').click()">
                                <i class="bi bi-cloud-arrow-up"></i>
                                ${not empty equipment.configFilePath ? 'Replace File' : 'Choose File'}
                            </div>
                            <c:if test="${not empty configFileName}">
                                <div class="doc-file-info" id="configExisting">
                                    <div class="file-icon default"><i class="bi bi-file-earmark-code"></i></div>
                                    <span class="file-name">${configFileName}</span>
                                    <span class="badge bg-success" style="font-size:10px;">Uploaded</span>
                                </div>
                            </c:if>
                            <div class="doc-file-info" id="configInfo" style="display:none;"></div>
                            <div class="doc-formats-badge"><i class="bi bi-info-circle"></i> CFG, XML, JSON, YAML, TXT</div>
                        </div>

                        <!-- Network Diagram -->
                        <div class="doc-upload-card ${not empty equipment.networkDiagramRef ? 'has-file' : ''}" id="networkCard" onclick="document.getElementById('networkDiagramFile').click()">
                            <div class="doc-upload-icon network">
                                <i class="bi bi-diagram-3"></i>
                            </div>
                            <div class="doc-upload-title">Network Diagram</div>
                            <div class="doc-upload-desc">Network topology, VLAN maps, cable maps</div>
                            <input type="file" class="doc-upload-input" id="networkDiagramFile" name="networkDiagramFile"
                                   accept=".pdf,.png,.jpg,.jpeg,.svg,.vsd,.vsdx,.drawio" onchange="handleFileSelect(this, 'networkCard', 'networkInfo')"/>
                            <div class="doc-upload-btn" onclick="event.stopPropagation(); document.getElementById('networkDiagramFile').click()">
                                <i class="bi bi-cloud-arrow-up"></i>
                                ${not empty equipment.networkDiagramRef ? 'Replace File' : 'Choose File'}
                            </div>
                            <c:if test="${not empty networkDiagramFileName}">
                                <div class="doc-file-info" id="networkExisting">
                                    <div class="file-icon img"><i class="bi bi-diagram-3"></i></div>
                                    <span class="file-name">${networkDiagramFileName}</span>
                                    <span class="badge bg-success" style="font-size:10px;">Uploaded</span>
                                </div>
                            </c:if>
                            <div class="doc-file-info" id="networkInfo" style="display:none;"></div>
                            <div class="doc-formats-badge"><i class="bi bi-info-circle"></i> PDF, PNG, JPG, SVG, Visio</div>
                        </div>

                        <!-- Rack Layout Diagram -->
                        <div class="doc-upload-card ${not empty equipment.rackLayoutDiagram ? 'has-file' : ''}" id="rackCard" onclick="document.getElementById('rackLayoutFile').click()">
                            <div class="doc-upload-icon rack">
                                <i class="bi bi-grid-3x3-gap"></i>
                            </div>
                            <div class="doc-upload-title">Rack Layout Diagram</div>
                            <div class="doc-upload-desc">Rack elevation, U-position layouts</div>
                            <input type="file" class="doc-upload-input" id="rackLayoutFile" name="rackLayoutFile"
                                   accept=".pdf,.png,.jpg,.jpeg,.svg,.vsd,.vsdx,.xlsx,.drawio" onchange="handleFileSelect(this, 'rackCard', 'rackInfo')"/>
                            <div class="doc-upload-btn" onclick="event.stopPropagation(); document.getElementById('rackLayoutFile').click()">
                                <i class="bi bi-cloud-arrow-up"></i>
                                ${not empty equipment.rackLayoutDiagram ? 'Replace File' : 'Choose File'}
                            </div>
                            <c:if test="${not empty rackLayoutFileName}">
                                <div class="doc-file-info" id="rackExisting">
                                    <div class="file-icon img"><i class="bi bi-grid-3x3-gap"></i></div>
                                    <span class="file-name">${rackLayoutFileName}</span>
                                    <span class="badge bg-success" style="font-size:10px;">Uploaded</span>
                                </div>
                            </c:if>
                            <div class="doc-file-info" id="rackInfo" style="display:none;"></div>
                            <div class="doc-formats-badge"><i class="bi bi-info-circle"></i> PDF, PNG, JPG, SVG, Excel</div>
                        </div>

                        <!-- Maintenance Report -->
                        <div class="doc-upload-card ${not empty equipment.maintenanceReportPath ? 'has-file' : ''}" id="maintCard" onclick="document.getElementById('maintenanceReportFile').click()">
                            <div class="doc-upload-icon maintenance">
                                <i class="bi bi-clipboard2-check"></i>
                            </div>
                            <div class="doc-upload-title">Maintenance Report</div>
                            <div class="doc-upload-desc">Service reports, inspection records</div>
                            <input type="file" class="doc-upload-input" id="maintenanceReportFile" name="maintenanceReportFile"
                                   accept=".pdf,.doc,.docx,.xlsx,.xls,.txt,.csv" onchange="handleFileSelect(this, 'maintCard', 'maintInfo')"/>
                            <div class="doc-upload-btn" onclick="event.stopPropagation(); document.getElementById('maintenanceReportFile').click()">
                                <i class="bi bi-cloud-arrow-up"></i>
                                ${not empty equipment.maintenanceReportPath ? 'Replace File' : 'Choose File'}
                            </div>
                            <c:if test="${not empty maintenanceReportFileName}">
                                <div class="doc-file-info" id="maintExisting">
                                    <div class="file-icon doc"><i class="bi bi-clipboard2-check"></i></div>
                                    <span class="file-name">${maintenanceReportFileName}</span>
                                    <span class="badge bg-success" style="font-size:10px;">Uploaded</span>
                                </div>
                            </c:if>
                            <div class="doc-file-info" id="maintInfo" style="display:none;"></div>
                            <div class="doc-formats-badge"><i class="bi bi-info-circle"></i> PDF, DOC, DOCX, Excel</div>
                        </div>

                        <!-- Equipment Photos -->
                        <div class="doc-upload-card ${not empty equipment.photosPath ? 'has-file' : ''}" id="photosCard" onclick="document.getElementById('photosFile').click()">
                            <div class="doc-upload-icon photos">
                                <i class="bi bi-camera"></i>
                            </div>
                            <div class="doc-upload-title">Equipment Photos</div>
                            <div class="doc-upload-desc">Equipment photos, labels, serial plates</div>
                            <input type="file" class="doc-upload-input" id="photosFile" name="photosFile"
                                   accept=".png,.jpg,.jpeg,.gif,.bmp,.webp,.heic" onchange="handleFileSelect(this, 'photosCard', 'photosInfo')"/>
                            <div class="doc-upload-btn" onclick="event.stopPropagation(); document.getElementById('photosFile').click()">
                                <i class="bi bi-cloud-arrow-up"></i>
                                ${not empty equipment.photosPath ? 'Replace File' : 'Choose File'}
                            </div>
                            <c:if test="${not empty photosFileName}">
                                <div class="doc-file-info" id="photosExisting">
                                    <div class="file-icon img"><i class="bi bi-camera"></i></div>
                                    <span class="file-name">${photosFileName}</span>
                                    <span class="badge bg-success" style="font-size:10px;">Uploaded</span>
                                </div>
                            </c:if>
                            <div class="doc-file-info" id="photosInfo" style="display:none;"></div>
                            <div class="doc-formats-badge"><i class="bi bi-info-circle"></i> PNG, JPG, GIF, WebP</div>
                        </div>

                    </div>

                    <div class="d-flex align-items-center gap-2 mb-3" style="font-size:12px; color:#6b7280;">
                        <i class="bi bi-shield-check" style="color:var(--accent-green);"></i>
                        <span>Maximum file size: 10MB per file. Files are securely stored and only accessible by authorized users.</span>
                    </div>
                </div>

                <div class="d-flex gap-2 mt-3">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Save Equipment</button>
                    <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // File selection handler with preview info
        function handleFileSelect(input, cardId, infoId) {
            const card = document.getElementById(cardId);
            const infoDiv = document.getElementById(infoId);

            if (input.files && input.files[0]) {
                const file = input.files[0];
                const fileSize = formatFileSize(file.size);
                const ext = file.name.split('.').pop().toLowerCase();
                const iconClass = getFileIconClass(ext);

                card.classList.add('has-file');
                infoDiv.innerHTML =
                    '<div class="file-icon ' + iconClass + '"><i class="bi ' + getFileIcon(ext) + '"></i></div>' +
                    '<span class="file-name">' + file.name + '</span>' +
                    '<span class="file-size">' + fileSize + '</span>' +
                    '<button type="button" class="doc-file-remove" onclick="event.stopPropagation(); clearFile(\'' + input.id + '\', \'' + cardId + '\', \'' + infoId + '\')"><i class="bi bi-x"></i></button>';
                infoDiv.style.display = 'flex';

                // Hide existing file info if present
                const existingInfo = card.querySelector('[id$="Existing"]');
                if (existingInfo) existingInfo.style.display = 'none';
            }
        }

        // Clear selected file
        function clearFile(inputId, cardId, infoId) {
            const input = document.getElementById(inputId);
            const card = document.getElementById(cardId);
            const infoDiv = document.getElementById(infoId);

            input.value = '';
            infoDiv.style.display = 'none';
            infoDiv.innerHTML = '';

            // Show existing file info if present
            const existingInfo = card.querySelector('[id$="Existing"]');
            if (existingInfo) {
                existingInfo.style.display = 'flex';
            } else {
                card.classList.remove('has-file');
            }
        }

        // Format file size
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 B';
            const k = 1024;
            const sizes = ['B', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
        }

        // Get icon class based on file extension
        function getFileIconClass(ext) {
            if (['pdf'].includes(ext)) return 'pdf';
            if (['png','jpg','jpeg','gif','bmp','svg','webp'].includes(ext)) return 'img';
            if (['doc','docx','xls','xlsx'].includes(ext)) return 'doc';
            return 'default';
        }

        // Get Bootstrap icon based on file extension
        function getFileIcon(ext) {
            if (['pdf'].includes(ext)) return 'bi-file-earmark-pdf';
            if (['png','jpg','jpeg','gif','bmp','webp'].includes(ext)) return 'bi-file-earmark-image';
            if (['svg','vsd','vsdx','drawio'].includes(ext)) return 'bi-file-earmark-richtext';
            if (['doc','docx'].includes(ext)) return 'bi-file-earmark-word';
            if (['xls','xlsx','csv'].includes(ext)) return 'bi-file-earmark-spreadsheet';
            if (['cfg','conf','json','yaml','yml','xml','ini'].includes(ext)) return 'bi-file-earmark-code';
            if (['txt','log'].includes(ext)) return 'bi-file-earmark-text';
            return 'bi-file-earmark';
        }

        // Drag and drop support
        document.querySelectorAll('.doc-upload-card').forEach(card => {
            card.addEventListener('dragover', (e) => {
                e.preventDefault();
                card.classList.add('drag-over');
            });
            card.addEventListener('dragleave', () => {
                card.classList.remove('drag-over');
            });
            card.addEventListener('drop', (e) => {
                e.preventDefault();
                card.classList.remove('drag-over');
                const input = card.querySelector('input[type="file"]');
                if (e.dataTransfer.files.length > 0) {
                    input.files = e.dataTransfer.files;
                    const changeEvent = new Event('change', { bubbles: true });
                    input.dispatchEvent(changeEvent);
                }
            });
        });
    </script>
</body>
</html>
