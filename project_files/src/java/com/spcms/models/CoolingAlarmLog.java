package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "cooling_alarm_log")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class CoolingAlarmLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "alarm_id")
    private Long alarmId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cooling_id", nullable = false)
    private CoolingUnit coolingUnit;

    @Enumerated(EnumType.STRING)
    @Column(name = "alarm_type", nullable = false, length = 25)
    private AlarmType alarmType;

    @Column(name = "alarm_time", nullable = false)
    private LocalDateTime alarmTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Severity severity;

    @Column(name = "action_taken", columnDefinition = "TEXT")
    private String actionTaken;

    @Column(name = "resolved_by", length = 100)
    private String resolvedBy;

    @Column(name = "resolution_time")
    private LocalDateTime resolutionTime;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum AlarmType {
        HIGH_TEMP, LOW_TEMP, GAS_LEAK, FAN_FAILURE,
        HUMIDITY_HIGH, HUMIDITY_LOW, COMPRESSOR_FAILURE
    }

    public enum Severity {
        LOW, MEDIUM, HIGH, CRITICAL
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
