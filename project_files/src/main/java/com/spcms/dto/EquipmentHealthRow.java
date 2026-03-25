package com.spcms.dto;

import com.spcms.models.Equipment;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class EquipmentHealthRow {
    private Equipment equipment;
    private String healthStatus;
    private boolean maintenanceOverdue;
    private boolean warrantyExpired;
    private boolean warrantyExpiring;
    private boolean endOfLife;
    private boolean endOfLifeSoon;
    private long incidentsLast30Days;
    private Long daysToMaintenanceDue;
    private Long daysToWarrantyExpiry;
    private Long daysToEndOfLife;
}
