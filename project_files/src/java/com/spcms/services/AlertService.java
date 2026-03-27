package com.spcms.services;

import com.spcms.models.Alert;
import com.spcms.repositories.AlertRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.mail.internet.MimeMessage;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Alert & Notification Service.
 * 
 * Handles alert creation, email notifications, and dashboard warnings
 * for: High Temperature, Low Battery, UPS Overload, Humidity,
 * Maintenance Due, and Equipment Faults.
 */
@Service
@Transactional
public class AlertService {

    @Autowired
    private AlertRepository alertRepository;

    @Autowired(required = false)
    private JavaMailSender mailSender;

    // ==================== Alert CRUD ====================

    public Alert createAlert(Alert alert) {
        return alertRepository.save(alert);
    }

    public Optional<Alert> getAlertById(Long id) {
        return alertRepository.findById(id);
    }

    public List<Alert> getAllAlerts() {
        return alertRepository.findAll();
    }

    public List<Alert> getUnsentAlerts() {
        return alertRepository.findByIsSentFalse();
    }

    public List<Alert> getUnacknowledgedAlerts() {
        return alertRepository.findByIsAcknowledgedFalse();
    }

    // ==================== Alert Generators ====================

    /**
     * Create a High Temperature alert for a UPS or Cooling unit.
     */
    public Alert createHighTempAlert(Alert.EquipmentCategory equipmentType,
                                      Long equipmentId, BigDecimal threshold, BigDecimal actual) {
        Alert alert = Alert.builder()
                .alertType(Alert.AlertType.HIGH_TEMP)
                .equipmentType(equipmentType)
                .equipmentId(equipmentId)
                .message("HIGH TEMPERATURE ALERT: Actual " + actual + "°C exceeds threshold " + threshold + "°C")
                .thresholdValue(threshold)
                .actualValue(actual)
                .isSent(false)
                .isAcknowledged(false)
                .build();
        return alertRepository.save(alert);
    }

    /**
     * Create a Low Battery alert for a UPS unit.
     */
    public Alert createLowBatteryAlert(Long upsId, BigDecimal threshold, BigDecimal actual) {
        Alert alert = Alert.builder()
                .alertType(Alert.AlertType.LOW_BATTERY)
                .equipmentType(Alert.EquipmentCategory.UPS)
                .equipmentId(upsId)
                .message("LOW BATTERY ALERT: Battery level " + actual + "% below threshold " + threshold + "%")
                .thresholdValue(threshold)
                .actualValue(actual)
                .isSent(false)
                .isAcknowledged(false)
                .build();
        return alertRepository.save(alert);
    }

    /**
     * Create a UPS Overload alert.
     */
    public Alert createOverloadAlert(Long upsId, BigDecimal threshold, BigDecimal actual) {
        Alert alert = Alert.builder()
                .alertType(Alert.AlertType.UPS_OVERLOAD)
                .equipmentType(Alert.EquipmentCategory.UPS)
                .equipmentId(upsId)
                .message("UPS OVERLOAD ALERT: Load " + actual + "% exceeds threshold " + threshold + "%")
                .thresholdValue(threshold)
                .actualValue(actual)
                .isSent(false)
                .isAcknowledged(false)
                .build();
        return alertRepository.save(alert);
    }

    /**
     * Create a Maintenance Due alert.
     */
    public Alert createMaintenanceDueAlert(Alert.EquipmentCategory type, Long equipmentId, String message) {
        Alert alert = Alert.builder()
                .alertType(Alert.AlertType.MAINTENANCE_DUE)
                .equipmentType(type)
                .equipmentId(equipmentId)
                .message("MAINTENANCE DUE: " + message)
                .isSent(false)
                .isAcknowledged(false)
                .build();
        return alertRepository.save(alert);
    }

    // ==================== Acknowledgment ====================

