package com.spcms.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spcms.dto.reports.ReportFilterDto;
import com.spcms.models.ReportLog;
import com.spcms.util.ComplianceReportExportUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Service
public class ComplianceReportExportService {

    private final ComplianceReportService complianceReportService;
    private final ComplianceReportExportUtil exportUtil;
    private final ReportLogService reportLogService;
    private final ObjectMapper objectMapper;

    @Value("${file.upload-dir:./uploads}")
    private String uploadDir;

    public ComplianceReportExportService(ComplianceReportService complianceReportService,
                                         ComplianceReportExportUtil exportUtil,
                                         ReportLogService reportLogService,
                                         ObjectMapper objectMapper) {
        this.complianceReportService = complianceReportService;
        this.exportUtil = exportUtil;
        this.reportLogService = reportLogService;
        this.objectMapper = objectMapper;
    }

    public ExportPayload export(String reportType,
                                String format,
                                ReportFilterDto filter,
                                Long shiftId,
                                boolean autoGenerate,
                                String username) throws IOException {
        String lowerReportType = reportType.toLowerCase();
        String lowerFormat = format.toLowerCase();
        String filtersUsed = objectMapper.writeValueAsString(filter);

        try {
            List<?> rows = switch (lowerReportType) {
                case "equipment-health" -> complianceReportService.getEquipmentHealthReport(filter).getRows();
                case "maintenance" -> complianceReportService.getMaintenanceHistoryReport(filter).getRows();
                case "incidents" -> complianceReportService.getIncidentDowntimeReport(filter).getRows();
                case "shift" -> complianceReportService.getShiftTechnicianReport(shiftId, filter).getRows();
                case "daily" -> complianceReportService.getDailyConsolidatedReport(filter, autoGenerate).getRows();
                case "compliance" -> complianceReportService.getComplianceReport(filter).getRows();
                default -> throw new IllegalArgumentException("Unsupported reportType: " + reportType);
            };

            byte[] body;
            String contentType;
            if ("pdf".equals(lowerFormat)) {
                body = exportUtil.toPdf(reportType + " report", rows);
                contentType = MediaType.APPLICATION_PDF_VALUE;
            } else {
                body = exportUtil.toCsv(rows);
                contentType = "text/csv";
            }

            String fileName = buildFileName(lowerReportType, lowerFormat);
            String relativePath = persistFile(fileName, body);

            reportLogService.saveExportLog(lowerReportType, username, lowerFormat.toUpperCase(), relativePath,
                    filtersUsed, ReportLog.ExportStatus.SUCCESS, null);

            return new ExportPayload(fileName, contentType, body, relativePath);
        } catch (Exception ex) {
            reportLogService.saveExportLog(lowerReportType, username, lowerFormat.toUpperCase(), null,
                    filtersUsed, ReportLog.ExportStatus.FAILED, ex.getMessage());
            if (ex instanceof IOException ioException) {
                throw ioException;
            }
            throw new IOException("Failed to export report: " + ex.getMessage(), ex);
        }
    }

    private String buildFileName(String reportType, String format) {
        String stamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
        return reportType + "-" + stamp + "." + format;
    }

    private String persistFile(String fileName, byte[] body) throws IOException {
        Path folder = Paths.get(uploadDir).toAbsolutePath().normalize().resolve("reports");
        Files.createDirectories(folder);
        Path filePath = folder.resolve(fileName);
        Files.write(filePath, body);
        return "/uploads/reports/" + fileName;
    }

    public record ExportPayload(String fileName, String contentType, byte[] body, String filePath) {
    }
}
