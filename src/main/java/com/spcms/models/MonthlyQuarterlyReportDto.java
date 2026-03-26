package com.spcms.models;

import lombok.*;

import java.math.BigDecimal;

/**
 * Data Transfer Object for Quarterly and Monthly aggregated reports.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MonthlyQuarterlyReportDto {

    private String periodName; // e.g., "January 2026", "Q1 2026"

    private BigDecimal avgDailyLoad;
    private Integer totalUpsAlarms;

    private BigDecimal avgRoomTemperature;
    private BigDecimal highestTempRecorded;

    private Integer totalIncidents;
    private Integer totalDowntimeMin;

    private BigDecimal mttrMinutes;
    private BigDecimal mtbfHours;

    private Integer totalVisitors;
}
