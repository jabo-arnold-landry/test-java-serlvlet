package com.spcms.controllers;

import com.spcms.services.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

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
}
