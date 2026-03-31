package com.spcms.dto.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyConsolidatedReportDto {
    private Long reportId;
    private LocalDate reportDate;
    private BigDecimal avgDailyLoad;
    private String batteryStatusSummary;
    private BigDecimal avgRoomTemperature;
    private BigDecimal highestTempRecorded;
    private BigDecimal mttrMinutes;
    private BigDecimal mtbfHours;
    private Integer totalDowntimeMin;
    private Integer totalIncidents;
}
