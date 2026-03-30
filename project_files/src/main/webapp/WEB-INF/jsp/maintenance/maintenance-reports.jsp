<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Maintenance Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Maintenance Reports</h4>
                <small class="text-muted">View, filter, and export all maintenance activities</small>
            </div>
            <div class="d-flex gap-2">
                <button onclick="exportPDF()" class="btn btn-danger shadow-sm"><i class="bi bi-file-earmark-pdf"></i> Export PDF</button>
                <button onclick="exportExcel()" class="btn btn-success shadow-sm"><i class="bi bi-file-earmark-excel"></i> Export Excel</button>
                <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Back to Scheduler
                </a>
            </div>
        </div>

        <!-- Filters -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <form method="get" class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">From Date</label>
                        <input type="date" name="startDate" class="form-control" value="${startDate}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">To Date</label>
                        <input type="date" name="endDate" class="form-control" value="${endDate}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Equipment</label>
                        <select name="equipmentType" class="form-select">
                            <option value="ALL" ${equipmentType == 'ALL' ? 'selected' : ''}>All</option>
                            <option value="UPS" ${equipmentType == 'UPS' ? 'selected' : ''}>UPS Only</option>
                            <option value="COOLING" ${equipmentType == 'COOLING' ? 'selected' : ''}>Cooling Only</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Technician</label>
                        <select name="technician" class="form-select">
                            <option value="">All Technicians</option>
                            <c:forEach var="tech" items="${technicianList}">
                                <option value="${tech.fullName}" ${selectedTechnician == tech.fullName ? 'selected' : ''}>${tech.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-funnel"></i> Filter
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- UPS Records -->
        <c:if test="${equipmentType == 'ALL' || equipmentType == 'UPS'}">
            <h6 class="mb-3 text-primary"><i class="bi bi-battery-charging"></i> UPS Maintenance Records
                <span class="badge bg-primary">${upsRecords.size()}</span>
            </h6>
            <div class="table-container mb-5">
                <table class="table table-hover" id="upsReportTable">
                    <thead class="table-light">
                        <tr>
                            <th>UPS Asset</th>
                            <th>Type</th>
                            <th>Date</th>
                            <th>Next Due</th>
                            <th>Technician</th>
                            <th>Vendor</th>
                            <th>Service Report</th>
                            <th>Generate Report</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${upsRecords}">
                        <tr>
                            <td><strong>${m.ups.assetTag}</strong></td>
                            <td>
                                <span class="badge ${m.maintenanceType == 'PREVENTIVE' ? 'bg-success' : 'bg-danger'}">${m.maintenanceType}</span>
                            </td>
                            <td>${m.maintenanceDate}</td>
                            <td>${m.nextDueDate}</td>
                            <td>${m.technician}</td>
                            <td>${m.vendor}</td>
                            <td>
                                <c:if test="${not empty m.serviceReportPath}">
                                    <a href="${pageContext.request.contextPath}/maintenance/download-report/ups/${m.maintenanceId}"
                                       class="btn btn-sm btn-outline-success" title="Download Report">
                                        <i class="bi bi-file-earmark-arrow-down"></i> Download
                                    </a>
                                </c:if>
                                <c:if test="${empty m.serviceReportPath}">
                                    <span class="text-muted">No report</span>
                                </c:if>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-outline-info"
                                        onclick="generateSingleReport('UPS', '${m.ups.assetTag}', '${m.maintenanceType}', '${m.maintenanceDate}', '${m.nextDueDate}', '${m.technician}', '${m.vendor}', '${m.remarks}')">
                                    <i class="bi bi-file-earmark-text"></i> Generate
                                </button>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty upsRecords}">
                            <tr><td colspan="8" class="text-center text-muted">No UPS maintenance records found for the selected filters.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>

        <!-- Cooling Records -->
        <c:if test="${equipmentType == 'ALL' || equipmentType == 'COOLING'}">
            <h6 class="mb-3 text-info"><i class="bi bi-snow2"></i> Cooling Maintenance Records
                <span class="badge bg-info">${coolingRecords.size()}</span>
            </h6>
            <div class="table-container mb-4">
                <table class="table table-hover" id="coolingReportTable">
                    <thead class="table-light">
                        <tr>
                            <th>Cooling Asset</th>
                            <th>Type</th>
                            <th>Date</th>
                            <th>Next Due</th>
                            <th>Technician</th>
                            <th>Service Report</th>
                            <th>Generate Report</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${coolingRecords}">
                        <tr>
                            <td><strong>${m.coolingUnit.assetTag}</strong></td>
                            <td>
                                <span class="badge ${m.maintenanceType == 'PREVENTIVE' ? 'bg-success' : 'bg-danger'}">${m.maintenanceType}</span>
                            </td>
                            <td>${m.maintenanceDate}</td>
                            <td>${m.nextMaintenanceDate}</td>
                            <td>${m.technician}</td>
                            <td>
                                <c:if test="${not empty m.serviceReportPath}">
                                    <a href="${pageContext.request.contextPath}/maintenance/download-report/cooling/${m.maintenanceId}"
                                       class="btn btn-sm btn-outline-success" title="Download Report">
                                        <i class="bi bi-file-earmark-arrow-down"></i> Download
                                    </a>
                                </c:if>
                                <c:if test="${empty m.serviceReportPath}">
                                    <span class="text-muted">No report</span>
                                </c:if>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-outline-info"
                                        onclick="generateSingleReport('COOLING', '${m.coolingUnit.assetTag}', '${m.maintenanceType}', '${m.maintenanceDate}', '${m.nextMaintenanceDate}', '${m.technician}', '', '${m.remarks}')">
                                    <i class="bi bi-file-earmark-text"></i> Generate
                                </button>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty coolingRecords}">
                            <tr><td colspan="7" class="text-center text-muted">No cooling maintenance records found for the selected filters.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>

