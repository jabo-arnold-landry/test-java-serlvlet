<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Trends Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">Manager Dashboard - Trends</h4>
                <p class="text-muted mb-0" style="font-size:14px;">UPS Load Trends, Temperature Trends, and Downtime Analysis</p>
            </div>
            <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="alert alert-info mb-4" role="alert">
            <h6 class="fw-bold mb-2"><i class="bi bi-info-circle"></i> Quick Guide</h6>
            <p class="mb-2">Use this page to understand service health and SLA direction quickly.</p>
            <p class="mb-1"><strong>Downtime Trend:</strong> negative % means improvement, positive % means downtime increased.</p>
            <p class="mb-1"><strong>UPS Load Trend:</strong> watch for frequent values near 100%.</p>
            <p class="mb-1"><strong>Temperature Trend:</strong> values above 28C can indicate cooling risk.</p>
            <p class="mb-0"><strong>If charts are empty:</strong> generate daily reports first from the Daily Report page so trend data is available.</p>
        </div>

        <c:if test="${empty loadTrend}">
            <div class="alert alert-warning mb-4" role="alert">
                <i class="bi bi-exclamation-triangle"></i>
                No trend records found yet. Go to Daily Report and generate reports for recent dates, then return here.
            </div>
        </c:if>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-label">Downtime Trend (7d vs prior 7d)</div>
                    <div class="stat-value" style="color:${trend > 0 ? 'var(--accent-red)' : 'var(--accent-green)'}">
                        ${trend != null ? trend : 0}%
                    </div>
                    <div class="text-muted" style="font-size:12px;">${trend > 0 ? 'Increase' : trend < 0 ? 'Decrease' : 'No Change'}</div>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-graph-up"></i> UPS Load Trend (30 Days)</h6>
                    <canvas id="loadTrendChart" height="250"></canvas>
                </div>
            </div>
            <div class="col-md-6">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-thermometer-half"></i> Temperature Trend (30 Days)</h6>
                    <canvas id="tempTrendChart" height="250"></canvas>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-12">
                <div class="stat-card">
                    <h6 class="fw-bold mb-3"><i class="bi bi-fire"></i> Incident Heatmap (Daily Count)</h6>
                    <canvas id="incidentHeatmap" height="150"></canvas>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script>
        // Build data arrays from server-side loadTrend list
        var labels = [], loadData = [], tempData = [], incidentData = [];
        <c:forEach var="r" items="${loadTrend}">
            labels.push('${r.reportDate}');
            loadData.push(${r.avgDailyLoad != null ? r.avgDailyLoad : 0});
            tempData.push(${r.avgRoomTemperature != null ? r.avgRoomTemperature : 0});
            incidentData.push(${r.totalIncidents != null ? r.totalIncidents : 0});
        </c:forEach>
        labels.reverse(); loadData.reverse(); tempData.reverse(); incidentData.reverse();

        new Chart(document.getElementById('loadTrendChart'), {
            type: 'line',
            data: { labels: labels, datasets: [{ label: 'Avg Load %', data: loadData, borderColor: '#3b82f6', backgroundColor: 'rgba(59,130,246,0.1)', fill: true, tension: 0.3 }] },
            options: { responsive: true, scales: { y: { beginAtZero: true, max: 100 } }, plugins: { legend: { display: false } } }
        });
        new Chart(document.getElementById('tempTrendChart'), {
            type: 'line',
            data: { labels: labels, datasets: [
                { label: 'Avg Temp', data: tempData, borderColor: '#ef4444', backgroundColor: 'rgba(239,68,68,0.1)', fill: true, tension: 0.3 },
                { label: 'Threshold (28C)', data: labels.map(function(){return 28;}), borderColor: '#f59e0b', borderDash: [5,5], pointRadius: 0 }
            ] },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
        });
        new Chart(document.getElementById('incidentHeatmap'), {
            type: 'bar',
            data: { labels: labels, datasets: [{ label: 'Incidents', data: incidentData, backgroundColor: incidentData.map(function(v){return v>=3?'#ef4444':v>=1?'#f59e0b':'#10b981';}) }] },
            options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }, plugins: { legend: { display: false } } }
        });
    </script>
</body>
</html>
