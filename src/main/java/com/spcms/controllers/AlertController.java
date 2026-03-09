package com.spcms.controllers;

import com.spcms.models.Alert;
import com.spcms.models.User;
import com.spcms.services.AlertService;
import com.spcms.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

@Controller
@RequestMapping("/alerts")
public class AlertController {

    @Autowired
    private AlertService alertService;

    @Autowired
    private UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("alerts", alertService.getAllAlerts());
        model.addAttribute("unacknowledgedAlerts", alertService.getUnacknowledgedAlerts().size());
        return "alerts/list";
    }

    @GetMapping("/view/{id}")
    public String viewAlert(@PathVariable Long id, Model model) {
        Alert alert = alertService.getAlertById(id)
                .orElseThrow(() -> new RuntimeException("Alert not found: " + id));
        
        model.addAttribute("alert", alert);
        
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
        return "alerts/test";
    }

    @PostMapping("/test/high-temp")
    public String createTestHighTempAlert(
            @RequestParam String equipmentType,
            @RequestParam Long equipmentId,
            @RequestParam BigDecimal actualTemp,
            @RequestParam BigDecimal threshold,
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            Alert.EquipmentCategory category = "UPS".equals(equipmentType) 
                ? Alert.EquipmentCategory.UPS 
                : Alert.EquipmentCategory.COOLING;
            
            Alert alert = alertService.createHighTempAlert(category, equipmentId, threshold, actualTemp);
            
            if (email != null && !email.trim().isEmpty()) {
                alertService.sendAlertEmail(alert.getAlertId(), email.trim());
                redirectAttributes.addFlashAttribute("success", 
                    "High Temperature alert created and email sent to " + email);
            } else {
                redirectAttributes.addFlashAttribute("success", 
                    "High Temperature alert created (ID: " + alert.getAlertId() + ")");
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
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            Alert.EquipmentCategory category = "UPS".equals(equipmentType) 
                ? Alert.EquipmentCategory.UPS 
                : Alert.EquipmentCategory.COOLING;
            
            boolean isHigh = "HIGH".equals(humidityType);
            Alert alert = alertService.createHumidityAlert(category, equipmentId, threshold, actualHumidity, isHigh);
            
            if (email != null && !email.trim().isEmpty()) {
                alertService.sendAlertEmail(alert.getAlertId(), email.trim());
                redirectAttributes.addFlashAttribute("success", 
                    "Humidity alert created and email sent to " + email);
            } else {
                redirectAttributes.addFlashAttribute("success", 
                    "Humidity alert created (ID: " + alert.getAlertId() + ")");
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
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            Alert alert = alertService.createOverloadAlert(upsId, threshold, actualLoad);
            
            if (email != null && !email.trim().isEmpty()) {
                alertService.sendAlertEmail(alert.getAlertId(), email.trim());
                redirectAttributes.addFlashAttribute("success", 
                    "⚡ UPS OVERLOAD alert triggered! Email sent to " + email);
            } else {
                redirectAttributes.addFlashAttribute("success", 
                    "⚡ UPS OVERLOAD alert triggered (ID: " + alert.getAlertId() + ")");
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
            @RequestParam(required = false) String email,
            RedirectAttributes redirectAttributes) {
        try {
            Alert alert = alertService.createLowBatteryAlert(upsId, threshold, actualLevel);
            
            if (email != null && !email.trim().isEmpty()) {
                alertService.sendAlertEmail(alert.getAlertId(), email.trim());
                redirectAttributes.addFlashAttribute("success", 
                    "🔋 LOW BATTERY alert triggered! Email sent to " + email);
            } else {
                redirectAttributes.addFlashAttribute("success", 
                    "🔋 LOW BATTERY alert triggered (ID: " + alert.getAlertId() + ")");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed: " + e.getMessage());
        }
        return "redirect:/alerts/test";
    }
}