<script>
    // Generate a PDF report for a single maintenance record
    function generateSingleReport(type, asset, maintType, date, nextDue, tech, vendor, remarks) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        doc.setFontSize(18);
        doc.setFont('helvetica', 'bold');
        doc.text('SPCMS - Maintenance Report', 14, 20);

        doc.setFontSize(11);
        doc.setFont('helvetica', 'normal');
        doc.text('Generated: ' + new Date().toLocaleDateString(), 14, 28);

        doc.setDrawColor(13, 110, 253);
        doc.setLineWidth(0.5);
        doc.line(14, 32, 196, 32);

        var y = 42;
        var details = [
            ['Equipment Type', type],
            ['Asset Tag', asset],
            ['Maintenance Type', maintType],
            ['Maintenance Date', date],
            ['Next Due Date', nextDue || 'N/A'],
            ['Technician', tech || 'N/A'],
            ['Vendor', vendor || 'N/A'],
            ['Remarks', remarks || 'N/A']
        ];

        details.forEach(function(row) {
            doc.setFont('helvetica', 'bold');
            doc.text(row[0] + ':', 14, y);
            doc.setFont('helvetica', 'normal');
            doc.text(row[1], 70, y);
            y += 8;
        });

        doc.setFontSize(9);
        doc.setTextColor(128);
        doc.text('Smart Power & Cooling Management System (SPCMS)', 14, 280);

        doc.save('maintenance-report-' + asset + '-' + date + '.pdf');
    }

    // Export full maintenance report as PDF
    function exportPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('landscape');
        doc.setFontSize(16);
        doc.text('SPCMS - Full Maintenance Report', 14, 15);
        doc.setFontSize(10);
        doc.text('Generated: ' + new Date().toLocaleDateString(), 14, 22);

        var startY = 30;
        var upsTable = document.getElementById('upsReportTable');
        if (upsTable) {
            doc.setFontSize(12);
            doc.text('UPS Maintenance Records', 14, startY);
            doc.autoTable({
                startY: startY + 4,
                html: '#upsReportTable',
                styles: { fontSize: 7 },
                headStyles: { fillColor: [13, 110, 253] },
                columns: [0, 1, 2, 3, 4, 5, 6].map(function(i) { return { dataKey: i }; })
            });
            startY = doc.lastAutoTable.finalY + 12;
        }

        var coolingTable = document.getElementById('coolingReportTable');
        if (coolingTable) {
            doc.setFontSize(12);
            doc.text('Cooling Maintenance Records', 14, startY);
            doc.autoTable({
                startY: startY + 4,
                html: '#coolingReportTable',
                styles: { fontSize: 7 },
                headStyles: { fillColor: [13, 202, 240] },
                columns: [0, 1, 2, 3, 4, 5].map(function(i) { return { dataKey: i }; })
            });
        }

        doc.save('spcms-full-maintenance-report.pdf');
    }

    // Export full maintenance report as Excel
    function exportExcel() {
        var wb = XLSX.utils.book_new();

        var headerData = [
            ['SPCMS - Full Maintenance Report'],
            ['Generated', new Date().toLocaleDateString()],
            []
        ];

        var upsTable = document.getElementById('upsReportTable');
        if (upsTable) {
            var ws1 = XLSX.utils.aoa_to_sheet([['UPS Maintenance Records'], []]);
            XLSX.utils.sheet_add_dom(ws1, upsTable, { origin: 'A3' });
            XLSX.utils.book_append_sheet(wb, ws1, 'UPS Maintenance');
        }

        var coolingTable = document.getElementById('coolingReportTable');
        if (coolingTable) {
            var ws2 = XLSX.utils.aoa_to_sheet([['Cooling Maintenance Records'], []]);
            XLSX.utils.sheet_add_dom(ws2, coolingTable, { origin: 'A3' });
            XLSX.utils.book_append_sheet(wb, ws2, 'Cooling Maintenance');
        }

        XLSX.writeFile(wb, 'spcms-full-maintenance-report.xlsx');
    }
</script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
