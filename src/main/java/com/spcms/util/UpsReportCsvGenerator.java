package com.spcms.util;

import com.spcms.models.UpsReport;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * CSV Report Generator for UPS Reports
 * Uses built-in Java PrintWriter without external PDF libraries
 */
@Component
public class UpsReportCsvGenerator {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DATETIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * Generate CSV report from UpsReport object
     */
    public byte[] generateCsv(UpsReport report) throws java.io.IOException {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PrintWriter writer = new PrintWriter(outputStream);

        // Write header information
        writer.println("UPS Device Report");
        writer.println(report.getReportPeriod() + " Report: " + report.getPeriodStartDate() + " to " + report.getPeriodEndDate());
        writer.println("Generated on: " + report.getGeneratedAt().format(DATETIME_FORMATTER));
        
        if (report.getFilterStatus() != null || report.getFilterLocation() != null) {
            writer.print("Applied Filters: ");
            if (report.getFilterStatus() != null) {
                writer.print("Status=" + report.getFilterStatus() + " ");
            }
            if (report.getFilterLocation() != null) {
                writer.print("Location=" + report.getFilterLocation());
            }
            writer.println();
        }
        
        writer.println();
        writer.println();

        // Write summary statistics
        writer.println("SUMMARY STATISTICS");
        writer.println("Metric,Value");
        writer.println("Total Devices Added," + report.getTotalDevicesAdded());
        writer.println("Active Devices," + report.getTotalActiveDevices());
        writer.println("Faulty Devices," + report.getTotalFaultyDevices());
        writer.println("Under Maintenance," + report.getTotalUnderMaintenanceDevices());
        writer.println("Decommissioned," + report.getTotalDecommissionedDevices());

        writer.println();

        // Write capacity statistics
        if (report.getTotalCapacityKva() != null) {
            writer.println("CAPACITY STATISTICS (kVA)");
            writer.println("Metric,Value");
            writer.println("Total Capacity," + report.getTotalCapacityKva());
            writer.println("Average Capacity," + report.getAverageCapacityKva());
            writer.println("Maximum Capacity," + report.getMaxCapacityKva());
            writer.println("Minimum Capacity," + report.getMinCapacityKva());
            writer.println();
        }

        // Write location distribution
        if (report.getDevicesByLocation() != null && !report.getDevicesByLocation().isEmpty()) {
            writer.println("DISTRIBUTION BY LOCATION");
            writer.println("Location,Device Count");
            for (Map.Entry<String, Integer> entry : report.getDevicesByLocation().entrySet()) {
                writer.println(escapeCsv(entry.getKey()) + "," + entry.getValue());
            }
            writer.println();
        }

        // Write status distribution
        if (report.getDevicesByStatus() != null && !report.getDevicesByStatus().isEmpty()) {
            writer.println("DISTRIBUTION BY STATUS");
            writer.println("Status,Device Count");
            for (Map.Entry<String, Integer> entry : report.getDevicesByStatus().entrySet()) {
                writer.println(escapeCsv(entry.getKey()) + "," + entry.getValue());
            }
            writer.println();
        }

        // Write brand distribution
        if (report.getDevicesByBrand() != null && !report.getDevicesByBrand().isEmpty()) {
            writer.println("DISTRIBUTION BY BRAND");
            writer.println("Brand,Device Count");
            for (Map.Entry<String, Integer> entry : report.getDevicesByBrand().entrySet()) {
                writer.println(escapeCsv(entry.getKey()) + "," + entry.getValue());
            }
            writer.println();
        }

        // Write device details
        if (report.getDeviceDetails() != null && !report.getDeviceDetails().isEmpty()) {
            writer.println("DEVICE DETAILS");
            writer.println("Asset Tag,Device Name,Brand,Model,Serial Number,Capacity (kVA),Status,Location,Installation Date");
            for (UpsReport.UpsReportDetail detail : report.getDeviceDetails()) {
                writer.println(
                    escapeCsv(detail.getAssetTag()) + "," +
                    escapeCsv(detail.getUpsName()) + "," +
                    escapeCsv(detail.getBrand()) + "," +
                    escapeCsv(detail.getModel()) + "," +
                    escapeCsv(detail.getSerialNumber()) + "," +
                    (detail.getCapacityKva() != null ? detail.getCapacityKva() : "N/A") + "," +
                    escapeCsv(detail.getStatus()) + "," +
                    escapeCsv(detail.getLocationRoom()) + "," +
                    (detail.getInstallationDate() != null ? detail.getInstallationDate().format(DATE_FORMATTER) : "N/A")
                );
            }
        }

        writer.flush();
        writer.close();
        return outputStream.toByteArray();
    }

    /**
     * Escape CSV special characters
     */
    private String escapeCsv(String value) {
        if (value == null) {
            return "N/A";
        }
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
