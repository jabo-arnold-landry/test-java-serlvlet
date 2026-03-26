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

    @GetMapping("/monthly")
    public String monthlyReport(@RequestParam(required = false) Integer year,
                                @RequestParam(required = false) Integer month,
                                Model model) {
        LocalDate now = LocalDate.now();
        int targetYear = year != null ? year : now.getYear();
        int targetMonth = month != null ? month : now.getMonthValue();
        model.addAttribute("report", reportService.generateMonthlyReport(targetYear, targetMonth));
        model.addAttribute("selectedYear", targetYear);
        model.addAttribute("selectedMonth", targetMonth);
        return "reports/monthly";
    }

    @GetMapping("/quarterly")
    public String quarterlyReport(@RequestParam(required = false) Integer year,
                                  @RequestParam(required = false) Integer quarter,
                                  Model model) {
        LocalDate now = LocalDate.now();
        int targetYear = year != null ? year : now.getYear();
        int targetQuarter = quarter != null ? quarter : (now.getMonthValue() - 1) / 3 + 1;
        model.addAttribute("report", reportService.generateQuarterlyReport(targetYear, targetQuarter));
        model.addAttribute("selectedYear", targetYear);
        model.addAttribute("selectedQuarter", targetQuarter);
        return "reports/quarterly";
    }
}
