<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Decision Request</title>
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
                <h4 style="font-weight:700;margin:0;">Decision Request #${decision.decisionId}</h4>
                <p class="text-muted mb-0" style="font-size:14px;">${decision.requestType}</p>
            </div>
            <a href="${pageContext.request.contextPath}/decisions" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
        </div>

        <div class="stat-card">
            <div class="row g-3">
                <div class="col-md-6">
                    <div class="text-muted">Title</div>
                    <div><strong>${decision.title}</strong></div>
                </div>
                <div class="col-md-3">
                    <div class="text-muted">Amount</div>
                    <div><c:if test="${decision.amount != null}">${decision.amount}</c:if></div>
                </div>
                <div class="col-md-3">
                    <div class="text-muted">Status</div>
                    <div><span class="badge ${decision.status == 'APPROVED' ? 'bg-success' : (decision.status == 'REJECTED' ? 'bg-danger' : 'bg-warning text-dark')}">${decision.status}</span></div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted">Requested By</div>
                    <div>${decision.requestedBy != null ? decision.requestedBy.fullName : 'N/A'}</div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted">Approved By</div>
                    <div>${decision.approvedBy != null ? decision.approvedBy.fullName : 'N/A'}</div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted">Decision Time</div>
                    <div>${decision.decisionTime}</div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted">Equipment</div>
                    <div>${decision.equipment != null ? decision.equipment.equipmentName : 'N/A'}</div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted">UPS</div>
                    <div>${decision.ups != null ? decision.ups.upsName : 'N/A'}</div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted">Cooling Unit</div>
                    <div>${decision.coolingUnit != null ? decision.coolingUnit.unitName : 'N/A'}</div>
                </div>
                <div class="col-12">
                    <div class="text-muted">Description</div>
                    <div>${decision.description}</div>
                </div>
                <div class="col-12">
                    <div class="text-muted">Remarks</div>
                    <div>${decision.remarks}</div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
