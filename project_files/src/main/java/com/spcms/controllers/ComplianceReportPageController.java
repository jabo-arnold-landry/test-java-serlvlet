package com.spcms.controllers;

import com.spcms.dto.reports.ReportLogFilterDto;
import com.spcms.models.User;
import com.spcms.services.ReportLogService;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

@Controller
@RequestMapping("/compliance/reports")
public class ComplianceReportPageController {

    private final ReportLogService reportLogService;

    public ComplianceReportPageController(ReportLogService reportLogService) {
        this.reportLogService = reportLogService;
    }

    @GetMapping("/dashboard")
    public String dashboard() {
        return "compliance/dashboard";
    }

    @GetMapping("/generate")
    public String generatePage(Model model, Authentication authentication) {
        model.addAttribute("today", LocalDate.now());
        model.addAttribute("isTechnician", hasRole(authentication, "ROLE_TECHNICIAN"));
        return "compliance/generate";
    }

    @GetMapping("/viewer")
    public String viewerPage(@RequestParam(required = false, defaultValue = "equipment-health") String reportType,
                             Model model,
                             Authentication authentication) {
        boolean isTechnician = hasRole(authentication, "ROLE_TECHNICIAN");
        String effectiveReportType = reportType;
        if (isTechnician && !("shift".equalsIgnoreCase(reportType) || "maintenance".equalsIgnoreCase(reportType))) {
            effectiveReportType = "maintenance";
            model.addAttribute("accessNotice", "Technician view is restricted to Shift and Maintenance reports.");
        }

        model.addAttribute("reportType", effectiveReportType);
        model.addAttribute("today", LocalDate.now());
        model.addAttribute("isTechnician", isTechnician);
        return "compliance/viewer";
    }

    @GetMapping("/history")
    public String historyPage(@RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate startDate,
                              @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate endDate,
                              @RequestParam(required = false) String reportType,
                              @RequestParam(required = false) Long userId,
                              Authentication authentication,
                              Model model) {
        User currentUser = authentication != null
                ? reportLogService.findUserByUsername(authentication.getName()).orElse(null)
                : null;

        ReportLogFilterDto filter = ReportLogFilterDto.builder()
                .startDate(startDate)
                .endDate(endDate)
                .reportType(reportType)
                .userId(userId)
                .build();

        model.addAttribute("logs", reportLogService.getLogs(filter, currentUser));
        model.addAttribute("users", reportLogService.getSelectableUsers(currentUser));
        model.addAttribute("selectedStartDate", startDate);
        model.addAttribute("selectedEndDate", endDate);
        model.addAttribute("selectedReportType", reportType);
        model.addAttribute("selectedUserId", userId);
        model.addAttribute("isTechnician", hasRole(authentication, "ROLE_TECHNICIAN"));
        return "compliance/history";
    }

    private boolean hasRole(Authentication authentication, String role) {
        if (authentication == null) {
            return false;
        }
        return authentication.getAuthorities().stream()
                .anyMatch(a -> role.equals(a.getAuthority()));
    }
}
