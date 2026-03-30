package com.spcms.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "ups")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Ups {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ups_id")
    private Long upsId;

    @NotBlank
    @Column(name = "asset_tag", nullable = false, unique = true, length = 50)
    private String assetTag;

    @NotBlank
    @Column(name = "ups_name", nullable = false, length = 100)
    private String upsName;

    @Column(length = 50)
    private String brand;

    @Column(length = 50)
    private String model;

    @Column(name = "serial_number", unique = true, length = 100)
    private String serialNumber;

    @Column(name = "capacity_kva", precision = 10, scale = 2)
    private BigDecimal capacityKva;

    @Convert(converter = PhaseConverter.class)
    @Column(length = 20)
    private Phase phase = Phase.SINGLE_PHASE;

    @Column(name = "installation_date")
    private LocalDate installationDate;

    @Column(name = "location_room", length = 100)
    private String locationRoom;

    @Column(name = "location_rack", length = 50)
    private String locationRack;

    @Column(name = "location_zone", length = 50)
    private String locationZone;

    @Convert(converter = UpsStatusConverter.class)
    @Column(length = 25)
    private UpsStatus status = UpsStatus.ACTIVE;

    // === Electrical & Power Parameters ===

    @Column(name = "input_voltage", precision = 10, scale = 2)
    private BigDecimal inputVoltage;

    @Column(name = "output_voltage", precision = 10, scale = 2)
    private BigDecimal outputVoltage;

    @Column(name = "load_percentage", precision = 5, scale = 2)
    private BigDecimal loadPercentage;

    @Column(name = "current_load_kw", precision = 10, scale = 2)
    private BigDecimal currentLoadKw;

    @Column(name = "battery_voltage", precision = 10, scale = 2)
    private BigDecimal batteryVoltage;

    @Column(name = "battery_current", precision = 10, scale = 2)
    private BigDecimal batteryCurrent;

    @Column(name = "frequency_hz", precision = 6, scale = 2)
    private BigDecimal frequencyHz;

    @Column(name = "power_factor", precision = 4, scale = 2)
    private BigDecimal powerFactor;

    @Column(name = "bypass_status")
    private Boolean bypassStatus = false;

    @Column(name = "generator_mode")
    private Boolean generatorMode = false;

    // === Relationships ===

    @OneToMany(mappedBy = "ups", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<UpsBattery> batteries;

    @OneToMany(mappedBy = "ups", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<UpsMaintenance> maintenanceRecords;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum Phase {
        SINGLE_PHASE, THREE_PHASE
    }

    public enum UpsStatus {
        ACTIVE, FAULTY, UNDER_MAINTENANCE, DECOMMISSIONED
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

    public static class PhaseConverter implements AttributeConverter<Phase, String> {
        @Override
        public String convertToDatabaseColumn(Phase attribute) {
            return attribute == null ? null : attribute.name();
        }

        @Override
        public Phase convertToEntityAttribute(String dbData) {
            if (dbData == null || dbData.trim().isEmpty()) {
                return null;
            }
            try {
                return Phase.valueOf(dbData.trim().toUpperCase());
            } catch (IllegalArgumentException e) {
                return Phase.SINGLE_PHASE; // Fallback for invalid DB string
            }
        }
    }

    public static class UpsStatusConverter implements AttributeConverter<UpsStatus, String> {
        @Override
        public String convertToDatabaseColumn(UpsStatus attribute) {
            return attribute == null ? null : attribute.name();
        }

        @Override
        public UpsStatus convertToEntityAttribute(String dbData) {
            if (dbData == null || dbData.trim().isEmpty()) {
                return null;
            }
            try {
                return UpsStatus.valueOf(dbData.trim().toUpperCase());
            } catch (IllegalArgumentException e) {
                return UpsStatus.ACTIVE; // Fallback for invalid DB string
            }
        }
    }
}
