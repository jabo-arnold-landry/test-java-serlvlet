package com.spcms.models;

import java.math.BigDecimal;
import java.util.List;

public class SlaComplianceSummary {

    private final int windowDays;
    private final int reportsCount;
    private final BigDecimal availabilityCompliance;
    private final BigDecimal downtimeTrend;
    private final int totalDowntimeMinutes;
    private final BigDecimal allowedDowntimeMinutes;
    private final BigDecimal maxTemperature;
    private final int temperatureReadingsCount;
    private final long temperatureViolations;
    private final long incidentsEvaluated;
    private final long responseViolations;
    private final BigDecimal responseCompliance;
    private final int overdueMaintenanceCount;
    private final long compliantRuleCount;
    private final long violatedRuleCount;
    private final BigDecimal availabilityTargetPercent;
    private final BigDecimal temperatureTargetC;
    private final int responseTargetMinutes;
    private final int monthlyDowntimeTargetMinutes;
    private final List<SlaCheckResult> checks;

    public SlaComplianceSummary(int windowDays,
                                int reportsCount,
                                BigDecimal availabilityCompliance,
                                BigDecimal downtimeTrend,
                                int totalDowntimeMinutes,
                                BigDecimal allowedDowntimeMinutes,
                                BigDecimal maxTemperature,
                                int temperatureReadingsCount,
                                long temperatureViolations,
                                long incidentsEvaluated,
                                long responseViolations,
                                BigDecimal responseCompliance,
                                int overdueMaintenanceCount,
                                long compliantRuleCount,
                                long violatedRuleCount,
                                BigDecimal availabilityTargetPercent,
                                BigDecimal temperatureTargetC,
                                int responseTargetMinutes,
                                int monthlyDowntimeTargetMinutes,
                                List<SlaCheckResult> checks) {
        this.windowDays = windowDays;
        this.reportsCount = reportsCount;
        this.availabilityCompliance = availabilityCompliance;
        this.downtimeTrend = downtimeTrend;
        this.totalDowntimeMinutes = totalDowntimeMinutes;
        this.allowedDowntimeMinutes = allowedDowntimeMinutes;
        this.maxTemperature = maxTemperature;
        this.temperatureReadingsCount = temperatureReadingsCount;
        this.temperatureViolations = temperatureViolations;
        this.incidentsEvaluated = incidentsEvaluated;
        this.responseViolations = responseViolations;
        this.responseCompliance = responseCompliance;
        this.overdueMaintenanceCount = overdueMaintenanceCount;
        this.compliantRuleCount = compliantRuleCount;
        this.violatedRuleCount = violatedRuleCount;
        this.availabilityTargetPercent = availabilityTargetPercent;
        this.temperatureTargetC = temperatureTargetC;
        this.responseTargetMinutes = responseTargetMinutes;
        this.monthlyDowntimeTargetMinutes = monthlyDowntimeTargetMinutes;
        this.checks = checks;
    }

    public int getWindowDays() {
        return windowDays;
    }

    public int getReportsCount() {
        return reportsCount;
    }

    public BigDecimal getAvailabilityCompliance() {
        return availabilityCompliance;
    }

    public BigDecimal getDowntimeTrend() {
        return downtimeTrend;
    }

    public int getTotalDowntimeMinutes() {
        return totalDowntimeMinutes;
    }

    public BigDecimal getAllowedDowntimeMinutes() {
        return allowedDowntimeMinutes;
    }

    public BigDecimal getMaxTemperature() {
        return maxTemperature;
    }

    public int getTemperatureReadingsCount() {
        return temperatureReadingsCount;
    }

    public long getTemperatureViolations() {
        return temperatureViolations;
    }

    public long getIncidentsEvaluated() {
        return incidentsEvaluated;
    }

    public long getResponseViolations() {
        return responseViolations;
    }

    public BigDecimal getResponseCompliance() {
        return responseCompliance;
    }

    public int getOverdueMaintenanceCount() {
        return overdueMaintenanceCount;
    }

    public long getCompliantRuleCount() {
        return compliantRuleCount;
    }

    public long getViolatedRuleCount() {
        return violatedRuleCount;
    }

    public BigDecimal getAvailabilityTargetPercent() {
        return availabilityTargetPercent;
    }

    public BigDecimal getTemperatureTargetC() {
        return temperatureTargetC;
    }

    public int getResponseTargetMinutes() {
        return responseTargetMinutes;
    }

    public int getMonthlyDowntimeTargetMinutes() {
        return monthlyDowntimeTargetMinutes;
    }

    public List<SlaCheckResult> getChecks() {
        return checks;
    }
}
