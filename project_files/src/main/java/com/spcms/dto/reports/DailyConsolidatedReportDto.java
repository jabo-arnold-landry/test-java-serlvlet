package com.spcms.dto.reports;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
