<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - ${isEdit ? 'Edit' : 'New'} Decision Request</title>
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
                <h4 style="font-weight:700;margin:0;">${isEdit ? 'Edit' : 'New'} Decision Request</h4>
                <p class="text-muted mb-0" style="font-size:14px;">Submit a request for approval</p>
            </div>
            <a href="${pageContext.request.contextPath}/decisions" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
        </div>

        <div class="stat-card">
            <form action="${pageContext.request.contextPath}/decisions/save" method="post">
                <c:if test="${decisionRequest.requestId != null}">
                    <input type="hidden" name="requestId" value="${decisionRequest.requestId}"/>
                </c:if>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label">Request Type <span class="text-danger">*</span></label>
                        <select class="form-select" name="requestType" required>
                            <c:forEach var="t" items="${requestTypes}">
                                <option value="${t}" ${decisionRequest.requestType == t ? 'selected' : ''}>${t}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label">Title <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title" value="${decisionRequest.title}" required/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Asset / System</label>
                        <input type="text" class="form-control" name="assetOrSystem" value="${decisionRequest.assetOrSystem}" placeholder="e.g., UPS 30kVA, Cooling Unit #2"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Quantity</label>
                        <input type="number" class="form-control" name="quantity" value="${decisionRequest.quantity}"/>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Estimated Cost</label>
                        <input type="number" step="0.01" class="form-control" name="estimatedCost" value="${decisionRequest.estimatedCost}"/>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Vendor / Supplier</label>
                        <input type="text" class="form-control" name="vendorOrSupplier" value="${decisionRequest.vendorOrSupplier}"/>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="description" rows="3">${decisionRequest.description}</textarea>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Justification</label>
                        <textarea class="form-control" name="justification" rows="3">${decisionRequest.justification}</textarea>
                    </div>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Save Request</button>
                    <a href="${pageContext.request.contextPath}/decisions" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
