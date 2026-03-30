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
                  <label class="form-label text-muted small fw-bold">TECHNICIAN ID</label>
                  <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-hash"></i></span>
                    <input type="number" class="form-control border-start-0" name="staff.userId" placeholder="Enter ID" required />
                  </div>
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
                  <input type="date" class="form-control" name="shiftDate" required />
                </div>
                <div class="col-md-3">
                  <label class="form-label text-muted small fw-bold">LOGIN TIME</label>
                  <input type="datetime-local" class="form-control" name="loginTime" />
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
                    <input type="number" step="0.1" class="form-control" name="highestTempRecorded">
                    <span class="input-group-text">°C</span>
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">LOWEST TEMP</label>
                  <div class="input-group">
                    <input type="number" step="0.1" class="form-control" name="lowestTempRecorded">
                    <span class="input-group-text">°C</span>
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">AVG HUMIDITY</label>
                  <div class="input-group">
                    <input type="number" step="0.1" class="form-control" name="avgHumidity">
                    <span class="input-group-text">%</span>
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">COMPRESSOR</label>
                  <input type="text" class="form-control" name="compressorStatus" placeholder="Status desc.">
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
                  <input type="number" class="form-control" name="numIncidents" value="0">
                </div>
                <div class="col-md-4">
                  <label class="form-label small fw-bold text-muted">CRITICAL FAULTS</label>
                  <input type="number" class="form-control" name="criticalIncidents" value="0">
                </div>
                <div class="col-md-4">
                  <label class="form-label small fw-bold text-muted">DOWNTIME (MIN)</label>
                  <input type="number" class="form-control" name="downtimeDurationMin" value="0">
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

          <!-- Section 5: Visitor Log -->
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
              <div class="row g-3">
                <div class="col-md-3">
                  <label class="form-label small fw-bold text-muted">VISITOR COUNT</label>
                  <input type="number" class="form-control" name="numVisitors" value="0">
                </div>
                <div class="col-md-4">
                  <label class="form-label small fw-bold text-muted">APPROVED BY</label>
                  <input type="text" class="form-control" name="visitorApprovedBy" placeholder="Approver Name">
                </div>
                <div class="col-md-5">
                  <label class="form-label small fw-bold text-muted">ESCORT / TECHNICIAN NAME</label>
                  <input type="text" class="form-control" name="escortName" placeholder="Full Name">
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
  </body>
</html>
