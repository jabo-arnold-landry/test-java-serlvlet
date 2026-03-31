package com.spcms.controllers;

import com.spcms.models.ShiftReport;
import com.spcms.models.ShiftHandoverNote;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import com.spcms.services.ShiftReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Controller
@RequestMapping("/shift-reports")
public class ShiftReportController {

    @Autowired
    private ShiftReportService shiftReportService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.spcms.repositories.MonitoringLogRepository monitoringLogRepository;

    @Autowired
    private com.spcms.repositories.IncidentRepository incidentRepository;

    @Autowired
    private com.spcms.repositories.CoolingUnitRepository coolingUnitRepository;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("reports", shiftReportService.getAllShiftReports());
        return "shift-reports/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model, Authentication authentication) {
        ShiftReport report = new ShiftReport();
        report.setShiftDate(LocalDate.now());
        report.setLoginTime(LocalDateTime.now());

        User currentUser = getCurrentUser(authentication);
        if (currentUser != null) {
            report.setStaff(currentUser);
            model.addAttribute("currentUser", currentUser);
        }

        model.addAttribute("shiftReport", report);
        return "shift-reports/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute ShiftReport report, 
                       @RequestParam(value="handoverSystemStatus", required=false) String handoverSystemStatus,
                       @RequestParam(value="handoverPendingIssues", required=false) String handoverPendingIssues,
                       @RequestParam(value="handoverRecommendations", required=false) String handoverRecommendations,
                       Authentication authentication, RedirectAttributes redirectAttributes) {
        User currentUser = getCurrentUser(authentication);
        if (currentUser == null) {
            redirectAttributes.addFlashAttribute("error", "Unable to resolve the logged-in user.");
            return "redirect:/login";
        }

        report.setStaff(currentUser);
        if (report.getShiftDate() == null) {
            report.setShiftDate(LocalDate.now());
        }
        if (report.getLoginTime() == null) {
            report.setLoginTime(LocalDateTime.now());
        }

        ShiftReport savedReport = shiftReportService.createShiftReport(report);
        
        if (handoverSystemStatus != null && !handoverSystemStatus.trim().isEmpty()) {
            ShiftHandoverNote note = new ShiftHandoverNote();
            note.setShiftReport(savedReport);
            note.setSystemStatusSummary(handoverSystemStatus);
            note.setPendingIssues(handoverPendingIssues);
            note.setRecommendations(handoverRecommendations);
            shiftReportService.addHandoverNote(note);
        }
        
        redirectAttributes.addFlashAttribute("success", "Shift report saved");
        return "redirect:/shift-reports";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("report", shiftReportService.getShiftReportById(id)
                .orElseThrow(() -> new RuntimeException("Shift report not found")));
        model.addAttribute("handoverNotes", shiftReportService.getHandoverNotes(id));
        return "shift-reports/view";
    }

    @PostMapping("/handover/{reportId}")
    public String addHandoverNote(@PathVariable Long reportId,
            @ModelAttribute ShiftHandoverNote note,
            RedirectAttributes redirectAttributes) {
        ShiftReport report = shiftReportService.getShiftReportById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found"));
        note.setShiftReport(report);
        shiftReportService.addHandoverNote(note);
        redirectAttributes.addFlashAttribute("success", "Handover note added");
        return "redirect:/shift-reports/view/" + reportId;
    }

    @PostMapping("/close/{id}")
    public String closeShift(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        shiftReportService.closeShift(id);
        redirectAttributes.addFlashAttribute("success", "Shift closed successfully");
        return "redirect:/shift-reports";
    }

    private User getCurrentUser(Authentication authentication) {
        if (authentication != null && authentication.isAuthenticated()) {
            String username = authentication.getName();
            return userRepository.findByUsername(username)
                    .orElse(null);
        }
        return null;
    }

    @GetMapping("/api/daily-summary")
    @ResponseBody
    public org.springframework.http.ResponseEntity<com.spcms.dto.reports.DailySummaryDto> getDailySummary(
            @RequestParam("date") @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate date) {
        
        com.spcms.dto.reports.DailySummaryDto dto = new com.spcms.dto.reports.DailySummaryDto();
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(23, 59, 59);

        // 1. Cooling Metrics
        java.util.List<com.spcms.models.MonitoringLog> logs = monitoringLogRepository.findByTypeAndDateRange(com.spcms.models.MonitoringLog.EquipmentType.COOLING, start, end);
        
        java.math.BigDecimal maxTemp = java.math.BigDecimal.ZERO;
        java.math.BigDecimal minTemp = java.math.BigDecimal.ZERO;
        java.math.BigDecimal avgHumidity = java.math.BigDecimal.ZERO;

        if (logs != null && !logs.isEmpty()) {
            maxTemp = logs.stream()
                .map(com.spcms.models.MonitoringLog::getTemperature)
                .filter(java.util.Objects::nonNull)
                .max(java.math.BigDecimal::compareTo).orElse(java.math.BigDecimal.ZERO);
            
            minTemp = logs.stream()
                .map(com.spcms.models.MonitoringLog::getTemperature)
                .filter(java.util.Objects::nonNull)
                .min(java.math.BigDecimal::compareTo).orElse(java.math.BigDecimal.ZERO);
                
            java.util.List<java.math.BigDecimal> humidities = logs.stream()
                .map(com.spcms.models.MonitoringLog::getHumidity)
                .filter(java.util.Objects::nonNull).toList();
            if (!humidities.isEmpty()) {
                double avg = humidities.stream().mapToDouble(java.math.BigDecimal::doubleValue).average().orElse(0.0);
                avgHumidity = java.math.BigDecimal.valueOf(avg).setScale(2, java.math.RoundingMode.HALF_UP);
            }
        }
        
        dto.setHighestTemp(maxTemp);
        dto.setLowestTemp(minTemp);
        dto.setAvgHumidity(avgHumidity);

        // 2. Incident Metrics
        java.util.List<com.spcms.models.Incident> incidents = incidentRepository.findByCreatedAtBetween(start, end);
        dto.setTotalIncidents(incidents != null ? (long) incidents.size() : 0L);
        
        long criticalCount = incidents != null ? incidents.stream()
            .filter(i -> i.getSeverity() == com.spcms.models.Incident.Severity.CRITICAL)
            .count() : 0L;
        dto.setCriticalFaults(criticalCount);
        
        Integer downtime = incidentRepository.sumDowntimeMinutes(start, end);
        dto.setTotalDowntime(downtime != null ? downtime : 0);

        // 3. Compressor Status
        java.util.List<com.spcms.models.CoolingUnit> stoppedCompressors = coolingUnitRepository.findActiveWithStoppedCompressor();
        if (stoppedCompressors != null && !stoppedCompressors.isEmpty()) {
            dto.setCompressorStatus("CRITICAL_FAULT");
        } else {
            dto.setCompressorStatus("OK");
        }

        return org.springframework.http.ResponseEntity.ok(dto);
    }
}
