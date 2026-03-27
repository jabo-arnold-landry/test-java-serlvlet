package com.spcms.services;

import com.spcms.models.Alert;
import com.spcms.models.User;
import com.spcms.repositories.AlertRepository;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.mail.internet.MimeMessage;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Alert & Notification Service.
 *
 * Handles alert creation, email notifications with graphics, and dashboard warnings
 * for: High Temperature, Low Battery, UPS Overload, Humidity,
 * Maintenance Due, and Equipment Faults.
 */
@Service
@Transactional(readOnly = true)
public class AlertService {

    @Autowired
    private AlertRepository alertRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${spcms.alerts.auto-send-email:true}")
    private boolean autoSendEmail;

    // Configurable thresholds (can be loaded from DB or config)
    private static BigDecimal HIGH_TEMP_THRESHOLD = new BigDecimal("28");
    private static BigDecimal HUMIDITY_HIGH_THRESHOLD = new BigDecimal("65");
    private static BigDecimal HUMIDITY_LOW_THRESHOLD = new BigDecimal("30");
    private static BigDecimal UPS_OVERLOAD_THRESHOLD = new BigDecimal("80");
    private static BigDecimal LOW_BATTERY_THRESHOLD = new BigDecimal("20");
    private static BigDecimal COOLING_HIGH_TEMP_THRESHOLD = new BigDecimal("25");
    private static int BATTERY_REPLACEMENT_WARNING_DAYS = 30;

    // Email recipients (comma-separated) - null means all users
    private static String EMAIL_RECIPIENTS = null;

    // ==================== Threshold Configuration ====================

    public Map<String, Object> getAlertThresholds() {
        Map<String, Object> thresholds = new HashMap<>();
        thresholds.put("upsHighTemp", HIGH_TEMP_THRESHOLD);
        thresholds.put("coolingHighTemp", COOLING_HIGH_TEMP_THRESHOLD);
        thresholds.put("humidityHigh", HUMIDITY_HIGH_THRESHOLD);
        thresholds.put("humidityLow", HUMIDITY_LOW_THRESHOLD);
        thresholds.put("upsOverload", UPS_OVERLOAD_THRESHOLD);
        thresholds.put("lowBattery", LOW_BATTERY_THRESHOLD);
        thresholds.put("batteryReplacementWarningDays", BATTERY_REPLACEMENT_WARNING_DAYS);
        thresholds.put("autoSendEmail", autoSendEmail);
        thresholds.put("emailRecipients", EMAIL_RECIPIENTS);
        return thresholds;
    }

    public void updateAlertThresholds(BigDecimal upsHighTemp, BigDecimal coolingHighTemp,
                                      BigDecimal humidityHigh, BigDecimal humidityLow,
                                      BigDecimal overload, BigDecimal lowBattery,
                                      int batteryReplacementWarningDays,
                                      boolean autoSend, String recipients) {
        HIGH_TEMP_THRESHOLD = upsHighTemp;
        COOLING_HIGH_TEMP_THRESHOLD = coolingHighTemp;
        HUMIDITY_HIGH_THRESHOLD = humidityHigh;
        HUMIDITY_LOW_THRESHOLD = humidityLow;
        UPS_OVERLOAD_THRESHOLD = overload;
        LOW_BATTERY_THRESHOLD = lowBattery;
        BATTERY_REPLACEMENT_WARNING_DAYS = batteryReplacementWarningDays;
        autoSendEmail = autoSend;
        EMAIL_RECIPIENTS = (recipients != null && !recipients.trim().isEmpty()) ? recipients.trim() : null;
    }

    public int getBatteryReplacementWarningDays() { return BATTERY_REPLACEMENT_WARNING_DAYS; }

