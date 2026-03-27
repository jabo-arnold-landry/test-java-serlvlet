package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "daily_consolidated_reports")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class DailyConsolidatedReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @Column(name = "report_date", nullable = false, unique = true)
    private LocalDate reportDate;

    // === Overall UPS Health ===

    @Column(name = "avg_daily_load", precision = 10, scale = 2)
    private BigDecimal avgDailyLoad;

    @Column(name = "total_ups_alarms")
    private Integer totalUpsAlarms = 0;

    @Column(name = "battery_status_summary", columnDefinition = "TEXT")
    private String batteryStatusSummary;

    @Column(name = "failover_to_generator")
    private Boolean failoverToGenerator = false;

    // === Cooling Performance ===

    @Column(name = "avg_room_temperature", precision = 5, scale = 2)
    private BigDecimal avgRoomTemperature;

    @Column(name = "highest_temp_recorded", precision = 5, scale = 2)
    private BigDecimal highestTempRecorded;

    @Column(name = "humidity_stability", length = 100)
    private String humidityStability;

    @Column(name = "cooling_failure")
    private Boolean coolingFailure = false;

    // === Incidents Summary ===

    @Column(name = "total_incidents")
    private Integer totalIncidents = 0;

    @Column(name = "total_downtime_min")
    private Integer totalDowntimeMin = 0;

    @Column(name = "mttr_minutes", precision = 10, scale = 2)
    private BigDecimal mttrMinutes;

    @Column(name = "mtbf_hours", precision = 10, scale = 2)
    private BigDecimal mtbfHours;

    // === Maintenance Summary ===

    @Column(name = "maintenance_performed", columnDefinition = "TEXT")
    private String maintenancePerformed;

    @Column(name = "overdue_maintenance", columnDefinition = "TEXT")
    private String overdueMaintenance;

    // === Visitor Summary ===

    @Column(name = "total_visitors")
    private Integer totalVisitors = 0;

    @Column(name = "overstayed_visitors")
    private Integer overstayedVisitors = 0;

    @Column(name = "high_risk_visits")
    private Integer highRiskVisits = 0;

    @Column(name = "generated_at", updatable = false)
    private LocalDateTime generatedAt;

    @PrePersist
    protected void onCreate() {
        generatedAt = LocalDateTime.now();
    }
}
