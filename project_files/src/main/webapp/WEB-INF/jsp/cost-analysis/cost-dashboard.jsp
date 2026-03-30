<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Cost Maintenance Analysis & Report</title>
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
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Cost Maintenance Analysis & Report</h4>
                <small class="text-muted">Track and analyze maintenance expenditures</small>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/maintenance-costs/add?maintenanceId=0&equipmentType=UPS"
                   class="btn btn-primary me-2"><i class="bi bi-plus-circle"></i> Add Cost Entry</a>
                <button onclick="exportPDF()" class="btn btn-danger me-2"><i class="bi bi-file-earmark-pdf"></i> Export PDF</button>
                <button onclick="exportExcel()" class="btn btn-success"><i class="bi bi-file-earmark-excel"></i> Export Excel</button>
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
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Equipment Type</label>
                        <select name="equipmentType" class="form-select">
                            <option value="ALL" ${equipmentType == 'ALL' ? 'selected' : ''}>All</option>
                            <option value="UPS" ${equipmentType == 'UPS' ? 'selected' : ''}>UPS Only</option>
                            <option value="COOLING" ${equipmentType == 'COOLING' ? 'selected' : ''}>Cooling Only</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary w-100"><i class="bi bi-funnel"></i> Filter Results</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Summary Cards -->
        <div class="row mb-4">
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm stat-card green h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-cash-stack"></i> Total Cost</div>
                        <h5 class="text-success fw-bold mb-0">RWF <fmt:formatNumber value="${totalCost}" type="number" minFractionDigits="2"/></h5>
                        <small class="text-muted">${costEntries.size()} cost entries</small>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm stat-card blue h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-battery-charging"></i> UPS Cost</div>
                        <h5 class="text-primary fw-bold mb-0">RWF <fmt:formatNumber value="${upsCost}" type="number" minFractionDigits="2"/></h5>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm stat-card cyan h-100">
                    <div class="card-body">
                        <div class="text-muted small mb-1"><i class="bi bi-snow2"></i> Cooling Cost</div>
                        <h5 class="text-info fw-bold mb-0">RWF <fmt:formatNumber value="${coolingCost}" type="number" minFractionDigits="2"/></h5>
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
                        <h6 class="fw-bold mb-3">Monthly Trends</h6>
                        <canvas id="monthlyChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <h6 class="fw-bold mb-3">Quarterly Trends</h6>
                        <canvas id="quarterlyChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cost Entries Table -->
        <h6 class="mb-3"><i class="bi bi-table"></i> Cost Entries</h6>
        <div class="table-container mb-4">
            <table class="table table-hover" id="costTableEl">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Equipment</th>
                        <th>Maint. ID</th>
                        <th>Cost (RWF)</th>
                        <th>Description</th>
                        <th>Recorded At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${costEntries}" varStatus="loop">
                    <tr>
                        <td>${loop.index + 1}</td>
                        <td><span class="badge ${c.equipmentType == 'UPS' ? 'bg-primary' : 'bg-info'}">${c.equipmentType}</span></td>
                        <td>${c.maintenanceId}</td>
                        <td><strong><fmt:formatNumber value="${c.costAmount}" type="number" minFractionDigits="2"/></strong></td>
                        <td>${c.costDescription}</td>
                        <td>${c.recordedAt}</td>
                        <td>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/maintenance-costs/edit/${c.costId}"
                                   class="btn btn-sm btn-outline-primary" title="Edit"><i class="bi bi-pencil"></i></a>
                                <form action="${pageContext.request.contextPath}/maintenance-costs/delete/${c.costId}"
                                      method="post" class="m-0"
                                      onsubmit="return confirm('Delete this cost entry?');">
                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty costEntries}">
                        <tr><td colspan="7" class="text-center text-muted">No cost entries found for the selected filters.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

