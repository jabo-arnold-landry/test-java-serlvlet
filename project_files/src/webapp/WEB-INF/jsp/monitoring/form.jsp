<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%> <%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SPCMS - Record Reading</title>
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
          <h4 style="font-weight: 700; margin: 0">Record Manual Reading</h4>
          <p class="text-muted mb-0" style="font-size: 14px">
            Enter UPS or Cooling monitoring readings
          </p>
        </div>
        <a
          href="${pageContext.request.contextPath}/monitoring"
          class="btn btn-outline-secondary"
          ><i class="bi bi-arrow-left"></i> Back</a
        >
      </div>
      <div class="stat-card">
        <form
          action="${pageContext.request.contextPath}/monitoring/save"
          method="post"
        >
          <h6 class="fw-bold mb-3">Equipment Selection</h6>
          <div class="row g-3 mb-4">
            <div class="col-md-4">
              <label class="form-label"
                >Equipment Type <span class="text-danger">*</span></label
              >
              <select
                class="form-select"
                name="equipmentType"
                id="equipmentType"
                required
                onchange="toggleFields()"
              >
                <option value="">-- Select --</option>
                <option value="UPS">UPS</option>
                <option value="COOLING">Cooling Unit</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label"
                >Equipment <span class="text-danger">*</span></label
              >
              <select
                class="form-select"
                name="equipmentId"
                id="upsSelect"
                disabled
              >
                <option value="">-- Select UPS --</option>
                <c:forEach var="u" items="${upsList}">
                  <option value="${u.upsId}">${u.upsName} (${u.assetTag})</option>
                </c:forEach>
              </select>
              <select
                class="form-select mt-2"
                name="equipmentId"
                id="coolingSelect"
                disabled
              >
                <option value="">-- Select Cooling Unit --</option>
                <c:forEach var="c" items="${coolingList}">
                  <option value="${c.coolingId}">${c.unitName} (${c.assetTag})</option>
                </c:forEach>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Recorded By</label>
              <input
                type="text"
                class="form-control"
                value="Current User"
                disabled
              />
            </div>
          </div>

          <div id="upsFields">
            <h6 class="fw-bold mb-3">UPS Readings</h6>
            <div class="row g-3 mb-4">
              <div class="col-md-3">
                <label class="form-label">Input Voltage (V)</label>
                <input
                  type="number"
                  step="0.01"
                  class="form-control"
                  name="inputVoltage"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Output Voltage (V)</label>
                <input
                  type="number"
                  step="0.01"
                  class="form-control"
                  name="outputVoltage"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Load (%)</label>
                <input
                  type="number"
                  step="0.01"
                  class="form-control"
                  name="loadPercentage"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Temperature</label>
                <input
                  type="number"
                  step="0.01"
                  class="form-control"
                  name="temperature"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Battery Status</label>
                <input
                  type="text"
                  class="form-control"
                  name="batteryStatus"
                  placeholder="e.g., Normal, Low"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Runtime Remaining (min)</label>
                <input
                  type="number"
                  class="form-control"
                  name="runtimeRemaining"
                />
              </div>
            </div>
          </div>

          <div id="coolingFields">
            <h6 class="fw-bold mb-3">Cooling Readings</h6>
            <div class="row g-3 mb-4">
              <div class="col-md-3">
                <label class="form-label">Supply Air Temp</label>
                <input
                  type="number"
                  step="0.01"
                  class="form-control"
                  name="supplyAirTemp"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Return Air Temp</label>
                <input
                  type="number"
                  step="0.01"
                  class="form-control"
                  name="returnAirTemp"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Humidity (%)</label>
                <input
                  type="number"
                  step="0.01"
                  class="form-control"
                  name="humidityPercent"
                />
              </div>
              <div class="col-md-3">
                <label class="form-label">Cooling Performance</label>
                <input
                  type="text"
                  class="form-control"
                  name="coolingPerformance"
                  placeholder="e.g., Good, Degraded"
                />
              </div>
            </div>
          </div>

          <h6 class="fw-bold mb-3">Notes</h6>
          <div class="row g-3 mb-4">
            <div class="col-12">
              <textarea
                class="form-control"
                name="notes"
                rows="3"
                placeholder="Additional observations..."
              ></textarea>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="bi bi-save"></i> Save Reading
            </button>
            <a
              href="${pageContext.request.contextPath}/monitoring"
              class="btn btn-outline-secondary"
              >Cancel</a
            >
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

        var upsSelect = document.getElementById("upsSelect");
        var coolingSelect = document.getElementById("coolingSelect");

        if (type === "UPS") {
          upsSelect.disabled = false;
          upsSelect.required = true;
          upsSelect.style.display = "block";
          coolingSelect.disabled = true;
          coolingSelect.required = false;
          coolingSelect.style.display = "none";
        } else if (type === "COOLING") {
          coolingSelect.disabled = false;
          coolingSelect.required = true;
          coolingSelect.style.display = "block";
          upsSelect.disabled = true;
          upsSelect.required = false;
          upsSelect.style.display = "none";
        } else {
          upsSelect.disabled = true;
          upsSelect.required = false;
          upsSelect.style.display = "block";
          coolingSelect.disabled = true;
          coolingSelect.required = false;
          coolingSelect.style.display = "block";
        }
      }
      toggleFields();
    </script>
  </body>
</html>
