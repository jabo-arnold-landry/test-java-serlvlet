package com.spcms.controllers;

import com.spcms.models.MaintenanceHistoryRecord;
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
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/reports")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String dailyReport(Model model) {
        model.addAttribute("report", reportService.getDailyReport(LocalDate.now()).orElse(null));
        return "reports/daily";
    }

    @GetMapping("/generate")
    public String generateReport(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        model.addAttribute("report", reportService.generateDailyReport(date));
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
    public String maintenanceHistoryDetail(@PathVariable String equipmentType,
            @PathVariable Long maintenanceId,
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
}
