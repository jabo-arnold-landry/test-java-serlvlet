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
@RequestMapping("/reports/branch-performance")
public class BranchPerformanceReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String branchPerformanceReport(
            @RequestParam(value = "branch", required = false) String branch,
            Model model) {
        
        // Get all branches
        List<String> branches = reportService.getAllBranches();
        model.addAttribute("branches", branches);

        // If no branch selected, use first available or show selection
        if (branch == null || branch.isBlank()) {
            if (!branches.isEmpty()) {
                branch = branches.get(0);
            } else {
                model.addAttribute("message", "No branches available.");
                return "reports/branch-performance";
            }
        }

        // Get today's branch report
        reportService.generateBranchPerformanceReport(branch, LocalDate.now());
        model.addAttribute("report", 
                reportService.getBranchPerformanceReport(branch, LocalDate.now()).orElse(null));
        model.addAttribute("selectedBranch", branch);

        return "reports/branch-performance";
    }

    @GetMapping("/range")
    public String branchPerformanceRange(
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

        if (branch == null || branch.isBlank()) {
            if (!branches.isEmpty()) {
                branch = branches.get(0);
            } else {
                model.addAttribute("message", "No branches available.");
                return "reports/branch-performance-range";
            }
        }

        // Generate reports for all days in range if not exist
        LocalDate current = start;
        while (!current.isAfter(end)) {
            reportService.generateBranchPerformanceReport(branch, current);
            current = current.plusDays(1);
        }

        // Fetch reports in range
        model.addAttribute("reports", 
                reportService.getBranchPerformanceReportsInRange(branch, start, end));
        model.addAttribute("selectedBranch", branch);
        model.addAttribute("startDate", start);
        model.addAttribute("endDate", end);

        return "reports/branch-performance-range";
    }

    @GetMapping("/comparison")
    public String branchComparison(
            @RequestParam(value = "date", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        
        // Set default to today if not provided
        if (date == null) {
            date = LocalDate.now();
        }

        // Generate reports for all branches for this date
        List<String> branches = reportService.getAllBranches();
        for (String branch : branches) {
            reportService.generateBranchPerformanceReport(branch, date);
        }

        // Fetch all branch reports for this date
        model.addAttribute("reports", reportService.getBranchPerformanceReportsByDate(date));
        model.addAttribute("date", date);

        return "reports/branch-comparison";
    }
}
