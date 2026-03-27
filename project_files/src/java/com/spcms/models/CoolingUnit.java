package com.spcms.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "cooling_unit")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class CoolingUnit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cooling_id")
    private Long coolingId;

    @NotBlank
    @Column(name = "asset_tag", nullable = false, unique = true, length = 50)
    private String assetTag;

    @NotBlank
    @Column(name = "unit_name", nullable = false, length = 100)
    private String unitName;

    @Column(length = 50)
    private String brand;

    @Column(length = 50)
    private String model;

    @Column(name = "serial_number", unique = true, length = 100)
    private String serialNumber;

    @Column(name = "cooling_capacity_kw", precision = 10, scale = 2)
    private BigDecimal coolingCapacityKw;

    @Column(name = "installation_date")
    private LocalDate installationDate;

    @Column(name = "location_zone", length = 100)
    private String locationZone;

    @Column(name = "location_room", length = 100)
    private String locationRoom;

    @Convert(converter = CoolingStatusConverter.class)
    @Column(length = 25)
    private CoolingStatus status = CoolingStatus.ACTIVE;

    // === Environmental Monitoring Parameters ===

    @Column(name = "return_air_temp", precision = 5, scale = 2)
    private BigDecimal returnAirTemp;

    @Column(name = "supply_air_temp", precision = 5, scale = 2)
    private BigDecimal supplyAirTemp;

    @Column(name = "room_temperature", precision = 5, scale = 2)
    private BigDecimal roomTemperature;

    @Column(name = "humidity_percent", precision = 5, scale = 2)
    private BigDecimal humidityPercent;

    @Column(name = "set_temperature", precision = 5, scale = 2)
    private BigDecimal setTemperature;

    @Column(name = "set_humidity", precision = 5, scale = 2)
    private BigDecimal setHumidity;

    @Column(name = "airflow_status", length = 50)
    private String airflowStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "cooling_mode", length = 10)
    private CoolingMode coolingMode = CoolingMode.AUTO;

    @Column(name = "fan_speed", length = 50)
    private String fanSpeed;

    @Enumerated(EnumType.STRING)
    @Column(name = "compressor_status", length = 10)
    private CompressorStatus compressorStatus = CompressorStatus.STOPPED;

    // === Electrical & Mechanical Parameters ===

    @Column(name = "input_voltage", precision = 10, scale = 2)
    private BigDecimal inputVoltage;

    @Column(name = "current_amps", precision = 10, scale = 2)
    private BigDecimal currentAmps;

    @Column(name = "power_consumption", precision = 10, scale = 2)
    private BigDecimal powerConsumption;

    @Column(name = "refrigerant_pressure", precision = 10, scale = 2)
    private BigDecimal refrigerantPressure;

    @Column(name = "refrigerant_type", length = 50)
    private String refrigerantType;

    @Enumerated(EnumType.STRING)
    @Column(name = "filter_status", length = 25)
    private FilterStatus filterStatus = FilterStatus.CLEAN;

    @Enumerated(EnumType.STRING)
    @Column(name = "drain_status", length = 10)
    private DrainStatus drainStatus = DrainStatus.CLEAR;

    // === Relationships ===

    @OneToMany(mappedBy = "coolingUnit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<CoolingAlarmLog> alarmLogs;

    @OneToMany(mappedBy = "coolingUnit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<CoolingMaintenance> maintenanceRecords;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // === Enums ===

    public enum CoolingStatus {
        ACTIVE, FAULTY, UNDER_MAINTENANCE, DECOMMISSIONED
    }

    public enum CoolingMode {
        AUTO, MANUAL
    }

    public enum CompressorStatus {
        RUNNING, STOPPED
    }

    public enum FilterStatus {
        CLEAN, DIRTY, NEEDS_REPLACEMENT
    }

    public enum DrainStatus {
        CLEAR, BLOCKED
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

    public static class CoolingStatusConverter implements AttributeConverter<CoolingStatus, String> {
        @Override
        public String convertToDatabaseColumn(CoolingStatus attribute) {
            return attribute == null ? null : attribute.name();
        }

        @Override
        public CoolingStatus convertToEntityAttribute(String dbData) {
            if (dbData == null || dbData.trim().isEmpty()) {
                return null;
            }
            try {
                return CoolingStatus.valueOf(dbData.trim().toUpperCase());
            } catch (IllegalArgumentException e) {
                return CoolingStatus.ACTIVE; // Fallback for invalid DB string
            }
        }
    }
}
