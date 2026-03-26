<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SPCMS - New Shift Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <jsp:include page="../common/styles.jsp" />
  </head>
  <body>
    <jsp:include page="../common/sidebar.jsp" />
    <jsp:include page="../common/topbar.jsp" />
    <div class="main-content">
      <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
          <i class="bi bi-exclamation-triangle-fill"></i> ${error}
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:if>
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h4 style="font-weight: 700; margin: 0">Create Shift Report</h4>
          <p class="text-muted mb-0" style="font-size: 14px">Fill in the shift report manually</p>
        </div>
        <a href="${pageContext.request.contextPath}/shift-reports" class="btn btn-outline-secondary"
          ><i class="bi bi-arrow-left"></i> Back</a
        >
      </div>

      <div class="stat-card">
        <form action="${pageContext.request.contextPath}/shift-reports/save" method="post">
          <h6 class="fw-bold mb-3">Shift Information</h6>
          <div class="row g-3 mb-4">
            <div class="col-md-3">
              <label class="form-label">Staff ID <span class="text-danger">*</span></label>
              <select class="form-select" name="staff.userId" required>
                <option value="">Select...</option>
                <c:forEach var="u" items="${users}">
                  <option value="${u.userId}">${u.userId} - ${u.fullName} (${u.username})</option>
                </c:forEach>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Shift Type <span class="text-danger">*</span></label>
              <select class="form-select" name="shiftType" required>
                <option value="">Select...</option>
                <option value="MORNING" ${shiftReport.shiftType == 'MORNING' ? 'selected' : ''}>Morning (06:00 - 14:00)</option>
                <option value="EVENING" ${shiftReport.shiftType == 'EVENING' ? 'selected' : ''}>Evening (14:00 - 22:00)</option>
                <option value="NIGHT" ${shiftReport.shiftType == 'NIGHT' ? 'selected' : ''}>Night (22:00 - 06:00)</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Shift Date <span class="text-danger">*</span></label>
              <input type="date" class="form-control" name="shiftDate" value="${shiftReport.shiftDate}" required />
            </div>
            <div class="col-md-3">
              <label class="form-label">Login Time</label>
              <input type="datetime-local" class="form-control" name="loginTime" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Logout Time</label>
              <input type="datetime-local" class="form-control" name="logoutTime" />
            </div>
          </div>

          <h6 class="fw-bold mb-3">UPS Monitoring Summary</h6>
          <div class="row g-3 mb-4">
            <div class="col-md-3">
              <label class="form-label">Avg Input Voltage (V)</label>
              <input type="number" step="0.01" class="form-control" name="avgInputVoltage" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Avg Output Voltage (V)</label>
              <input type="number" step="0.01" class="form-control" name="avgOutputVoltage" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Max Load (%)</label>
              <input type="number" step="0.01" class="form-control" name="maxLoadPercent" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Min Battery Level (%)</label>
              <input type="number" step="0.01" class="form-control" name="minBatteryLevel" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Battery Runtime Remaining (min)</label>
              <input type="number" class="form-control" name="batteryRuntimeRemaining" />
            </div>
            <div class="col-md-3">
              <div class="form-check mt-4">
                <input type="checkbox" class="form-check-input" name="overloadOccurred" value="true" />
                <label class="form-check-label">Overload Occurred</label>
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-check mt-4">
                <input type="checkbox" class="form-check-input" name="bypassActivated" value="true" />
                <label class="form-check-label">Bypass Activated</label>
              </div>
            </div>
          </div>

          <h6 class="fw-bold mb-3">Cooling Monitoring Summary</h6>
          <div class="row g-3 mb-4">
            <div class="col-md-3">
              <label class="form-label">Highest Temp Recorded (C)</label>
              <input type="number" step="0.01" class="form-control" name="highestTempRecorded" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Lowest Temp Recorded (C)</label>
              <input type="number" step="0.01" class="form-control" name="lowestTempRecorded" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Avg Humidity (%)</label>
              <input type="number" step="0.01" class="form-control" name="avgHumidity" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Compressor Status</label>
              <input type="text" class="form-control" name="compressorStatus" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Fan Status</label>
              <input type="text" class="form-control" name="fanStatus" />
            </div>
            <div class="col-md-3">
              <div class="form-check mt-4">
                <input type="checkbox" class="form-check-input" name="highTempAlarm" value="true" />
                <label class="form-check-label">High Temp Alarm</label>
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-check mt-4">
                <input type="checkbox" class="form-check-input" name="humidityAlarm" value="true" />
                <label class="form-check-label">Humidity Alarm</label>
              </div>
            </div>
          </div>

          <h6 class="fw-bold mb-3">Incidents During Shift</h6>
          <div class="row g-3 mb-4">
            <div class="col-md-3">
              <label class="form-label">Number of Incidents</label>
              <input type="number" class="form-control" name="numIncidents" value="0" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Critical Incidents</label>
              <input type="number" class="form-control" name="criticalIncidents" value="0" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Downtime Duration (min)</label>
              <input type="number" class="form-control" name="downtimeDurationMin" value="0" />
            </div>
            <div class="col-md-12">
              <label class="form-label">Root Cause Summary</label>
              <textarea class="form-control" name="rootCauseSummary" rows="2"></textarea>
            </div>
            <div class="col-md-12">
              <label class="form-label">Action Taken</label>
              <textarea class="form-control" name="actionTaken" rows="2"></textarea>
            </div>
          </div>

          <h6 class="fw-bold mb-3">Maintenance Activities Done</h6>
          <div class="row g-3 mb-4">
            <div class="col-md-12">
              <label class="form-label">Preventive Maintenance Done</label>
              <textarea class="form-control" name="preventiveMaintDone" rows="2"></textarea>
            </div>
            <div class="col-md-12">
              <label class="form-label">Corrective Maintenance Done</label>
              <textarea class="form-control" name="correctiveMaintDone" rows="2"></textarea>
            </div>
            <div class="col-md-12">
              <label class="form-label">Spare Parts Used</label>
              <textarea class="form-control" name="sparePartsUsed" rows="2"></textarea>
            </div>
            <div class="col-md-12">
              <label class="form-label">Photos Uploaded Path</label>
              <input type="text" class="form-control" name="photosUploadedPath" placeholder="./uploads/..." />
            </div>
          </div>

          <h6 class="fw-bold mb-3">Visitor Log</h6>
          <div class="row g-3 mb-4">
            <div class="col-md-3">
              <label class="form-label">Number of Visitors</label>
              <input type="number" class="form-control" name="numVisitors" value="0" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Approved By</label>
              <input type="text" class="form-control" name="visitorApprovedBy" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Escort Name</label>
              <input type="text" class="form-control" name="escortName" />
            </div>
            <div class="col-md-12">
              <label class="form-label">Visit Duration Summary</label>
              <textarea class="form-control" name="visitDurationSummary" rows="2"></textarea>
            </div>
            <div class="col-md-12">
              <label class="form-label">Visitor Incident</label>
              <textarea class="form-control" name="visitorIncident" rows="2"></textarea>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="bi bi-save"></i> Save Shift Report
            </button>
            <a href="${pageContext.request.contextPath}/shift-reports" class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
