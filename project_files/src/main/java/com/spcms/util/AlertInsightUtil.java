package com.spcms.util;

import com.spcms.models.Alert;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * Calculates warning intelligence (severity, SLA status, and recommendation)
 * without persisting any extra data.
 */
public final class AlertInsightUtil {

    private AlertInsightUtil() {
    }

    public static Map<Long, AlertInsight> buildInsights(List<Alert> alerts) {
        return buildInsights(alerts, LocalDateTime.now());
    }

    public static Map<Long, AlertInsight> buildInsights(List<Alert> alerts, LocalDateTime now) {
        if (alerts == null || alerts.isEmpty()) {
            return Collections.emptyMap();
        }

        List<Alert> safeAlerts = alerts.stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        Map<Long, AlertInsight> result = new HashMap<>();
        for (Alert alert : safeAlerts) {
            if (alert.getAlertId() == null) {
                continue;
            }

            long repeatIn24h = countRepeatsIn24Hours(alert, safeAlerts, now);
            int severityScore = calculateSeverityScore(alert, repeatIn24h, now);
            String severityLabel = resolveSeverityLabel(severityScore);
            int slaTargetMinutes = resolveSlaTargetMinutes(severityLabel);
            long openMinutes = calculateOpenMinutes(alert, now);
            boolean slaBreached = isUnacknowledged(alert) && openMinutes > slaTargetMinutes;
            String slaStatusText = resolveSlaStatusText(alert, openMinutes, slaTargetMinutes, slaBreached);
            String recommendation = buildRecommendation(alert, repeatIn24h, slaBreached);

            result.put(alert.getAlertId(), new AlertInsight(
                    severityScore,
                    severityLabel,
                    slaTargetMinutes,
                    slaBreached,
                    slaStatusText,
                    repeatIn24h,
                    recommendation
            ));
        }

        return result;
    }

    public static AlertInsight buildInsight(Alert alert, List<Alert> allAlerts, LocalDateTime now) {
        if (alert == null) {
            return AlertInsight.empty();
        }

        Map<Long, AlertInsight> insights = buildInsights(allAlerts, now);
        if (alert.getAlertId() != null && insights.containsKey(alert.getAlertId())) {
            return insights.get(alert.getAlertId());
        }

        long repeatIn24h = countRepeatsIn24Hours(alert, allAlerts == null ? Collections.emptyList() : allAlerts, now);
        int severityScore = calculateSeverityScore(alert, repeatIn24h, now);
        String severityLabel = resolveSeverityLabel(severityScore);
        int slaTargetMinutes = resolveSlaTargetMinutes(severityLabel);
        long openMinutes = calculateOpenMinutes(alert, now);
        boolean slaBreached = isUnacknowledged(alert) && openMinutes > slaTargetMinutes;

        return new AlertInsight(
                severityScore,
                severityLabel,
                slaTargetMinutes,
                slaBreached,
                resolveSlaStatusText(alert, openMinutes, slaTargetMinutes, slaBreached),
                repeatIn24h,
                buildRecommendation(alert, repeatIn24h, slaBreached)
        );
    }

    private static int calculateSeverityScore(Alert alert, long repeatIn24h, LocalDateTime now) {
        int score = baseScoreByType(alert != null ? alert.getAlertType() : null);

        BigDecimal actual = alert != null ? alert.getActualValue() : null;
        BigDecimal threshold = alert != null ? alert.getThresholdValue() : null;
        if (actual != null && threshold != null && threshold.compareTo(BigDecimal.ZERO) > 0) {
            double deviation = actual.subtract(threshold).abs().doubleValue();
            double breachPercent = (deviation / threshold.doubleValue()) * 100.0;
            score += (int) Math.min(20.0, breachPercent);
        }

        long openMinutes = calculateOpenMinutes(alert, now);
        if (openMinutes >= 60) {
            score += 5;
        }
        if (openMinutes >= 240) {
            score += 8;
        }
        if (openMinutes >= 720) {
            score += 7;
        }

        if (repeatIn24h >= 3) {
            score += 8;
        } else if (repeatIn24h == 2) {
            score += 4;
        }

        if (!isUnacknowledged(alert)) {
            score -= 10;
        }

        return Math.max(0, Math.min(100, score));
    }

    private static int baseScoreByType(Alert.AlertType type) {
        if (type == null) {
            return 45;
        }

        switch (type) {
            case EQUIPMENT_FAULT:
                return 85;
            case UPS_OVERLOAD:
                return 80;
            case HIGH_TEMP:
                return 75;
            case LOW_BATTERY:
                return 70;
            case HUMIDITY:
                return 62;
            case MAINTENANCE_DUE:
                return 55;
            default:
                return 50;
        }
    }

    private static String resolveSeverityLabel(int score) {
        if (score >= 85) {
            return "CRITICAL";
        }
        if (score >= 70) {
            return "HIGH";
        }
        if (score >= 50) {
            return "MEDIUM";
        }
        return "LOW";
    }

