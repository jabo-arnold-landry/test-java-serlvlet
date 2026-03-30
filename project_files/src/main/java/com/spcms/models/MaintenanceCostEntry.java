package com.spcms.models;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "maintenance_costs")
public class MaintenanceCostEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cost_id")
    private Long costId;

    @Column(name = "maintenance_id", nullable = false)
    private Long maintenanceId;

    @Enumerated(EnumType.STRING)
    @Column(name = "equipment_type", nullable = false, length = 10)
    private EquipmentType equipmentType;

    @Column(name = "cost_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal costAmount;

    @Column(name = "cost_description", columnDefinition = "TEXT")
    private String costDescription;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;

    public enum EquipmentType {
        UPS, COOLING
    }

    @PrePersist
    protected void onCreate() {
        if (recordedAt == null) {
            recordedAt = LocalDateTime.now();
        }
    }

    // === Getters & Setters ===

    public Long getCostId() { return costId; }
    public void setCostId(Long costId) { this.costId = costId; }

    public Long getMaintenanceId() { return maintenanceId; }
    public void setMaintenanceId(Long maintenanceId) { this.maintenanceId = maintenanceId; }

    public EquipmentType getEquipmentType() { return equipmentType; }
    public void setEquipmentType(EquipmentType equipmentType) { this.equipmentType = equipmentType; }

    public BigDecimal getCostAmount() { return costAmount; }
    public void setCostAmount(BigDecimal costAmount) { this.costAmount = costAmount; }

    public String getCostDescription() { return costDescription; }
    public void setCostDescription(String costDescription) { this.costDescription = costDescription; }

    public LocalDateTime getRecordedAt() { return recordedAt; }
    public void setRecordedAt(LocalDateTime recordedAt) { this.recordedAt = recordedAt; }
}
