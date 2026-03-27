package com.spcms.controllers;

import com.spcms.services.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/reports/cost-analysis")
public class CostAnalysisController {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String costAnalysisReport(
            @RequestParam(value = "branch", required = false) String branch,
            Model model) {

        // Get all branches
        List<String> branches = reportService.getAllBranches();
        model.addAttribute("branches", branches);

        LocalDate today = LocalDate.now();
        model.addAttribute("date", today);

        // Generate today's cost analysis report
        reportService.generateCostAnalysisReport(today, branch);
        model.addAttribute("report", 
                reportService.getCostAnalysisReport(branch, today).orElse(null));
        model.addAttribute("selectedBranch", branch);

        return "reports/cost-analysis";
    }

    @GetMapping("/range")
    public String costAnalysisRange(
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "start", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam(value = "end", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
            Model model) {
        
        // Set defaults if not provided
        if (end == null) {
            end = LocalDate.now();
        }
        if (start == null) {
            start = end.minusDays(6);
        }

        List<String> branches = reportService.getAllBranches();
        model.addAttribute("branches", branches);

        // Generate reports for all days in range
        LocalDate current = start;
        while (!current.isAfter(end)) {
            reportService.generateCostAnalysisReport(current, branch);
            current = current.plusDays(1);
        }

        // Fetch reports in range
        if (branch != null && !branch.isBlank()) {
            model.addAttribute("reports", reportService.getCostAnalysisReportsInRange(branch, start, end));
        } else {
            model.addAttribute("reports", reportService.getCostAnalysisReportsInRange(start, end));
        }
        model.addAttribute("selectedBranch", branch);
        model.addAttribute("startDate", start);
        model.addAttribute("endDate", end);

        return "reports/cost-analysis-range";
    }

    @GetMapping("/downtime-cost")
    public String downtimeCostAnalysis(
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "start", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam(value = "end", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
            Model model) {
        
        // Set defaults if not provided
        if (end == null) {
            end = LocalDate.now();
        }
        if (start == null) {
            start = end.minusDays(6);
        }

        List<String> branches = reportService.getAllBranches();
        model.addAttribute("branches", branches);

        // Generate reports for all days in range
        LocalDate current = start;
        while (!current.isAfter(end)) {
            reportService.generateCostAnalysisReport(current, branch);
            current = current.plusDays(1);
        }

        // Fetch reports and calculate downtime cost trends
        if (branch != null && !branch.isBlank()) {
            model.addAttribute("reports", reportService.getCostAnalysisReportsInRange(branch, start, end));
        } else {
            model.addAttribute("reports", reportService.getCostAnalysisReportsInRange(start, end));
        }
        model.addAttribute("selectedBranch", branch);
        model.addAttribute("startDate", start);
        model.addAttribute("endDate", end);

        return "reports/downtime-cost-analysis";
    }

    @GetMapping("/maintenance-breakdown")
    public String maintenanceBreakdown(
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "date", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        
        // Set default to today if not provided
        if (date == null) {
            date = LocalDate.now();
        }

        List<String> branches = reportService.getAllBranches();
        model.addAttribute("branches", branches);

        // Generate cost analysis report for the date
        reportService.generateCostAnalysisReport(date, branch);
        model.addAttribute("report", 
                reportService.getCostAnalysisReport(branch, date).orElse(null));
        model.addAttribute("selectedBranch", branch);
        model.addAttribute("date", date);

        return "reports/maintenance-cost-breakdown";
    }
}
