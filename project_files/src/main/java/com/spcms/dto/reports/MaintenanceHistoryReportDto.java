package com.spcms.dto.reports;

import lombok.*;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
