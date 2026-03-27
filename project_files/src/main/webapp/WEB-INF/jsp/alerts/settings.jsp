<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Alert Settings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
    <style>
        .settings-card {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            border: 1px solid #e5e7eb;
        }
        .settings-card h5 {
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: #1f2937;
        }
        .settings-card h5 i {
            font-size: 24px;
        }
        .threshold-input-group {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
        }
        .threshold-input-group label {
            flex: 0 0 200px;
            font-weight: 500;
            color: #374151;
        }
        .threshold-input-group input {
            flex: 0 0 120px;
            background: #f9fafb;
            border: 1px solid #d1d5db;
            color: #1f2937;
            border-radius: 8px;
            padding: 10px 15px;
            text-align: center;
            font-weight: 600;
        }
        .threshold-input-group input:focus {
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(59,130,246,0.2);
            outline: none;
            background: #fff;
        }
        .threshold-input-group .unit {
            color: #6b7280;
            font-size: 14px;
            font-weight: 500;
        }
        .icon-temp { color: #ef4444; }
        .icon-humidity { color: #3b82f6; }
        .icon-battery { color: #f59e0b; }
        .icon-overload { color: #ef4444; }
        .toggle-switch {
            position: relative;
            width: 50px;
            height: 26px;
        }
        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }
        .toggle-slider {
            position: absolute;
            cursor: pointer;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: #d1d5db;
            transition: .3s;
            border-radius: 26px;
        }
        .toggle-slider:before {
            position: absolute;
            content: "";
            height: 20px;
            width: 20px;
            left: 3px;
            bottom: 3px;
            background-color: white;
            transition: .3s;
            border-radius: 50%;
        }
        .toggle-switch input:checked + .toggle-slider {
            background-color: var(--accent-green);
        }
        .toggle-switch input:checked + .toggle-slider:before {
            transform: translateX(24px);
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
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 style="font-weight:700;margin:0;">
                    <i class="bi bi-gear"></i> Alert Settings
                </h4>
                <p class="text-muted mb-0" style="font-size:14px;">Configure alert thresholds</p>
            </div>
            <a href="${pageContext.request.contextPath}/alerts" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back to Alerts
            </a>
        </div>
        
        <form action="${pageContext.request.contextPath}/alerts/settings" method="post">
            
            <!-- Temperature Thresholds -->
            <div class="settings-card">
                <h5><i class="bi bi-thermometer-high icon-temp"></i> Temperature Thresholds</h5>
                
                <div class="threshold-input-group">
                    <label>UPS High Temperature</label>
                    <input type="number" name="upsHighTempThreshold" value="${thresholds.upsHighTemp != null ? thresholds.upsHighTemp : 35}" step="0.1" min="0" max="100">
                    <span class="unit">°C</span>
                </div>
                
                <div class="threshold-input-group">
                    <label>Cooling Unit High Temp</label>
                    <input type="number" name="coolingHighTempThreshold" value="${thresholds.coolingHighTemp != null ? thresholds.coolingHighTemp : 25}" step="0.1" min="0" max="100">
                    <span class="unit">°C</span>
                </div>
            </div>
            
            <!-- Humidity Thresholds -->
            <div class="settings-card">
                <h5><i class="bi bi-droplet icon-humidity"></i> Humidity Thresholds</h5>
                
                <div class="threshold-input-group">
                    <label>Maximum Humidity</label>
                    <input type="number" name="humidityHighThreshold" value="${thresholds.humidityHigh != null ? thresholds.humidityHigh : 65}" step="0.1" min="0" max="100">
                    <span class="unit">%</span>
                </div>
                
                <div class="threshold-input-group">
                    <label>Minimum Humidity</label>
                    <input type="number" name="humidityLowThreshold" value="${thresholds.humidityLow != null ? thresholds.humidityLow : 30}" step="0.1" min="0" max="100">
                    <span class="unit">%</span>
                </div>
            </div>
            
            <!-- UPS Thresholds -->
            <div class="settings-card">
                <h5><i class="bi bi-lightning icon-overload"></i> UPS Thresholds</h5>
                
                <div class="threshold-input-group">
                    <label>UPS Load Warning</label>
                    <input type="number" name="upsOverloadThreshold" value="${thresholds.upsOverload != null ? thresholds.upsOverload : 80}" step="1" min="0" max="100">
                    <span class="unit">%</span>
                </div>
            </div>
            
            <!-- Battery Thresholds -->
            <div class="settings-card">
                <h5><i class="bi bi-battery-half icon-battery"></i> Battery Thresholds</h5>
                
                <div class="threshold-input-group">
                    <label>Low Battery Warning</label>
                    <input type="number" name="lowBatteryThreshold" value="${thresholds.lowBattery != null ? thresholds.lowBattery : 20}" step="1" min="0" max="100">
                    <span class="unit">%</span>
                </div>
                
                <div class="threshold-input-group">
                    <label>Replacement Warning</label>
                    <input type="number" name="batteryReplacementWarningDays" value="${thresholds.batteryReplacementWarningDays != null ? thresholds.batteryReplacementWarningDays : 30}" step="1" min="1" max="365">
                    <span class="unit">days before due</span>
                </div>
            </div>
            
            <!-- Email Notification Settings -->
            <div class="settings-card">
                <h5><i class="bi bi-envelope"></i> Email Notifications</h5>
                
                <div class="threshold-input-group">
                    <label>Auto-send Email Alerts</label>
                    <label class="toggle-switch">
                        <input type="checkbox" name="autoSendEmail" value="true" ${thresholds.autoSendEmail ? 'checked' : ''}>
                        <span class="toggle-slider"></span>
                    </label>
                </div>
                
                <div class="threshold-input-group">
                    <label>Email Recipients</label>
                    <input type="text" name="emailRecipients" value="${thresholds.emailRecipients}" style="flex:1;max-width:400px;" placeholder="Enter email addresses">
                </div>
            </div>
            
            <div class="d-flex gap-3">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check2"></i> Save Settings
                </button>
                <button type="reset" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-counterclockwise"></i> Reset
                </button>
            </div>
        </form>
        
        <!-- Alert Preview Section -->
        <div class="settings-card mt-4">
            <h5><i class="bi bi-eye"></i> Alert Thresholds Visualization</h5>
            <div class="row">
                <div class="col-md-3">
                    <div class="text-center">
                        <svg width="120" height="120" viewBox="0 0 120 120">
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#2a2d35" stroke-width="10"/>
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#ef4444" stroke-width="10"
                                    stroke-dasharray="220" stroke-dashoffset="55" stroke-linecap="round"
                                    transform="rotate(-90 60 60)"/>
                            <text x="60" y="55" text-anchor="middle" fill="#ef4444" font-size="20" font-weight="700">35°C</text>
                            <text x="60" y="75" text-anchor="middle" fill="#6b7280" font-size="11">UPS Temp</text>
                        </svg>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center">
                        <svg width="120" height="120" viewBox="0 0 120 120">
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#2a2d35" stroke-width="10"/>
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#3b82f6" stroke-width="10"
                                    stroke-dasharray="204" stroke-dashoffset="71" stroke-linecap="round"
                                    transform="rotate(-90 60 60)"/>
                            <text x="60" y="55" text-anchor="middle" fill="#3b82f6" font-size="20" font-weight="700">65%</text>
                            <text x="60" y="75" text-anchor="middle" fill="#6b7280" font-size="11">Max Humidity</text>
                        </svg>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center">
                        <svg width="120" height="120" viewBox="0 0 120 120">
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#2a2d35" stroke-width="10"/>
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#ef4444" stroke-width="10"
                                    stroke-dasharray="251" stroke-dashoffset="50" stroke-linecap="round"
                                    transform="rotate(-90 60 60)"/>
                            <text x="60" y="55" text-anchor="middle" fill="#ef4444" font-size="20" font-weight="700">80%</text>
                            <text x="60" y="75" text-anchor="middle" fill="#6b7280" font-size="11">UPS Load</text>
                        </svg>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center">
                        <svg width="120" height="120" viewBox="0 0 120 120">
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#2a2d35" stroke-width="10"/>
                            <circle cx="60" cy="60" r="50" fill="none" stroke="#f59e0b" stroke-width="10"
                                    stroke-dasharray="63" stroke-dashoffset="0" stroke-linecap="round"
                                    transform="rotate(-90 60 60)"/>
                            <text x="60" y="55" text-anchor="middle" fill="#f59e0b" font-size="20" font-weight="700">20%</text>
                            <text x="60" y="75" text-anchor="middle" fill="#6b7280" font-size="11">Low Battery</text>
                        </svg>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/common/alert-notifications.jsp"/>
</body>
</html>
