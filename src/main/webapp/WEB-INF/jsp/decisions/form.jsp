<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${decision.decisionId != null ? 'Edit' : 'New'} Decision Request</title>
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
                <h4 style="font-weight:700;margin:0;">${decision.decisionId != null ? 'Edit' : 'Submit'} Decision Request</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Maintenance budget, equipment replacement, or procurement approval</p>
            </div>
            <a href="${pageContext.request.contextPath}/decisions" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/decisions/save" method="post">
                <c:if test="${decision.decisionId != null}">
                    <input type="hidden" name="decisionId" value="${decision.decisionId}"/>
                </c:if>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Request Type <span class="text-danger">*</span></label>
                        <select class="form-select" name="requestType" required>
                            <option value="MAINTENANCE_BUDGET" ${decision.requestType == 'MAINTENANCE_BUDGET' ? 'selected' : ''}>Maintenance Budget</option>
                            <option value="EQUIPMENT_REPLACEMENT" ${decision.requestType == 'EQUIPMENT_REPLACEMENT' ? 'selected' : ''}>Equipment Replacement</option>
                            <option value="UPS_PROCUREMENT" ${decision.requestType == 'UPS_PROCUREMENT' ? 'selected' : ''}>New UPS Procurement</option>
                            <option value="COOLING_PROCUREMENT" ${decision.requestType == 'COOLING_PROCUREMENT' ? 'selected' : ''}>New Cooling Procurement</option>
                        </select>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label">Title <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title" value="${decision.title}" required/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Amount</label>
                        <input type="number" step="0.01" class="form-control" name="amount" value="${decision.amount}"/>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label">Requested By</label>
                        <select class="form-select" name="requestedBy.userId">
                            <option value="">Auto (current user)</option>
                            <c:forEach var="u" items="${users}">
                                <option value="${u.userId}" ${decision.requestedBy != null && decision.requestedBy.userId == u.userId ? 'selected' : ''}>${u.fullName} (${u.username})</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Equipment (optional)</label>
                        <select class="form-select" name="equipment.equipmentId">
                            <option value="">None</option>
                            <c:forEach var="e" items="${equipmentList}">
                                <option value="${e.equipmentId}" ${decision.equipment != null && decision.equipment.equipmentId == e.equipmentId ? 'selected' : ''}>${e.equipmentName} (${e.assetTagNumber})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">UPS (optional)</label>
                        <select class="form-select" name="ups.upsId">
                            <option value="">None</option>
                            <c:forEach var="u" items="${upsList}">
                                <option value="${u.upsId}" ${decision.ups != null && decision.ups.upsId == u.upsId ? 'selected' : ''}>${u.upsName} (${u.assetTag})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Cooling Unit (optional)</label>
                        <select class="form-select" name="coolingUnit.coolingId">
                            <option value="">None</option>
                            <c:forEach var="c" items="${coolingList}">
                                <option value="${c.coolingId}" ${decision.coolingUnit != null && decision.coolingUnit.coolingId == c.coolingId ? 'selected' : ''}>${c.unitName} (${c.assetTag})</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label">Description</label>
                    <textarea class="form-control" name="description" rows="4" placeholder="Provide details and justification...">${decision.description}</textarea>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Save</button>
                    <a href="${pageContext.request.contextPath}/decisions" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
