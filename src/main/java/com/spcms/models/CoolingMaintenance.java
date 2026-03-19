package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "cooling_maintenance")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class CoolingMaintenance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "maintenance_id")
    private Long maintenanceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cooling_id", nullable = false)
    private CoolingUnit coolingUnit;

    @Convert(converter = MaintenanceTypeConverter.class)
    @Column(name = "maintenance_type", nullable = false, length = 15)
    private MaintenanceType maintenanceType;

    @Column(name = "maintenance_date", nullable = false)
    private LocalDate maintenanceDate;

    @Column(name = "filter_cleaning_date")
    private LocalDate filterCleaningDate;

    @Column(name = "gas_refill_date")
    private LocalDate gasRefillDate;

    @Column(name = "next_maintenance_date")
    private LocalDate nextMaintenanceDate;

    @Column(length = 100)
    private String technician;

    @Column(length = 100)
    private String vendor;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(name = "service_report_path", length = 500)
    private String serviceReportPath;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum MaintenanceType {
        PREVENTIVE, CORRECTIVE
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public static class MaintenanceTypeConverter implements AttributeConverter<MaintenanceType, String> {
        @Override
        public String convertToDatabaseColumn(MaintenanceType attribute) {
            return attribute == null ? null : attribute.name();
        }

        @Override
        public MaintenanceType convertToEntityAttribute(String dbData) {
            if (dbData == null || dbData.trim().isEmpty()) {
                return null;
            }
            try {
                return MaintenanceType.valueOf(dbData.trim().toUpperCase());
            } catch (IllegalArgumentException e) {
                return MaintenanceType.PREVENTIVE; // Fallback for invalid DB string
            }
        }
    }
}
