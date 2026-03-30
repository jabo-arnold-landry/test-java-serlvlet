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
@Table(name = "ups_maintenance")
public class UpsMaintenance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "maintenance_id")
    private Long maintenanceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ups_id", nullable = false)
    private Ups ups;

    @Convert(converter = MaintenanceTypeConverter.class)
    @Column(name = "maintenance_type", nullable = false, length = 20)
    private MaintenanceType maintenanceType;

    @Column(name = "maintenance_date", nullable = false)
    private LocalDate maintenanceDate;

    @Column(name = "next_due_date")
    private LocalDate nextDueDate;

    @Column(name = "technician", length = 100)
    private String technician;

    @Column(name = "vendor", length = 100)
    private String vendor;

    @Column(name = "spare_parts_used", columnDefinition = "TEXT")
    private String sparePartsUsed;

    @Column(name = "maintenance_cost", precision = 12, scale = 2)
    private BigDecimal maintenanceCost;

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

    public UpsMaintenance() {
    }

    // Kept for binary compatibility with previously generated Lombok constructor
    public UpsMaintenance(Long maintenanceId,
                          Ups ups,
                          MaintenanceType maintenanceType,
                          LocalDate maintenanceDate,
                          LocalDate nextDueDate,
                          String technician,
                          String vendor,
                          String sparePartsUsed,
                          BigDecimal maintenanceCost,
                          BigDecimal partsCost,
                          BigDecimal laborCost,
                          String remarks,
                          String serviceReportPath,
                          BigDecimal ignoredDuplicateMaintenanceCost,
                          LocalDateTime createdAt) {
        this.maintenanceId = maintenanceId;
        this.ups = ups;
        this.maintenanceType = maintenanceType;
        this.maintenanceDate = maintenanceDate;
        this.nextDueDate = nextDueDate;
        this.technician = technician;
        this.vendor = vendor;
        this.sparePartsUsed = sparePartsUsed;
        this.maintenanceCost = maintenanceCost != null ? maintenanceCost : ignoredDuplicateMaintenanceCost;
        this.partsCost = partsCost;
        this.laborCost = laborCost;
        this.remarks = remarks;
        this.serviceReportPath = serviceReportPath;
        this.createdAt = createdAt;
    }

    public static UpsMaintenanceBuilder builder() {
        return new UpsMaintenanceBuilder();
    }

    public static class UpsMaintenanceBuilder {
        private Long maintenanceId;
        private Ups ups;
        private MaintenanceType maintenanceType;
        private LocalDate maintenanceDate;
        private LocalDate nextDueDate;
        private String technician;
        private String vendor;
        private String sparePartsUsed;
        private BigDecimal maintenanceCost;
        private BigDecimal partsCost;
        private BigDecimal laborCost;
        private String remarks;
        private String serviceReportPath;
        private LocalDateTime createdAt;

        UpsMaintenanceBuilder() {
        }

        public UpsMaintenanceBuilder maintenanceId(Long maintenanceId) {
            this.maintenanceId = maintenanceId;
            return this;
        }

        public UpsMaintenanceBuilder ups(Ups ups) {
            this.ups = ups;
            return this;
        }

        public UpsMaintenanceBuilder maintenanceType(MaintenanceType maintenanceType) {
            this.maintenanceType = maintenanceType;
            return this;
        }

        public UpsMaintenanceBuilder maintenanceDate(LocalDate maintenanceDate) {
            this.maintenanceDate = maintenanceDate;
            return this;
        }

        public UpsMaintenanceBuilder nextDueDate(LocalDate nextDueDate) {
            this.nextDueDate = nextDueDate;
            return this;
        }

        public UpsMaintenanceBuilder technician(String technician) {
            this.technician = technician;
            return this;
        }

        public UpsMaintenanceBuilder vendor(String vendor) {
            this.vendor = vendor;
            return this;
        }

        public UpsMaintenanceBuilder sparePartsUsed(String sparePartsUsed) {
            this.sparePartsUsed = sparePartsUsed;
            return this;
        }

        public UpsMaintenanceBuilder maintenanceCost(BigDecimal maintenanceCost) {
            this.maintenanceCost = maintenanceCost;
            return this;
        }

        public UpsMaintenanceBuilder partsCost(BigDecimal partsCost) {
            this.partsCost = partsCost;
            return this;
        }

        public UpsMaintenanceBuilder laborCost(BigDecimal laborCost) {
            this.laborCost = laborCost;
            return this;
        }

        public UpsMaintenanceBuilder remarks(String remarks) {
            this.remarks = remarks;
            return this;
        }

        public UpsMaintenanceBuilder serviceReportPath(String serviceReportPath) {
            this.serviceReportPath = serviceReportPath;
            return this;
        }

        public UpsMaintenanceBuilder createdAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public UpsMaintenance build() {
            return new UpsMaintenance(
                    maintenanceId,
                    ups,
                    maintenanceType,
                    maintenanceDate,
                    nextDueDate,
                    technician,
                    vendor,
                    sparePartsUsed,
                    maintenanceCost,
                    partsCost,
                    laborCost,
                    remarks,
                    serviceReportPath,
                    maintenanceCost,
                    createdAt
            );
        }

        @Override
        public String toString() {
            return "UpsMaintenance.UpsMaintenanceBuilder(maintenanceId=" + maintenanceId +
                    ", ups=" + ups +
                    ", maintenanceType=" + maintenanceType +
                    ", maintenanceDate=" + maintenanceDate +
                    ", nextDueDate=" + nextDueDate +
                    ", technician=" + technician +
                    ", vendor=" + vendor +
                    ", sparePartsUsed=" + sparePartsUsed +
                    ", maintenanceCost=" + maintenanceCost +
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

    public Ups getUps() {
        return ups;
    }

    public MaintenanceType getMaintenanceType() {
        return maintenanceType;
    }

    public LocalDate getMaintenanceDate() {
        return maintenanceDate;
    }

    public LocalDate getNextDueDate() {
        return nextDueDate;
    }

    public String getTechnician() {
        return technician;
    }

    public String getVendor() {
        return vendor;
    }

    public String getSparePartsUsed() {
        return sparePartsUsed;
    }

    public BigDecimal getMaintenanceCost() {
        return maintenanceCost;
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

    public void setUps(Ups ups) {
        this.ups = ups;
    }

    public void setMaintenanceType(MaintenanceType maintenanceType) {
        this.maintenanceType = maintenanceType;
    }

    public void setMaintenanceDate(LocalDate maintenanceDate) {
        this.maintenanceDate = maintenanceDate;
    }

    public void setNextDueDate(LocalDate nextDueDate) {
        this.nextDueDate = nextDueDate;
    }

    public void setTechnician(String technician) {
        this.technician = technician;
    }

    public void setVendor(String vendor) {
        this.vendor = vendor;
    }

    public void setSparePartsUsed(String sparePartsUsed) {
        this.sparePartsUsed = sparePartsUsed;
    }

    public void setMaintenanceCost(BigDecimal maintenanceCost) {
        this.maintenanceCost = maintenanceCost;
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
