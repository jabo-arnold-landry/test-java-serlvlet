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
