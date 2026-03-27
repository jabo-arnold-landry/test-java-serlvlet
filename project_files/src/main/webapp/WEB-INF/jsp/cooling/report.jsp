<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Cooling Monitoring Summary</title>
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
                <h4 style="font-weight:700;margin:0;">Cooling Monitoring Summary</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Select a cooling unit to view its monitoring summary</p>
            </div>
            <a href="${pageContext.request.contextPath}/cooling" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
        </div>

        <div class="stat-card mb-4">
            <form action="${pageContext.request.contextPath}/cooling/report" method="get">
                <div class="row g-3 align-items-end">
                    <div class="col-md-8">
                        <label class="form-label">Cooling Unit</label>
                        <select class="form-select" name="coolingId" required>
                            <option value="" disabled ${reportCoolingId == null ? 'selected' : ''}>-- Select Cooling Unit --</option>
                            <c:forEach var="unit" items="${coolingUnits}">
                                <option value="${unit.coolingId}" ${reportCoolingId == unit.coolingId ? 'selected' : ''}>
                                    ${unit.assetTag} - ${unit.unitName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-eye"></i> View Summary
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <c:if test="${summary != null}">
            <c:choose>
                <c:when test="${summarySource == 'logs'}">
                    <div class="alert alert-success">
                        Summary based on monitoring readings for the selected unit.
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning">
                        No monitoring readings found for this unit. Showing the current cooling unit snapshot.
                    </div>
                </c:otherwise>
            </c:choose>
            <div class="stat-card mb-4">
                <h6 class="fw-bold mb-2"><i class="bi bi-snow2"></i> Selected Cooling Unit</h6>
                <div>
                    <strong>${selectedCooling != null ? selectedCooling.assetTag : ''}</strong>
                    ${selectedCooling != null ? ' - ' : ''}${selectedCooling != null ? selectedCooling.unitName : ''}
                </div>
                <div class="text-muted" style="font-size:13px;">
                    ${selectedCooling != null ? selectedCooling.locationRoom : ''} ${selectedCooling != null && selectedCooling.locationZone != null ? '- ' : ''}${selectedCooling != null ? selectedCooling.locationZone : ''}
                </div>
            </div>
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Total Readings</div>
                        <div class="stat-value">${summary.totalReadings}</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Avg Return Temp</div>
                        <div class="stat-value">${summary.avgReturnTemp != null ? summary.avgReturnTemp : 'N/A'}</div>
                        <div class="text-muted" style="font-size:12px;">&deg;C</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Avg Supply Temp</div>
                        <div class="stat-value">${summary.avgSupplyTemp != null ? summary.avgSupplyTemp : 'N/A'}</div>
                        <div class="text-muted" style="font-size:12px;">&deg;C</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Avg Humidity</div>
                        <div class="stat-value">${summary.avgHumidity != null ? summary.avgHumidity : 'N/A'}</div>
                        <div class="text-muted" style="font-size:12px;">%</div>
                    </div>
                </div>
            </div>
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Max Return Temp</div>
                        <div class="stat-value">${summary.maxReturnTemp != null ? summary.maxReturnTemp : 'N/A'}</div>
                        <div class="text-muted" style="font-size:12px;">&deg;C</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="stat-label">Min Return Temp</div>
                        <div class="stat-value">${summary.minReturnTemp != null ? summary.minReturnTemp : 'N/A'}</div>
                        <div class="text-muted" style="font-size:12px;">&deg;C</div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="stat-card text-center">
                        <div class="stat-label">High Temp</div>
                        <div class="stat-value">${summary.highTempCount}</div>
                        <div class="text-muted" style="font-size:12px;">&gt; 28&deg;C</div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="stat-card text-center">
                        <div class="stat-label">High Humidity</div>
                        <div class="stat-value">${summary.highHumidityCount}</div>
                        <div class="text-muted" style="font-size:12px;">&gt; 65%</div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="stat-card text-center">
                        <div class="stat-label">Low Humidity</div>
                        <div class="stat-value">${summary.lowHumidityCount}</div>
                        <div class="text-muted" style="font-size:12px;">&lt; 30%</div>
                    </div>
                </div>
            </div>

            <div class="stat-card mb-3">
                <h6 class="fw-bold mb-0"><i class="bi bi-list-check"></i> Cooling Unit Performance</h6>
            </div>
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Time</th>
                            <th>Cooling ID</th>
                            <th>Supply Temp</th>
                            <th>Return Temp</th>
                            <th>Humidity</th>
                            <th>Cooling Unit Performance</th>
                            <th>Recorded By</th>
                            <th>Notes</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${reportLogs}">
                        <tr>
                            <td>${log.readingTime}</td>
                            <td>${log.equipmentId}</td>
                            <td>${log.supplyAirTemp != null ? log.supplyAirTemp : '-'}</td>
                            <td>${log.returnAirTemp != null ? log.returnAirTemp : '-'}</td>
                            <td>${log.humidityPercent != null ? log.humidityPercent : '-'}</td>
                            <td>${reportPerformance[log.logId] != null ? reportPerformance[log.logId] : (log.coolingPerformance != null ? log.coolingPerformance : '-')}</td>
                            <td>${log.recordedBy != null ? log.recordedBy.fullName : 'N/A'}</td>
                            <td>${log.notes != null ? log.notes : '-'}</td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty reportLogs}">
                        <tr>
                            <td colspan="8" class="text-center text-muted py-4">
                                No monitoring readings found for this unit.
                            </td>
                        </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>
        <c:if test="${summary == null}">
            <div class="alert alert-info">
                Select a cooling unit and click "View Summary" to see monitoring results.
            </div>
        </c:if>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
