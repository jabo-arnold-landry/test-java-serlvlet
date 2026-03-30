<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>SPCMS - ${viewMode ? 'View' : (monitoringLog.logId != null ? 'Edit' : 'Record')} Reading</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
        rel="stylesheet" />
      <jsp:include page="../common/styles.jsp" />
    </head>

    <body>
      <jsp:include page="../common/sidebar.jsp" />
      <jsp:include page="../common/topbar.jsp" />
      <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
          <div>
            <h4 style="font-weight: 700; margin: 0">
              <c:choose>
                <c:when test="${viewMode}">View Reading</c:when>
                <c:when test="${monitoringLog.logId != null}">Edit Reading</c:when>
                <c:otherwise>Record Manual Reading</c:otherwise>
              </c:choose>
            </h4>
            <p class="text-muted mb-0" style="font-size: 14px">
              <c:choose>
                <c:when test="${viewMode}">Viewing UPS or Cooling monitoring reading details</c:when>
                <c:otherwise>Enter UPS or Cooling monitoring readings</c:otherwise>
              </c:choose>
            </p>
          </div>
          <a href="${pageContext.request.contextPath}/monitoring" class="btn btn-outline-secondary"><i
              class="bi bi-arrow-left"></i> Back</a>
        </div>
        <div class="stat-card">
          <form action="${pageContext.request.contextPath}/monitoring/save" method="post">
            <c:if test="${monitoringLog.logId != null}">
              <input type="hidden" name="logId" value="${monitoringLog.logId}" />
            </c:if>
            <c:if test="${monitoringLog.readingTime != null}">
              <input type="hidden" name="readingTime" value="${monitoringLog.readingTime}" />
            </c:if>

            <h6 class="fw-bold mb-3">Equipment Selection</h6>
            <div class="row g-3 mb-4">
              <div class="col-md-4">
                <label class="form-label">Equipment Type <span class="text-danger">*</span></label>
                <select class="form-select" name="equipmentType" id="equipmentType" required onchange="toggleFields()"
                  ${viewMode ? 'disabled' : '' }>
                  <option value="">-- Select --</option>
                  <option value="UPS" ${monitoringLog.equipmentType=='UPS' ? 'selected' : '' }>UPS</option>
                  <option value="COOLING" ${monitoringLog.equipmentType=='COOLING' ? 'selected' : '' }>Cooling Unit
                  </option>
                </select>
                <c:if test="${viewMode}">
                  <input type="hidden" name="equipmentType" value="${monitoringLog.equipmentType}" />
                </c:if>
              </div>
              <div class="col-md-4">
                <label class="form-label">Equipment ID <span class="text-danger">*</span></label>
                <input type="number" class="form-control" name="equipmentId" required placeholder="Enter asset ID"
                  value="${monitoringLog.equipmentId}" ${viewMode ? 'readonly' : '' } />
              </div>
              <div class="col-md-4">
                <label class="form-label">Recorded By (User ID)</label>
                <input type="number" class="form-control" name="recordedByUserId" placeholder="Your user ID"
                  value="${monitoringLog.recordedBy != null ? monitoringLog.recordedBy.userId : ''}" ${viewMode
                  ? 'readonly' : '' } />
              </div>
            </div>

            <div id="upsFields">
              <h6 class="fw-bold mb-3">UPS Readings</h6>
              <div class="row g-3 mb-4">
                <div class="col-md-3">
                  <label class="form-label">Input Voltage (V)</label>
                  <input type="number" step="0.01" class="form-control" name="inputVoltage"
                    value="${monitoringLog.inputVoltage}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Output Voltage (V)</label>
                  <input type="number" step="0.01" class="form-control" name="outputVoltage"
                    value="${monitoringLog.outputVoltage}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Load (%)</label>
                  <input type="number" step="0.01" class="form-control" name="loadPercentage"
                    value="${monitoringLog.loadPercentage}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Temperature</label>
                  <input type="number" step="0.01" class="form-control" name="temperature"
                    value="${monitoringLog.temperature}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Battery Status</label>
                  <input type="text" class="form-control" name="batteryStatus" placeholder="e.g., Normal, Low"
                    value="${monitoringLog.batteryStatus}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Runtime Remaining (min)</label>
                  <input type="number" class="form-control" name="runtimeRemaining"
                    value="${monitoringLog.runtimeRemaining}" ${viewMode ? 'readonly' : '' } />
                </div>
              </div>
            </div>

            <div id="coolingFields">
              <h6 class="fw-bold mb-3">Cooling Readings</h6>
              <div class="row g-3 mb-4">
                <div class="col-md-3">
                  <label class="form-label">Supply Air Temp</label>
                  <input type="number" step="0.01" class="form-control" name="supplyAirTemp"
                    value="${monitoringLog.supplyAirTemp}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Return Air Temp</label>
                  <input type="number" step="0.01" class="form-control" name="returnAirTemp"
                    value="${monitoringLog.returnAirTemp}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Humidity (%)</label>
                  <input type="number" step="0.01" class="form-control" name="humidityPercent"
                    value="${monitoringLog.humidityPercent}" ${viewMode ? 'readonly' : '' } />
                </div>
                <div class="col-md-3">
                  <label class="form-label">Cooling Performance</label>
                  <input type="text" class="form-control" name="coolingPerformance" placeholder="e.g., Good, Degraded"
                    value="${monitoringLog.coolingPerformance}" ${viewMode ? 'readonly' : '' } />
                </div>
              </div>
            </div>

            <h6 class="fw-bold mb-3">Notes</h6>
            <div class="row g-3 mb-4">
              <div class="col-12">
                <textarea class="form-control" name="notes" rows="3" placeholder="Additional observations..." ${viewMode
                  ? 'readonly' : '' }>${monitoringLog.notes}</textarea>
              </div>
            </div>

            <div class="d-flex gap-2">
              <c:if test="${!viewMode}">
                <button type="submit" class="btn btn-primary">
                  <i class="bi bi-save"></i>
                  ${monitoringLog.logId != null ? 'Update Reading' : 'Save Reading'}
                </button>
              </c:if>
              <c:if test="${viewMode}">
                <a href="${pageContext.request.contextPath}/monitoring/edit/${monitoringLog.logId}"
                  class="btn btn-warning">
                  <i class="bi bi-pencil"></i> Edit
                </a>
              </c:if>
              <a href="${pageContext.request.contextPath}/monitoring" class="btn btn-outline-secondary">Cancel</a>
            </div>
          </form>
        </div>
      </div>
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
      <script>
        function toggleFields() {
          var type = document.getElementById("equipmentType").value;
          document.getElementById("upsFields").style.display =
            type === "UPS" || type === "" ? "block" : "none";
          document.getElementById("coolingFields").style.display =
            type === "COOLING" || type === "" ? "block" : "none";
        }
        toggleFields();
      </script>
    </body>

    </html>