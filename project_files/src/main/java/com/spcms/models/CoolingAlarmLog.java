package com.spcms.models;

import java.io.Serializable;
import java.time.LocalDateTime;

public class CoolingAlarmLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long alarmId;
    private Long coolingUnitId;
    private String alarmType;
    private String alarmDescription;
    private String severity;
    private LocalDateTime alarmTriggeredAt;
    private LocalDateTime alarmResolvedAt;
    private String status;
    private String resolvedBy;
    private String resolution;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public CoolingAlarmLog() {
    }

    public CoolingAlarmLog(Long coolingUnitId, String alarmType, String alarmDescription, String severity) {
        this.coolingUnitId = coolingUnitId;
        this.alarmType = alarmType;
        this.alarmDescription = alarmDescription;
        this.severity = severity;
        this.status = "ACTIVE";
    }

    // Getters and Setters
    public Long getAlarmId() {
        return alarmId;
    }

    public void setAlarmId(Long alarmId) {
        this.alarmId = alarmId;
    }

    public Long getCoolingUnitId() {
        return coolingUnitId;
    }

    public void setCoolingUnitId(Long coolingUnitId) {
        this.coolingUnitId = coolingUnitId;
    }

    public String getAlarmType() {
        return alarmType;
    }

    public void setAlarmType(String alarmType) {
        this.alarmType = alarmType;
    }

    public String getAlarmDescription() {
        return alarmDescription;
    }

    public void setAlarmDescription(String alarmDescription) {
        this.alarmDescription = alarmDescription;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public LocalDateTime getAlarmTriggeredAt() {
        return alarmTriggeredAt;
    }

    public void setAlarmTriggeredAt(LocalDateTime alarmTriggeredAt) {
        this.alarmTriggeredAt = alarmTriggeredAt;
    }

    public LocalDateTime getAlarmResolvedAt() {
        return alarmResolvedAt;
    }

    public void setAlarmResolvedAt(LocalDateTime alarmResolvedAt) {
        this.alarmResolvedAt = alarmResolvedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResolvedBy() {
        return resolvedBy;
    }

    public void setResolvedBy(String resolvedBy) {
        this.resolvedBy = resolvedBy;
    }

    public String getResolution() {
        return resolution;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
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

    public void setResolution(LocalDateTime now) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'setResolution'");
    }
}
