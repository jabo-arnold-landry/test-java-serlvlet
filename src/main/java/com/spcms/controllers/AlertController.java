package com.spcms.controllers;

import com.spcms.models.Alert;
import com.spcms.models.User;
import com.spcms.services.AlertService;
import com.spcms.services.UserService;
import com.spcms.services.UpsService;
import com.spcms.services.MaintenanceService;
import com.spcms.models.UpsBattery;
import com.spcms.models.UpsMaintenance;
import com.spcms.models.Ups;
import com.spcms.util.AlertInsightUtil;
import com.spcms.util.AlertInsightUtil.AlertInsight;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@Controller
@RequestMapping("/alerts")
public class AlertController {

    @Autowired
    private AlertService alertService;

    @Autowired
    private UserService userService;

    @Autowired
    private UpsService upsService;

    @Autowired
    private MaintenanceService maintenanceService;

    private final List<SseEmitter> alertEmitters = new CopyOnWriteArrayList<>();

    @GetMapping
    public String list(Model model, Authentication authentication) {
        Long currentUserId = resolveCurrentUserId(authentication);
        List<Alert> alerts = alertService.getUnacknowledgedAlertsForUser(currentUserId);
        Map<Long, AlertInsight> insights = AlertInsightUtil.buildInsights(alerts, LocalDateTime.now());

        alerts.sort(Comparator
                .comparingInt((Alert alert) -> {
                    if (alert.getAlertId() == null || !insights.containsKey(alert.getAlertId())) {
                        return 0;
                    }
                    return insights.get(alert.getAlertId()).getSeverityScore();
                })
                .reversed()
                .thenComparing(Alert::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())));

        Map<Long, Integer> severityScoreById = new HashMap<>();
        Map<Long, String> severityLabelById = new HashMap<>();
        Map<Long, String> severityClassById = new HashMap<>();
        Map<Long, String> slaStatusById = new HashMap<>();
        Map<Long, String> recommendationById = new HashMap<>();

        for (Alert alert : alerts) {
            if (alert.getAlertId() == null) {
                continue;
            }
            AlertInsight insight = insights.getOrDefault(alert.getAlertId(), AlertInsight.empty());
            severityScoreById.put(alert.getAlertId(), insight.getSeverityScore());
            severityLabelById.put(alert.getAlertId(), insight.getSeverityLabel());
            severityClassById.put(alert.getAlertId(), severityBadgeClass(insight.getSeverityLabel()));
            slaStatusById.put(alert.getAlertId(), insight.getSlaStatusText());
            recommendationById.put(alert.getAlertId(), insight.getRecommendation());
        }

