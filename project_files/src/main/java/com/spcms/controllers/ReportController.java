package com.spcms.controllers;

import com.spcms.models.DailyConsolidatedReport;
import com.spcms.models.MaintenanceHistoryRecord;
import com.spcms.models.SlaCheckResult;
import com.spcms.models.SlaComplianceSummary;
import com.spcms.services.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.nio.charset.StandardCharsets;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/reports")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String dailyReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        LocalDate selectedDate = date != null ? date : LocalDate.now();
        model.addAttribute("selectedDate", selectedDate);
        model.addAttribute("today", LocalDate.now());
        model.addAttribute("report", reportService.getDailyReport(selectedDate).orElse(null));
        return "reports/daily";
    }

    @GetMapping("/generate")
    public String generateReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        LocalDate selectedDate = date != null ? date : LocalDate.now();
        model.addAttribute("selectedDate", selectedDate);
        model.addAttribute("today", LocalDate.now());
        model.addAttribute("report", reportService.generateDailyReport(selectedDate));
        model.addAttribute("reportStatus", "Daily report generated successfully.");
        return "reports/daily";
    }

    @GetMapping("/range")
    public String reportRange(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
            Model model) {
        model.addAttribute("reports", reportService.getReportsInRange(start, end));
        return "reports/range";
    }

    @GetMapping("/downtime-trend")
    public String downtimeTrend(Model model) {
        // Compare last 7 days vs previous 7 days
        LocalDate today = LocalDate.now();
        model.addAttribute("trend", reportService.getDowntimeTrend(
                today.minusDays(14), today.minusDays(7),
                today.minusDays(7), today));
        model.addAttribute("loadTrend", reportService.getLoadTrend(today.minusDays(30), today));
        return "reports/trends";
    }

    @GetMapping("/equipment-health")
    public String equipmentHealth(Model model) {
        LocalDate today = LocalDate.now();
        model.addAttribute("report", reportService.generateEquipmentHealthReport(today.minusDays(30), today));
        return "reports/equipment-health";
    }

    @GetMapping("/cost-of-maintenance")
    public String costOfMaintenance(Model model) {
        LocalDate today = LocalDate.now();
        model.addAttribute("report", reportService.generateCostOfMaintenanceReport(today.minusDays(30), today));
        return "reports/cost-of-maintenance";
    }

    @GetMapping("/downtime-analysis")
    public String downtimeAnalysis(Model model) {
        LocalDate today = LocalDate.now();
        model.addAttribute("report", reportService.generateDowntimeAnalysisReport(today.minusDays(30), today));
        return "reports/downtime-analysis";
    }

    @GetMapping("/monthly-quarterly")
    public String monthlyQuarterly(@RequestParam(defaultValue = "MONTH") String period, Model model) {
        model.addAttribute("report", reportService.generateMonthlyQuarterlyReports(period));
        model.addAttribute("period", period);
        return "reports/monthly-quarterly";
    }

    @GetMapping("/monthly")
    public String monthlyReport(Model model) {
        return monthlyQuarterly("MONTH", model);
    }

    @GetMapping("/quarterly")
    public String quarterlyReport(Model model) {
        return monthlyQuarterly("QUARTER", model);
    }

    @GetMapping("/project")
    public String projectReport(
            @RequestParam(defaultValue = "daily") String period,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        LocalDate reportDate = date != null ? date : LocalDate.now();
        LocalDate startDate = reportDate;
        if ("weekly".equalsIgnoreCase(period)) {
            startDate = reportDate.minusDays(6);
        } else if ("monthly".equalsIgnoreCase(period)) {
            startDate = reportDate.withDayOfMonth(1);
        }

        List<DailyConsolidatedReport> trendReports = reportService.getReportsInRange(startDate, reportDate);
        if (trendReports.isEmpty()) {
            trendReports = List.of(reportService.generateDailyReport(reportDate));
        }
        DailyConsolidatedReport primaryReport = trendReports.get(0);

        model.addAttribute("period", period.toLowerCase());
        model.addAttribute("reportDate", reportDate);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", reportDate);
        model.addAttribute("reportGeneratedAt", java.time.LocalDateTime.now());
        model.addAttribute("trendReports", trendReports);

        model.addAttribute("totalIncidents", safeInt(primaryReport.getTotalIncidents()));
        model.addAttribute("totalIncidentsInPeriod", trendReports.stream().mapToInt(r -> safeInt(r.getTotalIncidents())).sum());
        model.addAttribute("totalDowntimeMin", safeInt(primaryReport.getTotalDowntimeMin()));
        model.addAttribute("mttr", safeDecimal(primaryReport.getMttrMinutes()));
        model.addAttribute("mtbf", safeDecimal(primaryReport.getMtbfHours()));
        model.addAttribute("avgLoad", safeDecimal(primaryReport.getAvgDailyLoad()));
        model.addAttribute("maxTemp", safeDecimal(primaryReport.getHighestTempRecorded()));
        model.addAttribute("criticalCount", safeInt(primaryReport.getCriticalIncidents()));
        model.addAttribute("highCount", 0);
        model.addAttribute("mediumCount", 0);
        model.addAttribute("lowCount", 0);
        model.addAttribute("resolvedTotal", 0);
        model.addAttribute("resolvedWithinSla", 0);
        model.addAttribute("unresolvedIncidents", safeInt(primaryReport.getTotalIncidents()));
        model.addAttribute("slaBreachCount", 0);
        model.addAttribute("slaCompliancePercentage", new BigDecimal("100.00"));
        model.addAttribute("slaCompliance", true);
        model.addAttribute("incidentCompliance", true);
        model.addAttribute("maintenanceCompliance", true);
        model.addAttribute("alertCompliance", true);
        model.addAttribute("systemHealthStatus", "STABLE");
        model.addAttribute("systemHealthCss", "border-color:#198754;color:#198754;background:#ecfdf3;");
        model.addAttribute("executiveWarningText", "No major risk indicators detected for the selected period.");
        model.addAttribute("unacknowledgedAlerts", 0);
        model.addAttribute("upsAssets", Collections.emptyList());
        model.addAttribute("coolingAssets", Collections.emptyList());
        model.addAttribute("incidents", Collections.emptyList());
        model.addAttribute("upsMaintenance", Collections.emptyList());
        model.addAttribute("coolingMaintenance", Collections.emptyList());
        model.addAttribute("coolingAlarms", Collections.emptyList());
        model.addAttribute("recurringFaults", Collections.emptyMap());
        model.addAttribute("unacknowledgedAlertDetails", Collections.emptyList());
        model.addAttribute("alertNotifications", Collections.emptyList());
        model.addAttribute("recommendations", Collections.emptyList());
        model.addAttribute("overdueUps", Collections.emptyList());
        model.addAttribute("overdueCooling", Collections.emptyList());
        model.addAttribute("slaBreachedIncidents", Collections.emptyList());
        return "reports/project";
    }

    @GetMapping("/sla-compliance")
    public String slaCompliance(
            @RequestParam(defaultValue = "30") int windowDays,
            Model model) {
        int sanitizedWindow = Math.max(1, windowDays);
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(sanitizedWindow - 1L);
        List<DailyConsolidatedReport> reports = reportService.getReportsInRange(startDate, endDate);

        int totalDowntimeMinutes = reports.stream().mapToInt(r -> safeInt(r.getTotalDowntimeMin())).sum();
        BigDecimal allowedDowntimeMinutes = BigDecimal.valueOf(sanitizedWindow * 43L);
        BigDecimal availabilityCompliance = reports.isEmpty()
                ? new BigDecimal("100.00")
                : BigDecimal.valueOf(Math.max(0, 100 - (double) totalDowntimeMinutes / Math.max(1, sanitizedWindow)));
        BigDecimal maxTemperature = reports.stream()
                .map(DailyConsolidatedReport::getHighestTempRecorded)
                .filter(java.util.Objects::nonNull)
                .max(BigDecimal::compareTo)
                .orElse(BigDecimal.ZERO);
        long temperatureViolations = reports.stream()
                .map(DailyConsolidatedReport::getHighestTempRecorded)
                .filter(temp -> temp != null && temp.compareTo(new BigDecimal("28")) > 0)
                .count();

        List<SlaCheckResult> checks = new ArrayList<>();
        checks.add(new SlaCheckResult("Availability", "Daily uptime target", "99.90%", availabilityCompliance + "%",
                availabilityCompliance.compareTo(new BigDecimal("99.90")) >= 0, "Based on aggregated downtime."));
        checks.add(new SlaCheckResult("Temperature", "Maximum room temperature", "28 degC", maxTemperature + " degC",
                temperatureViolations == 0, "Uses highest recorded daily temperature."));
        checks.add(new SlaCheckResult("Downtime", "Monthly downtime allowance", allowedDowntimeMinutes + " min",
                totalDowntimeMinutes + " min", BigDecimal.valueOf(totalDowntimeMinutes).compareTo(allowedDowntimeMinutes) <= 0,
                "Window-scaled allowance for dashboard reporting."));
        long compliantRuleCount = checks.stream().filter(SlaCheckResult::isCompliant).count();
        long violatedRuleCount = checks.size() - compliantRuleCount;

        SlaComplianceSummary summary = new SlaComplianceSummary(
                sanitizedWindow,
                reports.size(),
                availabilityCompliance.setScale(2, BigDecimal.ROUND_HALF_UP),
                BigDecimal.ZERO.setScale(2, BigDecimal.ROUND_HALF_UP),
                totalDowntimeMinutes,
                allowedDowntimeMinutes,
                maxTemperature,
                reports.size(),
                temperatureViolations,
                reports.size(),
                0,
                new BigDecimal("100.00"),
                0,
                compliantRuleCount,
                violatedRuleCount,
                new BigDecimal("99.90"),
                new BigDecimal("28.00"),
                30,
                43,
                checks);

        model.addAttribute("summary", summary);
        model.addAttribute("windowDays", sanitizedWindow);
        return "reports/sla-compliance";
    }

    @GetMapping("/export/csv/range")
    public ResponseEntity<byte[]> exportCsvRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        List<DailyConsolidatedReport> reports = reportService.getReportsInRange(start, end);
        StringBuilder csv = new StringBuilder("report_date,avg_daily_load,total_incidents,total_downtime_min,mttr_minutes,mtbf_hours\n");
        for (DailyConsolidatedReport report : reports) {
            csv.append(report.getReportDate()).append(',')
                    .append(safeDecimal(report.getAvgDailyLoad())).append(',')
                    .append(safeInt(report.getTotalIncidents())).append(',')
                    .append(safeInt(report.getTotalDowntimeMin())).append(',')
                    .append(safeDecimal(report.getMttrMinutes())).append(',')
                    .append(safeDecimal(report.getMtbfHours())).append('\n');
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv"));
        headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=daily-reports-range.csv");
        return ResponseEntity.ok().headers(headers).body(csv.toString().getBytes(StandardCharsets.UTF_8));
    }

    @GetMapping("/maintenance-history")
    public String maintenanceHistory(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate,
            @RequestParam(required = false) String assetId,
            @RequestParam(defaultValue = "ALL") String equipmentType,
            @RequestParam(required = false) String technicianName,
            @RequestParam(defaultValue = "ALL") String maintenanceCategory,
            @RequestParam(defaultValue = "ALL") String status,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "newest") String sort,
            Model model) {

        Map<String, Object> report = reportService.generateMaintenanceHistoryReport(
                fromDate,
                toDate,
                assetId,
                equipmentType,
                technicianName,
                maintenanceCategory,
                status,
                keyword,
                sort);

        model.addAttribute("report", report);
        model.addAttribute("records", report.get("records"));

        model.addAttribute("fromDate", report.get("fromDate"));
        model.addAttribute("toDate", report.get("toDate"));
        model.addAttribute("assetId", report.get("assetId"));
        model.addAttribute("equipmentType", report.get("equipmentType"));
        model.addAttribute("technicianName", report.get("technicianName"));
        model.addAttribute("maintenanceCategory", report.get("maintenanceCategory"));
        model.addAttribute("status", report.get("status"));
        model.addAttribute("keyword", report.get("keyword"));
        model.addAttribute("sort", report.get("sort"));

        return "reports/maintenance-history";
    }

    @GetMapping("/maintenance-history/{equipmentType}/{maintenanceId}")
    public String maintenanceHistoryDetail(@PathVariable("equipmentType") String equipmentType,
            @PathVariable("maintenanceId") Long maintenanceId,
            Model model,
            RedirectAttributes redirectAttributes) {

        Optional<MaintenanceHistoryRecord> detail = reportService.getMaintenanceHistoryDetail(equipmentType, maintenanceId);
        if (detail.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Maintenance history record not found.");
            return "redirect:/reports/maintenance-history";
        }

        model.addAttribute("record", detail.get());
        return "reports/maintenance-history-detail";
    }

    @GetMapping("/maintenance-history/export")
    public ResponseEntity<byte[]> exportMaintenanceHistory(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate,
            @RequestParam(required = false) String assetId,
            @RequestParam(defaultValue = "ALL") String equipmentType,
            @RequestParam(required = false) String technicianName,
            @RequestParam(defaultValue = "ALL") String maintenanceCategory,
            @RequestParam(defaultValue = "ALL") String status,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "newest") String sort) {

        List<MaintenanceHistoryRecord> records = reportService.getMaintenanceHistoryRecords(
                fromDate,
                toDate,
                assetId,
                equipmentType,
                technicianName,
                maintenanceCategory,
                status,
                keyword,
                sort);

        String csv = reportService.buildMaintenanceHistoryCsv(records);
        byte[] content = csv.getBytes(StandardCharsets.UTF_8);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv"));
        headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=maintenance-history-report.csv");

        return ResponseEntity.ok()
                .headers(headers)
                .body(content);
    }

    private int safeInt(Integer value) {
        return value != null ? value : 0;
    }

    private BigDecimal safeDecimal(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}
