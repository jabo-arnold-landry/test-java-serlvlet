package com.spcms.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "equipment")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Equipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "equipment_id")
    private Long equipmentId;

    @NotBlank
    @Column(name = "asset_tag_number", nullable = false, unique = true, length = 50)
    private String assetTagNumber;

    @NotBlank
    @Column(name = "equipment_name", nullable = false, length = 100)
    private String equipmentName;

    @Column(name = "equipment_type", length = 50)
    private String equipmentType;

    @Column(name = "brand_manufacturer", length = 100)
    private String brandManufacturer;

    @Column(name = "model_number", length = 50)
    private String modelNumber;

    @Column(name = "serial_number", unique = true, length = 100)
    private String serialNumber;

    @Column(length = 100)
    private String hostname;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "mac_address", length = 50)
    private String macAddress;

    // === Location Information ===

    @Column(name = "data_center_name", length = 100)
    private String dataCenterName;

    @Column(name = "room_name", length = 100)
    private String roomName;

    @Column(name = "rack_number", length = 50)
    private String rackNumber;

    @Column(name = "rack_unit_position", length = 20)
    private String rackUnitPosition;

    @Column(name = "physical_location", length = 200)
    private String physicalLocation;

    @Column(name = "google_maps_location", length = 500)
    private String googleMapsLocation;

    // === Technical Specifications ===

    @Column(name = "cpu_type", length = 100)
    private String cpuType;

    @Column(name = "ram_size", length = 50)
    private String ramSize;

    @Column(name = "storage_capacity", length = 50)
    private String storageCapacity;

    @Column(name = "power_rating", length = 50)
    private String powerRating;

    @Column(name = "firmware_version", length = 50)
    private String firmwareVersion;

    @Column(name = "operating_system", length = 100)
    private String operatingSystem;

    @Column(name = "network_ports_count")
    private Integer networkPortsCount;

    @Column(name = "vlan_assignment", length = 50)
    private String vlanAssignment;

    // === Procurement Information ===

    @Column(name = "purchase_date")
    private LocalDate purchaseDate;

    @Column(name = "supplier_name", length = 100)
    private String supplierName;

    @Column(name = "purchase_order_number", length = 50)
    private String purchaseOrderNumber;

    @Column(name = "invoice_number", length = 50)
    private String invoiceNumber;

    @Column(name = "warranty_start_date")
    private LocalDate warrantyStartDate;

    @Column(name = "warranty_expiry_date")
    private LocalDate warrantyExpiryDate;

    @Column(precision = 12, scale = 2)
    private BigDecimal cost;

    @Column(name = "funding_source", length = 100)
    private String fundingSource;

    // === Maintenance & Support ===

    @Enumerated(EnumType.STRING)
    @Column(name = "maintenance_status", length = 20)
    private MaintenanceStatus maintenanceStatus = MaintenanceStatus.ACTIVE;

    @Column(name = "last_maintenance_date")
    private LocalDate lastMaintenanceDate;

    @Column(name = "next_maintenance_due")
    private LocalDate nextMaintenanceDue;

    @Column(name = "maintenance_type", length = 15)
    private String maintenanceType;

    @Column(name = "support_vendor", length = 100)
    private String supportVendor;

    @Column(name = "amc_contract_details", columnDefinition = "TEXT")
    private String amcContractDetails;

    @Column(name = "spare_parts_availability", columnDefinition = "TEXT")
    private String sparePartsAvailability;

    @Column(name = "incident_history", columnDefinition = "TEXT")
    private String incidentHistory;

    // === Power & Environmental Monitoring ===

    @Column(name = "power_source", length = 100)
    private String powerSource;

    @Column(name = "connected_pdu", length = 50)
    private String connectedPdu;

    @Column(name = "temperature_range", length = 50)
    private String temperatureRange;

    @Column(name = "humidity_level", length = 50)
    private String humidityLevel;

    @Column(name = "power_consumption", precision = 10, scale = 2)
    private BigDecimal powerConsumption;

    @Column(name = "cooling_zone", length = 50)
    private String coolingZone;

    // === Lifecycle Management ===

    @Column(name = "installation_date")
    private LocalDate installationDate;

    @Column(name = "commissioning_date")
    private LocalDate commissioningDate;

    @Column(name = "end_of_life")
    private LocalDate endOfLife;

    @Column(name = "end_of_support")
    private LocalDate endOfSupport;

    @Column(name = "disposal_date")
    private LocalDate disposalDate;

    @Column(name = "disposal_method", length = 100)
    private String disposalMethod;

    @Column(name = "reason_for_decommission", columnDefinition = "TEXT")
    private String reasonForDecommission;

    // === Documentation & Attachments ===

    @Column(name = "config_file_path", length = 500)
    private String configFilePath;

    @Column(name = "network_diagram_ref", length = 500)
    private String networkDiagramRef;

    @Column(name = "rack_layout_diagram", length = 500)
    private String rackLayoutDiagram;

    @Column(name = "maintenance_report_path", length = 500)
    private String maintenanceReportPath;

    @Column(name = "photos_path", length = 500)
    private String photosPath;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum MaintenanceStatus {
        ACTIVE, FAULTY, UNDER_REPAIR, DECOMMISSIONED
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
