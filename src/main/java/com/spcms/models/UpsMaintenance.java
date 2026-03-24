package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.springframework.format.annotation.DateTimeFormat;

@Entity
@Table(name = "ups_maintenance")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class UpsMaintenance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "maintenance_id")
    private Long maintenanceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ups_id", nullable = false)
    private Ups ups;

    @Enumerated(EnumType.STRING)
    @Column(name = "maintenance_type", nullable = false, length = 15)
    private MaintenanceType maintenanceType;

    @Column(name = "maintenance_date", nullable = false)
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate maintenanceDate;

    @Column(name = "next_due_date")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate nextDueDate;

    @Column(length = 100)
    private String technician;

    @Column(length = 100)
    private String vendor;

    @Column(name = "spare_parts_used", columnDefinition = "TEXT")
    private String sparePartsUsed;

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