    public BigDecimal getHighTempThreshold() { return HIGH_TEMP_THRESHOLD; }
    public BigDecimal getCoolingHighTempThreshold() { return COOLING_HIGH_TEMP_THRESHOLD; }
    public BigDecimal getHumidityHighThreshold() { return HUMIDITY_HIGH_THRESHOLD; }
    public BigDecimal getHumidityLowThreshold() { return HUMIDITY_LOW_THRESHOLD; }
    public BigDecimal getUpsOverloadThreshold() { return UPS_OVERLOAD_THRESHOLD; }
    public BigDecimal getLowBatteryThreshold() { return LOW_BATTERY_THRESHOLD; }

    // ==================== Auto-send to Admins & Managers ====================

    /**
     * Get all email addresses of active Admins and Managers for alert notifications.
     * If EMAIL_RECIPIENTS is set, use those instead.
     */
    public List<String> getAlertRecipientEmails() {
        // If specific recipients are configured, use them
        if (EMAIL_RECIPIENTS != null && !EMAIL_RECIPIENTS.isEmpty()) {
            return java.util.Arrays.stream(EMAIL_RECIPIENTS.split(","))
                    .map(String::trim)
                    .filter(e -> !e.isEmpty())
                    .collect(Collectors.toList());
        }

        // Otherwise, get all admins and managers
        List<User> admins = userRepository.findByRole(User.Role.ADMIN);
        List<User> managers = userRepository.findByRole(User.Role.MANAGER);

        java.util.ArrayList<User> recipients = new java.util.ArrayList<>();
        recipients.addAll(admins);
        recipients.addAll(managers);

        return recipients.stream()
                .filter(u -> u.isIsActive())  // Use the isIsActive() method from User
                .filter(u -> u.getEmail() != null && !u.getEmail().isEmpty())
                .map(User::getEmail)
                .collect(Collectors.toList());
    }

    /**
     * Send alert emails to all admins and managers asynchronously.
     */
    @Async
    public void sendAlertToAllRecipients(Alert alert) {
        if (!autoSendEmail) {
            System.out.println("Auto-send email disabled. Skipping email for alert: " + alert.getAlertId());
            return;
        }

        List<String> recipients = getAlertRecipientEmails();
        for (String email : recipients) {
            try {
                sendAlertEmail(alert.getAlertId(), email);
            } catch (Exception e) {
                System.err.println("Failed to send alert email to " + email + ": " + e.getMessage());
            }
        }
    }

    // ==================== Alert CRUD ====================

    @Transactional
    public Alert createAlert(Alert alert) {
        return alertRepository.save(alert);
    }

