package com.spcms.controllers;

import com.spcms.models.*;
import com.spcms.services.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

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
    public String dashboard(Model model) {
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
        model.addAttribute("latestAlertId",
                alertService.getLatestAlertAfter(null).map(Alert::getAlertId).orElse(0L));

        // Visitors
        model.addAttribute("activeVisitors", visitorService.getActiveVisitors().size());

        // Today's Report
        model.addAttribute("dailyReport", reportService.getDailyReport(LocalDate.now()).orElse(null));

        return "dashboard";
    }
}
