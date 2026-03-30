package com.spcms.dto;

import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MaintenanceHistoryRow {
    private String assetType;
    private String assetTag;
    private String assetName;
    private String maintenanceType;
    private LocalDate maintenanceDate;
    private LocalDate nextDueDate;
    private String technician;
    private String vendor;
    private String remarks;
}
