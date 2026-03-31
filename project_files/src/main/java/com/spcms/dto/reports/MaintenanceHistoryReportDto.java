package com.spcms.dto.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MaintenanceHistoryReportDto {
    private String equipmentType;
    private Long maintenanceId;
    private Long equipmentId;
    private String equipmentName;
    private String maintenanceType;
    private LocalDate maintenanceDate;
    private LocalDate nextDueDate;
    private String technician;
    private String vendor;
    private String maintenanceStatus;
    private String remarks;
}
