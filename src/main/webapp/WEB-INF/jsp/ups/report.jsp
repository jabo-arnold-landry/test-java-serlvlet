<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.time.LocalDate" %>

<!DOCTYPE html>
<html>
<head>
    <title>UPS Reports</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            color: #333;
        }
        
        .container {
            max-width: 1400px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            margin-bottom: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .report-form {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 1fr;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .form-row.full {
            grid-template-columns: 1fr;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            font-weight: 600;
            margin-bottom: 8px;
            color: #2c3e50;
            font-size: 13px;
        }
        
        .form-group input,
        .form-group select {
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 5px rgba(52, 152, 219, 0.3);
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s, transform 0.2s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background-color: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background-color: #95a5a6;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #7f8c8d;
        }
        
        .btn-success {
            background-color: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background-color: #229954;
        }
        
        .quick-links {
            display: flex;
            gap: 10px;
            margin-bottom: 0;
        }
        
        .alert {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: none;
        }
        
        .alert.show {
            display: block;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        /* Report Display Section */
        .report-display {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .report-title {
            font-size: 24px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 15px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        
        .report-meta {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
            padding: 20px;
            background-color: #ecf0f1;
            border-radius: 4px;
        }
        
        .meta-item {
            text-align: center;
        }
        
        .meta-label {
            font-size: 12px;
            color: #7f8c8d;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .meta-value {
            font-size: 18px;
            font-weight: bold;
            color: #2c3e50;
            margin-top: 5px;
        }
        
        .section {
            margin-bottom: 40px;
        }
        
        .section-title {
            font-size: 18px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .statistics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        
        .stat-card.active {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .stat-card.faulty {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
        }
        
        .stat-card.maintenance {
            background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);
        }
        
        .stat-card.decommissioned {
            background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
            color: #333;
        }
        
        .stat-label {
            font-size: 12px;
            opacity: 0.9;
            text-transform: uppercase;
            font-weight: 600;
        }
        
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            margin-top: 10px;
        }
        
        .distribution-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        .distribution-table thead {
            background-color: #34495e;
            color: white;
        }
        
        .distribution-table th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }
        
        .distribution-table td {
            padding: 12px;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .distribution-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .devices-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            font-size: 13px;
        }
        
        .devices-table thead {
            background-color: #34495e;
            color: white;
        }
        
        .devices-table th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .devices-table td {
            padding: 12px;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .devices-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-faulty {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .status-maintenance {
            background-color: #cce5ff;
            color: #004085;
        }
        
        .status-decommissioned {
            background-color: #e2e3e5;
            color: #383d41;
        }
        
        .download-section {
            margin-top: 30px;
            padding-top: 30px;
            border-top: 2px solid #ecf0f1;
            text-align: center;
        }
        
        .no-data {
            padding: 40px;
            text-align: center;
            color: #95a5a6;
            font-size: 16px;
        }
        
        @media print {
            .form-group, .button-group, .quick-links, .download-section {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>UPS Device Reports</h1>
            <p>Generate and analyze UPS device reports by time period with advanced filtering options</p>
        </div>

        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger show" style="background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; padding: 15px; border-radius: 4px; margin-bottom: 20px;">
                <strong>Error:</strong> ${error}
            </div>
        </c:if>

        <!-- Report Form -->
        <div class="report-form">
            <form id="reportForm" method="POST" action="${pageContext.request.contextPath}/ups/reports/generate" accept-charset="UTF-8">
                <div class="form-row">
                    <div class="form-group">
                        <label for="period">Report Period *</label>
                        <select id="period" name="period" required>
                            <option value="">-- Select Period --</option>
                            <option value="daily" ${period == 'daily' ? 'selected' : ''}>Daily</option>
                            <option value="weekly" ${period == 'weekly' ? 'selected' : ''}>Weekly</option>
                            <option value="monthly" ${period == 'monthly' ? 'selected' : ''}>Monthly</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="reportDate">Report Date *</label>
                        <input type="date" id="reportDate" name="reportDate" value="${reportDate}" required>
                    </div>
                    <div class="form-group">
                        <label for="filterStatus">Filter by Status</label>
                        <select id="filterStatus" name="filterStatus">
                            <option value="">All Statuses</option>
                            <c:forEach items="${statuses}" var="status">
                                <option value="${status}" ${filterStatus == status ? 'selected' : ''}>${status}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="filterLocation">Filter by Location</label>
                        <select id="filterLocation" name="filterLocation">
                            <option value="">All Locations</option>
                            <c:forEach items="${locations}" var="location">
                                <option value="${location}" ${filterLocation == location ? 'selected' : ''}>${location}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Generate Report</button>
                    
                    <div class="quick-links">
                        <a href="${pageContext.request.contextPath}/ups/reports/daily" class="btn btn-secondary">Today</a>
                        <a href="${pageContext.request.contextPath}/ups/reports/weekly" class="btn btn-secondary">This Week</a>
                        <a href="${pageContext.request.contextPath}/ups/reports/monthly" class="btn btn-secondary">This Month</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Report Display -->
        <c:if test="${report != null}">
            <div class="report-display">
                <div class="report-title">
                    <c:out value="${report.reportPeriod}" /> Report 
                    <c:if test="${report.periodStartDate != null and report.periodEndDate != null}">
                        (<c:out value="${report.periodStartDate}" /> to <c:out value="${report.periodEndDate}" />)
                    </c:if>
                </div>
                <div class="report-meta">
                    <div class="meta-item">
                        <div class="meta-label">Generated</div>
                        <div class="meta-value">
                            <c:if test="${report.generatedAt != null}">
                                <c:out value="${report.generatedAt}" />
                            </c:if>
                            <c:if test="${report.generatedAt == null}">N/A</c:if>
                        </div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Total Devices</div>
                        <div class="meta-value"><c:out value="${report.totalDevicesAdded != null ? report.totalDevicesAdded : 0}" /></div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Total Capacity</div>
                        <div class="meta-value">
                            <c:out value="${report.totalCapacityKva != null ? report.totalCapacityKva : 'N/A'}" /> kVA
                        </div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Report ID</div>
                        <div class="meta-value" style="font-size: 12px;"><c:out value="${report.reportId}" /></div>
                    </div>
                </div>

                <!-- Summary Statistics -->
                <div class="section">
                    <div class="section-title">Device Status Summary</div>
                    <div class="statistics-grid">
                        <div class="stat-card active">
                            <div class="stat-label">Active Devices</div>
                            <div class="stat-value"><c:out value="${report.totalActiveDevices != null ? report.totalActiveDevices : 0}" /></div>
                        </div>
                        <div class="stat-card faulty">
                            <div class="stat-label">Faulty Devices</div>
                            <div class="stat-value"><c:out value="${report.totalFaultyDevices != null ? report.totalFaultyDevices : 0}" /></div>
                        </div>
                        <div class="stat-card maintenance">
                            <div class="stat-label">Under Maintenance</div>
                            <div class="stat-value"><c:out value="${report.totalUnderMaintenanceDevices != null ? report.totalUnderMaintenanceDevices : 0}" /></div>
                        </div>
                        <div class="stat-card decommissioned">
                            <div class="stat-label">Decommissioned</div>
                            <div class="stat-value"><c:out value="${report.totalDecommissionedDevices != null ? report.totalDecommissionedDevices : 0}" /></div>
                        </div>
                    </div>
                </div>

                <!-- Capacity Statistics -->
                <c:if test="${report.totalCapacityKva != null}">
                    <div class="section">
                        <div class="section-title">Capacity Statistics (kVA)</div>
                        <table class="distribution-table">
                            <thead>
                                <tr>
                                    <th>Metric</th>
                                    <th>Value</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Total Capacity</td>
                                    <td><c:out value="${report.totalCapacityKva}" /></td>
                                </tr>
                                <tr>
                                    <td>Average Capacity</td>
                                    <td><c:out value="${report.averageCapacityKva}" /></td>
                                </tr>
                                <tr>
                                    <td>Maximum Capacity</td>
                                    <td><c:out value="${report.maxCapacityKva}" /></td>
                                </tr>
                                <tr>
                                    <td>Minimum Capacity</td>
                                    <td><c:out value="${report.minCapacityKva}" /></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <!-- Distribution By Location -->
                <c:if test="${report.devicesByLocation != null && !report.devicesByLocation.isEmpty()}">
                    <div class="section">
                        <div class="section-title">Distribution by Location</div>
                        <table class="distribution-table">
                            <thead>
                                <tr>
                                    <th>Location</th>
                                    <th>Device Count</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${report.devicesByLocation}" var="entry">
                                    <tr>
                                        <td><c:out value="${entry.key != null ? entry.key : 'Unspecified'}" /></td>
                                        <td><c:out value="${entry.value}" /></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <!-- Distribution By Status -->
                <c:if test="${report.devicesByStatus != null && !report.devicesByStatus.isEmpty()}">
                    <div class="section">
                        <div class="section-title">Distribution by Status</div>
                        <table class="distribution-table">
                            <thead>
                                <tr>
                                    <th>Status</th>
                                    <th>Device Count</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${report.devicesByStatus}" var="entry">
                                    <tr>
                                        <td><c:out value="${entry.key != null ? entry.key : 'Unspecified'}" /></td>
                                        <td><c:out value="${entry.value}" /></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <!-- Distribution By Brand -->
                <c:if test="${report.devicesByBrand != null && !report.devicesByBrand.isEmpty()}">
                    <div class="section">
                        <div class="section-title">Distribution by Brand</div>
                        <table class="distribution-table">
                            <thead>
                                <tr>
                                    <th>Brand</th>
                                    <th>Device Count</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${report.devicesByBrand}" var="entry">
                                    <tr>
                                        <td><c:out value="${entry.key != null ? entry.key : 'Unspecified'}" /></td>
                                        <td><c:out value="${entry.value}" /></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <!-- Device Details Table -->
                <c:if test="${report.deviceDetails != null && !report.deviceDetails.isEmpty()}">
                    <div class="section">
                        <div class="section-title">Device Details</div>
                        <table class="devices-table">
                            <thead>
                                <tr>
                                    <th>Asset Tag</th>
                                    <th>Device Name</th>
                                    <th>Brand</th>
                                    <th>Model</th>
                                    <th>Serial Number</th>
                                    <th>Capacity (kVA)</th>
                                    <th>Status</th>
                                    <th>Location</th>
                                    <th>Installation Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${report.deviceDetails}" var="device">
                                    <tr>
                                        <td><strong><c:out value="${device.assetTag}" /></strong></td>
                                        <td><c:out value="${device.upsName}" /></td>
                                        <td><c:out value="${device.brand != null ? device.brand : 'N/A'}" /></td>
                                        <td><c:out value="${device.model != null ? device.model : 'N/A'}" /></td>
                                        <td><c:out value="${device.serialNumber != null ? device.serialNumber : 'N/A'}" /></td>
                                        <td><c:out value="${device.capacityKva != null ? device.capacityKva : 'N/A'}" /></td>
                                        <td>
                                            <span class="status-badge status-${device.status.toLowerCase()}">
                                                <c:out value="${device.status}" />
                                            </span>
                                        </td>
                                        <td><c:out value="${device.locationRoom != null ? device.locationRoom : 'N/A'}" /></td>
                                        <td>
                                            <c:if test="${device.installationDate != null}">
                                                <c:out value="${device.installationDate}" />
                                            </c:if>
                                            <c:if test="${device.installationDate == null}">N/A</c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <c:if test="${(report.deviceDetails == null || report.deviceDetails.isEmpty())}">
                    <div class="no-data">
                        No devices found for the selected criteria.
                    </div>
                </c:if>

                <!-- Download CSV Section -->
                <div class="download-section">
                    <form method="post" action="${pageContext.request.contextPath}/ups/reports/download-csv" style="display: inline;">
                        <input type="hidden" name="period" value="${period}">
                        <input type="hidden" name="reportDate" value="${reportDate}">
                        <input type="hidden" name="filterStatus" value="${filterStatus != null ? filterStatus : ''}">
                        <input type="hidden" name="filterLocation" value="${filterLocation != null ? filterLocation : ''}">
                        <button type="submit" class="btn btn-success">Download as CSV</button>
                    </form>
                    <button type="button" class="btn btn-secondary" onclick="window.print();">Print Report (Use Browser Print to Save as PDF)</button>
                </div>
            </div>
        </c:if>

        <c:if test="${report == null}">
            <div class="report-display">
                <div class="no-data">
                    Select a report period and click "Generate Report" to view results.
                </div>
            </div>
        </c:if>
    </div>

    <script>
        // Form validation and initialization
        document.addEventListener('DOMContentLoaded', function() {
            // Set today's date as default
            const dateInput = document.getElementById('reportDate');
            if (!dateInput.value) {
                const today = new Date().toISOString().split('T')[0];
                dateInput.value = today;
            }

            // Add form submission validation
            const reportForm = document.getElementById('reportForm');
            if (reportForm) {
                reportForm.addEventListener('submit', function(e) {
                    const period = document.getElementById('period').value;
                    const reportDate = document.getElementById('reportDate').value;

                    if (!period || period === '') {
                        e.preventDefault();
                        alert('Please select a Report Period');
                        return false;
                    }

                    if (!reportDate || reportDate === '') {
                        e.preventDefault();
                        alert('Please select a Report Date');
                        return false;
                    }

                    // Form is valid, proceed with submission
                    return true;
                });
            }
        });
    </script>
</body>
</html>
