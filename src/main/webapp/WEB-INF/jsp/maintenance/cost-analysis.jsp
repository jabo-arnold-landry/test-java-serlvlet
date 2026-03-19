<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Cost Analysis</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .stat-card { border-left: 4px solid; border-radius: 8px; }
        .stat-card.blue { border-color: #0d6efd; }
        .stat-card.cyan { border-color: #0dcaf0; }
        .stat-card.green { border-color: #198754; }
        .stat-card.orange { border-color: #fd7e14; }
        .stat-card.purple { border-color: #6f42c1; }
        .stat-card.red { border-color: #dc3545; }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Maintenance Cost Analysis</h4>
                <small class="text-muted">Review and analyze maintenance expenditures</small>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline-secondary me-2">
                    <i class="bi bi-arrow-left"></i> Back
                </a>
                <button onclick="exportPDF()" class="btn btn-danger me-2">
                    <i class="bi bi-file-earmark-pdf"></i> Export PDF
                </button>
                <button onclick="exportExcel()" class="btn btn-success">
                    <i class="bi bi-file-earmark-excel"></i> Export Excel
                </button>
            </div>
        </div>

        <!-- Date Filter -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <form method="get" class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">From Date</label>
                        <input type="date" name="startDate" class="form-control" value="${startDate}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">To Date</label>
                        <input type="date" name="endDate" class="form-control" value="${endDate}">
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-funnel"></i> Filter Results
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Summary Cards Row 1 -->
        <div class="row mb-3">
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm stat-card blue h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-battery-charging"></i> Total UPS Cost</div>
                        <h5 class="text-primary fw-bold mb-0">RWF <fmt:formatNumber value="${totalUpsCost}" type="number" minFractionDigits="2"/></h5>
                        <small class="text-muted">${upsMaintenance.size()} records</small>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm stat-card cyan h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-snow2"></i> Total Cooling Cost</div>
                        <h5 class="text-info fw-bold mb-0">RWF <fmt:formatNumber value="${totalCoolingCost}" type="number" minFractionDigits="2"/></h5>
                        <small class="text-muted">${coolingMaintenance.size()} records</small>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm stat-card green h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-cash-stack"></i> Grand Total</div>
                        <h5 class="text-success fw-bold mb-0">RWF <fmt:formatNumber value="${grandTotal}" type="number" minFractionDigits="2"/></h5>
                        <small class="text-muted">All maintenance combined</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Summary Cards Row 2 -->
        <div class="row mb-4">
            <div class="col-md-3 mb-3">
                <div class="card border-0 shadow-sm stat-card orange h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-shield-check"></i> UPS Preventive</div>
                        <h6 class="fw-bold mb-0">RWF <fmt:formatNumber value="${upsPreventiveCost}" type="number" minFractionDigits="2"/></h6>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="card border-0 shadow-sm stat-card red h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-wrench"></i> UPS Corrective</div>
                        <h6 class="fw-bold mb-0">RWF <fmt:formatNumber value="${upsCorrectiveCost}" type="number" minFractionDigits="2"/></h6>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="card border-0 shadow-sm stat-card orange h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-shield-check"></i> Cooling Preventive</div>
                        <h6 class="fw-bold mb-0">RWF <fmt:formatNumber value="${coolingPreventiveCost}" type="number" minFractionDigits="2"/></h6>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="card border-0 shadow-sm stat-card red h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-wrench"></i> Cooling Corrective</div>
                        <h6 class="fw-bold mb-0">RWF <fmt:formatNumber value="${coolingCorrectiveCost}" type="number" minFractionDigits="2"/></h6>
                    </div>
                </div>
            </div>
        </div>

        <!-- Average Cost Cards -->
        <div class="row mb-4">
            <div class="col-md-6 mb-3">
                <div class="card border-0 shadow-sm stat-card purple h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-calculator"></i> Avg UPS Maintenance Cost</div>
                        <h6 class="fw-bold mb-0">RWF <fmt:formatNumber value="${avgUpsCost}" type="number" minFractionDigits="2"/> per record</h6>
                    </div>
                </div>
            </div>
            <div class="col-md-6 mb-3">
                <div class="card border-0 shadow-sm stat-card purple h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-calculator"></i> Avg Cooling Maintenance Cost</div>
                        <h6 class="fw-bold mb-0">RWF <fmt:formatNumber value="${avgCoolingCost}" type="number" minFractionDigits="2"/> per record</h6>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <h6 class="fw-bold mb-3">UPS vs Cooling Distribution</h6>
                        <canvas id="pieChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <h6 class="fw-bold mb-3">Preventive vs Corrective</h6>
                        <canvas id="typeChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <h6 class="fw-bold mb-3">Cost Comparison</h6>
                        <canvas id="barChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- UPS Table -->
        <h6 class="mb-3 text-primary"><i class="bi bi-battery-charging"></i> UPS Maintenance Records</h6>
        <div class="table-container mb-5">
            <table class="table table-hover" id="upsTableEl">
                <thead class="table-light">
                    <tr><th>UPS Asset Tag</th><th>Type</th><th>Date</th><th>Next Due</th><th>Technician</th><th>Vendor</th><th>Cost (RWF)</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${upsMaintenance}">
                    <tr>
                        <td><strong>${m.ups.assetTag}</strong></td>
                        <td><span class="badge ${m.maintenanceType == 'PREVENTIVE' ? 'bg-success' : 'bg-danger'}">${m.maintenanceType}</span></td>
                        <td>${m.maintenanceDate}</td>
                        <td>${m.nextDueDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.vendor}</td>
                        <td><fmt:formatNumber value="${m.maintenanceCost}" type="number" minFractionDigits="2"/></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty upsMaintenance}">
                        <tr><td colspan="7" class="text-center text-muted">No UPS maintenance records for this period.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Cooling Table -->
        <h6 class="mb-3 text-info"><i class="bi bi-snow2"></i> Cooling Maintenance Records</h6>
        <div class="table-container mb-4">
            <table class="table table-hover" id="coolingTableEl">
                <thead class="table-light">
                    <tr><th>Cooling Asset Tag</th><th>Type</th><th>Date</th><th>Technician</th><th>Next Due</th><th>Cost (RWF)</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${coolingMaintenance}">
                    <tr>
                        <td><strong>${m.coolingUnit.assetTag}</strong></td>
                        <td><span class="badge ${m.maintenanceType == 'PREVENTIVE' ? 'bg-success' : 'bg-danger'}">${m.maintenanceType}</span></td>
                        <td>${m.maintenanceDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.nextMaintenanceDate}</td>
                        <td><fmt:formatNumber value="${m.maintenanceCost}" type="number" minFractionDigits="2"/></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty coolingMaintenance}">
                        <tr><td colspan="6" class="text-center text-muted">No cooling maintenance records for this period.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

<script>
    const upsCost = parseFloat("${totalUpsCost}") || 0;
    const coolingCost = parseFloat("${totalCoolingCost}") || 0;
    const upsPreventive = parseFloat("${upsPreventiveCost}") || 0;
    const upsCorrective = parseFloat("${upsCorrectiveCost}") || 0;
    const coolingPreventive = parseFloat("${coolingPreventiveCost}") || 0;
    const coolingCorrective = parseFloat("${coolingCorrectiveCost}") || 0;

    // Pie Chart - UPS vs Cooling
    new Chart(document.getElementById('pieChart'), {
        type: 'doughnut',
        data: {
            labels: ['UPS', 'Cooling'],
            datasets: [{ data: [upsCost, coolingCost], backgroundColor: ['#0d6efd','#0dcaf0'], borderWidth: 2 }]
        },
        options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
    });

    // Type Chart - Preventive vs Corrective
    new Chart(document.getElementById('typeChart'), {
        type: 'doughnut',
        data: {
            labels: ['UPS Preventive','UPS Corrective','Cooling Preventive','Cooling Corrective'],
            datasets: [{ data: [upsPreventive, upsCorrective, coolingPreventive, coolingCorrective],
                backgroundColor: ['#198754','#dc3545','#0dcaf0','#fd7e14'], borderWidth: 2 }]
        },
        options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
    });

    // Bar Chart
    new Chart(document.getElementById('barChart'), {
        type: 'bar',
        data: {
            labels: ['UPS Prev.','UPS Corr.','Cool. Prev.','Cool. Corr.'],
            datasets: [{
                label: 'Cost (RWF)',
                data: [upsPreventive, upsCorrective, coolingPreventive, coolingCorrective],
                backgroundColor: ['#198754','#dc3545','#0dcaf0','#fd7e14'],
                borderRadius: 6
            }]
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
    });

    function exportPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(16);
        doc.text('Maintenance Cost Analysis Report', 14, 15);
        doc.setFontSize(10);
        doc.text('Period: ${startDate} to ${endDate}', 14, 22);
        doc.text('Generated: ' + new Date().toLocaleDateString(), 14, 28);

        doc.setFontSize(12);
        doc.text('Cost Summary', 14, 38);
        doc.autoTable({
            startY: 42,
            head: [['Category', 'Amount (RWF)']],
            body: [
                ['Total UPS Cost', upsCost.toLocaleString()],
                ['Total Cooling Cost', coolingCost.toLocaleString()],
                ['UPS Preventive', upsPreventive.toLocaleString()],
                ['UPS Corrective', upsCorrective.toLocaleString()],
                ['Cooling Preventive', coolingPreventive.toLocaleString()],
                ['Cooling Corrective', coolingCorrective.toLocaleString()],
                ['GRAND TOTAL', (upsCost + coolingCost).toLocaleString()]
            ],
            headStyles: { fillColor: [13, 110, 253] }
        });

        doc.addPage();
        doc.setFontSize(12);
        doc.text('UPS Maintenance Records', 14, 15);
        doc.autoTable({ startY: 20, html: '#upsTableEl', styles: { fontSize: 8 }, headStyles: { fillColor: [13, 110, 253] } });

        doc.addPage();
        doc.text('Cooling Maintenance Records', 14, 15);
        doc.autoTable({ startY: 20, html: '#coolingTableEl', styles: { fontSize: 8 }, headStyles: { fillColor: [13, 202, 240] } });

        doc.save('maintenance-cost-report.pdf');
    }

    function exportExcel() {
        const wb = XLSX.utils.book_new();
        const summaryData = [
            ['Maintenance Cost Analysis Report'],
            ['Period', '${startDate} to ${endDate}'],
            ['Generated', new Date().toLocaleDateString()],
            [],
            ['Category', 'Amount (RWF)'],
            ['Total UPS Cost', upsCost],
            ['Total Cooling Cost', coolingCost],
            ['UPS Preventive', upsPreventive],
            ['UPS Corrective', upsCorrective],
            ['Cooling Preventive', coolingPreventive],
            ['Cooling Corrective', coolingCorrective],
            ['GRAND TOTAL', upsCost + coolingCost]
        ];
        XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet(summaryData), 'Summary');
        XLSX.utils.book_append_sheet(wb, XLSX.utils.table_to_sheet(document.getElementById('upsTableEl')), 'UPS Maintenance');
        XLSX.utils.book_append_sheet(wb, XLSX.utils.table_to_sheet(document.getElementById('coolingTableEl')), 'Cooling Maintenance');
        XLSX.writeFile(wb, 'maintenance-cost-report.xlsx');
    }
</script>
</body>
</html>