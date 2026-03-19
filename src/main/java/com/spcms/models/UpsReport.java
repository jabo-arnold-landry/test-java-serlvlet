package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Entity
@Table(name = "ups_reports")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpsReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @Column(name = "ups_id")
    private Long upsId;

    @Column(name = "report_period")
    private String reportPeriod;

    @Column(name = "period_start_date")
    private LocalDate periodStartDate;

    @Column(name = "period_end_date")
    private LocalDate periodEndDate;

    @Column(name = "generated_at")
    private LocalDateTime generatedAt;

    @Column(name = "filter_status")
    private String filterStatus;

    @Column(name = "filter_location")
    private String filterLocation;

    @Column(name = "total_devices_added")
    private Integer totalDevicesAdded;

    @Column(name = "total_active_devices")
    private Integer totalActiveDevices;

    @Column(name = "total_faulty_devices")
    private Integer totalFaultyDevices;

    @Column(name = "total_under_maintenance_devices")
    private Integer totalUnderMaintenanceDevices;

    @Column(name = "total_decommissioned_devices")
    private Integer totalDecommissionedDevices;

    @Column(name = "total_capacity_kva")
    private BigDecimal totalCapacityKva;

    @Column(name = "average_capacity_kva")
    private BigDecimal averageCapacityKva;

    @Column(name = "max_capacity_kva")
    private BigDecimal maxCapacityKva;

    @Column(name = "min_capacity_kva")
    private BigDecimal minCapacityKva;

    @Column(name = "avg_temperature")
    private BigDecimal avgTemperature;

    @Column(name = "max_temperature")
    private BigDecimal maxTemperature;

    @Column(name = "min_temperature")
    private BigDecimal minTemperature;

    @Column(name = "avg_battery_level")
    private BigDecimal avgBatteryLevel;

    @Column(name = "avg_load")
    private BigDecimal avgLoad;

    @Column(name = "uptime_hours")
    private BigDecimal uptimeHours;

    @Column(name = "downtime_hours")
    private BigDecimal downtimeHours;

    @Column(name = "efficiency_percentage")
    private BigDecimal efficiencyPercentage;

    @Transient
    private Map<String, Integer> devicesByLocation;

    @Transient
    private Map<String, Integer> devicesByStatus;

    @Transient
    private Map<String, Integer> devicesByBrand;

    @Transient
    private List<UpsReportDetail> deviceDetails;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum ReportPeriod {
        DAILY("Daily"),
        WEEKLY("Weekly"),
        MONTHLY("Monthly"),
        QUARTERLY("Quarterly"),
        YEARLY("Yearly");

        private final String displayName;

        ReportPeriod(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
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

    // All Getter and Setter Methods
    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public Long getUpsId() {
        return upsId;
    }

    public void setUpsId(Long upsId) {
        this.upsId = upsId;
    }

    public String getReportPeriod() {
        return reportPeriod;
    }

    public void setReportPeriod(String reportPeriod) {
        this.reportPeriod = reportPeriod;
    }

    public LocalDate getPeriodStartDate() {
        return periodStartDate;
    }

    public void setPeriodStartDate(LocalDate periodStartDate) {
        this.periodStartDate = periodStartDate;
    }

    public LocalDate getPeriodEndDate() {
        return periodEndDate;
    }

    public void setPeriodEndDate(LocalDate periodEndDate) {
        this.periodEndDate = periodEndDate;
    }

    public LocalDateTime getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(LocalDateTime generatedAt) {
        this.generatedAt = generatedAt;
    }

    public String getFilterStatus() {
        return filterStatus;
    }

    public void setFilterStatus(String filterStatus) {
        this.filterStatus = filterStatus;
    }

    public String getFilterLocation() {
        return filterLocation;
    }

    public void setFilterLocation(String filterLocation) {
        this.filterLocation = filterLocation;
    }

    public Integer getTotalDevicesAdded() {
        return totalDevicesAdded;
    }

    public void setTotalDevicesAdded(Integer totalDevicesAdded) {
        this.totalDevicesAdded = totalDevicesAdded;
    }

    public Integer getTotalActiveDevices() {
        return totalActiveDevices;
    }

    public void setTotalActiveDevices(Integer totalActiveDevices) {
        this.totalActiveDevices = totalActiveDevices;
    }

    public Integer getTotalFaultyDevices() {
        return totalFaultyDevices;
    }

    public void setTotalFaultyDevices(Integer totalFaultyDevices) {
        this.totalFaultyDevices = totalFaultyDevices;
    }

    public Integer getTotalUnderMaintenanceDevices() {
        return totalUnderMaintenanceDevices;
    }

    public void setTotalUnderMaintenanceDevices(Integer totalUnderMaintenanceDevices) {
        this.totalUnderMaintenanceDevices = totalUnderMaintenanceDevices;
    }

    public Integer getTotalDecommissionedDevices() {
        return totalDecommissionedDevices;
    }

    public void setTotalDecommissionedDevices(Integer totalDecommissionedDevices) {
        this.totalDecommissionedDevices = totalDecommissionedDevices;
    }

    public BigDecimal getTotalCapacityKva() {
        return totalCapacityKva;
    }

    public void setTotalCapacityKva(BigDecimal totalCapacityKva) {
        this.totalCapacityKva = totalCapacityKva;
    }

    public BigDecimal getAverageCapacityKva() {
        return averageCapacityKva;
    }

    public void setAverageCapacityKva(BigDecimal averageCapacityKva) {
        this.averageCapacityKva = averageCapacityKva;
    }

    public BigDecimal getMaxCapacityKva() {
        return maxCapacityKva;
    }

    public void setMaxCapacityKva(BigDecimal maxCapacityKva) {
        this.maxCapacityKva = maxCapacityKva;
    }

    public BigDecimal getMinCapacityKva() {
        return minCapacityKva;
    }

    public void setMinCapacityKva(BigDecimal minCapacityKva) {
        this.minCapacityKva = minCapacityKva;
    }

    public BigDecimal getAvgTemperature() {
        return avgTemperature;
    }

    public void setAvgTemperature(BigDecimal avgTemperature) {
        this.avgTemperature = avgTemperature;
    }

    public BigDecimal getMaxTemperature() {
        return maxTemperature;
    }

    public void setMaxTemperature(BigDecimal maxTemperature) {
        this.maxTemperature = maxTemperature;
    }

    public BigDecimal getMinTemperature() {
        return minTemperature;
    }

    public void setMinTemperature(BigDecimal minTemperature) {
        this.minTemperature = minTemperature;
    }

    public BigDecimal getAvgBatteryLevel() {
        return avgBatteryLevel;
    }

    public void setAvgBatteryLevel(BigDecimal avgBatteryLevel) {
        this.avgBatteryLevel = avgBatteryLevel;
    }

    public BigDecimal getAvgLoad() {
        return avgLoad;
    }

    public void setAvgLoad(BigDecimal avgLoad) {
        this.avgLoad = avgLoad;
    }

    public BigDecimal getUptimeHours() {
        return uptimeHours;
    }

    public void setUptimeHours(BigDecimal uptimeHours) {
        this.uptimeHours = uptimeHours;
    }

    public BigDecimal getDowntimeHours() {
        return downtimeHours;
    }

    public void setDowntimeHours(BigDecimal downtimeHours) {
        this.downtimeHours = downtimeHours;
    }

    public BigDecimal getEfficiencyPercentage() {
        return efficiencyPercentage;
    }

    public void setEfficiencyPercentage(BigDecimal efficiencyPercentage) {
        this.efficiencyPercentage = efficiencyPercentage;
    }

    public Map<String, Integer> getDevicesByLocation() {
        return devicesByLocation;
    }

    public void setDevicesByLocation(Map<String, Integer> devicesByLocation) {
        this.devicesByLocation = devicesByLocation;
    }

    public Map<String, Integer> getDevicesByStatus() {
        return devicesByStatus;
    }

    public void setDevicesByStatus(Map<String, Integer> devicesByStatus) {
        this.devicesByStatus = devicesByStatus;
    }

    public Map<String, Integer> getDevicesByBrand() {
        return devicesByBrand;
    }

    public void setDevicesByBrand(Map<String, Integer> devicesByBrand) {
        this.devicesByBrand = devicesByBrand;
    }

    public List<UpsReportDetail> getDeviceDetails() {
        return deviceDetails;
    }

    public void setDeviceDetails(List<UpsReportDetail> deviceDetails) {
        this.deviceDetails = deviceDetails;
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

    // Inner class for Report Details
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class UpsReportDetail {
        private Long detailId;
        private Long reportId;
        private String assetTag;
        private String upsName;
        private String brand;
        private String model;
        private String serialNumber;
        private BigDecimal capacityKva;
        private String status;
        private String locationRoom;
        private LocalDate installationDate;
        private LocalDateTime recordTime;
        private BigDecimal temperature;
        private BigDecimal batteryLevel;
        private BigDecimal loadPercentage;

        public Long getDetailId() {
            return detailId;
        }

        public void setDetailId(Long detailId) {
            this.detailId = detailId;
        }

        public Long getReportId() {
            return reportId;
        }

        public void setReportId(Long reportId) {
            this.reportId = reportId;
        }

        public String getAssetTag() {
            return assetTag;
        }

        public void setAssetTag(String assetTag) {
            this.assetTag = assetTag;
        }

        public String getUpsName() {
            return upsName;
        }

        public void setUpsName(String upsName) {
            this.upsName = upsName;
        }

        public String getBrand() {
            return brand;
        }

        public void setBrand(String brand) {
            this.brand = brand;
        }

        public String getModel() {
            return model;
        }

        public void setModel(String model) {
            this.model = model;
        }

        public String getSerialNumber() {
            return serialNumber;
        }

        public void setSerialNumber(String serialNumber) {
            this.serialNumber = serialNumber;
        }

        public String getSerialNo() {
            return this.serialNumber;
        }

        public void setSerialNo(String serialNo) {
            this.serialNumber = serialNo;
        }

        public BigDecimal getCapacityKva() {
            return capacityKva;
        }

        public void setCapacityKva(BigDecimal capacityKva) {
            this.capacityKva = capacityKva;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getLocationRoom() {
            return locationRoom;
        }

        public void setLocationRoom(String locationRoom) {
            this.locationRoom = locationRoom;
        }

        public LocalDate getInstallationDate() {
            return installationDate;
        }

        public void setInstallationDate(LocalDate installationDate) {
            this.installationDate = installationDate;
        }

        public LocalDateTime getRecordTime() {
            return recordTime;
        }

        public void setRecordTime(LocalDateTime recordTime) {
            this.recordTime = recordTime;
        }

        public BigDecimal getTemperature() {
            return temperature;
        }

        public void setTemperature(BigDecimal temperature) {
            this.temperature = temperature;
        }

        public BigDecimal getBatteryLevel() {
            return batteryLevel;
        }

        public void setBatteryLevel(BigDecimal batteryLevel) {
            this.batteryLevel = batteryLevel;
        }

        public BigDecimal getLoadPercentage() {
            return loadPercentage;
        }

        public void setLoadPercentage(BigDecimal loadPercentage) {
            this.loadPercentage = loadPercentage;
        }
    }
}