        model.addAttribute("alerts", alerts);
        model.addAttribute("severityScoreById", severityScoreById);
        model.addAttribute("severityLabelById", severityLabelById);
        model.addAttribute("severityClassById", severityClassById);
        model.addAttribute("slaStatusById", slaStatusById);
        model.addAttribute("recommendationById", recommendationById);
        model.addAttribute("unacknowledgedAlerts", alertService.countUnacknowledgedAlertsForUser(currentUserId));
        return "alerts/list";
    }

    @GetMapping("/history")
    public String history(@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
                          @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate,
                          @RequestParam(required = false) Alert.AlertType alertType,
                          Model model,
                          Authentication authentication) {

        Long currentUserId = resolveCurrentUserId(authentication);

        LocalDate normalizedFrom = fromDate;
        LocalDate normalizedTo = toDate;

        if (normalizedFrom != null && normalizedTo != null && normalizedFrom.isAfter(normalizedTo)) {
            LocalDate temp = normalizedFrom;
            normalizedFrom = normalizedTo;
            normalizedTo = temp;
        }

        List<Alert> historyAlerts = alertService.getAcknowledgedAlertsForUser(currentUserId, normalizedFrom, normalizedTo, alertType);
        Map<Long, LocalDateTime> acknowledgedAtMap = alertService.getAcknowledgedAtMapForUser(currentUserId, historyAlerts);
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        Map<Long, String> triggeredAtById = new HashMap<>();
        Map<Long, String> acknowledgedAtById = new HashMap<>();

        for (Alert alert : historyAlerts) {
            if (alert.getAlertId() == null) {
                continue;
            }
            triggeredAtById.put(
                    alert.getAlertId(),
                    alert.getCreatedAt() != null ? alert.getCreatedAt().format(dateTimeFormatter) : "-");
            acknowledgedAtById.put(
                    alert.getAlertId(),
                    acknowledgedAtMap.get(alert.getAlertId()) != null
                        ? acknowledgedAtMap.get(alert.getAlertId()).format(dateTimeFormatter)
                        : "-");
        }

        model.addAttribute("historyAlerts", historyAlerts);
        model.addAttribute("fromDate", normalizedFrom);
        model.addAttribute("toDate", normalizedTo);
        model.addAttribute("selectedAlertType", alertType);
        model.addAttribute("alertTypes", Alert.AlertType.values());
        model.addAttribute("triggeredAtById", triggeredAtById);
        model.addAttribute("acknowledgedAtById", acknowledgedAtById);
        model.addAttribute("unacknowledgedAlerts", alertService.countUnacknowledgedAlertsForUser(currentUserId));
        return "alerts/history";
    }

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamAlerts() {
        SseEmitter emitter = new SseEmitter(300_000L); // 5 minute timeout; client will reconnect
        alertEmitters.add(emitter);
        emitter.onCompletion(() -> alertEmitters.remove(emitter));
        emitter.onTimeout(() -> alertEmitters.remove(emitter));
        emitter.onError(e -> alertEmitters.remove(emitter));
        try {
            emitter.send(SseEmitter.event().name("ping").data("connected"));
        } catch (Exception ignore) {}
        return emitter;
    }

    @GetMapping(value = "/latest", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> latestAlert(@RequestParam(required = false) Long sinceId) {
        return alertService.getLatestAlertAfter(sinceId)
                .map(alert -> Map.<String, Object>of(
                        "id", alert.getAlertId(),
                        "type", alert.getAlertType(),
                        "message", alert.getMessage(),
                        "equipmentType", alert.getEquipmentType(),
                        "equipmentId", alert.getEquipmentId(),
                        "createdAt", alert.getCreatedAt()))
                .orElseGet(Map::of);
    }

            @GetMapping(value = "/details/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
            @ResponseBody
            public Map<String, Object> alertDetails(@PathVariable Long id, Authentication authentication) {
            Alert alert = alertService.getAlertById(id)
                .orElseThrow(() -> new RuntimeException("Alert not found: " + id));
            Long currentUserId = resolveCurrentUserId(authentication);

            AlertInsight insight = AlertInsightUtil.buildInsight(alert, alertService.getAllAlerts(), LocalDateTime.now());
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            boolean acknowledgedByCurrentUser = alertService.isAcknowledgedByUser(id, currentUserId);
            LocalDateTime acknowledgedAtForCurrentUser = alertService.getAcknowledgedAtForUser(id, currentUserId).orElse(null);

            Map<String, Object> details = new LinkedHashMap<>();
            details.put("id", alert.getAlertId());
            details.put("type", alert.getAlertType() != null ? alert.getAlertType().name() : "-");
            details.put("equipment", (alert.getEquipmentType() != null ? alert.getEquipmentType().name() : "-") +
                (alert.getEquipmentId() != null ? " #" + alert.getEquipmentId() : ""));
            details.put("message", alert.getMessage() != null ? alert.getMessage() : "-");
            details.put("thresholdValue", alert.getThresholdValue() != null ? alert.getThresholdValue().toPlainString() : "-");
            details.put("actualValue", alert.getActualValue() != null ? alert.getActualValue().toPlainString() : "-");
            details.put("sent", Boolean.TRUE.equals(alert.getIsSent()) ? "Yes" : "No");
            details.put("status", acknowledgedByCurrentUser ? "Acknowledged" : "Pending");
            details.put("createdAt", alert.getCreatedAt() != null ? alert.getCreatedAt().format(formatter) : "-");
            details.put("acknowledgedAt", acknowledgedAtForCurrentUser != null ? acknowledgedAtForCurrentUser.format(formatter) : "-");
            details.put("severity", insight.getSeverityLabel());
            details.put("score", insight.getSeverityScore());
            details.put("sla", insight.getSlaStatusText());
            details.put("recommendation", insight.getRecommendation());
            return details;
            }

    @GetMapping("/view/{id}")
    public String viewAlert(@PathVariable Long id, Model model) {
        Alert alert = alertService.getAlertById(id)
                .orElseThrow(() -> new RuntimeException("Alert not found: " + id));
        
        model.addAttribute("alert", alert);

        AlertInsight insight = AlertInsightUtil.buildInsight(alert, alertService.getAllAlerts(), LocalDateTime.now());
        model.addAttribute("alertSeverityScore", insight.getSeverityScore());
        model.addAttribute("alertSeverityLabel", insight.getSeverityLabel());
        model.addAttribute("alertSeverityClass", severityBadgeClass(insight.getSeverityLabel()));
        model.addAttribute("alertSlaStatus", insight.getSlaStatusText());
        model.addAttribute("alertRecommendation", insight.getRecommendation());
        model.addAttribute("alertRepeatCount24h", insight.getRepeatCount24h());
        
        // Calculate max gauge value based on alert type
        BigDecimal maxGaugeValue;
        switch (alert.getAlertType()) {
            case HIGH_TEMP:
                maxGaugeValue = new BigDecimal("50"); // Max temp 50°C
                break;
            case HUMIDITY:
                maxGaugeValue = new BigDecimal("100"); // Max humidity 100%
                break;
            case LOW_BATTERY:
            case UPS_OVERLOAD:
                maxGaugeValue = new BigDecimal("100"); // Percentage
                break;
            default:
                maxGaugeValue = new BigDecimal("100");
        }
        model.addAttribute("maxGaugeValue", maxGaugeValue);
        
        return "alerts/view";
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

    private Long resolveCurrentUserId(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            return null;
        }
        return userService.getUserByUsername(authentication.getName())
                .map(User::getUserId)
                .orElse(null);
    }

    private void pushAlert(Alert alert) {
        List<SseEmitter> dead = new java.util.ArrayList<>();
        for (SseEmitter emitter : alertEmitters) {
            try {
                Map<String, Object> payload = Map.of(
                        "id", alert.getAlertId(),
                        "type", alert.getAlertType(),
                        "message", alert.getMessage(),
                        "equipmentType", alert.getEquipmentType(),
                        "equipmentId", alert.getEquipmentId(),
                        "createdAt", alert.getCreatedAt()
                );
                emitter.send(SseEmitter.event()
                        .name("alert")
                        .data(java.util.Objects.requireNonNull(payload), MediaType.APPLICATION_JSON));
            } catch (Exception e) {
                dead.add(emitter);
            }
        }
        alertEmitters.removeAll(dead);
    }

    @PostMapping("/acknowledge/{id}")
    public String acknowledge(@PathVariable Long id,
                               Authentication authentication,
                               RedirectAttributes redirectAttributes) {
        User currentUser = userService.getUserByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        alertService.acknowledgeAlert(id, currentUser.getUserId());
        redirectAttributes.addFlashAttribute("success", "Alert acknowledged successfully");
        return "redirect:/alerts";
    }

    @PostMapping("/send-email/{id}")
    public String sendAlertEmail(@PathVariable Long id,
                                  @RequestParam String email,
                                  RedirectAttributes redirectAttributes) {
        try {
            alertService.sendAlertEmail(id, email);
            redirectAttributes.addFlashAttribute("success", "Alert email sent to " + email);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to send email: " + e.getMessage());
        }
        return "redirect:/alerts/view/" + id;
    }

    @GetMapping("/settings")
    public String alertSettings(Model model) {
        model.addAttribute("thresholds", alertService.getAlertThresholds());
        return "alerts/settings";
    }

    @PostMapping("/settings")
    public String saveAlertSettings(
            @RequestParam(required = false) BigDecimal upsHighTempThreshold,
            @RequestParam(required = false) BigDecimal coolingHighTempThreshold,
            @RequestParam(required = false) BigDecimal humidityHighThreshold,
            @RequestParam(required = false) BigDecimal humidityLowThreshold,
            @RequestParam(required = false) BigDecimal upsOverloadThreshold,
            @RequestParam(required = false) BigDecimal lowBatteryThreshold,
            @RequestParam(required = false) Integer batteryReplacementWarningDays,
            @RequestParam(required = false) Boolean autoSendEmail,
            @RequestParam(required = false) String emailRecipients,
            RedirectAttributes redirectAttributes) {
        
        try {
            alertService.updateAlertThresholds(
                upsHighTempThreshold != null ? upsHighTempThreshold : new BigDecimal("35"),
                coolingHighTempThreshold != null ? coolingHighTempThreshold : new BigDecimal("25"),
                humidityHighThreshold != null ? humidityHighThreshold : new BigDecimal("65"),
                humidityLowThreshold != null ? humidityLowThreshold : new BigDecimal("30"),
                upsOverloadThreshold != null ? upsOverloadThreshold : new BigDecimal("80"),
                lowBatteryThreshold != null ? lowBatteryThreshold : new BigDecimal("20"),
                batteryReplacementWarningDays != null ? batteryReplacementWarningDays : 30,
                autoSendEmail != null && autoSendEmail,
                emailRecipients
            );
            redirectAttributes.addFlashAttribute("success", "Alert settings updated successfully");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to save settings: " + e.getMessage());
        }
        return "redirect:/alerts/settings";
    }

    // ==================== TEST ALERTS (for development/demo) ====================

    @GetMapping("/test")
    public String testAlertsPage(Model model) {
        model.addAttribute("thresholds", alertService.getAlertThresholds());
        model.addAttribute("upsList", upsService.getAllUps());
        model.addAttribute("dueUpsMaintenance", maintenanceService.getOverdueUpsMaintenance());
        model.addAttribute("dueBatteries", upsService.getBatteriesDueForReplacement());
        model.addAttribute("allUsers", userService.getAllUsers());
        return "alerts/test";
    }

    @PostMapping("/test/high-temp")
    public String createTestHighTempAlert(
            @RequestParam String equipmentType,
            @RequestParam Long equipmentId,
            @RequestParam BigDecimal actualTemp,
            @RequestParam BigDecimal threshold,
            @RequestParam(defaultValue = "false") boolean sendEmail,
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            Alert.EquipmentCategory category = "UPS".equals(equipmentType) 
                ? Alert.EquipmentCategory.UPS 
                : Alert.EquipmentCategory.COOLING;
            
            // VALIDATION: Check if actual value exceeds threshold
            if (actualTemp.compareTo(threshold) <= 0) {
                redirectAttributes.addFlashAttribute("warning", 
                    "NO THRESHOLD EXCEEDED: Actual temperature (" + actualTemp + "°C) does not exceed limit (" + threshold + "°C). No alert will be sent.");
                return "redirect:/alerts/test";
            }
            
            if (sendEmail) {
                // NOTIFY: send email only, no alert created, no toast
                if (email == null || email.trim().isEmpty()) {
                    redirectAttributes.addFlashAttribute("error", "Provide an email to notify.");
                    return "redirect:/alerts/test";
                }
                String message = "HIGH TEMPERATURE NOTIFICATION: Actual " + actualTemp + "°C exceeds threshold " + threshold + "°C on " + category + " (ID: " + equipmentId + ")";
                alertService.sendStandaloneNotificationEmail("High Temperature", message, email.trim());
                redirectAttributes.addFlashAttribute("success", "High Temperature notification email sent to " + email);
            } else {
                // TRIGGER: create alert + push SSE toast
                Alert alert = alertService.createHighTempAlert(category, equipmentId, threshold, actualTemp, false);
                pushAlert(alert);
                redirectAttributes.addFlashAttribute("success", 
                    "High Temperature alert triggered (ID: " + alert.getAlertId() + ")");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed: " + e.getMessage());
        }
        return "redirect:/alerts/test";
    }

    @PostMapping("/test/humidity")
    public String createTestHumidityAlert(
            @RequestParam String equipmentType,
            @RequestParam Long equipmentId,
            @RequestParam BigDecimal actualHumidity,
            @RequestParam BigDecimal threshold,
            @RequestParam String humidityType,
            @RequestParam(defaultValue = "false") boolean sendEmail,
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            Alert.EquipmentCategory category = "UPS".equals(equipmentType) 
                ? Alert.EquipmentCategory.UPS 
                : Alert.EquipmentCategory.COOLING;
            
            boolean isHigh = "HIGH".equals(humidityType);
            String direction = isHigh ? "above" : "below";
            
            // VALIDATION: Check if actual value violates threshold
            boolean violatesThreshold = (isHigh && actualHumidity.compareTo(threshold) > 0) || 
                                       (!isHigh && actualHumidity.compareTo(threshold) < 0);
            
            if (!violatesThreshold) {
                String expectedCondition = isHigh ? "higher than " + threshold + "%" : "lower than " + threshold + "%";
                redirectAttributes.addFlashAttribute("warning", 
                    "NO THRESHOLD EXCEEDED: Actual humidity (" + actualHumidity + "%) is not " + expectedCondition + ". No alert will be sent.");
                return "redirect:/alerts/test";
            }
            
            if (sendEmail) {
                if (email == null || email.trim().isEmpty()) {
                    redirectAttributes.addFlashAttribute("error", "Provide an email to notify.");
                    return "redirect:/alerts/test";
                }
                String message = "HUMIDITY NOTIFICATION: Actual " + actualHumidity + "% is " + direction + " threshold " + threshold + "% on " + category + " (ID: " + equipmentId + ")";
                alertService.sendStandaloneNotificationEmail("Humidity Alert", message, email.trim());
                redirectAttributes.addFlashAttribute("success", "Humidity notification email sent to " + email);
            } else {
                Alert alert = alertService.createHumidityAlert(category, equipmentId, threshold, actualHumidity, isHigh, false);
                pushAlert(alert);
                redirectAttributes.addFlashAttribute("success", 
                    "Humidity alert triggered (ID: " + alert.getAlertId() + ")");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed: " + e.getMessage());
        }
        return "redirect:/alerts/test";
    }

    @PostMapping("/test/send-test-email")
    public String sendTestEmail(@RequestParam String email, RedirectAttributes redirectAttributes) {
        try {
            alertService.sendTestEmail(email);
            redirectAttributes.addFlashAttribute("success", "Test email sent to " + email);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Email failed: " + e.getMessage());
        }
        return "redirect:/alerts/test";
    }

    @PostMapping("/test/ups-overload")
    public String createUpsOverloadAlert(
            @RequestParam Long upsId,
            @RequestParam BigDecimal actualLoad,
            @RequestParam BigDecimal threshold,
            @RequestParam(defaultValue = "false") boolean sendEmail,
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            if (sendEmail) {
                if (email == null || email.trim().isEmpty()) {
                    redirectAttributes.addFlashAttribute("error", "Provide an email to notify.");
                    return "redirect:/alerts/test";
                }
                String message = "UPS OVERLOAD NOTIFICATION: Load " + actualLoad + "% exceeds threshold " + threshold + "% on UPS (ID: " + upsId + ")";
                alertService.sendStandaloneNotificationEmail("UPS Overload", message, email.trim());
                redirectAttributes.addFlashAttribute("success",
                    "UPS Overload notification email sent to " + email);
            } else {
                Alert alert = alertService.createOverloadAlert(upsId, threshold, actualLoad, false);
                pushAlert(alert);
                redirectAttributes.addFlashAttribute("success",
                    "UPS OVERLOAD alert triggered (ID: " + alert.getAlertId() + ")");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed: " + e.getMessage());
        }
        return "redirect:/alerts/test";
    }


    @PostMapping("/test/low-battery")
    public String createLowBatteryAlert(
            @RequestParam Long upsId,
            @RequestParam BigDecimal actualLevel,
            @RequestParam BigDecimal threshold,
            @RequestParam(defaultValue = "false") boolean sendEmail,
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            if (sendEmail) {
                if (email == null || email.trim().isEmpty()) {
                    redirectAttributes.addFlashAttribute("error", "Provide an email to notify.");
                    return "redirect:/alerts/test";
                }
                String message = "LOW BATTERY NOTIFICATION: Battery level " + actualLevel + "% below threshold " + threshold + "% on UPS (ID: " + upsId + ")";
                alertService.sendStandaloneNotificationEmail("Low Battery", message, email.trim());
                redirectAttributes.addFlashAttribute("success",
                    "Low Battery notification email sent to " + email);
            } else {
                Alert alert = alertService.createLowBatteryAlert(upsId, threshold, actualLevel, false);
                pushAlert(alert);
                redirectAttributes.addFlashAttribute("success",
                    "LOW BATTERY alert triggered (ID: " + alert.getAlertId() + ")");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed: " + e.getMessage());
        }
        return "redirect:/alerts/test";
    }

    @PostMapping("/test/maintenance-due")
    public String createMaintenanceDueAlert(
            @RequestParam Long upsId,
            @RequestParam(required = false) Long upsMaintenanceId,
            @RequestParam(required = false) Long batteryId,
            @RequestParam(required = false) Boolean isUpsReplacement,
            @RequestParam(required = false) String note,
            @RequestParam(defaultValue = "false") boolean sendEmail,
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            Ups ups = upsService.getUpsById(upsId)
                    .orElseThrow(() -> new RuntimeException("Selected UPS not found."));

            StringBuilder messageBuilder = new StringBuilder();
            messageBuilder.append("Maintenance notification for UPS ").append(ups.getAssetTag())
                    .append(" (").append(ups.getUpsName()).append(")");

            if (upsMaintenanceId != null && upsMaintenanceId > 0) {
                UpsMaintenance maintenance = maintenanceService.getUpsMaintenanceById(upsMaintenanceId)
                        .orElseThrow(() -> new RuntimeException("Select a valid UPS maintenance record."));
                String dueDate = maintenance.getNextDueDate() != null
                        ? maintenance.getNextDueDate().toString()
                        : maintenance.getMaintenanceDate().toString();
                messageBuilder.append(" | Maintenance (").append(maintenance.getMaintenanceType()).append(") due on ").append(dueDate);
            }

            if (batteryId != null && batteryId > 0) {
                UpsBattery battery = upsService.getBatteryById(batteryId)
                        .orElseThrow(() -> new RuntimeException("Select a valid battery."));
                String dueDate = battery.getReplacementDueDate() != null
                        ? battery.getReplacementDueDate().toString()
                        : "upcoming";
                messageBuilder.append(" | Battery ").append(battery.getBatteryId()).append(" replacement due ").append(dueDate);
            }

            if (Boolean.TRUE.equals(isUpsReplacement)) {
                messageBuilder.append(" | UPS nearing end of life, replacement needed");
            }

            if (note != null && !note.trim().isEmpty()) {
                messageBuilder.append("\nNote: ").append(note.trim());
            }

            String finalMessage = messageBuilder.toString();

            if (sendEmail) {
                if (email == null || email.trim().isEmpty()) {
                    redirectAttributes.addFlashAttribute("error", "Provide an email to notify.");
                    return "redirect:/alerts/test";
                }
                alertService.sendStandaloneNotificationEmail("Maintenance Due", finalMessage, email.trim());
                redirectAttributes.addFlashAttribute("success",
                        "Maintenance due notification email sent to " + email);
            } else {
                Alert alert = alertService.createMaintenanceDueAlert(Alert.EquipmentCategory.UPS, upsId, finalMessage, false);
                pushAlert(alert);
                redirectAttributes.addFlashAttribute("success",
                        "Maintenance due alert triggered (ID: " + alert.getAlertId() + ")");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed: " + e.getMessage());
        }
        return "redirect:/alerts/test";
    }
}


