package com.spcms.dto.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EquipmentHealthReportDto {
    private String equipmentType;
    private Long equipmentId;
    private String equipmentName;
    private String assetTag;
    private String location;
    private Double loadPercentage;
    private String batteryHealthStatus;
    private Integer estimatedRuntimeMin;
    private Double roomTemperature;
    private Double humidityPercent;
    private String compressorStatus;
    private String equipmentStatus;
    private String healthStatus;
    private Integer incidentCount;
    private Boolean highRisk;
}
