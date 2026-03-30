package com.spcms.controllers;

import com.spcms.models.UpsReport;
import com.spcms.services.UpsReportService;
import com.spcms.util.UpsReportCsvGenerator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.time.LocalDate;

@Controller
@RequestMapping("/ups/reports")
public class UpsReportController {

    @Autowired
    private UpsReportService upsReportService;

    @Autowired
    private UpsReportCsvGenerator csvGenerator;

    /**
     * Display report generation form
     */
    @GetMapping
    public String reportForm(Model model) {
        model.addAttribute("locations", upsReportService.getAllLocations());
        model.addAttribute("statuses", upsReportService.getAllStatuses());
        model.addAttribute("period", "daily");  // Set default period
        model.addAttribute("reportDate", LocalDate.now().toString());  // Set default date as String (yyyy-MM-dd)
        model.addAttribute("filterStatus", "");  // Empty filter
        model.addAttribute("filterLocation", "");  // Empty filter
        return "ups/report";
    }

    /**
     * Generate and display report
     */
    @PostMapping("/generate")
    public String generateReport(
            @RequestParam(value = "period", required = false) String period,
            @RequestParam(value = "reportDate", required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate reportDate,
            @RequestParam(value = "filterStatus", required = false) String filterStatus,
            @RequestParam(value = "filterLocation", required = false) String filterLocation,
            Model model) {
        
        try {
            // Validate inputs
            if (period == null || period.isEmpty()) {
                period = "DAILY";
            }
            if (reportDate == null) {
                reportDate = LocalDate.now();
            }

            // Generate report
            UpsReport report = upsReportService.generateReport(
                    UpsReport.ReportPeriod.valueOf(period.toUpperCase()),
                    reportDate,
                    filterStatus != null && !filterStatus.isEmpty() ? filterStatus : null,
                    filterLocation != null && !filterLocation.isEmpty() ? filterLocation : null
            );

            // Populate model
            model.addAttribute("report", report);
            model.addAttribute("locations", upsReportService.getAllLocations());
            model.addAttribute("statuses", upsReportService.getAllStatuses());
            model.addAttribute("period", period.toLowerCase());
            model.addAttribute("reportDate", reportDate.toString());  // Convert LocalDate to String (yyyy-MM-dd)
            model.addAttribute("filterStatus", filterStatus != null ? filterStatus : "");
            model.addAttribute("filterLocation", filterLocation != null ? filterLocation : "");

            return "ups/report";
        } catch (Exception e) {
            // Log error and return to form with error message
            System.err.println("Error generating report: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "Error generating report: " + e.getMessage());
            model.addAttribute("locations", upsReportService.getAllLocations());
            model.addAttribute("statuses", upsReportService.getAllStatuses());
            return "ups/report";
        }
    }

    /**
     * Download report as CSV
     */
    @PostMapping("/download-csv")
    public ResponseEntity<byte[]> downloadCsv(
            @RequestParam("period") String period,
            @RequestParam("reportDate") @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate reportDate,
            @RequestParam(value = "filterStatus", required = false) String filterStatus,
            @RequestParam(value = "filterLocation", required = false) String filterLocation) throws IOException {

        UpsReport report = upsReportService.generateReport(
                UpsReport.ReportPeriod.valueOf(period.toUpperCase()),
                reportDate,
                filterStatus,
                filterLocation
        );

        byte[] csvBytes = csvGenerator.generateCsv(report);

        String fileName = String.format("UPS-Report-%s-%s.csv", period, reportDate);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.TEXT_PLAIN);
        headers.setContentDispositionFormData("attachment", fileName);
        headers.setContentLength(csvBytes.length);

        return ResponseEntity.ok()
                .headers(headers)
                .body(csvBytes);
    }

    /**
     * Quick report endpoints for predefined periods
     */

    @GetMapping("/daily")
    public String dailyReport(Model model) {
        try {
            System.out.println("========== DAILY REPORT REQUEST ==========");
            LocalDate today = LocalDate.now();
            System.out.println("Date: " + today);
            UpsReport report = upsReportService.generateReport(UpsReport.ReportPeriod.DAILY, today, null, null);
            System.out.println("Report generated successfully");
            model.addAttribute("report", report);
            model.addAttribute("period", "daily");
            model.addAttribute("reportDate", today.toString());  // Convert LocalDate to String (yyyy-MM-dd)
            model.addAttribute("locations", upsReportService.getAllLocations());
            model.addAttribute("statuses", upsReportService.getAllStatuses());
            System.out.println("========== DAILY REPORT SUCCESS ==========");
            return "ups/report";
        } catch (Exception e) {
            System.err.println("========== ERROR GENERATING DAILY REPORT ==========");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace(System.err);
            System.err.println("=============================================");
            model.addAttribute("error", "Error generating daily report: " + e.getMessage());
            try {
                model.addAttribute("locations", upsReportService.getAllLocations());
                model.addAttribute("statuses", upsReportService.getAllStatuses());
            } catch (Exception ex) {
                System.err.println("Error fetching filter options: " + ex.getMessage());
            }
            return "ups/report";
        }
    }

    @GetMapping("/weekly")
    public String weeklyReport(Model model) {
        try {
            System.out.println("========== WEEKLY REPORT REQUEST ==========");
            LocalDate today = LocalDate.now();
            System.out.println("Date: " + today);
            UpsReport report = upsReportService.generateReport(UpsReport.ReportPeriod.WEEKLY, today, null, null);
            System.out.println("Report generated successfully");
            model.addAttribute("report", report);
            model.addAttribute("period", "weekly");
            model.addAttribute("reportDate", today.toString());  // Convert LocalDate to String (yyyy-MM-dd)
            model.addAttribute("locations", upsReportService.getAllLocations());
            model.addAttribute("statuses", upsReportService.getAllStatuses());
            System.out.println("========== WEEKLY REPORT SUCCESS ==========");
            return "ups/report";
        } catch (Exception e) {
            System.err.println("========== ERROR GENERATING WEEKLY REPORT ==========");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace(System.err);
            System.err.println("=============================================");
            model.addAttribute("error", "Error generating weekly report: " + e.getMessage());
            try {
                model.addAttribute("locations", upsReportService.getAllLocations());
                model.addAttribute("statuses", upsReportService.getAllStatuses());
            } catch (Exception ex) {
                System.err.println("Error fetching filter options: " + ex.getMessage());
            }
            return "ups/report";
        }
    }

    @GetMapping("/monthly")
    public String monthlyReport(Model model) {
        try {
            System.out.println("========== MONTHLY REPORT REQUEST ==========");
            LocalDate today = LocalDate.now();
            System.out.println("Date: " + today);
            UpsReport report = upsReportService.generateReport(UpsReport.ReportPeriod.MONTHLY, today, null, null);
            System.out.println("Report generated successfully");
            model.addAttribute("report", report);
            model.addAttribute("period", "monthly");
            model.addAttribute("reportDate", today.toString());  // Convert LocalDate to String (yyyy-MM-dd)
            model.addAttribute("locations", upsReportService.getAllLocations());
            model.addAttribute("statuses", upsReportService.getAllStatuses());
            System.out.println("========== MONTHLY REPORT SUCCESS ==========");
            return "ups/report";
        } catch (Exception e) {
            System.err.println("========== ERROR GENERATING MONTHLY REPORT ==========");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace(System.err);
            System.err.println("=============================================");
            model.addAttribute("error", "Error generating monthly report: " + e.getMessage());
            try {
                model.addAttribute("locations", upsReportService.getAllLocations());
                model.addAttribute("statuses", upsReportService.getAllStatuses());
            } catch (Exception ex) {
                System.err.println("Error fetching filter options: " + ex.getMessage());
            }
            return "ups/report";
        }
    }
}
