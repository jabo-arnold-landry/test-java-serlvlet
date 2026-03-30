package com.spcms.models;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Converter;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "cooling_maintenance")
public class CoolingMaintenance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "maintenance_id")
    private Long maintenanceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cooling_id", nullable = false)
    private CoolingUnit coolingUnit;

    @Convert(converter = MaintenanceTypeConverter.class)
    @Column(name = "maintenance_type", nullable = false, length = 20)
    private MaintenanceType maintenanceType;

    @Column(name = "maintenance_date", nullable = false)
    private LocalDate maintenanceDate;

    @Column(name = "filter_cleaning_date")
    private LocalDate filterCleaningDate;

    @Column(name = "gas_refill_date")
    private LocalDate gasRefillDate;

    @Column(name = "next_maintenance_date")
    private LocalDate nextMaintenanceDate;

    @Column(name = "technician", length = 100)
    private String technician;

    @Column(name = "maintenance_cost", precision = 12, scale = 2)
    private BigDecimal maintenanceCost;

    @Column(name = "vendor", length = 100)
    private String vendor;

    @Column(name = "parts_cost", precision = 12, scale = 2)
    private BigDecimal partsCost;

    @Column(name = "labor_cost", precision = 12, scale = 2)
    private BigDecimal laborCost;

    @Column(name = "remarks", columnDefinition = "TEXT")
    private String remarks;

    @Column(name = "service_report_path", length = 500)
    private String serviceReportPath;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum MaintenanceType {
        PREVENTIVE,
        CORRECTIVE
    }

    @Converter
    public static class MaintenanceTypeConverter implements AttributeConverter<MaintenanceType, String> {
        @Override
        public String convertToDatabaseColumn(MaintenanceType attribute) {
            return attribute == null ? null : attribute.name();
        }

        @Override
        public MaintenanceType convertToEntityAttribute(String dbData) {
            return dbData == null ? null : MaintenanceType.valueOf(dbData);
        }
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    public CoolingMaintenance() {
    }

    // Kept for binary compatibility with previously generated Lombok constructor
    public CoolingMaintenance(Long maintenanceId,
                              CoolingUnit coolingUnit,
                              MaintenanceType maintenanceType,
                              LocalDate maintenanceDate,
                              LocalDate filterCleaningDate,
                              LocalDate gasRefillDate,
                              LocalDate nextMaintenanceDate,
                              String technician,
                              BigDecimal maintenanceCost,
                              String vendor,
                              BigDecimal partsCost,
                              BigDecimal laborCost,
                              BigDecimal ignoredDuplicateMaintenanceCost,
                              String remarks,
                              String serviceReportPath,
                              LocalDateTime createdAt) {
        this.maintenanceId = maintenanceId;
        this.coolingUnit = coolingUnit;
        this.maintenanceType = maintenanceType;
        this.maintenanceDate = maintenanceDate;
        this.filterCleaningDate = filterCleaningDate;
        this.gasRefillDate = gasRefillDate;
        this.nextMaintenanceDate = nextMaintenanceDate;
        this.technician = technician;
        this.maintenanceCost = maintenanceCost != null ? maintenanceCost : ignoredDuplicateMaintenanceCost;
        this.vendor = vendor;
        this.partsCost = partsCost;
        this.laborCost = laborCost;
        this.remarks = remarks;
        this.serviceReportPath = serviceReportPath;
        this.createdAt = createdAt;
    }

    public static CoolingMaintenanceBuilder builder() {
        return new CoolingMaintenanceBuilder();
    }

    public static class CoolingMaintenanceBuilder {
        private Long maintenanceId;
        private CoolingUnit coolingUnit;
        private MaintenanceType maintenanceType;
        private LocalDate maintenanceDate;
        private LocalDate filterCleaningDate;
        private LocalDate gasRefillDate;
        private LocalDate nextMaintenanceDate;
        private String technician;
        private BigDecimal maintenanceCost;
        private String vendor;
        private BigDecimal partsCost;
        private BigDecimal laborCost;
        private String remarks;
        private String serviceReportPath;
        private LocalDateTime createdAt;

        CoolingMaintenanceBuilder() {
        }

        public CoolingMaintenanceBuilder maintenanceId(Long maintenanceId) {
            this.maintenanceId = maintenanceId;
            return this;
        }

        public CoolingMaintenanceBuilder coolingUnit(CoolingUnit coolingUnit) {
            this.coolingUnit = coolingUnit;
            return this;
        }

        public CoolingMaintenanceBuilder maintenanceType(MaintenanceType maintenanceType) {
            this.maintenanceType = maintenanceType;
            return this;
        }

        public CoolingMaintenanceBuilder maintenanceDate(LocalDate maintenanceDate) {
            this.maintenanceDate = maintenanceDate;
            return this;
        }

        public CoolingMaintenanceBuilder filterCleaningDate(LocalDate filterCleaningDate) {
            this.filterCleaningDate = filterCleaningDate;
            return this;
        }

        public CoolingMaintenanceBuilder gasRefillDate(LocalDate gasRefillDate) {
            this.gasRefillDate = gasRefillDate;
            return this;
        }

        public CoolingMaintenanceBuilder nextMaintenanceDate(LocalDate nextMaintenanceDate) {
            this.nextMaintenanceDate = nextMaintenanceDate;
            return this;
        }

        public CoolingMaintenanceBuilder technician(String technician) {
            this.technician = technician;
            return this;
        }

        public CoolingMaintenanceBuilder maintenanceCost(BigDecimal maintenanceCost) {
            this.maintenanceCost = maintenanceCost;
            return this;
        }

        public CoolingMaintenanceBuilder vendor(String vendor) {
            this.vendor = vendor;
            return this;
        }

        public CoolingMaintenanceBuilder partsCost(BigDecimal partsCost) {
            this.partsCost = partsCost;
            return this;
        }

        public CoolingMaintenanceBuilder laborCost(BigDecimal laborCost) {
            this.laborCost = laborCost;
            return this;
        }

        public CoolingMaintenanceBuilder remarks(String remarks) {
            this.remarks = remarks;
            return this;
        }

        public CoolingMaintenanceBuilder serviceReportPath(String serviceReportPath) {
            this.serviceReportPath = serviceReportPath;
            return this;
        }

        public CoolingMaintenanceBuilder createdAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public CoolingMaintenance build() {
            return new CoolingMaintenance(
                    maintenanceId,
                    coolingUnit,
                    maintenanceType,
                    maintenanceDate,
                    filterCleaningDate,
                    gasRefillDate,
                    nextMaintenanceDate,
                    technician,
                    maintenanceCost,
                    vendor,
                    partsCost,
                    laborCost,
                    maintenanceCost,
                    remarks,
                    serviceReportPath,
                    createdAt
            );
        }

        @Override
        public String toString() {
            return "CoolingMaintenance.CoolingMaintenanceBuilder(maintenanceId=" + maintenanceId +
                    ", coolingUnit=" + coolingUnit +
                    ", maintenanceType=" + maintenanceType +
                    ", maintenanceDate=" + maintenanceDate +
                    ", filterCleaningDate=" + filterCleaningDate +
                    ", gasRefillDate=" + gasRefillDate +
                    ", nextMaintenanceDate=" + nextMaintenanceDate +
                    ", technician=" + technician +
                    ", maintenanceCost=" + maintenanceCost +
                    ", vendor=" + vendor +
                    ", partsCost=" + partsCost +
                    ", laborCost=" + laborCost +
                    ", remarks=" + remarks +
                    ", serviceReportPath=" + serviceReportPath +
                    ", createdAt=" + createdAt + ")";
        }
    }

    public Long getMaintenanceId() {
        return maintenanceId;
    }

    public CoolingUnit getCoolingUnit() {
        return coolingUnit;
    }

    public MaintenanceType getMaintenanceType() {
        return maintenanceType;
    }

    public LocalDate getMaintenanceDate() {
        return maintenanceDate;
    }

    public LocalDate getFilterCleaningDate() {
        return filterCleaningDate;
    }

    public LocalDate getGasRefillDate() {
        return gasRefillDate;
    }

    public LocalDate getNextMaintenanceDate() {
        return nextMaintenanceDate;
    }

    public String getTechnician() {
        return technician;
    }

    public BigDecimal getMaintenanceCost() {
        return maintenanceCost;
    }

    public String getVendor() {
        return vendor;
    }

    public BigDecimal getPartsCost() {
        return partsCost;
    }

    public BigDecimal getLaborCost() {
        return laborCost;
    }

    public String getRemarks() {
        return remarks;
    }

    public String getServiceReportPath() {
        return serviceReportPath;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setMaintenanceId(Long maintenanceId) {
        this.maintenanceId = maintenanceId;
    }

    public void setCoolingUnit(CoolingUnit coolingUnit) {
        this.coolingUnit = coolingUnit;
    }

    public void setMaintenanceType(MaintenanceType maintenanceType) {
        this.maintenanceType = maintenanceType;
    }

    public void setMaintenanceDate(LocalDate maintenanceDate) {
        this.maintenanceDate = maintenanceDate;
    }

    public void setFilterCleaningDate(LocalDate filterCleaningDate) {
        this.filterCleaningDate = filterCleaningDate;
    }

    public void setGasRefillDate(LocalDate gasRefillDate) {
        this.gasRefillDate = gasRefillDate;
    }

    public void setNextMaintenanceDate(LocalDate nextMaintenanceDate) {
        this.nextMaintenanceDate = nextMaintenanceDate;
    }

    public void setTechnician(String technician) {
        this.technician = technician;
    }

    public void setMaintenanceCost(BigDecimal maintenanceCost) {
        this.maintenanceCost = maintenanceCost;
    }

    public void setVendor(String vendor) {
        this.vendor = vendor;
    }

    public void setPartsCost(BigDecimal partsCost) {
        this.partsCost = partsCost;
    }

    public void setLaborCost(BigDecimal laborCost) {
        this.laborCost = laborCost;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public void setServiceReportPath(String serviceReportPath) {
        this.serviceReportPath = serviceReportPath;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
