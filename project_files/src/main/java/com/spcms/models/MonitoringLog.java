package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import org.springframework.format.annotation.DateTimeFormat;

@Entity
@Table(name = "monitoring_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MonitoringLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Long logId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EquipmentType equipmentType;

    @Column(name = "equipment_id")
    private Long equipmentId;

    @Column(name = "temperature")
    private BigDecimal temperature;

    @Column(name = "humidity")
    private BigDecimal humidity;

    @Column(name = "battery_level")
    private BigDecimal batteryLevel;

    @Column(name = "load_percentage")
    private BigDecimal loadPercentage;

    @Column(name = "status")
    private String status;

    @Column(name = "return_air_temp")
    private BigDecimal returnAirTemp;

    @Column(name = "supply_air_temp")
    private BigDecimal supplyAirTemp;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "reading_time")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime readingTime;

    @Column(columnDefinition = "TEXT")
    private String notes;

    public enum EquipmentType {
        UPS, COOLING
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Explicit Getter and Setter Methods
    public Long getLogId() {
        return logId;
    }

    public void setLogId(Long logId) {
        this.logId = logId;
    }

    public EquipmentType getEquipmentType() {
        return equipmentType;
    }

    public void setEquipmentType(EquipmentType equipmentType) {
        this.equipmentType = equipmentType;
    }

    public Long getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(Long equipmentId) {
        this.equipmentId = equipmentId;
    }

    public BigDecimal getTemperature() {
        return temperature;
    }

    public void setTemperature(BigDecimal temperature) {
        this.temperature = temperature;
    }

    public BigDecimal getHumidity() {
        return humidity;
    }

    public void setHumidity(BigDecimal humidity) {
        this.humidity = humidity;
    }

    public BigDecimal getBatteryLevel() {
        return batteryLevel;
    }

    public void setBatteryLevel(BigDecimal batteryLevel) {
        this.batteryLevel = batteryLevel;
    }

    public BigDecimal getLoadPercentage() {
        return loadPercentage;
    }

    public void setLoadPercentage(BigDecimal loadPercentage) {
        this.loadPercentage = loadPercentage;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    // Additional getter methods
    public BigDecimal getHumidityPercent() {
        return humidity;
    }

    public void setHumidityPercent(BigDecimal humidity) {
        this.humidity = humidity;
    }

    public BigDecimal getReturnAirTemp() {
        return returnAirTemp;
    }

    public void setReturnAirTemp(BigDecimal returnAirTemp) {
        this.returnAirTemp = returnAirTemp;
    }

    public BigDecimal getSupplyAirTemp() {
        return supplyAirTemp;
    }

    public void setSupplyAirTemp(BigDecimal supplyAirTemp) {
        this.supplyAirTemp = supplyAirTemp;
    }
}
