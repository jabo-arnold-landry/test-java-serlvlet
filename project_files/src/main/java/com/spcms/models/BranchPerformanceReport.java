package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "branch_performance_reports")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class BranchPerformanceReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @Column(name = "branch", nullable = false)
    private String branch;

    @Column(name = "report_date", nullable = false)
    private LocalDate reportDate;

    // === UPS / Power Metrics ===

    @Column(name = "avg_daily_load", precision = 10, scale = 2)
    private BigDecimal avgDailyLoad;

    @Column(name = "peak_load", precision = 10, scale = 2)
    private BigDecimal peakLoad;

    @Column(name = "total_ups_alarms")
    private Integer totalUpsAlarms = 0;

    @Column(name = "failover_to_generator")
    private Boolean failoverToGenerator = false;

    // === Cooling Performance ===

    @Column(name = "avg_room_temperature", precision = 5, scale = 2)
    private BigDecimal avgRoomTemperature;

    @Column(name = "highest_temp_recorded", precision = 5, scale = 2)
    private BigDecimal highestTempRecorded;

    @Column(name = "cooling_failure")
    private Boolean coolingFailure = false;

    // === Incidents & Downtime ===

    @Column(name = "total_incidents")
    private Integer totalIncidents = 0;

    @Column(name = "critical_incidents")
    private Integer criticalIncidents = 0;

    @Column(name = "total_downtime_min")
    private Integer totalDowntimeMin = 0;

    @Column(name = "mttr_minutes", precision = 10, scale = 2)
    private BigDecimal mttrMinutes;

    @Column(name = "mtbf_hours", precision = 10, scale = 2)
    private BigDecimal mtbfHours;

    // === Visitor Summary ===

    @Column(name = "total_visitors")
    private Integer totalVisitors = 0;

    @Column(name = "overstayed_visitors")
    private Integer overstayedVisitors = 0;

    // === Metadata ===

    @Column(name = "user_count")
    private Integer userCount = 0;

    @Column(name = "generated_at", updatable = false)
    private LocalDateTime generatedAt;

    @PrePersist
    protected void onCreate() {
        generatedAt = LocalDateTime.now();
    }
}
