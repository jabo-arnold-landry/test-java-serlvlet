package com.spcms.controllers;

import com.spcms.models.*;
import com.spcms.services.*;
import com.spcms.util.AlertInsightUtil;
import com.spcms.util.AlertInsightUtil.AlertInsight;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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

        @Autowired
        private UserService userService;

    @GetMapping
        public String dashboard(Model model, Authentication authentication) {
                Long currentUserId = null;
                if (authentication != null && authentication.getName() != null) {
                        currentUserId = userService.getUserByUsername(authentication.getName())
                                        .map(User::getUserId)
                                        .orElse(null);
                }

        // UPS Summary
        model.addAttribute("totalUps", upsService.getAllUps().size());
        model.addAttribute("activeUps", upsService.getUpsByStatus(Ups.UpsStatus.ACTIVE).size());
        model.addAttribute("faultyUps", upsService.getUpsByStatus(Ups.UpsStatus.FAULTY).size());

        // Cooling Summary
        model.addAttribute("totalCooling", coolingService.getAllCoolingUnits().size());
        model.addAttribute("activeCooling",
                coolingService.getCoolingUnitsByStatus(CoolingUnit.CoolingStatus.ACTIVE).size());

        // Incidents
        model.addAttribute("inProgressIncidents",
                incidentService.getIncidentsByStatus(Incident.IncidentStatus.IN_PROGRESS).size());
        model.addAttribute("criticalIncidents",
                incidentService.getIncidentsBySeverity(Incident.Severity.CRITICAL).size());

        // Alerts
        List<Alert> unacknowledgedAlerts = alertService.getUnacknowledgedAlertsForUser(currentUserId);
        Map<Alert.AlertType, Long> warningCounts = unacknowledgedAlerts.stream()
                .filter(alert -> alert.getAlertType() != null)
                .collect(Collectors.groupingBy(Alert::getAlertType, Collectors.counting()));
        Map<Long, AlertInsight> warningInsights = AlertInsightUtil.buildInsights(unacknowledgedAlerts);

        List<Alert> latestWarnings = unacknowledgedAlerts.stream()
                .sorted(Comparator
                        .comparingInt((Alert alert) -> {
                            if (alert.getAlertId() == null || !warningInsights.containsKey(alert.getAlertId())) {
                                return 0;
                            }
                            return warningInsights.get(alert.getAlertId()).getSeverityScore();
                        })
                        .reversed()
                        .thenComparing(Alert::getCreatedAt,
                                Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(5)
                .collect(Collectors.toList());

        Map<Long, String> dashboardWarningSeverityById = new HashMap<>();
        Map<Long, String> dashboardWarningSeverityClassById = new HashMap<>();
        Map<Long, String> dashboardWarningSlaById = new HashMap<>();
                Map<Long, String> dashboardWarningTriggeredAtById = new HashMap<>();
                Map<Long, String> dashboardWarningReadingById = new HashMap<>();
                DateTimeFormatter warningDateFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

        for (Alert warning : latestWarnings) {
            if (warning.getAlertId() == null) {
                continue;
            }
            AlertInsight insight = warningInsights.getOrDefault(warning.getAlertId(), AlertInsight.empty());
            String severity = insight.getSeverityLabel();
            dashboardWarningSeverityById.put(warning.getAlertId(), severity);
            dashboardWarningSlaById.put(warning.getAlertId(), insight.getSlaStatusText());
            dashboardWarningSeverityClassById.put(warning.getAlertId(), severityBadgeClass(severity));
                        dashboardWarningTriggeredAtById.put(
                                        warning.getAlertId(),
                                        warning.getCreatedAt() != null ? warning.getCreatedAt().format(warningDateFormat) : "-");

                        String readingSummary;
                        if (warning.getActualValue() != null || warning.getThresholdValue() != null) {
                                String actual = warning.getActualValue() != null ? warning.getActualValue().toPlainString() : "-";
                                String threshold = warning.getThresholdValue() != null ? warning.getThresholdValue().toPlainString() : "-";
                                String unit = measurementUnitForType(warning.getAlertType());
                                readingSummary = actual + unit + " / " + threshold + unit;
                        } else {
                                readingSummary = "No sensor reading";
                        }
                        dashboardWarningReadingById.put(warning.getAlertId(), readingSummary);
        }

        model.addAttribute("unacknowledgedAlerts", unacknowledgedAlerts.size());
        model.addAttribute("latestAlertId",
                alertService.getLatestAlertAfter(null).map(Alert::getAlertId).orElse(0L));
        model.addAttribute("dashboardTotalWarnings", unacknowledgedAlerts.size());
        model.addAttribute("dashboardHighTempWarnings",
                warningCounts.getOrDefault(Alert.AlertType.HIGH_TEMP, 0L));
        model.addAttribute("dashboardHumidityWarnings",
                warningCounts.getOrDefault(Alert.AlertType.HUMIDITY, 0L));
        model.addAttribute("dashboardLowBatteryWarnings",
                warningCounts.getOrDefault(Alert.AlertType.LOW_BATTERY, 0L));
        model.addAttribute("dashboardOverloadWarnings",
                warningCounts.getOrDefault(Alert.AlertType.UPS_OVERLOAD, 0L));
        model.addAttribute("dashboardMaintenanceDueWarnings",
                warningCounts.getOrDefault(Alert.AlertType.MAINTENANCE_DUE, 0L));
        model.addAttribute("dashboardWarnings", latestWarnings);
        model.addAttribute("dashboardWarningSeverityById", dashboardWarningSeverityById);
        model.addAttribute("dashboardWarningSeverityClassById", dashboardWarningSeverityClassById);
        model.addAttribute("dashboardWarningSlaById", dashboardWarningSlaById);
        model.addAttribute("dashboardWarningTriggeredAtById", dashboardWarningTriggeredAtById);
        model.addAttribute("dashboardWarningReadingById", dashboardWarningReadingById);

        // Visitors
        model.addAttribute("activeVisitors", visitorService.getActiveVisitors().size());

        // Today's Report
        model.addAttribute("dailyReport", reportService.getDailyReport(LocalDate.now()).orElse(null));

        return "dashboard";
    }

        private String severityBadgeClass(String severity) {
                if ("CRITICAL".equals(severity)) {
                        return "danger";
                }
                if ("HIGH".equals(severity)) {
                        return "warning text-dark";
                }
                if ("MEDIUM".equals(severity)) {
                        return "info text-dark";
                }
                return "secondary";
        }

        private String measurementUnitForType(Alert.AlertType alertType) {
                if (alertType == Alert.AlertType.HIGH_TEMP) {
                        return " C";
                }
                if (alertType == Alert.AlertType.HUMIDITY
                                || alertType == Alert.AlertType.LOW_BATTERY
                                || alertType == Alert.AlertType.UPS_OVERLOAD) {
                        return "%";
                }
                return "";
        }
}