    @Transactional(readOnly = true)
    public Optional<Alert> getAlertById(Long id) {
        return alertRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public Optional<Alert> getLatestAlertAfter(Long afterId) {
        if (afterId != null) {
            return alertRepository.findFirstByAlertIdGreaterThanOrderByAlertIdDesc(afterId);
        }
        return alertRepository.findFirstByOrderByAlertIdDesc();
    }

    @Transactional(readOnly = true)
    public List<Alert> getAllAlerts() {
        return alertRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Alert> getUnsentAlerts() {
        return alertRepository.findByIsSentFalse();
    }

    @Transactional(readOnly = true)
    public List<Alert> getUnacknowledgedAlerts() {
        return alertRepository.findByIsAcknowledgedFalse();
    }

    @Transactional(readOnly = true)
    public long countUnacknowledgedAlerts() {
        return alertRepository.countByIsAcknowledgedFalse();
    }

    // ==================== Alert Generators ====================

    /**
     * Create a High Temperature alert for a UPS or Cooling unit.
     * Auto-sends email notification to all admins/managers.
     */
    public Alert createHighTempAlert(Alert.EquipmentCategory equipmentType,
                                     Long equipmentId, BigDecimal threshold, BigDecimal actual) {
        return createHighTempAlert(equipmentType, equipmentId, threshold, actual, true);
    }

    @Transactional
    public Alert createHighTempAlert(Alert.EquipmentCategory equipmentType,
                                     Long equipmentId, BigDecimal threshold, BigDecimal actual,
                                     boolean notifyAll) {
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
        Alert saved = alertRepository.save(alert);
        if (notifyAll) {
            sendAlertToAllRecipients(saved);
        }
        return saved;
    }
    /**
     * Create a Low Battery alert for a UPS unit.
     * Auto-sends email notification to all admins/managers.
     */
    public Alert createLowBatteryAlert(Long upsId, BigDecimal threshold, BigDecimal actual) {
        return createLowBatteryAlert(upsId, threshold, actual, true);
    }

    @Transactional
    public Alert createLowBatteryAlert(Long upsId, BigDecimal threshold, BigDecimal actual, boolean notifyAll) {
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
        Alert saved = alertRepository.save(alert);
        if (notifyAll) {
            sendAlertToAllRecipients(saved);
        }
        return saved;
    }
    /**
     * Create a UPS Overload alert.
     * Auto-sends email notification to all admins/managers.
     */
    public Alert createOverloadAlert(Long upsId, BigDecimal threshold, BigDecimal actual) {
        return createOverloadAlert(upsId, threshold, actual, true);
    }

    @Transactional
    public Alert createOverloadAlert(Long upsId, BigDecimal threshold, BigDecimal actual, boolean notifyAll) {
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
        Alert saved = alertRepository.save(alert);
        if (notifyAll) {
            sendAlertToAllRecipients(saved);
        }
        return saved;
    }
    /**
     * Create a Maintenance Due alert.
     */
    public Alert createMaintenanceDueAlert(Alert.EquipmentCategory type, Long equipmentId, String message) {
        return createMaintenanceDueAlert(type, equipmentId, message, true);
    }

    @Transactional
    public Alert createMaintenanceDueAlert(Alert.EquipmentCategory type, Long equipmentId, String message, boolean notifyAll) {
        Alert alert = Alert.builder()
                .alertType(Alert.AlertType.MAINTENANCE_DUE)
                .equipmentType(type)
                .equipmentId(equipmentId)
                .message("MAINTENANCE DUE: " + message)
                .isSent(false)
                .isAcknowledged(false)
                .build();
        Alert saved = alertRepository.save(alert);
        if (notifyAll) {
            sendAlertToAllRecipients(saved);
        }
        return saved;
    }
// ==================== Acknowledgment ====================

    @Transactional
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
     * Auto-sends email notification to all admins/managers.
     */
    public Alert createHumidityAlert(Alert.EquipmentCategory equipmentType,
                                     Long equipmentId, BigDecimal threshold, BigDecimal actual, String direction) {
        return createHumidityAlert(equipmentType, equipmentId, threshold, actual, direction, true);
    }

    @Transactional
    public Alert createHumidityAlert(Alert.EquipmentCategory equipmentType,
                                     Long equipmentId, BigDecimal threshold, BigDecimal actual, String direction,
                                     boolean notifyAll) {
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
        Alert saved = alertRepository.save(alert);
        if (notifyAll) {
            sendAlertToAllRecipients(saved); // Auto-send email
        }
        return saved;
    }

    // ==================== Email Notification ====================

    /**
     * Send email notification for an alert using HTML templates.
     */
    @Transactional
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
        BigDecimal actual = alert.getActualValue() != null ? alert.getActualValue() : BigDecimal.ZERO;
        BigDecimal threshold = alert.getThresholdValue() != null ? alert.getThresholdValue() : BigDecimal.ZERO;

        // Determine colors and icons based on alert type
        String primaryColor, bgColor, icon, unit, maxValue;
        switch (alert.getAlertType()) {
            case HIGH_TEMP:
                primaryColor = "#ef4444"; bgColor = "#fef2f2"; icon = "🌡️"; unit = "°C"; maxValue = "50";
                break;
            case HUMIDITY:
                primaryColor = "#3b82f6"; bgColor = "#eff6ff"; icon = "💧"; unit = "%"; maxValue = "100";
                break;
            case LOW_BATTERY:
                primaryColor = "#f59e0b"; bgColor = "#fffbeb"; icon = "🔋"; unit = "%"; maxValue = "100";
                break;
            case UPS_OVERLOAD:
                primaryColor = "#ef4444"; bgColor = "#fef2f2"; icon = "⚡"; unit = "%"; maxValue = "100";
                break;
            default:
                primaryColor = "#ef4444"; bgColor = "#fef2f2"; icon = "⚠️"; unit = ""; maxValue = "100";
        }

        // Calculate bar width percentage
        double barWidthPercent = Math.min((actual.doubleValue() / Double.parseDouble(maxValue)) * 100, 100);
        double thresholdPosition = (threshold.doubleValue() / Double.parseDouble(maxValue)) * 100;

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        return "<!DOCTYPE html>"
                + "<html><head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;font-family:Inter,Arial,sans-serif;background-color:#f0f2f5;'>"
                + "<div style='max-width:600px;margin:0 auto;padding:20px;'>"
                // Header
                + "  <div style='background:linear-gradient(135deg,#1a1d23,#2d3139);border-radius:12px 12px 0 0;padding:30px;text-align:center;'>"
                + "    <h1 style='color:#fff;margin:0;font-size:24px;'>⚡ SPCMS Alert</h1>"
                + "    <p style='color:rgba(255,255,255,0.7);margin:10px 0 0;font-size:14px;'>SmartPower & Cooling Management System</p>"
                + "  </div>"
                // Alert Type Badge
                + "  <div style='background:" + bgColor + ";padding:20px;text-align:center;border-left:1px solid #e5e7eb;border-right:1px solid #e5e7eb;'>"
                + "    <span style='display:inline-block;background:" + primaryColor + ";color:#fff;padding:10px 25px;border-radius:25px;font-weight:600;font-size:16px;'>"
                + icon + " " + alert.getAlertType().name().replace("_", " ") + "</span>"
                + "  </div>"
                // Main Content
                + "  <div style='background:#fff;padding:30px;border:1px solid #e5e7eb;'>"
                // Equipment Info
                + "    <div style='margin-bottom:25px;'>"
                + "      <p style='margin:0 0 8px;color:#6b7280;font-size:13px;text-transform:uppercase;letter-spacing:1px;'>Equipment</p>"
                + "      <p style='margin:0;font-size:18px;font-weight:600;color:#1a1d23;'>" + alert.getEquipmentType() + " (ID: " + alert.getEquipmentId() + ")</p>"
                + "    </div>"
                // Message
                + "    <div style='background:#f9fafb;border-radius:8px;padding:15px;margin-bottom:25px;border-left:4px solid " + primaryColor + ";'>"
                + "      <p style='margin:0;color:#1a1d23;font-size:14px;'>" + alert.getMessage() + "</p>"
                + "    </div>"
                // Graphical Indicator
                + "    <div style='margin-bottom:25px;'>"
                + "      <p style='margin:0 0 15px;color:#6b7280;font-size:13px;text-transform:uppercase;letter-spacing:1px;'>Visual Indicator</p>"
                // Values Row
                + "      <div style='display:flex;justify-content:space-between;margin-bottom:15px;'>"
                + "        <div style='text-align:center;'>"
                + "          <p style='margin:0;color:#6b7280;font-size:12px;'>Actual</p>"
                + "          <p style='margin:5px 0 0;font-size:28px;font-weight:700;color:" + primaryColor + ";'>" + actual + "<span style='font-size:14px;'>" + unit + "</span></p>"
                + "        </div>"
                + "        <div style='text-align:center;'>"
                + "          <p style='margin:0;color:#6b7280;font-size:12px;'>Threshold</p>"
                + "          <p style='margin:5px 0 0;font-size:28px;font-weight:700;color:#1a1d23;'>" + threshold + "<span style='font-size:14px;'>" + unit + "</span></p>"
                + "        </div>"
                + "        <div style='text-align:center;'>"
                + "          <p style='margin:0;color:#6b7280;font-size:12px;'>Deviation</p>"
                + "          <p style='margin:5px 0 0;font-size:28px;font-weight:700;color:" + primaryColor + ";'>+" + actual.subtract(threshold) + "<span style='font-size:14px;'>" + unit + "</span></p>"
                + "        </div>"
                + "      </div>"
                // Progress Bar
                + "      <div style='position:relative;height:30px;background:#e5e7eb;border-radius:8px;overflow:hidden;'>"
                + "        <div style='position:absolute;left:0;top:0;height:100%;width:" + barWidthPercent + "%;background:" + primaryColor + ";border-radius:8px;'></div>"
                + "        <div style='position:absolute;left:" + thresholdPosition + "%;top:0;height:100%;width:3px;background:#1a1d23;'></div>"
                + "      </div>"
                + "      <div style='display:flex;justify-content:space-between;margin-top:5px;font-size:11px;color:#6b7280;'>"
                + "        <span>0</span><span>Threshold: " + threshold + unit + "</span><span>" + maxValue + "</span>"
                + "      </div>"
                + "    </div>"
                // Action Required
                + "    <div style='background:#fef2f2;border:1px solid #fecaca;border-radius:8px;padding:15px;text-align:center;'>"
                + "      <p style='margin:0;color:#dc2626;font-weight:600;'>⚠️ Immediate Action Required</p>"
                + "      <p style='margin:8px 0 0;color:#7f1d1d;font-size:13px;'>Please investigate and acknowledge this alert in the SPCMS dashboard.</p>"
                + "    </div>"
                + "  </div>"
                // Footer
                + "  <div style='background:#f9fafb;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;padding:20px;text-align:center;'>"
                + "    <p style='margin:0;color:#6b7280;font-size:12px;'>Sent at " + timestamp + "</p>"
                + "    <p style='margin:8px 0 0;color:#9ca3af;font-size:11px;'>SmartPower & Cooling Management System</p>"
                + "  </div>"
                + "</div>"
                + "</body></html>";
    }

    /**
     * Create humidity alert with boolean isHigh parameter.
     */
    public Alert createHumidityAlert(Alert.EquipmentCategory equipmentType,
                                     Long equipmentId, BigDecimal threshold, BigDecimal actual, boolean isHigh) {
        return createHumidityAlert(equipmentType, equipmentId, threshold, actual, isHigh, true);
    }

    @Transactional
    public Alert createHumidityAlert(Alert.EquipmentCategory equipmentType,
                                     Long equipmentId, BigDecimal threshold, BigDecimal actual, boolean isHigh,
                                     boolean notifyAll) {
        String direction = isHigh ? "above" : "below";
        return createHumidityAlert(equipmentType, equipmentId, threshold, actual, direction, notifyAll);
    }

    public Alert createHumidityAlertWithRange(Alert.EquipmentCategory equipmentType,
                                              Long equipmentId,
                                              BigDecimal lowThreshold,
                                              BigDecimal highThreshold,
                                              BigDecimal actual,
                                              boolean notifyAll) {
        boolean isHighViolation = actual != null && highThreshold != null && actual.compareTo(highThreshold) > 0;
        BigDecimal breachedThreshold = isHighViolation ? highThreshold : lowThreshold;
        return createHumidityAlert(equipmentType, equipmentId, breachedThreshold, actual, isHighViolation, notifyAll);
    }

    /**
     * Send a test email to verify email configuration.
     */
    public void sendTestEmail(String recipientEmail) {
        if (mailSender == null) {
            throw new RuntimeException("Email service not configured. Please set up SMTP in application.properties");
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(recipientEmail);
            helper.setSubject("✅ SPCMS Alert System - Test Email");

            String html = "<!DOCTYPE html><html><body style='font-family:Inter,Arial,sans-serif;'>"
                    + "<div style='max-width:500px;margin:0 auto;padding:30px;'>"
                    + "  <div style='background:linear-gradient(135deg,#3b82f6,#8b5cf6);border-radius:12px 12px 0 0;padding:30px;text-align:center;'>"
                    + "    <h1 style='color:#fff;margin:0;font-size:24px;'>✅ Email Configuration Working!</h1>"
                    + "  </div>"
                    + "  <div style='background:#fff;border:1px solid #e5e7eb;border-top:none;padding:30px;'>"
                    + "    <p style='color:#374151;font-size:16px;line-height:1.6;'>This is a test email from the <strong>SPCMS Alert System</strong>.</p>"
                    + "    <p style='color:#374151;font-size:16px;line-height:1.6;'>If you received this email, your email notifications are properly configured.</p>"
                    + "    <div style='background:#ecfdf5;border:1px solid #a7f3d0;border-radius:8px;padding:15px;margin-top:20px;'>"
                    + "      <p style='margin:0;color:#065f46;font-weight:600;'>🎉 You're all set!</p>"
                    + "      <p style='margin:8px 0 0;color:#047857;font-size:14px;'>Alert emails will be sent to this address when thresholds are exceeded.</p>"
                    + "    </div>"
                    + "  </div>"
                    + "  <div style='background:#f9fafb;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;padding:20px;text-align:center;'>"
                    + "    <p style='margin:0;color:#6b7280;font-size:12px;'>SmartPower & Cooling Management System</p>"
                    + "  </div>"
                    + "</div>"
                    + "</body></html>";

            helper.setText(html, true);
            mailSender.send(message);

        } catch (Exception e) {
            throw new RuntimeException("Failed to send test email: " + e.getMessage(), e);
        }
    }

    /**
     * Send a standalone notification email without creating a DB alert record.
     * Used by the "Notify" button on the simulation console.
     */
    public void sendStandaloneNotificationEmail(String alertTypeName, String message, String recipientEmail) {
        if (mailSender == null) {
            System.out.println("Mail sender not configured. Standalone email skipped.");
            return;
        }
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setTo(recipientEmail);
            helper.setSubject("[SPCMS NOTIFICATION] " + alertTypeName);

            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
                    + "<body style='margin:0;padding:0;font-family:Inter,Arial,sans-serif;background:#f0f2f5;'>"
                    + "<div style='max-width:600px;margin:0 auto;padding:20px;'>"
                    + "  <div style='background:linear-gradient(135deg,#1a1d23,#2d3139);border-radius:12px 12px 0 0;padding:30px;text-align:center;'>"
                    + "    <h1 style='color:#fff;margin:0;font-size:24px;'>\u26A1 SPCMS Notification</h1>"
                    + "    <p style='color:rgba(255,255,255,0.7);margin:10px 0 0;font-size:14px;'>SmartPower & Cooling Management System</p>"
                    + "  </div>"
                    + "  <div style='background:#fff;padding:30px;border:1px solid #e5e7eb;'>"
                    + "    <div style='background:#eff6ff;border:1px solid #bfdbfe;border-radius:8px;padding:15px;margin-bottom:20px;border-left:4px solid #3b82f6;'>"
                    + "      <p style='margin:0;font-weight:600;color:#1e40af;'>" + alertTypeName + "</p>"
                    + "    </div>"
                    + "    <p style='color:#374151;font-size:15px;line-height:1.6;'>" + message + "</p>"
                    + "    <p style='color:#6b7280;font-size:13px;margin-top:20px;'>This is a notification email. No alert record was created in the system.</p>"
                    + "  </div>"
                    + "  <div style='background:#f9fafb;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;padding:20px;text-align:center;'>"
                    + "    <p style='margin:0;color:#6b7280;font-size:12px;'>Sent at " + timestamp + "</p>"
                    + "  </div>"
                    + "</div></body></html>";

            helper.setText(html, true);
            mailSender.send(mimeMessage);
        } catch (Exception e) {
            throw new RuntimeException("Failed to send notification email: " + e.getMessage(), e);
        }
    }
}




