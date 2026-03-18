package com.spcms.controllers;

import com.spcms.models.DailyConsolidatedReport;
import com.spcms.services.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/reports")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String dailyReport(Model model) {
        LocalDate today = LocalDate.now();
        model.addAttribute("selectedDate", today);
        model.addAttribute("report", reportService.getDailyReport(today).orElse(null));
        return "reports/daily";
    }

    @GetMapping("/generate")
    public String generateReport(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                                  Model model) {
        model.addAttribute("selectedDate", date);
        model.addAttribute("report", reportService.generateDailyReport(date));
        return "reports/daily";
    }

    @GetMapping("/range")
    public String reportRange(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
                               @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
                               Model model) {
        model.addAttribute("selectedStart", start);
        model.addAttribute("selectedEnd", end);
        model.addAttribute("reports", reportService.getReportsInRange(start, end));
        return "reports/range";
    }

        @GetMapping("/export/csv")
        public ResponseEntity<String> exportDailyCsv(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        DailyConsolidatedReport report = reportService.getDailyReport(date)
            .orElseGet(() -> reportService.generateDailyReport(date));

        StringBuilder csv = new StringBuilder();
        csv.append("report_date,avg_daily_load,total_ups_alarms,avg_room_temperature,highest_temp_recorded,")
            .append("total_incidents,total_downtime_min,mttr_minutes,mtbf_hours,total_visitors,generated_at\n");
        csv.append(csvCell(report.getReportDate())).append(',')
            .append(csvCell(report.getAvgDailyLoad())).append(',')
            .append(csvCell(report.getTotalUpsAlarms())).append(',')
            .append(csvCell(report.getAvgRoomTemperature())).append(',')
            .append(csvCell(report.getHighestTempRecorded())).append(',')
            .append(csvCell(report.getTotalIncidents())).append(',')
            .append(csvCell(report.getTotalDowntimeMin())).append(',')
            .append(csvCell(report.getMttrMinutes())).append(',')
            .append(csvCell(report.getMtbfHours())).append(',')
            .append(csvCell(report.getTotalVisitors())).append(',')
            .append(csvCell(report.getGeneratedAt())).append('\n');

        String filename = "daily-consolidated-report-" + date + ".csv";
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
            .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
            .body(csv.toString());
        }

        @GetMapping("/export/csv/range")
        public ResponseEntity<String> exportRangeCsv(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        List<DailyConsolidatedReport> reports = reportService.getReportsInRange(start, end);

        StringBuilder csv = new StringBuilder();
        csv.append("report_date,avg_daily_load,total_ups_alarms,avg_room_temperature,highest_temp_recorded,")
            .append("total_incidents,total_downtime_min,mttr_minutes,mtbf_hours,total_visitors,generated_at\n");

        for (DailyConsolidatedReport report : reports) {
            csv.append(csvCell(report.getReportDate())).append(',')
                .append(csvCell(report.getAvgDailyLoad())).append(',')
                .append(csvCell(report.getTotalUpsAlarms())).append(',')
                .append(csvCell(report.getAvgRoomTemperature())).append(',')
                .append(csvCell(report.getHighestTempRecorded())).append(',')
                .append(csvCell(report.getTotalIncidents())).append(',')
                .append(csvCell(report.getTotalDowntimeMin())).append(',')
                .append(csvCell(report.getMttrMinutes())).append(',')
                .append(csvCell(report.getMtbfHours())).append(',')
                .append(csvCell(report.getTotalVisitors())).append(',')
                .append(csvCell(report.getGeneratedAt())).append('\n');
        }

        String filename = "daily-consolidated-reports-" + start + "-to-" + end + ".csv";
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
            .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
            .body(csv.toString());
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

    private String csvCell(Object value) {
        if (value == null) {
            return "";
        }
        String text = String.valueOf(value);
        String escaped = text.replace("\"", "\"\"");
        return "\"" + escaped + "\"";
    }
}
