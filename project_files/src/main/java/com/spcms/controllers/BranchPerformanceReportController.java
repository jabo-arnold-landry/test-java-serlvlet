package com.spcms.controllers;

import com.spcms.services.ReportService;
import com.spcms.models.BranchPerformanceReport;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletResponse;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.io.IOException;
import com.lowagie.text.Document;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Table;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.pdf.PdfWriter;

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

    // PDF Export Methods
    @GetMapping("/export-pdf")
    public void exportBranchPerformancePdf(
            @RequestParam(value = "branch") String branch,
            HttpServletResponse response) throws IOException {
        
        Optional<BranchPerformanceReport> report = reportService.getBranchPerformanceReport(branch, LocalDate.now());
        
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=branch-performance-" + branch + "-" + LocalDate.now() + ".pdf");

        try {
            Document document = new Document(PageSize.A4);
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Title
            Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD);
            document.add(new Paragraph("Branch Performance Report", titleFont));
            document.add(new Paragraph("Branch: " + branch + " | Date: " + LocalDate.now(), new Font(Font.HELVETICA, 10)));
            document.add(new Paragraph(" "));

            if (report.isPresent()) {
                BranchPerformanceReport r = report.get();

                // Key Metrics Table
                Table metricsTable = new Table(2);
                metricsTable.setWidth(100);
                metricsTable.addCell("Metric");
                metricsTable.addCell("Value");
                metricsTable.addCell("Average Daily Load");
                metricsTable.addCell(r.getAvgDailyLoad() + "%");
                metricsTable.addCell("Peak Load");
                metricsTable.addCell(r.getPeakLoad() + "%");
                metricsTable.addCell("Average Temperature");
                metricsTable.addCell(r.getAvgRoomTemperature() + "°C");
                metricsTable.addCell("Highest Temperature");
                metricsTable.addCell(r.getHighestTempRecorded() + "°C");
                metricsTable.addCell("Total Incidents");
                metricsTable.addCell(String.valueOf(r.getTotalIncidents()));
                metricsTable.addCell("Critical Incidents");
                metricsTable.addCell(String.valueOf(r.getCriticalIncidents()));
                metricsTable.addCell("Total Downtime (minutes)");
                metricsTable.addCell(String.valueOf(r.getTotalDowntimeMin()));
                metricsTable.addCell("MTTR (Mean Time To Repair)");
                metricsTable.addCell(r.getMttrMinutes() + " minutes");
                metricsTable.addCell("MTBF (Mean Time Between Failures)");
                metricsTable.addCell(r.getMtbfHours() + " hours");
                metricsTable.addCell("UPS Alarms");
                metricsTable.addCell(String.valueOf(r.getTotalUpsAlarms()));
                metricsTable.addCell("Active Users");
                metricsTable.addCell(String.valueOf(r.getUserCount()));
                metricsTable.addCell("Total Visitors");
                metricsTable.addCell(String.valueOf(r.getTotalVisitors()));

                document.add(metricsTable);
            } else {
                document.add(new Paragraph("No report data available for this branch."));
            }

            document.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @GetMapping("/export-range-pdf")
    public void exportBranchPerformanceRangePdf(
            @RequestParam(value = "branch") String branch,
            @RequestParam(value = "start") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam(value = "end") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
            HttpServletResponse response) throws IOException {
        
        List<BranchPerformanceReport> reports = reportService.getBranchPerformanceReportsInRange(branch, start, end);
        
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=branch-performance-range-" + branch + "-" + start + "-to-" + end + ".pdf");

        try {
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Title
            Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD);
            document.add(new Paragraph("Branch Performance Range Report", titleFont));
            document.add(new Paragraph("Branch: " + branch + " | Period: " + start + " to " + end, new Font(Font.HELVETICA, 10)));
            document.add(new Paragraph(" "));

            // Data Table
            Table dataTable = new Table(10);
            dataTable.setWidth(100);
            
            // Headers
            String[] headers = {"Date", "Avg Load %", "Peak Load %", "Avg Temp °C", "Max Temp °C", "Incidents", "Critical", "Downtime (min)", "MTTR (min)", "MTBF (hrs)"};
            for (String header : headers) {
                dataTable.addCell(header);
            }

            // Rows
            for (BranchPerformanceReport r : reports) {
                dataTable.addCell(r.getReportDate().toString());
                dataTable.addCell(r.getAvgDailyLoad() != null ? r.getAvgDailyLoad().toString() : "N/A");
                dataTable.addCell(r.getPeakLoad() != null ? r.getPeakLoad().toString() : "N/A");
                dataTable.addCell(r.getAvgRoomTemperature() != null ? r.getAvgRoomTemperature().toString() : "N/A");
                dataTable.addCell(r.getHighestTempRecorded() != null ? r.getHighestTempRecorded().toString() : "N/A");
                dataTable.addCell(String.valueOf(r.getTotalIncidents()));
                dataTable.addCell(String.valueOf(r.getCriticalIncidents()));
                dataTable.addCell(String.valueOf(r.getTotalDowntimeMin()));
                dataTable.addCell(r.getMttrMinutes() != null ? r.getMttrMinutes().toString() : "N/A");
                dataTable.addCell(r.getMtbfHours() != null ? r.getMtbfHours().toString() : "N/A");
            }

            document.add(dataTable);
            document.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @GetMapping("/export-comparison-pdf")
    public void exportBranchComparisonPdf(
            @RequestParam(value = "date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            HttpServletResponse response) throws IOException {
        
        List<BranchPerformanceReport> reports = reportService.getBranchPerformanceReportsByDate(date);
        
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=branch-comparison-" + date + ".pdf");

        try {
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Title
            Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD);
            document.add(new Paragraph("Branch Comparison Report", titleFont));
            document.add(new Paragraph("Date: " + date, new Font(Font.HELVETICA, 10)));
            document.add(new Paragraph(" "));

            // Data Table
            Table comparisonTable = new Table(11);
            comparisonTable.setWidth(100);
            
            // Headers
            String[] headers = {"Branch", "Avg Load %", "Peak Load %", "Avg Temp °C", "Max Temp °C", "Incidents", "Critical", "Downtime (min)", "MTTR (min)", "MTBF (hrs)", "Users"};
            for (String header : headers) {
                comparisonTable.addCell(header);
            }

            // Rows
            for (BranchPerformanceReport r : reports) {
                comparisonTable.addCell(r.getBranch());
                comparisonTable.addCell(r.getAvgDailyLoad() != null ? r.getAvgDailyLoad().toString() : "N/A");
                comparisonTable.addCell(r.getPeakLoad() != null ? r.getPeakLoad().toString() : "N/A");
                comparisonTable.addCell(r.getAvgRoomTemperature() != null ? r.getAvgRoomTemperature().toString() : "N/A");
                comparisonTable.addCell(r.getHighestTempRecorded() != null ? r.getHighestTempRecorded().toString() : "N/A");
                comparisonTable.addCell(String.valueOf(r.getTotalIncidents()));
                comparisonTable.addCell(String.valueOf(r.getCriticalIncidents()));
                comparisonTable.addCell(String.valueOf(r.getTotalDowntimeMin()));
                comparisonTable.addCell(r.getMttrMinutes() != null ? r.getMttrMinutes().toString() : "N/A");
                comparisonTable.addCell(r.getMtbfHours() != null ? r.getMtbfHours().toString() : "N/A");
                comparisonTable.addCell(String.valueOf(r.getUserCount()));
            }

            document.add(comparisonTable);
            document.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
