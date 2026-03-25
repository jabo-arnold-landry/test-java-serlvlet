package com.spcms.controllers;

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

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.StringJoiner;

@Controller
@RequestMapping("/reports")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String dailyReport(Model model) {
        LocalDate today = LocalDate.now();
        model.addAttribute("report", reportService.getDailyReport(today).orElse(null));
        model.addAttribute("selectedDate", today);
        return "reports/daily";
    }

    @GetMapping("/generate")
    public String generateReport(@RequestParam(required = false) String date,
                                  @RequestParam(defaultValue = "false") boolean force,
                                  Model model) {
        LocalDate selectedDate;
        try {
            selectedDate = (date == null || date.trim().isEmpty()) ? LocalDate.now() : LocalDate.parse(date.trim());
        } catch (DateTimeParseException ex) {
            selectedDate = LocalDate.now();
        }

        model.addAttribute("report", reportService.generateDailyReport(selectedDate, force));
        model.addAttribute("selectedDate", selectedDate);
        model.addAttribute("reportStatus", force ? "Report re-generated successfully." : "Report generated successfully.");
        return "reports/daily";
    }

    @GetMapping("/export/csv")
    public ResponseEntity<String> exportDailyReportCsv(@RequestParam(required = false) String date) {
        LocalDate selectedDate;
        try {
            selectedDate = (date == null || date.trim().isEmpty()) ? LocalDate.now() : LocalDate.parse(date.trim());
        } catch (DateTimeParseException ex) {
            selectedDate = LocalDate.now();
        }

        var report = reportService.getDailyReport(selectedDate)
                .orElseGet(() -> reportService.generateDailyReport(selectedDate));

        StringJoiner csv = new StringJoiner("\n");
        csv.add("Metric,Value");
        csv.add("Report Date," + selectedDate);
        csv.add("MTTR (min)," + (report.getMttrMinutes() != null ? report.getMttrMinutes() : "0"));
        csv.add("MTBF (hrs)," + (report.getMtbfHours() != null ? report.getMtbfHours() : "0"));
        csv.add("Average Daily Load (%)," + (report.getAvgDailyLoad() != null ? report.getAvgDailyLoad() : "0"));
        csv.add("Max Temperature (C)," + (report.getHighestTempRecorded() != null ? report.getHighestTempRecorded() : "0"));
        csv.add("Total Incidents," + (report.getTotalIncidents() != null ? report.getTotalIncidents() : "0"));
        csv.add("Total Downtime (min)," + (report.getTotalDowntimeMin() != null ? report.getTotalDowntimeMin() : "0"));
        csv.add("Total Visitors," + (report.getTotalVisitors() != null ? report.getTotalVisitors() : "0"));
        csv.add("Overstayed Visitors," + (report.getOverstayedVisitors() != null ? report.getOverstayedVisitors() : "0"));

        String filename = "daily-report-" + selectedDate + ".csv";
        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_PLAIN)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .body(csv.toString());
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

    @GetMapping("/sla-compliance")
    public String slaCompliance(@RequestParam(defaultValue = "7") int windowDays, Model model) {
        int days = Math.max(1, Math.min(windowDays, 30));
        SlaComplianceSummary summary = reportService.buildSlaComplianceSummary(days);

        model.addAttribute("windowDays", days);
        model.addAttribute("summary", summary);
        return "reports/sla-compliance";
    }
}
