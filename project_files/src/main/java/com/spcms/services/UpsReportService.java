package com.spcms.services;

import com.spcms.models.Ups;
import com.spcms.models.UpsReport;
import com.spcms.repositories.UpsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class UpsReportService {

    @Autowired
    private UpsRepository upsRepository;

    /**
     * Generate a report for a specific period
     */
    public UpsReport generateReport(UpsReport.ReportPeriod period, LocalDate reportDate,
            String filterStatus, String filterLocation) {

        try {
            System.out.println("[UpsReportService] Starting report generation");
            System.out.println("[UpsReportService] Period: " + period);
            System.out.println("[UpsReportService] ReportDate: " + reportDate);
            System.out.println("[UpsReportService] FilterStatus: " + filterStatus);
            System.out.println("[UpsReportService] FilterLocation: " + filterLocation);

            LocalDateTime startDateTime;
            LocalDateTime endDateTime;

            // Calculate date range based on period
            switch (period) {
                case DAILY:
                    startDateTime = reportDate.atStartOfDay();
                    endDateTime = reportDate.plusDays(1).atStartOfDay();
                    break;
                case WEEKLY:
                    LocalDate weekStart = reportDate.minusDays(reportDate.getDayOfWeek().getValue() - 1);
                    LocalDate weekEnd = weekStart.plusDays(7);
                    startDateTime = weekStart.atStartOfDay();
                    endDateTime = weekEnd.atStartOfDay();
                    break;
                case MONTHLY:
                    LocalDate monthStart = reportDate.withDayOfMonth(1);
                    LocalDate monthEnd = monthStart.plusMonths(1);
                    startDateTime = monthStart.atStartOfDay();
                    endDateTime = monthEnd.atStartOfDay();
                    break;
                default:
                    throw new IllegalArgumentException("Invalid report period: " + period);
            }

            System.out.println("[UpsReportService] Date Range: " + startDateTime + " to " + endDateTime);

            // Fetch devices based on filters
            System.out.println("[UpsReportService] Fetching devices from repository...");
            List<Ups> devices = fetchDevicesByFilters(startDateTime, endDateTime, filterStatus, filterLocation);
            System.out.println("[UpsReportService] Found " + devices.size() + " devices");

            // Build and populate the report
            System.out.println("[UpsReportService] Building report...");
            UpsReport report = buildUpsReport(period, reportDate, devices, startDateTime.toLocalDate(),
                    endDateTime.toLocalDate(), filterStatus, filterLocation);
            System.out.println("[UpsReportService] Report generated successfully");
            return report;
        } catch (Exception e) {
            System.err.println("[UpsReportService] ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            throw e;
        }
    }

    /**
     * Fetch devices by applying filters
     */
    private List<Ups> fetchDevicesByFilters(LocalDateTime startDate, LocalDateTime endDate, String filterStatus,
            String filterLocation) {

        try {
            System.out.println("[UpsReportService] fetchDevicesByFilters called");
            System.out.println(
                    "[UpsReportService] FilterStatus: " + filterStatus + ", FilterLocation: " + filterLocation);

            if (filterStatus != null && !filterStatus.isEmpty() && filterLocation != null
                    && !filterLocation.isEmpty()) {
                System.out.println("[UpsReportService] Applying BOTH status and location filters");
                return upsRepository.findByDateRangeStatusAndLocation(startDate, endDate,
                        Ups.UpsStatus.valueOf(filterStatus), filterLocation);
            } else if (filterStatus != null && !filterStatus.isEmpty()) {
                System.out.println("[UpsReportService] Applying status filter only");
                return upsRepository.findByDateRangeAndStatus(startDate, endDate,
                        Ups.UpsStatus.valueOf(filterStatus));
            } else if (filterLocation != null && !filterLocation.isEmpty()) {
                System.out.println("[UpsReportService] Applying location filter only");
                return upsRepository.findByDateRangeAndLocation(startDate, endDate, filterLocation);
            } else {
                System.out.println("[UpsReportService] Applying NO filters - fetching all devices");
                return upsRepository.findByDateRange(startDate, endDate);
            }
        } catch (Exception e) {
            System.err.println("[UpsReportService] ERROR in fetchDevicesByFilters: " + e.getMessage());
            e.printStackTrace(System.err);
            throw e;
        }
    }

    /**
     * Build the complete report with statistics
     */
    private UpsReport buildUpsReport(UpsReport.ReportPeriod period, LocalDate reportDate,
            List<Ups> devices, LocalDate startDate, LocalDate endDate,
            String filterStatus, String filterLocation) {

        UpsReport report = UpsReport.builder()
                .generatedAt(LocalDateTime.now())
                .reportPeriod(period.name()) // added .name() to convert enum to String
                .periodStartDate(startDate)
                .periodEndDate(endDate)
                .filterStatus(filterStatus)
                .filterLocation(filterLocation)
                .build();

        // Calculate statistics
        calculateStatistics(report, devices);

        // Convert devices to report details
        report.setDeviceDetails(devices.stream()
                .map(this::convertToReportDetail)
                .collect(Collectors.toList()));

        return report;
    }

    /**
     * Calculate report statistics
     */
    private void calculateStatistics(UpsReport report, List<Ups> devices) {

        report.setTotalDevicesAdded(devices.size());

        // Status breakdown
        Map<String, Integer> statusCount = devices.stream()
                .collect(Collectors.groupingBy(
                        u -> u.getStatus().toString(),
                        Collectors.summingInt(u -> 1)));
        report.setDevicesByStatus(statusCount);

        report.setTotalActiveDevices(statusCount.getOrDefault("ACTIVE", 0));
        report.setTotalFaultyDevices(statusCount.getOrDefault("FAULTY", 0));
        report.setTotalUnderMaintenanceDevices(statusCount.getOrDefault("UNDER_MAINTENANCE", 0));
        report.setTotalDecommissionedDevices(statusCount.getOrDefault("DECOMMISSIONED", 0));

        // Location distribution
        Map<String, Integer> locationCount = devices.stream()
                .collect(Collectors.groupingBy(
                        u -> u.getLocationRoom() != null ? u.getLocationRoom() : "Unknown",
                        Collectors.summingInt(u -> 1)));
        report.setDevicesByLocation(locationCount);

        // Brand distribution
        Map<String, Integer> brandCount = devices.stream()
                .collect(Collectors.groupingBy(
                        u -> u.getBrand() != null ? u.getBrand() : "Unknown",
                        Collectors.summingInt(u -> 1)));
        report.setDevicesByBrand(brandCount);

        // Capacity statistics
        List<BigDecimal> capacities = devices.stream()
                .map(Ups::getCapacityKva)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (!capacities.isEmpty()) {
            BigDecimal totalCapacity = capacities.stream()
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            report.setTotalCapacityKva(totalCapacity);
            report.setAverageCapacityKva(
                    totalCapacity.divide(BigDecimal.valueOf(capacities.size()), 2, RoundingMode.HALF_UP));
            report.setMaxCapacityKva(capacities.stream().max(BigDecimal::compareTo).orElse(BigDecimal.ZERO));
            report.setMinCapacityKva(capacities.stream().min(BigDecimal::compareTo).orElse(BigDecimal.ZERO));
        }
    }

    /**
     * Convert Ups entity to UpsReportDetail
     */
    private UpsReport.UpsReportDetail convertToReportDetail(Ups ups) {
        return UpsReport.UpsReportDetail.builder()
                .assetTag(ups.getAssetTag())
                .upsName(ups.getUpsName())
                .brand(ups.getBrand())
                .model(ups.getModel())
                .serialNumber(ups.getSerialNumber())
                .capacityKva(ups.getCapacityKva())
                .status(ups.getStatus().toString())
                .locationRoom(ups.getLocationRoom())
                .installationDate(ups.getInstallationDate())
                .loadPercentage(ups.getLoadPercentage())
                .build();
    }

    /**
     * Generate a unique report ID
     */
    private String generateReportId(UpsReport.ReportPeriod period, LocalDate reportDate) {
        return String.format("UPS-%s-%s-%d", period.name().substring(0, 3), reportDate, System.currentTimeMillis());
    }

    /**
     * Get all unique locations for filter dropdown
     */
    public List<String> getAllLocations() {
        try {
            return upsRepository.findAll().stream()
                    .map(Ups::getLocationRoom)
                    .filter(Objects::nonNull)
                    .distinct()
                    .sorted()
                    .collect(Collectors.toList());
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    /**
     * Get all unique statuses for filter dropdown
     */
    public List<String> getAllStatuses() {
        try {
            return Arrays.stream(Ups.UpsStatus.values())
                    .map(Enum::toString)
                    .sorted()
                    .collect(Collectors.toList());
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }
}