    public Alert acknowledgeAlert(Long alertId, Long userId) {
        Alert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new RuntimeException("Alert not found: " + alertId));
        var user = new com.spcms.models.User();
        user.setUserId(userId);
        alert.setIsAcknowledged(true);
        alert.setAcknowledgedBy(user);
        alert.setAcknowledgedAt(LocalDateTime.now());
        return alertRepository.save(alert);
    }

    /**
     * Create a Humidity alert.
     */
    public Alert createHumidityAlert(Alert.EquipmentCategory equipmentType,
                                      Long equipmentId, BigDecimal threshold, BigDecimal actual, String direction) {
        Alert alert = Alert.builder()
                .alertType(Alert.AlertType.HUMIDITY)
                .equipmentType(equipmentType)
                .equipmentId(equipmentId)
                .message("HUMIDITY ALERT: Actual " + actual + "% is " + direction + " threshold " + threshold + "%")
                .thresholdValue(threshold)
                .actualValue(actual)
                .isSent(false)
                .isAcknowledged(false)
                .build();
        return alertRepository.save(alert);
    }

    // ==================== Email Notification ====================

    /**
     * Send email notification for an alert using HTML templates.
     */
    public void sendAlertEmail(Long alertId, String recipientEmail) {
        Alert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new RuntimeException("Alert not found: " + alertId));

        if (mailSender != null) {
            try {
                MimeMessage message = mailSender.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
                
                helper.setTo(recipientEmail);
                helper.setSubject("[SPCMS ALERT] " + alert.getAlertType().name());
                
                String htmlBody = generateHtmlEmailBody(alert);
                helper.setText(htmlBody, true);
                
                mailSender.send(message);

                alert.setIsSent(true);
                alertRepository.save(alert);
            } catch (Exception e) {
                // Log error but don't fail the transaction
                System.err.println("Failed to send alert email: " + e.getMessage());
            }
        } else {
            System.out.println("Mail sender not configured. Alert email skipped for alert: " + alertId);
            System.out.println("Mock Email Body: \n" + generateHtmlEmailBody(alert));
        }
    }
    
    private String generateHtmlEmailBody(Alert alert) {
        String color = "red";
        if (alert.getAlertType() == Alert.AlertType.LOW_BATTERY) color = "orange";
        
        BigDecimal actual = alert.getActualValue() != null ? alert.getActualValue() : BigDecimal.ZERO;
        BigDecimal threshold = alert.getThresholdValue() != null ? alert.getThresholdValue() : BigDecimal.ZERO;
        
        // Calculate a percentage for the bar graphic
        double barWidth = 0;
        if (threshold.doubleValue() > 0) {
            barWidth = Math.min((actual.doubleValue() / threshold.doubleValue()) * 50, 100); // Scale logic depends on alert type, but keeping it simple for visualization
        }
        if (alert.getAlertType() == Alert.AlertType.UPS_OVERLOAD || alert.getAlertType() == Alert.AlertType.LOW_BATTERY || alert.getAlertType() == Alert.AlertType.HUMIDITY) {
             barWidth = Math.min(actual.doubleValue(), 100.0); // Directly use % if it's already a percent
        }

        return "<html><body style='font-family: Arial, sans-serif; color: #333;'>"
             + "<h2 style='color: " + color + ";'>SPCMS Alert Notification</h2>"
             + "<p><strong>Alert Type:</strong> " + alert.getAlertType() + "</p>"
             + "<p><strong>Equipment:</strong> " + alert.getEquipmentType() + " (ID: " + alert.getEquipmentId() + ")</p>"
             + "<p><strong>Message:</strong> " + alert.getMessage() + "</p>"
             + "<div style='margin-top: 20px; padding: 15px; border: 1px solid #ccc; border-radius: 5px; background-color: #f9f9f9;'>"
             + "  <h3 style='margin-top: 0;'>Visual Indicator</h3>"
             + "  <div style='display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 14px;'>"
             + "    <span>Actual: " + actual + "</span>"
             + "    <span>Threshold: " + threshold + "</span>"
             + "  </div>"
             + "  <div style='width: 100%; background-color: #e0e0e0; border-radius: 4px; height: 24px; overflow: hidden;'>"
             + "    <div style='width: " + barWidth + "%; background-color: " + color + "; height: 100%;'></div>"
             + "  </div>"
             + "</div>"
             + "<p style='margin-top: 30px; font-size: 12px; color: #777;'>Sent from SmartPower & Cooling Management System</p>"
             + "</body></html>";
    }
}
