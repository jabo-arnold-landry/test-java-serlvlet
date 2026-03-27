package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "alerts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Alert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "alert_id")
    private Long alertId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AlertType alertType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EquipmentCategory equipmentType;

    @Column(name = "equipment_id")
    private Long equipmentId;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(name = "threshold_value")
    private BigDecimal thresholdValue;

    @Column(name = "actual_value")
    private BigDecimal actualValue;

    @Column(name = "is_sent")
    private Boolean isSent = false;

    @Column(name = "is_acknowledged")
    private Boolean isAcknowledged = false;

    @ManyToOne
    @JoinColumn(name = "acknowledged_by_user_id")
    private User acknowledgedBy;

    @Column(name = "acknowledged_at")
    private LocalDateTime acknowledgedAt;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum AlertType {
        HIGH_TEMP, LOW_BATTERY, UPS_OVERLOAD, HUMIDITY, MAINTENANCE_DUE, EQUIPMENT_FAULT
    }

    public enum EquipmentCategory {
        UPS, COOLING
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (isSent == null)
            isSent = false;
        if (isAcknowledged == null)
            isAcknowledged = false;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getter Methods
    public Long getAlertId() {
        return alertId;
    }

    public void setAlertId(Long alertId) {
        this.alertId = alertId;
    }

    public AlertType getAlertType() {
        return alertType;
    }

    public void setAlertType(AlertType alertType) {
        this.alertType = alertType;
    }

    public EquipmentCategory getEquipmentType() {
        return equipmentType;
    }

    public void setEquipmentType(EquipmentCategory equipmentType) {
        this.equipmentType = equipmentType;
    }

    public Long getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(Long equipmentId) {
        this.equipmentId = equipmentId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public BigDecimal getThresholdValue() {
        return thresholdValue;
    }

    public void setThresholdValue(BigDecimal thresholdValue) {
        this.thresholdValue = thresholdValue;
    }

    public BigDecimal getActualValue() {
        return actualValue;
    }

    public void setActualValue(BigDecimal actualValue) {
        this.actualValue = actualValue;
    }

    public Boolean getIsSent() {
        return isSent;
    }

    public void setIsSent(Boolean isSent) {
        this.isSent = isSent;
    }

    public Boolean getIsAcknowledged() {
        return isAcknowledged;
    }

    public void setIsAcknowledged(Boolean isAcknowledged) {
        this.isAcknowledged = isAcknowledged;
    }

    public User getAcknowledgedBy() {
        return acknowledgedBy;
    }

    public void setAcknowledgedBy(User acknowledgedBy) {
        this.acknowledgedBy = acknowledgedBy;
    }

    public LocalDateTime getAcknowledgedAt() {
        return acknowledgedAt;
    }

    public void setAcknowledgedAt(LocalDateTime acknowledgedAt) {
        this.acknowledgedAt = acknowledgedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Manual Builder Implementation
    public static AlertBuilder builder() {
        return new AlertBuilder();
    }

    public static class AlertBuilder {
        private Long alertId;
        private AlertType alertType;
        private EquipmentCategory equipmentType;
        private Long equipmentId;
        private String message;
        private BigDecimal thresholdValue;
        private BigDecimal actualValue;
        private Boolean isSent = false;
        private Boolean isAcknowledged = false;
        private User acknowledgedBy;
        private LocalDateTime acknowledgedAt;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public AlertBuilder alertId(Long alertId) {
            this.alertId = alertId;
            return this;
        }

        public AlertBuilder alertType(AlertType alertType) {
            this.alertType = alertType;
            return this;
        }

        public AlertBuilder equipmentType(EquipmentCategory equipmentType) {
            this.equipmentType = equipmentType;
            return this;
        }

        public AlertBuilder equipmentId(Long equipmentId) {
            this.equipmentId = equipmentId;
            return this;
        }

        public AlertBuilder message(String message) {
            this.message = message;
            return this;
        }

        public AlertBuilder thresholdValue(BigDecimal thresholdValue) {
            this.thresholdValue = thresholdValue;
            return this;
        }

        public AlertBuilder actualValue(BigDecimal actualValue) {
            this.actualValue = actualValue;
            return this;
        }

        public AlertBuilder isSent(Boolean isSent) {
            this.isSent = isSent;
            return this;
        }

        public AlertBuilder isAcknowledged(Boolean isAcknowledged) {
            this.isAcknowledged = isAcknowledged;
            return this;
        }

        public AlertBuilder acknowledgedBy(User acknowledgedBy) {
            this.acknowledgedBy = acknowledgedBy;
            return this;
        }

        public AlertBuilder acknowledgedAt(LocalDateTime acknowledgedAt) {
            this.acknowledgedAt = acknowledgedAt;
            return this;
        }

        public AlertBuilder createdAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public AlertBuilder updatedAt(LocalDateTime updatedAt) {
            this.updatedAt = updatedAt;
            return this;
        }

        public Alert build() {
            Alert alert = new Alert();
            alert.alertId = this.alertId;
            alert.alertType = this.alertType;
            alert.equipmentType = this.equipmentType;
            alert.equipmentId = this.equipmentId;
            alert.message = this.message;
            alert.thresholdValue = this.thresholdValue;
            alert.actualValue = this.actualValue;
            alert.isSent = this.isSent;
            alert.isAcknowledged = this.isAcknowledged;
            alert.acknowledgedBy = this.acknowledgedBy;
            alert.acknowledgedAt = this.acknowledgedAt;
            alert.createdAt = this.createdAt;
            alert.updatedAt = this.updatedAt;
            return alert;
        }
    }
}
