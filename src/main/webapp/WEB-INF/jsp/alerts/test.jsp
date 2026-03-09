<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Simulation Console</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .sim-card {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            border: 1px solid #e5e7eb;
        }
        .sim-card h5 {
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: #1f2937;
        }
        .sim-card h5 i { font-size: 24px; }
        .form-label { color: #374151; font-weight: 500; }
        .form-control, .form-select {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 10px 15px;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(59,130,246,0.2);
        }
        .icon-temp { color: #ef4444; }
        .icon-humidity { color: #3b82f6; }
        .icon-email { color: #10b981; }
        .icon-overload { color: #ef4444; }
        .icon-battery { color: #f59e0b; }
        .demo-banner {
            background: linear-gradient(135deg, #3b82f6, #8b5cf6);
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .demo-banner i { font-size: 20px; }
        .alert-scenario {
            background: #fef3c7;
            border: 1px solid #fcd34d;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }
        .alert-scenario.critical {
            background: #fee2e2;
            border-color: #fca5a5;
        }
    </style>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle-fill"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <div class="demo-banner">
            <i class="bi bi-broadcast"></i>
            <div>
                <strong>Simulation Console</strong>
                <span style="opacity:0.9;margin-left:10px;">Simulate sensor data for demonstration and training purposes</span>
            </div>
        </div>
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">
                    <i class="bi bi-cpu"></i> Alert Simulation
                </h4>
                <p class="text-muted mb-0" style="font-size:14px;">Trigger alerts as if sensors detected threshold violations</p>
            </div>
            <a href="${pageContext.request.contextPath}/alerts" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> View All Alerts
            </a>
        </div>
        
        <div class="row">
            <!-- Email Verification -->
            <div class="col-md-6">
                <div class="sim-card">
                    <h5><i class="bi bi-envelope-check icon-email"></i> Verify Email Delivery</h5>
                    <p class="text-muted mb-3">Confirm email notifications are working</p>
                    <form action="${pageContext.request.contextPath}/alerts/test/send-test-email" method="post">
                        <div class="mb-3">
                            <label class="form-label">Recipient Email</label>
                            <input type="email" name="email" class="form-control" placeholder="admin@datacenter.com" required>
                        </div>
                        <button type="submit" class="btn btn-success">
                            <i class="bi bi-send"></i> Send Verification Email
                        </button>
                    </form>
                </div>
            </div>
            
            <!-- Current Thresholds -->
            <div class="col-md-6">
                <div class="sim-card">
                    <h5><i class="bi bi-sliders"></i> Active Thresholds</h5>
                    <table class="table table-sm mb-0">
                        <tr><td>UPS Temperature Limit</td><td class="text-end fw-bold text-danger">${thresholds.upsHighTemp}°C</td></tr>
                        <tr><td>Cooling Unit Limit</td><td class="text-end fw-bold text-danger">${thresholds.coolingHighTemp}°C</td></tr>
                        <tr><td>Humidity Maximum</td><td class="text-end fw-bold text-primary">${thresholds.humidityHigh}%</td></tr>
                        <tr><td>Humidity Minimum</td><td class="text-end fw-bold text-primary">${thresholds.humidityLow}%</td></tr>
                        <tr><td>UPS Load Warning</td><td class="text-end fw-bold text-danger">${thresholds.upsOverload}%</td></tr>
                        <tr><td>Battery Critical Level</td><td class="text-end fw-bold text-warning">${thresholds.lowBattery}%</td></tr>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- CRITICAL ALERTS ROW -->
        <div class="row">
            <!-- UPS OVERLOAD - Main Demo Feature -->
            <div class="col-md-6">
                <div class="sim-card">
                    <h5><i class="bi bi-lightning-fill icon-overload"></i> UPS Overload</h5>
                    <div class="alert-scenario critical">
                        <strong>⚡ Critical Scenario:</strong> UPS load exceeds safe operating capacity
                    </div>
                    <form action="${pageContext.request.contextPath}/alerts/test/ups-overload" method="post">
                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">UPS Unit ID</label>
                                <input type="number" name="upsId" class="form-control" value="1" min="1" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Current Load (%)</label>
                                <input type="number" name="actualLoad" class="form-control" value="95" step="1" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Threshold (%)</label>
                                <input type="number" name="threshold" class="form-control" value="80" step="1" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Send Alert Email To</label>
                            <input type="email" name="email" class="form-control" placeholder="admin@datacenter.com">
                        </div>
                        <button type="submit" class="btn btn-danger btn-lg w-100">
                            <i class="bi bi-lightning-fill"></i> Trigger UPS Overload Alert
                        </button>
                    </form>
                </div>
            </div>
            
            <!-- LOW BATTERY -->
            <div class="col-md-6">
                <div class="sim-card">
                    <h5><i class="bi bi-battery-half icon-battery"></i> Low Battery Warning</h5>
                    <div class="alert-scenario">
                        <strong>🔋 Warning Scenario:</strong> UPS battery level critically low
                    </div>
                    <form action="${pageContext.request.contextPath}/alerts/test/low-battery" method="post">
                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">UPS Unit ID</label>
                                <input type="number" name="upsId" class="form-control" value="1" min="1" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Battery Level (%)</label>
                                <input type="number" name="actualLevel" class="form-control" value="12" step="1" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Threshold (%)</label>
                                <input type="number" name="threshold" class="form-control" value="20" step="1" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Send Alert Email To</label>
                            <input type="email" name="email" class="form-control" placeholder="admin@datacenter.com">
                        </div>
                        <button type="submit" class="btn btn-warning btn-lg w-100">
                            <i class="bi bi-battery-half"></i> Trigger Low Battery Alert
                        </button>
                    </form>
                </div>
            </div>
        </div>
        
        <!-- ENVIRONMENTAL ALERTS ROW -->
        <div class="row">
            <!-- High Temperature -->
            <div class="col-md-6">
                <div class="sim-card">
                    <h5><i class="bi bi-thermometer-high icon-temp"></i> High Temperature</h5>
                    <div class="alert-scenario critical">
                        <strong>🌡️ Critical Scenario:</strong> Equipment temperature exceeds safe limit
                    </div>
                    <form action="${pageContext.request.contextPath}/alerts/test/high-temp" method="post">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Equipment Type</label>
                                <select name="equipmentType" class="form-select" required>
                                    <option value="UPS">UPS Unit</option>
                                    <option value="COOLING">Cooling Unit</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Equipment ID</label>
                                <input type="number" name="equipmentId" class="form-control" value="1" min="1" required>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Actual Temp (°C)</label>
                                <input type="number" name="actualTemp" class="form-control" value="42" step="0.1" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Threshold (°C)</label>
                                <input type="number" name="threshold" class="form-control" value="35" step="0.1" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Send Alert Email To</label>
                            <input type="email" name="email" class="form-control" placeholder="admin@datacenter.com">
                        </div>
                        <button type="submit" class="btn btn-danger">
                            <i class="bi bi-thermometer-high"></i> Trigger Temperature Alert
                        </button>
                    </form>
                </div>
            </div>
            
            <!-- Humidity -->
            <div class="col-md-6">
                <div class="sim-card">
                    <h5><i class="bi bi-droplet icon-humidity"></i> Humidity Alert</h5>
                    <div class="alert-scenario">
                        <strong>💧 Warning Scenario:</strong> Humidity outside acceptable range
                    </div>
                    <form action="${pageContext.request.contextPath}/alerts/test/humidity" method="post">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Equipment Type</label>
                                <select name="equipmentType" class="form-select" required>
                                    <option value="COOLING">Cooling Unit</option>
                                    <option value="UPS">UPS Unit</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Equipment ID</label>
                                <input type="number" name="equipmentId" class="form-control" value="1" min="1" required>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Type</label>
                                <select name="humidityType" class="form-select" required>
                                    <option value="HIGH">Too High</option>
                                    <option value="LOW">Too Low</option>
                                </select>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Actual (%)</label>
                                <input type="number" name="actualHumidity" class="form-control" value="78" step="0.1" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Threshold (%)</label>
                                <input type="number" name="threshold" class="form-control" value="65" step="0.1" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Send Alert Email To</label>
                            <input type="email" name="email" class="form-control" placeholder="admin@datacenter.com">
                        </div>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-droplet"></i> Trigger Humidity Alert
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
