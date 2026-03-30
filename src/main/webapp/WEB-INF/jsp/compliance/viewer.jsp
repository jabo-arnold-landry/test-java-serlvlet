<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Compliance Report Viewer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .summary-pill {
            padding: 8px 14px;
            border-radius: 999px;
            background: #edf7ff;
            color: #0d4d73;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid #c9e8ff;
        }
    </style>
</head>
<body>
<jsp:include page="../common/sidebar.jsp"/>
<jsp:include page="../common/topbar.jsp"/>

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h4 style="font-weight:700;margin:0;">Report Viewer</h4>
            <p class="text-muted mb-0" style="font-size:14px;">Table + chart + CSV/PDF export</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/compliance/reports/generate" class="btn btn-outline-secondary"><i class="bi bi-funnel"></i> Change Filters</a>
            <button class="btn btn-outline-primary" onclick="exportReport('csv')"><i class="bi bi-file-earmark-spreadsheet"></i> CSV</button>
            <button class="btn btn-primary" onclick="exportReport('pdf')"><i class="bi bi-file-earmark-pdf"></i> PDF</button>
        </div>
    </div>

    <c:if test="${not empty accessNotice}">
        <div class="alert alert-warning">${accessNotice}</div>
    </c:if>

    <div class="card mb-3">
        <div class="card-body">
            <div id="summaryPills" class="d-flex flex-wrap gap-2"></div>
        </div>
    </div>

    <div class="card mb-3">
        <div class="card-body" style="min-height: 280px;">
            <canvas id="reportChart"></canvas>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered table-sm" id="reportTable">
                    <thead></thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    const search = new URLSearchParams(window.location.search);
    const reportType = search.get('reportType') || '${reportType}';

    function endpoint(type) {
        if (type === 'equipment-health') return '/api/reports/equipment-health';
        if (type === 'maintenance') return '/api/reports/maintenance';
        if (type === 'incidents') return '/api/reports/incidents';
        if (type === 'shift') return '/api/reports/shift/' + (search.get('shiftId') || '1');
        if (type === 'daily') return '/api/reports/daily';
        return '/api/reports/compliance';
    }

    function buildApiUrl() {
        const params = new URLSearchParams(search.toString());
        params.delete('reportType');
        return contextPath + endpoint(reportType) + '?' + params.toString();
    }

    function exportReport(format) {
        const params = new URLSearchParams(search.toString());
        params.set('reportType', reportType);
        params.set('format', format);
        window.open(contextPath + '/api/reports/export?' + params.toString(), '_blank');
    }

    function valueClass(v) {
        if (v === null || v === undefined) return '';
        const s = String(v).toUpperCase();
        if (s.includes('CRITICAL') || s.includes('FAULTY') || s.includes('OVERDUE') || s.includes('VIOLATION')) return 'text-danger fw-bold';
        if (s.includes('WARNING') || s.includes('POOR')) return 'text-warning fw-bold';
        if (s.includes('GOOD') || s.includes('ACTIVE') || s.includes('ON_TIME') || s.includes('RESOLVED')) return 'text-success fw-bold';
        return '';
    }

    function toBadge(v) {
        if (v === null || v === undefined) return '';
        const s = String(v).toUpperCase();
        if (s.includes('CRITICAL') || s.includes('FAULTY') || s.includes('OVERDUE') || s.includes('VIOLATION')) {
            return '<span class="badge bg-danger">' + v + '</span>';
        }
        if (s.includes('WARNING') || s.includes('POOR')) {
            return '<span class="badge bg-warning text-dark">' + v + '</span>';
        }
        if (s.includes('GOOD') || s.includes('ACTIVE') || s.includes('ON_TIME') || s.includes('RESOLVED')) {
            return '<span class="badge bg-success">' + v + '</span>';
        }
        return null;
    }

    function renderTable(rows) {
        const thead = document.querySelector('#reportTable thead');
        const tbody = document.querySelector('#reportTable tbody');
        thead.innerHTML = '';
        tbody.innerHTML = '';

        if (!rows || rows.length === 0) {
            thead.innerHTML = '<tr><th>No data</th></tr>';
            tbody.innerHTML = '<tr><td class="text-muted">No records found for selected filters.</td></tr>';
            return;
        }

        const columns = Object.keys(rows[0]);
        const headRow = document.createElement('tr');
        columns.forEach(c => {
            const th = document.createElement('th');
            th.textContent = c;
            headRow.appendChild(th);
        });
        thead.appendChild(headRow);

        rows.forEach(row => {
            const tr = document.createElement('tr');
            columns.forEach(c => {
                const td = document.createElement('td');
                const val = row[c] ?? '';
                const badgeHtml = toBadge(val);
                if (badgeHtml && (String(c).toLowerCase().includes('status') || String(c).toLowerCase().includes('severity') || String(c).toLowerCase().includes('health'))) {
                    td.innerHTML = badgeHtml;
                } else {
                    td.textContent = val;
                }
                td.className = valueClass(val);
                tr.appendChild(td);
            });
            tbody.appendChild(tr);
        });
    }

    function renderSummary(summary) {
        const holder = document.getElementById('summaryPills');
        holder.innerHTML = '';
        if (!summary) return;
        Object.keys(summary).forEach(key => {
            const div = document.createElement('div');
            div.className = 'summary-pill';
            div.textContent = key + ': ' + summary[key];
            holder.appendChild(div);
        });
    }

    let chartInstance = null;
    function renderChart(rows) {
        const ctx = document.getElementById('reportChart');
        if (chartInstance) {
            chartInstance.destroy();
        }

        if (!rows || rows.length === 0) {
            return;
        }

        const first = rows[0];
        const labelKey = Object.keys(first).find(k => String(k).toLowerCase().includes('date'))
            || Object.keys(first).find(k => String(k).toLowerCase().includes('name'))
            || Object.keys(first)[0];

        const numericKey = Object.keys(first).find(k => typeof first[k] === 'number' && !String(k).toLowerCase().includes('id'))
            || Object.keys(first).find(k => String(k).toLowerCase().includes('downtime'))
            || Object.keys(first).find(k => String(k).toLowerCase().includes('count'));

        if (!numericKey) {
            return;
        }

        const labels = rows.slice(0, 12).map(r => String(r[labelKey] ?? '-'));
        const values = rows.slice(0, 12).map(r => Number(r[numericKey] ?? 0));

        chartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels,
                datasets: [{
                    label: numericKey,
                    data: values,
                    backgroundColor: '#208cc8'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }

    fetch(buildApiUrl())
        .then(r => r.json())
        .then(data => {
            renderSummary(data.summary);
            renderTable(data.rows);
            renderChart(data.rows);
        })
        .catch(() => {
            document.querySelector('#reportTable thead').innerHTML = '<tr><th>Error</th></tr>';
            document.querySelector('#reportTable tbody').innerHTML = '<tr><td class="text-danger">Failed to load report data.</td></tr>';
        });
</script>
</body>
</html>
