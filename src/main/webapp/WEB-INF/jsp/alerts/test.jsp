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
        .searchable-select-wrapper {
            position: relative;
        }
        .searchable-select-wrapper input.search-filter {
            width: 100%;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 10px 15px;
            font-size: 14px;
            margin-bottom: 4px;
        }
        .searchable-select-wrapper input.search-filter:focus {
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(59,130,246,0.2);
            outline: none;
        }
        .searchable-select-wrapper select {
            width: 100%;
        }
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
            <!-- Current Thresholds -->
            <div class="col-md-12 col-lg-6">
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

        <datalist id="upsOptions">
            <c:forEach var="ups" items="${upsList}">
                <option value="${ups.upsId}">${ups.upsName} (${ups.assetTag})</option>
            </c:forEach>
        </datalist>

        <!-- MAINTENANCE DUE NOTIFIER -->
        <div class="row">
            <div class="col-md-12">
                <div class="sim-card">
                    <h5><i class="bi bi-tools"></i> Maintenance Due Notifier</h5>
                    <p class="text-muted mb-3">Notify users about upcoming or overdue maintenance for UPS units or batteries.</p>
                    <form action="${pageContext.request.contextPath}/alerts/test/maintenance-due" method="post">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Equipment (UPS)</label>
                                <select name="upsId" class="form-select" required>
                                    <option value="">-- Select UPS --</option>
                                    <c:forEach var="ups" items="${upsList}">
                                        <option value="${ups.upsId}">${ups.upsName} (${ups.assetTag})</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Send Alert Email To</label>
                                <div class="searchable-select-wrapper">
                                    <input type="text" class="search-filter form-control" placeholder="Search user..." autocomplete="off">
                                    <select name="email" class="form-select user-email-select">
                                        <option value="">-- Select user --</option>
                                        <c:forEach var="u" items="${allUsers}">
                                            <option value="${u.email}">${u.fullName} (${u.email}) - ${u.role}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <small class="text-muted">Select only when clicking Notify.</small>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">UPS Maintenance Record</label>
                            <select name="upsMaintenanceId" class="form-select">
                                <option value="">-- Select UPS maintenance --</option>
                                <c:forEach var="m" items="${dueUpsMaintenance}">
                                    <option value="${m.maintenanceId}">
                                        UPS ${m.ups.assetTag} • ${m.maintenanceType} • Due ${m.nextDueDate != null ? m.nextDueDate : m.maintenanceDate}
                                    </option>
                                </c:forEach>
                                <c:if test="${empty dueUpsMaintenance}">
                                    <option disabled>None available</option>
                                </c:if>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Battery Nearing Replacement</label>
                            <select name="batteryId" class="form-select">
                                <option value="">-- Select battery --</option>
                                <c:forEach var="b" items="${dueBatteries}">
                                    <option value="${b.batteryId}">
                                        Battery ${b.batteryId} • UPS ${b.ups.assetTag} • Replace by ${b.replacementDueDate}
                                    </option>
                                </c:forEach>
                                <c:if test="${empty dueBatteries}">
                                    <option disabled>None available</option>
                                </c:if>
                            </select>
                        </div>
                        <div class="mb-3 form-check">
                            <input type="checkbox" name="isUpsReplacement" value="true" class="form-check-input" id="upsReplaceCheck">
                            <label class="form-check-label" for="upsReplaceCheck">UPS Nearing Replacement</label>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Note</label>
                            <textarea name="note" class="form-control" rows="2" placeholder="Add any technician notes or access instructions"></textarea>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="submit" name="sendEmail" value="false" class="btn btn-secondary flex-fill">
                                <i class="bi bi-bell"></i> Trigger Maintenance Due Alert
                            </button>
                            <button type="submit" name="sendEmail" value="true" class="btn btn-outline-secondary flex-fill">
                                <i class="bi bi-envelope"></i> Notify Maintenance Due Alert
                            </button>
                        </div>
                    </form>
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
                                <label class="form-label">UPS ID</label>
                                <input type="text" name="upsId" class="form-control" list="upsOptions"
                                       placeholder="Search UPS by name or asset tag" inputmode="numeric" pattern="[0-9]+" required>
                                <small class="text-muted">Pick an existing UPS; the value submitted is its ID.</small>
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
                            <div class="searchable-select-wrapper">
                                <input type="text" class="search-filter form-control" placeholder="Search user..." autocomplete="off">
                                <select name="email" class="form-select user-email-select">
                                    <option value="">-- Select user --</option>
                                    <c:forEach var="u" items="${allUsers}">
                                        <option value="${u.email}">${u.fullName} (${u.email}) - ${u.role}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="submit" name="sendEmail" value="false" class="btn btn-danger btn-lg flex-fill">
                                <i class="bi bi-lightning-fill"></i> Trigger UPS Overload Alert
                            </button>
                            <button type="submit" name="sendEmail" value="true" class="btn btn-outline-danger btn-lg flex-fill">
                                <i class="bi bi-envelope"></i> Notify UPS Overload Alert
                            </button>
                        </div>
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
                                <label class="form-label">UPS ID</label>
                                <input type="text" name="upsId" class="form-control" list="upsOptions"
                                       placeholder="Search UPS by name or asset tag" inputmode="numeric" pattern="[0-9]+" required>
                                <small class="text-muted">Pick an existing UPS; the value submitted is its ID.</small>
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
                            <div class="searchable-select-wrapper">
                                <input type="text" class="search-filter form-control" placeholder="Search user..." autocomplete="off">
                                <select name="email" class="form-select user-email-select">
                                    <option value="">-- Select user --</option>
                                    <c:forEach var="u" items="${allUsers}">
                                        <option value="${u.email}">${u.fullName} (${u.email}) - ${u.role}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="submit" name="sendEmail" value="false" class="btn btn-warning btn-lg flex-fill">
                                <i class="bi bi-battery-half"></i> Trigger Low Battery Alert
                            </button>
                            <button type="submit" name="sendEmail" value="true" class="btn btn-outline-warning btn-lg flex-fill">
                                <i class="bi bi-envelope"></i> Notify Low Battery Alert
                            </button>
                        </div>
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
                            <div class="searchable-select-wrapper">
                                <input type="text" class="search-filter form-control" placeholder="Search user..." autocomplete="off">
                                <select name="email" class="form-select user-email-select">
                                    <option value="">-- Select user --</option>
                                    <c:forEach var="u" items="${allUsers}">
                                        <option value="${u.email}">${u.fullName} (${u.email}) - ${u.role}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="submit" name="sendEmail" value="false" class="btn btn-danger flex-fill">
                                <i class="bi bi-thermometer-high"></i> Trigger High Temperature Alert
                            </button>
                            <button type="submit" name="sendEmail" value="true" class="btn btn-outline-danger flex-fill">
                                <i class="bi bi-envelope"></i> Notify High Temperature Alert
                            </button>
                        </div>
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
                            <div class="searchable-select-wrapper">
                                <input type="text" class="search-filter form-control" placeholder="Search user..." autocomplete="off">
                                <select name="email" class="form-select user-email-select">
                                    <option value="">-- Select user --</option>
                                    <c:forEach var="u" items="${allUsers}">
                                        <option value="${u.email}">${u.fullName} (${u.email}) - ${u.role}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="submit" name="sendEmail" value="false" class="btn btn-primary flex-fill">
                                <i class="bi bi-droplet"></i> Trigger Humidity Alert
                            </button>
                            <button type="submit" name="sendEmail" value="true" class="btn btn-outline-primary flex-fill">
                                <i class="bi bi-envelope"></i> Notify Humidity Alert
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Global Alert Notification System -->
    
    
    <!-- AJAX form submission for real-time simulation without page refresh -->
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        const forms = document.querySelectorAll('.sim-card form');
        forms.forEach(form => {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                
                // Capture which button was clicked
                const submitter = e.submitter;
                const formData = new FormData(form);
                
                if (submitter && submitter.name) {
                    formData.append(submitter.name, submitter.value);
                }
                
                // Disable buttons and show loading state
                const buttons = form.querySelectorAll('button[type="submit"]');
                buttons.forEach(btn => {
                    const text = btn.innerHTML;
                    btn.dataset.originalText = text;
                    btn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Sending...';
                    btn.disabled = true;
                });
                
        fetch(form.action, {
            method: form.method || 'POST',
            body: new URLSearchParams(formData), // send as x-www-form-urlencoded
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        })
        .then(res => res.text())
        .then(html => {
            // Restore buttons
            buttons.forEach(btn => {
                btn.innerHTML = btn.dataset.originalText;
                btn.disabled = false;
            });
            
            // Parse HTML to pull flashed alerts
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const alertError = doc.querySelector('.alert-danger');
            const alertSuccess = doc.querySelector('.alert-success');

            // Clean existing alerts
            document.querySelectorAll('.main-content > .alert-danger, .main-content > .alert-success')
                .forEach(el => el.remove());

            const anchor = document.querySelector('.main-content');
            if (alertError) {
                const cloned = alertError.cloneNode(true);
                anchor.insertAdjacentElement('afterbegin', cloned);
                window.scrollTo({ top: 0, behavior: 'smooth' });
                return;
            }
            if (alertSuccess) {
                const cloned = alertSuccess.cloneNode(true);
                anchor.insertAdjacentElement('afterbegin', cloned);
                window.scrollTo({ top: 0, behavior: 'smooth' });
                return;
            }
            // Fallback generic success if no flash was present
            const generic = document.createElement('div');
            generic.className = 'alert alert-success alert-dismissible fade show';
            generic.innerHTML = '<i class=\"bi bi-check-circle-fill\"></i> Request submitted successfully.' +
                '<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\"></button>';
            anchor.insertAdjacentElement('afterbegin', generic);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        })
        .catch(err => {
            console.error('Error submitting form:', err);
            buttons.forEach(btn => {
                btn.innerHTML = btn.dataset.originalText;
                btn.disabled = false;
            });
            // Show a visible error message in-page
            document.querySelectorAll('.main-content > .alert-danger, .main-content > .alert-success')
                .forEach(el => el.remove());
            const anchor = document.querySelector('.main-content');
            const errBox = document.createElement('div');
            errBox.className = 'alert alert-danger alert-dismissible fade show';
            errBox.innerHTML = '<i class=\"bi bi-exclamation-circle-fill\"></i> Send failed: ' + err.message +
                '<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\"></button>';
            anchor.insertAdjacentElement('afterbegin', errBox);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
            });
        });
    });
    </script>
    
    <!-- Searchable user dropdown filter -->
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.searchable-select-wrapper').forEach(wrapper => {
            const searchInput = wrapper.querySelector('.search-filter');
            const select = wrapper.querySelector('select');
            
            // Store original options
            const allOptions = Array.from(select.options).map(opt => ({
                value: opt.value,
                text: opt.textContent,
                disabled: opt.disabled
            }));
            
            searchInput.addEventListener('input', function() {
                const query = this.value.toLowerCase();
                
                // Clear existing options
                select.innerHTML = '';
                
                // Add matching options
                allOptions.forEach(opt => {
                    if (opt.value === '' || opt.text.toLowerCase().includes(query)) {
                        const option = document.createElement('option');
                        option.value = opt.value;
                        option.textContent = opt.text;
                        if (opt.disabled) option.disabled = true;
                        select.appendChild(option);
                    }
                });
            });
        });
    });
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
