package com.spcms.services;

import com.spcms.models.Alert;
import com.spcms.repositories.AlertRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    // ==================== Email Notification ====================

    /**
     * Send email notification for an alert.
     * Placeholder implementation — configure SMTP in application.properties.
     */
    public void sendAlertEmail(Long alertId, String recipientEmail) {
        Alert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new RuntimeException("Alert not found: " + alertId));

        if (mailSender != null) {
            try {
                SimpleMailMessage mail = new SimpleMailMessage();
                mail.setTo(recipientEmail);
                mail.setSubject("[SPCMS ALERT] " + alert.getAlertType().name());
                mail.setText(alert.getMessage());
                mailSender.send(mail);

                alert.setIsSent(true);
                alertRepository.save(alert);
            } catch (Exception e) {
                // Log error but don't fail the transaction
                System.err.println("Failed to send alert email: " + e.getMessage());
            }
        } else {
            System.out.println("Mail sender not configured. Alert email skipped for alert: " + alertId);
        }
    }
}
