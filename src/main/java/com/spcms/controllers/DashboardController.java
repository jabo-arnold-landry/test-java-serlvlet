package com.spcms.controllers;

import com.spcms.models.*;
import com.spcms.services.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.security.Principal;
import java.util.LinkedHashMap;
import java.util.Map;

@Controller
@RequestMapping("/dashboard")
public class DashboardController {

    @Autowired
    private UpsService upsService;

    @Autowired
    private CoolingService coolingService;

    @Autowired
    private IncidentService incidentService;

    @Autowired
    private AlertService alertService;

    @Autowired
    private VisitorService visitorService;

    @Autowired
    private ReportService reportService;

    @GetMapping
    public String dashboard(Model model, java.security.Principal principal) {
        // UPS Summary
        model.addAttribute("totalUps", upsService.getAllUps().size());
        model.addAttribute("activeUps", upsService.getUpsByStatus(Ups.UpsStatus.ACTIVE).size());
        model.addAttribute("faultyUps", upsService.getUpsByStatus(Ups.UpsStatus.FAULTY).size());

        // Cooling Summary
        model.addAttribute("totalCooling", coolingService.getAllCoolingUnits().size());
        model.addAttribute("activeCooling",
                coolingService.getCoolingUnitsByStatus(CoolingUnit.CoolingStatus.ACTIVE).size());

        // Incidents
        model.addAttribute("openIncidents",
                incidentService.getIncidentsByStatus(Incident.IncidentStatus.OPEN).size());
        model.addAttribute("criticalIncidents",
                incidentService.getIncidentsBySeverity(Incident.Severity.CRITICAL).size());

        // Alerts
        model.addAttribute("unacknowledgedAlerts", alertService.getUnacknowledgedAlerts().size());

        // Visitors (Global)
        model.addAttribute("activeVisitorsCount", visitorService.getActiveVisitors().size());
        
        // Detailed Visitor Metrics for Security/Manager
        model.addAttribute("pendingApprovals", visitorService.getPendingApprovals().size());
        model.addAttribute("waitingForCheckIn", visitorService.getWaitingForCheckIn().size());
        model.addAttribute("checkOutsToday", visitorService.countCompletedVisitsToday());

        // Traffic Stats (Daily/Monthly) for Security/Manager Charts
        Map<String, Long> monthlyStats = new LinkedHashMap<>();
        Map<String, Long> dailyStats = new LinkedHashMap<>();
        DateTimeFormatter mFmt = DateTimeFormatter.ofPattern("MMM yyyy");
        DateTimeFormatter dFmt = DateTimeFormatter.ofPattern("dd MMM");
        
        for (int i = 5; i >= 0; i--) {
            java.time.YearMonth month = java.time.YearMonth.now().minusMonths(i);
            long count = visitorService.getAllVisitors().stream()
                    .filter(v -> v.getVisitDate() != null && java.time.YearMonth.from(v.getVisitDate()).equals(month))
                    .count();
            monthlyStats.put(month.format(mFmt), count);
        }
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            long count = visitorService.getVisitorsByDate(date).size();
            dailyStats.put(date.format(dFmt), count);
        }
        model.addAttribute("monthlyStats", monthlyStats);
        model.addAttribute("dailyStats", dailyStats);

        // Today's Report
        model.addAttribute("dailyReport", reportService.getDailyReport(LocalDate.now()).orElse(null));

        return "dashboard";
    }
}
