package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "monitoring_log")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class MonitoringLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Long logId;

    @Enumerated(EnumType.STRING)
    @Column(name = "equipment_type", nullable = false, length = 10)
    private EquipmentType equipmentType;

    @Column(name = "equipment_id", nullable = false)
    private Long equipmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recorded_by")
    private User recordedBy;

    // === UPS Readings ===

    @Column(name = "input_voltage", precision = 10, scale = 2)
    private BigDecimal inputVoltage;

    @Column(name = "output_voltage", precision = 10, scale = 2)
    private BigDecimal outputVoltage;

    @Column(name = "battery_status", length = 50)
    private String batteryStatus;

    @Column(name = "load_percentage", precision = 5, scale = 2)
    private BigDecimal loadPercentage;

    @Column(precision = 5, scale = 2)
    private BigDecimal temperature;

    @Column(name = "runtime_remaining")
    private Integer runtimeRemaining;

    // === Cooling Readings ===

    @Column(name = "supply_air_temp", precision = 5, scale = 2)
    private BigDecimal supplyAirTemp;

    @Column(name = "return_air_temp", precision = 5, scale = 2)
    private BigDecimal returnAirTemp;

    @Column(name = "humidity_percent", precision = 5, scale = 2)
    private BigDecimal humidityPercent;

    @Column(name = "cooling_performance", length = 100)
    private String coolingPerformance;

    @Column(name = "reading_time")
    private LocalDateTime readingTime;

    @Column(columnDefinition = "TEXT")
    private String notes;

    public enum EquipmentType {
        UPS, COOLING
    }

    @PrePersist
    protected void onCreate() {
        readingTime = LocalDateTime.now();
    }
}
