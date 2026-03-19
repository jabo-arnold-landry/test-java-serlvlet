package com.spcms.models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

/**
 * Report model for UPS device statistics and analytics
 */
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class UpsReport {

    private String reportId;
    private LocalDate reportDate;
    private LocalDateTime generatedAt;
    private ReportPeriod reportPeriod;  // DAILY, WEEKLY, MONTHLY
    private LocalDate periodStartDate;
    private LocalDate periodEndDate;

    // === Overall Statistics ===
    private Integer totalDevicesAdded;
    private Integer totalActiveDevices;
    private Integer totalFaultyDevices;
    private Integer totalUnderMaintenanceDevices;
    private Integer totalDecommissionedDevices;

    // === Capacity Statistics ===
    private BigDecimal totalCapacityKva;
    private BigDecimal averageCapacityKva;
    private BigDecimal maxCapacityKva;
    private BigDecimal minCapacityKva;

    // === Location Distribution ===
    private Map<String, Integer> devicesByLocation;  // Location -> Count
    private Map<String, Integer> devicesByStatus;    // Status -> Count
    private Map<String, Integer> devicesByBrand;     // Brand -> Count

    // === Device Details ===
    private List<UpsReportDetail> deviceDetails;

    // === Filter Criteria ===
    private String filterStatus;  // For filtering by status
    private String filterLocation; // For filtering by location

    public enum ReportPeriod {
        DAILY, WEEKLY, MONTHLY
    }

    /**
     * Inner class to hold individual device details in a report
     */
    @Getter @Setter
    @NoArgsConstructor @AllArgsConstructor
    @Builder
    public static class UpsReportDetail {
        private Long upsId;
        private String assetTag;
        private String upsName;
        private String brand;
        private String model;
        private String serialNumber;
        private BigDecimal capacityKva;
        private String status;
        private String locationRoom;
        private String locationRack;
        private String locationZone;
        private LocalDate installationDate;
        private LocalDateTime createdAt;
        private BigDecimal currentLoadKw;
        private BigDecimal loadPercentage;
    }
}
