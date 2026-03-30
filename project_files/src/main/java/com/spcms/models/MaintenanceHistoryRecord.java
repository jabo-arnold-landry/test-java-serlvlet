package com.spcms.models;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MaintenanceHistoryRecord {

    private Long reportId;
    private String equipmentType;
    private Long equipmentId;
    private String equipmentName;
    private String assetId;

    private LocalDate maintenanceDate;
    private String maintenanceType;
    private String technicianName;
    private String workPerformed;
    private String description;
    private String status;
    private String remarks;
    private LocalDate nextScheduledMaintenance;

    private String vendor;
    private String serviceReportPath;
    private String partsOrMaterials;
    private LocalDate filterCleaningDate;
    private LocalDate gasRefillDate;
}