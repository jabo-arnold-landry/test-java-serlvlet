package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "shift_reports")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class ShiftReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "staff_id", nullable = false)
    private User staff;

    @Enumerated(EnumType.STRING)
    @Column(name = "shift_type", nullable = false, length = 10)
    private ShiftType shiftType;

    @Column(name = "shift_date", nullable = false)
    private LocalDate shiftDate;

    @Column(name = "login_time")
    private LocalDateTime loginTime;

    @Column(name = "logout_time")
    private LocalDateTime logoutTime;

    // === UPS Monitoring Summary ===

    @Column(name = "avg_input_voltage", precision = 10, scale = 2)
    private BigDecimal avgInputVoltage;

    @Column(name = "avg_output_voltage", precision = 10, scale = 2)
    private BigDecimal avgOutputVoltage;

    @Column(name = "max_load_percent", precision = 5, scale = 2)
    private BigDecimal maxLoadPercent;

    @Column(name = "min_battery_level", precision = 5, scale = 2)
    private BigDecimal minBatteryLevel;

    @Column(name = "battery_runtime_remaining")
    private Integer batteryRuntimeRemaining;

    @Column(name = "overload_occurred")
    private Boolean overloadOccurred = false;

    @Column(name = "bypass_activated")
    private Boolean bypassActivated = false;

    // === Cooling Monitoring Summary ===

    @Column(name = "highest_temp_recorded", precision = 5, scale = 2)
    private BigDecimal highestTempRecorded;

    @Column(name = "lowest_temp_recorded", precision = 5, scale = 2)
    private BigDecimal lowestTempRecorded;

    @Column(name = "avg_humidity", precision = 5, scale = 2)
    private BigDecimal avgHumidity;

    @Column(name = "compressor_status", length = 50)
    private String compressorStatus;

    @Column(name = "fan_status", length = 50)
    private String fanStatus;

    @Column(name = "high_temp_alarm")
    private Boolean highTempAlarm = false;

    @Column(name = "humidity_alarm")
    private Boolean humidityAlarm = false;

    // === Incidents During Shift ===

    @Column(name = "num_incidents")
    private Integer numIncidents = 0;

    @Column(name = "critical_incidents")
    private Integer criticalIncidents = 0;

    @Column(name = "downtime_duration_min")
    private Integer downtimeDurationMin = 0;

    @Column(name = "root_cause_summary", columnDefinition = "TEXT")
    private String rootCauseSummary;

    @Column(name = "action_taken", columnDefinition = "TEXT")
    private String actionTaken;

    // === Maintenance Activities Done ===

    @Column(name = "preventive_maint_done", columnDefinition = "TEXT")
    private String preventiveMaintDone;

    @Column(name = "corrective_maint_done", columnDefinition = "TEXT")
    private String correctiveMaintDone;

    @Column(name = "spare_parts_used", columnDefinition = "TEXT")
    private String sparePartsUsed;

    @Column(name = "photos_uploaded_path", length = 500)
    private String photosUploadedPath;

    // === Visitor Log During Shift ===

    @Column(name = "num_visitors")
    private Integer numVisitors = 0;

    @Column(name = "visitor_approved_by", length = 100)
    private String visitorApprovedBy;

    @Column(name = "escort_name", length = 100)
    private String escortName;

    @Column(name = "visit_duration_summary", columnDefinition = "TEXT")
    private String visitDurationSummary;

    @Column(name = "visitor_incident", columnDefinition = "TEXT")
    private String visitorIncident;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum ShiftType {
        MORNING, EVENING, NIGHT
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
