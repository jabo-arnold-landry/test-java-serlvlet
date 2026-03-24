<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.context.ApplicationContext" %>
<%@ page import="com.spcms.repositories.UpsMaintenanceRepository" %>
<%@ page import="com.spcms.repositories.CoolingMaintenanceRepository" %>
<%@ page import="org.springframework.data.domain.Sort" %>
<%
    ApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(config.getServletContext());
    UpsMaintenanceRepository upsRepo = ctx.getBean(UpsMaintenanceRepository.class);
    CoolingMaintenanceRepository coolRepo = ctx.getBean(CoolingMaintenanceRepository.class);
    request.setAttribute("allUpsMaintenance", upsRepo.findAll(Sort.by(Sort.Direction.DESC, "maintenanceDate")));
    request.setAttribute("allCoolingMaintenance", coolRepo.findAll(Sort.by(Sort.Direction.DESC, "maintenanceDate")));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SPCMS - Maintenance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="../common/styles.jsp"/>
</head>
<body>
    <jsp:include page="../common/sidebar.jsp"/>
    <jsp:include page="../common/topbar.jsp"/>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div><h4 style="font-weight:700;margin:0;">Maintenance Schedule Report</h4></div>
            <div>
                <a href="${pageContext.request.contextPath}/maintenance/ups/new" class="btn btn-outline-primary shadow-sm me-2"><i class="bi bi-battery-charging"></i> Log UPS Maint</a>
                <a href="${pageContext.request.contextPath}/maintenance/cooling/new" class="btn btn-outline-info shadow-sm me-2"><i class="bi bi-snow2"></i> Log Cooling Maint</a>
                <a href="${pageContext.request.contextPath}/maintenance/cost-analysis" class="btn btn-outline-success shadow-sm me-2"><i class="bi bi-graph-up"></i> Cost Analysis & Report</a>
                <button onclick="window.print()" class="btn btn-secondary shadow-sm"><i class="bi bi-printer"></i> Generate Report</button>
            </div>
        </div>

        <h6 class="mb-3 text-danger"><i class="bi bi-exclamation-circle-fill"></i> Overdue & Upcoming UPS Maintenance</h6>
        <div class="table-container mb-5">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>UPS ID</th><th>Type</th><th>Maintenance Date</th><th>Next Due Date</th><th>Technician</th><th>Vendor</th><th>Cost (RWF)</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${allUpsMaintenance}">
                    <tr class="table-warning">
                        <td><strong>${m.ups.assetTag}</strong></td>
                        <td>${m.maintenanceType}</td>
                        <td>${m.maintenanceDate}</td>
                        <td class="text-danger fw-bold">${m.nextDueDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.vendor}</td>
                        <td><fmt:formatNumber value="${m.maintenanceCost}" type="number" minFractionDigits="2"/></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allUpsMaintenance}">
                        <tr><td colspan="7" class="text-center text-muted">No UPS maintenance records found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <h6 class="mb-3 text-primary"><i class="bi bi-card-checklist"></i> Recent Cooling Maintenance</h6>
        <div class="table-container">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>Cooling ID</th><th>Type</th><th>Date</th><th>Filter Cleaned</th><th>Technician</th><th>Next Due</th><th>Cost (RWF)</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${allCoolingMaintenance}">
                    <tr>
                        <td><strong>${m.coolingUnit.assetTag}</strong></td>
                        <td>${m.maintenanceType}</td>
                        <td>${m.maintenanceDate}</td>
                        <td>${m.filterCleaningDate}</td>
                        <td>${m.technician}</td>
                        <td>${m.nextMaintenanceDate}</td>
                        <td><fmt:formatNumber value="$${m.maintenanceCost}" type="number" minFractionDigits="2"/></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty allCoolingMaintenance}">
                        <tr><td colspan="7" class="text-center text-muted">No cooling maintenance records found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>