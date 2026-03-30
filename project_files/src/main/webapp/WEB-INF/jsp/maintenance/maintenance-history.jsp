<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Maintenance History</title>
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
                <h4 style="font-weight:700;margin:0;"><i class="bi bi-clock-history"></i> Maintenance History</h4>
                <small class="text-muted">Complete audit trail of all maintenance activities</small>
            </div>
            <div>
                <button onclick="exportPDF()" class="btn btn-danger me-2"><i class="bi bi-file-earmark-pdf"></i> Export PDF</button>
                <button onclick="exportExcel()" class="btn btn-success"><i class="bi bi-file-earmark-excel"></i> Export Excel</button>
            </div>
        </div>

        <!-- Filters -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <form method="get" class="row g-3 align-items-end">
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">From Date</label>
                        <input type="date" name="startDate" class="form-control" value="${startDate}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">To Date</label>
                        <input type="date" name="endDate" class="form-control" value="${endDate}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Equipment</label>
                        <select name="equipmentType" class="form-select">
                            <option value="">All Types</option>
                            <option value="UPS" ${selectedEquipmentType == 'UPS' ? 'selected' : ''}>UPS</option>
                            <option value="COOLING" ${selectedEquipmentType == 'COOLING' ? 'selected' : ''}>Cooling</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Action</label>
                        <select name="action" class="form-select">
                            <option value="">All Actions</option>
                            <c:forEach var="a" items="${actionTypes}">
                                <option value="${a}" ${selectedAction == a ? 'selected' : ''}>${a}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">User</label>
                        <select name="userId" class="form-select">
                            <option value="">All Users</option>
                            <c:forEach var="u" items="${userList}">
                                <option value="${u.userId}" ${selectedUserId == u.userId ? 'selected' : ''}>${u.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100"><i class="bi bi-funnel"></i> Filter</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Summary -->
        <div class="row mb-3">
            <div class="col">
                <span class="badge bg-secondary fs-6">${logs.size()} records found</span>
            </div>
        </div>

        <!-- History Table -->
        <div class="table-container">
            <table class="table table-hover" id="historyTableEl">
                <thead class="table-light">
                    <tr>
                        <th>Date/Time</th>
                        <th>User</th>
                        <th>Equipment Type</th>
                        <th>Maint. ID</th>
                        <th>Action</th>
                        <th>Remarks / Details</th>
                        <th>IP Address</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${logs}">
                    <tr>
                        <td><small>${log.timestamp}</small></td>
                        <td><strong>${log.user.fullName}</strong></td>
                        <td>
                            <c:choose>
                                <c:when test="${log.entityType.contains('UPS')}">
                                    <span class="badge bg-primary">UPS</span>
                                </c:when>
                                <c:when test="${log.entityType.contains('COOLING')}">
                                    <span class="badge bg-info">COOLING</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">${log.entityType}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${log.entityId}</td>
                        <td>
                            <c:choose>
                                <c:when test="${log.action == 'CREATED'}">
                                    <span class="badge bg-success">${log.action}</span>
                                </c:when>
                                <c:when test="${log.action == 'UPDATED'}">
                                    <span class="badge bg-warning text-dark">${log.action}</span>
                                </c:when>
                                <c:when test="${log.action == 'DELETED'}">
                                    <span class="badge bg-danger">${log.action}</span>
                                </c:when>
                                <c:when test="${log.action == 'FILE_UPLOAD'}">
                                    <span class="badge bg-info">${log.action}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">${log.action}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><small>${log.details}</small></td>
                        <td><small class="text-muted">${log.ipAddress}</small></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty logs}">
                        <tr><td colspan="7" class="text-center text-muted">No maintenance history records found for the selected filters.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

<script>
    function exportPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('landscape');
        doc.setFontSize(16);
        doc.text('Maintenance History Audit Report', 14, 15);
        doc.setFontSize(10);
        doc.text('Period: ${startDate} to ${endDate}', 14, 22);
        doc.text('Generated: ' + new Date().toLocaleDateString(), 14, 28);
        doc.text('Total Records: ${logs.size()}', 14, 34);

        doc.autoTable({
            startY: 40,
            html: '#historyTableEl',
            styles: { fontSize: 7 },
            headStyles: { fillColor: [13, 110, 253] },
            columnStyles: { 5: { cellWidth: 60 } }
        });

        doc.save('maintenance-history-audit.pdf');
    }

    function exportExcel() {
        const wb = XLSX.utils.book_new();
        const headerData = [
            ['Maintenance History Audit Report'],
            ['Period', '${startDate} to ${endDate}'],
            ['Generated', new Date().toLocaleDateString()],
            ['Total Records', '${logs.size()}'],
            []
        ];
        var ws = XLSX.utils.aoa_to_sheet(headerData);
        XLSX.utils.sheet_add_dom(ws, document.getElementById('historyTableEl'), { origin: 'A6' });
        XLSX.utils.book_append_sheet(wb, ws, 'History');
        XLSX.writeFile(wb, 'maintenance-history-audit.xlsx');
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
