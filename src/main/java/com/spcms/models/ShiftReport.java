package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "shift_reports")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@SuppressWarnings("lombok")
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

    @Builder.Default
    @Column(name = "overload_occurred")
    private Boolean overloadOccurred = false;

    @Builder.Default
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

    @Builder.Default
    @Column(name = "high_temp_alarm")
    private Boolean highTempAlarm = false;

    @Builder.Default
    @Column(name = "humidity_alarm")
    private Boolean humidityAlarm = false;

    // === Incidents During Shift ===

    @Builder.Default
    @Column(name = "num_incidents")
    private Integer numIncidents = 0;

    @Builder.Default
    @Column(name = "critical_incidents")
    private Integer criticalIncidents = 0;

    @Builder.Default
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

    @Builder.Default
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

    // Getter and Setter Methods (for safety)
    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public User getStaff() {
        return staff;
    }

    public void setStaff(User staff) {
        this.staff = staff;
    }

    public ShiftType getShiftType() {
        return shiftType;
    }

    public void setShiftType(ShiftType shiftType) {
        this.shiftType = shiftType;
    }

    public LocalDate getShiftDate() {
        return shiftDate;
    }

    public void setShiftDate(LocalDate shiftDate) {
        this.shiftDate = shiftDate;
    }

    public LocalDateTime getLoginTime() {
        return loginTime;
    }

    public void setLoginTime(LocalDateTime loginTime) {
        this.loginTime = loginTime;
    }

    public LocalDateTime getLogoutTime() {
        return logoutTime;
    }

    public void setLogoutTime(LocalDateTime logoutTime) {
        this.logoutTime = logoutTime;
    }

    public BigDecimal getAvgInputVoltage() {
        return avgInputVoltage;
    }

    public void setAvgInputVoltage(BigDecimal avgInputVoltage) {
        this.avgInputVoltage = avgInputVoltage;
    }

    public BigDecimal getAvgOutputVoltage() {
        return avgOutputVoltage;
    }

    public void setAvgOutputVoltage(BigDecimal avgOutputVoltage) {
        this.avgOutputVoltage = avgOutputVoltage;
    }

    public BigDecimal getMaxLoadPercent() {
        return maxLoadPercent;
    }

    public void setMaxLoadPercent(BigDecimal maxLoadPercent) {
        this.maxLoadPercent = maxLoadPercent;
    }

    public BigDecimal getMinBatteryLevel() {
        return minBatteryLevel;
    }

    public void setMinBatteryLevel(BigDecimal minBatteryLevel) {
        this.minBatteryLevel = minBatteryLevel;
    }

    public Integer getBatteryRuntimeRemaining() {
        return batteryRuntimeRemaining;
    }

    public void setBatteryRuntimeRemaining(Integer batteryRuntimeRemaining) {
        this.batteryRuntimeRemaining = batteryRuntimeRemaining;
    }

    public Boolean getOverloadOccurred() {
        return overloadOccurred;
    }

    public void setOverloadOccurred(Boolean overloadOccurred) {
        this.overloadOccurred = overloadOccurred;
    }

    public Boolean getBypassActivated() {
        return bypassActivated;
    }

    public void setBypassActivated(Boolean bypassActivated) {
        this.bypassActivated = bypassActivated;
    }

    public BigDecimal getHighestTempRecorded() {
        return highestTempRecorded;
    }

    public void setHighestTempRecorded(BigDecimal highestTempRecorded) {
        this.highestTempRecorded = highestTempRecorded;
    }

    public BigDecimal getLowestTempRecorded() {
        return lowestTempRecorded;
    }

    public void setLowestTempRecorded(BigDecimal lowestTempRecorded) {
        this.lowestTempRecorded = lowestTempRecorded;
    }

    public BigDecimal getAvgHumidity() {
        return avgHumidity;
    }

    public void setAvgHumidity(BigDecimal avgHumidity) {
        this.avgHumidity = avgHumidity;
    }

    public String getCompressorStatus() {
        return compressorStatus;
    }

    public void setCompressorStatus(String compressorStatus) {
        this.compressorStatus = compressorStatus;
    }

    public String getFanStatus() {
        return fanStatus;
    }

    public void setFanStatus(String fanStatus) {
        this.fanStatus = fanStatus;
    }

    public Boolean getHighTempAlarm() {
        return highTempAlarm;
    }

    public void setHighTempAlarm(Boolean highTempAlarm) {
        this.highTempAlarm = highTempAlarm;
    }

    public Boolean getHumidityAlarm() {
        return humidityAlarm;
    }

    public void setHumidityAlarm(Boolean humidityAlarm) {
        this.humidityAlarm = humidityAlarm;
    }

    public Integer getNumIncidents() {
        return numIncidents;
    }

    public void setNumIncidents(Integer numIncidents) {
        this.numIncidents = numIncidents;
    }

    public Integer getCriticalIncidents() {
        return criticalIncidents;
    }

    public void setCriticalIncidents(Integer criticalIncidents) {
        this.criticalIncidents = criticalIncidents;
    }

    public Integer getDowntimeDurationMin() {
        return downtimeDurationMin;
    }

    public void setDowntimeDurationMin(Integer downtimeDurationMin) {
        this.downtimeDurationMin = downtimeDurationMin;
    }

    public String getRootCauseSummary() {
        return rootCauseSummary;
    }

    public void setRootCauseSummary(String rootCauseSummary) {
        this.rootCauseSummary = rootCauseSummary;
    }

    public String getActionTaken() {
        return actionTaken;
    }

    public void setActionTaken(String actionTaken) {
        this.actionTaken = actionTaken;
    }

    public String getPreventiveMaintDone() {
        return preventiveMaintDone;
    }

    public void setPreventiveMaintDone(String preventiveMaintDone) {
        this.preventiveMaintDone = preventiveMaintDone;
    }

    public String getCorrectiveMaintDone() {
        return correctiveMaintDone;
    }

    public void setCorrectiveMaintDone(String correctiveMaintDone) {
        this.correctiveMaintDone = correctiveMaintDone;
    }

    public String getSparePartsUsed() {
        return sparePartsUsed;
    }

    public void setSparePartsUsed(String sparePartsUsed) {
        this.sparePartsUsed = sparePartsUsed;
    }

    public String getPhotosUploadedPath() {
        return photosUploadedPath;
    }

    public void setPhotosUploadedPath(String photosUploadedPath) {
        this.photosUploadedPath = photosUploadedPath;
    }

    public Integer getNumVisitors() {
        return numVisitors;
    }

    public void setNumVisitors(Integer numVisitors) {
        this.numVisitors = numVisitors;
    }

    public String getVisitorApprovedBy() {
        return visitorApprovedBy;
    }

    public void setVisitorApprovedBy(String visitorApprovedBy) {
        this.visitorApprovedBy = visitorApprovedBy;
    }

    public String getEscortName() {
        return escortName;
    }

    public void setEscortName(String escortName) {
        this.escortName = escortName;
    }

    public String getVisitDurationSummary() {
        return visitDurationSummary;
    }

    public void setVisitDurationSummary(String visitDurationSummary) {
        this.visitDurationSummary = visitDurationSummary;
    }

    public String getVisitorIncident() {
        return visitorIncident;
    }

    public void setVisitorIncident(String visitorIncident) {
        this.visitorIncident = visitorIncident;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
