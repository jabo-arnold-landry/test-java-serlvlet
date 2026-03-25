package com.spcms.controllers;

import com.spcms.dto.EquipmentHealthRow;
import com.spcms.dto.MaintenanceHistoryRow;
import com.spcms.services.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/reports")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String dailyReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        LocalDate reportDate = (date != null) ? date : LocalDate.now();
        model.addAttribute("selectedDate", reportDate);
        model.addAttribute("report", reportService.getDailyReport(reportDate).orElse(null));
        return "reports/daily";
    }

    @GetMapping("/generate")
    public String generateReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        LocalDate reportDate = (date != null) ? date : LocalDate.now();
        model.addAttribute("selectedDate", reportDate);
        try {
            model.addAttribute("report", reportService.generateDailyReport(reportDate));
            model.addAttribute("success", "Report generated successfully for " + reportDate);
        } catch (Exception e) {
            model.addAttribute("error", "Failed to generate report: " + e.getMessage());
            model.addAttribute("report", null);
        }
        model.addAttribute("selectedDate", date);
        return "reports/daily";
    }

    @GetMapping("/range")
    public String reportRange(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
            Model model) {
        LocalDate endDate = (end != null) ? end : LocalDate.now();
        LocalDate startDate = (start != null) ? start : endDate.minusDays(7);
        model.addAttribute("reports", reportService.getReportsInRange(startDate, endDate));
        return "reports/range";
    }

    @GetMapping("/downtime-trend")
    public String downtimeTrend(Model model) {
        LocalDate today = LocalDate.now();
        try {
            model.addAttribute("trend", reportService.getDowntimeTrend(
                    today.minusDays(14), today.minusDays(7),
                    today.minusDays(7), today));
            model.addAttribute("loadTrend", reportService.getLoadTrend(today.minusDays(30), today));
        } catch (Exception e) {
            model.addAttribute("error", "Failed to load trend data: " + e.getMessage());
        }
        return "reports/trends";
    }

    @GetMapping("/equipment-health")
    public String equipmentHealth(@RequestParam(required = false)
                                  @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOf,
                                  Model model) {
        LocalDate asOfDate = asOf != null ? asOf : LocalDate.now();
        List<EquipmentHealthRow> rows = reportService.getEquipmentHealthReport(asOfDate);

        long healthyCount = rows.stream().filter(r -> "Healthy".equals(r.getHealthStatus())).count();
        long needsAttentionCount = rows.stream().filter(r -> "Needs Attention".equals(r.getHealthStatus())).count();
        long criticalCount = rows.stream().filter(r -> "Critical".equals(r.getHealthStatus())).count();
        long atRiskCount = rows.stream().filter(r -> "At Risk".equals(r.getHealthStatus())).count();
        long decommissionedCount = rows.stream().filter(r -> "Decommissioned".equals(r.getHealthStatus())).count();

        model.addAttribute("equipmentHealth", rows);
        model.addAttribute("asOfDate", asOfDate);
        model.addAttribute("totalEquipment", rows.size());
        model.addAttribute("healthyCount", healthyCount);
        model.addAttribute("needsAttentionCount", needsAttentionCount);
        model.addAttribute("criticalCount", criticalCount);
        model.addAttribute("atRiskCount", atRiskCount);
        model.addAttribute("decommissionedCount", decommissionedCount);
        return "reports/equipment-health";
    }

    @GetMapping("/maintenance-history")
    public String maintenanceHistory(@RequestParam(required = false)
                                     @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
                                     @RequestParam(required = false)
                                     @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
                                     Model model) {
        LocalDate endDate = end != null ? end : LocalDate.now();
        LocalDate startDate = start != null ? start : endDate.minusDays(30);
        if (startDate.isAfter(endDate)) {
            LocalDate tmp = startDate;
            startDate = endDate;
            endDate = tmp;
        }

        List<MaintenanceHistoryRow> rows = reportService.getMaintenanceHistory(startDate, endDate);
        long upsCount = rows.stream().filter(r -> "UPS".equals(r.getAssetType())).count();
        long coolingCount = rows.stream().filter(r -> "Cooling".equals(r.getAssetType())).count();

        model.addAttribute("maintenanceHistory", rows);
        model.addAttribute("selectedStart", startDate);
        model.addAttribute("selectedEnd", endDate);
        model.addAttribute("totalMaintenance", rows.size());
        model.addAttribute("upsMaintenanceCount", upsCount);
        model.addAttribute("coolingMaintenanceCount", coolingCount);
        return "reports/maintenance-history";
    }
}
