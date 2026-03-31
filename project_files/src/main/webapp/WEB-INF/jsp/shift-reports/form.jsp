<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%> <%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SPCMS - New Shift Report</title>
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
      rel="stylesheet"
    />
    <link
      href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
      rel="stylesheet"
    />
    <jsp:include page="../common/styles.jsp" />
  </head>
  <body>
    <jsp:include page="../common/sidebar.jsp" />
    <jsp:include page="../common/topbar.jsp" />
    <div class="main-content">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h4 style="font-weight: 700; margin: 0">Create Shift Report</h4>
          <p class="text-muted mb-0" style="font-size: 14px">
            Level 1 - Technician shift summary with auto-calculated metrics
          </p>
        </div>
        <a
          href="${pageContext.request.contextPath}/shift-reports"
          class="btn btn-outline-secondary"
          ><i class="bi bi-arrow-left"></i> Back</a
        >
      </div>
      <div class="stat-card">
        <form
          action="${pageContext.request.contextPath}/shift-reports/save"
          method="post"
        >
          <!-- Section 1: Staff & Shift Context -->
          <div class="card mb-4 border-0 shadow-sm">
            <div class="card-header bg-white border-0 py-3">
              <div class="d-flex align-items-center">
                <div class="bg-primary bg-opacity-10 p-2 rounded-3 me-3">
                  <i class="bi bi-person-badge text-primary fs-5"></i>
                </div>
                <h6 class="fw-bold mb-0">Staff & Shift Context</h6>
              </div>
            </div>
            <div class="card-body pt-0">
              <div class="row g-3">
                <div class="col-md-3">
                  <label class="form-label text-muted small fw-bold">TECHNICIAN</label>
                  <c:choose>
                    <c:when test="${not empty currentUser}">
                      <input type="text" class="form-control" value="${currentUser.fullName}" readonly />
                      <input type="hidden" name="staff.userId" value="${currentUser.userId}" />
                    </c:when>
                    <c:otherwise>
                      <input type="text" class="form-control" value="Unknown user" readonly />
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="col-md-3">
                  <label class="form-label text-muted small fw-bold">SHIFT TYPE</label>
                  <select class="form-select" name="shiftType" required>
                    <option value="MORNING">☀️ Morning Shift</option>
                    <option value="EVENING">🌆 Evening Shift</option>
                    <option value="NIGHT">🌙 Night Shift</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="form-label text-muted small fw-bold">SHIFT DATE</label>
                  <input type="date" class="form-control" id="shiftDate" name="shiftDate" value="${shiftReport.shiftDate}" onchange="fetchDailySummary()" required />
                </div>
                <div class="col-md-3">
                  <label class="form-label text-muted small fw-bold">LOGIN TIME</label>
                  <input type="datetime-local" class="form-control" name="loginTime" value="${shiftReport.loginTime}" />
                </div>
              </div>
            </div>
          </div>

          <!-- Section 2: UPS Monitoring Summary -->
          <div class="card mb-4 border-0 shadow-sm">
            <div class="card-header bg-white border-0 py-3">
              <div class="d-flex align-items-center">
                <div class="bg-warning bg-opacity-10 p-2 rounded-3 me-3">
                  <i class="bi bi-lightning-charge text-warning fs-5"></i>
                </div>
                <h6 class="fw-bold mb-0">UPS Monitoring Summary (During Shift)</h6>
              </div>
            </div>
            <div class="card-body pt-0">
              <div class="row g-4">
                <!-- Electrical Metrics Group -->
                <div class="col-md-6">
                  <div class="p-3 bg-light rounded-3">
                    <label class="d-block mb-2 small fw-bold text-uppercase text-muted border-bottom pb-1">Electrical Metrics</label>
                    <div class="row g-3">
                      <div class="col-6">
                        <label class="form-label small">Avg Input Voltage</label>
                        <div class="input-group input-group-sm">
                          <input type="number" step="0.01" class="form-control" name="avgInputVoltage" placeholder="0.00">
                          <span class="input-group-text border-start-0 small">V</span>
                        </div>
                      </div>
                      <div class="col-6">
                        <label class="form-label small">Avg Output Voltage</label>
                        <div class="input-group input-group-sm">
                          <input type="number" step="0.01" class="form-control" name="avgOutputVoltage" placeholder="0.00">
                          <span class="input-group-text border-start-0 small">V</span>
                        </div>
                      </div>
                      <div class="col-12">
                        <label class="form-label small">Max Load Percentage</label>
                        <div class="input-group input-group-sm">
                          <input type="number" step="0.1" class="form-control" name="maxLoadPercent" placeholder="0.0">
                          <span class="input-group-text border-start-0 small">%</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <!-- Battery Status Group -->
                <div class="col-md-6">
                  <div class="p-3 bg-light rounded-3">
                    <label class="d-block mb-2 small fw-bold text-uppercase text-muted border-bottom pb-1">Battery & Runtime</label>
                    <div class="row g-3">
                      <div class="col-6">
                        <label class="form-label small">Min Battery Level</label>
                        <div class="input-group input-group-sm">
                          <input type="number" step="0.1" class="form-control" name="minBatteryLevel" placeholder="0.0">
                          <span class="input-group-text border-start-0 small">%</span>
                        </div>
                      </div>
                      <div class="col-6">
                        <label class="form-label small">Est. Runtime</label>
                        <div class="input-group input-group-sm">
                          <input type="number" class="form-control" name="batteryRuntimeRemaining" placeholder="0">
                          <span class="input-group-text border-start-0 small">min</span>
                        </div>
                      </div>
                      <div class="col-12 mt-4">
                        <div class="d-flex gap-4">
                          <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" name="overloadOccurred" value="true">
                            <label class="form-check-label small">Overload Event</label>
                          </div>
                          <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" name="bypassActivated" value="true">
                            <label class="form-check-label small">Bypass Active</label>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Section 3: Cooling Monitoring Summary -->
          <div class="card mb-4 border-0 shadow-sm">
            <div class="card-header bg-white border-0 py-3">
              <div class="d-flex align-items-center">
                <div class="bg-info bg-opacity-10 p-2 rounded-3 me-3">
                  <i class="bi bi-snow text-info fs-5"></i>
                </div>
                <h6 class="fw-bold mb-0">Cooling Monitoring Summary</h6>
              </div>
            </div>
            <div class="card-body pt-0">
              <div class="row g-3">
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">HIGHEST TEMP</label>
                  <div class="input-group">
                    <input type="number" step="0.1" class="form-control bg-light" id="highestTempRecorded" name="highestTempRecorded" readonly>
                    <span class="input-group-text">°C</span>
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">LOWEST TEMP</label>
                  <div class="input-group">
                    <input type="number" step="0.1" class="form-control bg-light" id="lowestTempRecorded" name="lowestTempRecorded" readonly>
                    <span class="input-group-text">°C</span>
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">AVG HUMIDITY</label>
                  <div class="input-group">
                    <input type="number" step="0.1" class="form-control bg-light" id="avgHumidity" name="avgHumidity" readonly>
                    <span class="input-group-text">%</span>
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">COMPRESSOR</label>
                  <input type="text" class="form-control bg-light" id="compressorStatus" name="compressorStatus" placeholder="Auto-calculated" readonly>
                </div>
                <div class="col-md-12 mt-3">
                  <div class="d-flex gap-4">
                    <div class="form-check form-switch">
                      <input class="form-check-input" type="checkbox" name="highTempAlarm" value="true">
                      <label class="form-check-label small">Temp Alarm Triggered</label>
                    </div>
                    <div class="form-check form-switch">
                      <input class="form-check-input" type="checkbox" name="humidityAlarm" value="true">
                      <label class="form-check-label small">Humidity Alarm Triggered</label>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Section 4: Incidents & Activities -->
          <div class="card mb-4 border-0 shadow-sm">
            <div class="card-header bg-white border-0 py-3">
              <div class="d-flex align-items-center">
                <div class="bg-danger bg-opacity-10 p-2 rounded-3 me-3">
                  <i class="bi bi-exclamation-triangle text-danger fs-5"></i>
                </div>
                <h6 class="fw-bold mb-0">Incidents & Activities During Shift</h6>
              </div>
            </div>
            <div class="card-body pt-0">
              <div class="row g-3 mb-3">
                <div class="col-md-4">
                  <label class="form-label small fw-bold text-muted">TOTAL INCIDENTS</label>
                  <input type="number" class="form-control bg-light" id="numIncidents" name="numIncidents" value="0" readonly>
                </div>
                <div class="col-md-4">
                  <label class="form-label small fw-bold text-muted">CRITICAL FAULTS</label>
                  <input type="number" class="form-control bg-light" id="criticalIncidents" name="criticalIncidents" value="0" readonly>
                </div>
                <div class="col-md-4">
                  <label class="form-label small fw-bold text-muted">DOWNTIME (MIN)</label>
                  <input type="number" class="form-control bg-light" id="downtimeDurationMin" name="downtimeDurationMin" value="0" readonly>
                </div>
              </div>
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label small fw-bold text-muted">ROOT CAUSE SUMMARY</label>
                  <textarea class="form-control" name="rootCauseSummary" rows="3" placeholder="Explain what happened..."></textarea>
                </div>
                <div class="col-md-6">
                  <label class="form-label small fw-bold text-muted">ACTION TAKEN</label>
                  <textarea class="form-control" name="actionTaken" rows="3" placeholder="Steps taken to resolve..."></textarea>
                </div>
              </div>
            </div>
          </div>

          <!-- Section 5: Maintenance Activities -->
          <div class="card mb-4 border-0 shadow-sm">
            <div class="card-header bg-white border-0 py-3">
              <div class="d-flex align-items-center">
                <div class="bg-primary bg-opacity-10 p-2 rounded-3 me-3">
                  <i class="bi bi-tools text-primary fs-5"></i>
                </div>
                <h6 class="fw-bold mb-0">Maintenance Activities</h6>
              </div>
            </div>
            <div class="card-body pt-0">
              <div class="row g-3 mb-3">
                <div class="col-md-12">
                  <label class="form-label small fw-bold text-muted">SELECT MAINTENANCE TYPE</label>
                  <div class="d-flex gap-4 mt-1">
                    <div class="form-check">
                      <input class="form-check-input" type="checkbox" id="checkPreventive" onchange="toggleMaintInput('preventive')">
                      <label class="form-check-label" for="checkPreventive">Preventive Maintenance</label>
                    </div>
                    <div class="form-check">
                      <input class="form-check-input" type="checkbox" id="checkCorrective" onchange="toggleMaintInput('corrective')">
                      <label class="form-check-label" for="checkCorrective">Corrective Maintenance</label>
                    </div>
                  </div>
                </div>
              </div>
              <div class="row g-3">
                <div class="col-md-6" id="preventiveSection" style="display:none;">
                  <label class="form-label small fw-bold text-muted">PREVENTIVE TASKS SUMMARY</label>
                  <textarea class="form-control" name="preventiveMaintDone" rows="3" placeholder="List preventive tasks done..."></textarea>
                </div>
                <div class="col-md-6" id="correctiveSection" style="display:none;">
                  <label class="form-label small fw-bold text-muted">CORRECTIVE TASKS SUMMARY</label>
                  <textarea class="form-control" name="correctiveMaintDone" rows="3" placeholder="List corrective tasks done..."></textarea>
                </div>
                <div class="col-md-12">
                  <label class="form-label small fw-bold text-muted">SPARE PARTS USED</label>
                  <textarea class="form-control" name="sparePartsUsed" rows="2" placeholder="Document any spare parts used during this shift..."></textarea>
                </div>
              </div>
              <script>
                function toggleMaintInput(type) {
                    const check = document.getElementById('check' + type.charAt(0).toUpperCase() + type.slice(1));
                    const section = document.getElementById(type + 'Section');
                    if (check.checked) {
                        section.style.display = 'block';
                    } else {
                        section.style.display = 'none';
                        section.querySelector('textarea').value = '';
                    }
                }
              </script>
            </div>
          </div>

          <!-- Section 6: Visitor Log -->
          <div class="card mb-4 border-0 shadow-sm">
            <div class="card-header bg-white border-0 py-3">
              <div class="d-flex align-items-center">
                <div class="bg-success bg-opacity-10 p-2 rounded-3 me-3">
                  <i class="bi bi-people text-success fs-5"></i>
                </div>
                <h6 class="fw-bold mb-0">Visitor Log Summary</h6>
              </div>
            </div>
            <div class="card-body pt-0">
              <table class="table table-bordered mb-0">
                <thead class="table-light">
                  <tr>
                    <th scope="col" style="font-size:12px;" class="text-muted fw-bold">NUMBER OF VISITORS</th>
                    <th scope="col" style="font-size:12px;" class="text-muted fw-bold">APPROVED BY</th>
                    <th scope="col" style="font-size:12px;" class="text-muted fw-bold">ESCORT / TECHNICIAN NAME</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><input type="number" class="form-control border-0" name="numVisitors" value="0"></td>
                    <td><input type="text" class="form-control border-0" name="visitorApprovedBy" placeholder="Approver Name"></td>
                    <td><input type="text" class="form-control border-0" name="escortName" placeholder="Full Name"></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Section 7: Mandatory Handover Notes -->
          <div class="card mb-4 border-0 shadow-sm border-start border-warning border-4">
            <div class="card-header bg-white border-0 py-3">
              <div class="d-flex align-items-center">
                <div class="bg-warning bg-opacity-10 p-2 rounded-3 me-3">
                  <i class="bi bi-journal-text text-warning fs-5"></i>
                </div>
                <h6 class="fw-bold mb-0">Mandatory Shift Handover Notes</h6>
              </div>
            </div>
            <div class="card-body pt-0">
              <div class="row g-3">
                <div class="col-md-12">
                  <label class="form-label small fw-bold text-muted">SYSTEM STATUS SUMMARY <span class="text-danger">*</span></label>
                  <textarea class="form-control" name="handoverSystemStatus" rows="2" placeholder="Overall status of the systems at the end of shift..." required></textarea>
                </div>
                <div class="col-md-6">
                  <label class="form-label small fw-bold text-muted">PENDING ISSUES (REMAINING TASKS)</label>
                  <textarea class="form-control" name="handoverPendingIssues" rows="3" placeholder="Tasks or issues passing to the next shift..."></textarea>
                </div>
                <div class="col-md-6">
                  <label class="form-label small fw-bold text-muted">RECOMMENDATIONS <span class="text-danger">*</span></label>
                  <textarea class="form-control" name="handoverRecommendations" rows="3" placeholder="Recommendations for next shift..." required></textarea>
                </div>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="d-flex gap-3 justify-content-end mt-5 pb-5">
            <a href="${pageContext.request.contextPath}/shift-reports" class="btn btn-light px-4 border">
              Cancel
            </a>
            <button type="submit" class="btn btn-primary px-5 shadow-sm">
              <i class="bi bi-check2-circle me-2"></i> Submit Official Report
            </button>
          </div>
        </form>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
      function fetchDailySummary() {
        const shiftDate = document.getElementById('shiftDate').value;
        if (!shiftDate) return;

        // Visual feedback
        document.getElementById('highestTempRecorded').placeholder = "Loading...";
        document.getElementById('numIncidents').placeholder = "Loading...";

        fetch(`${pageContext.request.contextPath}/shift-reports/api/daily-summary?date=` + shiftDate)
          .then(res => res.json())
          .then(data => {
            document.getElementById('highestTempRecorded').value = data.highestTemp || 0;
            document.getElementById('lowestTempRecorded').value = data.lowestTemp || 0;
            document.getElementById('avgHumidity').value = data.avgHumidity || 0;
            document.getElementById('compressorStatus').value = data.compressorStatus || 'OK';
            
            document.getElementById('numIncidents').value = data.totalIncidents || 0;
            document.getElementById('criticalIncidents').value = data.criticalFaults || 0;
            document.getElementById('downtimeDurationMin').value = data.totalDowntime || 0;
          })
          .catch(err => {
            console.error('Failed to fetch daily summary', err);
          });
      }

      // Initial load
      document.addEventListener('DOMContentLoaded', function() {
        fetchDailySummary();
      });
    </script>
  </body>
</html>
