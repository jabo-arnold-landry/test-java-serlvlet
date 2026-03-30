package com.spcms.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Report Calculation Utility.
 * 
 * Provides static methods for calculating key metrics used in
 * Daily and Shift Reports as per the business model requirements.
 */
public final class ReportCalculationUtil {

    private ReportCalculationUtil() {
        // Utility class - no instantiation
    }

    /**
     * Calculate Mean Time To Repair (MTTR).
     * MTTR = Total Downtime / Number of Incidents
     *
     * @param totalDowntimeMinutes total downtime in minutes during the period
     * @param numberOfIncidents    number of incidents in the period
     * @return MTTR in minutes, or 0 if no incidents
     */
    public static BigDecimal calculateMTTR(int totalDowntimeMinutes, int numberOfIncidents) {
        if (numberOfIncidents == 0) {
            return BigDecimal.ZERO;
        }
        return BigDecimal.valueOf(totalDowntimeMinutes)
                .divide(BigDecimal.valueOf(numberOfIncidents), 2, RoundingMode.HALF_UP);
    }

    /**
     * Calculate Mean Time Between Failures (MTBF).
     * MTBF = (Total Operational Time - Total Downtime) / Number of Failures
     *
     * @param totalOperationalHours total operational hours in the period (e.g., 24 for daily)
     * @param totalDowntimeMinutes  total downtime in minutes
     * @param numberOfFailures      number of failures/incidents
     * @return MTBF in hours, or the full operational time if no failures
     */
    public static BigDecimal calculateMTBF(double totalOperationalHours, int totalDowntimeMinutes,
                                            int numberOfFailures) {
        if (numberOfFailures == 0) {
            return BigDecimal.valueOf(totalOperationalHours).setScale(2, RoundingMode.HALF_UP);
        }
        double downtimeHours = totalDowntimeMinutes / 60.0;
        double operationalTime = totalOperationalHours - downtimeHours;
        return BigDecimal.valueOf(operationalTime / numberOfFailures)
                .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Calculate daily average load percentage.
     *
     * @param loadReadings list of load percentage readings during the day
     * @return average load percentage, or 0 if no readings
     */
    public static BigDecimal calculateDailyAverageLoad(List<BigDecimal> loadReadings) {
        if (loadReadings == null || loadReadings.isEmpty()) {
            return BigDecimal.ZERO;
        }
        BigDecimal sum = loadReadings.stream()
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return sum.divide(BigDecimal.valueOf(loadReadings.size()), 2, RoundingMode.HALF_UP);
    }

    /**
     * Calculate downtime trend (percentage change between two periods).
     *
     * @param previousDowntime downtime in previous period (minutes)
     * @param currentDowntime  downtime in current period (minutes)
     * @return percentage change (positive = increased, negative = decreased)
     */
    public static BigDecimal calculateDowntimeTrend(int previousDowntime, int currentDowntime) {
        if (previousDowntime == 0) {
            if (currentDowntime == 0) return BigDecimal.ZERO;
            return BigDecimal.valueOf(100); // 100% increase from 0
        }
        double change = ((double) (currentDowntime - previousDowntime) / previousDowntime) * 100;
        return BigDecimal.valueOf(change).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Calculate average temperature from a list of readings.
     *
     * @param temperatures list of temperature readings
     * @return average temperature, or 0 if no readings
     */
    public static BigDecimal calculateAverageTemperature(List<BigDecimal> temperatures) {
        if (temperatures == null || temperatures.isEmpty()) {
            return BigDecimal.ZERO;
        }
        BigDecimal sum = temperatures.stream()
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return sum.divide(BigDecimal.valueOf(temperatures.size()), 2, RoundingMode.HALF_UP);
    }

    /**
     * Find the maximum value in a list of readings.
     */
    public static BigDecimal findMax(List<BigDecimal> values) {
        if (values == null || values.isEmpty()) return BigDecimal.ZERO;
        return values.stream().max(BigDecimal::compareTo).orElse(BigDecimal.ZERO);
    }

    /**
     * Find the minimum value in a list of readings.
     */
    public static BigDecimal findMin(List<BigDecimal> values) {
        if (values == null || values.isEmpty()) return BigDecimal.ZERO;
        return values.stream().min(BigDecimal::compareTo).orElse(BigDecimal.ZERO);
    }
}
