package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "alerts")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Alert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "alert_id")
    private Long alertId;

    @Enumerated(EnumType.STRING)
    @Column(name = "alert_type", nullable = false, length = 25)
    private AlertType alertType;

    @Enumerated(EnumType.STRING)
    @Column(name = "equipment_type", nullable = false, length = 10)
    private EquipmentCategory equipmentType;

    @Column(name = "equipment_id")
    private Long equipmentId;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(name = "threshold_value", precision = 10, scale = 2)
    private BigDecimal thresholdValue;

    @Column(name = "actual_value", precision = 10, scale = 2)
    private BigDecimal actualValue;

    @Column(name = "is_sent")
    private Boolean isSent = false;

    @Column(name = "is_acknowledged")
    private Boolean isAcknowledged = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "acknowledged_by")
    private User acknowledgedBy;

    @Column(name = "acknowledged_at")
    private LocalDateTime acknowledgedAt;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum AlertType {
        HIGH_TEMP, LOW_BATTERY, UPS_OVERLOAD,
        HUMIDITY, MAINTENANCE_DUE, EQUIPMENT_FAULT
    }

    public enum EquipmentCategory {
        UPS, COOLING, OTHER
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
