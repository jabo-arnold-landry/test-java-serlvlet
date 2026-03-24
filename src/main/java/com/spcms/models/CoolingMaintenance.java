package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.springframework.format.annotation.DateTimeFormat;

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

    @Enumerated(EnumType.STRING)
    @Column(name = "maintenance_type", nullable = false, length = 15)
    private MaintenanceType maintenanceType;

    @Column(name = "maintenance_date", nullable = false)
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate maintenanceDate;

    @Column(name = "filter_cleaning_date")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate filterCleaningDate;

    @Column(name = "gas_refill_date")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate gasRefillDate;

    @Column(name = "next_maintenance_date")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
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
}
