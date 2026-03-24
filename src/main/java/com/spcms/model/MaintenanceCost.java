package com.spcms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class MaintenanceCost implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long costId;
    private Long upsMaintenanceId;
    private Long coolingMaintenanceId;
    private String equipmentType;
    private BigDecimal partsCost;
    private BigDecimal laborCost;
    private BigDecimal vendorCharge;
    private BigDecimal batteryReplacementCost;
    private BigDecimal gasRefillCost;
    private BigDecimal totalCost;
    private LocalDate costDate;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public MaintenanceCost() {
        this.partsCost = BigDecimal.ZERO;
        this.laborCost = BigDecimal.ZERO;
        this.vendorCharge = BigDecimal.ZERO;
        this.batteryReplacementCost = BigDecimal.ZERO;
        this.gasRefillCost = BigDecimal.ZERO;
    }

    public Long getCostId() {
        return costId;
    }

    public void setCostId(Long costId) {
        this.costId = costId;
    }

    public Long getUpsMaintenanceId() {
        return upsMaintenanceId;
    }

    public void setUpsMaintenanceId(Long upsMaintenanceId) {
        this.upsMaintenanceId = upsMaintenanceId;
    }

    public Long getCoolingMaintenanceId() {
        return coolingMaintenanceId;
    }

    public void setCoolingMaintenanceId(Long coolingMaintenanceId) {
        this.coolingMaintenanceId = coolingMaintenanceId;
    }

    public String getEquipmentType() {
        return equipmentType;
    }

    public void setEquipmentType(String equipmentType) {
        this.equipmentType = equipmentType;
    }

    public BigDecimal getPartsCost() {
        return partsCost;
    }

    public void setPartsCost(BigDecimal partsCost) {
        this.partsCost = partsCost;
    }

    public BigDecimal getLaborCost() {
        return laborCost;
    }

    public void setLaborCost(BigDecimal laborCost) {
        this.laborCost = laborCost;
    }

    public BigDecimal getVendorCharge() {
        return vendorCharge;
    }

    public void setVendorCharge(BigDecimal vendorCharge) {
        this.vendorCharge = vendorCharge;
    }

    public BigDecimal getBatteryReplacementCost() {
        return batteryReplacementCost;
    }

    public void setBatteryReplacementCost(BigDecimal batteryReplacementCost) {
        this.batteryReplacementCost = batteryReplacementCost;
    }

    public BigDecimal getGasRefillCost() {
        return gasRefillCost;
    }

    public void setGasRefillCost(BigDecimal gasRefillCost) {
        this.gasRefillCost = gasRefillCost;
    }

    public BigDecimal getTotalCost() {
        return partsCost.add(laborCost).add(vendorCharge).add(batteryReplacementCost).add(gasRefillCost);
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    public LocalDate getCostDate() {
        return costDate;
    }

    public void setCostDate(LocalDate costDate) {
        this.costDate = costDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}