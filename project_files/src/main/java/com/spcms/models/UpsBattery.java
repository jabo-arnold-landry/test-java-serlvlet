package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "ups_battery")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class UpsBattery {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "battery_id")
    private Long batteryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ups_id", nullable = false)
    private Ups ups;

    @Column(name = "battery_type", length = 50)
    private String batteryType;

    @Column(name = "battery_quantity")
    private Integer batteryQuantity;

    @Column(name = "battery_capacity_ah", precision = 10, scale = 2)
    private BigDecimal batteryCapacityAh;

    @Column(name = "battery_install_date")
    private LocalDate batteryInstallDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "battery_health_status", length = 20)
    private BatteryHealthStatus batteryHealthStatus = BatteryHealthStatus.GOOD;

    @Column(name = "last_battery_test_date")
    private LocalDate lastBatteryTestDate;

    @Column(name = "estimated_runtime_min")
    private Integer estimatedRuntimeMin;

    @Column(name = "replacement_due_date")
    private LocalDate replacementDueDate;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum BatteryHealthStatus {
        GOOD, FAIR, POOR, CRITICAL, REPLACE
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
}