    private static int resolveSlaTargetMinutes(String severityLabel) {
        if ("CRITICAL".equals(severityLabel)) {
            return 10;
        }
        if ("HIGH".equals(severityLabel)) {
            return 30;
        }
        if ("MEDIUM".equals(severityLabel)) {
            return 120;
        }
        return 240;
    }

    private static String resolveSlaStatusText(Alert alert, long openMinutes, int targetMinutes, boolean breached) {
        if (!isUnacknowledged(alert)) {
            return "Acknowledged";
        }
        if (alert == null || alert.getCreatedAt() == null) {
            return "No timestamp";
        }
        if (breached) {
            return "Breached by " + formatDuration(openMinutes - targetMinutes);
        }
        return "Due in " + formatDuration(Math.max(0, targetMinutes - openMinutes));
    }

    private static String buildRecommendation(Alert alert, long repeatIn24h, boolean slaBreached) {
        String recommendation;

        Alert.AlertType type = alert != null ? alert.getAlertType() : null;
        if (type == Alert.AlertType.HIGH_TEMP) {
            recommendation = "Inspect cooling airflow and verify compressor/fan operation immediately.";
        } else if (type == Alert.AlertType.HUMIDITY) {
            recommendation = "Check humidity control setpoints and inspect cooling unit drain/filter condition.";
        } else if (type == Alert.AlertType.LOW_BATTERY) {
            recommendation = "Run UPS battery health test and schedule replacement for weak batteries.";
        } else if (type == Alert.AlertType.UPS_OVERLOAD) {
            recommendation = "Reduce UPS load by rebalancing connected equipment to alternate power paths.";
        } else if (type == Alert.AlertType.MAINTENANCE_DUE) {
            recommendation = "Complete the due preventive maintenance task and update the maintenance log.";
        } else {
            recommendation = "Investigate equipment fault details and assign a technician for corrective action.";
        }

        if (repeatIn24h >= 3) {
            recommendation += " Repeated " + repeatIn24h + " times in last 24h; escalate as recurring issue.";
        }
        if (slaBreached) {
            recommendation += " SLA breached; notify manager and prioritize immediate response.";
        }

        return recommendation;
    }

    private static long countRepeatsIn24Hours(Alert pivot, List<Alert> alerts, LocalDateTime now) {
        if (pivot == null || alerts == null || alerts.isEmpty()) {
            return 1;
        }

        LocalDateTime cutoff = now.minusHours(24);
        return alerts.stream()
                .filter(Objects::nonNull)
                .filter(a -> a.getAlertType() == pivot.getAlertType())
                .filter(a -> a.getEquipmentType() == pivot.getEquipmentType())
                .filter(a -> Objects.equals(a.getEquipmentId(), pivot.getEquipmentId()))
                .filter(a -> a.getCreatedAt() == null || !a.getCreatedAt().isBefore(cutoff))
                .count();
    }

    private static long calculateOpenMinutes(Alert alert, LocalDateTime now) {
        if (alert == null || alert.getCreatedAt() == null) {
            return 0;
        }
        return Math.max(0, Duration.between(alert.getCreatedAt(), now).toMinutes());
    }

    private static boolean isUnacknowledged(Alert alert) {
        return alert != null && !Boolean.TRUE.equals(alert.getIsAcknowledged());
    }

    private static String formatDuration(long minutes) {
        if (minutes < 60) {
            return minutes + "m";
        }
        long hours = minutes / 60;
        long remain = minutes % 60;
        return remain == 0 ? (hours + "h") : (hours + "h " + remain + "m");
    }

    public static final class AlertInsight {
        private final int severityScore;
        private final String severityLabel;
        private final int slaTargetMinutes;
        private final boolean slaBreached;
        private final String slaStatusText;
        private final long repeatCount24h;
        private final String recommendation;

        public AlertInsight(int severityScore,
                            String severityLabel,
                            int slaTargetMinutes,
                            boolean slaBreached,
                            String slaStatusText,
                            long repeatCount24h,
                            String recommendation) {
            this.severityScore = severityScore;
            this.severityLabel = severityLabel;
            this.slaTargetMinutes = slaTargetMinutes;
            this.slaBreached = slaBreached;
            this.slaStatusText = slaStatusText;
            this.repeatCount24h = repeatCount24h;
            this.recommendation = recommendation;
        }

        public static AlertInsight empty() {
            return new AlertInsight(0, "LOW", 240, false, "No timestamp", 1, "No recommendation available.");
        }

        public int getSeverityScore() {
            return severityScore;
        }

        public String getSeverityLabel() {
            return severityLabel;
        }

        public int getSlaTargetMinutes() {
            return slaTargetMinutes;
        }

        public boolean isSlaBreached() {
            return slaBreached;
        }

        public String getSlaStatusText() {
            return slaStatusText;
        }

        public long getRepeatCount24h() {
            return repeatCount24h;
        }

        public String getRecommendation() {
            return recommendation;
        }
    }
}