<script>
    const uCost = parseFloat("${upsCost}") || 0;
    const cCost = parseFloat("${coolingCost}") || 0;

    // Pie Chart
    new Chart(document.getElementById('pieChart'), {
        type: 'doughnut',
        data: {
            labels: ['UPS', 'Cooling'],
            datasets: [{ data: [uCost, cCost], backgroundColor: ['#0d6efd','#0dcaf0'], borderWidth: 2 }]
        },
        options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
    });

    // Monthly Trend
    var mLabels = [<c:forEach var="l" items="${monthLabels}" varStatus="s">'${l}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    var mUps = [<c:forEach var="v" items="${monthlyUpsCosts}" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>];
    var mCool = [<c:forEach var="v" items="${monthlyCoolingCosts}" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>];

    new Chart(document.getElementById('monthlyChart'), {
        type: 'bar',
        data: {
            labels: mLabels,
            datasets: [
                { label: 'UPS', data: mUps, backgroundColor: '#0d6efd', borderRadius: 4 },
                { label: 'Cooling', data: mCool, backgroundColor: '#0dcaf0', borderRadius: 4 }
            ]
        },
        options: { responsive: true, scales: { x: { ticks: { maxRotation: 45 } }, y: { beginAtZero: true } } }
    });

    // Quarterly Trend
    var qLabels = [<c:forEach var="l" items="${quarterLabels}" varStatus="s">'${l}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    var qUps = [<c:forEach var="v" items="${quarterlyUpsCosts}" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>];
    var qCool = [<c:forEach var="v" items="${quarterlyCoolingCosts}" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>];

    new Chart(document.getElementById('quarterlyChart'), {
        type: 'bar',
        data: {
            labels: qLabels,
            datasets: [
                { label: 'UPS', data: qUps, backgroundColor: '#0d6efd', borderRadius: 4 },
                { label: 'Cooling', data: qCool, backgroundColor: '#0dcaf0', borderRadius: 4 }
            ]
        },
        options: { responsive: true, scales: { y: { beginAtZero: true } } }
    });

    // ==================== Export Functions ====================

    function exportPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(16);
        doc.text('Cost Maintenance Analysis & Report', 14, 15);
        doc.setFontSize(10);
        doc.text('Period: ${startDate} to ${endDate}', 14, 22);
        doc.text('Filter: ${equipmentType}', 14, 28);
        doc.text('Generated: ' + new Date().toLocaleDateString(), 14, 34);

        doc.setFontSize(12);
        doc.text('Summary', 14, 44);
        doc.autoTable({
            startY: 48,
            head: [['Category', 'Amount (RWF)']],
            body: [
                ['Total Cost', uCost + cCost],
                ['UPS Cost', uCost],
                ['Cooling Cost', cCost]
            ],
            headStyles: { fillColor: [13, 110, 253] }
        });

        doc.addPage();
        doc.setFontSize(12);
        doc.text('Cost Entries Detail', 14, 15);
        doc.autoTable({ startY: 20, html: '#costTableEl', styles: { fontSize: 8 }, headStyles: { fillColor: [13, 110, 253] },
            columnStyles: { 6: { cellWidth: 0 } }
        });

        doc.save('cost-analysis-report.pdf');
    }

    function exportExcel() {
        const wb = XLSX.utils.book_new();
        const summaryData = [
            ['Cost Maintenance Analysis & Report'],
            ['Period', '${startDate} to ${endDate}'],
            ['Filter', '${equipmentType}'],
            ['Generated', new Date().toLocaleDateString()],
            [],
            ['Category', 'Amount (RWF)'],
            ['Total Cost', uCost + cCost],
            ['UPS Cost', uCost],
            ['Cooling Cost', cCost]
        ];
        XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet(summaryData), 'Summary');
        XLSX.utils.book_append_sheet(wb, XLSX.utils.table_to_sheet(document.getElementById('costTableEl')), 'Cost Entries');
        XLSX.writeFile(wb, 'cost-analysis-report.xlsx');
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
