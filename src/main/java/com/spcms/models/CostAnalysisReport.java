package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "cost_analysis_reports")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class CostAnalysisReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @Column(name = "report_date", nullable = false)
    private LocalDate reportDate;

    @Column(name = "branch")
    private String branch;

    // === Maintenance Costs ===

    @Column(name = "total_maintenance_cost", precision = 15, scale = 2)
    private BigDecimal totalMaintenanceCost = BigDecimal.ZERO;

    @Column(name = "ups_maintenance_cost", precision = 15, scale = 2)
    private BigDecimal upsMaintenanceCost = BigDecimal.ZERO;

    @Column(name = "cooling_maintenance_cost", precision = 15, scale = 2)
    private BigDecimal coolingMaintenanceCost = BigDecimal.ZERO;

    @Column(name = "preventive_maintenance_cost", precision = 15, scale = 2)
    private BigDecimal preventiveMaintenanceCost = BigDecimal.ZERO;

    @Column(name = "corrective_maintenance_cost", precision = 15, scale = 2)
    private BigDecimal correctiveMaintenanceCost = BigDecimal.ZERO;

    // === Incident/Repair Costs ===

    @Column(name = "total_repair_cost", precision = 15, scale = 2)
    private BigDecimal totalRepairCost = BigDecimal.ZERO;

    @Column(name = "critical_incident_cost", precision = 15, scale = 2)
    private BigDecimal criticalIncidentCost = BigDecimal.ZERO;

    // === Downtime Cost ===

    @Column(name = "total_downtime_minutes")
    private Integer totalDowntimeMinutes = 0;

    @Column(name = "cost_per_hour_loss", precision = 15, scale = 2)
    private BigDecimal costPerHourLoss = BigDecimal.ZERO;

    @Column(name = "total_downtime_cost", precision = 15, scale = 2)
    private BigDecimal totalDowntimeCost = BigDecimal.ZERO;

    // === Summary Costs ===

    @Column(name = "total_maintenance_cost_all", precision = 15, scale = 2)
    private BigDecimal totalMaintenanceCostAll = BigDecimal.ZERO;

    @Column(name = "total_operational_cost", precision = 15, scale = 2)
    private BigDecimal totalOperationalCost = BigDecimal.ZERO;

    // === Metrics ===

    @Column(name = "maintenance_cost_per_hour", precision = 15, scale = 2)
    private BigDecimal maintenanceCostPerHour = BigDecimal.ZERO;

    @Column(name = "total_incidents")
    private Integer totalIncidents = 0;

    @Column(name = "maintenance_events")
    private Integer maintenanceEvents = 0;

    // === Metadata ===

    @Column(name = "generated_at", updatable = false)
    private LocalDateTime generatedAt;

    @PrePersist
    protected void onCreate() {
        generatedAt = LocalDateTime.now();
        if (totalMaintenanceCost == null) totalMaintenanceCost = BigDecimal.ZERO;
        if (totalRepairCost == null) totalRepairCost = BigDecimal.ZERO;
        if (totalDowntimeCost == null) totalDowntimeCost = BigDecimal.ZERO;
    }
}
